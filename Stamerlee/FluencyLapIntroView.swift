import SwiftUI

// MARK: - Fluency Lap Onboarding & 30-Second Sprint Experience
// 4-Step Animated Flow matching the Prolonged Speech Onboarding Design:
// 1. "Let's start with Fluency Lap" with midnight sky, drifting clouds & glass button
// 2. "30-Second Sprint" preparation & airflow rhythm tips
// 3. Live 30-Second Countdown Timer with spoken word set, purple mic & Skip button
// 4. "Well done!" celebration with yellow Confetti explosion & navigation to Fluency Lap

public enum FluencyLapFlowStep: Int, CaseIterable {
    case intro = 1
    case encouragement = 2
    case practice = 3
    case wellDone = 4
}

public struct FluencyLapIntroView: View {
    @Bindable public var state: AppState

    @State private var step: FluencyLapFlowStep = .intro
    @State private var timeRemaining: Int = 30
    @State private var timerTask: Task<Void, Never>? = nil
    @State private var currentWordIndex: Int = 0
    @State private var isListening: Bool = false
    @State private var pulseMic: Bool = false
    @State private var floatAnim: Bool = false
    @State private var confettiCounter: Int = 0
    @State private var wellDoneBurst: Bool = false

    // Curated warm-up sprint words
    private let sprintWords: [String] = [
        "Sunrise",
        "Breathe",
        "Gentle",
        "River",
        "Calm",
        "Confidence",
        "Flow",
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

    public init(state: AppState) {
        self.state = state
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
                    // Top Navigation Bar (Glass close button only, no back button)
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
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                floatAnim = true
            }
        }
        .onDisappear {
            timerTask?.cancel()
        }
    }

    // MARK: - Top Navigation Bar (Glass close button only, no back button)
    private var topBar: some View {
        HStack {
            Spacer()

            GlassCloseButton {
                redirectToFluencyLap()
            }
            .accessibilityLabel("Close")
        }
    }

    // MARK: - Step 1: Intro Screen
    private func introContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer()

            // Heading positioned near the middle
            VStack(spacing: 8) {
                Text("Let's start with")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Fluency Lap")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("A 60-second lap designed to build speed, smoothness, and speech confidence under time pressure.")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(red: 200 / 255, green: 195 / 255, blue: 230 / 255))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
                    .padding(.top, 12)
            }
            .padding(.bottom, h * 0.10)

            Spacer()

            // CTA Button
            VStack(spacing: 16) {
                GlassActionButton(title: "Begin") {
                    goToStep(.encouragement)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
    }

    // MARK: - Step 2: Encouragement & Prep Screen
    private func encouragementContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 16) {
            Spacer()

            TwinklingStarView(assetName: "Sparkle-2", size: 30, delay: 0.1, duration: 1.0)

            Text("60-Second Lap")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Speak as many words as you comfortably can\nwithin 60 seconds.")
                .font(.system(size: 19, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            // Tip badge
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(red: 255 / 255, green: 215 / 255, blue: 0 / 255))
                Text("Tip: Maintain continuous airflow and a steady pace during the 60s lap")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(red: 220 / 255, green: 215 / 255, blue: 245 / 255))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.08), in: Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.14), lineWidth: 1))
            .padding(.top, 8)

            Spacer()

            VStack(spacing: 12) {
                GlassActionButton(title: "Ready!") {
                    startSprint()
                }

                Button {
                    redirectToFluencyLap()
                } label: {
                    Text("Skip Warm-up")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 185 / 255, green: 180 / 255, blue: 220 / 255))
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Step 3: Practice with 30-Second Timer, Words & Skip Button
    private func practiceContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 0) {
            // Live 30-Second Countdown Timer & Word Progress Bar
            HStack {
                // Countdown Pill
                HStack(spacing: 6) {
                    Image(systemName: "stopwatch.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(timeRemaining <= 5 ? Color(red: 255 / 255, green: 110 / 255, blue: 110 / 255) : Color(red: 180 / 255, green: 165 / 255, blue: 255 / 255))

                    Text("\(timeRemaining)s")
                        .font(.system(size: 17, weight: .bold, design: .monospaced))
                        .foregroundStyle(timeRemaining <= 5 ? Color(red: 255 / 255, green: 120 / 255, blue: 120 / 255) : .white)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.10), in: Capsule())
                .overlay(
                    Capsule().stroke(
                        timeRemaining <= 5 ? Color.red.opacity(0.5) : Color.white.opacity(0.18),
                        lineWidth: 1
                    )
                )

                Spacer()

                // Explicit Skip Button
                Button {
                    completeSprint()
                } label: {
                    HStack(spacing: 5) {
                        Text("Skip")
                            .font(.system(size: 13.5, weight: .semibold, design: .rounded))
                        Image(systemName: "forward.fill")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(Color.white.opacity(0.9))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color.white.opacity(0.12), in: Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.24), lineWidth: 1))
                }
                .buttonStyle(.haptic(weight: .light))
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)

            Spacer()

            // Instructions text
            Text("Speak the word with steady airflow")
                .font(.system(size: 14.5, weight: .medium, design: .rounded))
                .foregroundStyle(Color(red: 210 / 255, green: 205 / 255, blue: 240 / 255))
                .padding(.bottom, 22)

            // Current Word Display
            Text(currentWord)
                .font(.system(size: 52, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: StamerleeTheme.primaryBlue.opacity(0.45), radius: 14)
                .id(currentWordIndex)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))

            // Word counter progress
            Text("Word \(min(currentWordIndex + 1, sprintWords.count)) of \(sprintWords.count)")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color(red: 175 / 255, green: 165 / 255, blue: 215 / 255))
                .padding(.top, 10)
                .padding(.bottom, 32)

            // Purple Glass Microphone Button
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

            Text(isListening ? "Listening... great pace!" : "Tap microphone to speak word")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(Color(red: 195 / 255, green: 190 / 255, blue: 220 / 255))
                .padding(.top, 16)
                .padding(.bottom, 36)

            Spacer()
        }
    }

    // MARK: - Step 4: Well Done! Screen with Yellow Confetti & Redirection
    private func wellDoneContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                VStack(spacing: 12) {
                    // Celebration Starburst
                    ZStack {
                        HStack(spacing: 24) {
                            Capsule()
                                .fill(Color(red: 255 / 255, green: 220 / 255, blue: 100 / 255))
                                .frame(width: 3.5, height: 16)
                                .rotationEffect(.degrees(-32))
                                .offset(x: -8, y: -16)

                            Capsule()
                                .fill(Color(red: 255 / 255, green: 220 / 255, blue: 100 / 255))
                                .frame(width: 3.5, height: 16)
                                .rotationEffect(.degrees(32))
                                .offset(x: 8, y: -16)
                        }

                        TwinklingStarView(assetName: "Sparkle", size: 40, delay: 0.0, duration: 1.2)
                    }
                    .frame(height: 52)
                    .scaleEffect(wellDoneBurst ? 1.08 : 0.94)

                    Text("Well done!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.top, 4)

                    Text("You completed your warm-up sprint!\nYou're ready to start the 60-second Fluency Lap.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundStyle(Color(red: 200 / 255, green: 195 / 255, blue: 230 / 255))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                        .padding(.top, 4)
                }
            }

            Spacer()

            VStack(spacing: 16) {
                GlassActionButton(title: "Start 60s Practice") {
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

    private func triggerSpeak() {
        guard !isListening else { return }
        isListening = true
        pulseMic = true

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            guard !Task.isCancelled else { return }

            withAnimation(.easeInOut(duration: 0.25)) {
                isListening = false
                pulseMic = false

                if currentWordIndex + 1 < sprintWords.count {
                    currentWordIndex += 1
                } else {
                    completeSprint()
                }
            }
        }
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

