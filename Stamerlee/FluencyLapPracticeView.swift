import SwiftUI

public struct FluencyLapPracticeView: View {
    @Bindable public var state: AppState
    @State private var currentWordIndex = 0
    @State private var isDAFEnabled = true
    @State private var isListening = false
    @State private var pulse = false
    @State private var advanceTask: Task<Void, Never>?

    private let words = [
        "Wattttter",
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
        "Progress"
    ]

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ZStack {
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                instruction
                    .padding(.top, 28)

                Spacer(minLength: 12)

                wordDisplay

                progress
                    .padding(.top, 22)

                Spacer(minLength: 16)

                microphoneControl

                Text("Tap and speak the word")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(red: 194 / 255, green: 192 / 255, blue: 218 / 255))
                    .padding(.top, 8)

                Button {
                    finishPractice()
                } label: {
                    HStack(spacing: 10) {
                        Text("Finish Practice")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                }
                .buttonStyle(FluencyFinishButtonStyle())
                .padding(.top, 22)
                .padding(.bottom, 12)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
        .preferredColorScheme(.dark)
        .onDisappear {
            advanceTask?.cancel()
        }
    }

    private var topBar: some View {
        HStack {
            BackNavButton {
                advanceTask?.cancel()
                state.navigate(to: .fluencyLap, forward: false)
            }

            Spacer()

            Button {
                isDAFEnabled.toggle()
            } label: {
                Label("DAF", systemImage: "headphones")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 17)
                    .frame(height: 40)
            }
            .buttonStyle(DAFButtonStyle(isEnabled: isDAFEnabled))
            .accessibilityLabel(isDAFEnabled ? "Disable DAF" : "Enable DAF")
        }
    }

    private var instruction: some View {
        Text("Stretch the sounds gently as you speak, keeping each word slow, smooth, and relaxed.")
            .font(.system(size: 15, weight: .regular, design: .rounded))
            .foregroundStyle(Color(red: 190 / 255, green: 188 / 255, blue: 214 / 255))
            .lineSpacing(5)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var wordDisplay: some View {
        let word = words[currentWordIndex % words.count]
        return (
            Text(String(word.prefix(1)))
                .foregroundStyle(StamerleeTheme.accentPurpleLight)
            + Text(String(word.dropFirst()))
                .foregroundStyle(.white)
        )
        .font(.system(size: 46, weight: .bold, design: .rounded))
        .minimumScaleFactor(0.7)
        .lineLimit(1)
        .frame(maxWidth: .infinity)
        .id(currentWordIndex)
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }

    private var progress: some View {
        VStack(spacing: 10) {
            Text("\(currentWordIndex + 1) of \(state.fluencyLapWordCount)")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(Color(red: 147 / 255, green: 145 / 255, blue: 175 / 255))

            HStack(spacing: 7) {
                ForEach(0..<min(state.fluencyLapWordCount, 8), id: \.self) { index in
                    Circle()
                        .fill(index == currentWordIndex % min(state.fluencyLapWordCount, 8) ? .white : Color(red: 80 / 255, green: 79 / 255, blue: 111 / 255))
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
                    .frame(width: 148, height: 148)
                    .scaleEffect(isListening && pulse ? 1.12 : 1)
                    .opacity(isListening ? (pulse ? 0.35 : 0.9) : 1)

                Circle()
                    .stroke(StamerleeTheme.primaryPurple.opacity(isListening ? 0.45 : 0.25), lineWidth: 12)
                    .frame(width: 126, height: 126)
                    .scaleEffect(isListening && pulse ? 1.08 : 1)
                    .opacity(isListening ? (pulse ? 0.55 : 1) : 1)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [StamerleeTheme.accentPurpleLight, StamerleeTheme.primaryPurpleDark],
                            center: .topLeading,
                            startRadius: 2,
                            endRadius: 75
                        )
                    )
                    .frame(width: 96, height: 96)
                    .shadow(color: StamerleeTheme.primaryPurple.opacity(isListening ? 0.95 : 0.7), radius: isListening ? 22 : 16)
                    .scaleEffect(isListening && pulse ? 1.05 : 1)

                Image(systemName: "mic.fill")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(.white)
                    .scaleEffect(isListening && pulse ? 1.08 : 1)
            }
            .frame(width: 168, height: 168)
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
        .accessibilityLabel(isListening ? "Listening" : "Speak word")
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
                if currentWordIndex + 1 < state.fluencyLapWordCount {
                    currentWordIndex += 1
                }
            }
        }
    }

    private func finishPractice() {
        advanceTask?.cancel()
        isListening = false
        pulse = false
        state.navigate(to: .homeDashboard, forward: false)
    }
}

private struct FluencyFinishButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(StamerleeTheme.primaryPurple, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

private struct DAFButtonStyle: ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 26.0, *) {
            configuration.label
                .buttonStyle(.glass(.regular.tint(isEnabled ? StamerleeTheme.primaryBlue : StamerleeTheme.cardDark).interactive()))
                .buttonBorderShape(.capsule)
        } else {
            configuration.label
                .background(isEnabled ? StamerleeTheme.primaryBlue : StamerleeTheme.cardDark, in: Capsule())
                .scaleEffect(configuration.isPressed ? 0.96 : 1)
        }
    }
}
