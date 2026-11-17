import SwiftUI

public struct FluencyLapPracticeView: View {
    @Bindable public var state: AppState
    @State private var showAnalysis: Bool = false
    @State private var scoredWords: Int = 40
    @State private var spokenWordsCount: Int = 0

    private let words = [
        "Water",
        "Sweet",
        "Today",
        "People",
        "Together",
        "Please",
        "Morning",
        "Family",
        "Coffee",
        "Window",
        "Garden",
        "Breathe",
        "Quiet",
        "Gentle",
        "River",
        "Courage",
        "Practice",
        "Balance",
        "Freedom",
        "Journey",
        "Progress",
        "Summer",
        "Bright",
        "Music",
        "Simple",
        "Smile",
        "Yellow",
        "Friend",
        "Silver",
        "Nature"
    ]

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        Group {
            if showAnalysis {
                ZStack(alignment: .top) {
                    StamerleeTheme.backgroundDark.ignoresSafeArea()

                    BackgroundImagesDecorationView()

                    ExerciseAnalysisSkeletonView(
                        scoreText: "\(scoredWords)",
                        scoreUnitText: "WORDS",
                        highScoreText: "HIGH SCORE: \(state.fluencyLapPersonalBest > 0 ? state.fluencyLapPersonalBest : 56) WORDS",
                        subtitle: "Great job completing your fluency lap session!",
                        affirmation: "You did great today!!",
                        onDone: {
                            state.hasCompletedFluencyLap = true
                            state.navigate(to: .homeDashboard, forward: false)
                        }
                    )
                }
            } else {
                SpeakPracticeScreen(
                    prompts: words,
                    showBackgroundImages: true,
                    timerDurationSeconds: 60,
                    showProgressCounter: false,
                    showMicrophonePrompt: false,
                    loopPrompts: true,
                    onBack: {
                        state.navigate(to: .homeDashboard, forward: false)
                    },
                    onFinish: {
                        let completedCount = spokenWordsCount > 0 ? spokenWordsCount : 40
                        scoredWords = completedCount
                        state.fluencyLapPreviousWordCount = completedCount
                        if completedCount > state.fluencyLapPersonalBest {
                            state.fluencyLapPersonalBest = completedCount
                        }
                        showAnalysis = true
                    },
                    onWordsCompletedCount: { count in
                        spokenWordsCount = count
                    }
                )
            }
        }
    }
}

public struct SpeakPracticeScreen: View {
    let prompts: [String]
    let instruction: String?
    let onBack: () -> Void
    let onFinish: () -> Void
    let allowsMultilinePrompt: Bool
    let showBackgroundImages: Bool
    let timerDurationSeconds: Int?
    let showProgressCounter: Bool
    let showMicrophonePrompt: Bool
    let loopPrompts: Bool
    let onWordsCompletedCount: ((Int) -> Void)?

    @State private var currentWordIndex = 0
    @State private var isListening = false
    @State private var pulse = false
    @State private var advanceTask: Task<Void, Never>?
    @State private var timeRemaining = 60
    @State private var sessionTimerTask: Task<Void, Never>?
    @State private var wordsCompleted = 0

    public init(
        prompts: [String],
        instruction: String? = nil,
        allowsMultilinePrompt: Bool = false,
        showBackgroundImages: Bool = false,
        timerDurationSeconds: Int? = nil,
        showProgressCounter: Bool = true,
        showMicrophonePrompt: Bool = true,
        loopPrompts: Bool = false,
        onBack: @escaping () -> Void,
        onFinish: @escaping () -> Void,
        onWordsCompletedCount: ((Int) -> Void)? = nil
    ) {
        self.prompts = prompts
        self.instruction = instruction
        self.allowsMultilinePrompt = allowsMultilinePrompt
        self.showBackgroundImages = showBackgroundImages
        self.timerDurationSeconds = timerDurationSeconds
        self.showProgressCounter = showProgressCounter
        self.showMicrophonePrompt = showMicrophonePrompt
        self.loopPrompts = loopPrompts
        self.onBack = onBack
        self.onFinish = onFinish
        self.onWordsCompletedCount = onWordsCompletedCount
    }

    private var promptCount: Int {
        max(prompts.count, 1)
    }

    private var currentPrompt: String {
        guard !prompts.isEmpty else { return "" }
        return prompts[min(currentWordIndex, prompts.count - 1)]
    }

    public var body: some View {
        ZStack(alignment: .top) {
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()

            if showBackgroundImages {
                BackgroundImagesDecorationView()
            }

            VStack(spacing: 0) {
                topBar

                if let duration = timerDurationSeconds {
                    timerProgressBar(duration: duration)
                }

                if let instruction, !instruction.isEmpty {
                    Text(instruction)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(.white)
                        .lineSpacing(5)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 28)
                }

                Spacer(minLength: 12)

                promptDisplay

                if showProgressCounter {
                    progress
                        .padding(.top, 22)
                }

                Spacer(minLength: 16)

                microphoneControl

                if showMicrophonePrompt {
                    Text(allowsMultilinePrompt ? "Tap and speak the prompt" : "Tap and speak the word")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(Color(red: 194 / 255, green: 192 / 255, blue: 218 / 255))
                        .padding(.top, 8)
                }

                PrimaryActionButton(title: "Finish") {
                    finishPractice()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 16)
                .padding(.bottom, 12)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if let duration = timerDurationSeconds {
                timeRemaining = duration
                sessionTimerTask?.cancel()
                sessionTimerTask = Task { @MainActor in
                    while timeRemaining > 0 && !Task.isCancelled {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        guard !Task.isCancelled else { break }
                        timeRemaining -= 1
                    }
                    if timeRemaining == 0 {
                        finishPractice()
                    }
                }
            }
        }
        .onDisappear {
            advanceTask?.cancel()
            sessionTimerTask?.cancel()
        }
    }

    private var topBar: some View {
        HStack {
            BackNavButton {
                advanceTask?.cancel()
                onBack()
            }

            Spacer()
        }
    }

    private var promptDisplay: some View {
        let prompt = currentPrompt
        let highlighted = (
            Text(String(prompt.prefix(1)))
                .foregroundStyle(StamerleeTheme.accentPurpleLight)
            + Text(String(prompt.dropFirst()))
                .foregroundStyle(.white)
        )
        .font(.system(size: promptFontSize, weight: .bold, design: .rounded))
        .multilineTextAlignment(.center)
        .minimumScaleFactor(0.7)
        .lineLimit(allowsMultilinePrompt ? 4 : 1)
        .frame(maxWidth: .infinity)
        .id(currentWordIndex)
        .transition(.opacity.combined(with: .scale(scale: 0.96)))

        return highlighted
    }

    private var promptFontSize: CGFloat {
        if !allowsMultilinePrompt {
            return 46
        }
        return currentPrompt.count > 42 ? 24 : 28
    }

    private var progress: some View {
        VStack(spacing: 10) {
            Text("\(currentWordIndex + 1) of \(promptCount)")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(Color(red: 147 / 255, green: 145 / 255, blue: 175 / 255))

            HStack(spacing: 7) {
                ForEach(0..<min(promptCount, 8), id: \.self) { index in
                    Circle()
                        .fill(index == currentWordIndex % min(promptCount, 8) ? .white : Color(red: 80 / 255, green: 79 / 255, blue: 111 / 255))
                        .frame(width: 7, height: 7)
                }
            }
        }
    }

    private var microphoneControl: some View {
        UniversalMicrophoneButton(isListening: isListening, disabled: false) {
            toggleListening()
        }
    }

    private func toggleListening() {
        if isListening {
            // Person hits mic again: stop recording & advance to next word immediately
            advanceTask?.cancel()
            withAnimation(.easeInOut(duration: 0.25)) {
                pulse = false
                isListening = false
                advanceWord()
            }
        } else {
            startListening()
        }
    }

    private func startListening() {
        guard !isListening else { return }

        advanceTask?.cancel()
        withAnimation(.easeInOut(duration: 0.22)) {
            isListening = true
            pulse = true
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        advanceTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(5))
            guard !Task.isCancelled else { return }

            withAnimation(.easeInOut(duration: 0.25)) {
                pulse = false
                isListening = false
                advanceWord()
            }
        }
    }

    private func timerProgressBar(duration: Int) -> some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "stopwatch.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(timeRemaining <= 10 ? Color(red: 255 / 255, green: 110 / 255, blue: 110 / 255) : Color(red: 180 / 255, green: 165 / 255, blue: 255 / 255))
                    Text("\(timeRemaining)s")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundStyle(timeRemaining <= 10 ? Color(red: 255 / 255, green: 120 / 255, blue: 120 / 255) : .white)
                }

                Spacer()

                Text("60s Fluency Lap")
                    .font(.system(size: 12.5, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(red: 194 / 255, green: 192 / 255, blue: 218 / 255))
            }

            GeometryReader { geo in
                let width = geo.size.width
                let progress = CGFloat(duration - timeRemaining) / CGFloat(max(duration, 1))
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
        .padding(.top, 10)
        .padding(.bottom, 6)
    }

    private func advanceWord() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        wordsCompleted += 1
        onWordsCompletedCount?(wordsCompleted)
        if loopPrompts {
            currentWordIndex = (currentWordIndex + 1) % promptCount
        } else if currentWordIndex + 1 < promptCount {
            currentWordIndex += 1
        } else {
            finishPractice()
        }
    }

    private func finishPractice() {
        advanceTask?.cancel()
        sessionTimerTask?.cancel()
        isListening = false
        pulse = false
        onFinish()
    }
}

private struct FluencyFinishButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
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
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
