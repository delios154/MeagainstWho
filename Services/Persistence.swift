import Foundation

class PersistenceService {
    static let shared = PersistenceService()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Stars
    var totalStars: Int {
        get { userDefaults.integer(forKey: "totalStars") }
        set { userDefaults.set(newValue, forKey: "totalStars") }
    }
    
    func addStars(_ amount: Int) {
        totalStars += amount
    }
    
    // MARK: - Streak
    var currentStreak: Int {
        get { userDefaults.integer(forKey: "currentStreak") }
        set { userDefaults.set(newValue, forKey: "currentStreak") }
    }
    
    var bestStreak: Int {
        get { userDefaults.integer(forKey: "bestStreak") }
        set { userDefaults.set(newValue, forKey: "bestStreak") }
    }
    
    func incrementStreak() {
        currentStreak += 1
        if currentStreak > bestStreak {
            bestStreak = currentStreak
        }
    }
    
    func resetStreak() {
        currentStreak = 0
    }
    
    // MARK: - Daily Seed
    var lastPlayDate: String {
        get { userDefaults.string(forKey: "lastPlayDate") ?? "" }
        set { userDefaults.set(newValue, forKey: "lastPlayDate") }
    }
    
    var dailySeed: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    func getDailyOpponent() -> Opponent {
        let today = dailySeed
        if lastPlayDate != today {
            lastPlayDate = today
        }
        
        // Use date as seed for consistent daily opponent
        let seed = today.hash
        let opponentIndex = abs(seed) % Opponent.allOpponents.count
        return Opponent.allOpponents[opponentIndex]
    }
    
    // MARK: - Analytics
    var totalRoundsPlayed: Int {
        get { userDefaults.integer(forKey: "totalRoundsPlayed") }
        set { userDefaults.set(newValue, forKey: "totalRoundsPlayed") }
    }
    
    var totalPlayTime: TimeInterval {
        get { userDefaults.double(forKey: "totalPlayTime") }
        set { userDefaults.set(newValue, forKey: "totalPlayTime") }
    }
    
    func incrementRoundsPlayed() {
        totalRoundsPlayed += 1
    }
    
    func addPlayTime(_ time: TimeInterval) {
        totalPlayTime += time
    }
    
    // MARK: - Reset
    func resetAllProgress() {
        totalStars = 0
        currentStreak = 0
        bestStreak = 0
        totalRoundsPlayed = 0
        totalPlayTime = 0
        lastPlayDate = ""
    }
}