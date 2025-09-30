import Foundation

struct Opponent: Identifiable, Codable, Equatable {
    enum TokenColor: String, Codable, CaseIterable {
        case orange, gold, yellow, green, purple, blue
        
        var uiColor: String {
            switch self {
            case .orange: return "#FF8C00"
            case .gold: return "#FFD700"
            case .yellow: return "#FFFF00"
            case .green: return "#00FF00"
            case .purple: return "#800080"
            case .blue: return "#0000FF"
            }
        }
    }
    
    enum TokenSound: String, Codable, CaseIterable {
        case snare, fanfare, thunder, marimba, sparkle, beep
    }
    
    enum TokenSticker: String, Codable, CaseIterable {
        case paw, crown, lightning, leaf, star, gear
        
        var emoji: String {
            switch self {
            case .paw: return "🦶"
            case .crown: return "👑"
            case .lightning: return "⚡"
            case .leaf: return "🍃"
            case .star: return "⭐"
            case .gear: return "⚙️"
            }
        }
    }
    
    let id: String
    let name: String
    let emoji: String
    let color: TokenColor
    let sound: TokenSound
    let sticker: TokenSticker
    
    static let allOpponents: [Opponent] = [
        Opponent(id: "fox", name: "Fox", emoji: "🦊", color: .orange, sound: .snare, sticker: .paw),
        Opponent(id: "king", name: "King", emoji: "👑", color: .gold, sound: .fanfare, sticker: .crown),
        Opponent(id: "thunder", name: "Thunder", emoji: "⚡", color: .yellow, sound: .thunder, sticker: .lightning),
        Opponent(id: "leaf", name: "Leaf", emoji: "🍃", color: .green, sound: .marimba, sticker: .leaf),
        Opponent(id: "star", name: "Star", emoji: "⭐", color: .purple, sound: .sparkle, sticker: .star),
        Opponent(id: "robo", name: "Robo", emoji: "🤖", color: .blue, sound: .beep, sticker: .gear)
    ]
}