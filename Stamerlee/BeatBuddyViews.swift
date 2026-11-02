import SwiftUI

private let defaultBeatBuddyWords = [
    "Water", "University", "Breaking", "Computer", "Scale", "Laptop",
    "Vinyl", "Desk", "Swift", "Center", "Protocol", "Optional",
    "Morning", "Coffee", "Please", "Breathe", "Gentle", "Together",
    "Pacing", "Speech", "Natural", "Freedom", "Balance", "Progress",
    "Connection", "Confidence", "Smooth", "Presence", "Story", "Clarity"
]

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

// MARK: - 0. Beat Buddy Practice Type Selection Screen (Words / Sounds)
public struct BeatBuddyPracticeTypeView: View {
    @Bindable public var state: AppState
    @State private var path: [AppScreen] = []

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                StamerleeTheme.backgroundDark.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    // Back Button
                    BackNavButton {
                        state.navigate(to: .homeDashboard, forward: false)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    // Headings
                    Text("Practice")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.top, 18)

                    Text("Practise at your own pace with guided metronome beats.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(Color(red: 175 / 255, green: 170 / 255, blue: 205 / 255))
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        .padding(.bottom, 20)

                    // Cards (Words & Sounds)
                    VStack(spacing: 12) {
                        PracticeOptionCard(
                            title: "Words",
                            subtitle: "Practise words you've struggled with through guided speaking exercises.",
                            systemImage: "text.bubble"
                        ) {
                            state.beatBuddyMode = .words
                            path.append(.beatBuddyWords)
                        }

                        PracticeOptionCard(
                            title: "Sounds",
                            subtitle: "Focus on specific sounds and build confidence through short, targeted exercises.",
                            systemImage: "waveform"
                        ) {
                            state.beatBuddyMode = .sounds
                            path.append(.beatBuddySounds)
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: AppScreen.self) { screen in
                switch screen {
                case .beatBuddyWords:
                    BeatBuddyWordsView(state: state, onBack: {
                        if !path.isEmpty {
                            path.removeLast()
                        } else {
                            state.navigate(to: .beatBuddyPracticeType, forward: false)
                        }
                    }, onContinue: {
                        path.append(.beatBuddyBPM)
                    })
                    .navigationBarBackButtonHidden(true)

                case .beatBuddySounds:
                    BeatBuddySoundsView(state: state, onBack: {
                        if !path.isEmpty {
                            path.removeLast()
                        } else {
                            state.navigate(to: .beatBuddyPracticeType, forward: false)
                        }
                    }, onContinue: {
                        path.append(.beatBuddyBPM)
                    })
                    .navigationBarBackButtonHidden(true)

                case .beatBuddyBPM:
                    BeatBuddyBPMView(state: state, onBack: {
                        if !path.isEmpty {
                            path.removeLast()
                        } else {
                            state.navigate(to: state.beatBuddyMode == .sounds ? .beatBuddySounds : .beatBuddyWords, forward: false)
                        }
                    }, onStartPractice: {
                        path.append(.beatBuddyPractice)
                    })
                    .navigationBarBackButtonHidden(true)

                case .beatBuddyPractice:
                    BeatBuddyPracticeView(state: state, onBack: {
                        if !path.isEmpty {
                            path.removeLast()
                        } else {
                            state.navigate(to: .beatBuddyBPM, forward: false)
                        }
                    }, onFinish: {
                        path.removeAll()
                        state.navigate(to: .homeDashboard, forward: false)
                    })
                    .navigationBarBackButtonHidden(true)

                default:
                    EmptyView()
                }
            }
        }
    }
}

// MARK: - 1. Word Selection Screen
public struct BeatBuddyWordsView: View {
    @Bindable public var state: AppState
    public var onBack: (() -> Void)? = nil
    public var onContinue: (() -> Void)? = nil
    @State private var searchText = ""

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

    private var filteredWords: [String] {
        allWords.filter { searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }
    }

    private var isAllSelected: Bool {
        !filteredWords.isEmpty && filteredWords.allSatisfy { state.beatBuddySelectedWords.contains($0) }
    }

    public var body: some View {
        BeatBuddyShell(state: state, onBack: {
            if let onBack {
                onBack()
            } else {
                state.navigate(to: .beatBuddyPracticeType, forward: false)
            }
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // Screen Headings
                Text("Select Words")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textPrimaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                Text("Choose the words you want to practice with Beat Buddy")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textSecondaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(StamerleeTheme.textSecondaryDark)

                    TextField("Search words...", text: $searchText)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                        .tint(StamerleeTheme.primaryBlue)

                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(StamerleeTheme.textSecondaryDark)
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(Color.white.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal, 24)
                .padding(.top, 20)

                // Action Row: Counter + Single Toggle Button
                HStack {
                    Text("\(state.beatBuddySelectedWords.count) selected")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textSecondaryDark)

                    Spacer()

                    Button(isAllSelected ? "Deselect all" : "Select all") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if isAllSelected {
                                for word in filteredWords {
                                    state.beatBuddySelectedWords.remove(word)
                                }
                            } else {
                                for word in filteredWords {
                                    state.beatBuddySelectedWords.insert(word)
                                }
                            }
                        }
                    }
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(StamerleeTheme.primaryBlue)
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
                .padding(.bottom, 6)

                // Scrollable Words Grid (Larger Cards)
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
                        spacing: 14
                    ) {
                        ForEach(filteredWords, id: \.self) { word in
                            let isSelected = state.beatBuddySelectedWords.contains(word)
                            Button {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                    if isSelected {
                                        state.beatBuddySelectedWords.remove(word)
                                    } else {
                                        state.beatBuddySelectedWords.insert(word)
                                    }
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    Text(word)
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(isSelected ? .white : StamerleeTheme.textPrimaryDark)

                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 17, weight: .bold))
                                            .foregroundStyle(StamerleeTheme.primaryBlue)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 64)
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous).fill(
                                        isSelected
                                            ? StamerleeTheme.primaryBlue.opacity(0.38)
                                            : Color.white.opacity(0.07)
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(
                                        isSelected
                                            ? StamerleeTheme.primaryBlue
                                            : Color.white.opacity(0.12),
                                        lineWidth: isSelected ? 1.5 : 1
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                            .buttonStyle(.haptic)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }

                // Anchored CTA
                VStack {
                    PrimaryActionButton(title: "Continue") {
                        if state.beatBuddySelectedWords.isEmpty {
                            state.beatBuddySelectedWords = ["Water", "Coffee"]
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
        .sensoryFeedback(.selection, trigger: state.beatBuddySelectedWords)
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

// MARK: - Predefined Sound Items for Beat Buddy
private struct BeatBuddySoundItem: Identifiable, Hashable {
    let id: String
    let title: String
    let phonetic: String
    let exampleWords: [String]
}

private let defaultBeatBuddySounds: [BeatBuddySoundItem] = [
    BeatBuddySoundItem(id: "pb", title: "P, B", phonetic: "/p/, /b/", exampleWords: ["Please", "Book", "Paper", "Breathe"]),
    BeatBuddySoundItem(id: "td", title: "T, D", phonetic: "/t/, /d/", exampleWords: ["Today", "Door", "Together", "Desk"]),
    BeatBuddySoundItem(id: "kg", title: "K, G", phonetic: "/k/, /ɡ/", exampleWords: ["Coffee", "Gentle", "Keep", "Good"]),
    BeatBuddySoundItem(id: "sz", title: "S, Z", phonetic: "/s/, /z/", exampleWords: ["Speech", "Smooth", "Zone", "Scale"]),
    BeatBuddySoundItem(id: "fv", title: "F, V", phonetic: "/f/, /v/", exampleWords: ["Freedom", "Vinyl", "Focus", "Voice"]),
    BeatBuddySoundItem(id: "mn", title: "M, N", phonetic: "/m/, /n/", exampleWords: ["Morning", "Natural", "Mind", "Name"]),
    BeatBuddySoundItem(id: "rl", title: "R, L", phonetic: "/r/, /l/", exampleWords: ["Rhythm", "Laptop", "Relax", "Light"]),
    BeatBuddySoundItem(id: "th", title: "TH", phonetic: "/θ/, /ð/", exampleWords: ["Think", "Together", "Through", "Thanks"]),
    BeatBuddySoundItem(id: "shch", title: "SH, CH", phonetic: "/ʃ/, /tʃ/", exampleWords: ["Sharp", "Change", "Choice", "Share"])
]

// MARK: - 2. Sound Selection Screen
public struct BeatBuddySoundsView: View {
    @Bindable public var state: AppState
    public var onBack: (() -> Void)? = nil
    public var onContinue: (() -> Void)? = nil
    @State private var searchText = ""

    public init(state: AppState, onBack: (() -> Void)? = nil, onContinue: (() -> Void)? = nil) {
        self.state = state
        self.onBack = onBack
        self.onContinue = onContinue
    }

    private var filteredSounds: [BeatBuddySoundItem] {
        defaultBeatBuddySounds.filter {
            searchText.isEmpty ||
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.exampleWords.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
        }
    }

    private var isAllSelected: Bool {
        !filteredSounds.isEmpty && filteredSounds.allSatisfy { state.beatBuddySelectedSounds.contains($0.title) }
    }

    public var body: some View {
        BeatBuddyShell(state: state, onBack: {
            if let onBack {
                onBack()
            } else {
                state.navigate(to: .beatBuddyPracticeType, forward: false)
            }
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // Screen Headings
                Text("Select Sounds")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textPrimaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                Text("Choose specific sounds to focus on with guided metronome beats")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textSecondaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(StamerleeTheme.textSecondaryDark)

                    TextField("Search sounds or words...", text: $searchText)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                        .tint(StamerleeTheme.primaryPurple)

                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(StamerleeTheme.textSecondaryDark)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(red: 25 / 255, green: 22 / 255, blue: 45 / 255))
                )
                .padding(.horizontal, 24)
                .padding(.top, 20)

                // Controls row
                HStack {
                    Text("\(state.beatBuddySelectedSounds.count) selected")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(StamerleeTheme.primaryPurple)

                    Spacer()

                    Button {
                        if isAllSelected {
                            for item in filteredSounds {
                                state.beatBuddySelectedSounds.remove(item.title)
                            }
                        } else {
                            for item in filteredSounds {
                                state.beatBuddySelectedSounds.insert(item.title)
                            }
                        }
                    } label: {
                        Text(isAllSelected ? "Deselect All" : "Select All")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(StamerleeTheme.primaryPurple)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
                .padding(.bottom, 8)

                // Sounds List
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(filteredSounds) { item in
                            let isSelected = state.beatBuddySelectedSounds.contains(item.title)
                            Button {
                                if isSelected {
                                    state.beatBuddySelectedSounds.remove(item.title)
                                } else {
                                    state.beatBuddySelectedSounds.insert(item.title)
                                }
                            } label: {
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 8) {
                                            Text(item.title)
                                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                                .foregroundStyle(.white)

                                            Text(item.phonetic)
                                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                                .foregroundStyle(StamerleeTheme.textSecondaryDark)
                                        }

                                        Text(item.exampleWords.joined(separator: ", "))
                                            .font(.system(size: 13, weight: .regular, design: .rounded))
                                            .foregroundStyle(StamerleeTheme.textSecondaryDark)
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(isSelected ? StamerleeTheme.primaryPurple : Color.white.opacity(0.3))
                                }
                                .padding(.horizontal, 18)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(isSelected ? StamerleeTheme.primaryPurple.opacity(0.12) : Color.white.opacity(0.04))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(isSelected ? StamerleeTheme.primaryPurple : Color.white.opacity(0.08), lineWidth: isSelected ? 1.5 : 1)
                                )
                            }
                            .buttonStyle(.haptic)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 6)
                    .padding(.bottom, 24)
                }

                // Continue Button
                VStack {
                    PrimaryActionButton(title: "Continue") {
                        if state.beatBuddySelectedSounds.isEmpty {
                            state.beatBuddySelectedSounds = ["P, B", "T, D"]
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
        .sensoryFeedback(.selection, trigger: state.beatBuddySelectedSounds)
    }
}

// MARK: - 3. Select BPM Screen
public struct BeatBuddyBPMView: View {
    @Bindable public var state: AppState
    public var onBack: (() -> Void)? = nil
    public var onStartPractice: (() -> Void)? = nil
    @State private var soundEnabled: Bool = true
    @State private var vibrationEnabled: Bool = true

    public init(state: AppState, onBack: (() -> Void)? = nil, onStartPractice: (() -> Void)? = nil) {
        self.state = state
        self.onBack = onBack
        self.onStartPractice = onStartPractice
    }

    public var body: some View {
        BeatBuddyShell(state: state, onBack: {
            if let onBack {
                onBack()
            } else if state.beatBuddyMode == .sounds {
                state.navigate(to: .beatBuddySounds, forward: false)
            } else {
                state.navigate(to: .beatBuddyWords, forward: false)
            }
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // Headings
                Text("Select BPM")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textPrimaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 18)

                Text("Speak with the steady beat")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textSecondaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 6)

                Spacer(minLength: 24)

                // Arc Dial Centered
                HStack {
                    Spacer()
                    ArcBPMDialView(bpm: $state.beatBuddyBPM, size: 250)
                    Spacer()
                }

                Spacer(minLength: 20)

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
                        if let onStartPractice {
                            onStartPractice()
                        } else {
                            state.navigate(to: .beatBuddyPractice)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .sensoryFeedback(.selection, trigger: state.beatBuddyBPM)
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
        if state.beatBuddyMode == .sounds {
            let soundsList = defaultBeatBuddySounds.filter { state.beatBuddySelectedSounds.contains($0.title) }
            let examples = soundsList.flatMap { $0.exampleWords }
            return examples.isEmpty ? ["Please", "Book", "Today", "Door"] : examples
        }
        return Array(state.beatBuddySelectedWords.isEmpty ? Set(["Water", "Coffee"]) : state.beatBuddySelectedWords)
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
                // Top Info Bar (Only BPM Badge, no timer, no sound icon, no camera icon)
                HStack {
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
