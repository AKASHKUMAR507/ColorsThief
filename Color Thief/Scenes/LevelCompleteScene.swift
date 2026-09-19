import SpriteKit

/// Celebration. Stars are earned from time (spec: <30 s 3, <60 s 2, else 1) and
/// animate in one by one; "KEEP PLAYING!" → next level (or Level Select if locked).
class LevelCompleteScene: SKScene {
    
    private let level: Level
    private let elapsed: TimeInterval
    private let starsAwarded: Int
    private var soundButton: ChunkyButton?
    
    init(size: CGSize, level: Level, elapsed: TimeInterval) {
        self.level = level
        self.elapsed = elapsed
        self.starsAwarded = LevelProgressStore.stars(forTime: elapsed)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("not used") }
    
    override func didMove(to view: SKView) {
        LevelProgressStore.record(levelId: level.id, stars: starsAwarded, time: elapsed)
        
        let safeTop    = view.safeAreaInsets.top
        let safeBottom = view.safeAreaInsets.bottom
        let W = frame.width, H = frame.height
        
        setupSky()
        setupHills(height: H * 0.26)
        
        let topY = H - safeTop - 40
        setupTopHUD(y: topY)
        
        let bottomY = safeBottom + 12 + 28
        setupBottomHUD(y: bottomY)
        
        let cardH = min(H * 0.42, 380)
        let cardCenterY = (topY - 44 + bottomY + 40) / 2 + 10
        setupCard(center: CGPoint(x: frame.midX, y: cardCenterY), size: CGSize(width: W - 56, height: cardH))
        
        setupConfetti()
        HapticManager.success()
    }
    
    // MARK: - Backdrop
    
    private func setupSky() {
        let W = frame.width, H = frame.height
        let sky = SKSpriteNode(texture: .verticalGradient(size: size, top: .skyBlue, bottom: UIColor(hex: "#BDEBFF")),
                               size: size)
        sky.position  = CGPoint(x: frame.midX, y: frame.midY)
        sky.zPosition = -30
        addChild(sky)
        
        let rainbow = LandscapeArt.rainbow(radius: W * 0.62, bandWidth: 14)
        rainbow.position  = CGPoint(x: frame.midX, y: H * 0.42)
        rainbow.alpha     = 0.9
        rainbow.zPosition = -20
        addChild(rainbow)
        
        // Sun peeking in, top-right
        let sun = SKNode()
        sun.position  = CGPoint(x: W + 4, y: H - 14)
        sun.zPosition = -18
        let body = SKShapeNode(circleOfRadius: 44)
        body.fillColor = .sunshineYellow; body.strokeColor = .darkNavy; body.lineWidth = 3
        sun.addChild(body)
        for i in 0..<10 {
            let a = CGFloat(i) / 10 * .pi * 2
            let ray = SKShapeNode(rectOf: CGSize(width: 5, height: 22), cornerRadius: 2.5)
            ray.fillColor = .sunshineYellow; ray.strokeColor = .clear
            ray.position = CGPoint(x: cos(a) * 62, y: sin(a) * 62)
            ray.zRotation = a - .pi / 2
            sun.addChild(ray)
        }
        sun.addChild(KawaiiFace.make(scale: 44, blush: true))
        addChild(sun)
        
        // Clouds
        for (pos, s) in [(CGPoint(x: W * 0.18, y: H * 0.79), 14.0), (CGPoint(x: W * 0.84, y: H * 0.74), 11.0)] {
            let c = LandscapeArt.cloud(at: pos, scale: CGFloat(s), fill: .white, ink: .darkNavy, line: 3)
            c.zPosition = -15
            addChild(c)
            let drift = SKAction.sequence([SKAction.moveBy(x: 8, y: 0, duration: 3), SKAction.moveBy(x: -8, y: 0, duration: 3)])
            drift.timingMode = .easeInEaseOut
            c.run(SKAction.repeatForever(drift))
        }
    }
    
    private func setupHills(height h: CGFloat) {
        let W = frame.width
        // hill() draws in centred coords spanning ±w; shift so the base sits at the bottom edge
        let back = LandscapeArt.hill(width: W, height: h, baseY: 0, bump: h * 0.35,
                                     fill: UIColor(hex: "#5FE07A"), stroke: .darkNavy, line: 3, zPos: 0)
        back.position  = CGPoint(x: frame.midX, y: h * 0.55)
        back.zPosition = -10
        addChild(back)
        let front = LandscapeArt.hill(width: W, height: h, baseY: 0, bump: h * 0.25,
                                      fill: .grassGreen, stroke: .darkNavy, line: 3, zPos: 0)
        front.position  = CGPoint(x: frame.midX + W * 0.4, y: h * 0.32)
        front.zPosition = -9
        addChild(front)
        
        // Flowers
        for (x, c) in [(W * 0.10, UIColor.hotPink), (W * 0.90, UIColor.coralRed), (W * 0.30, UIColor.lavender)] {
            let f = SKNode()
            f.position  = CGPoint(x: x, y: h * 0.42)
            f.zPosition = -8
            let stem = SKShapeNode(rectOf: CGSize(width: 3, height: 18))
            stem.fillColor = .darkNavy; stem.strokeColor = .clear
            f.addChild(stem)
            let head = SKShapeNode(circleOfRadius: 8)
            head.fillColor = c; head.strokeColor = .darkNavy; head.lineWidth = 2
            head.position = CGPoint(x: 0, y: 12)
            f.addChild(head)
            addChild(f)
        }
    }
    
    // MARK: - HUD
    
    private func setupTopHUD(y: CGFloat) {
        let W = frame.width
        let circle = ChunkyButton.Style(fill: .white, lip: .darkNavy, lipHeight: 5, lineWidth: 3)
        
        let home = ChunkyButton(size: CGSize(width: 56, height: 56), style: circle,
                                icon: SKSpriteNode.symbol("house.fill", pointSize: 22, color: .darkNavy))
        home.position  = CGPoint(x: 16 + 28, y: y)
        home.zPosition = 20
        home.onTap = { [weak self] in self?.go(HomeScene(size: self!.size)) }
        addChild(home)
        
        let levelPill = ChunkyButton(size: CGSize(width: 150, height: 46), style: .white,
                                     title: "LEVEL \(level.id)", fontSize: 18,
                                     icon: dot(.grassGreen), iconGap: 8)
        levelPill.isUserInteractionEnabled = false
        levelPill.position  = CGPoint(x: frame.midX, y: y)
        levelPill.zPosition = 20
        addChild(levelPill)
        
        let sound = ChunkyButton(size: CGSize(width: 56, height: 56), style: circle, icon: soundIcon())
        sound.position  = CGPoint(x: W - 16 - 28, y: y)
        sound.zPosition = 20
        sound.onTap = { [weak self] in
            guard let self else { return }
            PlayerStats.musicEnabled.toggle()
            self.soundButton?.setIcon(self.soundIcon())
        }
        addChild(sound)
        soundButton = sound
    }
    
    private func setupBottomHUD(y: CGFloat) {
        let W = frame.width
        let circle = ChunkyButton.Style(fill: .white, lip: .darkNavy, lipHeight: 5, lineWidth: 3)
        
        let replay = ChunkyButton(size: CGSize(width: 56, height: 56), style: circle,
                                  icon: SKSpriteNode.symbol("arrow.counterclockwise", pointSize: 22, color: .darkNavy))
        replay.position  = CGPoint(x: W * 0.28, y: y)
        replay.zPosition = 20
        replay.onTap = { [weak self] in
            guard let self else { return }
            self.go(GameScene(size: self.size, level: self.level))
        }
        addChild(replay)
        
        // Level dots: one per level, filled for completed ones
        let levels = LevelData.all
        let dotsW = CGFloat(levels.count) * 22 + 28
        let dots = ChunkyButton(size: CGSize(width: dotsW, height: 46), style: .white)
        dots.isUserInteractionEnabled = false
        dots.position  = CGPoint(x: W * 0.62, y: y)
        dots.zPosition = 20
        addChild(dots)
        for (i, l) in levels.enumerated() {
            let done = LevelProgressStore.isCompleted(l.id)
            let d = SKShapeNode(circleOfRadius: 7)
            d.fillColor   = done ? .sunshineYellow : UIColor(hex: "#E4E0D6")
            d.strokeColor = done ? .darkNavy : .clear
            d.lineWidth   = 2
            d.position    = CGPoint(x: (CGFloat(i) - CGFloat(levels.count - 1) / 2) * 22, y: 0)
            d.zPosition   = 2
            dots.content.addChild(d)
        }
    }
    
    // MARK: - Card
    
    private func setupCard(center: CGPoint, size: CGSize) {
        let card = StickerCard(size: size, cornerRadius: 40, shadowOffset: 8)
        card.position  = center
        card.zPosition = 10
        card.setScale(0.6)
        card.alpha = 0
        addChild(card)
        card.run(SKAction.group([
            SKAction.fadeIn(withDuration: 0.25),
            SKAction.sequence([SKAction.scale(to: 1.06, duration: 0.25), SKAction.scale(to: 1.0, duration: 0.12)])
        ]))
        
        // Mascot peeking over the top edge
        let mascot = LandscapeArt.mascot(height: 440, cheering: true)
        mascot.position  = CGPoint(x: center.x, y: center.y + size.height / 2 + 26)
        mascot.zPosition = 12
        mascot.setScale(0)
        addChild(mascot)
        mascot.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.15),
            SKAction.scale(to: 1.15, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
        let bob = SKAction.sequence([SKAction.moveBy(x: 0, y: 5, duration: 0.8), SKAction.moveBy(x: 0, y: -5, duration: 0.8)])
        bob.timingMode = .easeInEaseOut
        mascot.run(SKAction.repeatForever(bob))
        
        let h = size.height
        
        // "YOU DID IT!"
        let title = LabelFactory.title("YOU DID IT!", size: 36, fill: .sunshineYellow, shadowOffset: 4)
        title.position = CGPoint(x: 0, y: h / 2 - 78)
        title.setScale(0)
        card.content.addChild(title)
        title.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.scale(to: 1.2, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
        
        // "● World Restored! 100%"
        let pill = ChunkyButton(size: CGSize(width: 232, height: 40),
                                style: ChunkyButton.Style(fill: UIColor(hex: "#EFECFF"), lip: .darkNavy, text: .darkNavy, lipHeight: 3, lineWidth: 2.5),
                                title: "World Restored! 100%", fontSize: 16, fontName: AppFonts.body,
                                icon: dot(.grassGreen), iconGap: 8)
        pill.isUserInteractionEnabled = false
        pill.position = CGPoint(x: 0, y: h / 2 - 130)
        pill.alpha = 0
        card.content.addChild(pill)
        pill.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.fadeIn(withDuration: 0.25)]))
        
        // Stars — one by one, 0.3 s apart (spec)
        let starY = h / 2 - 210
        let sizes: [CGFloat] = [50, 66, 50]
        for i in 0..<3 {
            let earned = i < starsAwarded
            let x = (CGFloat(i) - 1) * 84
            let y = starY + (i == 1 ? 8 : 0)
            let star = SKNode()
            star.position = CGPoint(x: x, y: y)
            star.setScale(0)
            let outline = SKSpriteNode.symbol("star.fill", pointSize: sizes[i] + 6, color: .darkNavy)
            let fill = SKSpriteNode.symbol("star.fill", pointSize: sizes[i],
                                           color: earned ? .sunshineYellow : UIColor(hex: "#E4E0D6"))
            fill.zPosition = 1
            star.addChild(outline)
            star.addChild(fill)
            if earned {
                let shine = SKSpriteNode.symbol("star.fill", pointSize: sizes[i] * 0.45, color: UIColor.white.withAlphaComponent(0.6))
                shine.position = CGPoint(x: -sizes[i] * 0.1, y: sizes[i] * 0.12)
                shine.zPosition = 2
                star.addChild(shine)
            }
            card.content.addChild(star)
            
            let delay = 0.7 + Double(i) * 0.3
            star.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.scale(to: 1.35, duration: 0.15),
                SKAction.scale(to: 1.0, duration: 0.1),
                SKAction.run { [weak self] in
                    if earned { self?.starSparkle(at: card.convert(star.position, from: card.content)) }
                }
            ]))
        }
        
        // KEEP PLAYING! ▶
        let button = ChunkyButton(size: CGSize(width: size.width - 56, height: 66), style: .yellow,
                                  title: "KEEP PLAYING!", fontSize: AppFonts.Size.button,
                                  icon: SKSpriteNode.symbol("play.fill", pointSize: 18, color: .darkNavy),
                                  iconGap: 14, iconTrailing: true)
        button.position = CGPoint(x: 0, y: -h / 2 + 58)
        button.setScale(0)
        button.onTap = { [weak self] in self?.keepPlaying() }
        card.content.addChild(button)
        button.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.7),
            SKAction.scale(to: 1.08, duration: 0.15),
            SKAction.scale(to: 1.0, duration: 0.1),
            SKAction.run { button.startIdleBounce(amplitude: 5) }
        ]))
    }
    
    private func starSparkle(at point: CGPoint) {
        let burst = TapSparkle.burst(color: .sunshineYellow)
        burst.position  = point
        burst.zPosition = 15
        addChild(burst)
        HapticManager.tap()
        SoundManager.shared.playTap()
    }
    
    // MARK: - Confetti (full screen)
    
    private func setupConfetti() {
        for e in Confetti.rain(width: frame.width) {
            e.position  = CGPoint(x: frame.midX, y: frame.height + 20)
            e.zPosition = 30
            addChild(e)
        }
    }
    
    // MARK: - Helpers
    
    private func dot(_ color: UIColor) -> SKNode {
        let d = SKShapeNode(circleOfRadius: 6)
        d.fillColor = color; d.strokeColor = .darkNavy; d.lineWidth = 2
        return d
    }
    
    private func soundIcon() -> SKNode {
        SKSpriteNode.symbol(PlayerStats.musicEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill",
                            pointSize: 20, color: .darkNavy)
    }
    
    // MARK: - Navigation
    
    /// Spec: "KEEP PLAYING!" → next level. If the next level needs the full game,
    /// show the paywall (spec: after Level 3); no next level → Level Select.
    private func keepPlaying() {
        guard let nextLevel = LevelData.level(after: level) else {
            go(LevelSelectScene(size: size))
            return
        }
        if nextLevel.isUnlocked {
            go(GameScene(size: size, level: nextLevel))
        } else {
            Paywall.present(from: view) { [weak self] in
                guard let self, let unlocked = LevelData.level(id: nextLevel.id), unlocked.isUnlocked else { return }
                self.go(GameScene(size: self.size, level: unlocked))
            }
        }
    }
    
    private func go(_ scene: SKScene) {
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: .fade(withDuration: 0.5))
    }
}
