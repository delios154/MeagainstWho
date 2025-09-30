import SpriteKit

class BalanceStackGame: Microgame {
    private weak var scene: SKScene?
    private var blocks: [SKNode] = []
    private var currentBlock: SKNode?
    private var stackHeight: CGFloat = 0
    private var targetHeight: CGFloat = 200
    private var isDropping = false
    
    func start(in scene: SKScene) {
        self.scene = scene
        createBase()
        createNextBlock()
    }
    
    private func createBase() {
        guard let scene = scene else { return }
        
        let base = SKShapeNode(rectOf: CGSize(width: 100, height: 20))
        base.fillColor = .brown
        base.strokeColor = .white
        base.lineWidth = 2
        base.position = CGPoint(x: scene.frame.midX, y: 50)
        scene.addChild(base)
        
        stackHeight = 70 // Base height
    }
    
    private func createNextBlock() {
        guard let scene = scene else { return }
        
        let block = SKShapeNode(rectOf: CGSize(width: 80, height: 20))
        block.fillColor = SKColor.random()
        block.strokeColor = .white
        block.lineWidth = 2
        block.position = CGPoint(x: scene.frame.midX, y: scene.frame.height - 100)
        scene.addChild(block)
        
        currentBlock = block
        
        // Add floating animation
        let float = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 10, duration: 0.5),
            SKAction.moveBy(x: 0, y: -10, duration: 0.5)
        ])
        block.run(SKAction.repeatForever(float))
    }
    
    func update(_ currentTime: TimeInterval) {
        // Check if target height reached
        if stackHeight >= targetHeight {
            // Success!
            HapticsService.shared.success()
            AudioService.shared.playSuccessSound()
            createSuccessEffect()
        }
    }
    
    func handleTouch(_ location: CGPoint) {
        guard currentBlock != nil, !isDropping else { return }
        
        dropBlock()
    }
    
    private func dropBlock() {
        guard let currentBlock = currentBlock, let scene = scene else { return }
        
        isDropping = true
        
        // Stop floating animation
        currentBlock.removeAllActions()
        
        // Drop to stack
        let dropAction = SKAction.move(to: CGPoint(x: scene.frame.midX, y: stackHeight), duration: 0.5)
        currentBlock.run(dropAction) { [weak self] in
            self?.blockLanded()
        }
        
        // Haptic feedback
        HapticsService.shared.medium()
    }
    
    private func blockLanded() {
        guard let currentBlock = currentBlock else { return }
        
        // Add to stack
        blocks.append(currentBlock)
        stackHeight += 20
        
        // Check if stack is stable
        if isStackStable() {
            // Success - create next block
            self.currentBlock = nil
            isDropping = false
            createNextBlock()
        } else {
            // Stack fell - reset
            resetStack()
        }
    }
    
    private func isStackStable() -> Bool {
        // Simple stability check - if blocks are reasonably aligned
        guard blocks.count > 1 else { return true }
        
        let lastBlock = blocks.last!
        let secondLastBlock = blocks[blocks.count - 2]
        
        let distance = abs(lastBlock.position.x - secondLastBlock.position.x)
        return distance < 40 // Within tolerance
    }
    
    private func resetStack() {
        // Animate stack falling
        for block in blocks {
            let fallAction = SKAction.moveBy(x: CGFloat.random(in: -50...50), y: -200, duration: 1.0)
            let fadeAction = SKAction.fadeOut(withDuration: 1.0)
            block.run(SKAction.group([fallAction, fadeAction])) {
                block.removeFromParent()
            }
        }
        
        // Reset state
        blocks.removeAll()
        stackHeight = 70
        isDropping = false
        
        // Create new base and first block
        createBase()
        createNextBlock()
        
        // Visual feedback
        createResetEffect()
    }
    
    private func createResetEffect() {
        guard let scene = scene else { return }
        
        // Shake effect
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -10, y: 0, duration: 0.1),
            SKAction.moveBy(x: 20, y: 0, duration: 0.1),
            SKAction.moveBy(x: -10, y: 0, duration: 0.1)
        ])
        scene.run(shake)
        
        // Haptic feedback
        HapticsService.shared.error()
    }
    
    private func createSuccessEffect() {
        guard let scene = scene else { return }
        
        // Success particles
        for _ in 0..<20 {
            let particle = SKShapeNode(circleOfRadius: 3)
            particle.fillColor = SKColor.random()
            particle.position = CGPoint(x: scene.frame.midX, y: stackHeight)
            scene.addChild(particle)
            
            let randomX = CGFloat.random(in: -100...100)
            let randomY = CGFloat.random(in: -100...100)
            
            particle.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: CGPoint(x: scene.frame.midX + randomX, y: stackHeight + randomY), duration: 1.0),
                    SKAction.fadeOut(withDuration: 1.0)
                ]),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    func teardown() {
        blocks.removeAll()
        currentBlock?.removeFromParent()
        currentBlock = nil
        stackHeight = 0
        isDropping = false
    }
}