import SpriteKit

/// Full-screen celebration confetti (spec: SKEmitterNode). One emitter per colour so
/// the pieces stay candy-bright instead of blending; each emits along the top edge.
/// NOTE: SpriteKit hit-tests emitters like any node, so keep interactive nodes at a higher zPosition.
enum Confetti {
    
    private static let pieceTexture: SKTexture = {
        let size = CGSize(width: 12, height: 16)
        let image = UIGraphicsImageRenderer(size: size).image { ctx in
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.addPath(CGPath(roundedRect: CGRect(origin: .zero, size: size),
                                         cornerWidth: 3, cornerHeight: 3, transform: nil))
            ctx.cgContext.fillPath()
        }
        return SKTexture(image: image)
    }()
    
    /// Emitters spanning `width` at the top of the screen. Add them at y = top edge.
    static func rain(width: CGFloat, burst: Bool = true) -> [SKEmitterNode] {
        let colors: [UIColor] = [.sunshineYellow, .skyBlue, .grassGreen, .coralRed, .hotPink, .lavender]
        return colors.map { color in
            let e = SKEmitterNode()
            e.particleTexture          = pieceTexture
            e.particleBirthRate        = burst ? 4 : 1.5
            e.particleLifetime         = 5
            e.particleLifetimeRange    = 1.5
            e.particlePositionRange    = CGVector(dx: width, dy: 20)
            e.emissionAngle            = -.pi / 2
            e.emissionAngleRange       = .pi * 0.25
            e.particleSpeed            = 90
            e.particleSpeedRange       = 50
            e.yAcceleration            = -30
            e.xAcceleration            = 0
            e.particleScale            = 0.8
            e.particleScaleRange       = 0.4
            e.particleRotationRange    = .pi * 2
            e.particleRotationSpeed    = 3
            e.particleAlpha            = 1
            e.particleAlphaSpeed       = -0.18
            e.particleColor            = color
            e.particleColorBlendFactor = 1
            e.particleBlendMode        = .alpha
            if burst {
                // Big opening burst, then settle to a gentle drizzle
                e.run(SKAction.sequence([SKAction.wait(forDuration: 1.2),
                                         SKAction.run { e.particleBirthRate = 1.2 }]))
            }
            return e
        }
    }
}
