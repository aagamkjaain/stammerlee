import SwiftUI

// MARK: - Fluency Lap Onboarding & 30-Second Sprint Experience
// 3-Step Animated Flow:
// 1. "Daily challenge" preparation
// 2. Timed warm-up with spoken word set and purple mic
// 3. "Well done!" celebration and navigation to Fluency Lap

public enum FluencyLapFlowStep: Int, CaseIterable {
    case countdown = 0
    case encouragement = 1
    case practice = 2
    case wellDone = 3
}

public struct FluencyLapIntroView: View {
    @Bindable public var state: AppState

    @State private var step: FluencyLapFlowStep
    @State private var timeRemaining: Int = 30
    @State private var timerTask: Task<Void, Never>? = nil
    @State private var countdownTask: Task<Void, Never>? = nil
    @State private var countdownValue = 3
    @State private var isCountdownNumberVisible = false
    @State private var currentWordIndex: Int = 0
    @State private var isListening: Bool = false
    @State private var pulseMic: Bool = false
    @State private var floatAnim: Bool = false
    @State private var confettiCounter: Int = 0
    @State private var wellDoneBurst: Bool = false
    @State private var speakTask: Task<Void, Never>? = nil

    // Curated warm-up sprint words
    private let sprintWords: [String] = [
        "Water",
        "Sweet",
        "Sunrise",
        "Breathe",
        "Gentle",
        "River",
        "Calm",
        "Bright"
    ]

    // Pure yellow palette for ConfettiSwiftUI celebration particles
    private let yellowConfettiColors: [Color] = [
        Color.yellow,
        Color(red: 255 / 255, green: 215 / 255, blue: 0 / 255),    // Bright Gold
        Color(red: 255 / 255, green: 238 / 255, blue: 88 / 255),   // Radiant Sunshine Yellow
        Color(red: 255 / 255, green: 249 / 255, blue: 196 / 255),  // Soft Pastel Yellow
        Color(red: 255 / 255, green: 179 / 255, blue: 0 / 255)     // Warm Amber Gold
    ]

    public init(state: AppState, startsWithCountdown: Bool = false) {
        self.state = state
        _step = State(initialValue: startsWithCountdown ? .countdown : .encouragement)
    }

    private var currentWord: String {
        guard !sprintWords.isEmpty else { return "" }
        return sprintWords[min(currentWordIndex, sprintWords.count - 1)]
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

                // Animated Clouds Layer with Edge-to-Edge Bleed
                cloudsLayer(w: w, h: h)

                // Subtle Yellow Confetti Effect using ConfettiSwiftUI (Step 3: Well done!)
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
                    if step != .countdown {
                        // Top Navigation Bar (Glass close button only, no back button)
                        topBar
                            .padding(.horizontal, 24)
                            .padding(.top, 14)
                    }

                    Spacer(minLength: 0)

                    // Step Content
                    Group {
                        switch step {
                        case .countdown:
                            countdownContent
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
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                floatAnim = true
            }
            if step == .countdown {
                startCountdown()
            }
        }
        .onDisappear {
            timerTask?.cancel()
            countdownTask?.cancel()
            speakTask?.cancel()
        }
    }

    // MARK: - Top Navigation Bar
    private var topBar: some View {
        HStack {
            Spacer()

            GlassCloseButton {
                redirectToFluencyLap()
            }
            .accessibilityLabel("Close")
        }
    }

    private var countdownContent: some View {
        VStack(spacing: 12) {
            Text("Starting in")
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundStyle(Color(red: 194 / 255, green: 192 / 255, blue: 218 / 255))

            Text("\(countdownValue)")
                .font(.system(size: 96, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .scaleEffect(isCountdownNumberVisible ? 1 : 0.55)
                .opacity(isCountdownNumberVisible ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Step 1: Encouragement & Prep Screen
    private func encouragementContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 16) {
            Spacer()

            TwinklingStarView(assetName: "Sparkle-2", size: 30, delay: 0.1, duration: 1.0)

            Text("Daily challenge")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Speak as many words as you comfortably can\nwithin 30 seconds.")
                .font(.system(size: 19, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()

            VStack {
                GlassActionButton(title: "Begin") {
                    startSprint()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Step 2: Practice with 30-Second Timer Progress Bar & Words
    private func practiceContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 0) {
            // Live Countdown Timer with Progress Bar
            VStack(spacing: 8) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "stopwatch.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(timeRemaining <= 5 ? Color(red: 255 / 255, green: 110 / 255, blue: 110 / 255) : Color(red: 180 / 255, green: 165 / 255, blue: 255 / 255))

                        Text("\(timeRemaining)s")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundStyle(timeRemaining <= 5 ? Color(red: 255 / 255, green: 120 / 255, blue: 120 / 255) : .white)
                    }

                    Spacer()

                    Text("Demo Lap")
                        .font(.system(size: 12.5, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 194 / 255, green: 192 / 255, blue: 218 / 255))
                }

                GeometryReader { geo in
                    let width = geo.size.width
                    let progress = CGFloat(30 - timeRemaining) / 30.0
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 6)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 160 / 255, green: 130 / 255, blue: 255 / 255),
                                        Color(red: 90 / 255, green: 200 / 255, blue: 255 / 255)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(6, width * progress), height: 6)
                            .animation(.linear(duration: 1.0), value: timeRemaining)
                    }
                }
                .frame(height: 6)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)

            Spacer()

            // Current Word Display
            Text(currentWord)
                .font(.system(size: 52, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: StamerleeTheme.primaryBlue.opacity(0.45), radius: 14)
                .id(currentWordIndex)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))

            Spacer()

            // Universal Purple Glass Microphone Button
            UniversalMicrophoneButton(isListening: isListening, disabled: false) {
                toggleListening()
            }

            Text(isListening ? "Listening... great pace!" : "Tap microphone to speak word")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(Color(red: 195 / 255, green: 190 / 255, blue: 220 / 255))
                .padding(.top, 16)
                .padding(.bottom, 48)
        }
    }

    // MARK: - Step 3: Well Done! Screen with Yellow Confetti & Redirection
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

                    Text("Well done!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.top, 4)

                    Text("You're ready to start the 30-second Fluency Lap.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundStyle(Color(red: 200 / 255, green: 195 / 255, blue: 230 / 255))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
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

            VStack(spacing: 16) {
                GlassActionButton(title: "Continue") {
                    redirectToFluencyLap()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.68)) {
                wellDoneBurst = true
            }
        }
    }

    // MARK: - Animated Cloud System
    @ViewBuilder
    private func cloudsLayer(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            // Top-Left Drifting Cloud
            assetImage("Drifting cloud-1")
                .scaledToFit()
                .frame(width: 130)
                .position(x: w * 0.06, y: h * 0.08)
                .offset(y: floatAnim ? -4 : 4)

            // Top-Right Drifting Cloud
            assetImage("Drifting cloud-4")
                .scaledToFit()
                .frame(width: 125)
                .position(x: w * 0.94, y: h * 0.16)
                .offset(y: floatAnim ? 3 : -3)

            // Mid-Right Drifting Cloud
            assetImage("Drifting cloud-3")
                .scaledToFit()
                .frame(width: 115)
                .position(x: w * 1.08, y: h * 0.26)
                .offset(y: floatAnim ? -5 : 5)

            // Bottom-Left Drifting Cloud
            assetImage("Drifting cloud-2")
                .scaledToFit()
                .frame(width: 140)
                .position(x: w * 0.10, y: h * 0.88)
                .offset(y: floatAnim ? 4 : -4)

            // Bottom Billowing Cloud Bank 1 (Right edge)
            assetImage("Cloud bank")
                .scaledToFit()
                .frame(width: w * 0.70)
                .position(x: w * 0.82, y: h * 0.86)
                .offset(y: floatAnim ? -3 : 3)

            // Bottom Billowing Cloud Bank 2 (Left edge)
            assetImage("Cloud bank-2")
                .scaledToFit()
                .frame(width: w * 0.66)
                .position(x: w * 0.20, y: h * 0.88)
                .offset(y: floatAnim ? 3 : -3)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Natural Twinkling Stars & Motes Layer
    @ViewBuilder
    private func twinklingStarsLayer(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            TwinklingStarView(assetName: "Sparkle", size: 28, delay: 0.0, duration: 1.1)
                .position(x: w * 0.32, y: h * 0.07)

            TwinklingStarView(assetName: "Sparkle", size: 24, delay: 0.4, duration: 1.35)
                .position(x: w * 0.74, y: h * 0.14)

            TwinklingStarView(assetName: "Floating mote", size: 10, delay: 0.2, duration: 0.95)
                .position(x: w * 0.18, y: h * 0.58)

            TwinklingStarView(assetName: "Sparkle-2", size: 26, delay: 0.6, duration: 1.2)
                .position(x: w * 0.84, y: h * 0.62)

            TwinklingStarView(assetName: "Floating mote", size: 10, delay: 0.8, duration: 1.4)
                .position(x: w * 0.35, y: h * 0.68)
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

    // MARK: - Step Navigation & Practice Flow
    private func goToStep(_ next: FluencyLapFlowStep) {
        withAnimation(.spring(response: 0.72, dampingFraction: 0.8)) {
            step = next
        }
        if next == .wellDone {
            confettiCounter += 1
        }
    }

    private func startSprint() {
        goToStep(.practice)
        startTimer()
    }

    private func startCountdown() {
        countdownTask?.cancel()
        countdownTask = Task { @MainActor in
            for value in stride(from: 3, through: 1, by: -1) {
                countdownValue = value
                withAnimation(.spring(response: 0.42, dampingFraction: 0.56)) {
                    isCountdownNumberVisible = true
                }

                try? await Task.sleep(nanoseconds: 820_000_000)
                guard !Task.isCancelled else { return }

                withAnimation(.easeOut(duration: 0.18)) {
                    isCountdownNumberVisible = false
                }

                try? await Task.sleep(nanoseconds: 180_000_000)
                guard !Task.isCancelled else { return }
            }

            state.navigate(to: .fluencyLapPractice)
        }
    }

    private func startTimer() {
        timerTask?.cancel()
        timeRemaining = 30
        currentWordIndex = 0

        timerTask = Task { @MainActor in
            while timeRemaining > 0 && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { break }
                timeRemaining -= 1
            }
            if timeRemaining == 0 {
                completeSprint()
            }
        }
    }

    private func toggleListening() {
        if isListening {
            speakTask?.cancel()
            withAnimation(.easeInOut(duration: 0.25)) {
                isListening = false
                pulseMic = false
                advanceWord()
            }
        } else {
            isListening = true
            pulseMic = true
            UIImpactFeedbackGenerator(style: .light).impactOccurred()

            speakTask?.cancel()
            speakTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 4_000_000_000)
                guard !Task.isCancelled else { return }

                withAnimation(.easeInOut(duration: 0.25)) {
                    isListening = false
                    pulseMic = false
                    advanceWord()
                }
            }
        }
    }

    private func advanceWord() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        currentWordIndex = (currentWordIndex + 1) % max(sprintWords.count, 1)
    }

    private func completeSprint() {
        timerTask?.cancel()
        goToStep(.wellDone)
    }

    private func redirectToFluencyLap() {
        timerTask?.cancel()
        state.hasCompletedFluencyLapIntro = true
        state.fluencyLapWordCount = 20
        state.navigate(to: .fluencyLapPractice, forward: true)
    }
}

