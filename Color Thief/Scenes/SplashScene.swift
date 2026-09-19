import SpriteKit

/// Spec: 2.5 s auto-dismiss, no input.
/// Grey world fades in → paint drop falls → colour spreads from the impact → logo reveals → HomeScene.
class SplashScene: SKScene {
    
    private let totalDuration: TimeInterval = 2.5
    
    // Timeline (seconds from scene start)
    private let tWorldFadeIn: TimeInterval = 0.0   // 0.4 s
    private let tDropStart:   TimeInterval = 0.35  // 0.5 s fall
    private let tReveal:      TimeInterval = 0.85  // 0.7 s spread
    private let tLogo:        TimeInterval = 1.25  // pops in
    
    override func didMove(to view: SKView) {
        backgroundColor = .warmCream
        
        let W = frame.width, H = frame.height
        let panelHeight = H * 0.36
        let worldSize   = CGSize(width: W, height: H - panelHeight)
        let worldCenter = CGPoint(x: frame.midX, y: panelHeight + worldSize.height / 2)
        
        // --- Grey world (fades in) ---
        var greyOpts = LandscapeArt.Options()
        greyOpts.palette = .grey
        greyOpts.mascotPainting = true
        let greyWorld = LandscapeArt.make(size: worldSize, options: greyOpts)
        greyWorld.position  = worldCenter
        greyWorld.zPosition = 0
        greyWorld.alpha     = 0
        addChild(greyWorld)
        
        // --- Colour world, revealed through a growing circle ---
        var colorOpts = LandscapeArt.Options()
        colorOpts.palette = .color
        colorOpts.showRainbow = true
        colorOpts.mascotPainting = true
        let colorWorld = LandscapeArt.make(size: worldSize, options: colorOpts)
        colorWorld.position = worldCenter
        
        // Impact point = the mascot's brush tip
        let impact = CGPoint(x: worldCenter.x + worldSize.height * 0.12,
                             y: worldCenter.y - worldSize.height * 0.02)
        
        let maskRadius: CGFloat = 10
        let mask = SKShapeNode(circleOfRadius: maskRadius)
        mask.fillColor   = .white
        mask.strokeColor = .clear
        mask.position    = impact
        mask.setScale(0.001)
        
        let reveal = SKCropNode()
        reveal.maskNode  = mask
        reveal.zPosition = 20   // well above every grey-world child (they go up to z 6)
        reveal.addChild(colorWorld)
        addChild(reveal)
        
        // --- Cream panel with the logo ---
        let panel = SKShapeNode(rect: CGRect(x: -W / 2, y: -panelHeight - 60, width: W, height: panelHeight + 60),
                                cornerRadius: 40)
        panel.fillColor   = .warmCream
        panel.strokeColor = .darkNavy
        panel.lineWidth   = 4
        panel.position    = CGPoint(x: frame.midX, y: panelHeight + 8)
        panel.zPosition   = 40
        addChild(panel)
        
        let logo = SKNode()
        logo.position  = CGPoint(x: frame.midX, y: panelHeight * 0.56)
        logo.zPosition = 41
        logo.setScale(0)
        let line1 = LabelFactory.title("Color", size: AppFonts.Size.xl)
        line1.position = CGPoint(x: 0, y: 30)
        let line2 = LabelFactory.title("Thief", size: AppFonts.Size.xl)
        line2.position = CGPoint(x: 0, y: -30)
        logo.addChild(line1)
        logo.addChild(line2)
        addChild(logo)
        
        let twinkles: [(CGFloat, CGFloat, UIColor)] = [(-120, 60, .sunshineYellow), (110, -50, .coralRed), (95, 70, .skyBlue)]
        for (dx, dy, color) in twinkles {
            let star = LabelFactory.body("✦", font: AppFonts.headline, size: 22, color: color)
            star.position  = CGPoint(x: logo.position.x + dx, y: logo.position.y + dy)
            star.zPosition = 41
            star.alpha     = 0
            addChild(star)
            let twinkle = SKAction.sequence([
                SKAction.scale(to: 1.3, duration: 0.5),
                SKAction.scale(to: 0.8, duration: 0.5)
            ])
            twinkle.timingMode = .easeInEaseOut
            star.run(SKAction.sequence([
                SKAction.wait(forDuration: tLogo + 0.2),
                SKAction.fadeIn(withDuration: 0.2),
                SKAction.repeatForever(twinkle)
            ]))
        }
        
        // --- Paint drop ---
        let drop = SKShapeNode(circleOfRadius: 16)
        drop.fillColor   = .sunshineYellow
        drop.strokeColor = .darkNavy
        drop.lineWidth   = 3
        drop.position    = CGPoint(x: impact.x, y: H + 40)
        drop.zPosition   = 30
        addChild(drop)
        
        // --- Timeline ---
        greyWorld.run(SKAction.sequence([
            SKAction.wait(forDuration: tWorldFadeIn),
            SKAction.fadeIn(withDuration: 0.4)
        ]))
        
        let fall = SKAction.moveTo(y: impact.y, duration: 0.5)
        fall.timingMode = .easeIn
        let splat = SKAction.sequence([
            SKAction.scaleX(to: 1.6, y: 0.5, duration: 0.06),
            SKAction.group([SKAction.scale(to: 0.1, duration: 0.25), SKAction.fadeOut(withDuration: 0.25)]),
            SKAction.removeFromParent()
        ])
        drop.run(SKAction.sequence([SKAction.wait(forDuration: tDropStart), fall, splat]))
        
        // Circle big enough to cover the whole world from the impact point
        let farCorner = max(hypot(impact.x, impact.y - panelHeight),
                            hypot(W - impact.x, H - impact.y),
                            hypot(impact.x, H - impact.y),
                            hypot(W - impact.x, impact.y - panelHeight))
        let grow = SKAction.scale(to: farCorner / maskRadius * 1.05, duration: 0.7)
        grow.timingMode = .easeOut
        mask.run(SKAction.sequence([SKAction.wait(forDuration: tReveal), grow]))
        
        let pop = SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.18),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        pop.timingMode = .easeOut
        logo.run(SKAction.sequence([SKAction.wait(forDuration: tLogo), pop]))
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: totalDuration),
            SKAction.run { [weak self] in self?.goToHome() }
        ]))
    }
    
    private func goToHome() {
        let home = HomeScene(size: self.size)
        home.scaleMode = .aspectFill
        view?.presentScene(home, transition: .fade(withDuration: 0.5))
    }
}
