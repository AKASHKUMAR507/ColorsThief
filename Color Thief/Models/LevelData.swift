import UIKit

/// Hardcoded level list. Levels 1–3 are free; the rest unlock with the full-game IAP.
enum LevelData {
    
    static let freeLevelCount = 3
    
    static var all: [Level] {
        let full = PlayerStats.hasFullGame
        // (world, palette, friend key) — objectCount is the friend's region count
        let defs: [(String, [UIColor], String)] = [
            ("Forest", [.grassGreen, .sunshineYellow, .coralRed, .skyBlue],            "butterfly"),
            ("Forest", [.hotPink, .sunshineYellow, .grassGreen, .lavender, .skyBlue], "flower"),
            ("Farm",   [.coralRed, .sunshineYellow, .grassGreen, .skyBlue],           "barn"),
            ("Farm",   [.hotPink, .sunshineYellow, .lavender, .grassGreen, .coralRed], "pig"),
            ("Ocean",  [.skyBlue, .mintGreen, .coralRed, .sunshineYellow, .hotPink],  "fish"),
            ("Ocean",  [.coralRed, .sunshineYellow, .skyBlue, .mintGreen, .lavender, .grassGreen], "boat")
        ]
        return defs.enumerated().map { i, d in
            let id = i + 1
            let regionCount = FriendArt.friend(for: d.2).regions.count
            return Level(id: id, worldName: d.0, objectCount: regionCount, availableColors: d.1,
                         isUnlocked: id <= freeLevelCount || full, imageName: d.2)
        }
    }
    
    static func level(id: Int) -> Level? {
        all.first { $0.id == id }
    }
    
    static func level(after level: Level) -> Level? {
        self.level(id: level.id + 1)
    }
    
    static var worldNames: [String] {
        var seen: [String] = []
        for l in all where !seen.contains(l.worldName) { seen.append(l.worldName) }
        return seen
    }
}
