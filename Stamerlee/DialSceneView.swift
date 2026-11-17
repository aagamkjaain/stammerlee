


import SwiftUI

// MARK: - Dial Scene Interactive Cloud Experience
// 4-Step Animated Flow with Cloud Transitions, Interactive Conversation & Confetti:
// 1. "Let's start with Dial Scene" with lowered cloud landscape, instruction pill & glass button
// 2. "Quick Demo" explaining back-and-forth call simulation
// 3. Simulated phone conversation: Bot says "Hi, how are you?" -> user speaks -> bot speaks -> user speaks -> bot says "bye bye"
// 4. "Well done!" celebration with Confetti explosion and 3-4s gap before real practice

public enum DialSceneFlowStep: Int, CaseIterable {
    case intro = 1
    case encouragement = 2
    case conversation = 3
    case wellDone = 4
}

public struct DialSceneIntroView: View {
    @Bindable public var state: AppState
    public var onBack: (() -> Void)? = nil
    public var onContinue: (() -> Void)? = nil

    @State private var step: DialSceneFlowStep = .intro
    @State private var isListening: Bool = false
    @State private var pulseMic: Bool = false
    @State private var floatAnim: Bool = false
    @State private var confettiCounter: Int = 0
    @State private var wellDoneBurst: Bool = false
    @State private var hasRedirected: Bool = false

    // Pure yellow palette for ConfettiSwiftUI celebration particles
    private let yellowConfettiColors: [Color] = [
        Color.yellow,
        Color(red: 255 / 255, green: 215 / 255, blue: 0 / 255),    // Bright Gold
        Color(red: 255 / 255, green: 238 / 255, blue: 88 / 255),   // Radiant Sunshine Yellow
        Color(red: 255 / 255, green: 249 / 255, blue: 196 / 255),  // Soft Pastel Yellow
        Color(red: 255 / 255, green: 179 / 255, blue: 0 / 255)     // Warm Amber Gold
    ]

    // Conversation turns:
    // 0: Bot greeted ("Hi! How are you?") -> waiting for User Reply 1
    // 1: User replying ("I'm doing well, thank you!")
    // 2: Bot replied ("Awesome! Ready for our practice call?") -> waiting for User Reply 2
    // 3: User replying ("Yes, ready to practice!")
    // 4: Bot farewell ("Wonderful! Have a great day, bye bye! 👋")
    @State private var convoTurn: Int = 0

    public init(
        state: AppState,
        onBack: (() -> Void)? = nil,
        onContinue: (() -> Void)? = nil
    ) {
        self.state = state
        self.onBack = onBack
        self.onContinue = onContinue
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

                // Animated Clouds Layer
                cloudsLayer(w: w, h: h)
                    .allowsHitTesting(false)

                // Subtle Yellow Confetti Effect using ConfettiSwiftUI (Step 4: Well done!)
                Color.clear
                    .frame(width: 1, height: 1)
                    .confettiCannon(
                        counter: $confettiCounter,
                        num: 26,
                        confettis: [
                            .shape(.circle),
                            .shape(.triangle),
                            .shape(.square)
                        ],
                        colors: yellowConfettiColors,
                        confettiSize: 7.5,
                        rainHeight: 480.0,
                        opacity: 0.85,
                        openingAngle: .degrees(0),
                        closingAngle: .degrees(360),
                        radius: 200.0
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
                        case .conversation:
                            conversationContent(w: w, h: h)
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
                redirectToRealPractice()
            }
        }
    }

    // MARK: - Step 1: Intro Screen
    // MARK: - Step 1: Intro Screen (Text near middle, cloud lowered & glass button)
    private func introContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer()

            // Heading positioned near the middle of the screen
            VStack(spacing: 8) {
                Text("Let's start with")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Dial Scene")
                    .font(.system(size: 33, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .multilineTextAlignment(.center)
            .padding(.bottom, h * 0.12)

            Spacer()

            // CTA Button
            VStack(spacing: 16) {
                // Purple Glass Effect CTA Button
                DialGlassActionButton(title: "Begin") {
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

                DialTwinklingStarView(assetName: "Sparkle-2", size: 28, delay: 0.1, duration: 1.0)
            

            Text("Let's understand how Dial\nScene works")
                .font(.system(size: 21, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text("The caller will speak to you,\nand you reply just like a conversation")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(Color(red: 195 / 255, green: 185 / 255, blue: 230 / 255))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.top, 4)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            goToStep(.conversation)
        }
    }

    // MARK: - Step 3: Interactive Call Conversation Demo
    private func conversationContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer()

            // Chat Messages Floating Directly on Scene
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        // Turn 1: Bot greets
                        chatBubble(text: "Hi! How are you?", isUser: false)
                            .id(1)

                        // Turn 2: User reply 1
                        if convoTurn >= 1 {
                            chatBubble(text: "I'm doing well, thank you!", isUser: true)
                                .transition(.scale.combined(with: .opacity))
                                .id(2)
                        }

                        // Turn 3: Bot reply
                        if convoTurn >= 2 {
                            chatBubble(text: "Awesome! Ready for our practice call?", isUser: false)
                                .transition(.scale.combined(with: .opacity))
                                .id(3)
                        }

                        // Turn 4: User reply 2
                        if convoTurn >= 3 {
                            chatBubble(text: "Yes, ready to practice!", isUser: true)
                                .transition(.scale.combined(with: .opacity))
                                .id(4)
                        }

                        // Turn 5: Bot farewell
                        if convoTurn >= 4 {
                            chatBubble(text: "Wonderful! Have a great day, bye bye! 👋", isUser: false)
                                .transition(.scale.combined(with: .opacity))
                                .id(5)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .padding(.bottom, 16)
                }
                .frame(maxHeight: min(340, h * 0.44))
                .onChange(of: convoTurn) { _, newTurn in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(newTurn + 1, anchor: .bottom)
                    }
                }
            }

            Spacer()

            // Dynamic Microphone Prompt & Button or Continue Button (Constant bottom position)
            if convoTurn >= 4 {
                VStack(spacing: 16) {
                    DialGlassActionButton(title: "Continue") {
                        goToStep(.wellDone)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
            } else {
                VStack(spacing: 12) {
                    // Instructions cue
                    Text(micPromptText)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 215 / 255, green: 210 / 255, blue: 245 / 255))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .frame(height: 22)

                    // Purple Glass Microphone Control
                    Button {
                        triggerUserTurn()
                    } label: {
                        ZStack {
                            Circle()
                                .stroke(StamerleeTheme.primaryBlue.opacity(isListening ? 0.5 : 0.22), lineWidth: 1.5)
                                .frame(width: 96, height: 96)
                                .scaleEffect(isListening && pulseMic ? 1.18 : 1.0)

                            Circle()
                                .fill(Color(red: 32 / 255, green: 26 / 255, blue: 58 / 255))
                                .frame(width: 72, height: 72)
                                .scaleEffect(isListening && pulseMic ? 1.08 : 1.0)

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
                                .frame(width: 54, height: 54)
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
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: pulseMic)
                    }
                    .buttonStyle(.plain)
                    .disabled(isListening || convoTurn == 1 || convoTurn == 3)
                }
                .padding(.bottom, 36)
            }
        }
    }

    private var micPromptText: String {
        if isListening {
            return "Listening"
        } else if convoTurn == 0 {
            return "Tap and hold to say: \"I'm doing well, thank you!\""
        } else if convoTurn == 2 {
            return "Tap and hold to say: \"Yes, ready to practice!\""
        } else if convoTurn >= 4 {
            return "Call completed! Good job."
        } else {
            return "Caller is speaking"
        }
    }

    private func chatBubble(text: String, isUser: Bool) -> some View {
        HStack {
            if isUser { Spacer(minLength: 40) }

            Text(text)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            isUser
                                ? LinearGradient(
                                    colors: [
                                        Color(red: 145 / 255, green: 110 / 255, blue: 250 / 255),
                                        StamerleeTheme.primaryBlueDark
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [
                                        Color(red: 45 / 255, green: 40 / 255, blue: 80 / 255).opacity(0.95),
                                        Color(red: 35 / 255, green: 30 / 255, blue: 65 / 255).opacity(0.95)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(isUser ? 0.35 : 0.18), lineWidth: 1)
                        )
                )
                .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 3)

            if !isUser { Spacer(minLength: 40) }
        }
    }

    private func triggerUserTurn() {
        guard !isListening else { return }
        isListening = true
        pulseMic = true

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            isListening = false
            pulseMic = false

            if convoTurn == 0 {
                // User spoke reply 1
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    convoTurn = 1
                }
                // Bot speaks reply after 1s
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    convoTurn = 2
                }
            } else if convoTurn == 2 {
                // User spoke reply 2
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    convoTurn = 3
                }
                // Bot speaks farewell after 1s
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    convoTurn = 4
                }
            }
        }
    }

    // MARK: - Step 4: Well Done! Screen with Confetti & Direct Redirection
    private func wellDoneContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer()

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

            // Glass Action Button to proceed immediately
            DialGlassActionButton(title: "Continue") {
                redirectToRealPractice()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            redirectToRealPractice()
        }
        .onAppear {
            confettiCounter += 1
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                wellDoneBurst = true
            }
        }
    }

    private func redirectToRealPractice() {
        // Only ever redirect once (tap and auto-timer could both fire)
        guard !hasRedirected else { return }
        hasRedirected = true
        state.hasSeenDialSceneIntro = true
        if let onContinue {
            onContinue()
        } else {
            state.navigate(to: .dialScene)
        }
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
                .opacity((step == .intro || step == .encouragement || step == .conversation) ? 1.0 : 0.0)
                .offset(y: floatAnim ? -5 : 5)
                .animation(.spring(response: 0.75, dampingFraction: 0.8), value: step)

            // 4. Bottom-Left Drifting Cloud (Bleeds off left edge)
            assetImage("Drifting cloud-2")
                .scaledToFit()
                .frame(width: 142)
                .position(x: w * 0.10, y: step == .wellDone ? h * 0.88 : (step == .encouragement ? h * 0.90 : h * 1.25))
                .opacity((step == .intro || step == .conversation) ? 0.0 : 1.0)
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
                .opacity((step == .intro || step == .conversation || step == .wellDone) ? 1.0 : 0.0)
                .offset(y: floatAnim ? -3 : 3)
                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: step)

            // 7. Bottom Billowing Cloud Bank 2 (Screen 1, Screen 3 & Screen 4: Hugs bottom-left edge)
            assetImage("Cloud bank-2")
                .scaledToFit()
                .frame(width: w * 0.66)
                .position(bottomBankLeftPosition(w: w, h: h))
                .opacity((step == .intro || step == .conversation || step == .wellDone) ? 1.0 : 0.0)
                .offset(y: floatAnim ? 3 : -3)
                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: step)
        }
        .allowsHitTesting(false)
    }

    // Dynamic Cloud Positions for each step
    private func topLeftCloudPosition(w: CGFloat, h: CGFloat) -> CGPoint {
        switch step {
        case .intro, .conversation: return CGPoint(x: w * 0.06, y: h * 0.08)
        case .encouragement: return CGPoint(x: w * 0.06, y: h * 0.08)
        case .wellDone: return CGPoint(x: w * -0.06, y: h * 0.08)
        }
    }

    private func topRightCloudPosition(w: CGFloat, h: CGFloat) -> CGPoint {
        switch step {
        case .intro, .conversation: return CGPoint(x: w * 0.94, y: h * 0.18)
        case .encouragement: return CGPoint(x: w * 1.15, y: h * 0.065)
        case .wellDone: return CGPoint(x: w * 1.06, y: h * 0.10)
        }
    }

    private func midRightCloudPosition(w: CGFloat, h: CGFloat) -> CGPoint {
        switch step {
        case .intro, .conversation: return CGPoint(x: w * 1.08, y: h * 0.26)
        case .encouragement: return CGPoint(x: w * 0.96, y: h * 0.28)
        case .wellDone: return CGPoint(x: w * 1.25, y: h * 0.30)
        }
    }

    private func bottomBankLeftPosition(w: CGFloat, h: CGFloat) -> CGPoint {
        switch step {
        case .intro, .conversation: return CGPoint(x: w * 0.20, y: h * 0.88)
        case .encouragement: return CGPoint(x: w * 0.1, y: h * 1.25)
        case .wellDone: return CGPoint(x: w * 0.05, y: h * 0.88)
        }
    }

    private func bottomBankRightPosition(w: CGFloat, h: CGFloat) -> CGPoint {
        switch step {
        case .intro, .conversation: return CGPoint(x: w * 0.82, y: h * 0.86)
        case .encouragement: return CGPoint(x: w * 0.9, y: h * 1.25)
        case .wellDone: return CGPoint(x: w * 0.95, y: h * 0.86)
        }
    }

    // MARK: - Natural Twinkling Stars & Motes Layer
    @ViewBuilder
    private func twinklingStarsLayer(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            DialTwinklingStarView(assetName: "Sparkle", size: 28, delay: 0.0, duration: 1.1)
                .position(x: w * 0.32, y: h * 0.07)

            if step != .intro && step != .wellDone {
                DialTwinklingStarView(assetName: "Sparkle", size: 24, delay: 0.4, duration: 1.35)
                    .position(x: w * 0.74, y: h * 0.14)

                DialTwinklingStarView(assetName: "Floating mote", size: 10, delay: 0.2, duration: 0.95)
                    .position(x: w * 0.18, y: h * 0.58)

                DialTwinklingStarView(assetName: "Sparkle-2", size: 26, delay: 0.6, duration: 1.2)
                    .position(x: w * 0.84, y: h * 0.62)

                DialTwinklingStarView(assetName: "Floating mote", size: 10, delay: 0.8, duration: 1.4)
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
    private func goToStep(_ next: DialSceneFlowStep) {
        withAnimation(.spring(response: 0.72, dampingFraction: 0.8)) {
            step = next
        }
        if next == .wellDone {
            confettiCounter += 1
        }
    }
}

// MARK: - Dial Glass Action Button
private struct DialGlassActionButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        GlassActionButton(title: title, icon: icon, action: action)
    }
}

// MARK: - Natural Star Twinkle Component
private struct DialTwinklingStarView: View {
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

// MARK: - Dial Scene
/// Conversation practice unlocked alongside Picture Description.
public struct DialSceneView: View {
    @Bindable public var state: AppState

    @State private var selectedScenario = "Ordering at a Café"
    @State private var stage: Stage
    @State private var isListening: Bool = false
    @State private var conversationStep = 0
    @State private var micPhase: DialMicPhase = .idle
    @State private var hasSpoken: Bool = false
    @State private var turnTask: Task<Void, Never>?

    private enum Stage {
        case intro
        case scenarios
        case conversation
        case analysis
    }

    private let scenarios = [
        ("Ordering at a Café", "Practice placing your order.", "cup.and.saucer.fill"),
        ("Ordering at a Restaurant", "Practice ordering a meal.", "fork.knife"),
        ("Checking into a Hotel", "Build confidence checking in.", "building.2.fill"),
        ("At a Hair Salon", "Practice common salon phrases.", "scissors"),
        ("At a Grocery Store", "Practice asking for items.", "basket.fill")
    ]

    private let sampleWords = [
        "Medium", "Latte", "Vanilla", "Special", "Order", "Whole", "Please", "Morning"
    ]

    public init(state: AppState) {
        self.state = state
        _stage = State(initialValue: state.hasSeenDialSceneIntro ? .scenarios : .intro)
    }

    public var body: some View {
        ZStack(alignment: .top) {
            StamerleeTheme.backgroundDark.ignoresSafeArea()

            BackgroundImagesDecorationView()

            switch stage {
            case .intro:
                DialSceneIntroView(
                    state: state,
                    onBack: {
                        state.navigate(to: .homeDashboard, forward: false)
                    },
                    onContinue: {
                        // Ignore stray/late calls once we've left the intro
                        guard stage == .intro else { return }
                        state.hasSeenDialSceneIntro = true
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                            stage = .scenarios
                        }
                    }
                )
            case .scenarios:
                scenarioView
            case .conversation:
                conversationView
            case .analysis:
                analysisView
            }
        }
    }

    private var header: some View {
        HStack {
            BackNavButton {
                state.navigate(to: .homeDashboard, forward: false)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    private var scenarioView: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Text("Dial Scene")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.top, 22)
            Text("Practice real life conversations through\ninteractive scenarios.")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .padding(.bottom, 24)

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(scenarios, id: \.0) { scenario in
                        Button {
                            selectedScenario = scenario.0
                            stage = .conversation
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: scenario.2)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 38)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(scenario.0)
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                    Text(scenario.1)
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundStyle(StamerleeTheme.textSecondaryDark)
                                }
                                .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 38, height: 38)
                                    .background(Color(red: 73 / 255, green: 65 / 255, blue: 174 / 255))
                                    .clipShape(Circle())
                            }
                            .padding(.horizontal, 14)
                            .frame(height: 72)
                            .background(Color.white.opacity(0.07))
                            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.white.opacity(0.08)))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.haptic)
                    }
                }
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
            Spacer()
        }
    }

    private var conversationView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                header
                Spacer()
            }
            Text(selectedScenario)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.top, 20)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(Array(conversationMessages.prefix(conversationStep + 1).enumerated()), id: \.offset) { index, message in
                            bubble(message.speaker, message.text, isUser: message.isUser)
                                .id(index)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 8)
                }
                .scrollIndicators(.hidden)
                .frame(maxHeight: .infinity)
                .onChange(of: conversationStep) { _, newStep in
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(newStep, anchor: .bottom)
                    }
                }
            }

            // Mic only. Animates while listening; Finish appears once the user has spoken.
            VStack(spacing: 14) {
                DialMicButton(phase: micPhase, action: micTapped)

                Text(micHint)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(red: 195 / 255, green: 190 / 255, blue: 220 / 255))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 28)
                    .frame(height: 40, alignment: .top)
                    .animation(.easeInOut(duration: 0.2), value: micPhase)
            }
            .frame(maxWidth: .infinity)

            // Fixed-height slot so the mic never jumps when Finish appears
            ZStack {
                if hasSpoken {
                    DialGlassActionButton(title: "Finish") {
                        turnTask?.cancel()
                        state.hasCompletedDialScene = true
                        stage = .analysis
                    }
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .frame(height: 56)
            .padding(.top, 24)
            .padding(.bottom, 28)
        }
        .onAppear {
            conversationStep = 0
            micPhase = .idle
            hasSpoken = false
        }
        .onDisappear { turnTask?.cancel() }
        .sensoryFeedback(.impact(weight: .heavy), trigger: micPhase)
    }

    // MARK: - Mic turn logic

    private var userHasNextLine: Bool {
        let next = conversationStep + 1
        return next < conversationMessages.count && conversationMessages[next].isUser
    }

    private var nextUserLine: String? {
        userHasNextLine ? conversationMessages[conversationStep + 1].text : nil
    }

    private var micHint: String {
        switch micPhase {
        case .listening: return "Listening"
        case .idle:
            if let line = nextUserLine { return "Tap and hold to speak" }
            return "Great job! Tap Finish when you're ready"
        }
    }

    private func micTapped() {
        switch micPhase {
        case .idle:
            guard userHasNextLine else { return }
            startTurn()
        case .listening:
            endTurn()
        }
    }

    /// User taps the mic: start listening. The mic just pulses; nothing is revealed yet.
    private func startTurn() {
        turnTask?.cancel()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) { micPhase = .listening }
        isListening = true
        // TODO: hook real speech recognition in here (start recording).
    }

    /// User taps the mic again ("I'm done"): show their message, then the other
    /// person replies. Everything is driven by the user's taps, not by a timer.
    private func endTurn() {
        guard micPhase == .listening else { return }
        // TODO: stop real speech recognition here.
        withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) { micPhase = .idle }
        isListening = false

        // Reveal the user's line right now
        guard userHasNextLine else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            conversationStep += 1
            hasSpoken = true               // Finish button appears
        }

        // Then the other person answers (short natural pause only)
        let next = conversationStep + 1
        guard next < conversationMessages.count, !conversationMessages[next].isUser else { return }
        turnTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(700))
            guard !Task.isCancelled else { return }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { conversationStep += 1 }
        }
    }

    /// Each scenario has its own script: bot line, your line, bot, you, bot, you.
    private var conversationMessages: [(speaker: String, text: String, isUser: Bool)] {
        switch selectedScenario {
        case "Ordering at a Restaurant":
            return [
                ("Waiter", "Welcome! Are you ready to order?", false),
                ("You", "Yes, I'd like the pasta, please.", true),
                ("Waiter", "Excellent choice. Anything to drink?", false),
                ("You", "A glass of water, please.", true),
                ("Waiter", "Would you like to see the dessert menu later?", false),
                ("You", "Maybe later. Thank you!", true)
            ]
        case "Checking into a Hotel":
            return [
                ("Receptionist", "Good evening! Do you have a reservation?", false),
                ("You", "Yes, it's under the name Alex.", true),
                ("Receptionist", "Found it! Two nights, is that right?", false),
                ("You", "Yes, that's correct.", true),
                ("Receptionist", "Here's your key. Breakfast starts at 7 AM.", false),
                ("You", "Thank you very much!", true)
            ]
        case "At a Hair Salon":
            return [
                ("Stylist", "Hi there! What are we doing today?", false),
                ("You", "Just a trim, please.", true),
                ("Stylist", "Sure! How much would you like off?", false),
                ("You", "About two inches, please.", true),
                ("Stylist", "Perfect. Would you like a wash first?", false),
                ("You", "Yes, please. Thank you!", true)
            ]
        case "At a Grocery Store":
            return [
                ("Staff", "Hello! Can I help you find something?", false),
                ("You", "Where can I find the milk?", true),
                ("Staff", "Aisle three, right next to the eggs.", false),
                ("You", "Thank you. Do you have fresh bread?", true),
                ("Staff", "Yes, the bakery section is at the back.", false),
                ("You", "Great, thanks for your help!", true)
            ]
        default: // Ordering at a Café
            return [
                ("Barista", "Hi! What can I get for you today?", false),
                ("You", "A medium iced latte, please.", true),
                ("Barista", "Sure! Any milk preference?", false),
                ("You", "Whole milk, with one vanilla.", true),
                ("Barista", "Got it! Anything else today?", false),
                ("You", "No, that's all. Thank you!", true)
            ]
        }
    }

    private func bubble(_ speaker: String, _ text: String, isUser: Bool) -> some View {
        HStack {
            if isUser { Spacer() }
            VStack(alignment: .leading, spacing: 4) {
                Text(speaker)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                Text(text)
                    .font(.system(size: 13, design: .rounded))
                    .lineSpacing(2)
            }
            .foregroundStyle(isUser ? .black : .white)
            .padding(14)
            .background(isUser ? Color(red: 226 / 255, green: 229 / 255, blue: 250 / 255) : Color(red: 35 / 255, green: 39 / 255, blue: 78 / 255))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            if !isUser { Spacer() }
        }
    }

    private var analysisView: some View {
        ExerciseAnalysisSkeletonView(
            scoreText: "8.4",
            maxScoreText: "/ 10",
            subtitle: "Great job completing your conversation session!",
            affirmation: "Great progress today!",
            onDone: {
                state.navigate(to: .homeDashboard)
            }
        )
    }
}


// MARK: - Dial Mic Button Style
private struct DialMicButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
            .sensoryFeedback(trigger: configuration.isPressed) { _, isPressed in
                isPressed ? .impact(weight: .light) : nil
            }
    }
}

// MARK: - Dial Mic Button (iOS-native size & feedback, animated while live)
enum DialMicPhase: Equatable {
    case idle
    case listening
}

private struct DialMicButton: View {
    let phase: DialMicPhase
    let action: () -> Void

    private var isActive: Bool { phase != .idle }

    var body: some View {
        Button(action: action) {
            // Always animating: a calm idle pulse, a faster/stronger one while live
            TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { context in
                let t = context.date.timeIntervalSinceReferenceDate
                let pulse = (sin(t * (isActive ? 3.0 : 1.8)) + 1) / 2

                ZStack {
                    // Expanding ripples (soft when idle, stronger when live)
                    ForEach(0..<2, id: \.self) { k in
                        let speed = isActive ? 0.7 : 0.35
                        let p = (t * speed + Double(k) * 0.5).truncatingRemainder(dividingBy: 1.0)
                        Circle()
                            .stroke(StamerleeTheme.primaryBlue.opacity((1 - p) * (isActive ? 0.45 : 0.20)), lineWidth: 1.5)
                            .frame(width: 96, height: 96)
                            .scaleEffect(1.0 + p * 0.35)
                    }

                    // Faint static outer ring
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        .frame(width: 104, height: 104)
                        .scaleEffect(1.0 + 0.04 * pulse)

                    // Deep navy back ring
                    Circle()
                        .fill(Color(red: 32 / 255, green: 26 / 255, blue: 58 / 255))
                        .frame(width: 78, height: 78)
                        .scaleEffect(1.0 + (isActive ? 0.06 : 0.03) * pulse)

                    // Core purple glass button
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
                        .frame(width: 60, height: 60)
                        .scaleEffect(1.0 + (isActive ? 0.03 : 0.015) * pulse)
                        .overlay(
                            Circle().stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.7), Color.white.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                        )
                        .shadow(
                            color: StamerleeTheme.primaryBlue.opacity(isActive ? 0.85 : 0.45),
                            radius: isActive ? 12 : 8
                        )

                    // Same mic icon always; the pulse alone shows it's live
                    Image(systemName: "mic.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 120, height: 120)
                .contentShape(Circle())
                .animation(.easeInOut(duration: 0.25), value: isActive)
            }
        }
        .buttonStyle(DialMicButtonStyle())
        .accessibilityLabel(isActive ? "Stop microphone" : "Start microphone")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview("Dial Scene") {
    DialSceneView(
        state: AppState()
    )
}



