import SwiftUI

public struct FluencyLapView: View {
    @Bindable public var state: AppState
    @Environment(\.headerNamespace) private var headerNamespace

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

                // Subtitle
                Text("Practice words from the sounds you tend to stutter on. Build speed, smoothness, and confidence under time pressure.")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(red: 221 / 255, green: 218 / 255, blue: 239 / 255))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
                    .padding(.top, 4)

                // Goal Card
                goalCard
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                Spacer(minLength: 8)

                // Stopwatch Display
                stopwatchHeroView

                Spacer(minLength: 16)

                // Primary Action Button pinned to bottom
                VStack {
                    PrimaryActionButton(
                        title: "Start 60s Challenge",
                        icon: "play.fill"
                    ) {
                        state.fluencyLapWordCount = 20
                        state.navigate(to: .fluencyLapPractice)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
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
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundStyle(StamerleeTheme.textPrimaryLight)

            Text("Speak as many words as you comfortably can in 60 seconds, focusing on smooth, continuous airflow and steady speech. Keep going at your own pace, stay relaxed, and aim to complete as many words as possible before the timer ends.")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(Color(red: 79 / 255, green: 76 / 255, blue: 101 / 255))
                .lineSpacing(3.5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 235 / 255, green: 232 / 255, blue: 255 / 255), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 3)
    }

    private var stopwatchHeroView: some View {
        VStack(spacing: 14) {
            // Large circular timer ring matching design
            ZStack {
                // Outer clean lilac ring
                Circle()
                    .stroke(
                        Color(red: 195 / 255, green: 175 / 255, blue: 255 / 255),
                        lineWidth: 4.5
                    )
                    .frame(width: 190, height: 190)
                    .shadow(color: Color(red: 195 / 255, green: 175 / 255, blue: 255 / 255).opacity(0.2), radius: 10)

                // Inside content: Stopwatch icon, 60, seconds
                VStack(spacing: 4) {
                    Image(systemName: "stopwatch")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color(red: 195 / 255, green: 175 / 255, blue: 255 / 255))
                        .padding(.bottom, 2)

                    Text("60")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("seconds")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 185 / 255, green: 180 / 255, blue: 215 / 255))
                }
            }

            // Subtitle below the timer ring
            Text("Ready when you are")
                .font(.system(size: 15.5, weight: .medium, design: .rounded))
                .foregroundStyle(Color(red: 170 / 255, green: 168 / 255, blue: 195 / 255))
        }
        .frame(maxWidth: .infinity)
    }
}
