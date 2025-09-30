import SpriteKit
import SwiftUI

protocol MicrogameSceneDelegate: AnyObject {
    func microgameCompleted(success: Bool)
}

class MicrogameScene: SKScene {
    weak var microgameDelegate: MicrogameSceneDelegate?
    
    private let microgame: Microgame
    private let duration: TimeInterval
    private var timeRemaining: TimeInterval
    private var timer: Timer?
    
    private var progressBar: SKShapeNode?
    private var timeLabel: SKLabelNode?
    private var clueBanner: SKNode?
    
    init(microgame: Microgame, duration: TimeInterval) {
        self.microgame = microgame
        self.duration = duration
        self.timeRemaining = duration
        super.init(size: CGSize(width: 400, height: 800))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        // Ensure the scene fills the available view
        self.scaleMode = .resizeFill
        self.size = view.bounds.size
        setupBackground()
        setupTimer()
        setupProgressBar()
        setupMicrogame()
    }
    
    private func setupBackground() {
        backgroundColor = SKColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 1.0)
    }
    
    private func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func updateTimer() {
        timeRemaining -= 0.1
        
        if timeRemaining <= 0 {
            timer?.invalidate()
            timer = nil
            microgame.teardown()
            microgameDelegate?.microgameCompleted(success: false)
        } else {
            updateProgressBar()
        }
    }
    
    private func setupProgressBar() {
        let background = SKShapeNode(rectOf: CGSize(width: 300, height: 20), cornerRadius: 10)
        background.fillColor = SKColor.black.withAlphaComponent(0.3)
        background.strokeColor = .clear
        background.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        addChild(background)
        
        progressBar = SKShapeNode(rectOf: CGSize(width: 300, height: 20), cornerRadius: 10)
        progressBar?.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0)
        progressBar?.strokeColor = .clear
        progressBar?.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        addChild(progressBar!)
        
        timeLabel = SKLabelNode(fontNamed: "Arial-Bold")
        timeLabel?.text = "\(Int(timeRemaining))"
        timeLabel?.fontSize = 16
        timeLabel?.fontColor = .white
        timeLabel?.position = CGPoint(x: frame.midX, y: frame.maxY - 30)
        timeLabel?.horizontalAlignmentMode = .center
        addChild(timeLabel!)
    }
    
    private func updateProgressBar() {
        let progress = timeRemaining / duration
        let width = 300 * progress
        
        if let bar = progressBar {
            let rect = CGRect(x: -(width / 2.0), y: -10.0, width: width, height: 20.0)
            let path = CGPath(roundedRect: rect, cornerWidth: 10.0, cornerHeight: 10.0, transform: nil)
            bar.path = path
        }
        timeLabel?.text = "\(Int(timeRemaining))"
    }
    
    private func setupMicrogame() {
        microgame.start(in: self)
    }
    
    func showClueBanner(clue: Clue) {
        // Remove existing banner
        clueBanner?.removeFromParent()
        
        // Create new banner
        let banner = SKNode()
        
        // Background
        let background = SKShapeNode(rectOf: CGSize(width: 350, height: 80), cornerRadius: 20)
        background.fillColor = SKColor.black.withAlphaComponent(0.8)
        background.strokeColor = .white
        background.lineWidth = 2
        banner.addChild(background)
        
        // Clue content based on type
        switch clue.type {
        case .color:
            let colorNode = SKShapeNode(circleOfRadius: 20)
            colorNode.fillColor = SKColor(hex: clue.displayValue) ?? .white
            colorNode.strokeColor = .white
            colorNode.lineWidth = 2
            colorNode.position = CGPoint(x: -100, y: 0)
            banner.addChild(colorNode)
            
            let label = SKLabelNode(fontNamed: "Arial-Bold")
            label.text = "COLOR CLUE!"
            label.fontSize = 16
            label.fontColor = .white
            label.position = CGPoint(x: 0, y: 0)
            label.horizontalAlignmentMode = .center
            banner.addChild(label)
            
        case .sound:
            let soundIcon = SKLabelNode(fontNamed: "Arial")
            soundIcon.text = "🔊"
            soundIcon.fontSize = 24
            soundIcon.position = CGPoint(x: -100, y: 0)
            banner.addChild(soundIcon)
            
            let label = SKLabelNode(fontNamed: "Arial-Bold")
            label.text = "SOUND CLUE!"
            label.fontSize = 16
            label.fontColor = .white
            label.position = CGPoint(x: 0, y: 0)
            label.horizontalAlignmentMode = .center
            banner.addChild(label)
            
        case .sticker:
            let stickerIcon = SKLabelNode(fontNamed: "Arial")
            stickerIcon.text = clue.displayValue
            stickerIcon.fontSize = 24
            stickerIcon.position = CGPoint(x: -100, y: 0)
            banner.addChild(stickerIcon)
            
            let label = SKLabelNode(fontNamed: "Arial-Bold")
            label.text = "STICKER CLUE!"
            label.fontSize = 16
            label.fontColor = .white
            label.position = CGPoint(x: 0, y: 0)
            label.horizontalAlignmentMode = .center
            banner.addChild(label)
        }
        
        banner.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(banner)
        
        clueBanner = banner
        
        // Animate in
        banner.alpha = 0
        banner.setScale(0.5)
        banner.run(SKAction.group([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ]))
        
        // Play sound
        AudioService.shared.playSound(ClueService.shared.getSoundForClue(clue))
        
        // Haptic feedback
        HapticsService.shared.light()
        
        // Auto-hide after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            banner.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        microgame.handleTouch(location)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        microgame.handleTouch(location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        microgame.handleTouch(location)
    }
    
    override func update(_ currentTime: TimeInterval) {
        microgame.update(currentTime)
    }
    
    deinit {
        timer?.invalidate()
        microgame.teardown()
    }
}

extension SKColor {
    convenience init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}