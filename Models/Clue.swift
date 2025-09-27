import Foundation

enum ClueType: String, Codable, CaseIterable {
    case color, sound, sticker
}

struct ClueToken: Codable, Equatable {
    let type: ClueType
    let value: String
    
    init(type: ClueType, value: String) {
        self.type = type
        self.value = value
    }
}

struct Clue: Identifiable, Equatable {
    let id = UUID()
    let type: ClueType
    let value: String
    let displayValue: String
    
    init(type: ClueType, value: String, displayValue: String) {
        self.type = type
        self.value = value
        self.displayValue = displayValue
    }
}