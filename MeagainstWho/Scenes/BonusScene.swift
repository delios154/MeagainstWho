import SpriteKit

protocol BonusSceneDelegate: AnyObject {
    func bonusCompleted(starsEarned: Int)
}

class BonusScene: SKScene {
    weak var bonusDelegate: BonusSceneDelegate?
    
    private var timeRemaining: TimeInterval = 5.0
    private var timer: Timer?
    private var score = 0
    private var targetScore = 10
    
    private var progressBar: SKShapeNode?
    private var timeLabel: SKLabelNode?
    private var scoreLabel: SKLabelNode?
    private var targetNode: SKNode?
    private var tapZone: SKNode?
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupUI()
        setupGame()
        startTimer()
    }
    
    private func setupBackground() {
        backgroundColor = SKColor(red: 0.2, green: 0.1, blue: 0.3, alpha: 1.0)
        
        // Add sparkle effect
        for _ in 0..<20 {
            let sparkle = SKShapeNode(circleOfRadius: 2)
            sparkle.fillColor = .white
            sparkle.alpha = 0.6
            sparkle.position = CGPoint(
                x: CGFloat.random(in: 0...frame.width),
                y: CGFloat.random(in: 0...frame.height)
            )
            addChild(sparkle)
            
            let twinkle = SKAction.sequence([
                SKAction.fadeOut(withDuration: 1.0),
                SKAction.fadeIn(withDuration: 1.0)
            ])
            sparkle.run(SKAction.repeatForever(twinkle))
        }
    }
    
    private func setupUI() {
        // Title
        let titleLabel = SKLabelNode(fontNamed: "Arial-Bold")
        titleLabel.text = "BONUS ROUND!"
        titleLabel.fontSize = 28
        titleLabel.fontColor = .yellow
        titleLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 60)
        titleLabel.horizontalAlignmentMode = .center
        addChild(titleLabel)
        
        // Instructions
        let instructionLabel = SKLabelNode(fontNamed: "Arial")
        instructionLabel.text = "Tap the targets as they appear!"
        instructionLabel.fontSize = 16
        instructionLabel.fontColor = .white
        instructionLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 90)
        instructionLabel.horizontalAlignmentMode = .center
        addChild(instructionLabel)
        
        // Progress bar
        let progressBackground = SKShapeNode(rectOf: CGSize(width: 300, height: 20), cornerRadius: 10)
        progressBackground.fillColor = SKColor.black.withAlphaComponent(0.3)
        progressBackground.strokeColor = .clear
        progressBackground.position = CGPoint(x: frame.midX, y: frame.maxY - 120)
        addChild(progressBackground)
        
        progressBar = SKShapeNode(rectOf: CGSize(width: 300, height: 20), cornerRadius: 10)
        progressBar?.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        progressBar?.strokeColor = .clear
        progressBar?.position = CGPoint(x: frame.midX, y: frame.maxY - 120)
        addChild(progressBar!)
        
        // Time label
        timeLabel = SKLabelNode(fontNamed: "Arial-Bold")
        timeLabel?.text = "\(Int(timeRemaining))"
        timeLabel?.fontSize = 18
        timeLabel?.fontColor = .white
        timeLabel?.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        timeLabel?.horizontalAlignmentMode = .center
        addChild(timeLabel!)
        
        // Score display
        scoreLabel = SKLabelNode(fontNamed: "Arial-Bold")
        scoreLabel?.text = "Score: \(score)/\(targetScore)"
        scoreLabel?.fontSize = 20
        scoreLabel?.fontColor = .white
        scoreLabel?.position = CGPoint(x: frame.midX, y: frame.minY + 100)
        scoreLabel?.horizontalAlignmentMode = .center
        addChild(scoreLabel!)
    }
    
    private func setupGame() {
        // Create tap zone
        tapZone = SKNode()
        tapZone?.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(tapZone!)
        
        // Start spawning targets
        spawnTarget()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func updateTimer() {
        timeRemaining -= 0.1
        
        if timeRemaining <= 0 {
            timer?.invalidate()
            timer = nil
            endBonusRound()
        } else {
            updateProgressBar()
        }
    }
    
    private func updateProgressBar() {
        let progress = timeRemaining / 5.0
        let width = 300 * progress
        
        progressBar?.run(SKAction.resize(toWidth: width, duration: 0.1))
        timeLabel?.text = "\(Int(timeRemaining))"
    }
    
    private func spawnTarget() {
        guard timeRemaining > 0 else { return }
        
        let target = createTarget()
        tapZone?.addChild(target)
        
        // Animate target
        target.alpha = 0
        target.setScale(0.5)
        target.run(SKAction.group([
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ]))
        
        // Auto-remove after 1 second
        target.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
        
        // Spawn next target
        let delay = Double.random(in: 0.5...1.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.spawnTarget()
        }
    }
    
    private func createTarget() -> SKNode {
        let target = SKNode()
        
        // Background circle
        let background = SKShapeNode(circleOfRadius: 30)
        background.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        background.strokeColor = .white
        background.lineWidth = 3
        target.addChild(background)
        
        // Star icon
        let starLabel = SKLabelNode(fontNamed: "Arial")
        starLabel.text = "⭐"
        starLabel.fontSize = 24
        starLabel.position = CGPoint(x: 0, y: -8)
        starLabel.horizontalAlignmentMode = .center
        target.addChild(starLabel)
        
        // Random position
        let randomX = CGFloat.random(in: -150...150)
        let randomY = CGFloat.random(in: -200...200)
        target.position = CGPoint(x: randomX, y: randomY)
        
        // Add pulsing animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        target.run(SKAction.repeatForever(pulse))
        
        return target
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: tapZone!)
        
        // Check if touch hit any target
        for child in tapZone!.children {
            if child.contains(location) {
                hitTarget(child)
                break
            }
        }
    }
    
    private func hitTarget(_ target: SKNode) {
        // Remove target
        target.removeFromParent()
        
        // Increment score
        score += 1
        scoreLabel?.text = "Score: \(score)/\(targetScore)"
        
        // Visual feedback
        createHitEffect(at: target.position)
        
        // Haptic feedback
        HapticsService.shared.light()
        
        // Sound
        AudioService.shared.playSuccessSound()
        
        // Check if target score reached
        if score >= targetScore {
            endBonusRound()
        }
    }
    
    private func createHitEffect(at position: CGPoint) {
        // Create particle effect
        let particleEmitter = SKEmitterNode()
        particleEmitter.particleTexture = SKTexture()
        particleEmitter.particleBirthRate = 100
        particleEmitter.particleLifetime = 0.5
        particleEmitter.particlePosition = position
        particleEmitter.particleSpeed = 150
        particleEmitter.particleSpeedRange = 100
        particleEmitter.particleAlpha = 0.8
        particleEmitter.particleScale = 0.1
        particleEmitter.particleColor = .yellow
        particleEmitter.particleColorBlendFactor = 1.0
        
        tapZone?.addChild(particleEmitter)
        
        // Remove particles after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            particleEmitter.removeFromParent()
        }
    }
    
    private func endBonusRound() {
        timer?.invalidate()
        timer = nil
        
        // Calculate stars earned
        let starsEarned = min(score, 3) // Max 3 stars
        
        // Show result
        showResult(starsEarned: starsEarned)
    }
    
    private func showResult(starsEarned: Int) {
        // Clear existing content
        tapZone?.removeAllChildren()
        
        // Result background
        let resultBackground = SKShapeNode(rectOf: CGSize(width: 300, height: 200), cornerRadius: 20)
        resultBackground.fillColor = SKColor.black.withAlphaComponent(0.8)
        resultBackground.strokeColor = .white
        resultBackground.lineWidth = 2
        resultBackground.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(resultBackground)
        
        // Result text
        let resultLabel = SKLabelNode(fontNamed: "Arial-Bold")
        resultLabel.text = "BONUS COMPLETE!"
        resultLabel.fontSize = 24
        resultLabel.fontColor = .yellow
        resultLabel.position = CGPoint(x: 0, y: 50)
        resultLabel.horizontalAlignmentMode = .center
        resultBackground.addChild(resultLabel)
        
        // Stars earned
        let starsLabel = SKLabelNode(fontNamed: "Arial-Bold")
        starsLabel.text = "⭐ \(starsEarned) Stars Earned!"
        starsLabel.fontSize = 20
        starsLabel.fontColor = .white
        starsLabel.position = CGPoint(x: 0, y: 10)
        starsLabel.horizontalAlignmentMode = .center
        resultBackground.addChild(starsLabel)
        
        // Final score
        let scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.text = "Final Score: \(score)"
        scoreLabel.fontSize = 16
        scoreLabel.fontColor = .lightGray
        scoreLabel.position = CGPoint(x: 0, y: -20)
        scoreLabel.horizontalAlignmentMode = .center
        resultBackground.addChild(scoreLabel)
        
        // Continue button
        let continueButton = SKShapeNode(rectOf: CGSize(width: 120, height: 40), cornerRadius: 20)
        continueButton.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0)
        continueButton.strokeColor = .white
        continueButton.lineWidth = 2
        continueButton.position = CGPoint(x: 0, y: -60)
        resultBackground.addChild(continueButton)
        
        let buttonLabel = SKLabelNode(fontNamed: "Arial-Bold")
        buttonLabel.text = "CONTINUE"
        buttonLabel.fontSize = 16
        buttonLabel.fontColor = .white
        buttonLabel.position = CGPoint(x: 0, y: -8)
        buttonLabel.horizontalAlignmentMode = .center
        continueButton.addChild(buttonLabel)
        
        // Animate result
        resultBackground.alpha = 0
        resultBackground.setScale(0.5)
        resultBackground.run(SKAction.group([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ]))
        
        // Auto-continue after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.bonusDelegate?.bonusCompleted(starsEarned: starsEarned)
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}