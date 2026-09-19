import SpriteKit

/// Tappable colour selector: glossy sphere with a navy outline. The active orb
/// grows and shows a paintbrush badge. Handles its own touches — set `onTap`.
class ColorOrb: SKNode {
    
    let color: UIColor
    var onTap: ((ColorOrb) -> Void)?
    
    var isActive = false {
        didSet { updateActiveState(animated: true) }
    }
    
    private let radius: CGFloat
    private let badge = SKNode()
    
    init(color: UIColor, radius: CGFloat = 28) {
        self.color  = color
        self.radius = radius
        super.init()
        
        let shadow = SKShapeNode(circleOfRadius: radius)
        shadow.fillColor   = color.darkened()
        shadow.strokeColor = .darkNavy
        shadow.lineWidth   = 4
        shadow.position    = CGPoint(x: 0, y: -4)
        addChild(shadow)
        
        let body = SKShapeNode(circleOfRadius: radius)
        body.fillColor   = color
        body.strokeColor = .darkNavy
        body.lineWidth   = 4
        body.zPosition   = 1
        addChild(body)
        
        let gloss = SKShapeNode(ellipseOf: CGSize(width: radius * 0.8, height: radius * 0.5))
        gloss.fillColor   = UIColor.white.withAlphaComponent(0.55)
        gloss.strokeColor = .clear
        gloss.position    = CGPoint(x: -radius * 0.28, y: radius * 0.42)
        gloss.zRotation   = 0.5
        gloss.zPosition   = 2
        addChild(gloss)
        
        // Brush badge (active only)
        let disc = SKShapeNode(circleOfRadius: radius * 0.42)
        disc.fillColor   = .darkNavy
        disc.strokeColor = .white
        disc.lineWidth   = 2.5
        badge.addChild(disc)
        let brush = SKSpriteNode.symbol("paintbrush.pointed.fill", pointSize: radius * 0.42, color: .white)
        brush.zPosition = 1
        badge.addChild(brush)
        badge.position  = CGPoint(x: radius * 0.68, y: -radius * 0.68)
        badge.zPosition = 3
        badge.setScale(0)
        addChild(badge)
        
        // Hit area a little larger than the orb
        let hit = SKSpriteNode(color: .clear, size: CGSize(width: radius * 2.6, height: radius * 2.6))
        hit.zPosition = 4
        addChild(hit)
        
        isUserInteractionEnabled = true
        updateActiveState(animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("not used") }
    
    private func updateActiveState(animated: Bool) {
        let scale: CGFloat = isActive ? 1.18 : 1.0
        let badgeScale: CGFloat = isActive ? 1 : 0
        if animated {
            run(SKAction.scale(to: scale, duration: 0.15), withKey: "active")
            badge.run(SKAction.scale(to: badgeScale, duration: 0.15))
        } else {
            setScale(scale)
            badge.setScale(badgeScale)
        }
    }
    
    // MARK: - Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeAction(forKey: "active")
        run(SKAction.scale(to: 0.85, duration: 0.06), withKey: "press")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        HapticManager.tap()
        SoundManager.shared.playTap()
        onTap?(self)
        // onTap flips isActive, which animates to the final scale
        if !isActive { updateActiveState(animated: true) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateActiveState(animated: true)
    }
}
