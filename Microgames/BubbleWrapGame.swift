import SpriteKit

class BubbleWrapGame: Microgame {
    private weak var scene: SKScene?
    private var bubbles: [SKNode] = []
    private var poppedCount = 0
    private var targetCount = 15
    
    func start(in scene: SKScene) {
        self.scene = scene
        createBubbles()
    }
    
    private func createBubbles() {
        guard let scene = scene else { return }
        
        let bubbleSize: CGFloat = 40
        let spacing: CGFloat = 50
        let startX: CGFloat = 50
        let startY: CGFloat = 200
        
        for row in 0..<4 {
            for col in 0..<8 {
                let bubble = createBubble()
                bubble.position = CGPoint(
                    x: startX + CGFloat(col) * spacing,
                    y: startY + CGFloat(row) * spacing
                )
                scene.addChild(bubble)
                bubbles.append(bubble)
            }
        }
    }
    
    private func createBubble() -> SKNode {
        let bubble = SKNode()
        
        // Bubble body
        let body = SKShapeNode(circleOfRadius: 20)
        body.fillColor = SKColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 0.8)
        body.strokeColor = .white
        body.lineWidth = 2
        bubble.addChild(body)
        
        // Bubble highlight
        let highlight = SKShapeNode(circleOfRadius: 8)
        highlight.fillColor = .white
        highlight.alpha = 0.6
        highlight.position = CGPoint(x: -5, y: 5)
        bubble.addChild(highlight)
        
        // Add subtle animation
        let float = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 2, duration: 0.5),
            SKAction.moveBy(x: 0, y: -2, duration: 0.5)
        ])
        bubble.run(SKAction.repeatForever(float))
        
        return bubble
    }
    
    func update(_ currentTime: TimeInterval) {
        // Check if target count reached
        if poppedCount >= targetCount {
            // Success!
            HapticsService.shared.success()
            AudioService.shared.playSuccessSound()
            createSuccessEffect()
        }
    }
    
    func handleTouch(_ location: CGPoint) {
        for (index, bubble) in bubbles.enumerated() {
            if bubble.contains(location) {
                popBubble(bubble, at: index)
                break
            }
        }
    }
    
    private func popBubble(_ bubble: SKNode, at index: Int) {
        // Remove from array
        bubbles.remove(at: index)
        
        // Create pop effect
        createPopEffect(at: bubble.position)
        
        // Remove bubble
        bubble.removeFromParent()
        
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
        for _ in 0..<8 {
            let particle = SKShapeNode(circleOfRadius: 2)
            particle.fillColor = SKColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0)
            particle.position = position
            scene.addChild(particle)
            
            let randomX = CGFloat.random(in: -20...20)
            let randomY = CGFloat.random(in: -20...20)
            
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
        for _ in 0..<30 {
            let particle = SKShapeNode(circleOfRadius: 3)
            particle.fillColor = SKColor.random()
            particle.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
            scene.addChild(particle)
            
            let randomX = CGFloat.random(in: -150...150)
            let randomY = CGFloat.random(in: -150...150)
            
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
        bubbles.removeAll()
        poppedCount = 0
    }
}