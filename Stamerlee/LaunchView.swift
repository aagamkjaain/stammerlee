import SwiftUI

// MARK: - 1. Launch Screen
/// Brand splash: deep navy background, centered Stamerlee wordmark with
/// soft pink sparkle rays, and the three organic curved blobs matching the design.
public struct LaunchView: View {
    @Bindable public var state: AppState

    @State private var logoOpacity: Double = 0.0
    @State private var logoScale: CGFloat = 0.96

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            ZStack {
                // Deep midnight navy background (#090B24)
                Color(red: 9 / 255, green: 11 / 255, blue: 36 / 255)
                    .ignoresSafeArea()

                // Decorative organic blobs
                LaunchBlobs(w: w, h: h)
                    .allowsHitTesting(false)

                // Wordmark & Sparkle Rays positioned at ~35% of screen height
                HStack(alignment: .top, spacing: 6) {
                    sparkleRays
                        .offset(y: 4)

                    Text("Stamerlee")
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .offset(x: -14) // balances the rays so "Stamerlee" is visually centered
                .position(x: w * 0.5, y: h * 0.35)
                .opacity(logoOpacity)
                .scaleEffect(logoScale)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            state.navigate(to: .login)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                logoOpacity = 1.0
                logoScale = 1.0
            }
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(2.0))
                if state.currentScreen == .launch {
                    state.navigate(to: .login)
                }
            }
        }
    }

    // MARK: - Sparkle Rays (3 angled pink accent strokes)
    private var sparkleRays: some View {
        ZStack(alignment: .bottomTrailing) {
            // Top ray: angled ~ -48° (pointing up-left)
            Capsule()
                .fill(Color(red: 235 / 255, green: 190 / 255, blue: 231 / 255))
                .frame(width: 3.5, height: 16)
                .rotationEffect(.degrees(-48))
                .offset(x: -6, y: -16)

            // Middle ray: angled ~ -18° (pointing left-up)
            Capsule()
                .fill(Color(red: 235 / 255, green: 190 / 255, blue: 231 / 255))
                .frame(width: 3.5, height: 18)
                .rotationEffect(.degrees(-18))
                .offset(x: -14, y: -4)

            // Bottom ray: angled ~ +4° (nearly horizontal)
            Capsule()
                .fill(Color(red: 235 / 255, green: 190 / 255, blue: 231 / 255))
                .frame(width: 3.5, height: 14)
                .rotationEffect(.degrees(4))
                .offset(x: -16, y: 8)
        }
        .frame(width: 28, height: 38)
    }
}

// MARK: - Decorative Blobs
/// The three organic shapes from the launch design:
/// 1. Large flowing lavender blob hugging bottom-left
/// 2. Soft purple horizontal pebble at mid-right
/// 3. Deep violet rounded dome at bottom-right
struct LaunchBlobs: View {
    let w: CGFloat
    let h: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 1. Large Lavender blob (#DEDDFD) — bottom-left
            LavenderFlowBlob()
                .fill(Color(red: 222 / 255, green: 221 / 255, blue: 253 / 255))
                .frame(width: w, height: h)

            // 2. Mid-right soft purple pebble (#7A7BD5)
            MidRightPebble()
                .fill(Color(red: 122 / 255, green: 123 / 255, blue: 213 / 255))
                .frame(width: w * 0.22, height: h * 0.072)
                .position(x: w * 0.86, y: h * 0.58)

            // 3. Bottom-right deep violet hill/dome (#5959BD)
            BottomRightDome()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 104 / 255, green: 100 / 255, blue: 204 / 255),
                            Color(red: 75 / 255, green: 72 / 255, blue: 175 / 255)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: w, height: h)
        }
        .ignoresSafeArea()
    }
}

// MARK: - 1. Flowing Lavender Blob Shape
struct LavenderFlowBlob: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height

        var path = Path()
        path.move(to: CGPoint(x: 0, y: h * 0.628))

        // Gentle slope down-right into the waist
        path.addCurve(
            to: CGPoint(x: w * 0.22, y: h * 0.69),
            control1: CGPoint(x: w * 0.08, y: h * 0.635),
            control2: CGPoint(x: w * 0.16, y: h * 0.655)
        )

        // Swell out into the top of the bulb
        path.addCurve(
            to: CGPoint(x: w * 0.55, y: h * 0.80),
            control1: CGPoint(x: w * 0.29, y: h * 0.73),
            control2: CGPoint(x: w * 0.46, y: h * 0.74)
        )

        // Smooth round crest of the bulb
        path.addCurve(
            to: CGPoint(x: w * 0.55, y: h * 0.89),
            control1: CGPoint(x: w * 0.60, y: h * 0.83),
            control2: CGPoint(x: w * 0.59, y: h * 0.86)
        )

        // Bottom curve sweeping down toward the bottom edge
        path.addCurve(
            to: CGPoint(x: w * 0.38, y: h),
            control1: CGPoint(x: w * 0.51, y: h * 0.93),
            control2: CGPoint(x: w * 0.46, y: h * 0.98)
        )

        path.addLine(to: CGPoint(x: 0, y: h))
        path.closeSubpath()
        return path
    }
}

// MARK: - 2. Mid-Right Pebble Shape
struct MidRightPebble: Shape {
    func path(in rect: CGRect) -> Path {
        let h = rect.height
        let radius = h * 0.48

        var path = Path()
        path.addRoundedRect(
            in: rect,
            cornerSize: CGSize(width: radius, height: radius),
            style: .continuous
        )
        return path
    }
}

// MARK: - 3. Bottom-Right Dome Shape
struct BottomRightDome: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height

        var path = Path()
        let leftX = w * 0.56
        let rightX = w * 0.96
        let peakX = w * 0.76
        let peakY = h * 0.87

        path.move(to: CGPoint(x: leftX, y: h))
        path.addCurve(
            to: CGPoint(x: peakX, y: peakY),
            control1: CGPoint(x: leftX + (peakX - leftX) * 0.15, y: h * 0.93),
            control2: CGPoint(x: peakX - (peakX - leftX) * 0.40, y: peakY)
        )
        path.addCurve(
            to: CGPoint(x: rightX, y: h),
            control1: CGPoint(x: peakX + (rightX - peakX) * 0.40, y: peakY),
            control2: CGPoint(x: rightX - (rightX - peakX) * 0.15, y: h * 0.93)
        )
        path.closeSubpath()
        return path
    }
}
