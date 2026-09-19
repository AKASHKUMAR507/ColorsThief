import UIKit

/// 25 levels in 5 worlds. All levels are free (freeLevelCount == all); the StoreKit
/// unlock stays wired for later, but nothing is locked behind it right now.
enum LevelData {
    
    static let levelsPerWorld = 5
    
    /// (world, friend keys in order, palette) — objectCount is each friend's region count
    private static let worlds: [(name: String, friends: [String], palette: [UIColor])] = [
        ("Forest", ["butterfly", "flower", "mushroom", "ladybug", "butterfly"],
                   [.grassGreen, .sunshineYellow, .coralRed, .skyBlue, .hotPink]),
        ("Farm",   ["barn", "pig", "chick", "flower", "pig"],
                   [.coralRed, .sunshineYellow, .grassGreen, .hotPink, .skyBlue]),
        ("Ocean",  ["fish", "boat", "whale", "fish", "boat"],
                   [.skyBlue, .mintGreen, .coralRed, .sunshineYellow, .lavender]),
        ("Sky",    ["sun", "balloon", "rocket", "sun", "balloon"],
                   [.sunshineYellow, .skyBlue, .coralRed, .lavender, .mintGreen]),
        ("Garden", ["ladybug", "mushroom", "flower", "butterfly", "rocket"],
                   [.hotPink, .grassGreen, .sunshineYellow, .lavender, .skyBlue])
    ]
    
    static var freeLevelCount: Int { worlds.count * levelsPerWorld }
    
    static var all: [Level] {
        let full = PlayerStats.hasFullGame
        var levels: [Level] = []
        for world in worlds {
            for (i, key) in world.friends.enumerated() {
                let id = levels.count + 1
                // Rotate the palette so the first (default) orb differs level to level
                let colors = Array(world.palette[i...] + world.palette[..<i])
                levels.append(Level(id: id, worldName: world.name,
                                    objectCount: FriendArt.friend(for: key).regions.count,
                                    availableColors: colors,
                                    isUnlocked: id <= freeLevelCount || full,
                                    imageName: key))
            }
        }
        return levels
    }
    
    static func level(id: Int) -> Level? {
        all.first { $0.id == id }
    }
    
    static func level(after level: Level) -> Level? {
        self.level(id: level.id + 1)
    }
    
    static func levels(inWorld name: String) -> [Level] {
        all.filter { $0.worldName == name }
    }
    
    static var worldNames: [String] {
        worlds.map { $0.name }
    }
    
    /// True when every level is playable without a purchase.
    static var everythingIsFree: Bool { freeLevelCount >= worlds.count * levelsPerWorld }
}
