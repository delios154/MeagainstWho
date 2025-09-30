import SpriteKit
import CoreMotion

class TiltBalanceGame: Microgame {
    private weak var scene: SKScene?
    private var ball: SKShapeNode?
    private var circle: SKShapeNode?
    private var motionManager: CMMotionManager?
    private var isBalanced = false
    private var balanceTime: TimeInterval = 0
    private var targetTime: TimeInterval = 3.0
    
    func start(in scene: SKScene) {
        self.scene = scene
        setupGame()
        startMotionUpdates()
    }
    
    private func setupGame() {
        guard let scene = scene else { return }
        
        // Create circle boundary
        circle = SKShapeNode(circleOfRadius: 60)
        circle?.strokeColor = .white
        circle?.lineWidth = 4
        circle?.fillColor = .clear
        circle?.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        scene.addChild(circle!)
        
        // Create ball
        ball = SKShapeNode(circleOfRadius: 15)
        ball?.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0)
        ball?.strokeColor = .white
        ball?.lineWidth = 2
        ball?.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        scene.addChild(ball!)
        
        // Add pulsing animation to circle
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        circle?.run(SKAction.repeatForever(pulse))
    }
    
    private func startMotionUpdates() {
        motionManager = CMMotionManager()
        motionManager?.accelerometerUpdateInterval = 0.1
        
        if motionManager?.isAccelerometerAvailable == true {
            motionManager?.startAccelerometerUpdates(to: .main) { [weak self] data, error in
                guard let data = data else { return }
                self?.updateBallPosition(acceleration: data.acceleration)
            }
        }
    }
    
    private func updateBallPosition(acceleration: CMAcceleration) {
        guard let scene = scene, let ball = ball else { return }
        
        // Convert acceleration to movement
        let sensitivity: CGFloat = 50
        let deltaX = CGFloat(acceleration.x) * sensitivity
        let deltaY = CGFloat(acceleration.y) * sensitivity
        
        // Update ball position
        ball.position.x += deltaX
        ball.position.y -= deltaY
        
        // Keep ball in bounds
        ball.position.x = max(50, min(scene.frame.width - 50, ball.position.x))
        ball.position.y = max(100, min(scene.frame.height - 100, ball.position.y))
        
        // Check if ball is in circle
        let distance = sqrt(pow(ball.position.x - scene.frame.midX, 2) + 
                           pow(ball.position.y - scene.frame.midY, 2))
        
        if distance < 60 {
            if !isBalanced {
                isBalanced = true
                balanceTime = 0
            }
        } else {
            if isBalanced {
                isBalanced = false
                balanceTime = 0
            }
        }
    }
    
    func update(_ currentTime: TimeInterval) {
        if isBalanced {
            balanceTime += 0.1
            
            if balanceTime >= targetTime {
                // Success!
                HapticsService.shared.success()
                AudioService.shared.playSuccessSound()
                createSuccessEffect()
            }
        }
    }
    
    func handleTouch(_ location: CGPoint) {
        // Touch to reset ball position
        guard let scene = scene, let ball = ball else { return }
        
        ball.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        
        // Haptic feedback
        HapticsService.shared.light()
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
        motionManager?.stopAccelerometerUpdates()
        motionManager = nil
        ball?.removeFromParent()
        ball = nil
        circle?.removeFromParent()
        circle = nil
        isBalanced = false
        balanceTime = 0
    }
}