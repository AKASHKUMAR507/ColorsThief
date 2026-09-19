import SpriteKit

/// Tactile toy push-button from the design system: pill/rounded face with a navy
/// outline and a solid darker "lip" underneath. Pressing drops the face onto the lip.
/// Handles its own touches — set `onTap`.
class ChunkyButton: SKNode {
    
    struct Style {
        var fill: UIColor
        var lip: UIColor
        var stroke: UIColor    = .darkNavy
        var text: UIColor      = .white
        var lipHeight: CGFloat = 6
        var lineWidth: CGFloat = 4
        var cornerRadius: CGFloat? = nil   // nil = full pill
        
        static let primary = Style(fill: .grassGreen, lip: UIColor(hex: "#2E9E45"))
        static let yellow  = Style(fill: .sunshineYellow, lip: UIColor(hex: "#D9A800"), text: .darkNavy)
        static let white   = Style(fill: .white, lip: .darkNavy, text: .darkNavy, lipHeight: 5, lineWidth: 3)
    }
    
    var onTap: (() -> Void)?
    let buttonSize: CGSize
    private let style: Style
    
    /// Everything that moves when pressed (face, label, icon). Add extra content here.
    let content = SKNode()
    private let label: SKLabelNode?
    private var iconNode: SKNode?
    
    init(size: CGSize,
         style: Style,
         title: String? = nil,
         fontSize: CGFloat = AppFonts.Size.button,
         fontName: String = AppFonts.headline,
         icon: SKNode? = nil,
         iconGap: CGFloat = 12,
         iconTrailing: Bool = false) {
        self.buttonSize = size
        self.style = style
        
        let radius = style.cornerRadius ?? size.height / 2
        let faceRect = CGRect(x: -size.width / 2, y: -size.height / 2,
                              width: size.width, height: size.height)
        
        // Lip (does not move)
        let lip = SKShapeNode(rect: faceRect.offsetBy(dx: 0, dy: -style.lipHeight), cornerRadius: radius)
        lip.fillColor   = style.lip
        lip.strokeColor = style.stroke
        lip.lineWidth   = style.lineWidth
        lip.zPosition   = 0
        
        // Face
        let face = SKShapeNode(rect: faceRect, cornerRadius: radius)
        face.fillColor   = style.fill
        face.strokeColor = style.stroke
        face.lineWidth   = style.lineWidth
        
        var lbl: SKLabelNode? = nil
        if let title {
            let l = SKLabelNode(text: title)
            l.fontName  = fontName
            l.fontSize  = fontSize
            l.fontColor = style.text
            l.horizontalAlignmentMode = .center
            l.verticalAlignmentMode   = .center
            l.zPosition = 2
            lbl = l
        }
        self.label = lbl
        
        super.init()
        
        addChild(lip)
        content.zPosition = 1
        content.addChild(face)
        
        // Lay out icon + label as one centred row (icon leading by default)
        let iconWidth = icon?.calculateAccumulatedFrame().width ?? 0
        let labelWidth = lbl?.frame.width ?? 0
        let rowWidth = iconWidth + labelWidth + (icon != nil && lbl != nil ? iconGap : 0)
        var cursor = -rowWidth / 2
        let placeIcon = {
            guard let icon else { return }
            icon.position = CGPoint(x: cursor + iconWidth / 2, y: 0)
            icon.zPosition = 2
            self.content.addChild(icon)
            cursor += iconWidth + iconGap
        }
        let placeLabel = {
            guard let lbl else { return }
            lbl.position = CGPoint(x: cursor + labelWidth / 2, y: 0)
            self.content.addChild(lbl)
            cursor += labelWidth + iconGap
        }
        if iconTrailing { placeLabel(); placeIcon() } else { placeIcon(); placeLabel() }
        iconNode = icon
        addChild(content)
        
        // Generous invisible hit area (covers stroke + lip)
        let hit = SKSpriteNode(color: .clear,
                               size: CGSize(width: size.width + 16, height: size.height + style.lipHeight + 16))
        hit.position = CGPoint(x: 0, y: -style.lipHeight / 2)
        hit.zPosition = 3
        addChild(hit)
        
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("not used") }
    
    // MARK: - Public
    
    func setTitle(_ text: String) {
        label?.text = text
    }
    
    /// Swap the icon in place (same position/z).
    func setIcon(_ icon: SKNode) {
        let pos = iconNode?.position ?? .zero
        iconNode?.removeFromParent()
        icon.position  = pos
        icon.zPosition = 2
        content.addChild(icon)
        iconNode = icon
    }
    
    /// Gentle float to draw a toddler's eye. 2 s full loop per the spec.
    func startIdleBounce(amplitude: CGFloat = 6) {
        let up   = SKAction.moveBy(x: 0, y: amplitude,  duration: 1.0)
        let down = SKAction.moveBy(x: 0, y: -amplitude, duration: 1.0)
        up.timingMode   = .easeInEaseOut
        down.timingMode = .easeInEaseOut
        run(SKAction.repeatForever(SKAction.sequence([up, down])), withKey: "idleBounce")
    }
    
    // MARK: - Press feedback
    
    /// For containers that route touches themselves (e.g. a scrolling grid).
    func setPressed(_ pressed: Bool) {
        pressed ? pressDown() : release()
    }
    
    /// Pop + fire `onTap`, as a real touch would.
    func performTap() {
        SoundManager.shared.playTap()
        let pop = SKAction.sequence([
            SKAction.scale(to: 1.06, duration: 0.08),
            SKAction.scale(to: 1.00, duration: 0.08)
        ])
        run(pop) { [weak self] in self?.onTap?() }
    }
    
    private func pressDown() {
        content.removeAllActions()
        let drop = SKAction.moveTo(y: -(style.lipHeight - 2), duration: 0.06)
        drop.timingMode = .easeOut
        content.run(drop)
    }
    
    private func release() {
        content.removeAllActions()
        let lift = SKAction.moveTo(y: 0, duration: 0.10)
        lift.timingMode = .easeOut
        content.run(lift)
    }
    
    private func contains(touch: UITouch) -> Bool {
        guard let parent else { return false }
        let p = touch.location(in: parent)
        let half = CGSize(width: buttonSize.width / 2 + 12, height: buttonSize.height / 2 + 12)
        return abs(p.x - position.x) <= half.width && abs(p.y - position.y) <= half.height
    }
    
    // MARK: - Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        pressDown()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        if contains(touch: t) { pressDown() } else { release() }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        release()
        guard let t = touches.first, contains(touch: t) else { return }
        SoundManager.shared.playTap()
        // Small pop, then fire
        let pop = SKAction.sequence([
            SKAction.scale(to: 1.06, duration: 0.08),
            SKAction.scale(to: 1.00, duration: 0.08)
        ])
        run(pop) { [weak self] in self?.onTap?() }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        release()
    }
}
