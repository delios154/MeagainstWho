import SpriteKit

class TapOnBeatGame: Microgame {
    private weak var scene: SKScene?
    private var target: SKShapeNode?
    private var ring: SKShapeNode?
    private var isTargetActive = false
    private var tapCount = 0
    private var targetCount = 5
    private var beatTimer: Timer?
    
    func start(in scene: SKScene) {
        self.scene = scene
        setupRing()
        startBeat()
    }
    
    private func setupRing() {
        guard let scene = scene else { return }
        
        // Create target ring
        ring = SKShapeNode(circleOfRadius: 60)
        ring?.strokeColor = .white
        ring?.lineWidth = 4
        ring?.fillColor = .clear
        ring?.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        scene.addChild(ring!)
        
        // Add pulsing animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        ring?.run(SKAction.repeatForever(pulse))
    }
    
    private func startBeat() {
        beatTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.spawnTarget()
        }
        
        // Initial target
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.spawnTarget()
        }
    }
    
    private func spawnTarget() {
        guard let scene = scene else { return }
        
        // Create target dot
        target = SKShapeNode(circleOfRadius: 15)
        target?.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        target?.strokeColor = .white
        target?.lineWidth = 2
        target?.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        scene.addChild(target!)
        
        isTargetActive = true
        
        // Animate target
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.3)
        target?.run(SKAction.sequence([scaleUp, scaleDown]))
        
        // Auto-remove after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.isTargetActive {
                self.missTarget()
            }
        }
    }
    
    private func missTarget() {
        isTargetActive = false
        target?.removeFromParent()
        target = nil
        
        // Visual feedback
        createMissEffect()
        
        // Haptic feedback
        HapticsService.shared.error()
    }
    
    private func createMissEffect() {
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
    
    func update(_ currentTime: TimeInterval) {
        // Check if target count reached
        if tapCount >= targetCount {
            // Success!
            beatTimer?.invalidate()
            beatTimer = nil
            HapticsService.shared.success()
            AudioService.shared.playSuccessSound()
            createSuccessEffect()
        }
    }
    
    func handleTouch(_ location: CGPoint) {
        guard isTargetActive, let target = target else { return }
        
        if target.contains(location) {
            hitTarget()
        }
    }
    
    private func hitTarget() {
        isTargetActive = false
        target?.removeFromParent()
        target = nil
        
        // Increment count
        tapCount += 1
        
        // Visual feedback
        createHitEffect()
        
        // Haptic feedback
        HapticsService.shared.light()
        
        // Sound
        AudioService.shared.playSound("beep")
    }
    
    private func createHitEffect() {
        guard let scene = scene else { return }
        
        // Create particle burst
        for _ in 0..<8 {
            let particle = SKShapeNode(circleOfRadius: 3)
            particle.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
            particle.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
            scene.addChild(particle)
            
            let randomX = CGFloat.random(in: -30...30)
            let randomY = CGFloat.random(in: -30...30)
            
            particle.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: CGPoint(x: scene.frame.midX + randomX, y: scene.frame.midY + randomY), duration: 0.5),
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
        beatTimer?.invalidate()
        beatTimer = nil
        target?.removeFromParent()
        target = nil
        ring?.removeFromParent()
        ring = nil
        isTargetActive = false
        tapCount = 0
    }
}