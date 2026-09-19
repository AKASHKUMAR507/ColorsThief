import SpriteKit

/// Vector placeholder landscape (sky, hills, sun, clouds, tree, house, mascot).
/// Renders in full colour or as the "stolen" grey world. Replace with real art later.
/// Coordinates are centred on (0,0) and span `size`; hills extend below the bottom edge.
enum LandscapeArt {
    
    struct Palette {
        var ink: UIColor
        var skyTop: UIColor, skyBottom: UIColor
        var hillBack: UIColor, hillFront: UIColor
        var sun: UIColor
        var cloud: UIColor
        var canopy: UIColor, trunk: UIColor
        var houseBody: UIColor, roof: UIColor, door: UIColor, window: UIColor
        var flowerA: UIColor, flowerB: UIColor
        
        static let color = Palette(
            ink: .darkNavy,
            skyTop: .skyBlue, skyBottom: UIColor(hex: "#A8E4FF"),
            hillBack: UIColor(hex: "#5FE07A"), hillFront: .grassGreen,
            sun: .sunshineYellow,
            cloud: .white,
            canopy: UIColor(hex: "#3DBE55"), trunk: UIColor(hex: "#B5772E"),
            houseBody: .white, roof: .coralRed, door: .sunshineYellow, window: .skyBlue,
            flowerA: .hotPink, flowerB: .lavender
        )
        
        static let grey = Palette(
            ink: .outlineDark,
            skyTop: .skyGrey, skyBottom: UIColor(hex: "#DEDEE8"),
            hillBack: UIColor(hex: "#B8B8C6"), hillFront: .groundGrey,
            sun: UIColor(hex: "#BCBCC8"),
            cloud: UIColor(hex: "#E4E4EC"),
            canopy: .objectGrey, trunk: UIColor(hex: "#7C7C8A"),
            houseBody: UIColor(hex: "#DCDCE4"), roof: UIColor(hex: "#9E9EAC"),
            door: UIColor(hex: "#B4B4C0"), window: UIColor(hex: "#C4C4D0"),
            flowerA: UIColor(hex: "#A4A4B2"), flowerB: UIColor(hex: "#B4B4C0")
        )
    }
    
    struct Options {
        var palette: Palette = .color
        var showRainbow = false
        /// Mascot holding a paintbrush (splash) instead of just standing.
        var mascotPainting = false
    }
    
    static func make(size: CGSize, options: Options = Options()) -> SKNode {
        let root = SKNode()
        let w = size.width, h = size.height
        let p = options.palette
        let ink = p.ink
        let line: CGFloat = 3
        
        // Sky
        let sky = SKSpriteNode(texture: .verticalGradient(size: size, top: p.skyTop, bottom: p.skyBottom),
                               size: size)
        root.addChild(sky)
        
        // Rainbow arch, top-right, partly out of frame
        if options.showRainbow {
            let rb = rainbow(radius: h * 0.26, bandWidth: 12)
            rb.position  = CGPoint(x: w * 0.34, y: h * 0.18)
            rb.zPosition = 1
            root.addChild(rb)
        }
        
        // Rolling hills (two layers)
        root.addChild(hill(width: w, height: h, baseY: -h * 0.22, bump: h * 0.16,
                           fill: p.hillBack, stroke: ink, line: line, zPos: 2))
        root.addChild(hill(width: w, height: h, baseY: -h * 0.34, bump: h * 0.12,
                           fill: p.hillFront, stroke: ink, line: line, zPos: 4))
        
        // Sun
        let sun = SKNode()
        sun.position = CGPoint(x: w * 0.34, y: h * 0.30)
        let sunBody = SKShapeNode(circleOfRadius: h * 0.075)
        sunBody.fillColor = p.sun; sunBody.strokeColor = ink; sunBody.lineWidth = line
        sun.addChild(sunBody)
        for i in 0..<8 {
            let a = CGFloat(i) / 8 * .pi * 2
            let ray = SKShapeNode(rectOf: CGSize(width: 4, height: h * 0.045), cornerRadius: 2)
            ray.fillColor = p.sun; ray.strokeColor = .clear
            ray.position = CGPoint(x: cos(a) * h * 0.115, y: sin(a) * h * 0.115)
            ray.zRotation = a - .pi / 2
            sun.addChild(ray)
        }
        sun.addChild(KawaiiFace.make(scale: h * 0.075, ink: ink))
        sun.zPosition = 3
        root.addChild(sun)
        
        // Clouds
        root.addChild(cloud(at: CGPoint(x: -w * 0.30, y: h * 0.30), scale: h * 0.05, fill: p.cloud, ink: ink, line: line))
        root.addChild(cloud(at: CGPoint(x: w * 0.12, y: h * 0.24), scale: h * 0.04, fill: p.cloud, ink: ink, line: line))
        
        // Tree
        let tree = self.tree(height: h, palette: p)
        tree.position = CGPoint(x: -w * 0.30, y: -h * 0.10)
        tree.zPosition = 5
        root.addChild(tree)
        
        // House
        let house = self.house(height: h, palette: p)
        house.position = CGPoint(x: w * 0.32, y: -h * 0.10)
        house.zPosition = 5
        root.addChild(house)
        
        // Mascot — always in colour; it's the one bringing colour back
        let mascot = self.mascot(height: h, painting: options.mascotPainting)
        mascot.position  = CGPoint(x: 0, y: -h * 0.16)
        mascot.zPosition = 6
        root.addChild(mascot)
        
        // Flowers
        for (x, c) in [(-w * 0.12, p.flowerA), (w * 0.14, p.flowerB)] {
            let f = SKNode()
            f.position = CGPoint(x: x, y: -h * 0.30)
            let stem = SKShapeNode(rectOf: CGSize(width: 3, height: h * 0.05))
            stem.fillColor = ink; stem.strokeColor = .clear
            f.addChild(stem)
            let head = SKShapeNode(circleOfRadius: h * 0.022)
            head.fillColor = c; head.strokeColor = ink; head.lineWidth = 2
            head.position = CGPoint(x: 0, y: h * 0.03)
            f.addChild(head)
            f.zPosition = 6
            root.addChild(f)
        }
        
        return root
    }
    
    // MARK: - Pieces
    
    /// Five-band rainbow arch (0…π), centred on its origin.
    static func rainbow(radius: CGFloat, bandWidth: CGFloat) -> SKNode {
        let node = SKNode()
        let bands: [UIColor] = [.hotPink, .sunshineYellow, .grassGreen, .skyBlue, .lavender]
        for (i, c) in bands.enumerated() {
            let r = radius - CGFloat(i) * (bandWidth + 1)
            let arc = SKShapeNode(path: KawaiiFace.arcPath(radius: r, start: 0, end: .pi))
            arc.strokeColor = c; arc.lineWidth = bandWidth; arc.lineCap = .butt
            node.addChild(arc)
        }
        return node
    }
    
    /// The paint-blob mascot (yellow, beret, blush), optionally holding a brush. Sized to a landscape height `h`.
    static func mascot(height h: CGFloat, painting: Bool = false, cheering: Bool = false) -> SKNode {
        let line: CGFloat = 3
        let mascot = SKNode()
        let blob = SKShapeNode(circleOfRadius: h * 0.09)
        blob.fillColor = .sunshineYellow; blob.strokeColor = .darkNavy; blob.lineWidth = line
        mascot.addChild(blob)
        blob.addChild(KawaiiFace.make(scale: h * 0.09, ink: .darkNavy, blush: true))
        let beret = SKShapeNode(ellipseOf: CGSize(width: h * 0.13, height: h * 0.05))
        beret.fillColor = .coralRed; beret.strokeColor = .darkNavy; beret.lineWidth = line
        beret.position = CGPoint(x: -h * 0.02, y: h * 0.085)
        beret.zRotation = -0.15
        mascot.addChild(beret)
        if cheering {
            for sx: CGFloat in [-1, 1] {
                let arm = SKShapeNode(path: {
                    let p = CGMutablePath()
                    p.move(to: CGPoint(x: sx * h * 0.07, y: h * 0.02))
                    p.addLine(to: CGPoint(x: sx * h * 0.15, y: h * 0.12))
                    return p
                }())
                arm.strokeColor = .darkNavy; arm.lineWidth = line + 1; arm.lineCap = .round
                arm.zPosition = -1
                mascot.addChild(arm)
                let hand = SKShapeNode(circleOfRadius: h * 0.022)
                hand.fillColor = .sunshineYellow; hand.strokeColor = .darkNavy; hand.lineWidth = line
                hand.position = CGPoint(x: sx * h * 0.15, y: h * 0.12)
                mascot.addChild(hand)
            }
        }
        if painting {
            let brush = SKNode()
            brush.position = CGPoint(x: h * 0.08, y: h * 0.02)
            brush.zRotation = 0.6
            let handle = SKShapeNode(rectOf: CGSize(width: h * 0.028, height: h * 0.20), cornerRadius: 4)
            handle.fillColor = UIColor(hex: "#B5772E"); handle.strokeColor = .darkNavy; handle.lineWidth = line
            brush.addChild(handle)
            let ferrule = SKShapeNode(rectOf: CGSize(width: h * 0.032, height: h * 0.03), cornerRadius: 2)
            ferrule.fillColor = .skyGrey; ferrule.strokeColor = .darkNavy; ferrule.lineWidth = 2
            ferrule.position = CGPoint(x: 0, y: h * 0.11)
            brush.addChild(ferrule)
            let tip = SKShapeNode(ellipseOf: CGSize(width: h * 0.036, height: h * 0.05))
            tip.fillColor = .hotPink; tip.strokeColor = .darkNavy; tip.lineWidth = 2
            tip.position = CGPoint(x: 0, y: h * 0.145)
            brush.addChild(tip)
            mascot.addChild(brush)
        }
        return mascot
    }
    
    /// Tree sized relative to a landscape height `h`.
    static func tree(height h: CGFloat, palette p: Palette) -> SKNode {
        let ink = p.ink, line: CGFloat = 3
        let tree = SKNode()
        let trunk = SKShapeNode(rectOf: CGSize(width: h * 0.05, height: h * 0.16), cornerRadius: 3)
        trunk.fillColor = p.trunk; trunk.strokeColor = ink; trunk.lineWidth = line
        trunk.position = CGPoint(x: 0, y: -h * 0.06)
        tree.addChild(trunk)
        let canopy = SKShapeNode(circleOfRadius: h * 0.10)
        canopy.fillColor = p.canopy; canopy.strokeColor = ink; canopy.lineWidth = line
        canopy.position = CGPoint(x: 0, y: h * 0.06)
        tree.addChild(canopy)
        canopy.addChild(KawaiiFace.make(scale: h * 0.10, ink: ink))
        return tree
    }
    
    /// House sized relative to a landscape height `h`.
    static func house(height h: CGFloat, palette p: Palette) -> SKNode {
        let ink = p.ink, line: CGFloat = 3
        let house = SKNode()
        let body = SKShapeNode(rectOf: CGSize(width: h * 0.20, height: h * 0.16), cornerRadius: 6)
        body.fillColor = p.houseBody; body.strokeColor = ink; body.lineWidth = line
        house.addChild(body)
        let roofPath = CGMutablePath()
        roofPath.move(to: CGPoint(x: -h * 0.12, y: h * 0.08))
        roofPath.addLine(to: CGPoint(x: 0, y: h * 0.19))
        roofPath.addLine(to: CGPoint(x: h * 0.12, y: h * 0.08))
        roofPath.closeSubpath()
        let roof = SKShapeNode(path: roofPath)
        roof.fillColor = p.roof; roof.strokeColor = ink; roof.lineWidth = line; roof.lineJoin = .round
        house.addChild(roof)
        let door = SKShapeNode(rectOf: CGSize(width: h * 0.045, height: h * 0.08), cornerRadius: 4)
        door.fillColor = p.door; door.strokeColor = ink; door.lineWidth = line
        door.position = CGPoint(x: h * 0.05, y: -h * 0.04)
        house.addChild(door)
        let window = SKShapeNode(rectOf: CGSize(width: h * 0.05, height: h * 0.05), cornerRadius: 4)
        window.fillColor = p.window; window.strokeColor = ink; window.lineWidth = line
        window.position = CGPoint(x: -h * 0.04, y: h * 0.01)
        house.addChild(window)
        return house
    }
    
    static func hill(width w: CGFloat, height h: CGFloat, baseY: CGFloat, bump: CGFloat,
                             fill: UIColor, stroke: UIColor, line: CGFloat, zPos: CGFloat) -> SKShapeNode {
        let p = CGMutablePath()
        p.move(to: CGPoint(x: -w, y: -h))
        p.addLine(to: CGPoint(x: -w, y: baseY))
        p.addCurve(to: CGPoint(x: 0, y: baseY + bump),
                   control1: CGPoint(x: -w * 0.5, y: baseY),
                   control2: CGPoint(x: -w * 0.2, y: baseY + bump))
        p.addCurve(to: CGPoint(x: w, y: baseY - bump * 0.3),
                   control1: CGPoint(x: w * 0.3, y: baseY + bump),
                   control2: CGPoint(x: w * 0.6, y: baseY - bump * 0.3))
        p.addLine(to: CGPoint(x: w, y: -h))
        p.closeSubpath()
        let n = SKShapeNode(path: p)
        n.fillColor = fill; n.strokeColor = stroke; n.lineWidth = line
        n.zPosition = zPos
        return n
    }
    
    static func cloud(at pos: CGPoint, scale s: CGFloat, fill: UIColor, ink: UIColor, line: CGFloat) -> SKNode {
        let n = SKNode()
        n.position = pos
        n.zPosition = 3
        let puffs = [
            CGRect(x: -s * 1.6, y: -s * 0.6, width: s * 3.2, height: s * 1.2),
            CGRect(x: -s * 1.0, y: -s * 0.2, width: s * 1.6, height: s * 1.6),
            CGRect(x: -s * 0.1, y: -s * 0.1, width: s * 1.5, height: s * 1.4)
        ]
        // Outlined puffs underneath, then fill-only puffs on top to hide the inner strokes
        for r in puffs {
            let edge = SKShapeNode(ellipseIn: r)
            edge.fillColor = fill; edge.strokeColor = ink; edge.lineWidth = line
            n.addChild(edge)
        }
        for r in puffs {
            let solid = SKShapeNode(ellipseIn: r)
            solid.fillColor = fill; solid.strokeColor = .clear
            solid.zPosition = 1
            n.addChild(solid)
        }
        let f = KawaiiFace.make(scale: s * 0.9, ink: ink, sleepy: true)
        f.zPosition = 2
        n.addChild(f)
        return n
    }
    
    private static func arcPath(radius: CGFloat, start: CGFloat, end: CGFloat) -> CGPath {
        let p = CGMutablePath()
        p.addArc(center: .zero, radius: radius, startAngle: start, endAngle: end, clockwise: false)
        return p
    }
}
