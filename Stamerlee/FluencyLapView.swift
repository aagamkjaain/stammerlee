import SwiftUI

public struct FluencyLapView: View {
    @Bindable public var state: AppState
    @State private var selectedDuration: LapDuration = .classic

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                StamerleeTheme.backgroundDark
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        BackNavButton {
                            state.navigate(to: .homeDashboard, forward: false)
                        }
                        .padding(.top, 28)

                        Text("Fluency Lap")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.top, 27)

                        Text("Practice words from the sounds you tend to stutter on. Build speed, smoothness, and confidence under time pressure.")
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .foregroundStyle(Color(red: 221 / 255, green: 218 / 255, blue: 239 / 255))
                            .lineSpacing(8)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 17)

                        goalCard
                            .padding(.top, 38)

                        Text("CHOOSE ROUND DURATION")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(StamerleeTheme.textSecondaryDark)
                            .tracking(0.6)
                            .padding(.top, 46)

                        HStack(spacing: 13) {
                            ForEach(LapDuration.allCases) { duration in
                                durationButton(duration)
                            }
                        }
                        .padding(.top, 20)

                        PrimaryActionButton(
                            title: "Start Today's Challenge",
                            icon: "play.fill"
                        ) {
                            state.fluencyLapWordCount = selectedDuration.wordCount
                            state.navigate(to: .fluencyLapPractice)
                        }
                        .padding(.top, 145)
                        .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 30)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private var goalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Challenge Goal")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(StamerleeTheme.textPrimaryLight)

            Text("Speak words from your stuttered sounds with smooth, continuous airflow before time ends.")
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundStyle(Color(red: 79 / 255, green: 76 / 255, blue: 101 / 255))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 27)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 235 / 255, green: 232 / 255, blue: 255 / 255), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private func durationButton(_ duration: LapDuration) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDuration = duration
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: "stopwatch")
                    .font(.system(size: 23, weight: .medium))
                Text(duration.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Text(duration.words)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.58))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 82)
            .overlay(alignment: .topTrailing) {
                if selectedDuration == duration {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 23))
                        .foregroundStyle(.white)
                        .padding(6)
                }
            }
        }
        .buttonStyle(FluencyLapDurationButtonStyle(isSelected: selectedDuration == duration))
        .accessibilityAddTraits(selectedDuration == duration ? .isSelected : [])
    }
}

private enum LapDuration: String, CaseIterable, Identifiable {
    case blitz
    case classic
    case master

    var id: String { rawValue }

    var title: String {
        switch self {
        case .blitz: return "30s Blitz"
        case .classic: return "45s Classic"
        case .master: return "60s Master"
        }
    }

    var words: String {
        switch self {
        case .blitz: return "7 words"
        case .classic: return "15 words"
        case .master: return "20 words"
        }
    }

    var wordCount: Int {
        switch self {
        case .blitz: return 7
        case .classic: return 15
        case .master: return 20
        }
    }
}

private struct FluencyLapDurationButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 26.0, *) {
            configuration.label
                .buttonStyle(.glass(.regular.tint(isSelected ? StamerleeTheme.primaryPurple : StamerleeTheme.cardDark).interactive()))
                .buttonBorderShape(.roundedRectangle(radius: 18))
                .scaleEffect(configuration.isPressed ? 0.97 : 1)
        } else {
            configuration.label
                    .background(isSelected ? StamerleeTheme.primaryPurple : StamerleeTheme.cardDark, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isSelected ? Color.white.opacity(0.7) : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
                }
                .scaleEffect(configuration.isPressed ? 0.97 : 1)
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
        }
    }
}
