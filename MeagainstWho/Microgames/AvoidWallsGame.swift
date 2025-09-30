import SpriteKit

class AvoidWallsGame: Microgame {
    private weak var scene: SKScene?
    private var player: SKShapeNode?
    private var walls: [SKNode] = []
    private var isRising = false
    private var wallTimer: Timer?
    private var score = 0
    private var targetScore = 10
    
    func start(in scene: SKScene) {
        self.scene = scene
        setupPlayer()
        startWallSpawning()
    }
    
    private func setupPlayer() {
        guard let scene = scene else { return }
        
        player = SKShapeNode(circleOfRadius: 20)
        player?.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0)
        player?.strokeColor = .white
        player?.lineWidth = 2
        player?.position = CGPoint(x: scene.frame.midX, y: 150)
        scene.addChild(player!)
        
        // Add subtle animation
        let float = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 5, duration: 0.5),
            SKAction.moveBy(x: 0, y: -5, duration: 0.5)
        ])
        player?.run(SKAction.repeatForever(float))
    }
    
    private func startWallSpawning() {
        wallTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            self?.spawnWall()
        }
        
        // Initial wall
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.spawnWall()
        }
    }
    
    private func spawnWall() {
        guard let scene = scene else { return }
        
        let wall = createWall()
        wall.position = CGPoint(x: scene.frame.midX, y: scene.frame.height + 50)
        scene.addChild(wall)
        walls.append(wall)
        
        // Animate wall moving down
        let moveAction = SKAction.moveTo(y: -50, duration: 3.0)
        wall.run(moveAction) {
            self.wallPassed(wall)
        }
    }
    
    private func createWall() -> SKNode {
        let wall = SKNode()
        
        // Create gap in wall
        let gapWidth: CGFloat = 100
        let wallHeight: CGFloat = 200
        
        // Top wall
        let topWall = SKShapeNode(rectOf: CGSize(width: scene?.frame.width ?? 400, height: wallHeight))
        topWall.fillColor = .red
        topWall.strokeColor = .white
        topWall.lineWidth = 2
        topWall.position = CGPoint(x: 0, y: gapWidth/2 + wallHeight/2)
        wall.addChild(topWall)
        
        // Bottom wall
        let bottomWall = SKShapeNode(rectOf: CGSize(width: scene?.frame.width ?? 400, height: wallHeight))
        bottomWall.fillColor = .red
        bottomWall.strokeColor = .white
        bottomWall.lineWidth = 2
        bottomWall.position = CGPoint(x: 0, y: -gapWidth/2 - wallHeight/2)
        wall.addChild(bottomWall)
        
        return wall
    }
    
    private func wallPassed(_ wall: SKNode) {
        // Remove from walls array
        if let index = walls.firstIndex(of: wall) {
            walls.remove(at: index)
        }
        
        // Remove wall
        wall.removeFromParent()
        
        // Increment score
        score += 1
        
        // Visual feedback
        createScoreEffect()
        
        // Haptic feedback
        HapticsService.shared.light()
        
        // Check if target reached
        if score >= targetScore {
            // Success!
            wallTimer?.invalidate()
            wallTimer = nil
            HapticsService.shared.success()
            AudioService.shared.playSuccessSound()
            createSuccessEffect()
        }
    }
    
    private func createScoreEffect() {
        guard let scene = scene else { return }
        
        // Score text
        let scoreText = SKLabelNode(fontNamed: "Arial-Bold")
        scoreText.text = "+1"
        scoreText.fontSize = 20
        scoreText.fontColor = .white
        scoreText.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        scene.addChild(scoreText)
        
        scoreText.run(SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 50, duration: 1.0),
                SKAction.fadeOut(withDuration: 1.0)
            ]),
            SKAction.removeFromParent()
        ]))
    }
    
    private func createSuccessEffect() {
        guard let scene = scene else { return }
        
        // Success particles
        for _ in 0..<20 {
            let particle = SKShapeNode(circleOfRadius: 4)
            particle.fillColor = SKColor.random()
            particle.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
            scene.addChild(particle)
            
            let randomX = CGFloat.random(in: -100...100)
            let randomY = CGFloat.random(in: -100...100)
            
            particle.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: CGPoint(x: scene.frame.midX + randomX, y: scene.frame.midY + randomY), duration: 1.0),
                    SKAction.fadeOut(withDuration: 1.0)
                ]),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    func update(_ currentTime: TimeInterval) {
        // Check if target score reached
        if score >= targetScore {
            // Success!
            wallTimer?.invalidate()
            wallTimer = nil
            HapticsService.shared.success()
            AudioService.shared.playSuccessSound()
            createSuccessEffect()
        }
        
        // Update player position
        if isRising {
            player?.position.y += 5
        } else {
            player?.position.y -= 3
        }
        
        // Keep player in bounds
        guard let scene = scene else { return }
        player?.position.y = max(50, min(scene.frame.height - 50, player?.position.y ?? 150))
        
        // Check collisions with walls
        checkCollisions()
    }
    
    private func checkCollisions() {
        guard let player = player else { return }
        
        for wall in walls {
            if wall.contains(player.position) {
                // Collision!
                gameOver()
                break
            }
        }
    }
    
    private func gameOver() {
        // Stop wall spawning
        wallTimer?.invalidate()
        wallTimer = nil
        
        // Visual feedback
        createGameOverEffect()
        
        // Haptic feedback
        HapticsService.shared.error()
        
        // Sound
        AudioService.shared.playFailSound()
    }
    
    private func createGameOverEffect() {
        guard let scene = scene else { return }
        
        // Flash effect
        let flash = SKShapeNode(rect: scene.frame)
        flash.fillColor = .red
        flash.alpha = 0.5
        scene.addChild(flash)
        
        flash.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
        
        // Shake effect
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -10, y: 0, duration: 0.1),
            SKAction.moveBy(x: 20, y: 0, duration: 0.1),
            SKAction.moveBy(x: -10, y: 0, duration: 0.1)
        ])
        scene.run(shake)
    }
    
    func handleTouch(_ location: CGPoint) {
        // Start rising
        isRising = true
        
        // Haptic feedback
        HapticsService.shared.light()
    }
    
    func teardown() {
        wallTimer?.invalidate()
        wallTimer = nil
        player?.removeFromParent()
        player = nil
        walls.removeAll()
        isRising = false
        score = 0
    }
}