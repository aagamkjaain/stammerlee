import SwiftUI

// MARK: - Prolonged Speech Interactive Cloud Experience
// 4-Step Animated Flow with Confetti Celebration, Glass Buttons & Direct Redirection:
// 1. "Let's start with Prolonged Speech" with lowered cloud, centered text & glass button
// 2. "✦ Great! Now let's try saying a few words" with drifting clouds
// 3. Word practice ("sweet" with sound stretching) + billowing cloud banks & purple mic
// 4. "Well done!" celebration with Confetti particle explosion, radiant starburst & automatic redirection to Words / Sentences / Paragraphs screen

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
    @State private var confettiCounter: Int = 0
    @State private var wellDoneBurst: Bool = false

    // Pure yellow palette for ConfettiSwiftUI celebration particles
    private let yellowConfettiColors: [Color] = [
        Color.yellow,
        Color(red: 255 / 255, green: 215 / 255, blue: 0 / 255),    // Bright Gold
        Color(red: 255 / 255, green: 238 / 255, blue: 88 / 255),   // Radiant Sunshine Yellow
        Color(red: 255 / 255, green: 249 / 255, blue: 196 / 255),  // Soft Pastel Yellow
        Color(red: 255 / 255, green: 179 / 255, blue: 0 / 255)     // Warm Amber Gold
    ]

    // Demonstration word: "sweet" practiced only once as an exercise demonstration
    private let demoPrefix = "swe"
    private let demoStretched = "et"

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

                // Twinkling Starfield & Motes Layer
                twinklingStarsLayer(w: w, h: h)
                    .allowsHitTesting(false)

                // Animated Clouds Layer with Edge-to-Edge Bleed & Lowered Bottom Cloud
                cloudsLayer(w: w, h: h)
                    .allowsHitTesting(false)

                // Yellow Confetti Effect using ConfettiSwiftUI (Step 4: Well done!)
                Color.clear
                    .frame(width: 1, height: 1)
                    .confettiCannon(
                        counter: $confettiCounter,
                        num: 60,
                        confettis: [
                            .shape(.circle),
                            .shape(.triangle),
                            .shape(.square),
                            .shape(.slimRectangle),
                            .shape(.roundedCross)
                        ],
                        colors: yellowConfettiColors,
                        confettiSize: 11.0,
                        rainHeight: 700.0,
                        openingAngle: .degrees(0),
                        closingAngle: .degrees(360),
                        radius: 280.0
                    )
                    .position(x: w * 0.5, y: h * 0.44)
                    .allowsHitTesting(false)
                    .zIndex(10)

                // Foreground Content for Active Step
                VStack(spacing: 0) {
                    // Top Navigation Bar (Back button on all steps instead of cross icon)
                    topBar
                        .padding(.horizontal, 24)
                        .padding(.top, 14)

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
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))

                    Spacer(minLength: 0)
                }
                .zIndex(20)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                floatAnim = true
            }
        }
    }

    // MARK: - Top Navigation Bar (Back button and glass close button)
    private var topBar: some View {
        HStack {
            if step != .wellDone {
                BackNavButton {
                    state.navigate(to: .homeDashboard, forward: false)
                }
            }
            Spacer()

            GlassCloseButton {
                redirectToDifficulty()
            }
            .accessibilityLabel("Skip Demo")
        }
    }

    // MARK: - Step 1: Intro Screen (Text near middle, cloud lowered & glass button)
    private func introContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer()

            // Heading positioned near the middle of the screen
            VStack(spacing: 8) {
                Text("Let's start with")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Prolonged Speech")
                    .font(.system(size: 33, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .multilineTextAlignment(.center)
            .padding(.bottom, h * 0.12)

            Spacer()

            // CTA Button
            VStack(spacing: 16) {
                // Purple Glass Effect CTA Button
                GlassActionButton(title: "Begin") {
                    goToStep(.encouragement)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
    }

    // MARK: - Step 2: Encouragement Screen
    private func encouragementContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 16) {
            Spacer()
            TwinklingStarView(assetName: "Sparkle-2", size: 28, delay: 0.1, duration: 1.0)

            Text("Quick Demo")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Let's see how stretching\nsounds works")
                .font(.system(size: 21, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text("We'll try with the word sweet")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(Color(red: 195 / 255, green: 185 / 255, blue: 230 / 255))
                .padding(.top, 4)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            goToStep(.practice)
        }
    }

    // MARK: - Step 3: Practice Word & Purple Microphone Screen (Demonstration of "sweet" only once)
    private func practiceContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Stretch the sound gently without rushing")
                .font(.system(size: 14.5, weight: .medium, design: .rounded))
                .foregroundStyle(Color(red: 210 / 255, green: 205 / 255, blue: 240 / 255))
                .padding(.bottom, 28)

            // Word display with sound stretching
            (
                Text(demoPrefix)
                    .foregroundStyle(Color(red: 195 / 255, green: 175 / 255, blue: 255 / 255))
                + Text(demoStretched)
                    .foregroundStyle(.white)
                    
            )
            .font(.system(size: 56, weight: .bold, design: .rounded))
            .shadow(color: StamerleeTheme.primaryBlue.opacity(0.45), radius: 14)

            // Visual soundwave hint
            Text("Sweeeet")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundStyle(Color(red: 175 / 255, green: 165 / 255, blue: 215 / 255))
                .padding(.top, 8)
                .padding(.bottom, 36)

            // Purple Glass Microphone Control
            Button {
                triggerSpeak()
            } label: {
                ZStack {
                    // Outer audio wave ripple
                    Circle()
                        .stroke(StamerleeTheme.primaryBlue.opacity(isListening ? 0.5 : 0.22), lineWidth: 1.5)
                        .frame(width: 120, height: 120)
                        .scaleEffect(isListening && pulseMic ? 1.18 : 1.0)

                    // Deep navy purple back ring
                    Circle()
                        .fill(Color(red: 32 / 255, green: 26 / 255, blue: 58 / 255))
                        .frame(width: 90, height: 90)
                        .scaleEffect(isListening && pulseMic ? 1.08 : 1.0)

                    // Core Purple Glass Button
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 160 / 255, green: 130 / 255, blue: 255 / 255),
                                    StamerleeTheme.primaryBlueDark
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 68, height: 68)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.7), Color.white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.2
                                )
                        )
                        .shadow(
                            color: StamerleeTheme.primaryBlue.opacity(isListening ? 0.9 : 0.5),
                            radius: isListening ? 16 : 10
                        )

                    Image(systemName: isListening ? "waveform" : "mic.fill")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: pulseMic)
            }
            .buttonStyle(.plain)
            .disabled(isListening)

            Text(isListening ? "Listening" : "Tap and hold to speak")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(Color(red: 195 / 255, green: 190 / 255, blue: 220 / 255))
                .padding(.top, 16)
                .padding(.bottom, 48)

            Spacer()
        }
    }

    // MARK: - Step 4: Well Done! Screen with Confetti & Direct Redirection
    private func wellDoneContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer()

            // Visual layout matching shared screenshot: Starburst + Well done! + Accents
            ZStack {
                VStack(spacing: 12) {
                    // Celebration Sparkle Asset
                    assetImage("celebration")
                        .frame(width: 68, height: 62)
                        .scaleEffect(wellDoneBurst ? 1.0 : 0.3)
                        .opacity(wellDoneBurst ? 1.0 : 0.0)
                        .shadow(color: Color(red: 255 / 255, green: 215 / 255, blue: 100 / 255).opacity(0.6), radius: 12)

                    // Bold "Well done!" Headline
                    Text("Well done!")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Let's start practicing")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 195 / 255, green: 185 / 255, blue: 230 / 255))
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }

                // Decorative Accent Motes & Stars from Screenshot
                // 1. Left yellow star
                assetImage("Sparkle")
                    .frame(width: 22, height: 22)
                    .offset(x: -w * 0.32, y: -8)

                // 2. Left cyan ring mote
                Circle()
                    .stroke(Color(red: 90 / 255, green: 210 / 255, blue: 255 / 255), lineWidth: 2)
                    .frame(width: 8, height: 8)
                    .offset(x: -w * 0.34, y: 24)

                // 3. Right cyan ring mote
                Circle()
                    .stroke(Color(red: 90 / 255, green: 210 / 255, blue: 255 / 255), lineWidth: 2)
                    .frame(width: 8, height: 8)
                    .offset(x: w * 0.33, y: -18)

                // 4. Right yellow star
                assetImage("Sparkle")
                    .frame(width: 20, height: 20)
                    .offset(x: w * 0.31, y: 16)

                // 5. Right cyan dot mote
                Circle()
                    .fill(Color(red: 120 / 255, green: 215 / 255, blue: 255 / 255))
                    .frame(width: 4.5, height: 4.5)
                    .offset(x: w * 0.26, y: 44)
            }

            Spacer()

            // Glass Action Button to proceed immediately (or auto-redirects after celebration)
            GlassActionButton(title: "Continue") {
                redirectToDifficulty()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            redirectToDifficulty()
        }
        .onAppear {
            confettiCounter += 1
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                wellDoneBurst = true
            }
        }
    }

    // Redirect to the "Words, Sentences, Paragraphs" screen
    private func redirectToDifficulty() {
        state.hasSeenProlongedSpeechIntro = true
        state.hasAttemptedProlongedEasy = true
        state.navigate(to: .prolongedSpeechDifficulty)
    }

    // MARK: - Animated Clouds Layer (Edge-to-Edge with Lowered Screen 1 Cloud)
    @ViewBuilder
    private func cloudsLayer(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            // 1. Top-Left Floating Cloud (Hugging left edge cleanly)
            assetImage(step == .encouragement ? "Drifting cloud" : "Cloud-2")
                .scaledToFit()
                .frame(width: step == .encouragement ? 150 : 140)
                .position(topLeftCloudPosition(w: w, h: h))
                .offset(y: floatAnim ? -4 : 4)
                .animation(.spring(response: 0.75, dampingFraction: 0.8), value: step)

            // 2. Top-Right Floating Cloud (Hugging right edge cleanly)
            assetImage("Cloud")
                .scaledToFit()
                .frame(width: 140)
                .position(topRightCloudPosition(w: w, h: h))
                .opacity(step == .encouragement ? 0.0 : 1.0)
                .offset(y: floatAnim ? 3 : -3)
                .animation(.spring(response: 0.75, dampingFraction: 0.8), value: step)

            // 3. Mid-Right Drifting Cloud (Offsets 18px transparent margin)
            assetImage("Drifting cloud-3")
                .scaledToFit()
                .frame(width: 115)
                .position(midRightCloudPosition(w: w, h: h))
                .opacity((step == .intro || step == .encouragement || step == .practice) ? 1.0 : 0.0)
                .offset(y: floatAnim ? -5 : 5)
                .animation(.spring(response: 0.75, dampingFraction: 0.8), value: step)

            // 4. Bottom-Left Drifting Cloud (Bleeds off left edge)
            assetImage("Drifting cloud-2")
                .scaledToFit()
                .frame(width: 142)
                .position(x: w * 0.10, y: step == .wellDone ? h * 0.88 : (step == .encouragement ? h * 0.90 : h * 1.25))
                .opacity((step == .intro || step == .practice) ? 0.0 : 1.0)
                .offset(y: floatAnim ? 4 : -4)
                .animation(.spring(response: 0.75, dampingFraction: 0.8), value: step)

            // 5. Cloud Landscape Bank
            assetImage("Cloud landscape")
                .scaledToFill()
                .frame(width: w * 1.08)
                .position(x: w * 0.5, y: h + 350)
                .opacity(0.0)
                .animation(.spring(response: 0.82, dampingFraction: 0.82), value: step)

            // 6. Bottom Billowing Cloud Bank 1 (Screen 1, Screen 3 & Screen 4: Hugs bottom-right edge)
            assetImage("Cloud bank")
                .scaledToFit()
                .frame(width: w * 0.70)
                .position(bottomBankRightPosition(w: w, h: h))
                .opacity((step == .intro || step == .practice || step == .wellDone) ? 1.0 : 0.0)
                .offset(y: floatAnim ? -3 : 3)
                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: step)

            // 7. Bottom Billowing Cloud Bank 2 (Screen 1, Screen 3 & Screen 4: Hugs bottom-left edge)
            assetImage("Cloud bank-2")
                .scaledToFit()
                .frame(width: w * 0.66)
                .position(bottomBankLeftPosition(w: w, h: h))
                .opacity((step == .intro || step == .practice || step == .wellDone) ? 1.0 : 0.0)
                .offset(y: floatAnim ? 3 : -3)
                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: step)
        }
        .allowsHitTesting(false)
    }

    // Dynamic Cloud Positions for each step
    private func topLeftCloudPosition(w: CGFloat, h: CGFloat) -> CGPoint {
        switch step {
        case .intro, .practice: return CGPoint(x: w * 0.06, y: h * 0.08)
        case .encouragement: return CGPoint(x: w * 0.06, y: h * 0.08)
        case .wellDone: return CGPoint(x: w * -0.06, y: h * 0.08)
        }
    }

    private func topRightCloudPosition(w: CGFloat, h: CGFloat) -> CGPoint {
        switch step {
        case .intro, .practice: return CGPoint(x: w * 0.94, y: h * 0.18)
        case .encouragement: return CGPoint(x: w * 1.15, y: h * 0.065)
        case .wellDone: return CGPoint(x: w * 1.06, y: h * 0.10)
        }
    }

    private func midRightCloudPosition(w: CGFloat, h: CGFloat) -> CGPoint {
        switch step {
        case .intro, .practice: return CGPoint(x: w * 1.08, y: h * 0.26)
        case .encouragement: return CGPoint(x: w * 0.96, y: h * 0.28)
        case .wellDone: return CGPoint(x: w * 1.25, y: h * 0.30)
        }
    }

    private func bottomBankLeftPosition(w: CGFloat, h: CGFloat) -> CGPoint {
        switch step {
        case .intro, .practice: return CGPoint(x: w * 0.20, y: h * 0.88)
        case .encouragement: return CGPoint(x: w * 0.1, y: h * 1.25)
        case .wellDone: return CGPoint(x: w * 0.05, y: h * 0.88)
        }
    }

    private func bottomBankRightPosition(w: CGFloat, h: CGFloat) -> CGPoint {
        switch step {
        case .intro, .practice: return CGPoint(x: w * 0.82, y: h * 0.86)
        case .encouragement: return CGPoint(x: w * 0.9, y: h * 1.25)
        case .wellDone: return CGPoint(x: w * 0.95, y: h * 0.86)
        }
    }

    // MARK: - Natural Twinkling Stars & Motes Layer
    @ViewBuilder
    private func twinklingStarsLayer(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            // Screen 1 Hero Twinkling Star (Matching shared photo position)
            TwinklingStarView(assetName: "Sparkle", size: 28, delay: 0.0, duration: 1.1)
                .position(x: w * 0.32, y: h * 0.07)

            if step != .intro && step != .wellDone {
                // Secondary Twinkling Sparkle (Upper right)
                TwinklingStarView(assetName: "Sparkle", size: 24, delay: 0.4, duration: 1.35)
                    .position(x: w * 0.74, y: h * 0.14)

                // Mid-left Mote
                TwinklingStarView(assetName: "Floating mote", size: 10, delay: 0.2, duration: 0.95)
                    .position(x: w * 0.18, y: h * 0.58)

                // Center-right Sparkle
                TwinklingStarView(assetName: "Sparkle-2", size: 26, delay: 0.6, duration: 1.2)
                    .position(x: w * 0.84, y: h * 0.62)

                // Lower-mid Mote
                TwinklingStarView(assetName: "Floating mote", size: 10, delay: 0.8, duration: 1.4)
                    .position(x: w * 0.35, y: h * 0.68)
            }
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
        if next == .wellDone {
            confettiCounter += 1
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

// MARK: - Glass Action Button
// Frosted translucent acrylic background with crisp gloss highlight, #available glass style, and pop spring effect
public struct GlassActionButton: View {
    public let title: String
    public let icon: String?
    public let action: () -> Void

    public init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        if #available(iOS 26.0, *) {
            Button(action: action) { content }
                .buttonStyle(.glass(.regular.tint(StamerleeTheme.primaryBlue).interactive()))
                .buttonBorderShape(.capsule)
                .frame(maxWidth: .infinity)
        } else {
            Button(action: action) { content }
                .buttonStyle(PopSpringButtonStyle(isEnabled: true))
        }
    }

    private var content: some View {
        HStack(spacing: 8) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
            }
            Text(title)
                .font(.system(size: 16.5, weight: .bold, design: .rounded))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background {
            if #available(iOS 26.0, *) {
                Color.clear
            } else {
                ZStack {
                    // Ultra thin translucent material blur
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(.ultraThinMaterial)

                    // Purple glass tint
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 155 / 255, green: 125 / 255, blue: 255 / 255).opacity(0.88),
                                    StamerleeTheme.primaryBlueDark.opacity(0.92)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Gloss shine highlight on top rim
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.70),
                                    Color.white.opacity(0.20),
                                    StamerleeTheme.primaryBlue.opacity(0.40)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                }
            }
        }
        .shadow(color: StamerleeTheme.primaryBlue.opacity(0.4), radius: 12, x: 0, y: 5)
    }
}

// MARK: - Natural Star Twinkle Component
public struct TwinklingStarView: View {
    public let assetName: String
    public let size: CGFloat
    public let delay: Double
    public let duration: Double

    @State private var isTwinkling = false

    public init(assetName: String, size: CGFloat, delay: Double = 0.0, duration: Double = 1.0) {
        self.assetName = assetName
        self.size = size
        self.delay = delay
        self.duration = duration
    }

    public var body: some View {
        Group {
            if let uiImage = UIImage(named: assetName) ?? UIImage(contentsOfFile: Bundle.main.path(forResource: assetName, ofType: "png") ?? "") {
                Image(uiImage: uiImage)
                    .resizable()
            } else {
                Image(assetName)
                    .resizable()
            }
        }
        .scaledToFit()
        .frame(width: size, height: size)
        .scaleEffect(isTwinkling ? 1.18 : 0.75)
        .opacity(isTwinkling ? 1.0 : 0.36)
        .shadow(
            color: Color(red: 255 / 255, green: 225 / 255, blue: 120 / 255).opacity(isTwinkling ? 0.85 : 0.12),
            radius: isTwinkling ? 7 : 1
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                ) {
                    isTwinkling = true
                }
            }
        }
    }
}
