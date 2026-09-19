import SpriteKit

/// A fixed, pre-coloured piece of a friend (body, stem, mast…).
struct FriendPart {
    let path: CGPath
    let fill: UIColor
    var stroke: UIColor = .darkNavy
    var lineWidth: CGFloat = 4
    var z: CGFloat = 0
}

/// A tappable, fillable area of a friend. Drawn white with a dotted outline until restored.
struct FriendRegion {
    let name: String
    let path: CGPath
    var z: CGFloat = 0
}

/// One colouring-book character. Coordinates are design units centred on (0,0),
/// spanning about `box` × `box`; the scene scales it to fit the play card.
struct Friend {
    let name: String          // "Butterfly Friend"
    let box: CGFloat
    let regions: [FriendRegion]
    let parts: [FriendPart]
    let faces: [(center: CGPoint, radius: CGFloat, blush: Bool)]
    /// Extra ink drawn on top (antennae, nostrils, tail…). Stroke only.
    var inkLines: [(path: CGPath, width: CGFloat)] = []
    var inkDots: [(center: CGPoint, radius: CGFloat, color: UIColor)] = []
}

enum FriendArt {
    
    static func friend(for key: String) -> Friend {
        // Procedural friends: "gen:<category>:<seed>"
        if key.hasPrefix("gen:") {
            let parts = key.split(separator: ":")
            if parts.count == 3, let category = FriendGenerator.Category(rawValue: String(parts[1])), let seed = Int(parts[2]) {
                return FriendGenerator.make(category: category, seed: seed)
            }
        }
        switch key {
        case "butterfly": return butterfly
        case "flower":    return flower
        case "barn":      return barn
        case "pig":       return pig
        case "fish":      return fish
        case "boat":      return boat
        case "mushroom":  return mushroom
        case "chick":     return chick
        case "whale":     return whale
        case "sun":       return sun
        case "balloon":   return balloon
        case "ladybug":   return ladybug
        case "rocket":    return rocket
        default:          return butterfly
        }
    }
    
    // MARK: - Path helpers
    
    private static func ellipse(_ cx: CGFloat, _ cy: CGFloat, _ w: CGFloat, _ h: CGFloat, rotation: CGFloat = 0) -> CGPath {
        var t = CGAffineTransform(translationX: cx, y: cy).rotated(by: rotation)
        return CGPath(ellipseIn: CGRect(x: -w / 2, y: -h / 2, width: w, height: h), transform: &t)
    }
    
    private static func circle(_ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat) -> CGPath {
        CGPath(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2), transform: nil)
    }
    
    private static func roundedRect(_ cx: CGFloat, _ cy: CGFloat, _ w: CGFloat, _ h: CGFloat, _ radius: CGFloat) -> CGPath {
        CGPath(roundedRect: CGRect(x: cx - w / 2, y: cy - h / 2, width: w, height: h),
               cornerWidth: radius, cornerHeight: radius, transform: nil)
    }
    
    private static func polygon(_ points: [(CGFloat, CGFloat)]) -> CGPath {
        let p = CGMutablePath()
        for (i, pt) in points.enumerated() {
            let c = CGPoint(x: pt.0, y: pt.1)
            i == 0 ? p.move(to: c) : p.addLine(to: c)
        }
        p.closeSubpath()
        return p
    }
    
    private static func line(_ points: [(CGFloat, CGFloat)]) -> CGPath {
        let p = CGMutablePath()
        for (i, pt) in points.enumerated() {
            let c = CGPoint(x: pt.0, y: pt.1)
            i == 0 ? p.move(to: c) : p.addLine(to: c)
        }
        return p
    }
    
    // MARK: - Friends
    
    /// Forest 1 — four wings to fill; body, head and antennae are fixed.
    static let butterfly = Friend(
        name: "Butterfly Friend", box: 230,
        regions: [
            FriendRegion(name: "wing-tl", path: ellipse(-60, 36, 100, 82, rotation: -0.35)),
            FriendRegion(name: "wing-tr", path: ellipse( 60, 36, 100, 82, rotation:  0.35)),
            FriendRegion(name: "wing-bl", path: ellipse(-50, -44, 80, 72, rotation: 0.35)),
            FriendRegion(name: "wing-br", path: ellipse( 50, -44, 80, 72, rotation: -0.35))
        ],
        parts: [
            FriendPart(path: circle(-62, 38, 13), fill: .white, lineWidth: 3, z: 1),
            FriendPart(path: circle( 62, 38, 13), fill: .white, lineWidth: 3, z: 1),
            FriendPart(path: circle(-50, -44, 10), fill: .white, lineWidth: 3, z: 1),
            FriendPart(path: circle( 50, -44, 10), fill: .white, lineWidth: 3, z: 1),
            FriendPart(path: ellipse(0, -12, 36, 112), fill: .lavender, z: 2),
            FriendPart(path: circle(0, 58, 27), fill: .sunshineYellow, z: 3)
        ],
        faces: [(CGPoint(x: 0, y: 58), 27, true)],
        inkLines: [(line([(-10, 80), (-24, 104)]), 3.5), (line([(10, 80), (24, 104)]), 3.5)],
        inkDots: [(CGPoint(x: -26, y: 108), 6, .coralRed), (CGPoint(x: 26, y: 108), 6, .coralRed)]
    )
    
    /// Forest 2 — five petals and two leaves; the centre and stem are fixed.
    static let flower: Friend = {
        var regions: [FriendRegion] = []
        for i in 0..<5 {
            let a = CGFloat(i) / 5 * .pi * 2 + .pi / 2
            regions.append(FriendRegion(name: "petal-\(i)",
                                        path: ellipse(cos(a) * 54, 28 + sin(a) * 54, 58, 84, rotation: a - .pi / 2)))
        }
        regions.append(FriendRegion(name: "leaf-l", path: ellipse(-34, -72, 56, 28, rotation: 0.55)))
        regions.append(FriendRegion(name: "leaf-r", path: ellipse( 34, -88, 56, 28, rotation: -0.55)))
        return Friend(
            name: "Flower Friend", box: 240,
            regions: regions,
            parts: [
                FriendPart(path: roundedRect(0, -62, 14, 96, 7), fill: .grassGreen, z: -1),
                FriendPart(path: circle(0, 28, 36), fill: .sunshineYellow, z: 2)
            ],
            faces: [(CGPoint(x: 0, y: 28), 36, true)]
        )
    }()
    
    /// Farm 1 — walls, roof, door, hayloft window and silo.
    static let barn = Friend(
        name: "Barn Friend", box: 250,
        regions: [
            FriendRegion(name: "walls", path: roundedRect(-15, -42, 140, 104, 10)),
            FriendRegion(name: "roof",  path: polygon([(-95, 8), (-95, 36), (-15, 96), (65, 36), (65, 8)])),
            FriendRegion(name: "door",  path: roundedRect(-15, -58, 56, 70, 12), z: 1),
            FriendRegion(name: "window", path: circle(-15, 52, 18), z: 1),
            FriendRegion(name: "silo",  path: roundedRect(90, -30, 44, 128, 22))
        ],
        parts: [
            FriendPart(path: ellipse(90, 34, 44, 26), fill: .coralRed, z: 1),
            FriendPart(path: ellipse(0, -96, 220, 22), fill: UIColor(hex: "#EFE4D2"), stroke: .clear, z: -2)
        ],
        faces: [(CGPoint(x: -15, y: -46), 22, true)]
    )
    
    /// Farm 2 — body, ears, snout and legs.
    static let pig = Friend(
        name: "Piggy Friend", box: 230,
        regions: [
            FriendRegion(name: "leg-l", path: roundedRect(-42, -78, 36, 48, 12), z: -1),
            FriendRegion(name: "leg-r", path: roundedRect( 42, -78, 36, 48, 12), z: -1),
            FriendRegion(name: "ear-l", path: polygon([(-78, 30), (-60, 82), (-28, 50)]), z: -1),
            FriendRegion(name: "ear-r", path: polygon([( 78, 30), ( 60, 82), ( 28, 50)]), z: -1),
            FriendRegion(name: "body",  path: ellipse(0, -8, 160, 126)),
            FriendRegion(name: "snout", path: ellipse(0, -14, 60, 42), z: 1)
        ],
        parts: [],
        faces: [],
        inkLines: [(line([(80, -20), (96, -8), (86, 4), (100, 14)]), 4)],
        inkDots: [(CGPoint(x: -32, y: 22), 7, .darkNavy), (CGPoint(x: 32, y: 22), 7, .darkNavy),
                  (CGPoint(x: -11, y: -14), 5, .darkNavy), (CGPoint(x: 11, y: -14), 5, .darkNavy),
                  (CGPoint(x: -56, y: 0), 9, UIColor.coralRed.withAlphaComponent(0.6)),
                  (CGPoint(x: 56, y: 0), 9, UIColor.coralRed.withAlphaComponent(0.6))]
    )
    
    /// Ocean 1 — body, tail, two fins and a bubble.
    static let fish = Friend(
        name: "Fishy Friend", box: 240,
        regions: [
            FriendRegion(name: "tail",   path: polygon([(-60, 0), (-115, 48), (-115, -48)]), z: -1),
            FriendRegion(name: "fin-top", path: polygon([(-12, 46), (38, 46), (18, 88)]), z: -1),
            FriendRegion(name: "fin-bottom", path: polygon([(-6, -44), (32, -44), (12, -80)]), z: -1),
            FriendRegion(name: "body",   path: ellipse(14, 0, 156, 104)),
            FriendRegion(name: "bubble", path: circle(96, 66, 17))
        ],
        parts: [
            FriendPart(path: circle(112, 92, 9), fill: .white, lineWidth: 3)
        ],
        faces: [],
        inkLines: [(smile(58, -8, 16), 3.5)],
        inkDots: [(CGPoint(x: 62, y: 16), 8, .darkNavy),
                  (CGPoint(x: 78, y: -4), 8, UIColor.coralRed.withAlphaComponent(0.6))]
    )
    
    /// Ocean 2 — hull, two sails, flag and sun.
    static let boat = Friend(
        name: "Boaty Friend", box: 240,
        regions: [
            FriendRegion(name: "hull", path: polygon([(-104, -28), (104, -28), (78, -84), (-78, -84)])),
            FriendRegion(name: "sail-main", path: polygon([(8, -22), (8, 92), (84, -22)])),
            FriendRegion(name: "sail-jib",  path: polygon([(-8, -22), (-8, 76), (-72, -22)])),
            FriendRegion(name: "flag", path: polygon([(2, 108), (2, 84), (34, 96)])),
            FriendRegion(name: "sun",  path: circle(-92, 88, 24))
        ],
        parts: [
            FriendPart(path: roundedRect(0, 40, 8, 140, 4), fill: UIColor(hex: "#B5772E"), z: -1),
            FriendPart(path: ellipse(0, -96, 230, 24), fill: .skyBlue, stroke: .clear, z: -2)
        ],
        faces: [(CGPoint(x: 0, y: -56), 22, true)]
    )
    

    /// Forest / Garden — cap and stem; spots are fixed.
    static let mushroom = Friend(
        name: "Mushroom Friend", box: 230,
        regions: [
            FriendRegion(name: "stem", path: roundedRect(0, -48, 84, 112, 30), z: -1),
            FriendRegion(name: "cap",  path: ellipse(0, 42, 186, 116))
        ],
        parts: [
            FriendPart(path: circle(-50, 50, 16), fill: .white, lineWidth: 3, z: 1),
            FriendPart(path: circle(20, 66, 13), fill: .white, lineWidth: 3, z: 1),
            FriendPart(path: circle(62, 34, 11), fill: .white, lineWidth: 3, z: 1),
            FriendPart(path: circle(-14, 22, 9), fill: .white, lineWidth: 3, z: 1)
        ],
        faces: [(CGPoint(x: 0, y: -52), 24, true)]
    )
    
    /// Farm — body, wing and feet; beak and eye are fixed.
    static let chick = Friend(
        name: "Chick Friend", box: 230,
        regions: [
            FriendRegion(name: "foot-l", path: roundedRect(-28, -92, 34, 16, 8), z: -1),
            FriendRegion(name: "foot-r", path: roundedRect( 28, -92, 34, 16, 8), z: -1),
            FriendRegion(name: "body",   path: ellipse(0, -8, 150, 140)),
            FriendRegion(name: "wing",   path: ellipse(-50, -18, 56, 36, rotation: 0.5), z: 1),
            FriendRegion(name: "tuft",   path: ellipse(4, 72, 34, 26, rotation: 0.4), z: -1)
        ],
        parts: [
            FriendPart(path: polygon([(36, 4), (68, 14), (36, 26)]), fill: .coralRed, z: 2)
        ],
        faces: [],
        inkLines: [(line([(-24, -84), (-24, -66)]), 4), (line([(24, -84), (24, -66)]), 4)],
        inkDots: [(CGPoint(x: 22, y: 24), 7, .darkNavy), (CGPoint(x: 42, y: -8), 8, UIColor.coralRed.withAlphaComponent(0.6))]
    )
    
    /// Ocean — body, tail, fin and spout.
    static let whale = Friend(
        name: "Whale Friend", box: 250,
        regions: [
            FriendRegion(name: "tail",  path: polygon([(68, -6), (120, 36), (122, -34)]), z: -1),
            FriendRegion(name: "fin",   path: ellipse(-6, -50, 66, 30, rotation: -0.25), z: 1),
            FriendRegion(name: "body",  path: ellipse(-12, -8, 184, 112)),
            FriendRegion(name: "spout", path: circle(-40, 84, 24))
        ],
        parts: [
            FriendPart(path: circle(-58, 60, 7), fill: .skyBlue, lineWidth: 2.5, z: -1),
            FriendPart(path: circle(-22, 60, 7), fill: .skyBlue, lineWidth: 2.5, z: -1),
            FriendPart(path: ellipse(-12, -40, 150, 40), fill: UIColor.white.withAlphaComponent(0.35), stroke: .clear, z: 1)
        ],
        faces: [],
        inkLines: [(smile(-48, -14, 16), 3.5), (line([(-40, 48), (-40, 60)]), 3)],
        inkDots: [(CGPoint(x: -66, y: 10), 8, .darkNavy), (CGPoint(x: -84, y: -14), 8, UIColor.coralRed.withAlphaComponent(0.6))]
    )
    
    /// Sky — core plus eight rays.
    static let sun: Friend = {
        var regions: [FriendRegion] = []
        for i in 0..<8 {
            let a = CGFloat(i) / 8 * .pi * 2
            let tip = CGPoint(x: cos(a) * 112, y: sin(a) * 112)
            let baseAngle = a + .pi / 2
            let b1 = CGPoint(x: cos(a) * 66 + cos(baseAngle) * 16, y: sin(a) * 66 + sin(baseAngle) * 16)
            let b2 = CGPoint(x: cos(a) * 66 - cos(baseAngle) * 16, y: sin(a) * 66 - sin(baseAngle) * 16)
            regions.append(FriendRegion(name: "ray-\(i)", path: polygon([(b1.x, b1.y), (tip.x, tip.y), (b2.x, b2.y)]), z: -1))
        }
        regions.append(FriendRegion(name: "core", path: circle(0, 0, 64)))
        return Friend(name: "Sunny Friend", box: 240, regions: regions, parts: [],
                      faces: [(CGPoint(x: 0, y: 0), 64, true)])
    }()
    
    /// Sky — envelope, basket and two clouds.
    static let balloon = Friend(
        name: "Balloon Friend", box: 240,
        regions: [
            FriendRegion(name: "cloud-l",  path: circle(-88, 78, 22), z: -2),
            FriendRegion(name: "cloud-r",  path: circle(90, -20, 18), z: -2),
            FriendRegion(name: "envelope", path: ellipse(0, 40, 140, 160)),
            FriendRegion(name: "basket",   path: roundedRect(0, -84, 58, 40, 10))
        ],
        parts: [
            FriendPart(path: ellipse(0, 40, 46, 160), fill: UIColor.white.withAlphaComponent(0.35), stroke: .clear, z: 1)
        ],
        faces: [(CGPoint(x: 0, y: 46), 32, true)],
        inkLines: [(line([(-28, -34), (-20, -64)]), 3.5), (line([(28, -34), (20, -64)]), 3.5)]
    )
    
    /// Garden — two wings and a head; spots and legs are fixed.
    static let ladybug = Friend(
        name: "Ladybug Friend", box: 230,
        regions: [
            FriendRegion(name: "wing-l", path: ellipse(-38, -14, 84, 124)),
            FriendRegion(name: "wing-r", path: ellipse( 38, -14, 84, 124)),
            FriendRegion(name: "head",   path: circle(0, 58, 40), z: 1)
        ],
        parts: [
            FriendPart(path: circle(-44, 4, 14), fill: .darkNavy, stroke: .clear, z: 1),
            FriendPart(path: circle( 44, 4, 14), fill: .darkNavy, stroke: .clear, z: 1),
            FriendPart(path: circle(-30, -48, 10), fill: .darkNavy, stroke: .clear, z: 1),
            FriendPart(path: circle( 30, -48, 10), fill: .darkNavy, stroke: .clear, z: 1)
        ],
        faces: [(CGPoint(x: 0, y: 56), 30, true)],
        inkLines: [(line([(0, 20), (0, -74)]), 3.5),
                   (line([(-14, 92), (-26, 112)]), 3.5), (line([(14, 92), (26, 112)]), 3.5),
                   (line([(-76, -30), (-100, -42)]), 4), (line([(76, -30), (100, -42)]), 4),
                   (line([(-70, -60), (-92, -80)]), 4), (line([(70, -60), (92, -80)]), 4)],
        inkDots: [(CGPoint(x: -28, y: 114), 5, .coralRed), (CGPoint(x: 28, y: 114), 5, .coralRed)]
    )
    
    /// Sky — body, nose cone, two fins and a porthole; flame is fixed.
    static let rocket = Friend(
        name: "Rocket Friend", box: 250,
        regions: [
            FriendRegion(name: "fin-l",  path: polygon([(-40, -36), (-78, -92), (-40, -78)]), z: -1),
            FriendRegion(name: "fin-r",  path: polygon([( 40, -36), ( 78, -92), ( 40, -78)]), z: -1),
            FriendRegion(name: "body",   path: roundedRect(0, 8, 82, 176, 40)),
            FriendRegion(name: "nose",   path: polygon([(-41, 88), (0, 136), (41, 88)])),
            FriendRegion(name: "window", path: circle(0, 40, 24), z: 1)
        ],
        parts: [
            FriendPart(path: ellipse(0, -102, 44, 54), fill: .coralRed, z: -2),
            FriendPart(path: ellipse(0, -96, 22, 32), fill: .sunshineYellow, z: -2)
        ],
        faces: [(CGPoint(x: 0, y: 40), 19, false)]
    )

    private static func smile(_ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat) -> CGPath {
        let p = CGMutablePath()
        p.addArc(center: CGPoint(x: cx, y: cy), radius: r, startAngle: .pi * 1.15, endAngle: .pi * 1.85, clockwise: false)
        return p
    }
}
