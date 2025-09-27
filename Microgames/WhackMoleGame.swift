import SpriteKit

class WhackMoleGame: Microgame {
    private weak var scene: SKScene?
    private var moles: [SKNode] = []
    private var holes: [SKNode] = []
    private var whackedCount = 0
    private var targetCount = 5
    private var moleTimer: Timer?
    
    func start(in scene: SKScene) {
        self.scene = scene
        setupHoles()
        startMoleSpawning()
    }
    
    private func setupHoles() {
        guard let scene = scene else { return }
        
        let holePositions = [
            CGPoint(x: 100, y: 200),
            CGPoint(x: 200, y: 200),
            CGPoint(x: 300, y: 200),
            CGPoint(x: 100, y: 300),
            CGPoint(x: 200, y: 300),
            CGPoint(x: 300, y: 300)
        ]
        
        for position in holePositions {
            let hole = createHole()
            hole.position = position
            scene.addChild(hole)
            holes.append(hole)
        }
    }
    
    private func createHole() -> SKNode {
        let hole = SKNode()
        
        // Hole background
        let background = SKShapeNode(circleOfRadius: 30)
        background.fillColor = .brown
        background.strokeColor = .white
        background.lineWidth = 2
        hole.addChild(background)
        
        // Hole shadow
        let shadow = SKShapeNode(circleOfRadius: 25)
        shadow.fillColor = .black
        shadow.alpha = 0.3
        shadow.position = CGPoint(x: 0, y: -5)
        hole.addChild(shadow)
        
        return hole
    }
    
    private func startMoleSpawning() {
        moleTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.spawnMole()
        }
        
        // Initial mole
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.spawnMole()
        }
    }
    
    private func spawnMole() {
        guard let scene = scene, !holes.isEmpty else { return }
        
        // Pick random hole
        let randomHole = holes.randomElement()!
        
        // Create mole
        let mole = createMole()
        mole.position = randomHole.position
        mole.alpha = 0
        mole.setScale(0.5)
        scene.addChild(mole)
        moles.append(mole)
        
        // Animate mole appearing
        mole.run(SKAction.group([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ]))
        
        // Auto-hide after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if self.moles.contains(mole) {
                self.hideMole(mole)
            }
        }
    }
    
    private func createMole() -> SKNode {
        let mole = SKNode()
        
        // Mole body
        let body = SKShapeNode(circleOfRadius: 20)
        body.fillColor = .brown
        body.strokeColor = .white
        body.lineWidth = 2
        mole.addChild(body)
        
        // Mole eyes
        let leftEye = SKShapeNode(circleOfRadius: 3)
        leftEye.fillColor = .black
        leftEye.position = CGPoint(x: -8, y: 5)
        mole.addChild(leftEye)
        
        let rightEye = SKShapeNode(circleOfRadius: 3)
        rightEye.fillColor = .black
        rightEye.position = CGPoint(x: 8, y: 5)
        mole.addChild(rightEye)
        
        // Mole nose
        let nose = SKShapeNode(circleOfRadius: 2)
        nose.fillColor = .black
        nose.position = CGPoint(x: 0, y: 0)
        mole.addChild(nose)
        
        // Add bobbing animation
        let bob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 5, duration: 0.5),
            SKAction.moveBy(x: 0, y: -5, duration: 0.5)
        ])
        mole.run(SKAction.repeatForever(bob))
        
        return mole
    }
    
    private func hideMole(_ mole: SKNode) {
        // Remove from moles array
        if let index = moles.firstIndex(of: mole) {
            moles.remove(at: index)
        }
        
        // Animate mole hiding
        mole.run(SKAction.group([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.scale(to: 0.5, duration: 0.3)
        ])) {
            mole.removeFromParent()
        }
    }
    
    func update(_ currentTime: TimeInterval) {
        // Check if target count reached
        if whackedCount >= targetCount {
            // Success!
            moleTimer?.invalidate()
            moleTimer = nil
            HapticsService.shared.success()
            AudioService.shared.playSuccessSound()
            createSuccessEffect()
        }
    }
    
    func handleTouch(_ location: CGPoint) {
        for (index, mole) in moles.enumerated() {
            if mole.contains(location) {
                whackMole(mole, at: index)
                break
            }
        }
    }
    
    private func whackMole(_ mole: SKNode, at index: Int) {
        // Remove from moles array
        moles.remove(at: index)
        
        // Create whack effect
        createWhackEffect(at: mole.position)
        
        // Remove mole
        mole.removeFromParent()
        
        // Increment count
        whackedCount += 1
        
        // Haptic feedback
        HapticsService.shared.medium()
        
        // Sound
        AudioService.shared.playSound("beep")
    }
    
    private func createWhackEffect(at position: CGPoint) {
        guard let scene = scene else { return }
        
        // Create particle burst
        for _ in 0..<10 {
            let particle = SKShapeNode(circleOfRadius: 3)
            particle.fillColor = SKColor.random()
            particle.position = position
            scene.addChild(particle)
            
            let randomX = CGFloat.random(in: -30...30)
            let randomY = CGFloat.random(in: -30...30)
            
            particle.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: CGPoint(x: position.x + randomX, y: position.y + randomY), duration: 0.5),
                    SKAction.fadeOut(withDuration: 0.5)
                ]),
                SKAction.removeFromParent()
            ]))
        }
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
    
    func teardown() {
        moleTimer?.invalidate()
        moleTimer = nil
        moles.removeAll()
        holes.removeAll()
        whackedCount = 0
    }
}