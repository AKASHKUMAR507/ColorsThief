import SpriteKit

/// One fillable area of a friend: white with a dotted navy outline until the player
/// taps it, then a radial fill of the active colour (0.4 s) and a solid outline.
class ColorableRegion: SKNode {
    
    let region: FriendRegion
    private(set) var isRestored = false
    private(set) var fillColor: UIColor?
    
    private let fill: SKShapeNode
    private let dotted: SKShapeNode
    private let solid: SKShapeNode
    private let path: CGPath
    
    init(region: FriendRegion) {
        self.region = region
        self.path = region.path
        
        fill = SKShapeNode(path: region.path)
        fill.fillColor   = .white
        fill.strokeColor = .clear
        
        dotted = SKShapeNode(path: region.path.copy(dashingWithPhase: 0, lengths: [7, 8]))
        dotted.strokeColor = .darkNavy
        dotted.lineWidth   = 3.5
        dotted.lineCap     = .round
        dotted.fillColor   = .clear
        dotted.zPosition   = 2
        
        solid = SKShapeNode(path: region.path)
        solid.strokeColor = .darkNavy
        solid.lineWidth   = 4
        solid.lineJoin    = .round
        solid.fillColor   = .clear
        solid.zPosition   = 2
        solid.alpha       = 0
        
        super.init()
        name = region.name
        addChild(fill)
        addChild(dotted)
        addChild(solid)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("not used") }
    
    /// - Parameter point: tap location in this node's coordinates (radial fill origin).
    func restore(with color: UIColor, at point: CGPoint) {
        guard !isRestored else { return }
        isRestored = true
        fillColor  = color
        
        // Radial fill clipped to the region
        let mask = SKShapeNode(path: path)
        mask.fillColor = .white
        let crop = SKCropNode()
        crop.maskNode  = mask
        crop.zPosition = 1
        let bounds = path.boundingBox
        let reach  = hypot(bounds.width, bounds.height)
        let blob = SKShapeNode(circleOfRadius: reach)
        blob.fillColor   = color
        blob.strokeColor = .clear
        blob.position    = point
        blob.setScale(0.02)
        crop.addChild(blob)
        addChild(crop)
        
        let grow = SKAction.scale(to: 1.0, duration: 0.4)
        grow.timingMode = .easeOut
        blob.run(SKAction.sequence([grow, SKAction.run { [weak self] in
            self?.fill.fillColor = color
            crop.removeFromParent()
        }]))
        
        dotted.run(SKAction.fadeOut(withDuration: 0.2))
        solid.run(SKAction.sequence([SKAction.wait(forDuration: 0.15), SKAction.fadeIn(withDuration: 0.2)]))
        
        // Squish → spring → settle
        let squish = SKAction.scale(to: 0.94, duration: 0.08)
        let spring = SKAction.scale(to: 1.04, duration: 0.12)
        let settle = SKAction.scale(to: 1.00, duration: 0.08)
        run(SKAction.sequence([squish, spring, settle]))
    }
    
    /// Undo: back to white + dotted.
    func reset() {
        guard isRestored else { return }
        isRestored = false
        fillColor  = nil
        removeAllActions()
        children.filter { $0 is SKCropNode }.forEach { $0.removeFromParent() }
        fill.fillColor = .white
        solid.removeAllActions(); solid.alpha = 0
        dotted.removeAllActions(); dotted.alpha = 1
        run(SKAction.sequence([SKAction.scale(to: 0.94, duration: 0.08), SKAction.scale(to: 1.0, duration: 0.1)]))
    }
    
    /// Hint: pulse the dotted outline.
    func pulse() {
        guard !isRestored else { return }
        let up = SKAction.scale(to: 1.06, duration: 0.15)
        let down = SKAction.scale(to: 1.0, duration: 0.15)
        run(SKAction.sequence([up, down, up, down]))
    }
}
