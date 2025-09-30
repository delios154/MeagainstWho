import Foundation
import Combine

class GameSettings: ObservableObject {
    @Published var soundOn: Bool {
        didSet { UserDefaults.standard.set(soundOn, forKey: "soundOn") }
    }
    
    @Published var hapticsOn: Bool {
        didSet { UserDefaults.standard.set(hapticsOn, forKey: "hapticsOn") }
    }
    
    @Published var tiltOn: Bool {
        didSet { UserDefaults.standard.set(tiltOn, forKey: "tiltOn") }
    }
    
    @Published var reducedMotion: Bool {
        didSet { UserDefaults.standard.set(reducedMotion, forKey: "reducedMotion") }
    }
    
    init() {
        self.soundOn = UserDefaults.standard.object(forKey: "soundOn") as? Bool ?? true
        self.hapticsOn = UserDefaults.standard.object(forKey: "hapticsOn") as? Bool ?? true
        self.tiltOn = UserDefaults.standard.object(forKey: "tiltOn") as? Bool ?? false
        self.reducedMotion = UserDefaults.standard.object(forKey: "reducedMotion") as? Bool ?? false
    }
    
    func reset() {
        soundOn = true
        hapticsOn = true
        tiltOn = false
        reducedMotion = false
    }
}