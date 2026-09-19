import Foundation

/// Lightweight persisted stats shown on the Home screen. Level-level progress
/// (per-level stars, completion) lands in LevelProgress in Phase 3.
enum PlayerStats {
    private static let defaults = UserDefaults.standard
    
    static var colorsRestored: Int {
        get { defaults.integer(forKey: UserDefaultsKeys.colorsRestored) }
        set { defaults.set(newValue, forKey: UserDefaultsKeys.colorsRestored) }
    }
    
    /// Sum of best stars across levels (see LevelProgressStore).
    static var starsEarned: Int { LevelProgressStore.totalStars }
    
    /// Worlds the player can currently play in.
    static var worldsUnlocked: Int {
        Set(LevelData.all.filter { $0.isUnlocked }.map { $0.worldName }).count
    }
    
    /// Full-game IAP flag (StoreKit wiring lands in Phase 5).
    static var hasFullGame: Bool {
        get { defaults.bool(forKey: UserDefaultsKeys.hasFullGame) }
        set { defaults.set(newValue, forKey: UserDefaultsKeys.hasFullGame) }
    }
    
    /// Defaults to true when the key has never been written.
    static var musicEnabled: Bool {
        get { defaults.object(forKey: UserDefaultsKeys.musicEnabled) as? Bool ?? true }
        set { defaults.set(newValue, forKey: UserDefaultsKeys.musicEnabled) }
    }
}
