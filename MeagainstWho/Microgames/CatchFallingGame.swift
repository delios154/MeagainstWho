import SpriteKit

class CatchFallingGame: Microgame {
    private weak var scene: SKScene?
    private var basket: SKNode?
    private var fallingItems: [SKNode] = []
    private var caughtCount = 0
    private var targetCount = 5
    private var spawnTimer: Timer?
    
    func start(in scene: SKScene) {
        self.scene = scene
        setupBasket()
        startSpawning()
    }
    
    private func setupBasket() {
        guard let scene = scene else { return }
        
        basket = SKNode()
        
        // Basket body
        let body = SKShapeNode(rectOf: CGSize(width: 80, height: 20))
        body.fillColor = .brown
        body.strokeColor = .white
        body.lineWidth = 2
        basket?.addChild(body)
        
        // Basket handle
        let handle = SKShapeNode(rectOf: CGSize(width: 4, height: 30))
        handle.fillColor = .brown
        handle.position = CGPoint(x: 0, y: 25)
        basket?.addChild(handle)
        
        basket?.position = CGPoint(x: scene.frame.midX, y: 100)
        scene.addChild(basket!)
    }
    
    private func startSpawning() {
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.spawnItem()
        }
        
        // Initial item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.spawnItem()
        }
    }
    
    private func spawnItem() {
        guard let scene = scene else { return }
        
        let item = createFallingItem()
        item.position = CGPoint(
            x: CGFloat.random(in: 50...scene.frame.width - 50),
            y: scene.frame.height - 50
        )
        scene.addChild(item)
        fallingItems.append(item)
        
        // Animate falling
        let fallAction = SKAction.moveTo(y: 0, duration: 2.0)
        item.run(fallAction) {
            self.itemLanded(item)
        }
    }
    
    private func createFallingItem() -> SKNode {
        let item = SKNode()
        
        // Item shape (random)
        let shape: SKShapeNode
        let randomShape = Int.random(in: 0...2)
        
        switch randomShape {
        case 0: // Circle
            shape = SKShapeNode(circleOfRadius: 15)
        case 1: // Square
            shape = SKShapeNode(rectOf: CGSize(width: 30, height: 30))
        default: // Triangle
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 15))
            path.addLine(to: CGPoint(x: -15, y: -15))
            path.addLine(to: CGPoint(x: 15, y: -15))
            path.closeSubpath()
            shape = SKShapeNode(path: path)
        }
        
        shape.fillColor = SKColor.random()
        shape.strokeColor = .white
        shape.lineWidth = 2
        item.addChild(shape)
        
        // Add rotation
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 1.0)
        item.run(SKAction.repeatForever(rotate))
        
        return item
    }
    
    private func itemLanded(_ item: SKNode) {
        // Check if caught by basket
        if let basket = basket, basket.contains(item.position) {
            catchItem(item)
        } else {
            missItem(item)
        }
    }
    
    private func catchItem(_ item: SKNode) {
        // Remove from falling items
        if let index = fallingItems.firstIndex(of: item) {
            fallingItems.remove(at: index)
        }
        
        // Remove item
        item.removeFromParent()
        
        // Increment count
        caughtCount += 1
        
        // Visual feedback
        createCatchEffect(at: item.position)
        
        // Haptic feedback
        HapticsService.shared.light()
        
        // Sound
        AudioService.shared.playSuccessSound()
        
        // Check if target reached
        if caughtCount >= targetCount {
            // Success!
            spawnTimer?.invalidate()
            spawnTimer = nil
            HapticsService.shared.success()
            createSuccessEffect()
        }
    }
    
    private func missItem(_ item: SKNode) {
        // Remove from falling items
        if let index = fallingItems.firstIndex(of: item) {
            fallingItems.remove(at: index)
        }
        
        // Remove item
        item.removeFromParent()
        
        // Visual feedback
        createMissEffect()
        
        // Haptic feedback
        HapticsService.shared.error()
    }
    
    private func createCatchEffect(at position: CGPoint) {
        guard let scene = scene else { return }
        
        // Create particle burst
        for _ in 0..<8 {
            let particle = SKShapeNode(circleOfRadius: 3)
            particle.fillColor = SKColor.random()
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
    
    private func createMissEffect() {
        guard let scene = scene else { return }
        
        // Flash effect
        let flash = SKShapeNode(rect: scene.frame)
        flash.fillColor = .red
        flash.alpha = 0.2
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
    
    func update(_ currentTime: TimeInterval) {
        // Check if target count reached
        if caughtCount >= targetCount {
            // Success!
            spawnTimer?.invalidate()
            spawnTimer = nil
            HapticsService.shared.success()
            AudioService.shared.playSuccessSound()
            createSuccessEffect()
        }
    }
    
    func handleTouch(_ location: CGPoint) {
        // Move basket to touch location
        guard let scene = scene else { return }
        
        let newX = max(40, min(scene.frame.width - 40, location.x))
        basket?.position = CGPoint(x: newX, y: basket?.position.y ?? 100)
        
        // Haptic feedback
        HapticsService.shared.light()
    }
    
    func teardown() {
        spawnTimer?.invalidate()
        spawnTimer = nil
        basket?.removeFromParent()
        basket = nil
        fallingItems.removeAll()
        caughtCount = 0
    }
}