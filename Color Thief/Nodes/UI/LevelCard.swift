import SpriteKit

/// One tile on the Level Select grid. Completed = world colour + gold stars,
/// Current = white with a play badge and idle bounce, Locked = grey with a padlock.
class LevelCard: ChunkyButton {
    
    let level: Level
    let state: LevelState
    
    init(level: Level, state: LevelState, size: CGFloat) {
        self.level = level
        self.state = state
        
        let style: ChunkyButton.Style
        switch state {
        case .completed:
            style = Style(fill: level.worldColor, lip: level.worldColor.darkened(),
                          lipHeight: 7, cornerRadius: size * 0.26)
        case .current:
            style = Style(fill: .white, lip: .darkNavy, text: .darkNavy,
                          lipHeight: 7, cornerRadius: size * 0.26)
        case .locked, .premium:
            style = Style(fill: .skyGrey, lip: .groundGrey, stroke: .outlineDark,
                          lipHeight: 7, cornerRadius: size * 0.26)
        }
        
        super.init(size: CGSize(width: size, height: size), style: style)
        
        switch state {
        case .completed(let stars):
            addNumber(fill: .white, stroke: .darkNavy, size: size)
            addStars(earned: stars, size: size)
        case .current:
            addNumber(fill: .coralRed, stroke: .darkNavy, size: size)
            addStars(earned: 0, size: size, empty: .skyGrey)
            addPlayBadge(size: size)
            startIdleBounce(amplitude: 4)
        case .locked:
            isUserInteractionEnabled = false
            let faint = LabelFactory.body("\(level.id)", font: AppFonts.headline, size: size * 0.24,
                                          color: UIColor.white.withAlphaComponent(0.7))
            faint.position = CGPoint(x: -size * 0.32, y: size * 0.30)
            content.addChild(faint)
            addPadlock(size: size)
        case .premium:
            let faint = LabelFactory.body("\(level.id)", font: AppFonts.headline, size: size * 0.24,
                                          color: UIColor.white.withAlphaComponent(0.7))
            faint.position = CGPoint(x: -size * 0.32, y: size * 0.30)
            content.addChild(faint)
            addPadlock(size: size, premium: true)
            startIdleBounce(amplitude: 3)
        }
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("not used") }
    
    // MARK: - Pieces
    
    private func addNumber(fill: UIColor, stroke: UIColor, size: CGFloat) {
        let number = LabelFactory.outlined("\(level.id)", size: size * 0.42, fill: fill, stroke: stroke, strokeWidth: 3)
        number.position = CGPoint(x: 0, y: size * 0.10)
        number.zPosition = 2
        content.addChild(number)
    }
    
    private func addStars(earned: Int, size: CGFloat, empty: UIColor = UIColor.white.withAlphaComponent(0.55)) {
        let starSize = size * 0.16
        let spacing  = starSize * 1.25
        for i in 0..<3 {
            let gold = i < earned
            let star = SKSpriteNode.symbol("star.fill", pointSize: starSize,
                                           color: gold ? .sunshineYellow : empty)
            star.position = CGPoint(x: (CGFloat(i) - 1) * spacing, y: -size * 0.26)
            star.zPosition = 2
            // Middle star sits a touch higher, like the mockup
            if i == 1 { star.position.y += starSize * 0.15 }
            content.addChild(star)
            if gold {
                let outline = SKSpriteNode.symbol("star.fill", pointSize: starSize + 3, color: .darkNavy)
                outline.position  = star.position
                outline.zPosition = 1
                content.addChild(outline)
            }
        }
    }
    
    private func addPlayBadge(size: CGFloat) {
        let badge = SKShapeNode(circleOfRadius: size * 0.15)
        badge.fillColor   = .sunshineYellow
        badge.strokeColor = .darkNavy
        badge.lineWidth   = 3
        badge.position    = CGPoint(x: size * 0.42, y: size * 0.42)
        badge.zPosition   = 4
        let play = SKSpriteNode.symbol("play.fill", pointSize: size * 0.13, color: .darkNavy)
        play.position = CGPoint(x: 1.5, y: 0)
        badge.addChild(play)
        content.addChild(badge)
    }
    
    private func addPadlock(size: CGFloat, premium: Bool = false) {
        let disc = SKShapeNode(circleOfRadius: size * 0.22)
        disc.fillColor   = premium ? .sunshineYellow : UIColor.white.withAlphaComponent(0.35)
        disc.strokeColor = premium ? .darkNavy : .clear
        disc.lineWidth   = 3
        disc.position    = CGPoint(x: 0, y: -size * 0.04)
        disc.zPosition   = 2
        let lock = SKSpriteNode.symbol("lock.fill", pointSize: size * 0.22, color: premium ? .darkNavy : .outlineDark)
        disc.addChild(lock)
        content.addChild(disc)
    }
}
