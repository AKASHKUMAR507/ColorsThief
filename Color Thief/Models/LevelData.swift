import UIKit

/// 25 levels in 5 worlds. All levels are free (freeLevelCount == all); the StoreKit
/// unlock stays wired for later, but nothing is locked behind it right now.
enum LevelData {
    
    static let levelsPerWorld = 5
    
    /// Per world: a pool of friends (hand-made keys and generator categories) and a palette.
    /// Each level draws from its world's pool with a seeded RNG, so level N is always the same
    /// character but no two levels look alike. Garden is the "anything goes" world.
    private static let worlds: [(name: String, pool: [String], palette: [UIColor])] = [
        ("Forest", ["gen:tree", "gen:animal", "butterfly", "gen:tree", "mushroom", "gen:animal", "ladybug", "flower"],
                   [.grassGreen, .sunshineYellow, .coralRed, .skyBlue, .hotPink, .lavender]),
        ("Farm",   ["gen:animal", "gen:house", "barn", "pig", "gen:car", "chick", "gen:house", "gen:animal"],
                   [.coralRed, .sunshineYellow, .grassGreen, .hotPink, .skyBlue, .lavender]),
        ("Ocean",  ["gen:fish", "gen:fish", "gen:fish", "boat", "whale", "gen:fish", "fish"],
                   [.skyBlue, .mintGreen, .coralRed, .sunshineYellow, .lavender, .hotPink]),
        ("Sky",    ["gen:sky", "gen:sky", "balloon", "rocket", "sun", "gen:sky", "gen:sky"],
                   [.sunshineYellow, .skyBlue, .coralRed, .lavender, .mintGreen, .hotPink]),
        ("Garden", ["gen:fish", "gen:animal", "gen:house", "gen:car", "gen:tree", "gen:sky", "butterfly", "ladybug"],
                   [.hotPink, .grassGreen, .sunshineYellow, .lavender, .skyBlue, .coralRed])
    ]
    
    static var freeLevelCount: Int { worlds.count * levelsPerWorld }
    
    static var all: [Level] {
        let full = PlayerStats.hasFullGame
        var levels: [Level] = []
        for world in worlds {
            for _ in 0..<levelsPerWorld {
                let id = levels.count + 1
                var rng = SeededRNG(seed: id * 104_729 + 17)
                let entry = world.pool[Int(rng.next() % UInt64(world.pool.count))]
                // Generator entries get a per-level seed so the same category still varies
                let key = entry.hasPrefix("gen:") ? "\(entry):\(id)" : entry
                let shift = Int(rng.next() % UInt64(world.palette.count))
                let colors = Array(world.palette[shift...] + world.palette[..<shift])
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
