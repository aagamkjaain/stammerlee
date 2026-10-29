import SwiftUI

// MARK: - Dial Scene Intro View
/// Introduces the Dial Scene scenario-based phone practice technique.
public struct DialSceneIntroView: View {
    @Bindable public var state: AppState
    public var onBack: (() -> Void)? = nil
    public var onContinue: (() -> Void)? = nil

    @State private var breatheEffect: Bool = false

    private let heroFallbackPath = "/Users/user89/Documents/stammerlee/Stamerlee/pictures/dialscenehero.png"

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
        ZStack {
            // Dark Background
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Top Navigation Bar
                HStack {
                    BackNavButton {
                        if let onBack {
                            onBack()
                        } else {
                            state.navigate(to: .homeDashboard, forward: false)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // Headings Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Let's start with\nDial Scene")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textPrimaryDark)
                        .lineSpacing(2)

                    Text("Dial Scene helps you practice real-life phone conversations, manage speaking challenges and build confidence in communicating smoothly during everyday calls.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textSecondaryDark)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 22)

                // Hero Illustration
                ZStack {
                    if let uiImage = StamerleeImageLoader.loadHeroImage(
                        name: "DialSceneHero",
                        fallbackPath: heroFallbackPath
                    ) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 360)
                            .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 10)
                            .scaleEffect(breatheEffect ? 1.015 : 0.985)
                            .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: breatheEffect)
                    } else {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(red: 25 / 255, green: 30 / 255, blue: 65 / 255))
                            .frame(width: 250, height: 230)
                            .overlay(
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(StamerleeTheme.primaryBlue)
                            )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)

                Spacer()

                // Bottom CTA Button ("Continue")
                VStack {
                    PrimaryActionButton(title: "Continue") {
                        state.hasSeenDialSceneIntro = true
                        if let onContinue {
                            onContinue()
                        } else {
                            state.navigate(to: .dialScene)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            breatheEffect = true
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
    @State private var selectedWords: Set<String> = ["Medium", "Special"]

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
        ZStack {
            StamerleeTheme.backgroundDark.ignoresSafeArea()
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

            ScrollView(showsIndicators: false) {
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
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
            }
            Spacer()
        }
    }

    private var conversationView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                header
                Spacer()
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
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
                bubble("Barista", "Hi! What can I get for you today?", isUser: false)
                bubble("You", "A medium iced latte with whole milk and one pump of vanilla, please.", isUser: true)
                bubble("Barista", "Of course! One medium iced vanilla latte. Anything else on the side?", isUser: false)
                bubble("You", "What about today's special?", isUser: true)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            Spacer()

            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isListening.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(red: 205 / 255, green: 215 / 255, blue: 245 / 255))
                        .frame(width: 76, height: 76)
                    Circle()
                        .fill(StamerleeTheme.backgroundDark)
                        .frame(width: 52, height: 52)
                    Image(systemName: isListening ? "waveform" : "mic.fill")
                        .foregroundStyle(isListening ? StamerleeTheme.primaryBlue : .white)
                        .font(.system(size: 22, weight: .bold))
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
            subtitle: "Choose words to practice using Beat Buddy",
            affirmation: "Great progress today!",
            wordsList: sampleWords,
            selectedWords: $selectedWords,
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
