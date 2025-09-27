import UIKit

class HapticsService {
    static let shared = HapticsService()
    
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    private init() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        notificationFeedback.prepare()
    }
    
    func light() {
        guard GameSettings().hapticsOn else { return }
        lightImpact.impactOccurred()
    }
    
    func medium() {
        guard GameSettings().hapticsOn else { return }
        mediumImpact.impactOccurred()
    }
    
    func heavy() {
        guard GameSettings().hapticsOn else { return }
        heavyImpact.impactOccurred()
    }
    
    func success() {
        guard GameSettings().hapticsOn else { return }
        notificationFeedback.notificationOccurred(.success)
    }
    
    func error() {
        guard GameSettings().hapticsOn else { return }
        notificationFeedback.notificationOccurred(.error)
    }
    
    func warning() {
        guard GameSettings().hapticsOn else { return }
        notificationFeedback.notificationOccurred(.warning)
    }
}