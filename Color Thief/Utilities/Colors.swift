import UIKit

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = CGFloat((int >> 16) & 0xFF) / 255
        let g = CGFloat((int >> 8)  & 0xFF) / 255
        let b = CGFloat(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

extension UIColor {
    // Restored world
    static let sunshineYellow = UIColor(hex: "#FFD23F")
    static let skyBlue        = UIColor(hex: "#54C8FF")
    static let grassGreen     = UIColor(hex: "#4CD964")
    static let coralRed       = UIColor(hex: "#FF6B6B")
    static let hotPink        = UIColor(hex: "#FF4081")
    static let lavender       = UIColor(hex: "#C77DFF")
    static let mintGreen      = UIColor(hex: "#00E5CC")
    
    // Grey world
    static let skyGrey        = UIColor(hex: "#C8C8D4")
    static let groundGrey     = UIColor(hex: "#A8A8B8")
    static let objectGrey     = UIColor(hex: "#909099")
    static let outlineDark    = UIColor(hex: "#4A4A5A")
    
    // UI
    static let darkNavy       = UIColor(hex: "#1A1A2E")
    static let warmCream      = UIColor(hex: "#FFF9F0")
}

extension UIColor {
    /// Same hue, darker — used for the bottom "lip" of chunky buttons.
    func darkened(by amount: CGFloat = 0.25) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a) else { return self }
        return UIColor(hue: h, saturation: min(1, s + amount * 0.4), brightness: max(0, b - amount), alpha: a)
    }
}
