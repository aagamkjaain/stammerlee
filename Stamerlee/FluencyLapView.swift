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
        VStack(spacing: 10) {
            ZStack {
                // Soft radial background glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 56 / 255, green: 170 / 255, blue: 255 / 255).opacity(0.32),
                                Color(red: 139 / 255, green: 92 / 255, blue: 246 / 255).opacity(0.16),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 4,
                            endRadius: 48
                        )
                    )
                    .frame(width: 96, height: 96)
                    .blur(radius: 8)

                // SF Symbol Stopwatch with Cyan-to-Purple Gradient
                Image(systemName: "stopwatch")
                    .font(.system(size: 60, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 88 / 255, green: 218 / 255, blue: 255 / 255),
                                Color(red: 58 / 255, green: 148 / 255, blue: 255 / 255),
                                Color(red: 105 / 255, green: 95 / 255, blue: 248 / 255),
                                Color(red: 140 / 255, green: 72 / 255, blue: 246 / 255)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color(red: 56 / 255, green: 170 / 255, blue: 255 / 255).opacity(0.4), radius: 12, x: 0, y: 3)
            }

            // Clean 60 seconds label
            VStack(spacing: 2) {
                Text("60")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.white,
                                Color(red: 232 / 255, green: 240 / 255, blue: 255 / 255)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Text("seconds")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 170 / 255, green: 186 / 255, blue: 235 / 255))
            }
        }
        .frame(maxWidth: .infinity)
    }
}
