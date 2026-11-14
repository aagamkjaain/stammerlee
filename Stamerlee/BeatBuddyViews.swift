import SwiftUI

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
        ZStack {
            StamerleeTheme.backgroundDark.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                BackNavButton {
                    if let onBack {
                        onBack()
                    } else {
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
        BeatBuddyShell(state: state, onBack: {
            if let onBack {
                onBack()
            } else {
                state.navigate(to: .homeDashboard, forward: false)
            }
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // Headings
                Text("Select BPM")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textPrimaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                Text("Speak with the steady beat")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textSecondaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 4)

                // Sound Category Picker
                VStack(alignment: .leading, spacing: 6) {
                    Text("Sound Focus")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textSecondaryDark)

                    Menu {
                        Picker("Sound Focus", selection: $selectedCategory) {
                            ForEach(BeatBuddySoundCategory.allCases) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "waveform")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.cyan)

                            Text(selectedCategory.rawValue)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)

                            Spacer()

                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(StamerleeTheme.textSecondaryDark)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)

                Spacer(minLength: 16)

                // Arc Dial Centered
                HStack {
                    Spacer()
                    ArcBPMDialView(bpm: $state.beatBuddyBPM, size: 240)
                    Spacer()
                }

                Spacer(minLength: 14)

                // Stepper Buttons (- and +)
                HStack {
                    Button {
                        adjustBPM(by: -5)
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Button {
                        adjustBPM(by: 5)
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 48)
                .padding(.bottom, 16)

                // Sound & Vibration Toggles
                HStack(spacing: 12) {
                    toggleButton(title: "Sound", icon: "speaker.wave.2.fill", isOn: soundEnabled) {
                        soundEnabled.toggle()
                    }
                    toggleButton(title: "Vibration", icon: "iphone.radiowaves.left.and.right", isOn: vibrationEnabled) {
                        vibrationEnabled.toggle()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

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

    private func startSession() {
        state.beatBuddySoundCategory = selectedCategory.rawValue
        let wordsList = selectedCategory.words
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
public struct BeatBuddyPracticeView: View {
    @Bindable public var state: AppState
    public var onBack: (() -> Void)? = nil
    public var onFinish: (() -> Void)? = nil
    @State private var index = 0

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

    public var body: some View {
        BeatBuddyShell(state: state, onBack: {
            if let onBack {
                onBack()
            } else {
                state.navigate(to: .beatBuddyBPM, forward: false)
            }
        }) {
            VStack(spacing: 0) {
                // Top Info Bar (Sound Category Badge and BPM Badge)
                HStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "waveform")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.cyan)
                        Text(state.beatBuddySoundCategory)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.08), in: Capsule())

                    Spacer()

                    // BPM Badge
                    HStack(spacing: 6) {
                        Image(systemName: "metronome.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.cyan)
                        Text("\(state.beatBuddyBPM) BPM")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.08), in: Capsule())
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)

                Spacer()

                // Center Word Practice Card (Large, prominent, clean)
                VStack(spacing: 18) {
                    Text(words[min(index, words.count - 1)])
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textSecondaryDark)

                    Text(splitWord(words[min(index, words.count - 1)]))
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    // Page Indicator Dots
                    HStack(spacing: 8) {
                        ForEach(0..<words.count, id: \.self) { i in
                            Circle()
                                .fill(i == index ? Color.cyan : Color.white.opacity(0.2))
                                .frame(width: i == index ? 8 : 6, height: i == index ? 8 : 6)
                        }
                    }
                    .padding(.top, 6)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .background(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 25 / 255, green: 40 / 255, blue: 95 / 255),
                                    Color(red: 18 / 255, green: 22 / 255, blue: 50 / 255)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.35), radius: 18, x: 0, y: 10)
                .padding(.horizontal, 24)

                Spacer()

                // Bottom Action Button
                VStack {
                    PrimaryActionButton(title: index + 1 < words.count ? "Next Word" : "Finish Practice") {
                        if index + 1 < words.count {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                index += 1
                            }
                        } else {
                            if let onFinish {
                                onFinish()
                            } else {
                                state.navigate(to: .homeDashboard, forward: false)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }

    private func splitWord(_ word: String) -> AttributedString {
        var result = AttributedString(word)
        let split = result.index(result.startIndex, offsetByCharacters: max(1, word.count / 2))
        if split < result.endIndex {
            result[split...].foregroundColor = Color.cyan
        }
        return result
    }
}
