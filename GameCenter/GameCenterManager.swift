import GameKit
import Foundation

class GameCenterManager: ObservableObject {
    static let shared = GameCenterManager()
    
    @Published var isAuthenticated = false
    @Published var localPlayer: GKLocalPlayer?
    
    private init() {
        localPlayer = GKLocalPlayer.local
        authenticatePlayer()
    }
    
    func authenticatePlayer() {
        guard let localPlayer = localPlayer else { return }
        
        localPlayer.authenticateHandler = { [weak self] viewController, error in
            DispatchQueue.main.async {
                if let viewController = viewController {
                    // Present authentication view controller
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController?.present(viewController, animated: true)
                    }
                } else if localPlayer.isAuthenticated {
                    self?.isAuthenticated = true
                    self?.loadAchievements()
                } else {
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    // MARK: - Achievements
    private func loadAchievements() {
        guard isAuthenticated else { return }
        
        GKAchievement.loadAchievements { achievements, error in
            if let error = error {
                print("Failed to load achievements: \(error)")
            }
        }
    }
    
    func reportAchievement(_ achievementID: String, percentComplete: Double = 100.0) {
        guard isAuthenticated else { return }
        
        let achievement = GKAchievement(identifier: achievementID)
        achievement.percentComplete = percentComplete
        
        GKAchievement.report([achievement]) { error in
            if let error = error {
                print("Failed to report achievement: \(error)")
            }
        }
    }
    
    // MARK: - Leaderboards
    func reportScore(_ score: Int, leaderboardID: String) {
        guard isAuthenticated else { return }
        
        GKLeaderboard.submitScore(score, category: leaderboardID) { error in
            if let error = error {
                print("Failed to report score: \(error)")
            }
        }
    }
    
    func showLeaderboard() {
        guard isAuthenticated else { return }
        
        let viewController = GKGameCenterViewController(leaderboardID: "daily_streak", playerScope: .global, timeScope: .allTime)
        viewController.gameCenterDelegate = self
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(viewController, animated: true)
        }
    }
    
    func showAchievements() {
        guard isAuthenticated else { return }
        
        let viewController = GKGameCenterViewController(state: .achievements)
        viewController.gameCenterDelegate = self
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(viewController, animated: true)
        }
    }
    
    // MARK: - Game-specific achievements
    func checkFirstWinAchievement() {
        reportAchievement("first_win")
    }
    
    func checkStreakAchievement(streak: Int) {
        if streak >= 10 {
            reportAchievement("ten_streak")
        }
    }
    
    func checkPerfectRoundAchievement() {
        reportAchievement("perfect_round")
    }
    
    func reportDailyStreak(_ streak: Int) {
        reportScore(streak, leaderboardID: "daily_streak")
    }
}

extension GameCenterManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}