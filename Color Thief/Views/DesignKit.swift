import SwiftUI

// MARK: - Tokens

extension Color {
    static let sunshineYellow = Color(uiColor: .sunshineYellow)
    static let skyBlue        = Color(uiColor: .skyBlue)
    static let grassGreen     = Color(uiColor: .grassGreen)
    static let coralRed       = Color(uiColor: .coralRed)
    static let hotPink        = Color(uiColor: .hotPink)
    static let lavender       = Color(uiColor: .lavender)
    static let mintGreen      = Color(uiColor: .mintGreen)
    static let skyGrey        = Color(uiColor: .skyGrey)
    static let darkNavy       = Color(uiColor: .darkNavy)
    static let warmCream      = Color(uiColor: .warmCream)
    static let inkMuted       = Color(uiColor: .darkNavy).opacity(0.6)
    static let paleTrack      = Color(uiColor: UIColor(hex: "#E4E0D6"))
}

enum AppFont {
    static func headline(_ size: CGFloat) -> Font { .custom(AppFonts.headline, size: size) }
    static func body(_ size: CGFloat) -> Font { .custom(AppFonts.body, size: size) }
}

// MARK: - Polka-dot paper background

struct PolkaDotBackground: View {
    var body: some View {
        Canvas { ctx, size in
            ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.warmCream))
            let spacing: CGFloat = 28, r: CGFloat = 3
            var row = 0
            var y: CGFloat = spacing / 2
            while y < size.height {
                var x: CGFloat = row % 2 == 0 ? spacing / 2 : spacing
                while x < size.width {
                    ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                             with: .color(Color(uiColor: UIColor(hex: "#FFE9B8"))))
                    x += spacing
                }
                y += spacing
                row += 1
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Sticker card

struct StickerCardModifier: ViewModifier {
    var fill: Color = .white
    var cornerRadius: CGFloat = 28
    var lineWidth: CGFloat = 4
    var shadowOffset: CGFloat = 6
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.darkNavy)
                        .offset(y: shadowOffset)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(fill)
                        .overlay(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.darkNavy, lineWidth: lineWidth))
                }
            )
            .padding(.bottom, shadowOffset)
    }
}

extension View {
    func stickerCard(fill: Color = .white, cornerRadius: CGFloat = 28, lineWidth: CGFloat = 4, shadowOffset: CGFloat = 6) -> some View {
        modifier(StickerCardModifier(fill: fill, cornerRadius: cornerRadius, lineWidth: lineWidth, shadowOffset: shadowOffset))
    }
}

// MARK: - Chunky button (3D lip, presses down)

struct ChunkyButtonStyle: ButtonStyle {
    var fill: Color
    var lip: Color = .darkNavy
    var stroke: Color = .darkNavy
    var lipHeight: CGFloat = 6
    var lineWidth: CGFloat = 3
    var cornerRadius: CGFloat? = nil   // nil = capsule
    var hPad: CGFloat = 20
    var minHeight: CGFloat = 52
    
    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        configuration.label
            .padding(.horizontal, hPad)
            .frame(minHeight: minHeight)
            .background(
                ZStack {
                    shape.fill(lip)
                        .overlay(shape.stroke(stroke, lineWidth: lineWidth))
                        .offset(y: lipHeight)
                    shape.fill(fill)
                        .overlay(shape.stroke(stroke, lineWidth: lineWidth))
                }
            )
            .offset(y: pressed ? lipHeight - 2 : 0)
            .padding(.bottom, lipHeight)
            .animation(.easeOut(duration: 0.08), value: pressed)
    }
    
    private var shape: AnyShape {
        if let r = cornerRadius { return AnyShape(RoundedRectangle(cornerRadius: r, style: .continuous)) }
        return AnyShape(Capsule())
    }
}

// MARK: - Chunky toggle

struct ChunkyToggle: View {
    @Binding var isOn: Bool
    var tint: Color = .sunshineYellow
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { isOn.toggle() }
            HapticManager.tap()
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .fill(isOn ? tint : Color.paleTrack)
                    .overlay(Capsule().stroke(Color.darkNavy, lineWidth: 3))
                    .frame(width: 66, height: 36)
                Circle()
                    .fill(Color.white)
                    .overlay(Circle().stroke(Color.darkNavy, lineWidth: 3))
                    .frame(width: 28, height: 28)
                    .padding(4)
            }
        }
        .buttonStyle(.plain)
        .accessibilityValue(isOn ? "On" : "Off")
    }
}

// MARK: - Icon tile (rounded square with a glyph)

struct IconTile: View {
    var systemName: String
    var tint: Color
    var glyph: Color = .darkNavy
    var size: CGFloat = 54
    
    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
            .fill(tint)
            .overlay(RoundedRectangle(cornerRadius: size * 0.3, style: .continuous).stroke(Color.darkNavy, lineWidth: 3))
            .overlay(Image(systemName: systemName).font(.system(size: size * 0.42, weight: .heavy)).foregroundColor(glyph))
            .frame(width: size, height: size)
    }
}

// MARK: - Shake effect (wrong answer)

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 12
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: amount * sin(animatableData * .pi * shakesPerUnit), y: 0))
    }
}
