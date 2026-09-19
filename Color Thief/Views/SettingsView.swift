import SwiftUI

/// Sound FX · Music · Vibration · Parent Zone, persisted in UserDefaults. Sits behind the Parent Gate.
struct SettingsView: View {
    
    var onClose: () -> Void
    
    @AppStorage(UserDefaultsKeys.soundEnabled)     private var soundOn     = true
    @AppStorage(UserDefaultsKeys.musicEnabled)     private var musicOn     = true
    @AppStorage(UserDefaultsKeys.vibrationEnabled) private var vibrationOn = true
    @State private var showParentZone = false
    
    var body: some View {
        ZStack {
            PolkaDotBackground()
            
            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        gateCard
                        
                        toggleRow(icon: "speaker.wave.2.fill", tint: Color(uiColor: UIColor(hex: "#FFF3B0")),
                                  title: "Sound Effects", subtitle: "Taps, pops, and squishes",
                                  isOn: $soundOn, toggleTint: .sunshineYellow)
                        toggleRow(icon: "music.note", tint: Color(uiColor: UIColor(hex: "#D8FFF7")),
                                  title: "Music", subtitle: "Gentle happy tunes",
                                  isOn: $musicOn, toggleTint: .mintGreen)
                        toggleRow(icon: "iphone.radiowaves.left.and.right", tint: Color(uiColor: UIColor(hex: "#FFD6E7")),
                                  title: "Vibration", subtitle: "Bouncy tap feedback",
                                  isOn: $vibrationOn, toggleTint: .sunshineYellow)
                        
                        parentZoneRow
                        
                        footer
                            .padding(.top, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 22)
                    .padding(.bottom, 30)
                }
            }
        }
        .fullScreenCover(isPresented: $showParentZone) {
            ParentZoneView(onClose: { showParentZone = false })
        }
    }
    
    // MARK: - Pieces
    
    private var header: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "chevron.left").font(.system(size: 20, weight: .heavy)).foregroundColor(.darkNavy)
                    .frame(width: 52, height: 52)
            }
            .buttonStyle(ChunkyButtonStyle(fill: .white, lipHeight: 5, cornerRadius: 18, hPad: 0, minHeight: 52))
            
            Spacer()
            
            HStack(spacing: 10) {
                Text("SETTINGS").font(AppFont.headline(30)).foregroundColor(.darkNavy)
                Circle().fill(Color.sunshineYellow).overlay(Circle().stroke(Color.darkNavy, lineWidth: 2.5)).frame(width: 18)
            }
            
            Spacer()
            
            // Avatar sticker (decorative)
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.mintGreen)
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.darkNavy, lineWidth: 3))
                .overlay(
                    VStack(spacing: 5) {
                        HStack(spacing: 10) {
                            Circle().fill(Color.darkNavy).frame(width: 6)
                            Circle().fill(Color.darkNavy).frame(width: 6)
                        }
                        Capsule().fill(Color.darkNavy).frame(width: 14, height: 4)
                    }
                )
                .frame(width: 52, height: 52)
        }
    }
    
    private var gateCard: some View {
        HStack(spacing: 14) {
            IconTile(systemName: "lock.fill", tint: .skyBlue, glyph: .darkNavy)
                .overlay(Circle().fill(Color.sunshineYellow).overlay(Circle().stroke(Color.darkNavy, lineWidth: 2)).frame(width: 14).offset(x: 20, y: -20))
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("Adults Only").font(AppFont.headline(21)).foregroundColor(.darkNavy)
                    Text("GATE").font(AppFont.headline(11)).foregroundColor(.darkNavy)
                        .padding(.horizontal, 9).padding(.vertical, 4)
                        .background(Capsule().fill(Color.sunshineYellow).overlay(Capsule().stroke(Color.darkNavy, lineWidth: 2)))
                }
                Text("Quiet sound and vibration controls for playtime")
                    .font(AppFont.body(14)).foregroundColor(.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(18)
        .stickerCard(cornerRadius: 30)
    }
    
    private func toggleRow(icon: String, tint: Color, title: String, subtitle: String,
                           isOn: Binding<Bool>, toggleTint: Color) -> some View {
        HStack(spacing: 14) {
            IconTile(systemName: icon, tint: tint)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(AppFont.headline(21)).foregroundColor(.darkNavy)
                Text(subtitle).font(AppFont.body(14)).foregroundColor(.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            ChunkyToggle(isOn: isOn, tint: toggleTint)
        }
        .padding(18)
        .stickerCard(cornerRadius: 30)
    }
    
    private var parentZoneRow: some View {
        Button { showParentZone = true } label: {
            HStack(spacing: 14) {
                IconTile(systemName: "person.2.fill", tint: Color(uiColor: UIColor(hex: "#E2DEFF")))
                VStack(alignment: .leading, spacing: 3) {
                    Text("Parent Zone").font(AppFont.headline(21)).foregroundColor(.darkNavy)
                    Text("Purchases, limits & profiles").font(AppFont.body(14)).foregroundColor(.inkMuted)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right").font(.system(size: 18, weight: .heavy)).foregroundColor(.darkNavy)
                    .frame(width: 48, height: 48)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.warmCream)
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.darkNavy, lineWidth: 3)))
            }
            .padding(18)
        }
        .buttonStyle(.plain)
        .stickerCard(cornerRadius: 30)
    }
    
    private var footer: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Circle().fill(Color.sunshineYellow).overlay(Circle().stroke(Color.darkNavy, lineWidth: 2)).frame(width: 10)
                Text("COLOR THIEF V\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                    .font(AppFont.headline(14)).foregroundColor(.darkNavy)
            }
            .padding(.horizontal, 18).padding(.vertical, 10)
            .background(Capsule().fill(Color.white).overlay(Capsule().stroke(Color.darkNavy, lineWidth: 2.5)))
            
            Text("MADE WITH JOY & CARE FOR LITTLE ARTISTS")
                .font(AppFont.body(12)).tracking(0.5).foregroundColor(.inkMuted)
            
            Link(destination: AppConfig.websiteURL) {
                HStack(spacing: 6) {
                    Image(systemName: "safari.fill").font(.system(size: 12, weight: .bold))
                    Text(AppConfig.websiteURL.host ?? "Website").font(AppFont.body(13))
                }
                .foregroundColor(.darkNavy)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(Capsule().fill(Color.white).overlay(Capsule().stroke(Color.darkNavy, lineWidth: 2)))
            }
        }
    }
}
