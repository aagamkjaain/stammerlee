import SwiftUI
import AVFoundation

// MARK: - Speech Synthesis Helper
private final class DialSceneSpeechService: NSObject, @unchecked Sendable, AVSpeechSynthesizerDelegate {
    static let shared = DialSceneSpeechService()
    private let synthesizer = AVSpeechSynthesizer()
    private var onFinish: (() -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String, onFinish: (() -> Void)? = nil) {
        synthesizer.stopSpeaking(at: .immediate)
        self.onFinish = onFinish

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.48 // Clear, conversational pace
        utterance.pitchMultiplier = 1.05
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        onFinish = nil
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.onFinish?()
            self?.onFinish = nil
        }
    }
}

// MARK: - Dial Scene Models
public struct ScenarioItem: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let icon: String

    public init(id: String = UUID().uuidString, title: String, subtitle: String, icon: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }
}

public struct DialogueTurn: Identifiable, Equatable {
    public let id: String
    public let speaker: String
    public let text: String
    public let isUser: Bool

    public init(id: String = UUID().uuidString, speaker: String, text: String, isUser: Bool) {
        self.id = id
        self.speaker = speaker
        self.text = text
        self.isUser = isUser
    }
}

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

// MARK: - Dial Scene View
/// Interactive conversation practice with real to-and-fro: Partner speaks, user opens mic, user speaks and sends message, partner responds.
public struct DialSceneView: View {
    @Bindable public var state: AppState

    @State private var stage: Stage
    @State private var selectedScenario = "Ordering at a Café"
    @State private var selectedWords: Set<String> = ["Medium", "Special"]

    @State private var scenarioList: [ScenarioItem] = [
        ScenarioItem(id: "cafe", title: "Ordering at a Café", subtitle: "Practice placing your order.", icon: "cup.and.saucer.fill"),
        ScenarioItem(id: "restaurant", title: "Ordering at a Restaurant", subtitle: "Practice ordering a meal.", icon: "fork.knife"),
        ScenarioItem(id: "hotel", title: "Checking into a Hotel", subtitle: "Build confidence checking in.", icon: "building.2.fill"),
        ScenarioItem(id: "salon", title: "At a Hair Salon", subtitle: "Practice common salon phrases.", icon: "scissors"),
        ScenarioItem(id: "grocery", title: "At a Grocery Store", subtitle: "Practice asking for items.", icon: "basket.fill")
    ]

    // To-and-fro conversation state machine
    private enum ConversationStep {
        case partnerSpeaking
        case waitingToOpenMic
        case micOpenRecording
        case messageSent
        case finished
    }

    @State private var conversationStep: ConversationStep = .partnerSpeaking
    @State private var revealedTurnsCount: Int = 1
    @State private var isSpeakingAnimation: Bool = false
    @State private var micPulseAnimation: Bool = false
    @State private var fallbackTimer: Timer? = nil

    // Custom scenario creation states
    @State private var showAddScenarioSheet: Bool = false
    @State private var customDialogues: [String: [DialogueTurn]] = [:]

    private enum Stage {
        case intro
        case scenarios
        case conversation
        case analysis
    }

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
        .sheet(isPresented: $showAddScenarioSheet) {
            AddCustomScenarioSheet(isPresented: $showAddScenarioSheet) { title, subtitle, icon, turns in
                let newScenario = ScenarioItem(title: title, subtitle: subtitle, icon: icon)
                scenarioList.append(newScenario)
                customDialogues[title] = turns
                selectedScenario = title
                startConversation(for: title)
            }
        }
    }

    // MARK: - Navigation Header
    private var header: some View {
        HStack {
            BackNavButton {
                if stage == .scenarios {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        stage = .intro
                    }
                } else if stage == .conversation {
                    stopAllSpeech()
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        stage = .scenarios
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

    // MARK: - Scenarios Selection Screen
    private var scenarioView: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Text("Dial Scene")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.top, 22)
            Text("Practice real-life conversations through interactive turn-by-turn scenarios.")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(StamerleeTheme.textSecondaryDark)
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 22)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    // Scenario Cards
                    ForEach(scenarioList) { scenario in
                        Button {
                            selectedScenario = scenario.title
                            startConversation(for: scenario.title)
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: scenario.icon)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 36)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(scenario.title)
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    Text(scenario.subtitle)
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(StamerleeTheme.textSecondaryDark)
                                }
                                Spacer()
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 12, weight: .bold))
                                    .padding(8)
                                    .background(Color(red: 73 / 255, green: 65 / 255, blue: 174 / 255))
                                    .clipShape(Circle())
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 64)
                            .background(Color.white.opacity(0.07))
                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.1), lineWidth: 1))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }

                    // Add Custom Scenario Card
                    Button {
                        showAddScenarioSheet = true
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(StamerleeTheme.primaryBlue.opacity(0.2))
                                    .frame(width: 38, height: 38)
                                Image(systemName: "plus")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(StamerleeTheme.primaryBlue)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text("Add your scenario")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Text("Create a custom conversation situation")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(StamerleeTheme.textSecondaryDark)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color.white.opacity(0.35))
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 64)
                        .background(Color.white.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(
                                    StamerleeTheme.primaryBlue.opacity(0.45),
                                    style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
            Spacer()
        }
    }

    // MARK: - To-And-Fro Conversation Flow Screen
    private var conversationView: some View {
        let allTurns = turns(for: selectedScenario)
        let partnerSpeakerName = allTurns.first?.speaker ?? "Partner"
        let currentUserTurn: DialogueTurn? = (revealedTurnsCount < allTurns.count) ? allTurns[revealedTurnsCount] : nil

        return VStack(alignment: .leading, spacing: 0) {
            // Top Bar with Caller Details
            HStack {
                header
                Spacer()
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("\(partnerSpeakerName) • Connected")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.08), in: Capsule())
                .padding(.trailing, 24)
            }

            Text(selectedScenario)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.top, 12)

            // Chat Messages Stream
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(Array(allTurns.prefix(revealedTurnsCount).enumerated()), id: \.element.id) { index, turn in
                            let isCurrentlySpeakingTurn = (index == revealedTurnsCount - 1) && (conversationStep == .partnerSpeaking)
                            bubble(turn.speaker, turn.text, isUser: turn.isUser, isSpeaking: isCurrentlySpeakingTurn)
                                .id(turn.id)
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.95).combined(with: .opacity).combined(with: .move(edge: turn.isUser ? .trailing : .leading)),
                                    removal: .opacity
                                ))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 18)
                }
                .onChange(of: revealedTurnsCount) { _, _ in
                    if let lastId = allTurns.prefix(revealedTurnsCount).last?.id {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }

            Spacer(minLength: 8)

            // Turn-by-Turn Dynamic Control Panel
            VStack(spacing: 12) {
                switch conversationStep {
                case .partnerSpeaking:
                    // 1. Partner is speaking
                    partnerSpeakingCard(partnerName: partnerSpeakerName)

                case .waitingToOpenMic:
                    // 2. Partner finished; User prompted to open mic
                    if let userTurn = currentUserTurn {
                        waitingToOpenMicCard(textToSay: userTurn.text, turnNumber: revealedTurnsCount + 1, totalTurns: allTurns.count)
                    }

                case .micOpenRecording:
                    // 3. User opened mic and is speaking; ready to send
                    if let userTurn = currentUserTurn {
                        micOpenRecordingCard(textToSay: userTurn.text, allTurns: allTurns)
                    }

                case .messageSent:
                    // 4. Message sent indicator
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green)
                        Text("Message Sent!")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 24)

                case .finished:
                    // 5. Conversation Complete
                    conversationCompletedCard
                }

                // Finish / Exit Button
                if conversationStep != .finished {
                    Button {
                        stopAllSpeech()
                        state.hasCompletedDialScene = true
                        stage = .analysis
                    } label: {
                        Text("End Call & View Results")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(StamerleeTheme.textSecondaryDark)
                            .underline()
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 16)
                }
            }
        }
    }

    // MARK: - Conversation State Cards

    // Step 1: Partner Speaking UI
    private func partnerSpeakingCard(partnerName: String) -> some View {
        HStack(spacing: 12) {
            // Live waveform audio bars
            HStack(spacing: 3) {
                ForEach(0..<4) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.cyan)
                        .frame(width: 3, height: CGFloat(8 + (i % 2 == 0 ? 14 : 7)))
                        .scaleEffect(y: isSpeakingAnimation ? 1.3 : 0.6)
                        .animation(
                            .easeInOut(duration: 0.32).repeatForever().delay(Double(i) * 0.1),
                            value: isSpeakingAnimation
                        )
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(partnerName) is speaking...")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Listen to the dialogue")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(StamerleeTheme.textSecondaryDark)
            }

            Spacer()

            Button("Skip") {
                partnerDidFinishSpeaking()
            }
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.12), in: Capsule())
        }
        .padding(14)
        .background(Color(red: 25 / 255, green: 32 / 255, blue: 68 / 255))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.cyan.opacity(0.3), lineWidth: 1))
        .padding(.horizontal, 24)
    }

    // Step 2: Waiting to Open Mic UI
    private func waitingToOpenMicCard(textToSay: String, turnNumber: Int, totalTurns: Int) -> some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(StamerleeTheme.primaryBlue)
                    Text("Your turn to speak")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.primaryBlue)
                    Spacer()
                    Text("Turn \(turnNumber) of \(totalTurns)")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(StamerleeTheme.textSecondaryDark)
                }

                Text("\"\(textToSay)\"")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineSpacing(2)

                Text("Tap 'Open Mic' to speak this message")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(StamerleeTheme.textSecondaryDark)
            }
            .padding(14)
            .background(Color.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.12), lineWidth: 1))
            .padding(.horizontal, 24)

            // Open Mic Button
            Button {
                openMic()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text("Open Mic to Speak")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    LinearGradient(
                        colors: [Color(red: 65 / 255, green: 110 / 255, blue: 250 / 255), StamerleeTheme.primaryBlueDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 16)
                )
                .shadow(color: Color.blue.opacity(0.25), radius: 8, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
        }
    }

    // Step 3: Mic Open & Recording UI with "Send Message"
    private func micOpenRecordingCard(textToSay: String, allTurns: [DialogueTurn]) -> some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .scaleEffect(micPulseAnimation ? 1.3 : 0.85)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: micPulseAnimation)

                    Text("Mic is Open • Recording Voice")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.red)

                    Spacer()

                    // Visual audio bars
                    HStack(spacing: 3) {
                        ForEach(0..<4) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.red.opacity(0.8))
                                .frame(width: 3, height: CGFloat(9 + (i % 2 == 0 ? 12 : 5)))
                        }
                    }
                }

                Text("\"\(textToSay)\"")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineSpacing(2)

                Text("Speak clearly at your own pace, then tap 'Send Message'")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(StamerleeTheme.textSecondaryDark)
            }
            .padding(14)
            .background(Color.red.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.red.opacity(0.4), lineWidth: 1.5))
            .padding(.horizontal, 24)

            // Send Message Button
            Button {
                sendMessage(allTurns: allTurns)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 15, weight: .bold))
                    Text("Send Message")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color(red: 35 / 255, green: 175 / 255, blue: 95 / 255), in: RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.green.opacity(0.3), radius: 8, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
        }
    }

    // Step 5: Completed conversation card
    private var conversationCompletedCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Color.green)

            Text("Conversation Complete!")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Great to-and-fro pacing. Ready to review your score?")
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(StamerleeTheme.textSecondaryDark)

            PrimaryActionButton(title: "View Analysis") {
                stopAllSpeech()
                state.hasCompletedDialScene = true
                stage = .analysis
            }
            .padding(.horizontal, 24)
            .padding(.top, 4)
            .padding(.bottom, 12)
        }
    }

    // MARK: - To-And-Fro Actions

    private func startConversation(for scenarioTitle: String) {
        stopAllSpeech()
        let allTurns = turns(for: scenarioTitle)
        revealedTurnsCount = 1
        conversationStep = .partnerSpeaking
        stage = .conversation

        if let firstTurn = allTurns.first {
            playPartnerDialogue(turn: firstTurn)
        }
    }

    private func playPartnerDialogue(turn: DialogueTurn) {
        conversationStep = .partnerSpeaking
        isSpeakingAnimation = true

        // 1. Text-To-Speech audio
        DialSceneSpeechService.shared.speak(turn.text) {
            partnerDidFinishSpeaking()
        }

        // 2. Fallback timer in case speech finishes or device is muted
        fallbackTimer?.invalidate()
        let estimatedDuration = max(Double(turn.text.count) * 0.065, 2.4)
        fallbackTimer = Timer.scheduledTimer(withTimeInterval: estimatedDuration, repeats: false) { _ in
            partnerDidFinishSpeaking()
        }
    }

    private func partnerDidFinishSpeaking() {
        guard conversationStep == .partnerSpeaking else { return }
        fallbackTimer?.invalidate()
        isSpeakingAnimation = false

        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            conversationStep = .waitingToOpenMic
        }
    }

    private func openMic() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            conversationStep = .micOpenRecording
            micPulseAnimation = true
        }
    }

    private func sendMessage(allTurns: [DialogueTurn]) {
        guard conversationStep == .micOpenRecording else { return }
        micPulseAnimation = false

        // Play positive send haptic
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)

        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
            conversationStep = .messageSent
            revealedTurnsCount += 1 // Reveal user's spoken bubble in chat
        }

        // After a natural moment, partner responds or finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            if revealedTurnsCount < allTurns.count {
                let partnerTurn = allTurns[revealedTurnsCount]
                withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                    revealedTurnsCount += 1 // Reveal partner bubble
                }
                playPartnerDialogue(turn: partnerTurn)
            } else {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                    conversationStep = .finished
                }
            }
        }
    }

    private func stopAllSpeech() {
        fallbackTimer?.invalidate()
        DialSceneSpeechService.shared.stop()
        isSpeakingAnimation = false
        micPulseAnimation = false
    }

    // MARK: - Dialogue Bubble
    private func bubble(_ speaker: String, _ text: String, isUser: Bool, isSpeaking: Bool) -> some View {
        HStack {
            if isUser { Spacer(minLength: 40) }
            VStack(alignment: isUser ? .trailing : .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text(speaker)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(isUser ? StamerleeTheme.primaryBlue : Color.white.opacity(0.8))

                    if isSpeaking {
                        HStack(spacing: 2) {
                            ForEach(0..<3) { _ in
                                Circle()
                                    .fill(Color.cyan)
                                    .frame(width: 4, height: 4)
                            }
                        }
                    }
                }

                Text(text)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .lineSpacing(3)
                    .foregroundColor(isUser ? .black : .white)

                if isUser {
                    HStack(spacing: 3) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                        Text("Sent")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(StamerleeTheme.primaryBlue)
                    .padding(.top, 1)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(
                isUser
                    ? Color(red: 226 / 255, green: 229 / 255, blue: 250 / 255)
                    : Color(red: 35 / 255, green: 39 / 255, blue: 78 / 255)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        isSpeaking ? Color.cyan.opacity(0.5) : (isUser ? StamerleeTheme.primaryBlue.opacity(0.3) : Color.white.opacity(0.08)),
                        lineWidth: isSpeaking ? 1.5 : 1
                    )
            )
            if !isUser { Spacer(minLength: 40) }
        }
    }

    // MARK: - Dialogue Script Source
    private func turns(for scenario: String) -> [DialogueTurn] {
        if let custom = customDialogues[scenario] {
            return custom
        }

        switch scenario {
        case "Ordering at a Café":
            return [
                DialogueTurn(speaker: "Barista", text: "Hi! Welcome in. What can I get started for you today?", isUser: false),
                DialogueTurn(speaker: "You", text: "A medium iced latte with whole milk and one pump of vanilla, please.", isUser: true),
                DialogueTurn(speaker: "Barista", text: "Of course! One medium iced vanilla latte. Anything else on the side today?", isUser: false),
                DialogueTurn(speaker: "You", text: "What about today's special pastry?", isUser: true),
                DialogueTurn(speaker: "Barista", text: "We have fresh warm almond croissants and blueberry scones today!", isUser: false),
                DialogueTurn(speaker: "You", text: "I'll take an almond croissant as well, thank you.", isUser: true),
                DialogueTurn(speaker: "Barista", text: "Sounds wonderful! Your total is $7.50. It will be ready at the counter in just a moment.", isUser: false)
            ]
        case "Ordering at a Restaurant":
            return [
                DialogueTurn(speaker: "Server", text: "Good evening! Welcome. Can I start you off with something to drink?", isUser: false),
                DialogueTurn(speaker: "You", text: "I'll have sparkling water with a slice of lemon, please.", isUser: true),
                DialogueTurn(speaker: "Server", text: "Coming right up. Are you ready to order your main entree?", isUser: false),
                DialogueTurn(speaker: "You", text: "Yes, I would like the grilled salmon with roasted vegetables.", isUser: true),
                DialogueTurn(speaker: "Server", text: "Excellent choice. I'll get that started with the chef right away.", isUser: false)
            ]
        case "Checking into a Hotel":
            return [
                DialogueTurn(speaker: "Front Desk", text: "Good afternoon! Welcome to the Grand Hotel. Are you checking in?", isUser: false),
                DialogueTurn(speaker: "You", text: "Yes, I have a reservation under the name Alex Smith.", isUser: true),
                DialogueTurn(speaker: "Front Desk", text: "Found your reservation! May I please see your ID to confirm?", isUser: false),
                DialogueTurn(speaker: "You", text: "Here is my ID and credit card for incidentals.", isUser: true),
                DialogueTurn(speaker: "Front Desk", text: "Thank you Alex. You're in room 512 on the fifth floor. Enjoy your stay!", isUser: false)
            ]
        case "At a Hair Salon":
            return [
                DialogueTurn(speaker: "Stylist", text: "Hi there! Great to see you today. What style or cut are we aiming for?", isUser: false),
                DialogueTurn(speaker: "You", text: "Just a light trim on the sides and slightly shorter on top, please.", isUser: true),
                DialogueTurn(speaker: "Stylist", text: "Sounds great! Would you like a hair wash before we begin?", isUser: false),
                DialogueTurn(speaker: "You", text: "A quick wash first would be wonderful, thank you.", isUser: true),
                DialogueTurn(speaker: "Stylist", text: "Awesome, let's step over to the shampoo basin right this way.", isUser: false)
            ]
        case "At a Grocery Store":
            return [
                DialogueTurn(speaker: "Staff", text: "Hello! Did you find everything you were looking for today?", isUser: false),
                DialogueTurn(speaker: "You", text: "Almost, could you tell me which aisle has the olive oil?", isUser: true),
                DialogueTurn(speaker: "Staff", text: "Sure! The oils and vinegars are in aisle 4, right in the middle shelf.", isUser: false),
                DialogueTurn(speaker: "You", text: "Thank you so much for pointing me in the right direction.", isUser: true),
                DialogueTurn(speaker: "Staff", text: "Anytime! Have a great rest of your day.", isUser: false)
            ]
        default:
            return [
                DialogueTurn(speaker: "Partner", text: "Hello! Let's practice this scenario together. How can I help you today?", isUser: false),
                DialogueTurn(speaker: "You", text: "Hi! I wanted to follow up and go over our key plans.", isUser: true),
                DialogueTurn(speaker: "Partner", text: "Of course! Everything is ready on my side. What would you like to discuss first?", isUser: false),
                DialogueTurn(speaker: "You", text: "Let's review the main timeline and next action items.", isUser: true),
                DialogueTurn(speaker: "Partner", text: "Sounds like a solid plan. Thank you for your clear communication!", isUser: false)
            ]
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
        case "Ordering at a Café": return "7.6"
        case "Ordering at a Restaurant": return "7.8"
        case "Checking into a Hotel": return "7.4"
        default: return "7.7"
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

// MARK: - Add Custom Scenario Sheet
private struct AddCustomScenarioSheet: View {
    @Binding var isPresented: Bool
    var onAdd: (String, String, String, [DialogueTurn]) -> Void

    @State private var title: String = ""
    @State private var subtitle: String = ""
    @State private var selectedIcon: String = "bubble.left.and.bubble.right.fill"
    @State private var partnerFirstLine: String = ""
    @State private var userFirstLine: String = ""

    private let availableIcons = [
        "bubble.left.and.bubble.right.fill",
        "briefcase.fill",
        "stethoscope",
        "airplane",
        "cart.fill",
        "person.2.fill",
        "phone.fill"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                StamerleeTheme.backgroundDark.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Create Custom Scenario")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 6)

                        Text("Set up a personalized situation to practice your speech pacing and fluency.")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(StamerleeTheme.textSecondaryDark)

                        // Scenario Title
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Scenario Title")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)

                            TextField("e.g. Job Interview, Calling Doctor...", text: $title)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.white)
                                .tint(StamerleeTheme.primaryBlue)
                                .padding(.horizontal, 14)
                                .frame(height: 48)
                                .background(Color.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Scenario Subtitle
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Scenario Goal / Description")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)

                            TextField("e.g. Practice answering interview questions calmly", text: $subtitle)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.white)
                                .tint(StamerleeTheme.primaryBlue)
                                .padding(.horizontal, 14)
                                .frame(height: 48)
                                .background(Color.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Icon Selector
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Choose Icon")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)

                            HStack(spacing: 12) {
                                ForEach(availableIcons, id: \.self) { icon in
                                    let isSelected = selectedIcon == icon
                                    Button {
                                        selectedIcon = icon
                                    } label: {
                                        Image(systemName: icon)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(isSelected ? .white : StamerleeTheme.textSecondaryDark)
                                            .frame(width: 42, height: 42)
                                            .background(
                                                isSelected
                                                    ? StamerleeTheme.primaryBlue
                                                    : Color.white.opacity(0.08),
                                                in: Circle()
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // Optional custom first turns
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Initial Dialogue (Optional)")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)

                            TextField("Partner's first line (e.g. Hello, how can I help?)", text: $partnerFirstLine)
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .frame(height: 44)
                                .background(Color.white.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            TextField("Your response (e.g. I am calling to ask about...)", text: $userFirstLine)
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .frame(height: 44)
                                .background(Color.white.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        // Create Button
                        PrimaryActionButton(
                            title: "Create & Practice Scenario"
                        ) {
                            guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                            let finalSubtitle = subtitle.isEmpty ? "Custom speaking practice." : subtitle
                            let turns = buildCustomTurns()
                            onAdd(title, finalSubtitle, selectedIcon, turns)
                            isPresented = false
                        }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                        .opacity(title.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 22)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.white.opacity(0.6))
                    }
                }
            }
        }
        .presentationBackground(StamerleeTheme.backgroundDark)
    }

    private func buildCustomTurns() -> [DialogueTurn] {
        let p1 = partnerFirstLine.isEmpty ? "Hello! Thanks for connecting. How can I help you today?" : partnerFirstLine
        let u1 = userFirstLine.isEmpty ? "Hi! I wanted to follow up and go over our plan." : userFirstLine

        return [
            DialogueTurn(speaker: "Partner", text: p1, isUser: false),
            DialogueTurn(speaker: "You", text: u1, isUser: true),
            DialogueTurn(speaker: "Partner", text: "Understood! Everything is set on my end. What would you like to review next?", isUser: false),
            DialogueTurn(speaker: "You", text: "Let's review the main schedule and next steps.", isUser: true),
            DialogueTurn(speaker: "Partner", text: "Sounds like a solid plan. Thank you for your clear pacing and communication!", isUser: false)
        ]
    }
}
