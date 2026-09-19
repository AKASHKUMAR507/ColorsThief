import SpriteKit

/// Simple storybook face (dot eyes, smile, optional blush) scaled to a body radius.
enum KawaiiFace {
    
    static func make(scale r: CGFloat, ink: UIColor = .darkNavy, blush: Bool = false, sleepy: Bool = false) -> SKNode {
        let n = SKNode()
        n.zPosition = 1
        for sx: CGFloat in [-0.35, 0.35] {
            if sleepy {
                let arc = SKShapeNode(path: arcPath(radius: r * 0.12, start: .pi, end: 0))
                arc.strokeColor = ink; arc.lineWidth = 2.5; arc.lineCap = .round
                arc.position = CGPoint(x: sx * r, y: r * 0.15)
                n.addChild(arc)
            } else {
                let eye = SKShapeNode(circleOfRadius: r * 0.12)
                eye.fillColor = ink; eye.strokeColor = .clear
                eye.position = CGPoint(x: sx * r, y: r * 0.15)
                n.addChild(eye)
            }
        }
        let smile = SKShapeNode(path: arcPath(radius: r * 0.28, start: .pi * 1.15, end: .pi * 1.85))
        smile.strokeColor = ink; smile.lineWidth = 2.5; smile.lineCap = .round
        smile.position = CGPoint(x: 0, y: -r * 0.05)
        n.addChild(smile)
        if blush {
            for sx: CGFloat in [-0.55, 0.55] {
                let b = SKShapeNode(circleOfRadius: r * 0.12)
                b.fillColor = UIColor.coralRed.withAlphaComponent(0.6); b.strokeColor = .clear
                b.position = CGPoint(x: sx * r, y: -r * 0.12)
                n.addChild(b)
            }
        }
        return n
    }
    
    static func arcPath(radius: CGFloat, start: CGFloat, end: CGFloat) -> CGPath {
        let p = CGMutablePath()
        p.addArc(center: .zero, radius: radius, startAngle: start, endAngle: end, clockwise: false)
        return p
    }
}
