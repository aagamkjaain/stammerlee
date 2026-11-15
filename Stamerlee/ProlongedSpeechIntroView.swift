import SwiftUI

// MARK: - Prolonged Speech Interactive Cloud Experience
// 4-Step Animated Flow using the user-provided Cloud, Sparkle & Floating Mote assets:
// 1. "Let's start with Prolonged Speech" with Cloud landscape & pill card
// 2. "✦ Great! Now let's try saying a few words" with Drifting clouds repositioning
// 3. Word practice ("sweet" with sound stretching) + Cloud banks & pulsing microphone
// 4. "Well done!" celebration with radiant Sparkle star & parting Cloud banks

public enum ProlongedFlowStep: Int, CaseIterable {
    case intro = 1
    case encouragement = 2
    case practice = 3
    case wellDone = 4
}

public struct ProlongedSpeechIntroView: View {
    @Bindable public var state: AppState

    @State private var step: ProlongedFlowStep = .intro
    @State private var isListening: Bool = false
    @State private var pulseMic: Bool = false
    @State private var floatAnim: Bool = false
    @State private var sparklePulse: Bool = false
    @State private var practiceWordIndex: Int = 0

    private let practiceWords: [(prefix: String, stretched: String)] = [
        ("swe", "et"),
        ("wa", "ter"),
        ("brea", "the"),
        ("smoo", "th")
    ]

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Midnight Sky Background (#0A0D1F)
                Color(red: 10 / 255, green: 13 / 255, blue: 31 / 255)
                    .ignoresSafeArea()

                // Floating Motes & Sparkles Background Layer
                motesAndSparklesLayer(w: w, h: h)

                // Animated Clouds Layer with Asset Images
                cloudsLayer(w: w, h: h)

                // Foreground Content for Active Step
                VStack(spacing: 0) {
                    // Top Navigation / Close Bar
                    topBar
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    Spacer(minLength: 0)

                    // Step Content
                    Group {
                        switch step {
                        case .intro:
                            introContent(w: w, h: h)
                        case .encouragement:
                            encouragementContent(w: w, h: h)
                        case .practice:
                            practiceContent(w: w, h: h)
                        case .wellDone:
                            wellDoneContent(w: w, h: h)
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))

                    Spacer(minLength: 0)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                floatAnim = true
            }
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                sparklePulse = true
            }
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            if step == .intro {
                BackNavButton {
                    state.navigate(to: .homeDashboard, forward: false)
                }
            } else {
                Spacer()
                Button {
                    state.navigate(to: .homeDashboard, forward: false)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(Color(red: 45 / 255, green: 115 / 255, blue: 245 / 255), in: Circle())
                }
                .buttonStyle(.plain)
            }
            if step == .intro {
                Spacer()
            }
        }
    }

    // MARK: - Step 1: Intro Screen
    private func introContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 0) {
            // Heading
            VStack(spacing: 6) {
                Text("Let's start with")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Prolonged Speech")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .multilineTextAlignment(.center)
            .padding(.top, 18)

            Spacer()

            // Card inside the bottom cloud landscape
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 226 / 255, green: 222 / 255, blue: 250 / 255))
                            .frame(width: 38, height: 38)

                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 125 / 255, green: 112 / 255, blue: 235 / 255))
                    }

                    Text("Practice gently stretching sounds while speaking slowly")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(Color(red: 90 / 255, green: 80 / 255, blue: 125 / 255))
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)

                // Begin Button
                Button {
                    goToStep(.encouragement)
                } label: {
                    Text("Begin")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(red: 45 / 255, green: 115 / 255, blue: 245 / 255), in: Capsule())
                        .shadow(color: Color(red: 45 / 255, green: 115 / 255, blue: 245 / 255).opacity(0.4), radius: 10, y: 4)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
    }

    // MARK: - Step 2: Encouragement Screen
    private func encouragementContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 16) {
            Spacer()

            HStack(spacing: 8) {
                assetImage("Sparkle-2")
                    .frame(width: 24, height: 24)
                    .scaleEffect(sparklePulse ? 1.15 : 0.95)

                Text("Great!")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            Text("Now let's try saying\na few words")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            goToStep(.practice)
        }
        .task {
            try? await Task.sleep(nanoseconds: 2_400_000_000)
            if step == .encouragement {
                goToStep(.practice)
            }
        }
    }

    // MARK: - Step 3: Practice Word & Microphone Screen
    private func practiceContent(w: CGFloat, h: CGFloat) -> some View {
        let current = practiceWords[practiceWordIndex % practiceWords.count]

        return VStack(spacing: 0) {
            Spacer()

            // Word display with sound stretching
            (
                Text(current.prefix)
                    .foregroundStyle(.white)
                + Text(current.stretched)
                    .foregroundStyle(Color(red: 100 / 255, green: 170 / 255, blue: 255 / 255))
            )
            .font(.system(size: 54, weight: .bold, design: .rounded))
            .shadow(color: Color(red: 100 / 255, green: 170 / 255, blue: 255 / 255).opacity(0.35), radius: 14)
            .padding(.bottom, 48)

            // Pulsing Microphone Control
            Button {
                triggerSpeak()
            } label: {
                ZStack {
                    Circle()
                        .stroke(Color(red: 45 / 255, green: 115 / 255, blue: 245 / 255).opacity(isListening ? 0.35 : 0.18), lineWidth: 1)
                        .frame(width: 120, height: 120)
                        .scaleEffect(isListening && pulseMic ? 1.16 : 1.0)

                    Circle()
                        .fill(Color(red: 35 / 255, green: 45 / 255, blue: 85 / 255))
                        .frame(width: 90, height: 90)
                        .scaleEffect(isListening && pulseMic ? 1.08 : 1.0)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 65 / 255, green: 145 / 255, blue: 255 / 255),
                                    Color(red: 35 / 255, green: 105 / 255, blue: 240 / 255)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 68, height: 68)
                        .shadow(color: Color(red: 45 / 255, green: 115 / 255, blue: 245 / 255).opacity(isListening ? 0.8 : 0.45), radius: 14)

                    Image(systemName: "mic.fill")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: pulseMic)
            }
            .buttonStyle(.plain)
            .disabled(isListening)
            .padding(.bottom, 60)

            Spacer()
        }
    }

    // MARK: - Step 4: Well Done! Screen
    private func wellDoneContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 20) {
            Spacer()

            // Glowing Radiant Star
            ZStack {
                assetImage("Sparkle-2")
                    .frame(width: 64, height: 64)
                    .blur(radius: 6)
                    .opacity(0.4)
                    .scaleEffect(sparklePulse ? 1.2 : 0.9)

                assetImage("Sparkle-2")
                    .frame(width: 44, height: 44)
                    .scaleEffect(sparklePulse ? 1.08 : 0.98)
                    .shadow(color: Color(red: 255 / 255, green: 215 / 255, blue: 100 / 255).opacity(0.85), radius: 16)
            }

            Text("Well done!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            // Complete Button
            Button {
                state.hasSeenProlongedSpeechIntro = true
                state.hasAttemptedProlongedEasy = true
                state.completedProlongedDifficulties.insert("Words")
                state.navigate(to: .homeDashboard, forward: false)
            } label: {
                Text("Complete")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(red: 45 / 255, green: 115 / 255, blue: 245 / 255), in: Capsule())
                    .shadow(color: Color(red: 45 / 255, green: 115 / 255, blue: 245 / 255).opacity(0.4), radius: 10, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
    }

    // MARK: - Animated Clouds Layer (Using Uploaded Assets)
    @ViewBuilder
    private func cloudsLayer(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            // 1. Top-Left Floating Cloud
            assetImage(step == .encouragement ? "Drifting cloud" : "Cloud-2")
                .scaledToFit()
                .frame(width: step == .encouragement ? 140 : 118)
                .position(topLeftCloudPosition(w: w, h: h))
                .offset(y: floatAnim ? -4 : 4)
                .animation(.spring(response: 0.75, dampingFraction: 0.8), value: step)

            // 2. Top-Right Floating Cloud
            assetImage("Cloud")
                .scaledToFit()
                .frame(width: 113)
                .position(topRightCloudPosition(w: w, h: h))
                .opacity(step == .encouragement ? 0.0 : 1.0)
                .offset(y: floatAnim ? 3 : -3)
                .animation(.spring(response: 0.75, dampingFraction: 0.8), value: step)

            // 3. Mid-Right Drifting Cloud (Appears prominently on Step 2 and Step 3)
            assetImage("Drifting cloud-3")
                .scaledToFit()
                .frame(width: 98)
                .position(midRightCloudPosition(w: w, h: h))
                .opacity((step == .encouragement || step == .practice) ? 1.0 : 0.0)
                .offset(y: floatAnim ? -5 : 5)
                .animation(.spring(response: 0.75, dampingFraction: 0.8), value: step)

            // 4. Bottom-Left Drifting Cloud (Appears on Step 2 & Step 4)
            assetImage("Drifting cloud-2")
                .scaledToFit()
                .frame(width: 128)
                .position(x: w * 0.16, y: step == .wellDone ? h * 0.85 : (step == .encouragement ? h * 0.90 : h * 1.2))
                .opacity(step == .intro ? 0.0 : 1.0)
                .offset(y: floatAnim ? 4 : -4)
                .animation(.spring(response: 0.75, dampingFraction: 0.8), value: step)

            // 5. Cloud Landscape Bank (Screen 1 bottom cloud covering lower 42%)
            assetImage("Cloud landscape")
                .scaledToFill()
                .frame(width: w)
                .position(x: w * 0.5, y: step == .intro ? (h - 180) : (h + 300))
                .opacity(step == .intro ? 1.0 : 0.0)
                .animation(.spring(response: 0.82, dampingFraction: 0.82), value: step)

            // 6. Bottom Billowing Cloud Bank 1 (Screen 3 & Screen 4)
            assetImage("Cloud bank")
                .scaledToFit()
                .frame(width: w * 0.62)
                .position(bottomBankRightPosition(w: w, h: h))
                .opacity((step == .practice || step == .wellDone) ? 1.0 : 0.0)
                .offset(y: floatAnim ? -3 : 3)
                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: step)

            // 7. Bottom Billowing Cloud Bank 2 (Screen 3 & Screen 4)
            assetImage("Cloud bank-2")
                .scaledToFit()
                .frame(width: w * 0.58)
                .position(bottomBankLeftPosition(w: w, h: h))
                .opacity((step == .practice || step == .wellDone) ? 1.0 : 0.0)
                .offset(y: floatAnim ? 3 : -3)
                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: step)
        }
        .allowsHitTesting(false)
    }

    // Dynamic Cloud Positions for each step
    private func topLeftCloudPosition(w: CGFloat, h: CGFloat) -> CGPoint {
        switch step {
        case .intro: return CGPoint(x: w * 0.14, y: h * 0.12)
        case .encouragement: return CGPoint(x: w * 0.16, y: h * 0.13)
        case .practice: return CGPoint(x: w * 0.15, y: h * 0.14)
        case .wellDone: return CGPoint(x: w * -0.05, y: h * 0.10)
        }
    }

    private func topRightCloudPosition(w: CGFloat, h: CGFloat) -> CGPoint {
        switch step {
        case .intro: return CGPoint(x: w * 0.88, y: h * 0.13)
        case .encouragement: return CGPoint(x: w * 1.15, y: h * 0.13)
        case .practice: return CGPoint(x: w * 0.88, y: h * 0.22)
        case .wellDone: return CGPoint(x: w * 1.05, y: h * 0.12)
        }
    }

    private func midRightCloudPosition(w: CGFloat, h: CGFloat) -> CGPoint {
        switch step {
        case .intro: return CGPoint(x: w * 1.25, y: h * 0.32)
        case .encouragement: return CGPoint(x: w * 0.90, y: h * 0.29)
        case .practice: return CGPoint(x: w * 0.88, y: h * 0.26)
        case .wellDone: return CGPoint(x: w * 1.25, y: h * 0.30)
        }
    }

    private func bottomBankLeftPosition(w: CGFloat, h: CGFloat) -> CGPoint {
        switch step {
        case .intro: return CGPoint(x: w * 0.2, y: h * 1.2)
        case .encouragement: return CGPoint(x: w * 0.1, y: h * 1.25)
        case .practice: return CGPoint(x: w * 0.24, y: h * 0.88)
        case .wellDone: return CGPoint(x: w * 0.14, y: h * 0.86)
        }
    }

    private func bottomBankRightPosition(w: CGFloat, h: CGFloat) -> CGPoint {
        switch step {
        case .intro: return CGPoint(x: w * 0.8, y: h * 1.2)
        case .encouragement: return CGPoint(x: w * 0.9, y: h * 1.25)
        case .practice: return CGPoint(x: w * 0.78, y: h * 0.86)
        case .wellDone: return CGPoint(x: w * 0.88, y: h * 0.84)
        }
    }

    // MARK: - Floating Motes & Sparkles Layer
    @ViewBuilder
    private func motesAndSparklesLayer(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            // Sparkle 1 (Top left)
            assetImage("Sparkle")
                .frame(width: 27, height: 28)
                .position(x: w * 0.28, y: h * 0.11)
                .scaleEffect(sparklePulse ? 1.1 : 0.9)

            // Sparkle 2 (Upper mid-right)
            assetImage("Sparkle")
                .frame(width: 27, height: 28)
                .position(x: w * 0.72, y: h * 0.15)
                .scaleEffect(sparklePulse ? 0.9 : 1.1)

            // Floating Mote 1 (Mid left)
            assetImage("Floating mote")
                .frame(width: 10, height: 10)
                .position(x: w * 0.18, y: h * 0.58)
                .opacity(sparklePulse ? 0.9 : 0.4)

            // Sparkle 3 (Center right)
            assetImage("Sparkle-2")
                .frame(width: 28, height: 28)
                .position(x: w * 0.84, y: h * 0.62)
                .scaleEffect(sparklePulse ? 1.05 : 0.95)

            // Floating Mote 2 (Lower mid)
            assetImage("Floating mote")
                .frame(width: 10, height: 10)
                .position(x: w * 0.35, y: h * 0.68)
                .opacity(sparklePulse ? 0.5 : 0.9)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Asset Image Loader Helper
    @ViewBuilder
    private func assetImage(_ name: String) -> some View {
        if let uiImage = UIImage(named: name) ?? UIImage(contentsOfFile: Bundle.main.path(forResource: name, ofType: "png") ?? "") {
            Image(uiImage: uiImage)
                .resizable()
        } else {
            Image(name)
                .resizable()
        }
    }

    // MARK: - Step Helpers
    private func goToStep(_ next: ProlongedFlowStep) {
        withAnimation(.spring(response: 0.72, dampingFraction: 0.8)) {
            step = next
        }
    }

    private func triggerSpeak() {
        guard !isListening else { return }
        isListening = true
        pulseMic = true

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_200_000_000)
            withAnimation(.spring(response: 0.65, dampingFraction: 0.8)) {
                isListening = false
                pulseMic = false
                goToStep(.wellDone)
            }
        }
    }
}
