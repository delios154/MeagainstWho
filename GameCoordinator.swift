import SwiftUI
import SpriteKit
import Foundation

enum GameState {
    case menu
    case playing
    case showingClue
    case guessing
    case result
    case bonus
}

class GameCoordinator: ObservableObject {
    @Published var currentScene: SKScene
    @Published var totalStars: Int = 0
    
    private var gameState: GameState = .menu
    private var currentRun: GameRun?
    private var currentMicrogameIndex = 0
    private var currentClueIndex = 0
    private var hiddenOpponent: Opponent?
    private var clues: [Clue] = []
    
    private let persistence = PersistenceService.shared
    private let clueService = ClueService.shared
    private let gameCenter = GameCenterManager.shared
    
    init() {
        self.currentScene = MenuScene()
        self.totalStars = persistence.totalStars
    }
    
    func start() {
        currentScene = MenuScene()
        gameState = .menu
    }
    
    func startNewRun() {
        // Select hidden opponent
        hiddenOpponent = Opponent.allOpponents.randomElement()
        guard let opponent = hiddenOpponent else { return }
        
        // Generate clues for this opponent
        clues = clueService.generateClues(for: opponent)
        currentClueIndex = 0
        
        // Create new run
        currentRun = GameRun(opponent: opponent, clues: clues)
        
        // Start first microgame
        startNextMicrogame()
    }
    
    private func startNextMicrogame() {
        guard let run = currentRun else { return }
        
        gameState = .playing
        currentMicrogameIndex += 1
        
        if currentMicrogameIndex <= 3 {
            let microgame = MicrogameFactory.createRandomMicrogame()
            let scene = MicrogameScene(microgame: microgame, duration: 5.0)
            scene.delegate = self
            currentScene = scene
        } else {
            // All microgames complete, show guess screen
            showGuessScreen()
        }
    }
    
    private func showGuessScreen() {
        gameState = .guessing
        let scene = GuessScene()
        scene.delegate = self
        currentScene = scene
    }
    
    func showClue() {
        guard currentClueIndex < clues.count else { return }
        
        let clue = clues[currentClueIndex]
        currentClueIndex += 1
        
        // Show clue banner
        if let microgameScene = currentScene as? MicrogameScene {
            microgameScene.showClueBanner(clue: clue)
        }
    }
    
    func makeGuess(_ opponent: Opponent) {
        guard let hiddenOpponent = hiddenOpponent else { return }
        
        let isCorrect = opponent.id == hiddenOpponent.id
        
        // Show result
        let resultScene = ResultScene(isCorrect: isCorrect, correctOpponent: hiddenOpponent)
        resultScene.delegate = self
        currentScene = resultScene
        
        if isCorrect {
            // Award stars
            let starsEarned = 1
            persistence.addStars(starsEarned)
            persistence.incrementStreak()
            totalStars = persistence.totalStars
            
            // Check achievements
            gameCenter.checkFirstWinAchievement()
            gameCenter.checkStreakAchievement(streak: persistence.currentStreak)
            
            // Report to leaderboard
            gameCenter.reportDailyStreak(persistence.currentStreak)
        } else {
            persistence.resetStreak()
        }
        
        persistence.incrementRoundsPlayed()
    }
    
    func startBonusRound() {
        gameState = .bonus
        let bonusScene = BonusScene()
        bonusScene.delegate = self
        currentScene = bonusScene
    }
    
    func returnToMenu() {
        start()
    }
}

// MARK: - MicrogameSceneDelegate
extension GameCoordinator: MicrogameSceneDelegate {
    func microgameCompleted(success: Bool) {
        if success {
            showClue()
            
            // Wait a bit then start next microgame
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.startNextMicrogame()
            }
        } else {
            // Retry current microgame
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.startNextMicrogame()
            }
        }
    }
}

// MARK: - GuessSceneDelegate
extension GameCoordinator: GuessSceneDelegate {
    func opponentSelected(_ opponent: Opponent) {
        makeGuess(opponent)
    }
}

// MARK: - ResultSceneDelegate
extension GameCoordinator: ResultSceneDelegate {
    func resultSceneFinished() {
        if let run = currentRun, run.wasCorrect {
            startBonusRound()
        } else {
            returnToMenu()
        }
    }
}

// MARK: - BonusSceneDelegate
extension GameCoordinator: BonusSceneDelegate {
    func bonusCompleted(starsEarned: Int) {
        persistence.addStars(starsEarned)
        totalStars = persistence.totalStars
        returnToMenu()
    }
}

// MARK: - Game Run Model
struct GameRun {
    let opponent: Opponent
    let clues: [Clue]
    var wasCorrect: Bool = false
    
    init(opponent: Opponent, clues: [Clue]) {
        self.opponent = opponent
        self.clues = clues
    }
}