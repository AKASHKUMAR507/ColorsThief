import SwiftUI
import StoreKit
import SpriteKit

/// Offer → Parent Gate → Checkout. Shown after Level 3 (spec) and from premium level cards.
/// Purchases always go through the gate (App Store Kids category requirement).
struct PaywallView: View {
    
    var onClose: () -> Void
    var onUnlocked: () -> Void
    
    @ObservedObject private var store = StoreKitManager.shared
    @State private var step: Step
    
    enum Step { case offer, gate, checkout, unlocked }
    
    init(onClose: @escaping () -> Void, onUnlocked: @escaping () -> Void, initialStep: Step = .offer) {
        self.onClose = onClose
        self.onUnlocked = onUnlocked
        _step = State(initialValue: initialStep)
    }
    
    var body: some View {
        ZStack {
            PolkaDotBackground()
            switch step {
            case .offer:
                offer.transition(.opacity)
            case .gate:
                ParentGateView(onPass: { withAnimation { step = .checkout } },
                               onClose: { withAnimation { step = .offer } })
                    .transition(.opacity)
            case .checkout:
                checkout.transition(.move(edge: .trailing).combined(with: .opacity))
            case .unlocked:
                unlocked.transition(.scale.combined(with: .opacity))
            }
        }
        .onChange(of: store.hasFullGame) { owned in
            if owned && step != .unlocked { withAnimation { step = .unlocked } }
        }
    }
    
    // MARK: - Offer (child-facing)
    
    private var offer: some View {
        VStack(spacing: 0) {
            HStack {
                closeButton
                Spacer()
            }
            .padding(.horizontal, 20).padding(.top, 8)
            
            Spacer(minLength: 10)
            
            VStack(spacing: 18) {
                Image("LaunchLogo")
                    .resizable().scaledToFit()
                    .frame(height: 130)
                    .padding(.top, 6)
                
                Text("Unlock All Worlds!")
                    .font(AppFont.headline(30)).foregroundColor(.darkNavy)
                
                VStack(alignment: .leading, spacing: 10) {
                    feature("paintpalette.fill", tint: .sunshineYellow, "All \(LevelData.all.count) levels in \(LevelData.worldNames.count) worlds")
                    feature("face.smiling.fill", tint: .skyBlue, "New friends to color")
                    feature("star.fill", tint: .grassGreen, "One-time unlock, no ads ever")
                }
                .padding(.horizontal, 6)
                
                Button { withAnimation { step = .gate } } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "lock.fill").font(.system(size: 16, weight: .heavy))
                        Text("ASK A GROWN-UP").font(AppFont.headline(20))
                    }
                    .foregroundColor(.darkNavy)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(ChunkyButtonStyle(fill: .sunshineYellow, lip: Color(uiColor: UIColor.sunshineYellow.darkened()), minHeight: 62))
                .padding(.top, 6)
                
                Button(action: onClose) {
                    Text("Maybe later").font(AppFont.body(16)).foregroundColor(.darkNavy)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(ChunkyButtonStyle(fill: .white, lipHeight: 5, minHeight: 48))
            }
            .padding(.horizontal, 22).padding(.vertical, 26)
            .stickerCard(cornerRadius: 36, shadowOffset: 8)
            .padding(.horizontal, 22)
            
            Spacer(minLength: 20)
            
            Text("Levels 1–\(LevelData.freeLevelCount) are always free.")
                .font(AppFont.body(13)).foregroundColor(.inkMuted)
                .padding(.bottom, 10)
        }
    }
    
    private func feature(_ icon: String, tint: Color, _ text: String) -> some View {
        HStack(spacing: 12) {
            IconTile(systemName: icon, tint: tint, size: 40)
            Text(text).font(AppFont.body(16)).foregroundColor(.darkNavy)
            Spacer(minLength: 0)
        }
    }
    
    // MARK: - Checkout (adult-facing)
    
    private var checkout: some View {
        VStack(spacing: 0) {
            HStack {
                closeButton
                Spacer()
                Text("PARENT CHECKOUT").font(AppFont.headline(22)).foregroundColor(.darkNavy)
                Spacer()
                Color.clear.frame(width: 48, height: 48)
            }
            .padding(.horizontal, 20).padding(.top, 8)
            
            Spacer(minLength: 10)
            
            VStack(spacing: 18) {
                HStack(spacing: 14) {
                    IconTile(systemName: "star.fill", tint: Color(uiColor: UIColor(hex: "#FFF3B0")))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(store.fullGame?.displayName ?? "Full Game").font(AppFont.headline(21)).foregroundColor(.darkNavy)
                        Text(store.fullGame?.description ?? "Unlock every level and world, forever.")
                            .font(AppFont.body(14)).foregroundColor(.inkMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                    Text(store.displayPrice).font(AppFont.headline(22)).foregroundColor(.darkNavy)
                }
                
                Button {
                    Task { await store.purchaseFullGame() }
                } label: {
                    HStack(spacing: 10) {
                        if store.isBusy { ProgressView().tint(.darkNavy) }
                        Text(store.isBusy ? "PLEASE WAIT…" : "UNLOCK FOR \(store.displayPrice)").font(AppFont.headline(20))
                    }
                    .foregroundColor(.darkNavy)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(ChunkyButtonStyle(fill: .sunshineYellow, lip: Color(uiColor: UIColor.sunshineYellow.darkened()), minHeight: 62))
                .disabled(store.isBusy)
                
                Button {
                    Task { await store.restorePurchases() }
                } label: {
                    Text("Restore Purchases").font(AppFont.body(16)).foregroundColor(.darkNavy)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(ChunkyButtonStyle(fill: .white, lipHeight: 5, minHeight: 48))
                .disabled(store.isBusy)
                
                if let error = store.lastError {
                    Text(error).font(AppFont.body(13)).foregroundColor(.coralRed)
                        .multilineTextAlignment(.center)
                }
                
                Text("One-time purchase. Family Sharing supported.")
                    .font(AppFont.body(12)).foregroundColor(.inkMuted)
            }
            .padding(.horizontal, 22).padding(.vertical, 26)
            .stickerCard(cornerRadius: 36, shadowOffset: 8)
            .padding(.horizontal, 22)
            
            Spacer(minLength: 20)
        }
        .onAppear { store.lastError = nil }
    }
    
    // MARK: - Unlocked
    
    private var unlocked: some View {
        VStack(spacing: 20) {
            Spacer()
            Image("LaunchLogo").resizable().scaledToFit().frame(height: 150)
            Text("All Worlds Unlocked!").font(AppFont.headline(30)).foregroundColor(.darkNavy)
            Text("Thank you! Every friend is waiting to be colored.")
                .font(AppFont.body(16)).foregroundColor(.inkMuted).multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button(action: onUnlocked) {
                HStack(spacing: 10) {
                    Text("LET'S PLAY!").font(AppFont.headline(22))
                    Image(systemName: "play.fill").font(.system(size: 16, weight: .heavy))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(ChunkyButtonStyle(fill: .grassGreen, lip: Color(uiColor: UIColor.grassGreen.darkened()), minHeight: 64))
            .padding(.horizontal, 40).padding(.top, 8)
            Spacer()
        }
        .onAppear { HapticManager.success(); SoundManager.shared.playFanfare() }
    }
    
    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark").font(.system(size: 18, weight: .heavy)).foregroundColor(.darkNavy)
                .frame(width: 48, height: 48)
        }
        .buttonStyle(ChunkyButtonStyle(fill: .white, lipHeight: 5, hPad: 0, minHeight: 48))
    }
}

enum Paywall {
    /// Hosts the paywall over the SpriteKit view. `onUnlocked` runs after dismissal when the purchase succeeded.
    static func present(from skView: SKView?, initialStep: PaywallView.Step = .offer, onUnlocked: @escaping () -> Void) {
        guard let root = skView?.window?.rootViewController else { return }
        let host = UIHostingController(rootView: PaywallView(onClose: {}, onUnlocked: {}))
        host.rootView = PaywallView(
            onClose: { [weak host] in host?.dismiss(animated: true) },
            onUnlocked: { [weak host] in host?.dismiss(animated: true, completion: onUnlocked) },
            initialStep: initialStep
        )
        host.modalPresentationStyle = .fullScreen
        host.modalTransitionStyle   = .crossDissolve
        root.present(host, animated: true)
    }
}
