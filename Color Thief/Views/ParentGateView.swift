import SwiftUI

/// COPPA gate: a random addition question with four options. Wrong → shake + new question.
struct ParentGateView: View {
    
    var onPass: () -> Void
    var onClose: () -> Void
    
    @State private var a = 0
    @State private var b = 0
    @State private var options: [Int] = []
    @State private var attempts: CGFloat = 0
    @State private var flashCorrect = false
    
    var body: some View {
        ZStack {
            PolkaDotBackground()
            
            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
                Spacer(minLength: 12)
                
                mascotLock
                
                Text("Ask a grown-up for help!")
                    .font(AppFont.headline(24))
                    .foregroundColor(.darkNavy)
                    .padding(.top, 18)
                Text("Please solve this quick problem to enter parent settings.")
                    .font(AppFont.body(15))
                    .foregroundColor(.inkMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 44)
                    .padding(.top, 6)
                
                Spacer(minLength: 20)
                
                questionCard
                    .padding(.horizontal, 22)
                    .modifier(ShakeEffect(animatableData: attempts))
                
                Spacer(minLength: 20)
                
                footer
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
            }
        }
        .onAppear(perform: newQuestion)
    }
    
    // MARK: - Pieces
    
    private var header: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark").font(.system(size: 18, weight: .heavy)).foregroundColor(.darkNavy)
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(ChunkyButtonStyle(fill: .white, lipHeight: 5, hPad: 0, minHeight: 48))
            
            Spacer()
            
            HStack(spacing: 10) {
                Circle().fill(Color.coralRed).frame(width: 9, height: 9)
                Text("Grown-Ups Only").font(AppFont.headline(22)).foregroundColor(.darkNavy)
                Circle().fill(Color.sunshineYellow).frame(width: 9, height: 9)
            }
            
            Spacer()
            
            Color.clear.frame(width: 48, height: 48)
        }
    }
    
    private var mascotLock: some View {
        ZStack {
            // Sparkle dots
            Circle().fill(Color.mintGreen).frame(width: 12).offset(x: -54, y: -30)
            Circle().fill(Color.sunshineYellow).frame(width: 14).offset(x: 58, y: -16)
            Circle().fill(Color.coralRed).frame(width: 10).offset(x: 46, y: 44)
            
            VStack(spacing: -6) {
                // Shackle
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.darkNavy, lineWidth: 4)
                    .background(RoundedRectangle(cornerRadius: 22).fill(Color.mintGreen))
                    .frame(width: 44, height: 46)
                    .mask(Rectangle().padding(.bottom, 14))
                    .zIndex(-1)
                // Body with a face
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.sunshineYellow)
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.darkNavy, lineWidth: 4))
                    .frame(width: 78, height: 66)
                    .overlay(
                        VStack(spacing: 3) {
                            HStack(spacing: 18) {
                                Circle().fill(Color.darkNavy).frame(width: 7)
                                Circle().fill(Color.darkNavy).frame(width: 7)
                            }
                            // Smile
                            Path { p in p.addArc(center: CGPoint(x: 10, y: 0), radius: 10,
                                                 startAngle: .degrees(20), endAngle: .degrees(160), clockwise: false) }
                                .stroke(Color.darkNavy, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                .frame(width: 20, height: 10)
                            // Keyhole
                            Capsule().fill(Color.darkNavy).frame(width: 7, height: 10).padding(.top, 2)
                        }
                        .offset(y: 2)
                    )
                    .overlay(
                        HStack(spacing: 40) {
                            Circle().fill(Color.coralRed.opacity(0.55)).frame(width: 10)
                            Circle().fill(Color.coralRed.opacity(0.55)).frame(width: 10)
                        }.offset(y: -2)
                    )
            }
        }
        .frame(height: 120)
    }
    
    private var questionCard: some View {
        VStack(spacing: 22) {
            HStack(spacing: 6) {
                Image(systemName: "lock.fill").font(.system(size: 11, weight: .heavy))
                Text("ADULT CHECK").font(AppFont.headline(13)).tracking(1)
            }
            .foregroundColor(.darkNavy)
            .padding(.horizontal, 16).padding(.vertical, 8)
            .background(Capsule().fill(Color(uiColor: UIColor(hex: "#FFF3B0"))).overlay(Capsule().stroke(Color.darkNavy, lineWidth: 2.5)))
            
            HStack(spacing: 12) {
                Text("What is").font(AppFont.headline(30)).foregroundColor(.darkNavy)
                Text("\(a) + \(b)")
                    .font(AppFont.headline(30)).foregroundColor(.darkNavy)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(flashCorrect ? Color.grassGreen.opacity(0.35) : Color(uiColor: UIColor(hex: "#FFF3DC")))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.darkNavy, lineWidth: 3)))
                Text("?").font(AppFont.headline(30)).foregroundColor(.darkNavy)
            }
            
            HStack(spacing: 12) {
                ForEach(options, id: \.self) { value in
                    Button { answer(value) } label: {
                        Text("\(value)")
                            .font(AppFont.headline(28))
                            .foregroundColor(.darkNavy)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ChunkyButtonStyle(fill: .white, lipHeight: 6, cornerRadius: 18, hPad: 0, minHeight: 68))
                }
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 26)
        .stickerCard(cornerRadius: 32, shadowOffset: 8)
    }
    
    private var footer: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.shield.fill").font(.system(size: 14, weight: .bold)).foregroundColor(.darkNavy)
            Text("This check helps keep your child safe in the game.")
                .font(AppFont.body(12)).foregroundColor(.inkMuted)
                .lineLimit(1).minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 18).padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Capsule().fill(Color.white).overlay(Capsule().stroke(Color.darkNavy, lineWidth: 2.5)))
    }
    
    // MARK: - Logic
    
    private func newQuestion() {
        a = Int.random(in: 2...9)
        b = Int.random(in: 2...9)
        let correct = a + b
        var set: Set<Int> = [correct]
        while set.count < 4 {
            let candidate = correct + Int.random(in: -4...4)
            if candidate > 0 { set.insert(candidate) }
        }
        options = Array(set).shuffled()
    }
    
    private func answer(_ value: Int) {
        if value == a + b {
            HapticManager.success()
            withAnimation(.easeOut(duration: 0.15)) { flashCorrect = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { onPass() }
        } else {
            HapticManager.tap()
            withAnimation(.easeInOut(duration: 0.4)) { attempts += 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { newQuestion() }
        }
    }
}
