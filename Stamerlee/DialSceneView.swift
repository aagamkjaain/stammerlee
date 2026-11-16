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
    @State private var showConfetti: Bool = false
    @State private var wellDoneBurst: Bool = false

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

                // Animated Clouds Layer
                cloudsLayer(w: w, h: h)

                // Confetti Explosion Layer (Triggers on Step 4: Well done!)
                if showConfetti {
                    DialConfettiCelebrationView()
                        .position(x: w * 0.5, y: h * 0.44)
                        .allowsHitTesting(false)
                        .zIndex(10)
                }

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
            BackNavButton {
                if let onBack {
                    onBack()
                } else if step == .intro {
                    state.navigate(to: .homeDashboard, forward: false)
                } else if step == .encouragement {
                    goToStep(.intro)
                } else if step == .conversation {
                    goToStep(.encouragement)
                } else {
                    state.navigate(to: .homeDashboard, forward: false)
                }
            }
            Spacer()
        }
    }

    // MARK: - Step 1: Intro Screen
    private func introContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer()

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

            // Lowered Card & Glass Button inside the lower cloud
            VStack(spacing: 16) {
                // Glass-effect Instruction Pill Card
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 236 / 255, green: 230 / 255, blue: 255 / 255))
                            .frame(width: 42, height: 42)

                        Image(systemName: "phone.bubble.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(StamerleeTheme.primaryBlue)
                    }

                    Text("Practice real-life conversations to build confidence and fluency during calls")
                        .font(.system(size: 13.5, weight: .regular, design: .rounded))
                        .foregroundStyle(Color(red: 88 / 255, green: 78 / 255, blue: 124 / 255))
                        .lineSpacing(2.5)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.white.opacity(0.92))
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.white.opacity(0.8), lineWidth: 1)
                    }
                )
                .shadow(color: Color(red: 120 / 255, green: 90 / 255, blue: 180 / 255).opacity(0.12), radius: 10, x: 0, y: 4)

                // Purple Glass Effect CTA Button
                DialGlassActionButton(title: "Begin") {
                    goToStep(.encouragement)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Step 2: Encouragement Screen
    private func encouragementContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 16) {
            Spacer()

            HStack(spacing: 10) {
                DialTwinklingStarView(assetName: "Sparkle-2", size: 28, delay: 0.1, duration: 1.0)

                Text("Quick Demo")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            Text("Let's see how Dial\nScene calls work")
                .font(.system(size: 21, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text("The caller will speak to you,\nand you reply naturally with your voice")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(Color(red: 195 / 255, green: 185 / 255, blue: 230 / 255))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.top, 4)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            goToStep(.conversation)
        }
        .task {
            try? await Task.sleep(nanoseconds: 2_400_000_000)
            if step == .encouragement {
                goToStep(.conversation)
            }
        }
    }

    // MARK: - Step 3: Interactive Call Conversation Demo
    private func conversationContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: 4)

            // Instruction Title
            Text("Simulated Phone Conversation")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(red: 220 / 255, green: 215 / 255, blue: 245 / 255))
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)

            // Phone Conversation Container Card
            VStack(spacing: 10) {
                // Call Header
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 60 / 255, green: 45 / 255, blue: 110 / 255))
                            .frame(width: 32, height: 32)
                        Image(systemName: "phone.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color(red: 140 / 255, green: 220 / 255, blue: 180 / 255))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Practice Caller")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                            Text("Call Connected")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.green.opacity(0.85))
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 4)

                Divider()
                    .background(Color.white.opacity(0.12))

                // Chat Messages Scroll/Stack
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 10) {
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
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                    .frame(maxHeight: 210)
                    .onChange(of: convoTurn) { _, newTurn in
                        withAnimation {
                            proxy.scrollTo(newTurn + 1, anchor: .bottom)
                        }
                    }
                }
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(red: 22 / 255, green: 20 / 255, blue: 45 / 255).opacity(0.88))
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.20), lineWidth: 1)
                }
            )
            .shadow(color: StamerleeTheme.primaryBlue.opacity(0.3), radius: 14, x: 0, y: 6)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            // Dynamic Microphone Prompt & Button
            VStack(spacing: 10) {
                // Instructions cue
                Text(micPromptText)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(red: 215 / 255, green: 210 / 255, blue: 245 / 255))
                    .multilineTextAlignment(.center)
                    .frame(height: 20)

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
                .disabled(isListening || convoTurn == 1 || convoTurn == 3 || convoTurn >= 4)
                .opacity((convoTurn >= 4) ? 0.5 : 1.0)
            }
            .padding(.bottom, 16)

            Spacer(minLength: 0)
        }
    }

    private var micPromptText: String {
        if isListening {
            return "Listening... speaking your reply"
        } else if convoTurn == 0 {
            return "Tap microphone to say: \"I'm doing well, thank you!\""
        } else if convoTurn == 2 {
            return "Tap microphone to say: \"Yes, ready to practice!\""
        } else if convoTurn >= 4 {
            return "Call completed! Good job."
        } else {
            return "Caller is speaking..."
        }
    }

    private func chatBubble(text: String, isUser: Bool) -> some View {
        HStack {
            if isUser { Spacer(minLength: 40) }

            Text(text)
                .font(.system(size: 13.5, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
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
                                        Color(red: 50 / 255, green: 45 / 255, blue: 85 / 255),
                                        Color(red: 40 / 255, green: 35 / 255, blue: 70 / 255)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                )
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)

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
                // Wrap up and transition to Well Done after 1.8s
                try? await Task.sleep(nanoseconds: 1_800_000_000)
                goToStep(.wellDone)
            }
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

                    Text("You completed your demo call with ease")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 195 / 255, green: 185 / 255, blue: 230 / 255))
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)

                    // 3-4s gap indicator before real practice starts
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(Color(red: 195 / 255, green: 175 / 255, blue: 255 / 255))
                            .scaleEffect(0.85)
                        Text("Starting real call in a moment...")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(red: 210 / 255, green: 205 / 255, blue: 240 / 255))
                    }
                    .padding(.top, 10)
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
            DialGlassActionButton(title: "Start Call Now") {
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
            showConfetti = true
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                wellDoneBurst = true
            }
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 3_500_000_000)
                if step == .wellDone {
                    redirectToRealPractice()
                }
            }
        }
    }

    private func redirectToRealPractice() {
        state.hasSeenDialSceneIntro = true
        if let onContinue {
            onContinue()
        } else {
            state.navigate(to: .dialScene)
        }
    }

    // MARK: - Animated Clouds Layer
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
                .opacity((step == .encouragement || step == .conversation) ? 1.0 : 0.0)
                .offset(y: floatAnim ? -5 : 5)
                .animation(.spring(response: 0.75, dampingFraction: 0.8), value: step)

            // 4. Bottom-Left Drifting Cloud
            assetImage("Drifting cloud-2")
                .scaledToFit()
                .frame(width: 142)
                .position(x: w * 0.10, y: step == .wellDone ? h * 0.88 : (step == .encouragement ? h * 0.90 : h * 1.25))
                .opacity(step == .intro ? 0.0 : 1.0)
                .offset(y: floatAnim ? 4 : -4)
                .animation(.spring(response: 0.75, dampingFraction: 0.8), value: step)

            // 5. Cloud Landscape Bank (Screen 1 lowered)
            assetImage("Cloud landscape")
                .scaledToFill()
                .frame(width: w * 1.08)
                .position(x: w * 0.5, y: step == .intro ? (h * 0.93) : (h + 350))
                .opacity(step == .intro ? 1.0 : 0.0)
                .animation(.spring(response: 0.82, dampingFraction: 0.82), value: step)

            // 6. Bottom Billowing Cloud Bank 1
            assetImage("Cloud bank")
                .scaledToFit()
                .frame(width: w * 0.70)
                .position(bottomBankRightPosition(w: w, h: h))
                .opacity((step == .conversation || step == .wellDone) ? 1.0 : 0.0)
                .offset(y: floatAnim ? -3 : 3)
                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: step)

            // 7. Bottom Billowing Cloud Bank 2
            assetImage("Cloud bank-2")
                .scaledToFit()
                .frame(width: w * 0.66)
                .position(bottomBankLeftPosition(w: w, h: h))
                .opacity((step == .conversation || step == .wellDone) ? 1.0 : 0.0)
                .offset(y: floatAnim ? 3 : -3)
                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: step)
        }
        .allowsHitTesting(false)
    }

    private func topLeftCloudPosition(w: CGFloat, h: CGFloat) -> CGPoint {
        switch step {
        case .intro: return CGPoint(x: w * 0.06, y: h * 0.055)
        case .encouragement: return CGPoint(x: w * 0.06, y: h * 0.08)
        case .conversation: return CGPoint(x: w * 0.06, y: h * 0.08)
        case .wellDone: return CGPoint(x: w * -0.06, y: h * 0.08)
        }
    }

    private func topRightCloudPosition(w: CGFloat, h: CGFloat) -> CGPoint {
        switch step {
        case .intro: return CGPoint(x: w * 0.94, y: h * 0.065)
        case .encouragement: return CGPoint(x: w * 1.15, y: h * 0.065)
        case .conversation: return CGPoint(x: w * 0.94, y: h * 0.18)
        case .wellDone: return CGPoint(x: w * 1.06, y: h * 0.10)
        }
    }

    private func midRightCloudPosition(w: CGFloat, h: CGFloat) -> CGPoint {
        switch step {
        case .intro: return CGPoint(x: w * 1.25, y: h * 0.32)
        case .encouragement: return CGPoint(x: w * 0.96, y: h * 0.28)
        case .conversation: return CGPoint(x: w * 0.94, y: h * 0.26)
        case .wellDone: return CGPoint(x: w * 1.25, y: h * 0.30)
        }
    }

    private func bottomBankLeftPosition(w: CGFloat, h: CGFloat) -> CGPoint {
        switch step {
        case .intro: return CGPoint(x: w * 0.2, y: h * 1.25)
        case .encouragement: return CGPoint(x: w * 0.1, y: h * 1.25)
        case .conversation: return CGPoint(x: w * 0.20, y: h * 0.88)
        case .wellDone: return CGPoint(x: w * 0.05, y: h * 0.88)
        }
    }

    private func bottomBankRightPosition(w: CGFloat, h: CGFloat) -> CGPoint {
        switch step {
        case .intro: return CGPoint(x: w * 0.8, y: h * 1.25)
        case .encouragement: return CGPoint(x: w * 0.9, y: h * 1.25)
        case .conversation: return CGPoint(x: w * 0.82, y: h * 0.86)
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
    }
}

// MARK: - Dial Glass Action Button
private struct DialGlassActionButton: View {
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

// MARK: - Confetti Particle Celebration System
private struct DialConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let shape: Int
    let size: CGFloat
    let angle: Double
    let distance: CGFloat
    let spinSpeed: Double
}

private struct DialConfettiCelebrationView: View {
    @State private var progress: CGFloat = 0

    private let particles: [DialConfettiParticle] = {
        let colors: [Color] = [
            Color(red: 255 / 255, green: 215 / 255, blue: 0 / 255),
            Color(red: 255 / 255, green: 185 / 255, blue: 0 / 255),
            Color(red: 139 / 255, green: 112 / 255, blue: 245 / 255),
            Color(red: 185 / 255, green: 155 / 255, blue: 255 / 255),
            Color(red: 56 / 255, green: 189 / 255, blue: 248 / 255),
            Color(red: 251 / 255, green: 113 / 255, blue: 133 / 255),
            Color.white
        ]
        return (0..<48).map { i in
            DialConfettiParticle(
                color: colors[i % colors.count],
                shape: i % 3,
                size: CGFloat.random(in: 6...12),
                angle: Double.random(in: 0...(2 * .pi)),
                distance: CGFloat.random(in: 70...210),
                spinSpeed: Double.random(in: 360...1080)
            )
        }
    }()

    var body: some View {
        ZStack {
            ForEach(particles) { p in
                let curDist = p.distance * progress
                let x = cos(p.angle) * curDist
                let y = sin(p.angle) * curDist + (progress * progress * 35)
                let opacity = progress < 0.15 ? (progress / 0.15) : max(0, 1.0 - (progress - 0.5) / 0.5)

                Group {
                    if p.shape == 0 {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(p.color)
                            .frame(width: p.size * 0.55, height: p.size * 1.3)
                    } else if p.shape == 1 {
                        Circle()
                            .fill(p.color)
                            .frame(width: p.size * 0.75, height: p.size * 0.75)
                    } else {
                        Image(systemName: "sparkle")
                            .font(.system(size: p.size))
                            .foregroundStyle(p.color)
                    }
                }
                .rotationEffect(.degrees(p.spinSpeed * Double(progress)))
                .offset(x: x, y: y)
                .opacity(opacity)
                .scaleEffect(progress < 0.2 ? progress * 5 : max(0.4, 1.1 - progress * 0.5))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 2.0)) {
                progress = 1.0
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
    @State private var isDAFActive: Bool = false
    @State private var isListening: Bool = false
    @State private var conversationStep = 0

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
                if stage == .scenarios {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        stage = .intro
                    }
                } else {
                    stage = .scenarios
                }
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
                .foregroundStyle(StamerleeTheme.textSecondaryDark)
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .padding(.bottom, 24)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(scenarios, id: \.0) { scenario in
                        Button {
                            selectedScenario = scenario.0
                            stage = .conversation
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: scenario.2)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 36)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(scenario.0)
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                    Text(scenario.1)
                                        .font(.system(size: 11, design: .rounded))
                                        .foregroundStyle(StamerleeTheme.textSecondaryDark)
                                }
                                .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "phone.fill")
                                    .foregroundStyle(.white)
                                    .padding(8)
                                    .background(Color(red: 73 / 255, green: 65 / 255, blue: 174 / 255))
                                    .clipShape(Circle())
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 62)
                            .background(Color.white.opacity(0.07))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08)))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.haptic)
                    }
                }
                .padding(.horizontal, 24)
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
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isDAFActive.toggle()
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "headphones")
                            .font(.system(size: 12, weight: .bold))
                        Text("DAF")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(isDAFActive ? StamerleeTheme.primaryBlue : StamerleeTheme.primaryBlueDark)
                    .clipShape(Capsule())
                }
                .padding(.trailing, 24)
            }
            Text(selectedScenario)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.top, 20)

            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(conversationMessages.prefix(conversationStep + 1).enumerated()), id: \.offset) { _, message in
                    bubble(message.speaker, message.text, isUser: message.isUser)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            Spacer()

            SpeechMicrophoneButton(isListening: $isListening) {
                guard conversationStep + 1 < conversationMessages.count else { return }
                isListening = true
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    conversationStep += 1
                }
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(500))
                    isListening = false
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 24)

            PrimaryActionButton(title: "Finish") {
                state.hasCompletedDialScene = true
                stage = .analysis
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .sensoryFeedback(.impact(weight: .light), trigger: isDAFActive)
        .sensoryFeedback(.impact(weight: .heavy), trigger: isListening)
    }

    private var conversationMessages: [(speaker: String, text: String, isUser: Bool)] {
        [
            ("Barista", "Hi! What can I get for you today?", false),
            ("You", "A medium iced latte with whole milk and one pump of vanilla, please.", true),
            ("Barista", "Of course! One medium iced vanilla latte. Anything else on the side?", false),
            ("You", "What about today's special?", true)
        ]
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
            subtitle: "Here's a summary of your conversation.",
            affirmation: "Great progress today!",
            onDone: {
                state.navigate(to: .homeDashboard)
            }
        )
    }
}


#Preview("Dial Scene") {
    DialSceneView(
        state: AppState()
    )
}
