import SpriteKit

protocol ResultSceneDelegate: AnyObject {
    func resultSceneFinished()
}

class ResultScene: SKScene {
    weak var delegate: ResultSceneDelegate?
    
    private let isCorrect: Bool
    private let correctOpponent: Opponent
    private var resultLabel: SKLabelNode?
    private var opponentDisplay: SKNode?
    private var continueButton: SKNode?
    
    init(isCorrect: Bool, correctOpponent: Opponent) {
        self.isCorrect = isCorrect
        self.correctOpponent = correctOpponent
        super.init(size: CGSize(width: 400, height: 800))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupResult()
        setupOpponentDisplay()
        setupContinueButton()
        playResultEffects()
    }
    
    private func setupBackground() {
        if isCorrect {
            backgroundColor = SKColor(red: 0.1, green: 0.4, blue: 0.1, alpha: 1.0)
        } else {
            backgroundColor = SKColor(red: 0.4, green: 0.1, blue: 0.1, alpha: 1.0)
        }
    }
    
    private func setupResult() {
        resultLabel = SKLabelNode(fontNamed: "Arial-Bold")
        resultLabel?.text = isCorrect ? "CORRECT!" : "WRONG!"
        resultLabel?.fontSize = 36
        resultLabel?.fontColor = .white
        resultLabel?.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        resultLabel?.horizontalAlignmentMode = .center
        addChild(resultLabel!)
        
        let subtitle = SKLabelNode(fontNamed: "Arial")
        subtitle.text = isCorrect ? "Great detective work!" : "Better luck next time!"
        subtitle.fontSize = 18
        subtitle.fontColor = .lightGray
        subtitle.position = CGPoint(x: frame.midX, y: frame.maxY - 140)
        subtitle.horizontalAlignmentMode = .center
        addChild(subtitle)
    }
    
    private func setupOpponentDisplay() {
        let displaySize = CGSize(width: 200, height: 200)
        let display = SKNode()
        
        // Background
        let background = SKShapeNode(rectOf: displaySize, cornerRadius: 20)
        background.fillColor = SKColor(hex: correctOpponent.color.uiColor) ?? .white
        background.strokeColor = .white
        background.lineWidth = 4
        display.addChild(background)
        
        // Emoji
        let emojiLabel = SKLabelNode(fontNamed: "Arial")
        emojiLabel.text = correctOpponent.emoji
        emojiLabel.fontSize = 80
        emojiLabel.position = CGPoint(x: 0, y: 20)
        emojiLabel.horizontalAlignmentMode = .center
        display.addChild(emojiLabel)
        
        // Name
        let nameLabel = SKLabelNode(fontNamed: "Arial-Bold")
        nameLabel.text = correctOpponent.name
        nameLabel.fontSize = 24
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: -60)
        nameLabel.horizontalAlignmentMode = .center
        display.addChild(nameLabel)
        
        display.position = CGPoint(x: frame.midX, y: frame.midY + 50)
        addChild(display)
        
        opponentDisplay = display
    }
    
    private func setupContinueButton() {
        let buttonSize = CGSize(width: 180, height: 50)
        let button = SKShapeNode(rectOf: buttonSize, cornerRadius: 25)
        button.fillColor = isCorrect ? 
            SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0) :
            SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        button.strokeColor = .white
        button.lineWidth = 2
        button.position = CGPoint(x: frame.midX, y: frame.minY + 100)
        addChild(button)
        
        let buttonLabel = SKLabelNode(fontNamed: "Arial-Bold")
        buttonLabel.text = isCorrect ? "BONUS ROUND!" : "TRY AGAIN"
        buttonLabel.fontSize = 18
        buttonLabel.fontColor = .white
        buttonLabel.position = CGPoint(x: 0, y: -6)
        buttonLabel.horizontalAlignmentMode = .center
        button.addChild(buttonLabel)
        
        continueButton = button
        
        // Add glow effect
        let glow = SKShapeNode(rectOf: CGSize(width: 200, height: 70), cornerRadius: 35)
        glow.fillColor = .clear
        glow.strokeColor = button.fillColor.withAlphaComponent(0.5)
        glow.lineWidth = 2
        glow.position = CGPoint(x: frame.midX, y: frame.minY + 100)
        addChild(glow)
        
        // Animate glow
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 1.0),
            SKAction.scale(to: 1.0, duration: 1.0)
        ])
        glow.run(SKAction.repeatForever(pulse))
    }
    
    private func playResultEffects() {
        if isCorrect {
            // Success effects
            HapticsService.shared.success()
            AudioService.shared.playSuccessSound()
            
            // Confetti particles
            createConfettiEffect()
            
            // Animate result label
            resultLabel?.run(SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.3)
            ]))
            
        } else {
            // Failure effects
            HapticsService.shared.error()
            AudioService.shared.playFailSound()
            
            // Shake effect
            let shake = SKAction.sequence([
                SKAction.moveBy(x: -10, y: 0, duration: 0.1),
                SKAction.moveBy(x: 20, y: 0, duration: 0.1),
                SKAction.moveBy(x: -10, y: 0, duration: 0.1)
            ])
            resultLabel?.run(shake)
        }
        
        // Animate opponent display
        opponentDisplay?.run(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ]))
    }
    
    private func createConfettiEffect() {
        let colors: [SKColor] = [.red, .blue, .green, .yellow, .purple, .orange]
        
        for _ in 0..<50 {
            let confetti = SKShapeNode(rectOf: CGSize(width: 8, height: 8))
            confetti.fillColor = colors.randomElement() ?? .white
            confetti.strokeColor = .clear
            confetti.position = CGPoint(x: frame.midX, y: frame.maxY)
            addChild(confetti)
            
            let randomX = CGFloat.random(in: -frame.width/2...frame.width/2)
            let randomY = CGFloat.random(in: -frame.height/2...frame.height/2)
            let randomRotation = CGFloat.random(in: 0...CGFloat.pi * 2)
            
            confetti.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: CGPoint(x: randomX, y: randomY), duration: 2.0),
                    SKAction.rotate(byAngle: randomRotation, duration: 2.0),
                    SKAction.fadeOut(withDuration: 2.0)
                ]),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let continueButton = continueButton, continueButton.contains(location) {
            // Animate button press
            let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
            let sequence = SKAction.sequence([scaleDown, scaleUp])
            continueButton.run(sequence)
            
            // Haptic feedback
            HapticsService.shared.medium()
            
            // Notify delegate
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.delegate?.resultSceneFinished()
            }
        }
    }
}