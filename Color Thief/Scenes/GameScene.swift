import SpriteKit

/// Core mechanic — colouring-book style. One "friend" per level made of dotted regions;
/// tap a region → it fills with the active colour + sparkles + haptic; progress bar fills;
/// ↩ undoes the last fill; all regions filled → LevelCompleteScene (✓ skips the short wait).
class GameScene: SKScene {
    
    // MARK: - Properties
    private let level: Level
    private let friend: Friend
    private var state: GameState
    private var regions: [ColorableRegion] = []
    private var history: [ColorableRegion] = []
    private var orbs: [ColorOrb] = []
    private var progressBar: ProgressBar!
    private var playCard: StickerCard!
    private var doneButton: ChunkyButton!
    private var isFinishing = false
    
    init(size: CGSize, level: Level) {
        self.level  = level
        self.friend = FriendArt.friend(for: level.imageName)
        self.state  = GameState(level: level)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("not used") }
    
    // MARK: - Setup
    override func didMove(to view: SKView) {
        backgroundColor = .darkNavy
        HapticManager.prepare()
        
        let safeTop    = view.safeAreaInsets.top
        let safeBottom = view.safeAreaInsets.bottom
        let W = frame.width, H = frame.height
        
        setupBackdrop()
        
        let hudH: CGFloat = 122
        let hudTop = H - safeTop - 10
        setupHUD(top: hudTop, size: CGSize(width: W - 28, height: hudH))
        
        let trayH: CGFloat = 128
        let trayTop = safeBottom + trayH
        setupTray(top: trayTop, safeBottom: safeBottom)
        
        let cardTop    = hudTop - hudH - 16
        let cardBottom = trayTop + 16
        setupPlayCard(top: cardTop, bottom: cardBottom, width: W - 28)
        setupFriend()
    }
    
    /// The "stolen" grey world, dimmed, behind everything.
    private func setupBackdrop() {
        var opts = LandscapeArt.Options()
        opts.palette = .grey
        let world = LandscapeArt.make(size: CGSize(width: size.width, height: size.height * 0.7), options: opts)
        world.position  = CGPoint(x: frame.midX, y: frame.height * 0.65)
        world.zPosition = -20
        addChild(world)
        
        let dim = SKSpriteNode(color: UIColor.darkNavy.withAlphaComponent(0.5), size: size)
        dim.position  = CGPoint(x: frame.midX, y: frame.midY)
        dim.zPosition = -10
        addChild(dim)
    }
    
    private func setupHUD(top: CGFloat, size: CGSize) {
        let hud = StickerCard(size: size, cornerRadius: 30, shadowOffset: 6)
        hud.position  = CGPoint(x: frame.midX, y: top - size.height / 2)
        hud.zPosition = 10
        addChild(hud)
        
        let rowY = size.height / 2 - 34
        let btnStyle = ChunkyButton.Style(fill: .white, lip: .darkNavy, lipHeight: 4, lineWidth: 3)
        
        // ✕ Close → Level Select
        let close = ChunkyButton(size: CGSize(width: 50, height: 50), style: btnStyle,
                                 icon: SKSpriteNode.symbol("xmark", pointSize: 20, color: .darkNavy))
        close.position = CGPoint(x: -size.width / 2 + 40, y: rowY)
        close.onTap = { [weak self] in self?.exitToLevelSelect() }
        hud.content.addChild(close)
        
        // ✓ Done (green)
        doneButton = ChunkyButton(size: CGSize(width: 50, height: 50),
                                  style: ChunkyButton.Style(fill: .grassGreen, lip: UIColor.grassGreen.darkened(), lipHeight: 4, lineWidth: 3),
                                  icon: SKSpriteNode.symbol("checkmark", pointSize: 20, color: .white))
        doneButton.position = CGPoint(x: size.width / 2 - 40, y: rowY)
        doneButton.onTap = { [weak self] in self?.doneTapped() }
        hud.content.addChild(doneButton)
        
        // ↩ Undo
        let undo = ChunkyButton(size: CGSize(width: 50, height: 50), style: btnStyle,
                                icon: SKSpriteNode.symbol("arrow.uturn.backward", pointSize: 18, color: .darkNavy))
        undo.position = CGPoint(x: size.width / 2 - 40 - 62, y: rowY)
        undo.onTap = { [weak self] in self?.undoTapped() }
        hud.content.addChild(undo)
        
        // Title block (centred between ✕ and ↩)
        let titleX = (-size.width / 2 + 65 + size.width / 2 - 40 - 62 - 25) / 2
        let title = LabelFactory.title("COLOR ME!", size: 24, fill: .sunshineYellow, shadowOffset: 3)
        title.position = CGPoint(x: titleX, y: rowY + 8)
        hud.content.addChild(title)
        let sub = LabelFactory.body("Tap to fill magic colors", size: 12, color: UIColor.darkNavy.withAlphaComponent(0.6))
        sub.position = CGPoint(x: titleX, y: rowY - 16)
        hud.content.addChild(sub)
        
        // Progress bar
        progressBar = ProgressBar(width: size.width - 48, height: 18)
        progressBar.position = CGPoint(x: 0, y: -size.height / 2 + 26)
        hud.content.addChild(progressBar)
    }
    
    private func setupPlayCard(top: CGFloat, bottom: CGFloat, width: CGFloat) {
        let h = top - bottom
        playCard = StickerCard(size: CGSize(width: width, height: h), cornerRadius: 36,
                               fill: .warmCream, shadowOffset: 8)
        playCard.position  = CGPoint(x: frame.midX, y: (top + bottom) / 2)
        playCard.zPosition = 5
        addChild(playCard)
        
        // Friend badge, top-left
        let badge = ChunkyButton(size: CGSize(width: 168, height: 36), style: .yellow,
                                 title: "✦ \(friend.name)", fontSize: 15)
        badge.isUserInteractionEnabled = false
        badge.position = CGPoint(x: -width / 2 + 18 + 84, y: h / 2 - 18 - 20)
        badge.zPosition = 5
        playCard.content.addChild(badge)
        
        // Hint pill, bottom-right
        let hint = ChunkyButton(size: CGSize(width: 156, height: 34), style: .white,
                                title: "Tap dotted areas", fontSize: 13, fontName: AppFonts.body,
                                icon: SKSpriteNode.symbol("hand.tap.fill", pointSize: 14, color: .coralRed), iconGap: 6)
        hint.isUserInteractionEnabled = false
        hint.position = CGPoint(x: width / 2 - 18 - 78, y: -h / 2 + 18 + 16)
        hint.zPosition = 5
        playCard.content.addChild(hint)
    }
    
    /// Builds the friend: fixed parts, fillable regions, faces and ink, scaled to fit the card.
    private func setupFriend() {
        let areaW = playCard.cardSize.width - 56
        let areaH = playCard.cardSize.height - 150
        let scale = min(areaW, areaH) / friend.box
        
        let root = SKNode()
        root.setScale(scale)
        root.position  = CGPoint(x: 0, y: -4)
        root.zPosition = 2
        playCard.content.addChild(root)
        
        for part in friend.parts {
            let n = SKShapeNode(path: part.path)
            n.fillColor   = part.fill
            n.strokeColor = part.stroke
            n.lineWidth   = part.lineWidth
            n.lineJoin    = .round
            // Regions sit at 10 (fill) … 12 (outline); fixed parts go above that band, or below it if z < 0
            n.zPosition   = part.z < 0 ? 5 + part.z : 20 + part.z
            root.addChild(n)
        }
        for region in friend.regions {
            let n = ColorableRegion(region: region)
            n.zPosition = 10 + region.z
            root.addChild(n)
            regions.append(n)
        }
        for face in friend.faces {
            let f = KawaiiFace.make(scale: face.radius, blush: face.blush)
            f.position  = face.center
            f.zPosition = 30
            root.addChild(f)
        }
        for ink in friend.inkLines {
            let l = SKShapeNode(path: ink.path)
            l.strokeColor = .darkNavy
            l.lineWidth   = ink.width
            l.lineCap     = .round
            l.lineJoin    = .round
            l.zPosition   = 30
            root.addChild(l)
        }
        for dot in friend.inkDots {
            let d = SKShapeNode(circleOfRadius: dot.radius)
            d.fillColor   = dot.color
            d.strokeColor = .clear
            d.position    = dot.center
            d.zPosition   = 30
            root.addChild(d)
        }
    }
    
    private func setupTray(top: CGFloat, safeBottom: CGFloat) {
        let W = frame.width
        let trayH = top + 60   // bleeds off the bottom edge
        let tray = StickerCard(size: CGSize(width: W + 12, height: trayH), cornerRadius: 34, shadowOffset: 0)
        tray.position  = CGPoint(x: frame.midX, y: top - trayH / 2)
        tray.zPosition = 10
        addChild(tray)
        
        let handle = SKShapeNode(rectOf: CGSize(width: 48, height: 6), cornerRadius: 3)
        handle.fillColor   = .skyGrey
        handle.strokeColor = .clear
        handle.position    = CGPoint(x: 0, y: trayH / 2 - 14)
        tray.content.addChild(handle)
        
        // Orbs
        let colors = level.availableColors
        let radius: CGFloat = colors.count > 5 ? 24 : 28
        let spacing = min(radius * 2 + 18, (W - 40) / CGFloat(colors.count))
        let orbY = -trayH / 2 + (trayH - 60 - 24) / 2 + 60 - 2
        for (i, color) in colors.enumerated() {
            let orb = ColorOrb(color: color, radius: radius)
            orb.position = CGPoint(x: (CGFloat(i) - CGFloat(colors.count - 1) / 2) * spacing, y: orbY)
            orb.onTap = { [weak self] tapped in self?.select(tapped) }
            orb.zPosition = 2
            tray.content.addChild(orb)
            orbs.append(orb)
        }
        if let first = orbs.first {
            first.isActive = true
            state.activeColor = first.color
        }
    }
    
    // MARK: - Colour selection
    
    private func select(_ orb: ColorOrb) {
        for o in orbs { o.isActive = (o === orb) }
        state.activeColor = orb.color
    }
    
    // MARK: - Touch (regions; buttons and orbs handle their own)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isFinishing, let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Topmost unrestored region under the finger (nodes(at:) is front-to-back)
        for node in nodes(at: location) {
            var current: SKNode? = node
            while let n = current, !(n is ColorableRegion) { current = n.parent }
            guard let region = current as? ColorableRegion else { continue }
            if region.isRestored { continue }
            
            let local = region.convert(location, from: self)
            region.restore(with: state.activeColor, at: local)
            history.append(region)
            spawnParticles(at: location)
            HapticManager.tap()
            SoundManager.shared.playTap()
            state.restoredCount += 1
            PlayerStats.colorsRestored += 1
            updateProgressBar()
            checkComplete()
            break
        }
    }
    
    // MARK: - HUD actions
    
    private func undoTapped() {
        guard !isFinishing, let last = history.popLast() else { return }
        last.reset()
        state.restoredCount = max(0, state.restoredCount - 1)
        PlayerStats.colorsRestored = max(0, PlayerStats.colorsRestored - 1)
        updateProgressBar()
    }
    
    private func doneTapped() {
        guard !isFinishing else { return }
        if state.isComplete {
            finish(after: 0)
        } else {
            // Not yet — hint at what's left
            regions.forEach { $0.pulse() }
            let wiggle = SKAction.sequence([
                SKAction.rotate(byAngle: 0.12, duration: 0.06),
                SKAction.rotate(byAngle: -0.24, duration: 0.1),
                SKAction.rotate(byAngle: 0.12, duration: 0.06)
            ])
            doneButton.run(wiggle)
        }
    }
    
    // MARK: - Feedback
    
    private func updateProgressBar() {
        progressBar.setProgress(CGFloat(state.restoredCount) / CGFloat(state.totalObjects))
    }
    
    private func spawnParticles(at point: CGPoint) {
        let burst = TapSparkle.burst(color: state.activeColor)
        burst.position  = point
        burst.zPosition = 50
        addChild(burst)
    }
    
    private func checkComplete() {
        guard state.isComplete else { return }
        HapticManager.success()
        SoundManager.shared.playFanfare()
        finish(after: 0.5)   // spec: 0.5 s delay → LevelCompleteScene
    }
    
    private func finish(after delay: TimeInterval) {
        guard !isFinishing else { return }
        isFinishing = true
        let elapsed = state.elapsed
        run(SKAction.wait(forDuration: delay)) {
            let scene = LevelCompleteScene(size: self.size, level: self.level, elapsed: elapsed)
            scene.scaleMode = .aspectFill
            self.view?.presentScene(scene, transition: .fade(withDuration: 0.5))
        }
    }
    
    // MARK: - Navigation
    
    private func exitToLevelSelect() {
        let select = LevelSelectScene(size: size)
        select.scaleMode = .aspectFill
        view?.presentScene(select, transition: .fade(withDuration: 0.4))
    }
}
