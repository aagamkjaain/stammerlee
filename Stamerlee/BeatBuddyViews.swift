import SwiftUI
import AVFoundation
import AudioToolbox

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

// MARK: - 1. Word Selection Screen
public struct BeatBuddyWordsView: View {
    @Bindable public var state: AppState
    @State private var searchText = ""

    public init(state: AppState) {
        self.state = state
    }

    private var allWords: [String] {
        var words = defaultBeatBuddyWords
        // Prioritize any words the user previously selected in analysis
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
        BeatBuddyShell(state: state) {
            VStack(alignment: .leading, spacing: 0) {
                // Screen Headings
                Text("Select Words")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.textPrimaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                Text("Choose the words you want to practice with Beat Buddy")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(StamerleeTheme.textSecondaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(StamerleeTheme.textSecondaryDark)

                    TextField("Search words...", text: $searchText)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .tint(StamerleeTheme.primaryBlue)

                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(StamerleeTheme.textSecondaryDark)
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
                        .foregroundColor(StamerleeTheme.textSecondaryDark)

                    Spacer()

                    Button(isAllSelected ? "Deselect all" : "Select all") {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
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
                    .foregroundColor(StamerleeTheme.primaryBlue)
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
                .padding(.bottom, 6)

                // Scrollable Words Grid (Capsules with animated checkmarks)
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                        spacing: 12
                    ) {
                        ForEach(filteredWords, id: \.self) { word in
                            let isSelected = state.beatBuddySelectedWords.contains(word)
                            Button {
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                    if isSelected {
                                        state.beatBuddySelectedWords.remove(word)
                                    } else {
                                        state.beatBuddySelectedWords.insert(word)
                                    }
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Text(word)
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(isSelected ? .white : StamerleeTheme.textPrimaryDark)

                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(StamerleeTheme.primaryBlue)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(
                                    Capsule().fill(
                                        isSelected
                                            ? StamerleeTheme.primaryBlue.opacity(0.38)
                                            : Color.white.opacity(0.06)
                                    )
                                )
                                .overlay(
                                    Capsule().stroke(
                                        isSelected
                                            ? StamerleeTheme.primaryBlue
                                            : Color.white.opacity(0.12),
                                        lineWidth: isSelected ? 1.5 : 1
                                    )
                                )
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 6)
                    .padding(.bottom, 24)
                }

                // Anchored CTA
                VStack {
                    PrimaryActionButton(title: "Done") {
                        if state.beatBuddySelectedWords.isEmpty {
                            state.beatBuddySelectedWords = ["Water", "Coffee"]
                        }
                        state.navigate(to: .beatBuddyBPM)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}

// MARK: - 2. Interactive Arc BPM Dial
public struct ArcBPMDialView: View {
    @Binding public var bpm: Int
    public let minBPM: Int = 60
    public let maxBPM: Int = 180
    public let size: CGFloat

    @State private var isDragging: Bool = false
    @State private var beatPulse: Bool = false

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

            // Center Content (Waveform icon, big BPM value, and tempo description)
            VStack(spacing: 3) {
                Image(systemName: "waveform")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 30 / 255, green: 215 / 255, blue: 245 / 255))
                    .scaleEffect(beatPulse ? 1.25 : 0.95)
                    .padding(.bottom, 2)

                Text("\(bpm)")
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())

                Text("BPM")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.textSecondaryDark)
                    .tracking(1.4)

                Text(tempoDescriptor(for: bpm))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.cyan.opacity(0.85))
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
        .onAppear {
            startBeatPulse()
        }
        .onChange(of: bpm) {
            startBeatPulse()
        }
    }

    private func startBeatPulse() {
        let interval = 60.0 / max(Double(bpm), 40.0)
        withAnimation(.easeInOut(duration: min(interval * 0.4, 0.25)).repeatForever(autoreverses: true)) {
            beatPulse = true
        }
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
                let feedback = UISelectionFeedbackGenerator()
                feedback.selectionChanged()
                bpm = min(max(newBPM, minBPM), maxBPM)
            }
        } else if adjusted > 270 && adjusted < 315 {
            if bpm != maxBPM {
                let feedback = UISelectionFeedbackGenerator()
                feedback.selectionChanged()
                bpm = maxBPM
            }
        } else {
            if bpm != minBPM {
                let feedback = UISelectionFeedbackGenerator()
                feedback.selectionChanged()
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
    @State private var soundEnabled: Bool = true
    @State private var vibrationEnabled: Bool = true
    @State private var selectedTimerMinutes: Int = 2

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        BeatBuddyShell(state: state, onBack: {
            state.navigate(to: .beatBuddyWords, forward: false)
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // Headings
                Text("Select BPM")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.textPrimaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 18)

                Text("Speak with the steady beat")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(StamerleeTheme.textSecondaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 6)

                Spacer(minLength: 12)

                // Arc Dial Centered
                HStack {
                    Spacer()
                    ArcBPMDialView(bpm: $state.beatBuddyBPM, size: 236)
                    Spacer()
                }

                Spacer(minLength: 12)

                // Stepper & Quick Presets Row
                HStack(spacing: 12) {
                    Button {
                        adjustBPM(by: -5)
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }

                    Spacer()

                    // Quick BPM preset chips
                    ForEach([60, 90, 120, 150], id: \.self) { preset in
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                state.beatBuddyBPM = preset
                            }
                        } label: {
                            Text("\(preset)")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(state.beatBuddyBPM == preset ? .white : StamerleeTheme.textSecondaryDark)
                                .padding(.horizontal, 11)
                                .padding(.vertical, 7)
                                .background(
                                    state.beatBuddyBPM == preset
                                        ? StamerleeTheme.primaryBlue.opacity(0.5)
                                        : Color.white.opacity(0.05),
                                    in: Capsule()
                                )
                                .overlay(
                                    Capsule().stroke(
                                        state.beatBuddyBPM == preset ? StamerleeTheme.primaryBlue : Color.clear,
                                        lineWidth: 1
                                    )
                                )
                        }
                    }

                    Spacer()

                    Button {
                        adjustBPM(by: 5)
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
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
                .padding(.bottom, 18)

                // Distinct Practice Timer Section (Completely separate, never overlapping!)
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "timer")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color.cyan)
                        Text("PRACTICE TIMER")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(StamerleeTheme.textSecondaryDark)
                            .tracking(1.0)
                    }
                    .padding(.horizontal, 24)

                    HStack(spacing: 8) {
                        ForEach([1, 2, 3, 5, 0], id: \.self) { minutes in
                            let isSelected = selectedTimerMinutes == minutes
                            Button {
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                                selectedTimerMinutes = minutes
                            } label: {
                                Text(minutes == 0 ? "Continuous" : "\(minutes) min")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(isSelected ? .white : StamerleeTheme.textSecondaryDark)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 36)
                                    .background(
                                        isSelected
                                            ? StamerleeTheme.primaryBlue.opacity(0.4)
                                            : Color.white.opacity(0.06),
                                        in: Capsule()
                                    )
                                    .overlay(
                                        Capsule().stroke(
                                            isSelected ? StamerleeTheme.primaryBlue : Color.white.opacity(0.08),
                                            lineWidth: 1
                                        )
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 22)

                // Primary Start Button
                VStack {
                    PrimaryActionButton(title: "▶ Start Metronome") {
                        state.beatBuddyDurationMinutes = selectedTimerMinutes
                        state.navigate(to: .beatBuddyPractice)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            selectedTimerMinutes = state.beatBuddyDurationMinutes
        }
    }

    private func adjustBPM(by delta: Int) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
            state.beatBuddyBPM = min(max(state.beatBuddyBPM + delta, 60), 180)
        }
    }

    private func toggleButton(title: String, icon: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .foregroundColor(isOn ? .white : StamerleeTheme.textSecondaryDark)
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(isOn ? StamerleeTheme.primaryBlue.opacity(0.38) : Color.white.opacity(0.06), in: Capsule())
            .overlay(
                Capsule().stroke(
                    isOn ? StamerleeTheme.primaryBlue : Color.white.opacity(0.08),
                    lineWidth: 1
                )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 4. Practice Session Screen
public struct BeatBuddyPracticeView: View {
    @Bindable public var state: AppState
    @State private var index = 0
    @State private var isCameraEnabled = false
    @State private var beatPulse = false
    @State private var remainingSeconds: Int = 120
    @State private var metronomeTimer: Timer? = nil
    @State private var countdownTimer: Timer? = nil

    public init(state: AppState) {
        self.state = state
    }

    private var words: [String] {
        Array(state.beatBuddySelectedWords.isEmpty ? Set(["Water", "Coffee"]) : state.beatBuddySelectedWords)
    }

    private var isContinuous: Bool {
        state.beatBuddyDurationMinutes == 0
    }

    private var formattedTime: String {
        let mins = remainingSeconds / 60
        let secs = remainingSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    public var body: some View {
        BeatBuddyShell(state: state, onBack: {
            stopTimers()
            state.navigate(to: .beatBuddyBPM, forward: false)
        }) {
            VStack(spacing: 0) {
                // Top Info Bar (Timer, DAF, Camera)
                HStack(spacing: 10) {
                    // Practice Timer Display
                    if !isContinuous {
                        HStack(spacing: 5) {
                            Image(systemName: "timer")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(remainingSeconds <= 30 ? .red : .cyan)
                            Text(formattedTime)
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.white.opacity(0.08), in: Capsule())
                    }

                    Spacer()

                    // BPM Badge
                    HStack(spacing: 4) {
                        Image(systemName: "metronome.fill")
                            .font(.system(size: 11))
                            .scaleEffect(beatPulse ? 1.25 : 0.95)
                            .foregroundColor(.cyan)
                        Text("\(state.beatBuddyBPM) BPM")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.white.opacity(0.08), in: Capsule())

                    // Camera Toggle
                    Button {
                        isCameraEnabled.toggle()
                    } label: {
                        Label(
                            "Camera",
                            systemImage: isCameraEnabled ? "video.fill" : "video.slash.fill"
                        )
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            isCameraEnabled
                                ? StamerleeTheme.primaryBlue.opacity(0.45)
                                : Color.white.opacity(0.08),
                            in: Capsule()
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isCameraEnabled ? "Turn camera off" : "Turn camera on")
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)

                Spacer()

                // Center Word Practice Card with Rhythm Pulse Glow
                VStack(spacing: 16) {
                    Text(words[min(index, words.count - 1)])
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(StamerleeTheme.textSecondaryDark)

                    Text(splitWord(words[min(index, words.count - 1)]))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .scaleEffect(beatPulse ? 1.05 : 1.0)
                        .animation(.spring(response: 0.18, dampingFraction: 0.6), value: beatPulse)

                    // Page Indicator Dots
                    HStack(spacing: 6) {
                        ForEach(0..<words.count, id: \.self) { i in
                            Circle()
                                .fill(i == index ? Color.cyan : Color.white.opacity(0.2))
                                .frame(width: i == index ? 7 : 5, height: i == index ? 7 : 5)
                        }
                    }
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
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
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            beatPulse ? Color.cyan.opacity(0.7) : Color.white.opacity(0.12),
                            lineWidth: beatPulse ? 2 : 1
                        )
                )
                .shadow(
                    color: beatPulse ? Color.cyan.opacity(0.35) : Color.black.opacity(0.2),
                    radius: beatPulse ? 20 : 10,
                    x: 0,
                    y: 6
                )
                .padding(.horizontal, 24)

                Spacer()

                // Optional Front Camera Preview
                if isCameraEnabled {
                    BeatBuddyCameraPreview()
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                }

                // Bottom Action Button
                VStack {
                    PrimaryActionButton(title: index + 1 < words.count ? "Next Word" : "Finish Practice") {
                        if index + 1 < words.count {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                index += 1
                            }
                        } else {
                            stopTimers()
                            state.navigate(to: .homeDashboard, forward: false)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .animation(.easeInOut(duration: 0.25), value: isCameraEnabled)
        }
        .onAppear {
            remainingSeconds = max(state.beatBuddyDurationMinutes, 1) * 60
            startMetronome()
        }
        .onDisappear {
            stopTimers()
        }
    }

    private func startMetronome() {
        stopTimers()
        let interval = 60.0 / max(Double(state.beatBuddyBPM), 40.0)

        // Rhythmic Metronome Beat
        metronomeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            let impact = UIImpactFeedbackGenerator(style: .rigid)
            impact.impactOccurred()
            AudioServicesPlaySystemSound(1057)

            withAnimation(.spring(response: 0.15, dampingFraction: 0.6)) {
                beatPulse = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                beatPulse = false
            }
        }

        // Countdown Timer
        if !isContinuous {
            countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                } else {
                    stopTimers()
                    state.navigate(to: .homeDashboard, forward: false)
                }
            }
        }
    }

    private func stopTimers() {
        metronomeTimer?.invalidate()
        metronomeTimer = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
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

// MARK: - Camera Preview Subview
private struct BeatBuddyCameraPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> BeatBuddyCameraView {
        BeatBuddyCameraView()
    }

    func updateUIView(_ uiView: BeatBuddyCameraView, context: Context) {}

    static func dismantleUIView(_ uiView: BeatBuddyCameraView, coordinator: ()) {
        uiView.stopSession()
    }
}

private final class BeatBuddyCameraView: UIView {
    private let session = AVCaptureSession()

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    private var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        previewLayer.videoGravity = .resizeAspectFill
        requestCameraAccessAndStart()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func requestCameraAccessAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                DispatchQueue.main.async {
                    self?.startSession()
                }
            }
        default:
            break
        }
    }

    private func startSession() {
        guard !session.isRunning,
              let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input) else {
            return
        }

        session.beginConfiguration()
        session.addInput(input)
        session.commitConfiguration()
        previewLayer.session = session
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    func stopSession() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
    }
}
