import SpriteKit
import SwiftUI

class MenuScene: SKScene {
    private var playButton: SKNode?
    private var titleLabel: SKLabelNode?
    private var starsLabel: SKLabelNode?
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupTitle()
        setupPlayButton()
        setupStarsDisplay()
        setupParticles()
    }
    
    private func setupBackground() {
        backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        
        // Add gradient effect
        let gradient = SKShapeNode(rect: frame)
        gradient.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 0.3)
        gradient.strokeColor = .clear
        addChild(gradient)
    }
    
    private func setupTitle() {
        titleLabel = SKLabelNode(fontNamed: "Arial-Bold")
        titleLabel?.text = "Me Against Who?"
        titleLabel?.fontSize = 36
        titleLabel?.fontColor = .white
        titleLabel?.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        titleLabel?.horizontalAlignmentMode = .center
        addChild(titleLabel!)
        
        let subtitle = SKLabelNode(fontNamed: "Arial")
        subtitle.text = "Mini Mystery Duels"
        subtitle.fontSize = 20
        subtitle.fontColor = .lightGray
        subtitle.position = CGPoint(x: frame.midX, y: frame.midY + 60)
        subtitle.horizontalAlignmentMode = .center
        addChild(subtitle)
    }
    
    private func setupPlayButton() {
        let buttonSize = CGSize(width: 200, height: 60)
        let button = SKShapeNode(rectOf: buttonSize, cornerRadius: 30)
        button.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0)
        button.strokeColor = .white
        button.lineWidth = 3
        button.position = CGPoint(x: frame.midX, y: frame.midY - 20)
        addChild(button)
        
        let playLabel = SKLabelNode(fontNamed: "Arial-Bold")
        playLabel.text = "PLAY"
        playLabel.fontSize = 24
        playLabel.fontColor = .white
        playLabel.position = CGPoint(x: 0, y: -8)
        playLabel.horizontalAlignmentMode = .center
        button.addChild(playLabel)
        
        playButton = button
        
        // Add glow effect
        let glow = SKShapeNode(rectOf: CGSize(width: 220, height: 80), cornerRadius: 40)
        glow.fillColor = .clear
        glow.strokeColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 0.5)
        glow.lineWidth = 2
        glow.position = CGPoint(x: frame.midX, y: frame.midY - 20)
        addChild(glow)
        
        // Animate glow
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 1.0),
            SKAction.scale(to: 1.0, duration: 1.0)
        ])
        glow.run(SKAction.repeatForever(pulse))
    }
    
    private func setupStarsDisplay() {
        let starsBackground = SKShapeNode(rectOf: CGSize(width: 120, height: 40), cornerRadius: 20)
        starsBackground.fillColor = SKColor.black.withAlphaComponent(0.6)
        starsBackground.strokeColor = .clear
        starsBackground.position = CGPoint(x: frame.midX, y: frame.midY - 120)
        addChild(starsBackground)
        
        let starIcon = SKLabelNode(fontNamed: "Arial")
        starIcon.text = "⭐"
        starIcon.fontSize = 20
        starIcon.position = CGPoint(x: -30, y: -5)
        starIcon.horizontalAlignmentMode = .center
        starsBackground.addChild(starIcon)
        
        starsLabel = SKLabelNode(fontNamed: "Arial-Bold")
        starsLabel?.text = "\(PersistenceService.shared.totalStars)"
        starsLabel?.fontSize = 18
        starsLabel?.fontColor = .white
        starsLabel?.position = CGPoint(x: 20, y: -5)
        starsLabel?.horizontalAlignmentMode = .center
        starsBackground.addChild(starsLabel!)
    }
    
    private func setupParticles() {
        let particleEmitter = SKEmitterNode()
        particleEmitter.particleTexture = SKTexture()
        particleEmitter.particleBirthRate = 5
        particleEmitter.particleLifetime = 10
        particleEmitter.particleLifetimeRange = 5
        particleEmitter.particlePosition = CGPoint(x: frame.midX, y: frame.maxY)
        particleEmitter.particlePositionRange = CGVector(dx: frame.width, dy: 0)
        particleEmitter.particleSpeed = 20
        particleEmitter.particleSpeedRange = 10
        particleEmitter.particleAlpha = 0.3
        particleEmitter.particleAlphaRange = 0.2
        particleEmitter.particleScale = 0.1
        particleEmitter.particleScaleRange = 0.05
        particleEmitter.particleColor = .white
        particleEmitter.particleColorBlendFactor = 1.0
        
        addChild(particleEmitter)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let playButton = playButton, playButton.contains(location) {
            // Animate button press
            let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
            let sequence = SKAction.sequence([scaleDown, scaleUp])
            playButton.run(sequence)
            
            // Trigger haptic feedback
            HapticsService.shared.medium()
            
            // Start game after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                // This will be handled by the coordinator
                NotificationCenter.default.post(name: .startGame, object: nil)
            }
        }
    }
}

extension Notification.Name {
    static let startGame = Notification.Name("startGame")
}