import UIKit

/// Thin wrapper over UIFeedbackGenerator, gated by the Vibration setting.
enum HapticManager {
    
    private static let impact = UIImpactFeedbackGenerator(style: .medium)
    private static let notify = UINotificationFeedbackGenerator()
    
    static var isEnabled: Bool {
        UserDefaults.standard.object(forKey: UserDefaultsKeys.vibrationEnabled) as? Bool ?? true
    }
    
    static func prepare() {
        guard isEnabled else { return }
        impact.prepare()
    }
    
    /// Squishy tap on an object or orb.
    static func tap() {
        guard isEnabled else { return }
        impact.impactOccurred()
    }
    
    /// Level complete.
    static func success() {
        guard isEnabled else { return }
        notify.notificationOccurred(.success)
    }
}
