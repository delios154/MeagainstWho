import XCTest
@testable import MeAgainstWho

class ClueServiceTests: XCTestCase {
    var clueService: ClueService!
    
    override func setUp() {
        super.setUp()
        clueService = ClueService.shared
    }
    
    override func tearDown() {
        clueService = nil
        super.tearDown()
    }
    
    func testGenerateCluesForFox() {
        let fox = Opponent.allOpponents.first { $0.id == "fox" }!
        let clues = clueService.generateClues(for: fox)
        
        XCTAssertEqual(clues.count, 3)
        
        let clueTypes = clues.map { $0.type }
        XCTAssertTrue(clueTypes.contains(.color))
        XCTAssertTrue(clueTypes.contains(.sound))
        XCTAssertTrue(clueTypes.contains(.sticker))
        
        // Check color clue
        let colorClue = clues.first { $0.type == .color }!
        XCTAssertEqual(colorClue.value, "orange")
        XCTAssertEqual(colorClue.displayValue, "#FF8C00")
        
        // Check sound clue
        let soundClue = clues.first { $0.type == .sound }!
        XCTAssertEqual(soundClue.value, "snare")
        
        // Check sticker clue
        let stickerClue = clues.first { $0.type == .sticker }!
        XCTAssertEqual(stickerClue.value, "paw")
        XCTAssertEqual(stickerClue.displayValue, "🦶")
    }
    
    func testGenerateCluesForKing() {
        let king = Opponent.allOpponents.first { $0.id == "king" }!
        let clues = clueService.generateClues(for: king)
        
        XCTAssertEqual(clues.count, 3)
        
        // Check color clue
        let colorClue = clues.first { $0.type == .color }!
        XCTAssertEqual(colorClue.value, "gold")
        XCTAssertEqual(colorClue.displayValue, "#FFD700")
        
        // Check sound clue
        let soundClue = clues.first { $0.type == .sound }!
        XCTAssertEqual(soundClue.value, "fanfare")
        
        // Check sticker clue
        let stickerClue = clues.first { $0.type == .sticker }!
        XCTAssertEqual(stickerClue.value, "crown")
        XCTAssertEqual(stickerClue.displayValue, "👑")
    }
    
    func testGenerateCluesForAllOpponents() {
        for opponent in Opponent.allOpponents {
            let clues = clueService.generateClues(for: opponent)
            
            XCTAssertEqual(clues.count, 3)
            
            let clueTypes = clues.map { $0.type }
            XCTAssertTrue(clueTypes.contains(.color))
            XCTAssertTrue(clueTypes.contains(.sound))
            XCTAssertTrue(clueTypes.contains(.sticker))
            
            // Check that clues match opponent properties
            let colorClue = clues.first { $0.type == .color }!
            XCTAssertEqual(colorClue.value, opponent.color.rawValue)
            
            let soundClue = clues.first { $0.type == .sound }!
            XCTAssertEqual(soundClue.value, opponent.sound.rawValue)
            
            let stickerClue = clues.first { $0.type == .sticker }!
            XCTAssertEqual(stickerClue.value, opponent.sticker.rawValue)
        }
    }
    
    func testGetColorForClue() {
        let fox = Opponent.allOpponents.first { $0.id == "fox" }!
        let clues = clueService.generateClues(for: fox)
        let colorClue = clues.first { $0.type == .color }!
        
        let color = clueService.getColorForClue(colorClue)
        XCTAssertEqual(color, "#FF8C00")
    }
    
    func testGetSoundForClue() {
        let fox = Opponent.allOpponents.first { $0.id == "fox" }!
        let clues = clueService.generateClues(for: fox)
        let soundClue = clues.first { $0.type == .sound }!
        
        let sound = clueService.getSoundForClue(soundClue)
        XCTAssertEqual(sound, "snare")
    }
    
    func testGetStickerForClue() {
        let fox = Opponent.allOpponents.first { $0.id == "fox" }!
        let clues = clueService.generateClues(for: fox)
        let stickerClue = clues.first { $0.type == .sticker }!
        
        let sticker = clueService.getStickerForClue(stickerClue)
        XCTAssertEqual(sticker, "🦶")
    }
}