import Foundation

struct LevelProgress: Codable {
    let levelId: Int
    var starsEarned: Int          // 0, 1, 2, or 3
    var isCompleted: Bool
    var bestTime: TimeInterval    // for star rating
}

/// What a level card shows on the Level Select grid.
enum LevelState: Equatable {
    case completed(stars: Int)
    case current
    case locked      // not reached yet
    case premium     // reached, but needs the full-game purchase
}

/// UserDefaults-backed persistence for per-level progress + the unlock progression rules.
enum LevelProgressStore {
    
    private static let defaults = UserDefaults.standard
    
    static func all() -> [LevelProgress] {
        guard let data = defaults.data(forKey: UserDefaultsKeys.levelProgress),
              let list = try? JSONDecoder().decode([LevelProgress].self, from: data) else { return [] }
        return list
    }
    
    static func progress(for levelId: Int) -> LevelProgress? {
        all().first { $0.levelId == levelId }
    }
    
    /// Records a completion, keeping the best stars and fastest time.
    static func record(levelId: Int, stars: Int, time: TimeInterval) {
        var list = all()
        if let i = list.firstIndex(where: { $0.levelId == levelId }) {
            list[i].starsEarned = max(list[i].starsEarned, stars)
            list[i].bestTime    = list[i].isCompleted ? min(list[i].bestTime, time) : time
            list[i].isCompleted = true
        } else {
            list.append(LevelProgress(levelId: levelId, starsEarned: stars, isCompleted: true, bestTime: time))
        }
        if let data = try? JSONEncoder().encode(list) {
            defaults.set(data, forKey: UserDefaultsKeys.levelProgress)
        }
    }
    
    static func isCompleted(_ levelId: Int) -> Bool {
        progress(for: levelId)?.isCompleted ?? false
    }
    
    /// Completed → replayable. Current → first unlocked, incomplete level whose predecessor is done.
    /// Everything else (IAP-locked or not reached yet) → locked.
    static func state(for level: Level) -> LevelState {
        if let p = progress(for: level.id), p.isCompleted {
            return .completed(stars: p.starsEarned)
        }
        let previousDone = level.id == 1 || isCompleted(level.id - 1)
        guard previousDone else { return .locked }
        return level.isUnlocked ? .current : .premium
    }
    
    static var totalStars: Int {
        all().reduce(0) { $0 + $1.starsEarned }
    }
    
    static var completedCount: Int {
        all().filter { $0.isCompleted }.count
    }
    
    /// Spec: stars = time < 30s ? 3 : time < 60s ? 2 : 1
    static func stars(forTime time: TimeInterval) -> Int {
        time < 30 ? 3 : (time < 60 ? 2 : 1)
    }
}
