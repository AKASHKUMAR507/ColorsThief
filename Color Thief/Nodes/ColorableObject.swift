import SpriteKit

class ColorableObject: SKSpriteNode {
    
    var isRestored = false
    var coloredTextureName: String
    
    init(greyTexture: String, coloredTexture: String, size: CGSize) {
        self.coloredTextureName = coloredTexture
        // Empty name = placeholder subclass draws itself; avoid SpriteKit's red "missing texture" X
        let texture: SKTexture? = greyTexture.isEmpty ? nil : SKTexture(imageNamed: greyTexture)
        super.init(texture: texture, color: .clear, size: size)
        self.isUserInteractionEnabled = false // GameScene handles touches
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not used")
    }
    
    /// Restore this object using the player's active colour.
    /// - Parameter point: tap location in this node's coordinates (radial fill origin).
    /// Texture-based objects swap to their coloured asset (two-asset approach per spec);
    /// `color` is used by subclasses that draw themselves.
    func restore(with color: UIColor, at point: CGPoint = .zero) {
        guard !isRestored else { return }
        isRestored = true
        
        let newTexture = SKTexture(imageNamed: coloredTextureName)
        
        // Squish → color → spring back
        let squish   = SKAction.scale(to: 0.85, duration: 0.08)
        let colorize = SKAction.setTexture(newTexture)
        let spring   = SKAction.scale(to: 1.10, duration: 0.12)
        let settle   = SKAction.scale(to: 1.00, duration: 0.08)
        
        run(SKAction.sequence([squish, colorize, spring, settle]))
    }
}
