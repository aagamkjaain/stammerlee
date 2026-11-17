import SwiftUI

// MARK: - Picture Description Interactive Cloud Experience
// 4-Step Animated Flow with Cloud Transitions, Confetti Celebration & Microphone Interaction:
// 1. "Let's start with Picture Description" with lowered cloud landscape, instruction pill & glass button
// 2. "Quick Demo" explaining that a picture will be shown and you will describe it
// 3. Demo practice with picture preview, instruction text, and purple glass microphone
// 4. "Well done!" celebration with Confetti particle explosion and automatic navigation to practice

public enum PictureDescriptionFlowStep: Int, CaseIterable {
    case intro = 1
    case encouragement = 2
    case practice = 3
    case wellDone = 4
}

public struct PictureDescriptionIntroView: View {
    @Bindable public var state: AppState

    @State private var step: PictureDescriptionFlowStep = .intro
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
                    // Top Navigation Bar
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

    // MARK: - Top Navigation Bar
    private var topBar: some View {
        HStack {
            if step != .wellDone {
                BackNavButton {
                    state.navigate(to: .homeDashboard, forward: false)
                }
            }
            Spacer()
            GlassCloseButton {
                redirectToPractice()
            }
        }
    }

    // MARK: - Step 1: Intro Screen
    private func introContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer()

            // Heading positioned near the middle of the screen
            VStack(spacing: 8) {
                Text("Let's start with")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Picture Description")
                    .font(.system(size: 33, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .multilineTextAlignment(.center)
            .padding(.bottom, h * 0.12)

            Spacer()

            // CTA Button
            VStack(spacing: 16) {
                // Purple Glass Effect CTA Button
                PicGlassActionButton(title: "Begin") {
                    goToStep(.encouragement)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
    }

    // MARK: - Step 2: Encouragement / Quick Demo Screen
    private func encouragementContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 16) {
            Spacer()

            PicTwinklingStarView(assetName: "Sparkle-2", size: 28, delay: 0.1, duration: 1.0)

            Text("Let's understand how Picture\nDescription works:")
                .font(.system(size: 21, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text("A picture will be shown on your screen,\nand you have to describe it aloud")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(Color(red: 195 / 255, green: 185 / 255, blue: 230 / 255))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.top, 4)
                .padding(.horizontal, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            goToStep(.practice)
        }
    }

    // MARK: - Step 3: Demo Practice Screen (Picture Preview, Text Instructions & Microphone)
    private func practiceContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer()

            // Instruction Headline
            Text("Try to describe this picture")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(red: 220 / 255, green: 215 / 255, blue: 245 / 255))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
                .padding(.bottom, 14)

            // Picture Demonstration Card
            ZStack(alignment: .bottom) {
                Group {
                    if let uiImage = UIImage(named: "picturedesintro") ?? UIImage(contentsOfFile: Bundle.main.path(forResource: "picturedesintro", ofType: "png") ?? "") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else if let uiImage = UIImage(named: "picturehero") ?? UIImage(named: "PictureHero") ?? UIImage(contentsOfFile: Bundle.main.path(forResource: "picturehero", ofType: "png") ?? "") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image("picturedesintro")
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: min(w * 0.78, 280), height: 165)
                .clipped()

                // Bottom hint badge
                HStack(spacing: 4) {
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 11))
                    Text("e.g. \"A girl reading a book under a peaceful tree\"")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .lineLimit(1)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.65))
            }
            .frame(width: min(w * 0.78, 280), height: 165)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.28), lineWidth: 1)
            )
            .shadow(color: StamerleeTheme.primaryBlue.opacity(0.35), radius: 14, x: 0, y: 6)
            .padding(.bottom, 24)

            // Purple Glass Microphone Control
            Button {
                triggerSpeak()
            } label: {
                ZStack {
                    // Outer audio wave ripple
                    Circle()
                        .stroke(StamerleeTheme.primaryBlue.opacity(isListening ? 0.5 : 0.22), lineWidth: 1.5)
                        .frame(width: 104, height: 104)
                        .scaleEffect(isListening && pulseMic ? 1.18 : 1.0)

                    // Deep navy purple back ring
                    Circle()
                        .fill(Color(red: 32 / 255, green: 26 / 255, blue: 58 / 255))
                        .frame(width: 78, height: 78)
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
                        .frame(width: 58, height: 58)
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
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: pulseMic)
            }
            .buttonStyle(.plain)
            .disabled(isListening)

            Text(isListening ? "Listening" : "Tap and hold to speak")
                .font(.system(size: 13.5, weight: .regular, design: .rounded))
                .foregroundStyle(Color(red: 195 / 255, green: 190 / 255, blue: 220 / 255))
                .padding(.top, 14)
                .padding(.bottom, 28)

            Spacer()
        }
    }

    // MARK: - Step 4: Well Done! Screen with Confetti & Direct Redirection
    private func wellDoneContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                VStack(spacing: 12) {
                    // Celebration Starburst: Hero Star + 2 Angled Burst Rays
                    ZStack {
                        HStack(spacing: 24) {
                            Capsule()
                                .fill(Color(red: 255 / 255, green: 220 / 255, blue: 100 / 255))
                                .frame(width: 3.5, height: 14)
                                .rotationEffect(.degrees(-26))
                                .offset(y: -14)

                            Capsule()
                                .fill(Color(red: 255 / 255, green: 220 / 255, blue: 100 / 255))
                                .frame(width: 3.5, height: 14)
                                .rotationEffect(.degrees(26))
                                .offset(y: -14)
                        }
                        .scaleEffect(wellDoneBurst ? 1.0 : 0.4)
                        .opacity(wellDoneBurst ? 1.0 : 0.0)

                        // Center 4-Point Golden Star
                        assetImage("Sparkle-2")
                            .frame(width: 44, height: 44)
                            .shadow(color: Color(red: 255 / 255, green: 215 / 255, blue: 100 / 255).opacity(0.9), radius: 14)
                    }

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

                // Decorative Accent Motes & Stars
                assetImage("Sparkle")
                    .frame(width: 22, height: 22)
                    .offset(x: -w * 0.32, y: -8)

                Circle()
                    .stroke(Color(red: 90 / 255, green: 210 / 255, blue: 255 / 255), lineWidth: 2)
                    .frame(width: 8, height: 8)
                    .offset(x: -w * 0.34, y: 24)

                Circle()
                    .stroke(Color(red: 90 / 255, green: 210 / 255, blue: 255 / 255), lineWidth: 2)
                    .frame(width: 8, height: 8)
                    .offset(x: w * 0.33, y: -18)

                assetImage("Sparkle")
                    .frame(width: 20, height: 20)
                    .offset(x: w * 0.31, y: 16)

                Circle()
                    .fill(Color(red: 120 / 255, green: 215 / 255, blue: 255 / 255))
                    .frame(width: 4.5, height: 4.5)
                    .offset(x: w * 0.26, y: 44)
            }

            Spacer()

            // Glass Action Button to proceed immediately (or auto-redirects after celebration)
            PicGlassActionButton(title: "Continue") {
                redirectToPractice()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            redirectToPractice()
        }
        .onAppear {
            confettiCounter += 1
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                wellDoneBurst = true
            }

        }
    }

    // Redirect to Picture Description Practice
    private func redirectToPractice() {
        state.hasSeenPictureDescriptionIntro = true
        state.navigate(to: .pictureDescriptionPractice)
    }

    // MARK: - Animated Clouds Layer (Edge-to-Edge with Lowered Screen 1 Cloud)
    @ViewBuilder
    private func cloudsLayer(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            // 1. Top-Left Floating Cloud
            assetImage(step == .encouragement ? "Drifting cloud" : "Cloud-2")
                .scaledToFit()
                .frame(width: step == .encouragement ? 150 : 140)
                .position(topLeftCloudPosition(w: w, h: h))
                .offset(y: floatAnim ? -4 : 4)
                .animation(.spring(response: 0.75, dampingFraction: 0.8), value: step)

            // 2. Top-Right Floating Cloud
            assetImage("Cloud")
                .scaledToFit()
                .frame(width: 140)
                .position(topRightCloudPosition(w: w, h: h))
                .opacity(step == .encouragement ? 0.0 : 1.0)
                .offset(y: floatAnim ? 3 : -3)
                .animation(.spring(response: 0.75, dampingFraction: 0.8), value: step)

            // 3. Mid-Right Drifting Cloud
            assetImage("Drifting cloud-3")
                .scaledToFit()
                .frame(width: 115)
                .position(midRightCloudPosition(w: w, h: h))
                .opacity((step == .intro || step == .encouragement || step == .practice) ? 1.0 : 0.0)
                .offset(y: floatAnim ? -5 : 5)
                .animation(.spring(response: 0.75, dampingFraction: 0.8), value: step)

            // 4. Bottom-Left Drifting Cloud
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
            PicTwinklingStarView(assetName: "Sparkle", size: 28, delay: 0.0, duration: 1.1)
                .position(x: w * 0.32, y: h * 0.07)

            if step != .intro && step != .wellDone {
                PicTwinklingStarView(assetName: "Sparkle", size: 24, delay: 0.4, duration: 1.35)
                    .position(x: w * 0.74, y: h * 0.14)

                PicTwinklingStarView(assetName: "Floating mote", size: 10, delay: 0.2, duration: 0.95)
                    .position(x: w * 0.18, y: h * 0.58)

                PicTwinklingStarView(assetName: "Sparkle-2", size: 26, delay: 0.6, duration: 1.2)
                    .position(x: w * 0.84, y: h * 0.62)

                PicTwinklingStarView(assetName: "Floating mote", size: 10, delay: 0.8, duration: 1.4)
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
    private func goToStep(_ next: PictureDescriptionFlowStep) {
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
private struct PicGlassActionButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
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
                ZStack {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(.ultraThinMaterial)

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
            .shadow(color: StamerleeTheme.primaryBlue.opacity(0.4), radius: 12, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Natural Star Twinkle Component
private struct PicTwinklingStarView: View {
    let assetName: String
    let size: CGFloat
    let delay: Double
    let duration: Double

    @State private var isTwinkling = false

    var body: some View {
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
