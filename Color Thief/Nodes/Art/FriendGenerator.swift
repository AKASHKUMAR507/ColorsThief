import SpriteKit

/// Deterministic RNG so a level's friend is the same every time (seed = level id).
struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64
    init(seed: Int) { state = UInt64(bitPattern: Int64(seed)) &* 0x9E37_79B9_7F4A_7C15 | 1 }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

/// Procedural colouring-book friends. Each category composes a character from
/// randomised parts (shapes, counts, patterns) so every level looks different.
enum FriendGenerator {
    
    enum Category: String, CaseIterable {
        case fish, animal, house, car, tree, sky
    }
    
    static func make(category: Category, seed: Int) -> Friend {
        var rng = SeededRNG(seed: seed &* 7919 &+ category.rawValue.hashValue % 1000)
        switch category {
        case .fish:   return fish(&rng)
        case .animal: return animal(&rng)
        case .house:  return house(&rng)
        case .car:    return car(&rng)
        case .tree:   return tree(&rng)
        case .sky:    return sky(&rng)
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
    private static func rrect(_ cx: CGFloat, _ cy: CGFloat, _ w: CGFloat, _ h: CGFloat, _ r: CGFloat) -> CGPath {
        CGPath(roundedRect: CGRect(x: cx - w / 2, y: cy - h / 2, width: w, height: h),
               cornerWidth: min(r, w / 2), cornerHeight: min(r, h / 2), transform: nil)
    }
    private static func poly(_ pts: [(CGFloat, CGFloat)]) -> CGPath {
        let p = CGMutablePath()
        for (i, pt) in pts.enumerated() { i == 0 ? p.move(to: CGPoint(x: pt.0, y: pt.1)) : p.addLine(to: CGPoint(x: pt.0, y: pt.1)) }
        p.closeSubpath()
        return p
    }
    private static func line(_ pts: [(CGFloat, CGFloat)]) -> CGPath {
        let p = CGMutablePath()
        for (i, pt) in pts.enumerated() { i == 0 ? p.move(to: CGPoint(x: pt.0, y: pt.1)) : p.addLine(to: CGPoint(x: pt.0, y: pt.1)) }
        return p
    }
    private static func arc(_ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat, _ a0: CGFloat, _ a1: CGFloat) -> CGPath {
        let p = CGMutablePath()
        p.addArc(center: CGPoint(x: cx, y: cy), radius: r, startAngle: a0, endAngle: a1, clockwise: false)
        return p
    }
    /// A stroked arc turned into a fillable band (used for rainbows and curly tails).
    private static func band(_ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat, width: CGFloat, _ a0: CGFloat, _ a1: CGFloat) -> CGPath {
        arc(cx, cy, r, a0, a1).copy(strokingWithWidth: width, lineCap: .butt, lineJoin: .round, miterLimit: 1)
    }
    /// Clip `path` to `mask` (iOS 16 path booleans) — stripes and patches that stay inside a body.
    private static func clip(_ path: CGPath, to mask: CGPath) -> CGPath {
        path.intersection(mask, using: .winding)
    }
    
    private static func pick<T>(_ options: [T], _ rng: inout SeededRNG) -> T {
        options[Int(rng.next() % UInt64(options.count))]
    }
    private static func chance(_ p: Double, _ rng: inout SeededRNG) -> Bool {
        Double(rng.next() % 1000) / 1000 < p
    }
    private static func range(_ lo: CGFloat, _ hi: CGFloat, _ rng: inout SeededRNG) -> CGFloat {
        lo + (hi - lo) * CGFloat(rng.next() % 1000) / 1000
    }
    
    // MARK: - Fish
    
    private static func fish(_ rng: inout SeededRNG) -> Friend {
        let bw = range(130, 175, &rng), bh = range(80, 120, &rng)
        let cx: CGFloat = 12, cy: CGFloat = 0
        let bodyShape = pick(["round", "long", "puffer"], &rng)
        let body: CGPath = {
            switch bodyShape {
            case "long":   return ellipse(cx, cy, bw * 1.15, bh * 0.8)
            case "puffer": return circle(cx, cy, bh * 0.62)
            default:       return ellipse(cx, cy, bw, bh)
            }
        }()
        let bodyBox = body.boundingBox
        let left = bodyBox.minX, right = bodyBox.maxX, top = bodyBox.maxY, bottom = bodyBox.minY
        
        var regions: [FriendRegion] = []
        var parts: [FriendPart] = []
        var ink: [(CGPath, CGFloat)] = []
        var dots: [(CGPoint, CGFloat, UIColor)] = []
        
        // Tail
        let tailStyle = pick(["triangle", "fan", "fork"], &rng)
        let tx = left + 8
        switch tailStyle {
        case "fan":
            regions.append(FriendRegion(name: "tail-top", path: poly([(tx, 0), (tx - 52, 52), (tx - 40, 4)]), z: -1))
            regions.append(FriendRegion(name: "tail-bottom", path: poly([(tx, 0), (tx - 52, -52), (tx - 40, -4)]), z: -1))
        case "fork":
            regions.append(FriendRegion(name: "tail", path: poly([(tx, 0), (tx - 56, 48), (tx - 34, 0), (tx - 56, -48)]), z: -1))
        default:
            regions.append(FriendRegion(name: "tail", path: poly([(tx, 0), (tx - 54, 46), (tx - 54, -46)]), z: -1))
        }
        
        // Fins
        let finX = range(cx - 30, cx + 20, &rng)
        regions.append(FriendRegion(name: "fin-top", path: poly([(finX - 28, top - 8), (finX + 30, top - 8), (finX + 6, top + 48)]), z: -1))
        if chance(0.7, &rng) {
            regions.append(FriendRegion(name: "fin-bottom", path: poly([(finX - 18, bottom + 8), (finX + 28, bottom + 8), (finX + 4, bottom - 40)]), z: -1))
        }
        if chance(0.5, &rng) {   // side fin on the body
            regions.append(FriendRegion(name: "fin-side", path: ellipse(cx - 20, cy - 8, 40, 22, rotation: -0.5), z: 2))
        }
        
        regions.append(FriendRegion(name: "body", path: body))
        
        // Pattern
        let pattern = pick(["stripes", "spots", "plain", "stripes"], &rng)
        if pattern == "stripes" {
            let n = Int(rng.next() % 3) + 1
            for i in 0..<n {
                let x = left + (right - left) * (CGFloat(i) + 1) / CGFloat(n + 2) + 10
                let stripe = clip(rrect(x, cy, 18, bh * 1.2, 9), to: body)
                regions.append(FriendRegion(name: "stripe-\(i)", path: stripe, z: 1))
            }
        } else if pattern == "spots" {
            let n = Int(rng.next() % 2) + 2
            for i in 0..<n {
                let x = left + (right - left) * (CGFloat(i) + 1) / CGFloat(n + 1) - 10, y = range(bottom + 26, top - 26, &rng)
                regions.append(FriendRegion(name: "spot-\(i)", path: clip(circle(x, y, range(14, 20, &rng)), to: body), z: 1))
            }
        }
        
        // Face (eye near the front)
        let ex = right - bw * 0.22, ey = cy + bh * 0.12
        dots.append((CGPoint(x: ex, y: ey), 8, .darkNavy))
        dots.append((CGPoint(x: ex - 3, y: ey + 3), 3, .white))
        dots.append((CGPoint(x: ex + 14, y: ey - 18), 8, UIColor.coralRed.withAlphaComponent(0.55)))
        ink.append((arc(ex - 8, ey - 14, 12, .pi * 1.15, .pi * 1.85), 3.5))
        if chance(0.4, &rng) {   // lips
            parts.append(FriendPart(path: ellipse(right - 4, cy - 6, 14, 20), fill: .coralRed, lineWidth: 3, z: 1))
        }
        
        // Bubbles
        let bubbles = Int(rng.next() % 3)
        for i in 0..<bubbles {
            let r = range(9, 17, &rng)
            regions.append(FriendRegion(name: "bubble-\(i)", path: circle(right + 10 + CGFloat(i) * 18, top + 10 + CGFloat(i) * 26, r)))
        }
        
        let adjective = pattern == "stripes" ? "Stripy" : pattern == "spots" ? "Spotty" : pick(["Happy", "Little", "Sunny", "Bubbly"], &rng)
        let noun = bodyShape == "puffer" ? "Puffer" : bodyShape == "long" ? "Fish" : pick(["Fish", "Goldfish", "Guppy"], &rng)
        return Friend(name: "\(adjective) \(noun) Friend", box: 260, regions: regions, parts: parts, faces: [],
                      inkLines: ink, inkDots: dots)
    }
    
    // MARK: - Animal (front-facing critter)
    
    private static func animal(_ rng: inout SeededRNG) -> Friend {
        struct Kind { let name: String; let ears: String; let tail: String; let snout: Bool; let whiskers: Bool }
        let kinds = [
            Kind(name: "Cat",   ears: "pointy", tail: "curl",  snout: false, whiskers: true),
            Kind(name: "Dog",   ears: "floppy", tail: "short", snout: true,  whiskers: false),
            Kind(name: "Bunny", ears: "long",   tail: "puff",  snout: false, whiskers: true),
            Kind(name: "Bear",  ears: "round",  tail: "none",  snout: true,  whiskers: false),
            Kind(name: "Fox",   ears: "pointy", tail: "bushy", snout: true,  whiskers: true),
            Kind(name: "Mouse", ears: "round",  tail: "curl",  snout: false, whiskers: true),
            Kind(name: "Cow",   ears: "floppy", tail: "short", snout: true,  whiskers: false),
            Kind(name: "Panda", ears: "round",  tail: "none",  snout: false, whiskers: false)
        ]
        let kind = pick(kinds, &rng)
        let headR = range(44, 54, &rng)
        let headY: CGFloat = 52
        let bodyW = range(120, 150, &rng), bodyH = range(96, 116, &rng)
        let bodyY: CGFloat = -44
        
        var regions: [FriendRegion] = []
        var parts: [FriendPart] = []
        var ink: [(CGPath, CGFloat)] = []
        var dots: [(CGPoint, CGFloat, UIColor)] = []
        
        // Tail (behind)
        switch kind.tail {
        case "curl":  regions.append(FriendRegion(name: "tail", path: band(78, -30, 30, width: 16, -.pi * 0.5, .pi * 0.6), z: -2))
        case "bushy": regions.append(FriendRegion(name: "tail", path: ellipse(84, -46, 50, 90, rotation: -0.5), z: -2))
        case "puff":  regions.append(FriendRegion(name: "tail", path: circle(72, -70, 20), z: -2))
        case "short": regions.append(FriendRegion(name: "tail", path: ellipse(78, -60, 22, 44, rotation: -0.6), z: -2))
        default: break
        }
        
        // Ears (behind head)
        let ex = headR * 0.72, ey = headY + headR * 0.72
        switch kind.ears {
        case "pointy":
            regions.append(FriendRegion(name: "ear-l", path: poly([(-ex - 18, ey - 14), (-ex + 2, ey + 42), (-ex + 24, ey - 6)]), z: -1))
            regions.append(FriendRegion(name: "ear-r", path: poly([( ex + 18, ey - 14), ( ex - 2, ey + 42), ( ex - 24, ey - 6)]), z: -1))
        case "long":
            regions.append(FriendRegion(name: "ear-l", path: ellipse(-ex + 6, ey + 40, 30, 90, rotation: 0.15), z: -1))
            regions.append(FriendRegion(name: "ear-r", path: ellipse( ex - 6, ey + 40, 30, 90, rotation: -0.15), z: -1))
        case "floppy":
            regions.append(FriendRegion(name: "ear-l", path: ellipse(-ex - 20, headY - 4, 34, 74, rotation: 0.25), z: -1))
            regions.append(FriendRegion(name: "ear-r", path: ellipse( ex + 20, headY - 4, 34, 74, rotation: -0.25), z: -1))
        default:
            regions.append(FriendRegion(name: "ear-l", path: circle(-ex - 6, ey + 6, 22), z: -1))
            regions.append(FriendRegion(name: "ear-r", path: circle( ex + 6, ey + 6, 22), z: -1))
        }
        
        // Body, legs, head
        regions.append(FriendRegion(name: "leg-l", path: ellipse(-bodyW * 0.32, bodyY - bodyH * 0.42, 40, 34), z: 1))
        regions.append(FriendRegion(name: "leg-r", path: ellipse( bodyW * 0.32, bodyY - bodyH * 0.42, 40, 34), z: 1))
        regions.append(FriendRegion(name: "body", path: ellipse(0, bodyY, bodyW, bodyH)))
        if chance(0.6, &rng) {
            regions.append(FriendRegion(name: "belly", path: ellipse(0, bodyY - 8, bodyW * 0.5, bodyH * 0.6), z: 1))
        }
        regions.append(FriendRegion(name: "head", path: circle(0, headY, headR), z: 2))
        
        // Pattern
        let pattern = pick(["plain", "spots", "plain", "patch"], &rng)
        if pattern == "spots" {
            for i in 0..<3 {
                let x = range(-bodyW * 0.4, bodyW * 0.4, &rng), y = range(bodyY - bodyH * 0.3, bodyY + bodyH * 0.35, &rng)
                parts.append(FriendPart(path: clip(circle(x, y, range(8, 13, &rng)), to: ellipse(0, bodyY, bodyW, bodyH)), fill: .darkNavy, stroke: .clear, z: 2))
            }
        } else if pattern == "patch" {
            regions.append(FriendRegion(name: "patch", path: clip(circle(headR * 0.45, headY + headR * 0.25, headR * 0.42), to: circle(0, headY, headR)), z: 3))
        }
        
        // Face
        let eyeY = headY + headR * 0.12
        dots.append((CGPoint(x: -headR * 0.36, y: eyeY), 7, .darkNavy))
        dots.append((CGPoint(x:  headR * 0.36, y: eyeY), 7, .darkNavy))
        dots.append((CGPoint(x: -headR * 0.62, y: headY - headR * 0.2), 8, UIColor.coralRed.withAlphaComponent(0.55)))
        dots.append((CGPoint(x:  headR * 0.62, y: headY - headR * 0.2), 8, UIColor.coralRed.withAlphaComponent(0.55)))
        if kind.snout {
            parts.append(FriendPart(path: ellipse(0, headY - headR * 0.3, headR * 0.7, headR * 0.5), fill: .white, lineWidth: 3, z: 3))
            dots.append((CGPoint(x: 0, y: headY - headR * 0.16), 7, .darkNavy))
            ink.append((arc(0, headY - headR * 0.36, headR * 0.16, .pi * 1.15, .pi * 1.85), 3))
        } else {
            dots.append((CGPoint(x: 0, y: headY - headR * 0.16), 5, kind.name == "Bunny" ? .coralRed : .darkNavy))
            ink.append((arc(-headR * 0.12, headY - headR * 0.28, headR * 0.13, .pi * 1.1, .pi * 1.9), 3))
            ink.append((arc( headR * 0.12, headY - headR * 0.28, headR * 0.13, .pi * 1.1, .pi * 1.9), 3))
        }
        if kind.whiskers {
            for sx: CGFloat in [-1, 1] {
                ink.append((line([(sx * headR * 0.5, headY - headR * 0.22), (sx * (headR + 22), headY - headR * 0.12)]), 2.5))
                ink.append((line([(sx * headR * 0.5, headY - headR * 0.34), (sx * (headR + 22), headY - headR * 0.44)]), 2.5))
            }
        }
        if kind.name == "Panda" {
            parts.append(FriendPart(path: ellipse(-headR * 0.36, eyeY, headR * 0.42, headR * 0.5, rotation: 0.4), fill: .darkNavy, stroke: .clear, z: 3))
            parts.append(FriendPart(path: ellipse( headR * 0.36, eyeY, headR * 0.42, headR * 0.5, rotation: -0.4), fill: .darkNavy, stroke: .clear, z: 3))
            dots.append((CGPoint(x: -headR * 0.36, y: eyeY), 4, .white))
            dots.append((CGPoint(x:  headR * 0.36, y: eyeY), 4, .white))
        }
        
        let adjective = pattern == "spots" ? "Spotty" : pick(["Cuddly", "Happy", "Little", "Sleepy", "Bouncy"], &rng)
        return Friend(name: "\(adjective) \(kind.name) Friend", box: 250, regions: regions, parts: parts, faces: [],
                      inkLines: ink, inkDots: dots)
    }
    
    // MARK: - House
    
    private static func house(_ rng: inout SeededRNG) -> Friend {
        let w = range(130, 180, &rng), h = range(90, 120, &rng)
        let baseY: CGFloat = -50
        let roofStyle = pick(["triangle", "trapezoid", "dome"], &rng)
        var regions: [FriendRegion] = []
        var parts: [FriendPart] = []
        
        regions.append(FriendRegion(name: "walls", path: rrect(0, baseY, w, h, 8)))
        let roofBase = baseY + h / 2 - 4
        switch roofStyle {
        case "trapezoid":
            regions.append(FriendRegion(name: "roof", path: poly([(-w / 2 - 16, roofBase), (-w * 0.22, roofBase + 70), (w * 0.22, roofBase + 70), (w / 2 + 16, roofBase)])))
        case "dome":
            regions.append(FriendRegion(name: "roof", path: clip(ellipse(0, roofBase, w + 24, 130), to: rrect(0, roofBase + 40, w + 40, 80, 0))))
        default:
            regions.append(FriendRegion(name: "roof", path: poly([(-w / 2 - 16, roofBase), (0, roofBase + 84), (w / 2 + 16, roofBase)])))
        }
        // Door (face lives here)
        let doorX = pick([-w * 0.22, 0, w * 0.22], &rng)
        regions.append(FriendRegion(name: "door", path: rrect(doorX, baseY - h / 2 + 34, 46, 66, 16), z: 1))
        // Windows
        let winCount = Int(rng.next() % 3) + 1
        let winStyle = pick(["round", "square"], &rng)
        var placed: [CGFloat] = []
        for i in 0..<winCount {
            var x = range(-w * 0.36, w * 0.36, &rng)
            var tries = 0
            while (abs(x - doorX) < 46 || placed.contains(where: { abs($0 - x) < 44 })) && tries < 12 { x = range(-w * 0.36, w * 0.36, &rng); tries += 1 }
            if tries >= 12 { continue }
            placed.append(x)
            let y = baseY + h * 0.18
            let path = winStyle == "round" ? circle(x, y, 17) : rrect(x, y, 34, 34, 6)
            regions.append(FriendRegion(name: "window-\(i)", path: path, z: 1))
            parts.append(FriendPart(path: line([(x - 17, y), (x + 17, y)]), fill: .clear, lineWidth: 2.5, z: 2))
        }
        if chance(0.6, &rng) {
            regions.append(FriendRegion(name: "chimney", path: rrect(w * 0.28, roofBase + 40, 26, 50, 4), z: -1))
            parts.append(FriendPart(path: circle(w * 0.28, roofBase + 80, 12), fill: .white, lineWidth: 2.5, z: 1))
        }
        parts.append(FriendPart(path: ellipse(0, baseY - h / 2 - 4, w + 90, 22), fill: UIColor(hex: "#EFE4D2"), stroke: .clear, z: -3))
        
        let adjective = pick(["Cozy", "Sunny", "Little", "Happy", "Tiny"], &rng)
        let noun = roofStyle == "dome" ? "Cottage" : pick(["House", "Home", "Cabin"], &rng)
        return Friend(name: "\(adjective) \(noun) Friend", box: 250, regions: regions, parts: parts,
                      faces: [(CGPoint(x: doorX, y: baseY - h / 2 + 40), 18, true)])
    }
    
    // MARK: - Car
    
    private static func car(_ rng: inout SeededRNG) -> Friend {
        let type = pick(["car", "car", "bus", "truck", "van"], &rng)
        var regions: [FriendRegion] = []
        var parts: [FriendPart] = []
        let y: CGFloat = -30
        let wheelR: CGFloat = type == "truck" ? 26 : 24
        var faceAt = CGPoint(x: 0, y: 0)
        
        switch type {
        case "bus":
            regions.append(FriendRegion(name: "body", path: rrect(0, y + 20, 210, 110, 22)))
            for i in 0..<3 { regions.append(FriendRegion(name: "window-\(i)", path: rrect(-64 + CGFloat(i) * 64, y + 40, 44, 40, 8), z: 1)) }
            regions.append(FriendRegion(name: "wheel-l", path: circle(-68, y - 40, wheelR), z: -1))
            regions.append(FriendRegion(name: "wheel-r", path: circle( 68, y - 40, wheelR), z: -1))
            faceAt = CGPoint(x: 64, y: y + 40)
        case "truck":
            regions.append(FriendRegion(name: "cargo", path: rrect(-40, y + 22, 130, 96, 10)))
            regions.append(FriendRegion(name: "cab",   path: rrect(66, y + 4, 76, 62, 16)))
            regions.append(FriendRegion(name: "window", path: rrect(72, y + 12, 40, 30, 6), z: 1))
            regions.append(FriendRegion(name: "wheel-l", path: circle(-72, y - 40, wheelR), z: -1))
            regions.append(FriendRegion(name: "wheel-r", path: circle( 66, y - 40, wheelR), z: -1))
            faceAt = CGPoint(x: 92, y: y + 12)
        case "van":
            regions.append(FriendRegion(name: "body", path: rrect(0, y + 8, 200, 84, 24)))
            regions.append(FriendRegion(name: "roof", path: rrect(-10, y + 58, 150, 30, 12), z: -1))
            regions.append(FriendRegion(name: "window-l", path: rrect(-40, y + 20, 56, 34, 8), z: 1))
            regions.append(FriendRegion(name: "window-r", path: rrect( 40, y + 20, 56, 34, 8), z: 1))
            regions.append(FriendRegion(name: "wheel-l", path: circle(-66, y - 36, wheelR), z: -1))
            regions.append(FriendRegion(name: "wheel-r", path: circle( 66, y - 36, wheelR), z: -1))
            faceAt = CGPoint(x: 40, y: y + 20)
        default:
            regions.append(FriendRegion(name: "body", path: rrect(0, y, 200, 64, 24)))
            regions.append(FriendRegion(name: "cabin", path: poly([(-70, y + 28), (-40, y + 82), (50, y + 82), (78, y + 28)]), z: -1))
            regions.append(FriendRegion(name: "window", path: poly([(-50, y + 32), (-30, y + 70), (40, y + 70), (58, y + 32)]), z: 1))
            regions.append(FriendRegion(name: "wheel-l", path: circle(-62, y - 26, wheelR), z: 1))
            regions.append(FriendRegion(name: "wheel-r", path: circle( 62, y - 26, wheelR), z: 1))
            faceAt = CGPoint(x: 4, y: y + 50)
        }
        // Hubcaps + headlight
        for r in regions where r.name.hasPrefix("wheel") {
            let c = r.path.boundingBox
            parts.append(FriendPart(path: circle(c.midX, c.midY, wheelR * 0.4), fill: .white, lineWidth: 3, z: 2))
        }
        let bodyBox = regions.first { $0.name == "body" || $0.name == "cab" }!.path.boundingBox
        parts.append(FriendPart(path: circle(bodyBox.maxX - 8, bodyBox.midY - 6, 9), fill: .sunshineYellow, lineWidth: 2.5, z: 2))
        parts.append(FriendPart(path: ellipse(0, y - 62, 250, 18), fill: UIColor(hex: "#EFE4D2"), stroke: .clear, z: -3))
        
        let adjective = pick(["Zippy", "Little", "Speedy", "Happy", "Beep-Beep"], &rng)
        return Friend(name: "\(adjective) \(type.capitalized) Friend", box: 250, regions: regions, parts: parts,
                      faces: [(faceAt, 14, true)])
    }
    
    // MARK: - Tree
    
    private static func tree(_ rng: inout SeededRNG) -> Friend {
        let style = pick(["round", "cloud", "pine", "pine"], &rng)
        var regions: [FriendRegion] = []
        var parts: [FriendPart] = []
        let trunkW = range(30, 44, &rng)
        regions.append(FriendRegion(name: "trunk", path: rrect(0, -62, trunkW, 120, 10), z: -1))
        var fruitMask: CGPath? = nil
        switch style {
        case "cloud":
            let blobs: [(CGFloat, CGFloat, CGFloat)] = [(-46, 22, 50), (44, 26, 48), (0, 60, 56), (-14, 8, 44), (26, 0, 40)]
            for (i, b) in blobs.enumerated() { regions.append(FriendRegion(name: "leaf-\(i)", path: circle(b.0, b.1, b.2), z: i == 2 ? 1 : 0)) }
            fruitMask = circle(0, 30, 90)
        case "pine":
            let tiers = Int(rng.next() % 2) + 2
            for i in 0..<tiers {
                let yBase: CGFloat = -8 + CGFloat(i) * 46
                let halfW: CGFloat = 96 - CGFloat(i) * 22
                regions.append(FriendRegion(name: "tier-\(i)", path: poly([(-halfW, yBase), (halfW, yBase), (0, yBase + 76)]), z: CGFloat(i)))
            }
            if chance(0.5, &rng) { parts.append(FriendPart(path: circle(0, 22 + CGFloat(tiers) * 46, 12), fill: .sunshineYellow, lineWidth: 3, z: 5)) }
        default:
            let r = range(80, 96, &rng)
            regions.append(FriendRegion(name: "leaves", path: circle(0, 36, r)))
            fruitMask = circle(0, 36, r)
        }
        // Fruit
        var fruitName = ""
        if let mask = fruitMask, chance(0.7, &rng) {
            let n = Int(rng.next() % 3) + 2
            for i in 0..<n {
                let x = range(-60, 60, &rng), y = range(0, 80, &rng)
                regions.append(FriendRegion(name: "fruit-\(i)", path: clip(circle(x, y, 13), to: mask), z: 2))
            }
            fruitName = pick(["Apple", "Orange", "Cherry", "Peach"], &rng)
        }
        parts.append(FriendPart(path: ellipse(0, -124, 200, 20), fill: UIColor(hex: "#EFE4D2"), stroke: .clear, z: -3))
        
        let name = style == "pine" ? "Pine Tree" : fruitName.isEmpty ? pick(["Leafy Tree", "Happy Tree", "Big Tree"], &rng) : "\(fruitName) Tree"
        return Friend(name: "\(name) Friend", box: 250, regions: regions, parts: parts,
                      faces: [(CGPoint(x: 0, y: -66), 15, true)])
    }
    
    // MARK: - Sky
    
    private static func sky(_ rng: inout SeededRNG) -> Friend {
        let night = chance(0.3, &rng)
        var regions: [FriendRegion] = []
        var parts: [FriendPart] = []
        var ink: [(CGPath, CGFloat)] = []
        var faceAt = CGPoint(x: 0, y: 0)
        var faceR: CGFloat = 40
        
        if night {
            // Crescent moon (disc minus offset disc) + stars
            let moon = circle(-40, 40, 56).subtracting(circle(-14, 52, 48), using: .winding)
            regions.append(FriendRegion(name: "moon", path: moon))
            faceAt = CGPoint(x: -66, y: 34); faceR = 26
            // Stars in the upper-right, spread on a loose grid so they never overlap the moon or each other
            let n = Int(rng.next() % 2) + 3
            let slots: [(CGFloat, CGFloat)] = [(46, 96), (98, 70), (60, 30), (110, 10), (30, -6)]
            for i in 0..<n {
                let slot = slots[i]
                let cx = slot.0 + range(-8, 8, &rng), cy = slot.1 + range(-8, 8, &rng), r = range(16, 22, &rng)
                let star = CGMutablePath()
                for k in 0..<10 {
                    let a = CGFloat(k) * .pi / 5 - .pi / 2
                    let rr = k % 2 == 0 ? r : r * 0.45
                    let p = CGPoint(x: cx + cos(a) * rr, y: cy + sin(a) * rr)
                    k == 0 ? star.move(to: p) : star.addLine(to: p)
                }
                star.closeSubpath()
                regions.append(FriendRegion(name: "star-\(i)", path: star))
            }
        } else {
            // Sun (core region, rays fixed) top-left
            regions.append(FriendRegion(name: "sun", path: circle(-78, 92, 38)))
            for i in 0..<8 {
                let a = CGFloat(i) / 8 * .pi * 2
                parts.append(FriendPart(path: rrect(-78 + cos(a) * 54, 92 + sin(a) * 54, 7, 18, 3.5), fill: .sunshineYellow, lineWidth: 2.5, z: -1))
            }
            faceAt = CGPoint(x: -78, y: 92); faceR = 38
            if chance(0.6, &rng) {
                // Rainbow bands
                let bands = Int(rng.next() % 2) + 3
                for i in 0..<bands {
                    regions.append(FriendRegion(name: "rainbow-\(i)", path: band(36, -96, 100 - CGFloat(i) * 21, width: 19, 0.12, .pi - 0.12), z: -2))
                }
            }
        }
        // Clouds (2–3) along the bottom band, spaced out
        let clouds = Int(rng.next() % 2) + 2
        for i in 0..<clouds {
            let cx = -80 + CGFloat(i) * (170 / CGFloat(max(1, clouds - 1))) + range(-10, 10, &rng)
            let cy = range(-104, -66, &rng), s = range(20, 27, &rng)
            let cloud = ellipse(cx, cy, s * 3.2, s * 1.3).union(circle(cx - s * 0.6, cy + s * 0.3, s * 0.9), using: .winding)
                .union(circle(cx + s * 0.5, cy + s * 0.35, s * 0.8), using: .winding)
            regions.append(FriendRegion(name: "cloud-\(i)", path: cloud, z: 1))
        }
        // Birds
        if !night, chance(0.6, &rng) {
            for i in 0..<2 {
                let bx = range(20, 90, &rng), by = range(50, 100, &rng)
                ink.append((arc(bx - 10, by, 10, 0.3, .pi - 0.3), 3))
                ink.append((arc(bx + 10, by, 10, 0.3, .pi - 0.3), 3))
                _ = i
            }
        }
        let name = night ? pick(["Starry Night", "Moonlight", "Sleepy Sky"], &rng) : pick(["Sunny Sky", "Rainbow Sky", "Happy Sky"], &rng)
        return Friend(name: "\(name) Friend", box: 260, regions: regions, parts: parts,
                      faces: [(faceAt, faceR, true)], inkLines: ink)
    }
}
