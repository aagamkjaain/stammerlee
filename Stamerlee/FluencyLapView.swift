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
        VStack(spacing: 12) {
            ZStack {
                // Soft radial background glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 56 / 255, green: 180 / 255, blue: 255 / 255).opacity(0.38),
                                Color(red: 130 / 255, green: 85 / 255, blue: 248 / 255).opacity(0.20),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 6,
                            endRadius: 52
                        )
                    )
                    .frame(width: 104, height: 104)
                    .blur(radius: 10)

                // Custom Glowing Stopwatch matching the visual design
                ZStack {
                    // Top Stem & Plunger
                    VStack(spacing: 0) {
                        Capsule()
                            .fill(Color(red: 90 / 255, green: 218 / 255, blue: 255 / 255))
                            .frame(width: 24, height: 6)

                        Rectangle()
                            .fill(Color(red: 65 / 255, green: 185 / 255, blue: 255 / 255))
                            .frame(width: 6.5, height: 5.5)

                        Spacer()
                    }
                    .frame(height: 78)

                    // Top-Right Angled Lap Button
                    Capsule()
                        .fill(Color(red: 140 / 255, green: 115 / 255, blue: 250 / 255))
                        .frame(width: 10, height: 5.5)
                        .rotationEffect(.degrees(-45))
                        .offset(x: 24, y: -24)

                    // Main Glowing Dial Ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 88 / 255, green: 218 / 255, blue: 255 / 255),
                                    Color(red: 52 / 255, green: 145 / 255, blue: 255 / 255),
                                    Color(red: 105 / 255, green: 90 / 255, blue: 250 / 255),
                                    Color(red: 145 / 255, green: 75 / 255, blue: 248 / 255)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 8.5
                        )
                        .frame(width: 60, height: 60)
                        .shadow(color: Color(red: 56 / 255, green: 170 / 255, blue: 255 / 255).opacity(0.55), radius: 10, x: 0, y: 2)

                    // Clock Hand pointing to ~1:30 (45 degrees)
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color.white)
                        .frame(width: 4, height: 16)
                        .offset(y: -6)
                        .rotationEffect(.degrees(45))

                    // Center Pivot Dot
                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                        .shadow(color: Color.black.opacity(0.25), radius: 2)
                }
                .frame(width: 84, height: 84)
            }

            // Clean 60 seconds label matching visual hierarchy
            VStack(spacing: 2) {
                Text("60")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.white,
                                Color(red: 232 / 255, green: 242 / 255, blue: 255 / 255)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Text("seconds")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(red: 168 / 255, green: 184 / 255, blue: 232 / 255))
            }
        }
        .frame(maxWidth: .infinity)
    }
}
