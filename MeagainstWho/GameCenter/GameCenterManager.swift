import GameKit
import Foundation
import Combine
import UIKit

class GameCenterManager: NSObject, ObservableObject {
    static let shared = GameCenterManager()
    
    @Published var isAuthenticated = false
    @Published var localPlayer: GKLocalPlayer?
    
    private override init() {
        localPlayer = GKLocalPlayer.local
        super.init()
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
        
        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [leaderboardID]
        ) { error in
            if let error = error {
                print("Failed to report score: \(error)")
            }
        }
    }
    
    func showLeaderboard() {
        guard isAuthenticated else { return }

        if #available(iOS 14.0, *) {
            GKAccessPoint.shared.trigger(state: .leaderboards) { }
            return
        }
    }
    
    func showAchievements() {
        guard isAuthenticated else { return }

        if #available(iOS 14.0, *) {
            GKAccessPoint.shared.trigger(state: .achievements) { }
            return
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

