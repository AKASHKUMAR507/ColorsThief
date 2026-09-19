import SpriteKit

extension SKSpriteNode {
    /// An SF Symbol rendered as a tinted sprite — used for HUD glyphs (home, lock, play, star…).
    /// The tint is rasterised, because SKTexture reads the raw CGImage and ignores UIImage tinting.
    static func symbol(_ name: String,
                       pointSize: CGFloat,
                       weight: UIImage.SymbolWeight = .heavy,
                       color: UIColor) -> SKSpriteNode {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        guard let base = UIImage(systemName: name, withConfiguration: config) else {
            return SKSpriteNode(color: .clear, size: CGSize(width: pointSize, height: pointSize))
        }
        let renderer = UIGraphicsImageRenderer(size: base.size)
        let image = renderer.image { _ in
            base.withTintColor(color, renderingMode: .alwaysOriginal)
                .draw(in: CGRect(origin: .zero, size: base.size))
        }
        return SKSpriteNode(texture: SKTexture(image: image), size: image.size)
    }
}
