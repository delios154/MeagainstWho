import SpriteKit
import SwiftUI

protocol GuessSceneDelegate: AnyObject {
    func opponentSelected(_ opponent: Opponent)
}

class GuessScene: SKScene {
    weak var delegate: GuessSceneDelegate?
    
    private var opponentNodes: [SKNode] = []
    private var selectedOpponent: Opponent?
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupTitle()
        setupOpponentTiles()
        setupInstructions()
    }
    
    private func setupBackground() {
        backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        
        // Add subtle pattern
        for i in 0..<10 {
            for j in 0..<20 {
                if (i + j) % 2 == 0 {
                    let dot = SKShapeNode(circleOfRadius: 2)
                    dot.fillColor = SKColor.white.withAlphaComponent(0.1)
                    dot.position = CGPoint(x: CGFloat(i * 40), y: CGFloat(j * 40))
                    addChild(dot)
                }
            }
        }
    }
    
    private func setupTitle() {
        let titleLabel = SKLabelNode(fontNamed: "Arial-Bold")
        titleLabel.text = "Who is your opponent?"
        titleLabel.fontSize = 28
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 80)
        titleLabel.horizontalAlignmentMode = .center
        addChild(titleLabel)
        
        let subtitleLabel = SKLabelNode(fontNamed: "Arial")
        subtitleLabel.text = "Tap the one you think it is"
        subtitleLabel.fontSize = 16
        subtitleLabel.fontColor = .lightGray
        subtitleLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 110)
        subtitleLabel.horizontalAlignmentMode = .center
        addChild(subtitleLabel)
    }
    
    private func setupOpponentTiles() {
        let opponents = Opponent.allOpponents
        let tileSize = CGSize(width: 120, height: 120)
        let spacing: CGFloat = 20
        let startX = frame.midX - (CGFloat(opponents.count) * (tileSize.width + spacing)) / 2 + tileSize.width / 2
        let startY = frame.midY + 50
        
        for (index, opponent) in opponents.enumerated() {
            let tile = createOpponentTile(for: opponent, size: tileSize)
            tile.position = CGPoint(
                x: startX + CGFloat(index) * (tileSize.width + spacing),
                y: startY
            )
            addChild(tile)
            opponentNodes.append(tile)
        }
    }
    
    private func createOpponentTile(for opponent: Opponent, size: CGSize) -> SKNode {
        let tile = SKNode()
        
        // Background
        let background = SKShapeNode(rectOf: size, cornerRadius: 15)
        background.fillColor = SKColor(hex: opponent.color.uiColor) ?? .white
        background.strokeColor = .white
        background.lineWidth = 3
        tile.addChild(background)
        
        // Emoji
        let emojiLabel = SKLabelNode(fontNamed: "Arial")
        emojiLabel.text = opponent.emoji
        emojiLabel.fontSize = 40
        emojiLabel.position = CGPoint(x: 0, y: 10)
        emojiLabel.horizontalAlignmentMode = .center
        tile.addChild(emojiLabel)
        
        // Name
        let nameLabel = SKLabelNode(fontNamed: "Arial-Bold")
        nameLabel.text = opponent.name
        nameLabel.fontSize = 16
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: -30)
        nameLabel.horizontalAlignmentMode = .center
        tile.addChild(nameLabel)
        
        // Add subtle glow
        let glow = SKShapeNode(rectOf: CGSize(width: size.width + 10, height: size.height + 10), cornerRadius: 20)
        glow.fillColor = .clear
        glow.strokeColor = SKColor(hex: opponent.color.uiColor)?.withAlphaComponent(0.3) ?? .clear
        glow.lineWidth = 2
        tile.addChild(glow)
        
        // Store opponent reference
        tile.userData = ["opponent": opponent]
        
        // Add hover effect
        let hover = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        
        tile.run(SKAction.repeatForever(SKAction.sequence([
            hover,
            SKAction.wait(forDuration: 2.0)
        ])))
        
        return tile
    }
    
    private func setupInstructions() {
        let instructionLabel = SKLabelNode(fontNamed: "Arial")
        instructionLabel.text = "Use the clues you collected to guess!"
        instructionLabel.fontSize = 14
        instructionLabel.fontColor = .lightGray
        instructionLabel.position = CGPoint(x: frame.midX, y: frame.minY + 50)
        instructionLabel.horizontalAlignmentMode = .center
        addChild(instructionLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        for node in opponentNodes {
            if node.contains(location) {
                // Animate selection
                let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
                let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
                let sequence = SKAction.sequence([scaleDown, scaleUp])
                node.run(sequence)
                
                // Haptic feedback
                HapticsService.shared.medium()
                
                // Get opponent and notify delegate
                if let opponent = node.userData?["opponent"] as? Opponent {
                    selectedOpponent = opponent
                    
                    // Add selection effect
                    addSelectionEffect(to: node)
                    
                    // Delay to show effect, then notify
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.delegate?.opponentSelected(opponent)
                    }
                }
                break
            }
        }
    }
    
    private func addSelectionEffect(to node: SKNode) {
        // Create selection ring
        let selectionRing = SKShapeNode(circleOfRadius: 80)
        selectionRing.fillColor = .clear
        selectionRing.strokeColor = .yellow
        selectionRing.lineWidth = 4
        selectionRing.position = node.position
        addChild(selectionRing)
        
        // Animate selection
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([scaleUp, fadeOut, remove])
        
        selectionRing.run(sequence)
        
        // Add particles
        let particleEmitter = SKEmitterNode()
        particleEmitter.particleTexture = SKTexture()
        particleEmitter.particleBirthRate = 50
        particleEmitter.particleLifetime = 0.5
        particleEmitter.particlePosition = node.position
        particleEmitter.particleSpeed = 100
        particleEmitter.particleSpeedRange = 50
        particleEmitter.particleAlpha = 0.8
        particleEmitter.particleScale = 0.1
        particleEmitter.particleColor = .yellow
        particleEmitter.particleColorBlendFactor = 1.0
        
        addChild(particleEmitter)
        
        // Remove particles after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            particleEmitter.removeFromParent()
        }
    }
}