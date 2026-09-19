import SpriteKit

/// Sparkle burst for a restored object: 8–12 star particles float upward and fade.
/// Built in code (equivalent to the spec's TapSparkle.sks) so it works without the Xcode particle editor.
enum TapSparkle {
    
    private static let starTexture: SKTexture = {
        let size = CGSize(width: 24, height: 24)
        let image = UIGraphicsImageRenderer(size: size).image { ctx in
            let cg = ctx.cgContext
            let c = CGPoint(x: 12, y: 12)
            let path = CGMutablePath()
            for i in 0..<8 {
                let a = CGFloat(i) * .pi / 4 - .pi / 2
                let r: CGFloat = i % 2 == 0 ? 11 : 4.5
                let p = CGPoint(x: c.x + cos(a) * r, y: c.y + sin(a) * r)
                i == 0 ? path.move(to: p) : path.addLine(to: p)
            }
            path.closeSubpath()
            cg.setFillColor(UIColor.white.cgColor)
            cg.addPath(path)
            cg.fillPath()
        }
        return SKTexture(image: image)
    }()
    
    /// A one-shot emitter tinted toward `color`. Removes itself when finished.
    static func burst(color: UIColor) -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleTexture          = starTexture
        e.numParticlesToEmit       = Int.random(in: 8...12)
        e.particleBirthRate        = 120
        e.particleLifetime         = 0.7
        e.particleLifetimeRange    = 0.3
        e.emissionAngle            = .pi / 2
        e.emissionAngleRange       = .pi * 0.9
        e.particleSpeed            = 140
        e.particleSpeedRange       = 70
        e.yAcceleration            = 60
        e.particleScale            = 0.9
        e.particleScaleRange       = 0.4
        e.particleScaleSpeed       = -0.6
        e.particleAlphaSpeed       = -1.3
        e.particleRotationRange    = .pi
        e.particleRotationSpeed    = 2
        e.particleBlendMode        = .add
        e.particleColorBlendFactor = 1
        e.particleColorSequence    = SKKeyframeSequence(keyframeValues: [UIColor.white, color, UIColor.sunshineYellow],
                                                        times: [0, 0.3, 1])
        e.run(SKAction.sequence([SKAction.wait(forDuration: 1.2), SKAction.removeFromParent()]))
        return e
    }
}
