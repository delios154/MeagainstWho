import SpriteKit

class SliderStopGame: Microgame {
    private weak var scene: SKScene?
    private var slider: SKNode?
    private var targetZone: SKShapeNode?
    private var isMoving = true
    private var direction: CGFloat = 1
    private var speed: CGFloat = 3
    private var targetHit = false
    
    func start(in scene: SKScene) {
        self.scene = scene
        setupSlider()
        setupTargetZone()
    }
    
    private func setupSlider() {
        guard let scene = scene else { return }
        
        slider = SKNode()
        
        // Slider background
        let background = SKShapeNode(rectOf: CGSize(width: 300, height: 20), cornerRadius: 10)
        background.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        background.strokeColor = .white
        background.lineWidth = 2
        slider?.addChild(background)
        
        // Slider handle
        let handle = SKShapeNode(circleOfRadius: 15)
        handle.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0)
        handle.strokeColor = .white
        handle.lineWidth = 2
        slider?.addChild(handle)
        
        slider?.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        scene.addChild(slider!)
    }
    
    private func setupTargetZone() {
        guard let scene = scene else { return }
        
        let zone = SKShapeNode(rectOf: CGSize(width: 60, height: 20), cornerRadius: 10)
        zone.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 0.5)
        zone.strokeColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        zone.lineWidth = 3
        zone.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        scene.addChild(zone)
        targetZone = zone
        
        // Add pulsing animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        targetZone?.run(SKAction.repeatForever(pulse))
    }
    
    func update(_ currentTime: TimeInterval) {
        guard isMoving, let scene = scene else { return }
        
        // Move slider
        slider?.position.x += direction * speed
        
        // Check bounds
        if slider?.position.x ?? 0 <= 50 {
            direction = 1
        } else if slider?.position.x ?? 0 >= scene.frame.width - 50 {
            direction = -1
        }
        
        // Check if target hit
        if let slider = slider, let targetZone = targetZone {
            let distance = abs(slider.position.x - targetZone.position.x)
            if distance < 30 && !targetHit {
                hitTarget()
            }
        }
    }
    
    func handleTouch(_ location: CGPoint) {
        guard isMoving else { return }
        
        // Stop slider
        isMoving = false
        
        // Check if in target zone
        if let slider = slider, let targetZone = targetZone {
            let distance = abs(slider.position.x - targetZone.position.x)
            if distance < 30 {
                hitTarget()
            } else {
                missTarget()
            }
        }
        
        // Haptic feedback
        HapticsService.shared.medium()
    }
    
    private func hitTarget() {
        targetHit = true
        
        // Visual feedback
        createHitEffect()
        
        // Haptic feedback
        HapticsService.shared.success()
        
        // Sound
        AudioService.shared.playSuccessSound()
        
        // Success!
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.createSuccessEffect()
        }
    }
    
    private func missTarget() {
        // Visual feedback
        createMissEffect()
        
        // Haptic feedback
        HapticsService.shared.error()
        
        // Sound
        AudioService.shared.playFailSound()
        
        // Reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.resetSlider()
        }
    }
    
    private func createHitEffect() {
        guard let scene = scene else { return }
        
        // Create particle burst
        for _ in 0..<10 {
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
    
    private func resetSlider() {
        guard let scene = scene else { return }
        
        // Reset position
        slider?.position.x = scene.frame.midX
        
        // Reset state
        isMoving = true
        targetHit = false
        direction = 1
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
        slider?.removeFromParent()
        slider = nil
        targetZone?.removeFromParent()
        targetZone = nil
        isMoving = false
        targetHit = false
    }
}