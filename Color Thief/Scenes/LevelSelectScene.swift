import SpriteKit

/// Spec: 3-column grid, card states Completed / Current / Locked,
/// levels 1–3 free (4+ IAP), 0–3 stars per level.
class LevelSelectScene: SKScene {
    
    private let levels = LevelData.all
    private let columns = 3
    
    // Grid scrolling (only kicks in when the grid is taller than its viewport)
    private let gridContainer = SKNode()
    private var scrollRange: CGFloat = 0
    private var lastTouchY: CGFloat?
    
    override func didMove(to view: SKView) {
        backgroundColor = .warmCream
        
        let safeTop    = view.safeAreaInsets.top
        let safeBottom = view.safeAreaInsets.bottom
        let W = frame.width, H = frame.height
        
        setupBackground()
        
        let headerY = H - safeTop - 40
        setupHeader(y: headerY)
        
        let navH: CGFloat = 64
        let navY = safeBottom + 12 + navH / 2
        setupBottomNav(y: navY, size: navH)
        
        // Grid → progress card → ground strip → nav (mockup order)
        let progressH: CGFloat = 92
        let gridTop    = headerY - 64
        let minBottom  = navY + navH / 2 + 24 + progressH + 24
        let gridBottom = setupGrid(top: gridTop, minBottom: minBottom, width: W)
        
        let progressY = gridBottom - 24 - progressH / 2
        setupProgressCard(y: progressY, size: CGSize(width: W - 40, height: progressH))
        
        setupGroundStrip(top: progressY - progressH / 2 - 10, bottom: navY + navH / 2 + 10)
    }
    
    // MARK: - Background
    
    private func setupBackground() {
        let bg = SKSpriteNode(texture: .polkaDots(size: size, background: .warmCream,
                                                  dot: UIColor(hex: "#FFE9B8")),
                              size: size)
        bg.position  = CGPoint(x: frame.midX, y: frame.midY)
        bg.zPosition = -10
        addChild(bg)
    }
    
    // MARK: - Header
    
    private func setupHeader(y: CGFloat) {
        // Back
        let back = ChunkyButton(size: CGSize(width: 56, height: 56),
                                style: Style.circle(fill: .coralRed),
                                icon: SKSpriteNode.symbol("chevron.left", pointSize: 22, color: .white))
        back.position  = CGPoint(x: 16 + 28, y: y)
        back.zPosition = 10
        back.onTap = { [weak self] in self?.goHome() }
        addChild(back)
        
        // Title
        let chapter = LabelFactory.body("CHAPTER 1", size: 13, color: UIColor.darkNavy.withAlphaComponent(0.6))
        chapter.position  = CGPoint(x: frame.midX, y: y + 18)
        chapter.zPosition = 10
        addChild(chapter)
        
        let title = LabelFactory.title("WORLD", size: AppFonts.Size.title + 2,
                                       fill: .darkNavy, stroke: .darkNavy,
                                       shadowColor: .sunshineYellow, shadowOffset: 3)
        title.position  = CGPoint(x: frame.midX, y: y - 12)
        title.zPosition = 10
        addChild(title)
        
        // Star counter
        let pill = ChunkyButton(size: CGSize(width: 112, height: 46), style: .white)
        pill.isUserInteractionEnabled = false
        pill.position  = CGPoint(x: frame.width - 16 - 56, y: y)
        pill.zPosition = 10
        addChild(pill)
        let star = SKSpriteNode.symbol("star.fill", pointSize: 18, color: .sunshineYellow)
        star.position = CGPoint(x: -30, y: 0)
        pill.content.addChild(star)
        let starOutline = SKSpriteNode.symbol("star.fill", pointSize: 21, color: .darkNavy)
        starOutline.position  = star.position
        starOutline.zPosition = -0.5
        pill.content.addChild(starOutline)
        let count = LabelFactory.body("\(LevelProgressStore.totalStars)/\(levels.count * 3)",
                                      font: AppFonts.headline, size: 18)
        count.position = CGPoint(x: 12, y: 0)
        pill.content.addChild(count)
    }
    
    // MARK: - Grid
    
    /// Lays out the grid from `top` downward and returns the y where it ends.
    /// The viewport never extends below `minBottom`; taller grids scroll.
    @discardableResult
    private func setupGrid(top: CGFloat, minBottom: CGFloat, width: CGFloat) -> CGFloat {
        let gap: CGFloat  = 18
        let side          = min(104, (width - 56 - gap * CGFloat(columns - 1)) / CGFloat(columns))
        let rows          = Int(ceil(Double(levels.count) / Double(columns)))
        let gridW         = side * CGFloat(columns) + gap * CGFloat(columns - 1)
        let gridH         = side * CGFloat(rows) + gap * CGFloat(rows - 1)
        let originX       = frame.midX - gridW / 2 + side / 2
        let bottom        = max(minBottom, top - gridH - 24)
        
        // Viewport clip so scrolled cards don't run into the header/progress card
        let viewportH = top - bottom
        let crop = SKCropNode()
        let mask = SKSpriteNode(color: .white, size: CGSize(width: width, height: viewportH))
        mask.position = CGPoint(x: frame.midX, y: (top + bottom) / 2)
        crop.maskNode = mask
        crop.zPosition = 5
        addChild(crop)
        crop.addChild(gridContainer)
        
        // Content is laid out from `top` downward; if it overflows, allow dragging up.
        scrollRange = max(0, gridH + 16 - viewportH)
        let firstRowY = top - side / 2 - 8
        
        // Positions in snake order so the dotted path flows 1→2→3↓6←5←4
        var centres: [CGPoint] = []
        for (i, _) in levels.enumerated() {
            let row = i / columns
            var col = i % columns
            if row % 2 == 1 { col = columns - 1 - col }
            centres.append(CGPoint(x: originX + CGFloat(col) * (side + gap),
                                   y: firstRowY - CGFloat(row) * (side + gap)))
        }
        
        // Dotted path
        let path = CGMutablePath()
        for (i, c) in centres.enumerated() {
            if i == 0 { path.move(to: c) } else { path.addLine(to: c) }
        }
        let dashed = SKShapeNode(path: path.copy(dashingWithPhase: 0, lengths: [10, 12]))
        dashed.strokeColor = .sunshineYellow
        dashed.lineWidth   = 7
        dashed.lineCap     = .round
        dashed.zPosition   = 0
        gridContainer.addChild(dashed)
        
        // Cards
        for (i, level) in levels.enumerated() {
            let state = LevelProgressStore.state(for: level)
            let card  = LevelCard(level: level, state: state, size: side)
            card.position  = centres[i]
            card.zPosition = 1
            card.onTap = { [weak self] in
                if state == .premium { self?.showPaywall() } else { self?.play(level) }
            }
            gridContainer.addChild(card)
        }
        return bottom
    }
    
    // MARK: - Progress card
    
    private func setupProgressCard(y: CGFloat, size: CGSize) {
        let card = StickerCard(size: size, cornerRadius: 26, shadowOffset: 7)
        card.position  = CGPoint(x: frame.midX, y: y)
        card.zPosition = 5
        addChild(card)
        
        let completed = LevelProgressStore.completedCount
        let pct = levels.isEmpty ? 0 : CGFloat(completed) / CGFloat(levels.count)
        
        let bucket = SKSpriteNode.symbol("drop.fill", pointSize: 18, color: .coralRed)
        bucket.position = CGPoint(x: -size.width / 2 + 30, y: size.height * 0.20)
        card.content.addChild(bucket)
        
        let label = LabelFactory.body("WORLD RESTORED", font: AppFonts.headline, size: 16)
        label.horizontalAlignmentMode = .left
        label.position = CGPoint(x: -size.width / 2 + 48, y: size.height * 0.20)
        card.content.addChild(label)
        
        let percent = LabelFactory.body("\(Int((pct * 100).rounded()))%", font: AppFonts.headline, size: 20, color: .coralRed)
        percent.horizontalAlignmentMode = .right
        percent.position = CGPoint(x: size.width / 2 - 22, y: size.height * 0.20)
        card.content.addChild(percent)
        
        // Bar
        let trackW = size.width - 44
        let trackH: CGFloat = 18
        let trackY = -size.height * 0.20
        let track = SKShapeNode(rectOf: CGSize(width: trackW, height: trackH), cornerRadius: trackH / 2)
        track.fillColor   = UIColor(hex: "#EFE4D2")
        track.strokeColor = .clear
        track.position    = CGPoint(x: 0, y: trackY)
        card.content.addChild(track)
        
        let fillW = max(trackH, trackW * pct)
        if pct > 0 {
            let fill = SKSpriteNode(texture: .horizontalGradient(size: CGSize(width: fillW, height: trackH),
                                                                 left: .sunshineYellow, right: .mintGreen),
                                    size: CGSize(width: fillW, height: trackH))
            let fillMask = SKShapeNode(rectOf: CGSize(width: fillW, height: trackH), cornerRadius: trackH / 2)
            fillMask.fillColor = .white
            let clip = SKCropNode()
            clip.maskNode = fillMask
            clip.addChild(fill)
            clip.position = CGPoint(x: -trackW / 2 + fillW / 2, y: trackY)
            clip.zPosition = 1
            card.content.addChild(clip)
        }
    }
    
    // MARK: - Ground strip
    
    private func setupGroundStrip(top: CGFloat, bottom: CGFloat) {
        let h = top - bottom
        guard h > 40 else { return }
        let w = frame.width
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: bottom))
        path.addLine(to: CGPoint(x: 0, y: bottom + h * 0.55))
        path.addCurve(to: CGPoint(x: w, y: bottom + h * 0.45),
                      control1: CGPoint(x: w * 0.35, y: bottom + h * 1.0),
                      control2: CGPoint(x: w * 0.65, y: bottom + h * 0.1))
        path.addLine(to: CGPoint(x: w, y: bottom))
        path.closeSubpath()
        let ground = SKShapeNode(path: path)
        ground.fillColor   = UIColor(hex: "#FFF0C8")
        ground.strokeColor = .clear
        ground.zPosition   = 1
        addChild(ground)
        
        // Tiny tree + house; grey until the first level is done
        let palette: LandscapeArt.Palette = LevelProgressStore.completedCount > 0 ? .color : .grey
        let tree = LandscapeArt.tree(height: h * 1.6, palette: palette)
        tree.position  = CGPoint(x: w * 0.16, y: bottom + h * 0.62)
        tree.zPosition = 2
        addChild(tree)
        let house = LandscapeArt.house(height: h * 1.4, palette: palette)
        house.position  = CGPoint(x: w * 0.84, y: bottom + h * 0.56)
        house.zPosition = 2
        addChild(house)
    }
    
    // MARK: - Bottom nav
    
    private func setupBottomNav(y: CGFloat, size: CGFloat) {
        let spacing: CGFloat = 96
        let items: [(String, UIColor, UIColor, (() -> Void)?)] = [
            ("house.fill",        .sunshineYellow, .darkNavy, { [weak self] in self?.goHome() }),
            ("paintpalette.fill", .lavender,       .white,    nil),   // colour collection — later phase
            ("lock.fill",         .white,          .darkNavy, { [weak self] in ParentFlow.present(from: self?.view) })
        ]
        for (i, item) in items.enumerated() {
            let btn = ChunkyButton(size: CGSize(width: size, height: size),
                                   style: Style.circle(fill: item.1),
                                   icon: SKSpriteNode.symbol(item.0, pointSize: 24, color: item.2))
            btn.position  = CGPoint(x: frame.midX + (CGFloat(i) - 1) * spacing, y: y)
            btn.zPosition = 10
            btn.onTap = item.3
            addChild(btn)
        }
    }
    
    // MARK: - Scrolling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchY = touches.first?.location(in: self).y
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard scrollRange > 0, let t = touches.first, let last = lastTouchY else { return }
        let y = t.location(in: self).y
        gridContainer.position.y = min(scrollRange, max(0, gridContainer.position.y + (y - last)))
        lastTouchY = y
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { lastTouchY = nil }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { lastTouchY = nil }
    
    // MARK: - Navigation
    
    private func play(_ level: Level) {
        let game = GameScene(size: size, level: level)
        game.scaleMode = .aspectFill
        view?.presentScene(game, transition: .fade(withDuration: 0.4))
    }
    
    private func showPaywall() {
        Paywall.present(from: view) { [weak self] in
            guard let self else { return }
            // Rebuild so the unlocked cards appear
            let refreshed = LevelSelectScene(size: self.size)
            refreshed.scaleMode = .aspectFill
            self.view?.presentScene(refreshed, transition: .fade(withDuration: 0.3))
        }
    }
    
    private func goHome() {
        let home = HomeScene(size: size)
        home.scaleMode = .aspectFill
        view?.presentScene(home, transition: .fade(withDuration: 0.4))
    }
}

private typealias Style = ChunkyButton.Style

private extension ChunkyButton.Style {
    static func circle(fill: UIColor) -> ChunkyButton.Style {
        ChunkyButton.Style(fill: fill, lip: fill.darkened(), lipHeight: 5)
    }
}
