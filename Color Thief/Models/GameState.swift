import UIKit

/// In-memory state for one play session of a level.
struct GameState {
    let currentLevel: Level
    var restoredCount: Int = 0
    let totalObjects: Int
    var activeColor: UIColor
    let startTime: Date = Date()
    
    init(level: Level) {
        currentLevel = level
        totalObjects = level.objectCount
        activeColor  = level.availableColors.first ?? .sunshineYellow
    }
    
    var elapsed: TimeInterval { Date().timeIntervalSince(startTime) }
    var isComplete: Bool { restoredCount >= totalObjects }
}
