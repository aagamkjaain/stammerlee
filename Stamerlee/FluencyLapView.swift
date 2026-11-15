import SwiftUI

public struct FluencyLapView: View {
    @Bindable public var state: AppState
    @Environment(\.headerNamespace) private var headerNamespace
    @State private var selectedDuration: LapDuration = .classic

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ZStack(alignment: .top) {
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Top Header Banner
                headerImageView

                // Header Bar with Back Button & Fluency Lap title on top of the image
                HStack(spacing: 12) {
                    BackNavButton {
                        state.navigate(to: .homeDashboard, forward: false)
                    }

                    Text("Fluency Lap")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: Color.black.opacity(0.45), radius: 6, x: 0, y: 2)

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, -48)
                .padding(.bottom, 6)

                // Scrollable Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Practice words from the sounds you tend to stutter on. Build speed, smoothness, and confidence under time pressure.")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundStyle(Color(red: 221 / 255, green: 218 / 255, blue: 239 / 255))
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 4)

                        goalCard
                            .padding(.top, 18)

                        Text("CHOOSE ROUND DURATION")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(StamerleeTheme.textSecondaryDark)
                            .tracking(0.6)
                            .padding(.top, 22)

                        HStack(spacing: 10) {
                            ForEach(LapDuration.allCases) { duration in
                                durationButton(duration)
                            }
                        }
                        .padding(.top, 12)

                        PrimaryActionButton(
                            title: "Start Today's Challenge",
                            icon: "play.fill",
                            compact: true
                        ) {
                            state.fluencyLapWordCount = selectedDuration.wordCount
                            state.navigate(to: .fluencyLapPractice)
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 24)
                }
                .scrollIndicators(.hidden)
            }
        }
        .preferredColorScheme(.dark)
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

    private var goalCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's Challenge Goal")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(StamerleeTheme.textPrimaryLight)

            Text("Speak words from your stuttered sounds with smooth, continuous airflow before time ends.")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(Color(red: 79 / 255, green: 76 / 255, blue: 101 / 255))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 235 / 255, green: 232 / 255, blue: 255 / 255), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func durationButton(_ duration: LapDuration) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDuration = duration
            }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: "stopwatch")
                    .font(.system(size: 18, weight: .medium))
                Text(duration.title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Text(duration.words)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.58))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .overlay(alignment: .topTrailing) {
                if selectedDuration == duration {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
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
                .buttonBorderShape(.roundedRectangle(radius: 16))
                .scaleEffect(configuration.isPressed ? 0.97 : 1)
        } else {
            configuration.label
                .background(isSelected ? StamerleeTheme.primaryPurple : StamerleeTheme.cardDark, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isSelected ? Color.white.opacity(0.7) : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
                }
                .scaleEffect(configuration.isPressed ? 0.97 : 1)
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
        }
    }
}
