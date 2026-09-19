import SpriteKit

class HomeScene: SKScene {
    
    private var musicButton: ChunkyButton?
    
    override func didMove(to view: SKView) {
        backgroundColor = .warmCream
        SoundManager.shared.startMusic()
        
        let safeTop    = view.safeAreaInsets.top
        let safeBottom = view.safeAreaInsets.bottom
        let W = frame.width, H = frame.height
        
        setupBackground()
        
        // --- Vertical layout, bottom-up for the buttons, top-down for the header ---
        let smallPillH: CGFloat = 52
        let playH: CGFloat      = 72
        let statsH: CGFloat     = 52
        
        let smallPillY = safeBottom + 12 + smallPillH / 2
        let playY      = smallPillY + smallPillH / 2 + 22 + playH / 2
        let statsY     = playY + playH / 2 + 36 + statsH / 2
        
        let titleY   = H - safeTop - 40
        let taglineY = titleY - 50
        
        setupTitle(y: titleY, taglineY: taglineY)
        setupPreviewCard(top: taglineY - 36, bottom: statsY + statsH / 2 + 30, width: W - 48)
        setupStatsPill(y: statsY, size: CGSize(width: W - 32, height: statsH))
        setupPlayButton(y: playY, size: CGSize(width: W - 48, height: playH))
        setupSecondaryButtons(y: smallPillY, height: smallPillH, gap: 14)
    }
    
    // MARK: - Pieces
    
    private func setupBackground() {
        let bg = SKSpriteNode(texture: .verticalGradient(size: size,
                                                         top: UIColor(hex: "#FFE066"),
                                                         bottom: .warmCream),
                              size: size)
        bg.position  = CGPoint(x: frame.midX, y: frame.midY)
        bg.zPosition = -10
        addChild(bg)
    }
    
    private func setupTitle(y: CGFloat, taglineY: CGFloat) {
        let title = LabelFactory.title("Color Thief", size: AppFonts.Size.xl)
        title.position  = CGPoint(x: frame.midX, y: y)
        title.zPosition = 10
        addChild(title)
        
        // Twinkles either side of the logo
        let titleWidth = title.calculateAccumulatedFrame().width
        let twinkles: [(CGFloat, CGFloat, UIColor)] = [(-titleWidth / 2 - 28, 18, .white),
                                                     (titleWidth / 2 + 28, -6, .coralRed)]
        for (dx, dy, color) in twinkles {
            let star = LabelFactory.body("✦", font: AppFonts.headline, size: 22, color: color)
            star.position  = CGPoint(x: frame.midX + dx, y: y + dy)
            star.zPosition = 10
            addChild(star)
            let twinkle = SKAction.sequence([
                SKAction.scale(to: 1.3, duration: 0.6),
                SKAction.scale(to: 0.8, duration: 0.6)
            ])
            twinkle.timingMode = .easeInEaseOut
            star.run(SKAction.repeatForever(twinkle))
        }
        
        let tagline = LabelFactory.body("Bring the world back to life!", size: AppFonts.Size.label)
        tagline.position  = CGPoint(x: frame.midX, y: taglineY)
        tagline.zPosition = 10
        addChild(tagline)
    }
    
    private func setupPreviewCard(top: CGFloat, bottom: CGFloat, width: CGFloat) {
        let available = top - bottom
        let height = min(available, width * 0.9)
        let card = StickerCard(size: CGSize(width: width, height: height), cornerRadius: 36)
        card.position  = CGPoint(x: frame.midX, y: (top + bottom) / 2)
        card.zPosition = 5
        addChild(card)
        
        let art = LandscapeArt.make(size: CGSize(width: width, height: height))
        card.content.addChild(art)
    }
    
    private func setupStatsPill(y: CGFloat, size: CGSize) {
        let pill = ChunkyButton(size: size, style: .white)
        pill.isUserInteractionEnabled = false
        pill.position  = CGPoint(x: frame.midX, y: y)
        pill.zPosition = 5
        addChild(pill)
        
        let items: [(String, Int, String)] = [
            ("🎨", PlayerStats.colorsRestored, "Colors"),
            ("⭐", PlayerStats.starsEarned,    "Stars"),
            ("🌍", PlayerStats.worldsUnlocked, "Worlds")
        ]
        let slot = size.width / CGFloat(items.count)
        for (i, item) in items.enumerated() {
            let label = LabelFactory.body("\(item.0) \(item.1) \(item.2)", size: 15)
            label.position = CGPoint(x: -size.width / 2 + slot * (CGFloat(i) + 0.5), y: 0)
            label.zPosition = 2
            pill.addChild(label)
            if i < items.count - 1 {
                let dot = LabelFactory.body("★", font: AppFonts.headline, size: 12, color: .sunshineYellow)
                dot.position = CGPoint(x: -size.width / 2 + slot * CGFloat(i + 1), y: 0)
                dot.zPosition = 2
                pill.addChild(dot)
            }
        }
    }
    
    private func setupPlayButton(y: CGFloat, size: CGSize) {
        // White disc with a green play triangle
        let icon = SKNode()
        let disc = SKShapeNode(circleOfRadius: 17)
        disc.fillColor = .white; disc.strokeColor = .darkNavy; disc.lineWidth = 3
        icon.addChild(disc)
        let tri = CGMutablePath()
        tri.move(to: CGPoint(x: -5, y: -8))
        tri.addLine(to: CGPoint(x: 9, y: 0))
        tri.addLine(to: CGPoint(x: -5, y: 8))
        tri.closeSubpath()
        let play = SKShapeNode(path: tri)
        play.fillColor = .grassGreen; play.strokeColor = .clear; play.lineJoin = .round
        icon.addChild(play)
        
        let button = ChunkyButton(size: size, style: .primary, title: "TAP TO PLAY!",
                                  fontSize: AppFonts.Size.button + 2, icon: icon)
        button.position  = CGPoint(x: frame.midX, y: y)
        button.zPosition = 5
        button.onTap = { [weak self] in self?.startGame() }
        addChild(button)
        button.startIdleBounce()
    }
    
    private func setupSecondaryButtons(y: CGFloat, height: CGFloat, gap: CGFloat) {
        let width = (frame.width - 48 - gap) / 2
        let size  = CGSize(width: width, height: height)
        
        let parents = ChunkyButton(size: size, style: .white, title: "👨‍👩‍👧 For Parents",
                                   fontSize: 15, fontName: AppFonts.body)
        parents.position  = CGPoint(x: frame.midX - width / 2 - gap / 2, y: y)
        parents.zPosition = 5
        parents.onTap = { [weak self] in ParentFlow.present(from: self?.view) }
        addChild(parents)
        
        let music = ChunkyButton(size: size, style: .white, title: musicTitle(),
                                 fontSize: 15, fontName: AppFonts.body)
        music.position  = CGPoint(x: frame.midX + width / 2 + gap / 2, y: y)
        music.zPosition = 5
        music.onTap = { [weak self] in
            PlayerStats.musicEnabled.toggle()
            self?.musicButton?.setTitle(self?.musicTitle() ?? "")
        }
        addChild(music)
        musicButton = music
    }
    
    private func musicTitle() -> String {
        PlayerStats.musicEnabled ? "🎵 Music ON" : "🔇 Music OFF"
    }
    
    // MARK: - Navigation
    
    private func startGame() {
        let select = LevelSelectScene(size: self.size)
        select.scaleMode = .aspectFill
        view?.presentScene(select, transition: .fade(withDuration: 0.4))
    }
}
