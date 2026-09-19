import SpriteKit

/// Die-cut sticker card: rounded rect, navy outline, solid offset shadow.
/// Add children to `content` — it's clipped to the card's rounded shape.
class StickerCard: SKNode {
    
    let cardSize: CGSize
    let content = SKNode()
    
    init(size: CGSize,
         cornerRadius: CGFloat = 32,
         fill: UIColor = .white,
         stroke: UIColor = .darkNavy,
         lineWidth: CGFloat = 4,
         shadowOffset: CGFloat = 8) {
        self.cardSize = size
        super.init()
        
        let rect = CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height)
        
        let shadow = SKShapeNode(rect: rect.offsetBy(dx: 0, dy: -shadowOffset), cornerRadius: cornerRadius)
        shadow.fillColor   = stroke
        shadow.strokeColor = stroke
        shadow.lineWidth   = lineWidth
        shadow.zPosition   = 0
        addChild(shadow)
        
        let background = SKShapeNode(rect: rect, cornerRadius: cornerRadius)
        background.fillColor   = fill
        background.strokeColor = .clear
        background.zPosition   = 1
        addChild(background)
        
        // Clip content to the rounded shape
        let mask = SKShapeNode(rect: rect, cornerRadius: cornerRadius)
        mask.fillColor   = .white
        mask.strokeColor = .clear
        let crop = SKCropNode()
        crop.maskNode = mask
        crop.zPosition = 2
        crop.addChild(content)
        addChild(crop)
        
        // Outline drawn on top so content never covers it
        let outline = SKShapeNode(rect: rect, cornerRadius: cornerRadius)
        outline.fillColor   = .clear
        outline.strokeColor = stroke
        outline.lineWidth   = lineWidth
        outline.zPosition   = 3
        addChild(outline)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("not used") }
}
