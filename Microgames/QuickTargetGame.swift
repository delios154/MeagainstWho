import SpriteKit

class QuickTargetGame: Microgame {
    private weak var scene: SKScene?
    private var shapes: [SKNode] = []
    private var targetShape: SKNode?
    private var targetHit = false
    
    func start(in scene: SKScene) {
        self.scene = scene
        createShapes()
    }
    
    private func createShapes() {
        guard let scene = scene else { return }
        
        let shapePositions = [
            CGPoint(x: 100, y: 300),
            CGPoint(x: 200, y: 300),
            CGPoint(x: 300, y: 300),
            CGPoint(x: 100, y: 200),
            CGPoint(x: 200, y: 200),
            CGPoint(x: 300, y: 200)
        ]
        
        // Create 5 circles and 1 square (odd one out)
        let oddOneOutIndex = Int.random(in: 0..<6)
        
        for (index, position) in shapePositions.enumerated() {
            let shape: SKNode
            if index == oddOneOutIndex {
                shape = createSquare()
                targetShape = shape
            } else {
                shape = createCircle()
            }
            
            shape.position = position
            scene.addChild(shape)
            shapes.append(shape)
        }
    }
    
    private func createCircle() -> SKNode {
        let circle = SKShapeNode(circleOfRadius: 25)
        circle.fillColor = SKColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        circle.strokeColor = .white
        circle.lineWidth = 3
        return circle
    }
    
    private func createSquare() -> SKNode {
        let square = SKShapeNode(rectOf: CGSize(width: 50, height: 50))
        square.fillColor = SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
        square.strokeColor = .white
        square.lineWidth = 3
        return square
    }
    
    func update(_ currentTime: TimeInterval) {
        // Check if target hit
        if targetHit {
            // Success!
            HapticsService.shared.success()
            AudioService.shared.playSuccessSound()
            createSuccessEffect()
        }
    }
    
    func handleTouch(_ location: CGPoint) {
        for shape in shapes {
            if shape.contains(location) {
                if shape == targetShape {
                    hitTarget(shape)
                } else {
                    hitWrongShape(shape)
                }
                break
            }
        }
    }
    
    private func hitTarget(_ shape: SKNode) {
        targetHit = true
        
        // Visual feedback
        createHitEffect(at: shape.position)
        
        // Haptic feedback
        HapticsService.shared.success()
        
        // Sound
        AudioService.shared.playSuccessSound()
    }
    
    private func hitWrongShape(_ shape: SKNode) {
        // Visual feedback
        createMissEffect(at: shape.position)
        
        // Haptic feedback
        HapticsService.shared.error()
        
        // Sound
        AudioService.shared.playFailSound()
    }
    
    private func createHitEffect(at position: CGPoint) {
        guard let scene = scene else { return }
        
        // Create particle burst
        for _ in 0..<10 {
            let particle = SKShapeNode(circleOfRadius: 3)
            particle.fillColor = SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
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
    
    private func createMissEffect(at position: CGPoint) {
        guard let scene = scene else { return }
        
        // Flash effect
        let flash = SKShapeNode(rect: scene.frame)
        flash.fillColor = .red
        flash.alpha = 0.3
        scene.addChild(flash)
        
        flash.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
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
    
    func teardown() {
        shapes.removeAll()
        targetShape = nil
        targetHit = false
    }
}