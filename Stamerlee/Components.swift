import SwiftUI

// MARK: - Haptic Button Style
/// Native button style that plays a haptic when the button is pressed and optionally
/// scales the label while pressed. Uses `configuration.isPressed` and `.sensoryFeedback`
/// instead of UIKit feedback generators or custom drag gestures.
public struct HapticButtonStyle: ButtonStyle {
    public var weight: SensoryFeedback.Weight
    public var pressedScale: CGFloat

    public init(weight: SensoryFeedback.Weight = .light, pressedScale: CGFloat = 1) {
        self.weight = weight
        self.pressedScale = pressedScale
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
            .sensoryFeedback(trigger: configuration.isPressed) { _, isPressed in
                isPressed ? .impact(weight: weight) : nil
            }
    }
}

public extension ButtonStyle where Self == HapticButtonStyle {
    /// Light haptic on press, no scaling (drop-in replacement for `.plain`).
    static var haptic: HapticButtonStyle { HapticButtonStyle() }

    static func haptic(weight: SensoryFeedback.Weight = .light, pressedScale: CGFloat = 1) -> HapticButtonStyle {
        HapticButtonStyle(weight: weight, pressedScale: pressedScale)
    }
}

// MARK: - Primary Action Button
/// Vibrant blue pill button used for "Begin" and "Continue" actions across screens.
public struct PrimaryActionButton: View {
    public let title: String
    public let icon: String?
    public let isEnabled: Bool
    public let isLoading: Bool
    public let compact: Bool
    public let action: () -> Void

    public init(
        title: String,
        icon: String? = nil,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        compact: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.compact = compact
        self.action = action
    }

    public var body: some View {
        if #available(iOS 26.0, *) {
            Button(action: action) { label }
                .buttonStyle(.glass(.regular.tint(StamerleeTheme.primaryBlue).interactive()))
                .buttonBorderShape(.capsule)
                .frame(maxWidth: .infinity)
                .disabled(!isEnabled || isLoading)
        } else {
            Button(action: action) { label }
                .buttonStyle(.haptic(weight: .medium, pressedScale: 0.97))
                .disabled(!isEnabled || isLoading)
        }
    }

    private var label: some View {
        HStack(spacing: compact ? 6 : 8) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(compact ? 0.8 : 0.9)
            } else {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: compact ? 13 : 16, weight: .bold))
                }
                Text(title)
                    .font(.system(size: compact ? 15 : 16, weight: .semibold, design: .rounded))
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, minHeight: compact ? 44 : 52)
        .background {
            if #available(iOS 26.0, *) {
                // glass style owns the background
                Color.clear
            } else {
                Group {
                    if isEnabled {
                        StamerleeTheme.primaryBlue
                    } else {
                        StamerleeTheme.primaryBlue.opacity(0.4)
                    }
                }
                .clipShape(Capsule())
                .shadow(color: isEnabled ? StamerleeTheme.primaryBlue.opacity(0.3) : .clear, radius: 10, x: 0, y: 5)
            }
        }
    }
}

// MARK: - Social Auth Button Style
public enum SocialAuthType {
    case apple
    case google
    case email
    
    var title: String {
        switch self {
        case .apple: return "Continue with Apple"
        case .google: return "Continue with Google"
        case .email: return "Continue with Email"
        }
    }
}

// MARK: - Social Auth Button
public struct SocialAuthRow: View {
    public let type: SocialAuthType
    public let action: () -> Void

    public init(type: SocialAuthType, action: @escaping () -> Void) {
        self.type = type
        self.action = action
    }

    public var body: some View {
        if #available(iOS 26.0, *) {
            Button(action: action) { rowContent }
                .buttonStyle(.glass(.regular.tint(StamerleeTheme.cardLight).interactive()))
                .buttonBorderShape(.roundedRectangle(radius: 14))
                .frame(maxWidth: .infinity)
        } else {
            Button(action: action) { rowContent }
                .buttonStyle(.haptic(pressedScale: 0.98))
        }
    }

    private var rowContent: some View {
        HStack(spacing: 14) {
            // Leading Icon
            iconView
                .frame(width: 24, height: 24)

            // Title
            Text(type.title)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(StamerleeTheme.textPrimaryLight)

            Spacer()

            // Trailing Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.gray.opacity(0.6))
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, minHeight: 65, alignment: .leading)
        .background {
            if #available(iOS 26.0, *) {
                Color.clear
            } else {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(StamerleeTheme.cardLight)
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
            }
        }
    }
    
    @ViewBuilder
    private var iconView: some View {
        switch type {
        case .apple:
            Image(systemName: "applelogo")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.black)
        case .google:
            Image("googlesvg")
                .resizable()
                .frame(width: 20, height: 20)
    
            
        case .email:
            Image(systemName: "envelope")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(StamerleeTheme.primaryBlue)
        }
    }
}

// MARK: - Back Navigation Button
public struct BackNavButton: View {
    public let action: () -> Void
    
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.14))
                    .frame(width: 38, height: 38)
                
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.haptic)
        .accessibilityLabel("Go Back")
    }
}

// MARK: - Universal Difficulty Card
public struct DifficultyCard: View {
    public let title: String
    public let isLocked: Bool
    public let isCompleted: Bool
    public let action: () -> Void

    public init(
        title: String,
        isLocked: Bool,
        isCompleted: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLocked = isLocked
        self.isCompleted = isCompleted
        self.action = action
    }

    public var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textPrimaryLight)

                HStack {
                    badge
                    Spacer()
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(StamerleeTheme.primaryBlue)
                            .frame(width: 30, alignment: .trailing)
                    } else if !isLocked {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.gray.opacity(0.5))
                            .frame(width: 30, alignment: .trailing)
                    }
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 72)
            .background(Color(red: 238 / 255, green: 240 / 255, blue: 250 / 255))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.haptic)
    }

    @ViewBuilder
    private var badge: some View {
        if isLocked {
            Image(systemName: "lock.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(Color(red: 90 / 255, green: 105 / 255, blue: 180 / 255))
                .clipShape(Circle())
        } else {
            Color.clear
                .frame(width: 38, height: 38)
        }
    }
}

// MARK: - Exercise Intro Skeleton View
/// Standardized intro template for all exercises (Prolonged Speech, Dial Scene, Picture Description, Narration).
public struct ExerciseIntroSkeletonView: View {
    public let title: String
    public let subtitle: String
    public let heroImageName: String
    public let continueButtonTitle: String
    public let onBack: () -> Void
    public let onContinue: () -> Void

    @State private var breatheEffect: Bool = false

    public init(
        title: String,
        subtitle: String,
        heroImageName: String,
        continueButtonTitle: String = "Continue",
        onBack: @escaping () -> Void,
        onContinue: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.heroImageName = heroImageName
        self.continueButtonTitle = continueButtonTitle
        self.onBack = onBack
        self.onContinue = onContinue
    }

    public var body: some View {
        ZStack {
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Top Navigation Bar
                HStack {
                    BackNavButton(action: onBack)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // Headings Section
                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textPrimaryDark)
                        .lineSpacing(2)

                    Text(subtitle)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textSecondaryDark)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 22)

                // Hero Illustration
                Image(heroImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 360)
                    .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 10)
                    .scaleEffect(breatheEffect ? 1.015 : 0.985)
                    .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: breatheEffect)
                    .accessibilityHidden(true)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)

                Spacer()

                // Bottom CTA Button ("Continue")
                VStack {
                    PrimaryActionButton(title: continueButtonTitle, action: onContinue)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            breatheEffect = true
        }
    }
}

// MARK: - Exercise Analysis Skeleton View
/// Standardized result/analysis screen matching the Prolonged Speech design for all exercises.
public struct ExerciseAnalysisSkeletonView: View {
    public let scoreText: String
    public let maxScoreText: String
    public let subtitle: String
    public let affirmation: String?
    public let previousScoreText: String
    public let highScoreText: String
    public let onDone: () -> Void

    public init(
        scoreText: String,
        maxScoreText: String = "/ 10",
        subtitle: String = "Here's a summary of this exercise.",
        affirmation: String? = nil,
        previousScoreText: String = "8.4",
        highScoreText: String = "9.6",
        onDone: @escaping () -> Void
    ) {
        self.scoreText = scoreText
        self.maxScoreText = maxScoreText
        self.subtitle = subtitle
        self.affirmation = affirmation
        self.previousScoreText = previousScoreText
        self.highScoreText = highScoreText
        self.onDone = onDone
    }

    private var computedAffirmation: String {
        if let custom = affirmation, !custom.isEmpty {
            return custom
        }
        let clean = scoreText.replacingOccurrences(of: "%", with: "").trimmingCharacters(in: .whitespaces)
        let value = Double(clean) ?? 8.0
        if value >= 8.5 {
            return "You did great today 🎉"
        } else if value >= 7.5 {
            return "Great progress today!"
        } else {
            return "You can improve, keep practicing!"
        }
    }

    public var body: some View {
        ZStack {
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .medium))
                    Text("Back")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                }
                .foregroundStyle(StamerleeTheme.textSecondaryDark)
                .padding(.horizontal, 24)
                .padding(.top, 18)

                Text("Analysis")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textPrimaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 14)

                VStack(alignment: .center, spacing: 10) {
                    Text(computedAffirmation)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Text("YOU SCORED")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textSecondaryDark)
                        .tracking(1.4)
                        .padding(.top, 2)

                    scoreRing
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
                .padding(.bottom, 20)

                Spacer(minLength: 12)

                HStack(spacing: 0) {
                    scoreSummary(title: "PREVIOUS SESSION", value: previousScoreText)
                    Divider()
                        .frame(height: 52)
                        .overlay(Color.white.opacity(0.18))
                    scoreSummary(title: "HIGH SCORE", value: highScoreText)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 88)
                .background(Color(red: 238 / 255, green: 236 / 255, blue: 255 / 255))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(.horizontal, 20)

                Spacer()

                VStack {
                    PrimaryActionButton(title: "Done", action: onDone)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }

    private var scoreRing: some View {
        let score = min(max(Double(scoreText.replacingOccurrences(of: "%", with: "")) ?? 0, 0), 10)
        let progress = CGFloat(score / 10)

        return ZStack {
            Circle()
                .stroke(Color.purple.opacity(0.14), lineWidth: 12)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [.purple, .pink.opacity(0.9), .purple],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(135))
                .shadow(color: .purple.opacity(0.18), radius: 7)

            VStack(spacing: 2) {
                Text(scoreText)
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(maxScoreText)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textSecondaryDark)
            }
        }
        .frame(width: 172, height: 172)
    }

    private func scoreSummary(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 6, weight: .bold, design: .rounded))
                .tracking(1.2)
                .foregroundStyle(Color.indigo.opacity(0.55))
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 18 / 255, green: 22 / 255, blue: 58 / 255))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Reusable Profile Avatar
public struct ProfileAvatar: View {
    public let style: Int
    public let imageData: Data?
    public var size: CGFloat

    public init(style: Int, imageData: Data?, size: CGFloat = 84) {
        self.style = style
        self.imageData = imageData
        self.size = size
    }

    public var body: some View {
        avatarArtwork
            .scaleEffect(size / 84.0)
            .frame(width: size, height: size)
            .contentShape(Circle())
    }

    private var avatarArtwork: some View {
        ZStack {
            if let imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Circle()
                    .fill(backgroundColor)
                    .padding(8)

                Circle()
                    .fill(foregroundColor)
                    .frame(width: 22, height: 22)
                    .offset(y: -13)

                Capsule()
                    .fill(foregroundColor)
                    .frame(width: 59, height: 33)
                    .offset(y: 25)
            }
        }
        .frame(width: 84, height: 84)
        .background(Color.black)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(StamerleeTheme.profileCard, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.18), radius: 4, x: 0, y: 2)
    }

    private var backgroundColor: Color {
        switch style {
        case 1: return StamerleeTheme.accentPurple
        case 2: return StamerleeTheme.primaryBlue
        default: return StamerleeTheme.profileAvatarDark
        }
    }

    private var foregroundColor: Color {
        style == 2 ? StamerleeTheme.profileCard : StamerleeTheme.backgroundDark
    }
}

// MARK: - Avatar Interactive Button Style
public struct AvatarInteractiveButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.90 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.68), value: configuration.isPressed)
    }
}

// MARK: - Bouncy Card Button Style
public struct BouncyCardButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.24, dampingFraction: 0.64), value: configuration.isPressed)
    }
}

// MARK: - Matched Geometry View Helper
extension View {
    @ViewBuilder
    public func matchedGeometryEffectIfPresent<ID: Hashable>(
        id: ID,
        in namespace: Namespace.ID?,
        properties: MatchedGeometryProperties = .frame,
        anchor: UnitPoint = .center,
        isSource: Bool = true
    ) -> some View {
        if let namespace {
            self.matchedGeometryEffect(id: id, in: namespace, properties: properties, anchor: anchor, isSource: isSource)
        } else {
            self
        }
    }
}
