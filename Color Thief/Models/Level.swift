import UIKit

struct Level {
    let id: Int                 // 1...N
    let worldName: String       // "Forest", "Farm", "Ocean"
    let objectCount: Int        // grey objects to restore
    let availableColors: [UIColor]
    let isUnlocked: Bool        // free (1-3) or IAP
    let imageName: String       // asset catalog key
    
    /// Signature colour for this level's world (level cards, badges).
    var worldColor: UIColor {
        switch worldName {
        case "Forest": return .grassGreen
        case "Farm":   return .sunshineYellow
        case "Ocean":  return .skyBlue
        case "Sky":    return .lavender
        case "Garden": return .hotPink
        default:       return .coralRed
        }
    }
}
