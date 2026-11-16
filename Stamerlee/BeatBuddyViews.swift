import SwiftUI
import AVFoundation

private let defaultBeatBuddyWords = [
    "Water", "University", "Breaking", "Computer", "Scale", "Laptop",
    "Vinyl", "Desk", "Swift", "Center", "Protocol", "Optional",
    "Morning", "Coffee", "Please", "Breathe", "Gentle", "Together",
    "Pacing", "Speech", "Natural", "Freedom", "Balance", "Progress",
    "Connection", "Confidence", "Smooth", "Presence", "Story", "Clarity"
]

public enum BeatBuddySoundCategory: String, CaseIterable, Identifiable {
    case randomized = "Randomized"
    case kSound = "K Sound"
    case mSound = "M Sound"
    case sSound = "S Sound"
    case pSound = "P Sound"
    case tSound = "T Sound"
    case bSound = "B Sound"

    public var id: String { rawValue }

    public var words: [String] {
        switch self {
        case .randomized:
            return defaultBeatBuddyWords.shuffled()
        case .kSound:
            return ["Coffee", "Computer", "Courage", "Clarity", "Keep", "Care", "Kitchen", "Key", "Kite", "Candle"]
        case .mSound:
            return ["Morning", "Memory", "Mind", "Music", "Motion", "Master", "Moment", "Manage", "Market", "Message"]
        case .sSound:
            return ["Speech", "Smooth", "Scale", "Swift", "Story", "Silence", "Steady", "Start", "Simple", "Sunlight"]
        case .pSound:
            return ["Please", "Pacing", "Protocol", "Progress", "Presence", "Peace", "Power", "Practice", "Paper", "Picture"]
        case .tSound:
            return ["Together", "Today", "Time", "Topic", "Travel", "Target", "Trust", "Training", "Tomorrow", "Table"]
        case .bSound:
            return ["Breathe", "Balance", "Breaking", "Bright", "Begin", "Build", "Belief", "Better", "Bridge", "Button"]
        }
    }
}

private struct BeatBuddyShell<Content: View>: View {
    @Bindable var state: AppState
    var onBack: (() -> Void)? = nil
    let content: Content

    init(state: AppState, onBack: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.state = state
        self.onBack = onBack
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .top) {
            StamerleeTheme.backgroundDark.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    BackNavButton {
                        if let onBack {
                            onBack()
                        } else {
                            state.navigate(to: .homeDashboard, forward: false)
                        }
                    }
                    Spacer()
                    GlassCloseButton {
                        state.navigate(to: .homeDashboard, forward: false)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                content
            }
        }
    }
}

// MARK: - Practice Option Card
private struct PracticeOptionCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            HStack(alignment: .center, spacing: 14) {
                // Leading Icon Logo
                ZStack {
                    Circle()
                        .fill(Color(red: 228 / 255, green: 220 / 255, blue: 255 / 255))
                        .frame(width: 52, height: 52)

                    Image(systemName: systemImage)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color(red: 90 / 255, green: 76 / 255, blue: 160 / 255))
                }

                // Title and Subtitle on the right
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 18 / 255, green: 16 / 255, blue: 38 / 255))

                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 105 / 255, green: 98 / 255, blue: 142 / 255))
                        .lineSpacing(1.5)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Trailing Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color(red: 108 / 255, green: 92 / 255, blue: 168 / 255))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, minHeight: 104)
            .background(
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(red: 243 / 255, green: 240 / 255, blue: 254 / 255))

                    // Soft ambient highlight
                    Circle()
                        .fill(Color(red: 228 / 255, green: 220 / 255, blue: 255 / 255).opacity(0.85))
                        .frame(width: 90, height: 90)
                        .offset(x: 20, y: -20)
                        .blur(radius: 8)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.haptic(weight: .medium, pressedScale: 0.98))
    }
}


// MARK: - 1. Words Screen
public struct BeatBuddyWordsView: View {
    @Bindable public var state: AppState
    public var onBack: (() -> Void)? = nil
    public var onContinue: (() -> Void)? = nil
    @State private var customWordCountText = ""

    public init(state: AppState, onBack: (() -> Void)? = nil, onContinue: (() -> Void)? = nil) {
        self.state = state
        self.onBack = onBack
        self.onContinue = onContinue
    }

    private var allWords: [String] {
        var words = defaultBeatBuddyWords
        for word in state.beatBuddySelectedWords {
            if !words.contains(word) {
                words.insert(word, at: 0)
            }
        }
        return words
    }

    private var displayWords: [String] {
        let count = min(max(state.beatBuddyWordCount, 1), allWords.count)
        if state.beatBuddySelectedWords.isEmpty {
            return Array(allWords.prefix(count))
        }
        let selectedList = allWords.filter { state.beatBuddySelectedWords.contains($0) }
        return Array(selectedList.prefix(count))
    }

    public var body: some View {
        BeatBuddyShell(state: state, onBack: {
            if let onBack {
                onBack()
            } else {
                state.navigate(to: .homeDashboard, forward: false)
            }
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // Screen Headings
                Text("Beat buddy")
                    .font(.system(size: 35, weight: .bold, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textPrimaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 18)

                Text("Practice words with Beat Buddy at your chosen tempo")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textSecondaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .lineLimit(2)

                HStack(spacing: 10) {
                    Button {
                        randomizeWords()
                    } label: {
                        Label("Randomize", systemImage: "shuffle")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .frame(height: 40)
                            .background(StamerleeTheme.primaryBlue, in: Capsule())
                    }

                    Menu {
                        ForEach([10, 15, 20], id: \.self) { count in
                            Button("\(count) words") {
                                state.beatBuddyWordCount = count
                                state.beatBuddyUsesCustomWordCount = false
                                randomizeWords()
                            }
                        }
                        Button("Custom") {
                            state.beatBuddyUsesCustomWordCount = true
                        }
                    } label: {
                        Label(
                            "\(state.beatBuddyWordCount) words",
                            systemImage: "chevron.down"
                        )
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textPrimaryDark)
                        .padding(.horizontal, 14)
                        .frame(height: 40)
                        .background(Color.white.opacity(0.1), in: Capsule())
                    }

                    if state.beatBuddyUsesCustomWordCount {
                        TextField("Count", text: $customWordCountText)
                            .keyboardType(.numberPad)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 40)
                            .multilineTextAlignment(.center)
                            .background(Color.white.opacity(0.1), in: Capsule())
                            .onSubmit {
                                applyCustomWordCount()
                            }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 14)

                // Scrollable Words List (Clean display cards without selection)
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
                        spacing: 14
                    ) {
                        ForEach(displayWords, id: \.self) { word in
                            HStack(spacing: 10) {
                                Text(word)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                Capsule().fill(Color.white.opacity(0.08))
                            )
                            .overlay(
                                Capsule().stroke(
                                    Color.white.opacity(0.12),
                                    lineWidth: 1
                                )
                            )
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)

                // Anchored CTA
                VStack {
                    PrimaryActionButton(title: "Continue") {
                        if state.beatBuddySelectedWords.isEmpty {
                            randomizeWords()
                        }
                        if let onContinue {
                            onContinue()
                        } else {
                            state.navigate(to: .beatBuddyBPM)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            if state.beatBuddySelectedWords.isEmpty {
                randomizeWords()
            }
        }
    }

    private func applyCustomWordCount() {
        let count = min(max(Int(customWordCountText) ?? state.beatBuddyWordCount, 1), allWords.count)
        state.beatBuddyWordCount = count
        randomizeWords()
    }

    private func randomizeWords() {
        let count = min(max(state.beatBuddyWordCount, 1), allWords.count)
        state.beatBuddySelectedWords = Set(allWords.shuffled().prefix(count))
    }
}

// MARK: - 2. Interactive Arc BPM Dial
public struct ArcBPMDialView: View {
    @Binding public var bpm: Int
    public let minBPM: Int = 60
    public let maxBPM: Int = 180
    public let size: CGFloat

    @State private var isDragging: Bool = false

    public init(bpm: Binding<Int>, size: CGFloat = 240) {
        self._bpm = bpm
        self.size = size
    }

    private var fraction: Double {
        let clamped = min(max(bpm, minBPM), maxBPM)
        return Double(clamped - minBPM) / Double(maxBPM - minBPM)
    }

    private var knobAngleDegrees: Double {
        135.0 + fraction * 270.0
    }

    public var body: some View {
        let radius = (size - 36) / 2
        let center = CGPoint(x: size / 2, y: size / 2)
        let knobRad = knobAngleDegrees * .pi / 180.0
        let knobX = cos(knobRad) * radius
        let knobY = sin(knobRad) * radius

        ZStack {
            // Background Inactive Arc Track
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(
                    Color.white.opacity(0.08),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .rotationEffect(.degrees(135))
                .frame(width: size - 36, height: size - 36)

            // Active Colored Arc Track
            Circle()
                .trim(from: 0, to: CGFloat(fraction * 0.75))
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 30 / 255, green: 215 / 255, blue: 245 / 255),
                            StamerleeTheme.primaryBlue
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .rotationEffect(.degrees(135))
                .frame(width: size - 36, height: size - 36)
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: fraction)

            // Glowing Draggable Knob Thumb
            Circle()
                .fill(Color.white)
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .stroke(Color(red: 30 / 255, green: 215 / 255, blue: 245 / 255), lineWidth: 3.5)
                )
                .shadow(
                    color: Color(red: 30 / 255, green: 215 / 255, blue: 245 / 255).opacity(isDragging ? 0.9 : 0.5),
                    radius: isDragging ? 12 : 6,
                    x: 0,
                    y: 0
                )
                .scaleEffect(isDragging ? 1.15 : 1.0)
                .offset(x: knobX, y: knobY)
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: knobAngleDegrees)

            // Center Content (Big BPM value, label, and tempo descriptor - NO beating symbol / animation)
            VStack(spacing: 4) {
                Text("\(bpm)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())

                Text("BPM")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textSecondaryDark)
                    .tracking(1.4)

                Text(tempoDescriptor(for: bpm))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.cyan.opacity(0.85))
                    .padding(.top, 2)
            }
        }
        .frame(width: size, height: size)
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    isDragging = true
                    updateAngle(location: value.location, center: center)
                }
                .onEnded { _ in
                    isDragging = false
                }
        )
    }

    private func updateAngle(location: CGPoint, center: CGPoint) {
        let dx = location.x - center.x
        let dy = location.y - center.y
        var deg = atan2(dy, dx) * 180 / .pi
        if deg < 0 { deg += 360 }

        var adjusted = deg - 135
        if adjusted < 0 { adjusted += 360 }

        if adjusted <= 270 {
            let frac = adjusted / 270.0
            let newBPM = Int((Double(minBPM) + frac * Double(maxBPM - minBPM)).rounded())
            if newBPM != bpm {
                bpm = min(max(newBPM, minBPM), maxBPM)
            }
        } else if adjusted > 270 && adjusted < 315 {
            if bpm != maxBPM {
                bpm = maxBPM
            }
        } else {
            if bpm != minBPM {
                bpm = minBPM
            }
        }
    }

    private func tempoDescriptor(for bpm: Int) -> String {
        switch bpm {
        case ..<80: return "Slow & Relaxed"
        case 80..<110: return "Steady Flow"
        case 110..<140: return "Moderate Pacing"
        case 140..<165: return "Brisk Rhythm"
        default: return "Fast Tempo"
        }
    }
}


// MARK: - 3. Select BPM Screen
public struct BeatBuddyBPMView: View {
    @Bindable public var state: AppState
    @Environment(\.headerNamespace) private var headerNamespace
    public var onBack: (() -> Void)? = nil
    public var onStartPractice: (() -> Void)? = nil
    @State private var soundEnabled: Bool = true
    @State private var vibrationEnabled: Bool = true
    @State private var selectedCategory: BeatBuddySoundCategory = .randomized

    public init(state: AppState, onBack: (() -> Void)? = nil, onStartPractice: (() -> Void)? = nil) {
        self.state = state
        self.onBack = onBack
        self.onStartPractice = onStartPractice
    }

    public var body: some View {
        ZStack(alignment: .top) {
            // Dark Background
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Top Header Banner
                headerImageView

                // Header Bar with Back Button & Beat Buddy name on top of the image
                HStack(spacing: 12) {
                    BackNavButton {
                        if let onBack {
                            onBack()
                        } else {
                            state.navigate(to: .homeDashboard, forward: false)
                        }
                    }

                    Text("Beat Buddy")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: Color.black.opacity(0.45), radius: 6, x: 0, y: 2)

                    Spacer()

                    GlassCloseButton {
                        state.navigate(to: .homeDashboard, forward: false)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, -48)
                .padding(.bottom, 6)

                // Subtitle
                Text("Speak with the steady beat")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textSecondaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 2)

                // Randomized Practice Words Card (indicates random words in practice)
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 228 / 255, green: 220 / 255, blue: 255 / 255))
                            .frame(width: 40, height: 40)
                        Image(systemName: "shuffle")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(StamerleeTheme.primaryBlue)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Randomized Practice Words")
                            .font(.system(size: 14.5, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Practice will automatically cycle through random words with the beat")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(StamerleeTheme.textSecondaryDark)
                            .lineLimit(2)
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
                .padding(.horizontal, 24)
                .padding(.top, 14)

                Spacer(minLength: 12)

                // Arc Dial Centered
                HStack {
                    Spacer()
                    ArcBPMDialView(bpm: $state.beatBuddyBPM, size: 220)
                    Spacer()
                }

                Spacer(minLength: 14)

                // Sound & Vibration Toggles
                HStack(spacing: 12) {
                    toggleButton(title: "Sound", icon: "speaker.wave.2.fill", isOn: state.beatBuddySoundEnabled) {
                        state.beatBuddySoundEnabled.toggle()
                    }
                    toggleButton(title: "Vibration", icon: "iphone.radiowaves.left.and.right", isOn: state.beatBuddyVibrationEnabled) {
                        state.beatBuddyVibrationEnabled.toggle()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                Spacer()

                // Primary Start Button
                VStack {
                    PrimaryActionButton(title: "▶ Start Metronome") {
                        startSession()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            if let cat = BeatBuddySoundCategory(rawValue: state.beatBuddySoundCategory) {
                selectedCategory = cat
            } else {
                selectedCategory = .randomized
            }
        }
        .sensoryFeedback(.selection, trigger: state.beatBuddyBPM)
        .sensoryFeedback(.selection, trigger: selectedCategory)
    }

    @ViewBuilder
    private var headerImageView: some View {
        Group {
            if let uiImage = UIImage(named: "header") ?? UIImage(named: "Header") {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(edges: .top)
            } else {
                Image("Header")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(edges: .top)
            }
        }
        .matchedGeometryEffectIfPresent(id: "headerBanner", in: headerNamespace)
    }

    private func startSession() {
        state.beatBuddySoundCategory = BeatBuddySoundCategory.randomized.rawValue
        let wordsList = BeatBuddySoundCategory.randomized.words
        state.beatBuddyPracticeWords = wordsList
        state.beatBuddySelectedWords = Set(wordsList)
        if let onStartPractice {
            onStartPractice()
        } else {
            state.navigate(to: .beatBuddyPractice)
        }
    }

    private func adjustBPM(by delta: Int) {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
            state.beatBuddyBPM = min(max(state.beatBuddyBPM + delta, 60), 180)
        }
    }

    private func toggleButton(title: String, icon: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(isOn ? .white : StamerleeTheme.textSecondaryDark)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isOn ? StamerleeTheme.primaryBlue.opacity(0.38) : Color.white.opacity(0.06), in: Capsule())
            .overlay(
                Capsule().stroke(
                    isOn ? StamerleeTheme.primaryBlue : Color.white.opacity(0.08),
                    lineWidth: 1
                )
            )
        }
        .buttonStyle(.haptic)
    }
}

// MARK: - 4. Practice Session Screen
// Matches the Prolonged Speech Practice UI design with Syllable-by-Syllable Metronome Beat & pop.mp3 audio
public struct BeatBuddyPracticeView: View {
    @Bindable public var state: AppState
    public var onBack: (() -> Void)? = nil
    public var onFinish: (() -> Void)? = nil

    @State private var currentWordIndex = 0
    @State private var activeSyllableIndex = 0
    @State private var isMetronomeActive = true
    @State private var isListening = false
    @State private var pulse = false
    @State private var isBeating = false

    @State private var metronomeTask: Task<Void, Never>?
    @State private var advanceTask: Task<Void, Never>?

    private let popPlayer = BeatMetronomePlayer.shared

    public init(state: AppState, onBack: (() -> Void)? = nil, onFinish: (() -> Void)? = nil) {
        self.state = state
        self.onBack = onBack
        self.onFinish = onFinish
    }

    private var words: [String] {
        if !state.beatBuddyPracticeWords.isEmpty {
            return state.beatBuddyPracticeWords
        }
        if !state.beatBuddySelectedWords.isEmpty {
            return Array(state.beatBuddySelectedWords)
        }
        return BeatBuddySoundCategory.randomized.words
    }

    private var wordCount: Int {
        max(words.count, 1)
    }

    private var currentWord: String {
        guard !words.isEmpty else { return "" }
        return words[min(currentWordIndex, words.count - 1)]
    }

    private var currentSyllables: [String] {
        SyllableHelper.split(currentWord)
    }

    public var body: some View {
        ZStack(alignment: .top) {
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()

            BackgroundImagesDecorationView()

            VStack(spacing: 0) {
                topBar

                Text("Speak each syllable with the metronome beat. Stay relaxed and let the rhythm guide your pace.")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .foregroundStyle(Color(red: 220 / 255, green: 215 / 255, blue: 245 / 255))
                    .lineSpacing(3.5)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 14)

                Spacer(minLength: 14)

                promptDisplay

                progress
                    .padding(.top, 16)

                Spacer(minLength: 16)

                microphoneControl

                Text("Tap and speak with the beat")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(red: 194 / 255, green: 192 / 255, blue: 218 / 255))
                    .padding(.top, 8)

                Spacer(minLength: 12)

                Button {
                    finishPractice()
                } label: {
                    HStack(spacing: 10) {
                        Text("Finish Practice")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .buttonStyle(BeatBuddyFinishButtonStyle())
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            activeSyllableIndex = 0
            startMetronome()
        }
        .onDisappear {
            stopAll()
        }
        .onChange(of: isMetronomeActive) { _, active in
            if active {
                startMetronome()
            } else {
                stopMetronome()
            }
        }
    }

    private var topBar: some View {
        HStack {
            BackNavButton {
                stopAll()
                if let onBack {
                    onBack()
                } else {
                    state.navigate(to: .beatBuddyBPM, forward: false)
                }
            }

            Spacer()
        }
    }

    private var promptDisplay: some View {
        let syllables = currentSyllables

        return VStack(spacing: 12) {
            // Full original word caption
            Text(currentWord)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(StamerleeTheme.textSecondaryDark)
                .opacity(0.85)

            // Syllables broken with hyphens and animated to the metronome beat
            HStack(spacing: 6) {
                ForEach(Array(syllables.enumerated()), id: \.offset) { index, syllable in
                    let isActive = (index == activeSyllableIndex) && isMetronomeActive

                    HStack(spacing: 6) {
                        VStack(spacing: 6) {
                            Text(syllable)
                                .font(.system(size: syllableFontSize(for: syllables), weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    isActive
                                        ? AnyShapeStyle(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 175 / 255, green: 145 / 255, blue: 255 / 255),
                                                    Color(red: 100 / 255, green: 225 / 255, blue: 255 / 255)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        : AnyShapeStyle(Color.white.opacity(0.35))
                                )
                                .scaleEffect(isActive ? (isBeating ? 1.08 : 1.04) : 1.0)
                                .shadow(
                                    color: isActive
                                        ? Color(red: 139 / 255, green: 92 / 255, blue: 246 / 255).opacity(isBeating ? 0.8 : 0.4)
                                        : .clear,
                                    radius: isBeating ? 12 : 6
                                )

                            // Glowing beat indicator capsule beneath active syllable
                            Capsule()
                                .fill(
                                    isActive
                                        ? LinearGradient(
                                            colors: [StamerleeTheme.primaryBlue, Color.cyan],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        : LinearGradient(
                                            colors: [Color.white.opacity(0.12), Color.white.opacity(0.12)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                )
                                .frame(width: isActive ? 24 : 10, height: 3.5)
                                .shadow(color: isActive ? Color.cyan.opacity(0.7) : .clear, radius: 4)
                        }
                        .animation(.spring(response: 0.22, dampingFraction: 0.6), value: isActive)
                        .animation(.spring(response: 0.18, dampingFraction: 0.5), value: isBeating)

                        if index < syllables.count - 1 {
                            Text("-")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.25))
                                .padding(.horizontal, 2)
                                .padding(.bottom, 8)
                        }
                    }
                }
            }
            .id(currentWordIndex)
            .transition(.opacity.combined(with: .scale(scale: 0.96)))
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            advanceWord()
        }
    }

    private func syllableFontSize(for syllables: [String]) -> CGFloat {
        let totalChars = syllables.reduce(0) { $0 + $1.count } + (syllables.count - 1) * 2
        if totalChars > 16 {
            return 22
        } else if totalChars > 12 {
            return 26
        } else if totalChars > 8 {
            return 30
        } else {
            return 34
        }
    }

    private var progress: some View {
        VStack(spacing: 8) {
            Text("\(currentWordIndex + 1) of \(wordCount)")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(Color(red: 147 / 255, green: 145 / 255, blue: 175 / 255))

            HStack(spacing: 7) {
                ForEach(0..<min(wordCount, 8), id: \.self) { idx in
                    Circle()
                        .fill(idx == currentWordIndex % min(wordCount, 8) ? .white : Color(red: 80 / 255, green: 79 / 255, blue: 111 / 255))
                        .frame(width: 7, height: 7)
                }
            }
        }
    }

    private var microphoneControl: some View {
        Button {
            startListening()
        } label: {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    .frame(width: 118, height: 118)
                    .scaleEffect(isListening && pulse ? 1.10 : ((isBeating && isMetronomeActive) ? 1.04 : 1))
                    .opacity(isListening ? (pulse ? 0.35 : 0.9) : 1)

                Circle()
                    .stroke(StamerleeTheme.primaryPurple.opacity(isListening ? 0.45 : ((isBeating && isMetronomeActive) ? 0.35 : 0.25)), lineWidth: 9)
                    .frame(width: 100, height: 100)
                    .scaleEffect(isListening && pulse ? 1.06 : ((isBeating && isMetronomeActive) ? 1.03 : 1))
                    .opacity(isListening ? (pulse ? 0.55 : 1) : 1)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [StamerleeTheme.accentPurpleLight, StamerleeTheme.primaryPurpleDark],
                            center: .topLeading,
                            startRadius: 2,
                            endRadius: 55
                        )
                    )
                    .frame(width: 76, height: 76)
                    .shadow(color: StamerleeTheme.primaryPurple.opacity(isListening ? 0.9 : 0.6), radius: isListening ? 18 : 12)
                    .scaleEffect(isListening && pulse ? 1.04 : 1)

                Image(systemName: "mic.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(.white)
                    .scaleEffect(isListening && pulse ? 1.06 : 1)
            }
            .frame(width: 134, height: 134)
            .contentShape(Circle())
            .animation(
                isListening
                    ? .easeInOut(duration: 0.75).repeatForever(autoreverses: true)
                    : .easeOut(duration: 0.2),
                value: pulse
            )
        }
        .buttonStyle(.haptic(weight: .medium, pressedScale: 0.96))
        .disabled(isListening)
        .accessibilityLabel(isListening ? "Listening" : "Speak with the beat")
        .sensoryFeedback(.impact(weight: .medium), trigger: isListening)
    }

    private func startListening() {
        guard !isListening else { return }

        advanceTask?.cancel()
        isListening = true
        pulse = true

        advanceTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }

            withAnimation(.easeInOut(duration: 0.22)) {
                pulse = false
                isListening = false
                advanceWord()
            }
        }
    }

    private func advanceWord() {
        withAnimation(.easeInOut(duration: 0.22)) {
            if currentWordIndex + 1 < wordCount {
                currentWordIndex += 1
                activeSyllableIndex = 0
                startMetronome()
            } else {
                finishPractice()
            }
        }
    }

    private func startMetronome() {
        metronomeTask?.cancel()
        guard isMetronomeActive else { return }

        let bpm = max(40, min(state.beatBuddyBPM, 200))
        let intervalSeconds = 60.0 / Double(bpm)
        let intervalNanos = UInt64(intervalSeconds * 1_000_000_000)
        let pulseDurationNanos = min(intervalNanos / 3, 160_000_000)

        metronomeTask = Task { @MainActor in
            let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
            impactGenerator.prepare()

            while !Task.isCancelled && isMetronomeActive {
                // Play sound effect on each syllable beat if enabled
                if state.beatBuddySoundEnabled {
                    popPlayer.playPop()
                }
                // Trigger physical haptic vibration if enabled
                if state.beatBuddyVibrationEnabled {
                    impactGenerator.impactOccurred()
                    impactGenerator.prepare()
                }

                let syllables = currentSyllables
                let count = max(syllables.count, 1)

                withAnimation(.spring(response: 0.20, dampingFraction: 0.58)) {
                    isBeating = true
                }

                try? await Task.sleep(nanoseconds: pulseDurationNanos)
                guard !Task.isCancelled else { break }

                withAnimation(.easeOut(duration: 0.18)) {
                    isBeating = false
                }

                let remainingNanos = intervalNanos > pulseDurationNanos ? (intervalNanos - pulseDurationNanos) : (intervalNanos / 2)
                try? await Task.sleep(nanoseconds: remainingNanos)
                guard !Task.isCancelled else { break }

                // Advance to next syllable for the next beat
                withAnimation(.easeInOut(duration: 0.16)) {
                    activeSyllableIndex = (activeSyllableIndex + 1) % count
                }
            }
        }
    }

    private func stopMetronome() {
        metronomeTask?.cancel()
        metronomeTask = nil
        isBeating = false
        popPlayer.stop()
    }

    private func stopAll() {
        stopMetronome()
        advanceTask?.cancel()
        advanceTask = nil
        isListening = false
        pulse = false
    }

    private func finishPractice() {
        stopAll()
        if let onFinish {
            onFinish()
        } else {
            state.navigate(to: .homeDashboard, forward: false)
        }
    }
}

// MARK: - Syllable Splitter Helper
public enum SyllableHelper {
    public static let dictionary: [String: [String]] = [
        "university": ["uni", "ver", "sity"],
        "water": ["wa", "ter"],
        "breaking": ["break", "ing"],
        "computer": ["com", "pu", "ter"],
        "scale": ["scale"],
        "laptop": ["lap", "top"],
        "vinyl": ["vi", "nyl"],
        "desk": ["desk"],
        "swift": ["swift"],
        "center": ["cen", "ter"],
        "protocol": ["pro", "to", "col"],
        "optional": ["op", "tion", "al"],
        "morning": ["morn", "ing"],
        "coffee": ["cof", "fee"],
        "please": ["please"],
        "breathe": ["breathe"],
        "gentle": ["gen", "tle"],
        "together": ["to", "geth", "er"],
        "pacing": ["pa", "cing"],
        "speech": ["speech"],
        "natural": ["nat", "u", "ral"],
        "freedom": ["free", "dom"],
        "balance": ["bal", "ance"],
        "progress": ["prog", "ress"],
        "connection": ["con", "nec", "tion"],
        "confidence": ["con", "fi", "dence"],
        "smooth": ["smooth"],
        "presence": ["pres", "ence"],
        "story": ["sto", "ry"],
        "clarity": ["clar", "i", "ty"],
        "courage": ["cour", "age"],
        "keep": ["keep"],
        "care": ["care"],
        "kitchen": ["kitch", "en"],
        "key": ["key"],
        "kite": ["kite"],
        "candle": ["can", "dle"],
        "memory": ["mem", "o", "ry"],
        "mind": ["mind"],
        "music": ["mu", "sic"],
        "motion": ["mo", "tion"],
        "master": ["mas", "ter"],
        "moment": ["mo", "ment"],
        "manage": ["man", "age"],
        "market": ["mar", "ket"],
        "message": ["mes", "sage"],
        "silence": ["si", "lence"],
        "steady": ["stead", "y"],
        "start": ["start"],
        "simple": ["sim", "ple"],
        "sunlight": ["sun", "light"],
        "peace": ["peace"],
        "power": ["pow", "er"],
        "practice": ["prac", "tice"],
        "paper": ["pa", "per"],
        "picture": ["pic", "ture"],
        "today": ["to", "day"],
        "time": ["time"],
        "topic": ["top", "ic"],
        "travel": ["trav", "el"],
        "target": ["tar", "get"],
        "trust": ["trust"],
        "training": ["train", "ing"],
        "tomorrow": ["to", "mor", "row"],
        "table": ["ta", "ble"],
        "bright": ["bright"],
        "begin": ["be", "gin"],
        "build": ["build"],
        "belief": ["be", "lief"],
        "better": ["bet", "ter"],
        "bridge": ["bridge"],
        "button": ["but", "ton"]
    ]

    public static func split(_ word: String) -> [String] {
        let clean = word.trimmingCharacters(in: .whitespacesAndNewlines)
        let key = clean.lowercased()
        if let entry = dictionary[key] {
            if let firstChar = clean.first, firstChar.isUppercase {
                var capitalized = entry
                capitalized[0] = capitalized[0].prefix(1).uppercased() + capitalized[0].dropFirst()
                return capitalized
            }
            return entry
        }
        if clean.contains("-") {
            return clean.split(separator: "-").map { String($0) }
        }
        return ruleBasedSplit(clean)
    }

    private static func ruleBasedSplit(_ word: String) -> [String] {
        guard word.count > 4 else { return [word] }
        let vowels: Set<Character> = ["a", "e", "i", "o", "u", "y", "A", "E", "I", "O", "U", "Y"]
        var chunks: [String] = []
        var current = ""
        var hasVowel = false

        for char in word {
            current.append(char)
            if vowels.contains(char) {
                hasVowel = true
            } else if hasVowel && current.count >= 2 {
                chunks.append(current)
                current = ""
                hasVowel = false
            }
        }
        if !current.isEmpty {
            if chunks.isEmpty {
                chunks.append(current)
            } else {
                chunks[chunks.count - 1].append(current)
            }
        }
        return chunks.isEmpty ? [word] : chunks
    }
}

// MARK: - Metronome Audio Player for pop.mp3
@MainActor
final class BeatMetronomePlayer {
    static let shared = BeatMetronomePlayer()

    private var players: [AVAudioPlayer] = []
    private var playerIndex = 0

    private init() {
        setup()
    }

    private func setup() {
        let url = Bundle.main.url(forResource: "pop", withExtension: "mp3")
            ?? Bundle.main.url(forResource: "pop.mp3", withExtension: nil)
            ?? Bundle.main.url(forResource: "pop", withExtension: "mp3", subdirectory: "Stamerlee")

        guard let soundURL = url else {
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)

            for _ in 0..<3 {
                if let p = try? AVAudioPlayer(contentsOf: soundURL) {
                    p.prepareToPlay()
                    players.append(p)
                }
            }
        } catch {
            print("BeatMetronomePlayer audio session error: \(error)")
        }
    }

    func playPop() {
        if players.isEmpty {
            setup()
        }
        guard !players.isEmpty else { return }

        let player = players[playerIndex]
        player.currentTime = 0
        player.play()
        playerIndex = (playerIndex + 1) % players.count
    }

    func stop() {
        for player in players {
            player.stop()
        }
    }
}

private struct BeatBuddyFinishButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(StamerleeTheme.primaryPurple, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

private struct BeatBuddyBPMButtonStyle: ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Capsule()
                    .fill(isEnabled ? StamerleeTheme.primaryBlue : Color.white.opacity(0.08))
            )
            .overlay(
                Capsule()
                    .stroke(isEnabled ? Color.white.opacity(0.3) : Color.white.opacity(0.12), lineWidth: 1)
            )
            .contentShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
