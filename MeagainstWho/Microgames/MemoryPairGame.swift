import SpriteKit

class MemoryPairGame: Microgame {
    private weak var scene: SKScene?
    private var tiles: [SKNode] = []
    private var flippedTiles: [SKNode] = []
    private var matchedPairs = 0
    private var targetPairs = 1
    private var isFlipping = false
    
    private let icons = ["🍎", "🍊", "🍌", "🍇", "🍓", "🥝"]
    
    func start(in scene: SKScene) {
        self.scene = scene
        setupTiles()
    }
    
    private func setupTiles() {
        guard let scene = scene else { return }
        
        // Create 4 tiles (2 pairs)
        let tilePositions = [
            CGPoint(x: 100, y: 300),
            CGPoint(x: 200, y: 300),
            CGPoint(x: 100, y: 200),
            CGPoint(x: 200, y: 200)
        ]
        
        // Shuffle icons
        let shuffledIcons = icons.shuffled()
        
        for (index, position) in tilePositions.enumerated() {
            let tile = createTile(with: shuffledIcons[index % 2], at: position)
            scene.addChild(tile)
            tiles.append(tile)
        }
    }
    
    private func createTile(with icon: String, at position: CGPoint) -> SKNode {
        let tile = SKNode()
        
        // Tile background
        let background = SKShapeNode(rectOf: CGSize(width: 80, height: 80), cornerRadius: 10)
        background.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 1.0)
        background.strokeColor = .white
        background.lineWidth = 2
        tile.addChild(background)
        
        // Tile icon
        let iconLabel = SKLabelNode(fontNamed: "Arial")
        iconLabel.text = icon
        iconLabel.fontSize = 30
        iconLabel.position = CGPoint(x: 0, y: -10)
        iconLabel.horizontalAlignmentMode = .center
        tile.addChild(iconLabel)
        
        tile.position = position
        
        // Store icon for matching
        tile.userData = ["icon": icon]
        
        // Add flip animation
        let flip = SKAction.sequence([
            SKAction.scaleX(to: 0, duration: 0.2),
            SKAction.scaleX(to: 1, duration: 0.2)
        ])
        tile.run(flip)
        
        return tile
    }
    
    func update(_ currentTime: TimeInterval) {
        // Check if target pairs reached
        if matchedPairs >= targetPairs {
            // Success!
            HapticsService.shared.success()
            AudioService.shared.playSuccessSound()
            createSuccessEffect()
        }
    }
    
    func handleTouch(_ location: CGPoint) {
        guard !isFlipping else { return }
        
        for tile in tiles {
            if tile.contains(location) {
                flipTile(tile)
                break
            }
        }
    }
    
    private func flipTile(_ tile: SKNode) {
        guard !flippedTiles.contains(tile) else { return }
        
        isFlipping = true
        
        // Add to flipped tiles
        flippedTiles.append(tile)
        
        // Animate flip
        let flip = SKAction.sequence([
            SKAction.scaleX(to: 0, duration: 0.2),
            SKAction.scaleX(to: 1, duration: 0.2)
        ])
        tile.run(flip)
        
        // Haptic feedback
        HapticsService.shared.light()
        
        // Check for matches
        if flippedTiles.count == 2 {
            checkForMatch()
        }
    }
    
    private func checkForMatch() {
        guard flippedTiles.count == 2 else { return }
        
        let tile1 = flippedTiles[0]
        let tile2 = flippedTiles[1]
        
        let icon1 = tile1.userData?["icon"] as? String
        let icon2 = tile2.userData?["icon"] as? String
        
        if icon1 == icon2 {
            // Match!
            matchTiles(tile1, tile2)
        } else {
            // No match - flip back
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.flipBackTiles()
            }
        }
    }
    
    private func matchTiles(_ tile1: SKNode, _ tile2: SKNode) {
        // Remove from flipped tiles
        flippedTiles.removeAll()
        
        // Increment matched pairs
        matchedPairs += 1
        
        // Create match effect
        createMatchEffect(at: tile1.position)
        createMatchEffect(at: tile2.position)
        
        // Remove tiles
        tile1.removeFromParent()
        tile2.removeFromParent()
        
        // Remove from tiles array
        if let index1 = tiles.firstIndex(of: tile1) {
            tiles.remove(at: index1)
        }
        if let index2 = tiles.firstIndex(of: tile2) {
            tiles.remove(at: index2)
        }
        
        // Haptic feedback
        HapticsService.shared.success()
        
        // Sound
        AudioService.shared.playSuccessSound()
        
        isFlipping = false
    }
    
    private func flipBackTiles() {
        for tile in flippedTiles {
            let flip = SKAction.sequence([
                SKAction.scaleX(to: 0, duration: 0.2),
                SKAction.scaleX(to: 1, duration: 0.2)
            ])
            tile.run(flip)
        }
        
        flippedTiles.removeAll()
        isFlipping = false
        
        // Haptic feedback
        HapticsService.shared.error()
    }
    
    private func createMatchEffect(at position: CGPoint) {
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
        tiles.removeAll()
        flippedTiles.removeAll()
        matchedPairs = 0
        isFlipping = false
    }
}