import SwiftUI
import SpriteKit

/// Gate → Settings. Presented full-screen over the SpriteKit view; the gate is asked every time.
struct ParentFlowView: View {
    
    var onClose: () -> Void
    @State private var passed: Bool
    
    init(onClose: @escaping () -> Void, startAtSettings: Bool = false) {
        self.onClose = onClose
        _passed = State(initialValue: startAtSettings)
    }
    
    var body: some View {
        ZStack {
            if passed {
                SettingsView(onClose: onClose)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                ParentGateView(onPass: { withAnimation(.easeInOut(duration: 0.3)) { passed = true } },
                               onClose: onClose)
                    .transition(.opacity)
            }
        }
    }
}

enum ParentFlow {
    /// Hosts the flow over whatever is on screen.
    static func present(from skView: SKView?, startAtSettings: Bool = false) {
        guard let root = skView?.window?.rootViewController else { return }
        let host = UIHostingController(rootView: ParentFlowView(onClose: {}))
        host.rootView = ParentFlowView(onClose: { [weak host] in host?.dismiss(animated: true) },
                                       startAtSettings: startAtSettings)
        host.modalPresentationStyle = .fullScreen
        host.modalTransitionStyle   = .crossDissolve
        root.present(host, animated: true)
    }
}
