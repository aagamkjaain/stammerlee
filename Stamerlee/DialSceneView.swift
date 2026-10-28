import SwiftUI

// MARK: - Dial Scene Intro View
/// Introduces the Dial Scene scenario-based phone practice technique.
public struct DialSceneIntroView: View {
    @Bindable public var state: AppState
    public var onBack: (() -> Void)? = nil
    public var onContinue: (() -> Void)? = nil

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
        ExerciseIntroSkeletonView(
            title: "Let's start with\nDial Scene",
            subtitle: "Dial Scene helps you practice real-life phone conversations, manage speaking challenges and build confidence in communicating smoothly during everyday calls.",
            heroImageName: "DialSceneHero",
            heroFallbackPath: heroFallbackPath,
            systemIconFallback: "phone.fill",
            onBack: {
                if let onBack {
                    onBack()
                } else {
                    state.navigate(to: .homeDashboard, forward: false)
                }
            },
            onContinue: {
                state.hasSeenDialSceneIntro = true
                if let onContinue {
                    onContinue()
                } else {
                    state.navigate(to: .dialScene)
                }
            }
        )
    }
}

// MARK: - Dial Scene
/// Conversation practice unlocked alongside Picture Description.
public struct DialSceneView: View {
    @Bindable public var state: AppState

    @State private var selectedScenario = "Ordering at a Café"
    @State private var stage: Stage
    @State private var selectedSegment = "Prolongations"
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

    private let wordsBySegment: [String: [String]] = [
        "Prolongations": ["Medium", "What", "Order", "Special", "Side", "Iced"],
        "Blocks": ["One", "Vanilla", "Frappe", "Please", "Cup", "Small"],
        "Repetitions": ["What", "With", "Whole", "Latte", "Milk", "Today's"]
    ]

    public init(state: AppState) {
        self.state = state
        _stage = State(initialValue: state.hasSeenDialSceneIntro ? .scenarios : .intro)
    }

    private var words: [String] {
        wordsBySegment[selectedSegment, default: []]
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
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.top, 22)
            Text("Practice real life conversations through\ninteractive scenarios.")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(StamerleeTheme.textSecondaryDark)
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .padding(.bottom, 24)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(scenarios, id: \.0) { scenario in
                        Button {
                            selectedScenario = scenario.0
                            stage = .conversation
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: scenario.2)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 36)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(scenario.0)
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                    Text(scenario.1)
                                        .font(.system(size: 10, design: .rounded))
                                        .foregroundColor(StamerleeTheme.textSecondaryDark)
                                }
                                .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.white)
                                    .padding(7)
                                    .background(Color(red: 73 / 255, green: 65 / 255, blue: 174 / 255))
                                    .clipShape(Circle())
                            }
                            .padding(.horizontal, 12)
                            .frame(height: 56)
                            .background(Color.white.opacity(0.07))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08)))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
            Spacer()
        }
    }

    private var conversationView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                header
                Spacer()
                Text("DAF")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(StamerleeTheme.primaryBlueDark)
                    .clipShape(Capsule())
                    .padding(.trailing, 24)
            }
            Text(selectedScenario)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.top, 24)

            VStack(alignment: .leading, spacing: 12) {
                bubble("Barista", "Hi! What can I get for you today?", isUser: false)
                bubble("You", "A medium iced latte with whole milk and one pump of vanilla, please.", isUser: true)
                bubble("Barista", "Of course! One medium iced vanilla latte. Anything else on the side?", isUser: false)
                bubble("You", "What about today's special?", isUser: true)
            }
            .padding(.horizontal, 24)
            .padding(.top, 26)

            Spacer()

            Button {
                state.hasCompletedDialScene = true
                stage = .analysis
            } label: {
                ZStack {
                    Circle().fill(Color(red: 205 / 255, green: 215 / 255, blue: 245 / 255)).frame(width: 72, height: 72)
                    Circle().fill(StamerleeTheme.backgroundDark).frame(width: 48, height: 48)
                    Image(systemName: "mic.fill").foregroundColor(.white).font(.system(size: 21, weight: .bold))
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
                Text(speaker).font(.system(size: 11, weight: .bold, design: .rounded))
                Text(text).font(.system(size: 12, design: .rounded))
            }
            .foregroundColor(isUser ? .black : .white)
            .padding(12)
            .background(isUser ? Color(red: 226 / 255, green: 229 / 255, blue: 250 / 255) : Color(red: 35 / 255, green: 39 / 255, blue: 78 / 255))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            if !isUser { Spacer() }
        }
    }

    private var wordsList: [String] {
        [
            "Medium", "What", "Order", "Special", "Side", "Iced",
            "Vanilla", "Frappe", "Please", "Cup", "Small", "Latte",
            "Coffee", "Morning", "Smooth", "Table", "Thank you", "Counter"
        ]
    }

    private var scoreText: String {
        switch selectedScenario {
        case "Ordering at a Café":
            return "7.6"
        case "Ordering at a Restaurant":
            return "7.8"
        case "Checking into a Hotel":
            return "7.4"
        default:
            return "7.7"
        }
    }

    private var analysisView: some View {
        ExerciseAnalysisSkeletonView(
            scoreText: scoreText,
            maxScoreText: "/ 10",
            wordsList: wordsList,
            selectedWords: $selectedWords,
            onDone: {
                state.navigate(to: .homeDashboard)
            }
        )
    }
}
