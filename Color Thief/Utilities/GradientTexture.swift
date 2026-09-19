import SpriteKit

extension SKTexture {
    /// Vertical gradient texture, `top` colour at the top edge.
    static func verticalGradient(size: CGSize, top: UIColor, bottom: UIColor) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let space  = CGColorSpaceCreateDeviceRGB()
            let colors = [top.cgColor, bottom.cgColor] as CFArray
            guard let gradient = CGGradient(colorsSpace: space, colors: colors, locations: [0, 1]) else { return }
            ctx.cgContext.drawLinearGradient(gradient,
                                             start: .zero,
                                             end: CGPoint(x: 0, y: size.height),
                                             options: [])
        }
        return SKTexture(image: image)
    }

    /// Horizontal gradient texture, `left` colour at the left edge.
    static func horizontalGradient(size: CGSize, left: UIColor, right: UIColor) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let space  = CGColorSpaceCreateDeviceRGB()
            let colors = [left.cgColor, right.cgColor] as CFArray
            guard let gradient = CGGradient(colorsSpace: space, colors: colors, locations: [0, 1]) else { return }
            ctx.cgContext.drawLinearGradient(gradient,
                                             start: .zero,
                                             end: CGPoint(x: size.width, y: 0),
                                             options: [])
        }
        return SKTexture(image: image)
    }
    
    /// Storybook polka-dot paper: `background` with a staggered grid of `dot` circles.
    static func polkaDots(size: CGSize,
                          background: UIColor,
                          dot: UIColor,
                          spacing: CGFloat = 28,
                          radius: CGFloat = 3) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            cg.setFillColor(background.cgColor)
            cg.fill(CGRect(origin: .zero, size: size))
            cg.setFillColor(dot.cgColor)
            var row = 0
            var y: CGFloat = spacing / 2
            while y < size.height {
                var x: CGFloat = row % 2 == 0 ? spacing / 2 : spacing
                while x < size.width {
                    cg.fillEllipse(in: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2))
                    x += spacing
                }
                y += spacing
                row += 1
            }
        }
        return SKTexture(image: image)
    }
}
