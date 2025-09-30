import SpriteKit
import Combine

class TraceLineGame: Microgame {
    private weak var scene: SKScene?
    private var path: SKShapeNode?
    private var traceLine: SKShapeNode?
    private var isTracing = false
    private var tracePoints: [CGPoint] = []
    private var pathPoints: [CGPoint] = []
    private var currentPathIndex = 0
    
    func start(in scene: SKScene) {
        self.scene = scene
        createPath()
        setupTraceLine()
    }
    
    private func createPath() {
        guard let scene = scene else { return }
        
        // Create wavy path
        pathPoints = generateWavyPath()
        
        // Draw path
        path = SKShapeNode()
        path?.strokeColor = .white
        path?.lineWidth = 8
        path?.lineCap = .round
        scene.addChild(path!)
        
        // Create path shape
        let pathShape = CGMutablePath()
        pathShape.move(to: pathPoints[0])
        
        for i in 1..<pathPoints.count {
            pathShape.addLine(to: pathPoints[i])
        }
        
        path?.path = pathShape
    }
    
    private func generateWavyPath() -> [CGPoint] {
        guard let scene = scene else { return [] }
        
        let startX: CGFloat = 50
        let endX: CGFloat = scene.frame.width - 50
        let centerY: CGFloat = scene.frame.midY
        let amplitude: CGFloat = 80
        let frequency: CGFloat = 0.02
        
        var points: [CGPoint] = []
        let stepCount = 50
        
        for i in 0...stepCount {
            let x = startX + (endX - startX) * CGFloat(i) / CGFloat(stepCount)
            let y = centerY + amplitude * sin(frequency * x)
            points.append(CGPoint(x: x, y: y))
        }
        
        return points
    }
    
    private func setupTraceLine() {
        guard let scene = scene else { return }
        
        traceLine = SKShapeNode()
        traceLine?.strokeColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0)
        traceLine?.lineWidth = 6
        traceLine?.lineCap = .round
        scene.addChild(traceLine!)
    }
    
    func update(_ currentTime: TimeInterval) {
        // Check if path is complete
        if currentPathIndex >= pathPoints.count - 1 {
            // Success!
            HapticsService.shared.success()
            AudioService.shared.playSuccessSound()
            createSuccessEffect()
        }
    }
    
    func handleTouch(_ location: CGPoint) {
        if !isTracing {
            // Start tracing
            isTracing = true
            tracePoints = [location]
            currentPathIndex = 0
        } else {
            // Continue tracing
            tracePoints.append(location)
            checkPathAccuracy()
        }
    }
    
    private func checkPathAccuracy() {
        guard scene != nil else { return }
        
        // Check if current trace point is close to path
        let currentPathPoint = pathPoints[currentPathIndex]
        let distance = sqrt(pow(tracePoints.last!.x - currentPathPoint.x, 2) + 
                           pow(tracePoints.last!.y - currentPathPoint.y, 2))
        
        if distance < 30 { // Within tolerance
            currentPathIndex += 1
            
            // Update trace line
            updateTraceLine()
            
            // Haptic feedback
            HapticsService.shared.light()
        } else if distance > 60 { // Too far from path
            // Reset tracing
            resetTracing()
        }
    }
    
    private func updateTraceLine() {
        guard tracePoints.count > 1 else { return }
        
        let pathShape = CGMutablePath()
        pathShape.move(to: tracePoints[0])
        
        for i in 1..<tracePoints.count {
            pathShape.addLine(to: tracePoints[i])
        }
        
        traceLine?.path = pathShape
    }
    
    private func resetTracing() {
        isTracing = false
        tracePoints = []
        currentPathIndex = 0
        
        // Clear trace line
        traceLine?.path = nil
        
        // Visual feedback
        createResetEffect()
    }
    
    private func createResetEffect() {
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
        
        // Haptic feedback
        HapticsService.shared.error()
    }
    
    private func createSuccessEffect() {
        guard let scene = scene else { return }
        
        // Success particles
        for _ in 0..<15 {
            let particle = SKShapeNode(circleOfRadius: 4)
            particle.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0)
            particle.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
            scene.addChild(particle)
            
            let randomX = CGFloat.random(in: -100...100)
            let randomY = CGFloat.random(in: -100...100)
            
            particle.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: CGPoint(x: scene.frame.midX + randomX, y: scene.frame.midY + randomY), duration: 0.8),
                    SKAction.fadeOut(withDuration: 0.8)
                ]),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    func teardown() {
        path?.removeFromParent()
        traceLine?.removeFromParent()
        tracePoints = []
        pathPoints = []
        isTracing = false
        currentPathIndex = 0
    }
}