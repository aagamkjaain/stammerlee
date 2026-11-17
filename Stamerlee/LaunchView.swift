import SwiftUI

// MARK: - Launch Screen
/// Minimalist brand launch screen with centered "Stamerlee" typography.
public struct LaunchView: View {
    @Bindable public var state: AppState

    @State private var logoOpacity: Double = 0.0
    @State private var logoScale: CGFloat = 0.94

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ZStack {
            // Dark Background
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()

            // Centered Logo Wordmark
            VStack {
                Spacer()

                Text("Stamerlee")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textPrimaryDark)
                    .opacity(logoOpacity)
                    .scaleEffect(logoScale)
                    .shadow(color: Color.white.opacity(0.15), radius: 16, x: 0, y: 0)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) {
                logoOpacity = 1.0
                logoScale = 1.0
            }

            Task { @MainActor in
                try? await Task.sleep(for: .seconds(1.8))
                if state.currentScreen == .launch {
                    state.navigate(to: .welcome)
                }
            }
        }
    }
}

// MARK: - Welcome Screen
/// First onboarding screen, right after the launch logo. A calm Dial-Scene-style
/// scene (twinkling stars + drifting clouds) that auto-advances to Onboarding 1.
/// No close button, as requested.
public struct WelcomeView: View {
    @Bindable public var state: AppState

    @State private var cloudsIn: Bool = false
    @State private var cloudsOut: Bool = false
    @State private var textVisible: Bool = false
    @State private var hasAdvanced: Bool = false
    private var cloudPhase: Int { cloudsOut ? 2 : (cloudsIn ? 1 : 0) }

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Midnight Sky Background
                Color(red: 10 / 255, green: 13 / 255, blue: 31 / 255)
                    .ignoresSafeArea()

                // Twinkling Starfield & Motes (fade with the clouds)
                starsLayer(w: w, h: h)
                    .opacity(cloudsOut ? 0 : (cloudsIn ? 1 : 0))
                        .animation(.easeInOut(duration: 2.0), value: cloudsIn)    // was 0.8
                        .animation(.easeInOut(duration: 1.8), value: cloudsOut)   // was 0.8
                        .allowsHitTesting(false)
                // Drifting Clouds (staggered fade-in, then drift away & fade)
                cloudsLayer(w: w, h: h)
                    .allowsHitTesting(false)

                // Centered Heading (fades in after the clouds, fades out as they leave)
                VStack(spacing: 6) {
                    Text("Beyond the Pause")
                        .font(.system(size: 33, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Practice anywhere, at your own pace")
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .opacity(cloudsOut ? 0 : (textVisible ? 1 : 0))
                .scaleEffect(cloudsOut ? 1.05 : (textVisible ? 1.0 : 0.92))
                .offset(y: textVisible ? 0 : 14)
                .animation(.easeInOut(duration: 0.7), value: textVisible)
                .animation(.easeInOut(duration: 1.6), value: cloudsOut)
                .zIndex(20)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.3))
                cloudsIn = true

                // clouds need ~2.6s + stagger; show text once they're mostly in
                try? await Task.sleep(for: .seconds(2.4))
                textVisible = true

                try? await Task.sleep(for: .seconds(2.8))   // hold
                cloudsOut = true

                // wait for the slow fade-out to finish before navigating
                try? await Task.sleep(for: .seconds(2.6))
                guard !hasAdvanced, state.currentScreen == .welcome else { return }
                hasAdvanced = true
                state.navigate(to: .onboarding1, forward: true)
            }
        }
    }

    // MARK: - Cloud Specs
    /// Each cloud's entry offset (as a fraction of screen size) from outside the
    /// screen toward its final resting position.
    private let cloudSpecs: [(name: String, xf: Double, yf: Double, width: CGFloat, fraction: Bool, inXf: Double, inYf: Double)] = [
        ("Cloud-2", 0.06, 0.08, 140, false, -0.55, -0.40),
        ("Cloud", 0.94, 0.18, 140, false, 0.55, -0.40),
        ("Drifting cloud-3", 1.08, 0.26, 115, false, 0.60, -0.25),
        ("Cloud bank", 0.82, 0.86, 0.70, true, 0.45, 0.55),
        ("Cloud bank-2", 0.20, 0.88, 0.66, true, -0.45, 0.55)
    ]

    // MARK: - Animated Clouds Layer
    @ViewBuilder
    private func cloudsLayer(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            ForEach(Array(cloudSpecs.enumerated()), id: \.offset) { index, spec in
                let cloudWidth = spec.fraction ? w * spec.width : spec.width
                assetImage(spec.name)
                    .scaledToFit()
                    .frame(width: cloudWidth)
                    .position(x: w * spec.xf, y: h * spec.yf)
                    .opacity(cloudPhase == 1 ? 1 : 0)
                    .offset(
                        x: cloudPhase == 0 ? w * spec.inXf : 0,
                        y: cloudPhase == 0 ? h * spec.inYf : (cloudPhase == 2 ? -50 : 0)
                    )
                    // ONE animation covers opacity + offset. Slow in, slow out.
                    .animation(
                        cloudPhase == 2
                            ? .easeInOut(duration: 2.2).delay(Double(index) * 0.12)
                            : .easeInOut(duration: 2.6).delay(Double(index) * 0.15),
                        value: cloudPhase
                    )
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Natural Twinkling Stars & Motes Layer
    @ViewBuilder
    private func starsLayer(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            WelcomeTwinklingStarView(assetName: "Sparkle", size: 28, delay: 0.0, duration: 1.1)
                .position(x: w * 0.32, y: h * 0.07)

            WelcomeTwinklingStarView(assetName: "Floating mote", size: 10, delay: 0.2, duration: 0.95)
                .position(x: w * 0.18, y: h * 0.58)

            WelcomeTwinklingStarView(assetName: "Sparkle-2", size: 26, delay: 0.6, duration: 1.2)
                .position(x: w * 0.84, y: h * 0.62)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Asset Image Loader Helper
    @ViewBuilder
    private func assetImage(_ name: String) -> some View {
        if let uiImage = UIImage(named: name) ?? UIImage(contentsOfFile: Bundle.main.path(forResource: name, ofType: "png") ?? "") {
            Image(uiImage: uiImage)
                .resizable()
        } else {
            Image(name)
                .resizable()
        }
    }
}

// MARK: - Natural Star Twinkle Component (Welcome)
private struct WelcomeTwinklingStarView: View {
    let assetName: String
    let size: CGFloat
    let delay: Double
    let duration: Double

    @State private var isTwinkling = false

    var body: some View {
        Group {
            if let uiImage = UIImage(named: assetName) ?? UIImage(contentsOfFile: Bundle.main.path(forResource: assetName, ofType: "png") ?? "") {
                Image(uiImage: uiImage)
                    .resizable()
            } else {
                Image(assetName)
                    .resizable()
            }
        }
        .scaledToFit()
        .frame(width: size, height: size)
        .scaleEffect(isTwinkling ? 1.18 : 0.75)
        .opacity(isTwinkling ? 1.0 : 0.36)
        .shadow(
            color: Color(red: 255 / 255, green: 225 / 255, blue: 120 / 255).opacity(isTwinkling ? 0.85 : 0.12),
            radius: isTwinkling ? 7 : 1
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(
                    .easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                ) {
                    isTwinkling = true
                }
            }
        }
    }
}
