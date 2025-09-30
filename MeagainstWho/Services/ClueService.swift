import Foundation

class ClueService {
    static let shared = ClueService()
    
    private init() {}
    
    func generateClues(for opponent: Opponent) -> [Clue] {
        let clueTypes: [ClueType] = [.color, .sound, .sticker]
        var clues: [Clue] = []
        
        for type in clueTypes {
            let clue = createClue(for: opponent, type: type)
            clues.append(clue)
        }
        
        return clues
    }
    
    private func createClue(for opponent: Opponent, type: ClueType) -> Clue {
        switch type {
        case .color:
            return Clue(
                type: .color,
                value: opponent.color.rawValue,
                displayValue: opponent.color.uiColor
            )
        case .sound:
            return Clue(
                type: .sound,
                value: opponent.sound.rawValue,
                displayValue: opponent.sound.rawValue
            )
        case .sticker:
            return Clue(
                type: .sticker,
                value: opponent.sticker.rawValue,
                displayValue: opponent.sticker.emoji
            )
        }
    }
    
    func getColorForClue(_ clue: Clue) -> String {
        guard clue.type == .color else { return "#FFFFFF" }
        return clue.displayValue
    }
    
    func getSoundForClue(_ clue: Clue) -> String {
        guard clue.type == .sound else { return "beep" }
        return clue.value
    }
    
    func getStickerForClue(_ clue: Clue) -> String {
        guard clue.type == .sticker else { return "❓" }
        return clue.displayValue
    }
}