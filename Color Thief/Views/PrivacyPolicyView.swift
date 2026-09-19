import SwiftUI

/// In-app privacy policy (Apple guideline 5.1.1: the policy must be easily accessible in the app).
/// The same text lives in docs/privacy.html for the public URL required by App Store Connect.
struct PrivacyPolicyView: View {
    
    var onClose: () -> Void
    
    private let effectiveDate = "19 September 2026"
    
    var body: some View {
        ZStack {
            PolkaDotBackground()
            VStack(spacing: 0) {
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "chevron.left").font(.system(size: 20, weight: .heavy)).foregroundColor(.darkNavy)
                            .frame(width: 52, height: 52)
                    }
                    .buttonStyle(ChunkyButtonStyle(fill: .white, lipHeight: 5, cornerRadius: 18, hPad: 0, minHeight: 52))
                    Spacer()
                    Text("PRIVACY").font(AppFont.headline(28)).foregroundColor(.darkNavy)
                    Spacer()
                    Color.clear.frame(width: 52, height: 52)
                }
                .padding(.horizontal, 20).padding(.top, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        summaryCard
                        ForEach(PrivacyPolicyText.sections, id: \.title) { section in
                            sectionCard(section)
                        }
                        Text("Effective \(effectiveDate) · © 2026 \(PrivacyPolicyText.publisher)")
                            .font(AppFont.body(12)).foregroundColor(.inkMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 30)
                }
            }
        }
    }
    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                IconTile(systemName: "checkmark.shield.fill", tint: .grassGreen, glyph: .white, size: 44)
                Text("The short version").font(AppFont.headline(21)).foregroundColor(.darkNavy)
            }
            Text(PrivacyPolicyText.summary)
                .font(AppFont.body(15)).foregroundColor(.darkNavy)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .stickerCard(fill: Color(uiColor: UIColor(hex: "#FFF3B0")), cornerRadius: 28)
    }
    
    private func sectionCard(_ section: PrivacyPolicyText.Section) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                IconTile(systemName: section.icon, tint: section.tint, size: 40)
                Text(section.title).font(AppFont.headline(19)).foregroundColor(.darkNavy)
            }
            ForEach(section.paragraphs, id: \.self) { p in
                if p.hasPrefix("• ") {
                    HStack(alignment: .top, spacing: 8) {
                        Circle().fill(Color.sunshineYellow).overlay(Circle().stroke(Color.darkNavy, lineWidth: 1.5)).frame(width: 8).padding(.top, 7)
                        Text(p.dropFirst(2)).font(AppFont.body(15)).foregroundColor(.darkNavy)
                    }
                    .padding(.leading, 4)
                } else {
                    Text(p).font(AppFont.body(15)).foregroundColor(.darkNavy)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .stickerCard(cornerRadius: 28)
    }
}

/// Single source of truth for the policy wording. Keep docs/privacy.html in sync when this changes.
enum PrivacyPolicyText {
    
    // TODO: fill these in before submission
    static let publisher    = "[Your name / studio]"
    static let supportEmail = AppConfig.supportEmail
    
    static let summary = "Color Thief does not collect, store, or share any personal information — from children or adults. There are no accounts, no ads, no analytics, and no tracking. Everything the game remembers stays on your device."
    
    struct Section {
        let icon: String
        let tint: Color
        let title: String
        let paragraphs: [String]
    }
    
    static let sections: [Section] = [
        Section(icon: "person.fill", tint: .skyBlue, title: "Who we are", paragraphs: [
            "Color Thief is a colouring game for young children (ages 2–6) published by \(publisher). This policy explains what the app does — and doesn't do — with information."
        ]),
        Section(icon: "hand.raised.fill", tint: .coralRed, title: "Information we collect", paragraphs: [
            "None. The app does not ask for a name, email, photo, location, contacts, or any other personal information, and it does not collect device identifiers.",
            "The app makes no network requests of its own; the only connection it uses is Apple's App Store, for purchases."
        ]),
        Section(icon: "iphone", tint: .lavender, title: "Stored on your device", paragraphs: [
            "To make the game work, it saves a small amount of data locally on the device only:",
            "• Game progress — levels completed, stars earned, colours restored",
            "• Settings — sound effects, music, and vibration on/off",
            "• Whether the Full Game unlock has been purchased",
            "This data never leaves the device, is not linked to you, and is deleted when the app is deleted."
        ]),
        Section(icon: "cart.fill", tint: .sunshineYellow, title: "In-app purchases", paragraphs: [
            "Color Thief offers one optional purchase (\"Full Game\") that unlocks additional levels. Purchases are processed entirely by Apple through the App Store; we never see or store payment details.",
            "Purchases sit behind a parental gate (a simple math question) so that they can only be completed by a grown-up."
        ]),
        Section(icon: "figure.and.child.holdinghands", tint: .mintGreen, title: "Children's privacy", paragraphs: [
            "Color Thief is designed for children and is offered in the Kids category of the App Store. In line with COPPA and similar laws, we do not knowingly collect personal information from anyone, including children under 13.",
            "The app contains no third-party SDKs, no advertising, no analytics, no social features, and no links to the open web outside the parent-gated settings area."
        ]),
        Section(icon: "lock.shield.fill", tint: .skyBlue, title: "Device permissions", paragraphs: [
            "The app does not request access to the camera, microphone, photos, location, contacts, notifications, or any other protected resource."
        ]),
        Section(icon: "arrow.triangle.2.circlepath", tint: .lavender, title: "Changes to this policy", paragraphs: [
            "If the app ever changes what it does with information, this page will be updated and the effective date will change. Continued use of the app after an update means you accept the revised policy."
        ]),
        Section(icon: "envelope.fill", tint: .coralRed, title: "Contact", paragraphs: [
            "Questions about this policy? Email \(supportEmail)."
        ])
    ]
}
