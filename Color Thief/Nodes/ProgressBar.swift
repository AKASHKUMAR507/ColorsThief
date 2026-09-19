import SpriteKit

/// Gameplay progress: capsule track, yellow→mint gradient fill, paint bucket riding the fill edge.
class ProgressBar: SKNode {
    
    let barWidth: CGFloat
    let barHeight: CGFloat
    private(set) var progress: CGFloat = 0
    
    private let fillMask: SKShapeNode
    private let bucket = SKNode()
    
    init(width: CGFloat, height: CGFloat = 18) {
        barWidth  = width
        barHeight = height
        fillMask  = SKShapeNode()
        super.init()
        
        // Track
        let track = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: height / 2)
        track.fillColor   = UIColor(hex: "#EFE4D2")
        track.strokeColor = UIColor.darkNavy.withAlphaComponent(0.12)
        track.lineWidth   = 2
        addChild(track)
        
        // Fill (full-width gradient, revealed by a growing mask)
        let fill = SKSpriteNode(texture: .horizontalGradient(size: CGSize(width: width, height: height),
                                                             left: .sunshineYellow, right: .mintGreen),
                                size: CGSize(width: width, height: height))
        fillMask.fillColor   = .white
        fillMask.strokeColor = .clear
        fillMask.path        = maskPath(for: 0)
        let crop = SKCropNode()
        crop.maskNode = fillMask
        crop.addChild(fill)
        crop.zPosition = 1
        addChild(crop)
        
        // Shine stripe
        let shine = SKShapeNode(rectOf: CGSize(width: width - 8, height: height * 0.22), cornerRadius: height * 0.11)
        shine.fillColor   = UIColor.white.withAlphaComponent(0.35)
        shine.strokeColor = .clear
        shine.position    = CGPoint(x: 0, y: height * 0.24)
        shine.zPosition   = 2
        crop.addChild(shine)
        
        // Bucket
        bucket.addChild(makeBucket(size: height * 1.5))
        bucket.position  = CGPoint(x: -width / 2, y: height * 0.2)
        bucket.zPosition = 3
        addChild(bucket)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("not used") }
    
    func setProgress(_ value: CGFloat, animated: Bool = true) {
        let target = min(1, max(0, value))
        let start  = progress
        progress   = target
        
        guard animated else {
            fillMask.path   = maskPath(for: target)
            bucket.position.x = edgeX(for: target)
            return
        }
        
        let duration: TimeInterval = 0.3
        let grow = SKAction.customAction(withDuration: duration) { [weak self] _, elapsed in
            guard let self else { return }
            let t = min(elapsed / CGFloat(duration), 1)
            let eased = 1 - pow(1 - t, 3)
            let p = start + (target - start) * eased
            self.fillMask.path = self.maskPath(for: p)
            self.bucket.position.x = self.edgeX(for: p)
        }
        run(grow, withKey: "grow")
        
        // Bucket hops when the fill lands
        let hop = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 6, duration: 0.1),
            SKAction.moveBy(x: 0, y: -6, duration: 0.12)
        ])
        bucket.run(SKAction.sequence([SKAction.wait(forDuration: duration * 0.6), hop]))
    }
    
    // MARK: - Helpers
    
    private func maskPath(for p: CGFloat) -> CGPath {
        let w = max(barHeight, barWidth * p)   // never thinner than a full capsule end
        let rect = CGRect(x: -barWidth / 2, y: -barHeight / 2, width: w, height: barHeight)
        return CGPath(roundedRect: rect, cornerWidth: barHeight / 2, cornerHeight: barHeight / 2, transform: nil)
    }
    
    private func edgeX(for p: CGFloat) -> CGFloat {
        -barWidth / 2 + max(barHeight, barWidth * p) - barHeight / 2
    }
    
    /// Little paint bucket: tapered body + handle, in the ink-outline style.
    private func makeBucket(size s: CGFloat) -> SKNode {
        let n = SKNode()
        let body = CGMutablePath()
        body.move(to: CGPoint(x: -s * 0.45, y: s * 0.35))
        body.addLine(to: CGPoint(x: s * 0.45, y: s * 0.35))
        body.addLine(to: CGPoint(x: s * 0.34, y: -s * 0.45))
        body.addLine(to: CGPoint(x: -s * 0.34, y: -s * 0.45))
        body.closeSubpath()
        let shape = SKShapeNode(path: body)
        shape.fillColor = .sunshineYellow; shape.strokeColor = .darkNavy; shape.lineWidth = 2.5; shape.lineJoin = .round
        n.addChild(shape)
        let rim = SKShapeNode(ellipseOf: CGSize(width: s * 0.95, height: s * 0.28))
        rim.fillColor = .coralRed; rim.strokeColor = .darkNavy; rim.lineWidth = 2.5
        rim.position = CGPoint(x: 0, y: s * 0.35)
        n.addChild(rim)
        let handle = CGMutablePath()
        handle.addArc(center: CGPoint(x: 0, y: s * 0.35), radius: s * 0.42, startAngle: 0.15, endAngle: .pi - 0.15, clockwise: false)
        let h = SKShapeNode(path: handle)
        h.strokeColor = .darkNavy; h.lineWidth = 2.5; h.lineCap = .round
        n.addChild(h)
        return n
    }
}
