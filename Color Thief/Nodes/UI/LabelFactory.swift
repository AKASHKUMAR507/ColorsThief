import SpriteKit

/// Helpers for the storybook "ink outline" text style used across the UI.
enum LabelFactory {
    
    /// A label whose glyphs are filled with `fill` and outlined in `stroke`.
    /// SKLabelNode can't stroke (attributedText stroke renders flipped), so the outline
    /// is built from 8 offset copies of the label underneath the filled one.
    static func outlined(_ text: String,
                         font: String = AppFonts.headline,
                         size: CGFloat,
                         fill: UIColor,
                         stroke: UIColor = .darkNavy,
                         strokeWidth: CGFloat = 3) -> SKNode {
        let container = SKNode()
        let offsets: [CGPoint] = [
            CGPoint(x: -1, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 0, y: -1), CGPoint(x: 0, y: 1),
            CGPoint(x: -0.7, y: -0.7), CGPoint(x: 0.7, y: -0.7), CGPoint(x: -0.7, y: 0.7), CGPoint(x: 0.7, y: 0.7)
        ]
        for o in offsets {
            let edge = body(text, font: font, size: size, color: stroke)
            edge.position = CGPoint(x: o.x * strokeWidth, y: o.y * strokeWidth)
            container.addChild(edge)
        }
        let face = body(text, font: font, size: size, color: fill)
        face.zPosition = 1
        container.addChild(face)
        return container
    }
    
    /// Outlined label with a solid offset shadow underneath — the logo/title treatment.
    static func title(_ text: String,
                      size: CGFloat,
                      fill: UIColor = .sunshineYellow,
                      stroke: UIColor = .darkNavy,
                      shadowColor: UIColor? = nil,
                      shadowOffset: CGFloat = 4) -> SKNode {
        let container = SKNode()
        let shadowFill = shadowColor ?? stroke
        let shadow = outlined(text, size: size, fill: shadowFill, stroke: shadowFill, strokeWidth: 3)
        shadow.position = CGPoint(x: 0, y: -shadowOffset)
        let face = outlined(text, size: size, fill: fill, stroke: stroke, strokeWidth: 3)
        face.zPosition = 1
        container.addChild(shadow)
        container.addChild(face)
        return container
    }
    
    static func body(_ text: String,
                     font: String = AppFonts.body,
                     size: CGFloat,
                     color: UIColor = .darkNavy) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName  = font
        label.fontSize  = size
        label.fontColor = color
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode   = .center
        return label
    }
}
