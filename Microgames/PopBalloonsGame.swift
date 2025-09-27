import SpriteKit

class PopBalloonsGame: Microgame {
    private weak var scene: SKScene?
    private var balloons: [SKNode] = []
    private var poppedCount = 0
    private let targetCount = 5
    
    func start(in scene: SKScene) {
        self.scene = scene
        createBalloons()
    }
    
    private func createBalloons() {
        guard let scene = scene else { return }
        
        for i in 0..<targetCount {
            let balloon = createBalloon()
            balloon.position = CGPoint(
                x: CGFloat.random(in: 50...scene.frame.width - 50),
                y: CGFloat.random(in: 200...scene.frame.height - 200)
            )
            scene.addChild(balloon)
            balloons.append(balloon)
        }
    }
    
    private func createBalloon() -> SKNode {
        let balloon = SKNode()
        
        // Balloon body
        let body = SKShapeNode(circleOfRadius: 25)
        body.fillColor = SKColor.random()
        body.strokeColor = .white
        body.lineWidth = 2
        balloon.addChild(body)
        
        // Balloon string
        let string = SKShapeNode(rectOf: CGSize(width: 2, height: 30))
        string.fillColor = .white
        string.position = CGPoint(x: 0, y: -40)
        balloon.addChild(string)
        
        // Add floating animation
        let float = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 10, duration: 1.0),
            SKAction.moveBy(x: 0, y: -10, duration: 1.0)
        ])
        balloon.run(SKAction.repeatForever(float))
        
        return balloon
    }
    
    func update(_ currentTime: TimeInterval) {
        // Check if all balloons popped
        if poppedCount >= targetCount {
            // Success!
            HapticsService.shared.success()
            AudioService.shared.playSuccessSound()
            createSuccessEffect()
        }
    }
    
    func handleTouch(_ location: CGPoint) {
        for (index, balloon) in balloons.enumerated() {
            if balloon.contains(location) {
                popBalloon(balloon, at: index)
                break
            }
        }
    }
    
    private func popBalloon(_ balloon: SKNode, at index: Int) {
        // Remove from array
        balloons.remove(at: index)
        
        // Create pop effect
        createPopEffect(at: balloon.position)
        
        // Remove balloon
        balloon.removeFromParent()
        
        // Increment count
        poppedCount += 1
        
        // Haptic feedback
        HapticsService.shared.light()
        
        // Sound
        AudioService.shared.playSound("beep")
    }
    
    private func createPopEffect(at position: CGPoint) {
        guard let scene = scene else { return }
        
        // Create particle burst
        for _ in 0..<10 {
            let particle = SKShapeNode(circleOfRadius: 3)
            particle.fillColor = SKColor.random()
            particle.position = position
            scene.addChild(particle)
            
            let randomX = CGFloat.random(in: -50...50)
            let randomY = CGFloat.random(in: -50...50)
            
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
        
        // Confetti effect
        for _ in 0..<20 {
            let confetti = SKShapeNode(rectOf: CGSize(width: 8, height: 8))
            confetti.fillColor = SKColor.random()
            confetti.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
            scene.addChild(confetti)
            
            let randomX = CGFloat.random(in: -scene.frame.width/2...scene.frame.width/2)
            let randomY = CGFloat.random(in: -scene.frame.height/2...scene.frame.height/2)
            
            confetti.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: CGPoint(x: randomX, y: randomY), duration: 1.0),
                    SKAction.fadeOut(withDuration: 1.0)
                ]),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    func teardown() {
        balloons.removeAll()
        poppedCount = 0
    }
}

extension SKColor {
    static func random() -> SKColor {
        let colors: [SKColor] = [.red, .blue, .green, .yellow, .purple, .orange, .pink, .cyan]
        return colors.randomElement() ?? .white
    }
}