import SwiftUI

/// Purchases & policy. StoreKit wiring arrives in Phase 5; until then the buttons show status only.
struct ParentZoneView: View {
    
    var onClose: () -> Void
    @ObservedObject private var store = StoreKitManager.shared
    @State private var showPrivacy = false
    private var hasFullGame: Bool { store.hasFullGame }
    
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
                    Text("PARENT ZONE").font(AppFont.headline(28)).foregroundColor(.darkNavy)
                    Spacer()
                    Color.clear.frame(width: 52, height: 52)
                }
                .padding(.horizontal, 20).padding(.top, 8)
                
                VStack(spacing: 16) {
                    HStack(spacing: 14) {
                        IconTile(systemName: hasFullGame ? "star.fill" : "lock.open.fill", tint: Color(uiColor: UIColor(hex: "#FFF3B0")))
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Full Game").font(AppFont.headline(21)).foregroundColor(.darkNavy)
                            Text(hasFullGame ? "All worlds unlocked — thank you!" : "Levels 1–3 are free. Unlock all \(LevelData.all.count) levels.")
                                .font(AppFont.body(14)).foregroundColor(.inkMuted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(18)
                    .stickerCard(cornerRadius: 30)
                    
                    Button {
                        Task { await store.purchaseFullGame() }
                    } label: {
                        HStack(spacing: 10) {
                            if store.isBusy { ProgressView().tint(.darkNavy) }
                            Text(hasFullGame ? "UNLOCKED" : "UNLOCK FULL GAME · \(store.displayPrice)")
                                .font(AppFont.headline(19)).foregroundColor(.darkNavy)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ChunkyButtonStyle(fill: .sunshineYellow, lip: Color(uiColor: UIColor.sunshineYellow.darkened()), minHeight: 60))
                    .disabled(hasFullGame || store.isBusy)
                    .opacity(hasFullGame ? 0.6 : 1)
                    
                    Button {
                        Task { await store.restorePurchases() }
                    } label: {
                        Text("Restore Purchases").font(AppFont.body(16)).foregroundColor(.darkNavy)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ChunkyButtonStyle(fill: .white, lipHeight: 5, minHeight: 50))
                    .disabled(store.isBusy)
                    
                    if let error = store.lastError {
                        Text(error).font(AppFont.body(13)).foregroundColor(.coralRed)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button { showPrivacy = true } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "hand.raised.fill").font(.system(size: 14, weight: .bold))
                            Text("Privacy Policy").font(AppFont.body(16))
                        }
                        .foregroundColor(.darkNavy)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ChunkyButtonStyle(fill: .white, lipHeight: 5, minHeight: 50))
                    .padding(.top, 8)
                    
                    Link(destination: AppConfig.websiteURL) {
                        HStack(spacing: 8) {
                            Image(systemName: "safari.fill").font(.system(size: 14, weight: .bold))
                            Text("Visit Website").font(AppFont.body(16))
                            Image(systemName: "arrow.up.right").font(.system(size: 11, weight: .heavy)).opacity(0.6)
                        }
                        .foregroundColor(.darkNavy)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ChunkyButtonStyle(fill: .white, lipHeight: 5, minHeight: 50))
                }
                .padding(.horizontal, 20).padding(.top, 24)
                
                Spacer()
            }
        }
        .onAppear { store.lastError = nil }
        .fullScreenCover(isPresented: $showPrivacy) {
            PrivacyPolicyView(onClose: { showPrivacy = false })
        }
    }
}
