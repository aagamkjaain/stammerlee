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

// MARK: - Option Selection Row (Radio / Checkmark)
public struct SoundOption: Hashable {
    public let title: String
    public let subtitle: String?

    public init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
}

public struct OptionSelectRow: View {
    public let option: SoundOption
    public let isSelected: Bool
    public let onSelect: () -> Void
    
    public init(option: SoundOption, isSelected: Bool, onSelect: @escaping () -> Void) {
        self.option = option
        self.isSelected = isSelected
        self.onSelect = onSelect
    }

    public var body: some View {
        Button(action: {
            onSelect()
        }) {
            HStack(spacing: 12) {
                // Title and optional example subtitle
                VStack(alignment: .leading, spacing: 3) {
                    if let subtitle = option.subtitle {
                        HStack(spacing: 4) {
                            Text(option.title)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(StamerleeTheme.textPrimaryLight)
                            
                            Text("(\(subtitle))")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundStyle(StamerleeTheme.textSecondaryLight)
                        }
                    } else {
                        Text(option.title)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(StamerleeTheme.textPrimaryLight)
                    }
                }
                
                Spacer()
                
                // Custom Radio / Checked Indicator
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(StamerleeTheme.primaryBlue)
                            .frame(width: 22, height: 22)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Circle()
                            .stroke(Color(red: 210 / 255, green: 215 / 255, blue: 228 / 255), lineWidth: 1.8)
                            .frame(width: 22, height: 22)
                    }
                }
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? StamerleeTheme.primaryBlue.opacity(0.06) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.haptic)
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
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.gray.opacity(0.7))
                            .frame(width: 30, alignment: .trailing)
                    } else {
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
        Color.clear
            .frame(width: 30, height: 30)
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

            BackgroundImagesDecorationView()

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
                        .foregroundStyle(.white)
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

// MARK: - Pulsing Microphone Button
public struct PulsingMicrophoneButton: View {
    @Binding public var isListening: Bool
    public let action: () -> Void

    @State private var pulse = false

    public init(isListening: Binding<Bool>, action: @escaping () -> Void) {
        self._isListening = isListening
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
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
        .onChange(of: isListening) { _, listening in
            pulse = listening
        }
    }
}

// MARK: - Speech Microphone Button
public struct SpeechMicrophoneButton: View {
    @Binding public var isListening: Bool
    public let action: () -> Void

    public init(isListening: Binding<Bool>, action: @escaping () -> Void) {
        self._isListening = isListening
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: isListening ? "waveform" : "mic.fill")
                    .font(.system(size: 18, weight: .bold))

                Text(isListening ? "Listening..." : "Tap to speak")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(StamerleeTheme.primaryBlue)
            .clipShape(Capsule())
        }
        .buttonStyle(.haptic(weight: .medium, pressedScale: 0.97))
        .padding(.horizontal, 24)
        .accessibilityLabel(isListening ? "Listening" : "Tap to speak")
    }
}

// MARK: - Glass Effect Close (X) Button
public struct GlassCloseButton: View {
    public let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.14))
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.45), Color.white.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 36, height: 36)
            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.haptic(weight: .light, pressedScale: 0.92))
        .accessibilityLabel("Close")
    }
}

// MARK: - Exercise Analysis Skeleton View
/// Standardized result/analysis screen matching the Prolonged Speech design for all exercises.
public struct ExerciseAnalysisSkeletonView: View {
    public let scoreText: String
    public let maxScoreText: String
    public let subtitle: String
    public let affirmation: String?
    public let wordsList: [String]
    @Binding public var selectedWords: Set<String>
    public let onDone: () -> Void

    @State private var showAllWordsSheet: Bool = false
    @State private var starAppeared: Bool = false

    public init(
        scoreText: String,
        maxScoreText: String = "/ 10",
        subtitle: String = "Tap words you want Beat Buddy to revisit",
        affirmation: String? = nil,
        wordsList: [String],
        selectedWords: Binding<Set<String>>,
        onDone: @escaping () -> Void
    ) {
        self.scoreText = scoreText
        self.maxScoreText = maxScoreText
        self.subtitle = subtitle
        self.affirmation = affirmation
        self.wordsList = wordsList
        self._selectedWords = selectedWords
        self.onDone = onDone
    }

    public init(
        scoreText: String,
        maxScoreText: String = "/ 10",
        subtitle: String = "Here's a summary of this exercise.",
        affirmation: String? = nil,
        onDone: @escaping () -> Void
    ) {
        self.init(
            scoreText: scoreText,
            maxScoreText: maxScoreText,
            subtitle: subtitle,
            affirmation: affirmation,
            wordsList: [],
            selectedWords: .constant([]),
            onDone: onDone
        )
    }

    private var computedAffirmation: String {
        if let custom = affirmation, !custom.isEmpty {
            return custom
        }
        let clean = scoreText.replacingOccurrences(of: "%", with: "").trimmingCharacters(in: .whitespaces)
        let value = Double(clean) ?? 8.0
        if value >= 8.5 {
            return "You did great today!!"
        } else if value >= 7.5 {
            return "Great progress today!"
        } else {
            return "You can improve, keep practicing!"
        }
    }

    private var isAllSelected: Bool {
        !wordsList.isEmpty && selectedWords.count >= wordsList.count
    }

    private func toggleSelectAll() {
        withAnimation(.easeInOut(duration: 0.2)) {
            if isAllSelected {
                selectedWords.removeAll()
            } else {
                selectedWords = Set(wordsList)
            }
        }
    }

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()

                // Centered Analysis Block: Stars, Blots, Affirmation, Score & Details
                VStack(spacing: 0) {
                    // One Main Yellow Star, Two Small Yellow Stars & Blots (No Glow)
                    starsAndBlotsView
                        .padding(.bottom, 22)

                    // Affirmation Title ("You did great today!!")
                    Text(computedAffirmation)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    // "YOU SCORED" label
                    Text("YOU SCORED")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 175 / 255, green: 170 / 255, blue: 215 / 255))
                        .tracking(1.5)
                        .padding(.top, 14)

                    // Score Display ("8.8 /10")
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(scoreText)
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        if !maxScoreText.isEmpty {
                            Text(maxScoreText.trimmingCharacters(in: .whitespaces))
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 200 / 255, green: 195 / 255, blue: 230 / 255))
                        }
                    }
                    .padding(.top, 6)

                    // Instructions / Subtitle ("Great job completing your prolonged speech session!")
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundStyle(Color(red: 165 / 255, green: 160 / 255, blue: 195 / 255))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.top, 16)
                    }

                    // Words list details (shifted into the middle with the details)
                    if !wordsList.isEmpty {
                        wordsSectionView
                            .padding(.top, 24)
                    }
                }
                .frame(maxWidth: .infinity)

                Spacer()

                // Bottom CTA Button ("Done")
                PrimaryActionButton(title: "Done", action: onDone)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
        }
        .sensoryFeedback(.selection, trigger: selectedWords)
        .sheet(isPresented: $showAllWordsSheet) {
            wordsSheetView
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(StamerleeTheme.backgroundDark)
                .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                starAppeared = true
            }
        }
    }

    // MARK: - One Main Yellow Star, Two Small Yellow Stars & Blots
    private var starsAndBlotsView: some View {
        let starYellow = Color(red: 255 / 255, green: 218 / 255, blue: 60 / 255)
        let blotYellow = Color(red: 255 / 255, green: 220 / 255, blue: 90 / 255)

        return ZStack {
            // Radiating Ray Blots from center star
            HStack(spacing: 24) {
                Capsule()
                    .fill(blotYellow)
                    .frame(width: 3.5, height: 14)
                    .rotationEffect(.degrees(-26))
                    .offset(y: -14)

                Capsule()
                    .fill(blotYellow)
                    .frame(width: 3.5, height: 14)
                    .rotationEffect(.degrees(26))
                    .offset(y: -14)
            }
            .scaleEffect(starAppeared ? 1.0 : 0.4)
            .opacity(starAppeared ? 1.0 : 0.0)

            // 1. One Main Yellow Center Star (without glowing effect, fully yellow)
            starAssetOrShape("Sparkle-2", size: 42, color: starYellow)
                .scaleEffect(starAppeared ? 1.0 : 0.75)
                .opacity(starAppeared ? 1.0 : 0.0)

            // 2. Left Small Yellow Star (without glowing effect)
            starAssetOrShape("Sparkle", size: 20, color: starYellow)
                .offset(x: -56, y: 12)
                .scaleEffect(starAppeared ? 1.0 : 0.5)
                .opacity(starAppeared ? 1.0 : 0.0)

            // 3. Right Small Yellow Star (without glowing effect)
            starAssetOrShape("Sparkle", size: 19, color: starYellow)
                .offset(x: 52, y: 14)
                .scaleEffect(starAppeared ? 1.0 : 0.5)
                .opacity(starAppeared ? 1.0 : 0.0)

            // Accent Decorative Blots / Motes
            Circle()
                .fill(blotYellow.opacity(0.85))
                .frame(width: 3.5, height: 3.5)
                .offset(x: -28, y: -6)
                .scaleEffect(starAppeared ? 1.0 : 0.2)
                .opacity(starAppeared ? 0.9 : 0.0)

            Circle()
                .fill(blotYellow.opacity(0.85))
                .frame(width: 3.5, height: 3.5)
                .offset(x: 28, y: -4)
                .scaleEffect(starAppeared ? 1.0 : 0.2)
                .opacity(starAppeared ? 0.9 : 0.0)

            Circle()
                .fill(blotYellow.opacity(0.75))
                .frame(width: 2.5, height: 2.5)
                .offset(x: 72, y: 5)
                .scaleEffect(starAppeared ? 1.0 : 0.2)
                .opacity(starAppeared ? 0.8 : 0.0)
        }
        .frame(height: 52)
    }

    // MARK: - Word Selection Section in Middle
    @ViewBuilder
    private var wordsSectionView: some View {
        VStack(spacing: 12) {
            // Action Row: Counter + Single "Select all / Deselect all" Toggle Button
            HStack {
                Text("\(selectedWords.count) selected")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textSecondaryDark)

                Spacer()

                Button(isAllSelected ? "Deselect all" : "Select all") {
                    toggleSelectAll()
                }
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(StamerleeTheme.primaryBlue)
            }
            .padding(.horizontal, 24)

            // 2-Column Word Grid
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(Array(wordsList.prefix(6)), id: \.self) { word in
                    let isSelected = selectedWords.contains(word)
                    wordButton(word: word, isSelected: isSelected) {
                        toggleWordSelection(word)
                    }
                }
            }
            .padding(.horizontal, 24)

            // Hyperlink-style "View more" button
            if wordsList.count > 6 {
                Button {
                    showAllWordsSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Text("View more")
                            .underline()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .font(.system(size: 13.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(StamerleeTheme.primaryBlue)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 4)
            }
        }
    }

    @ViewBuilder
    private func starAssetOrShape(_ name: String, size: CGFloat, color: Color = Color(red: 255 / 255, green: 218 / 255, blue: 60 / 255)) -> some View {
        Group {
            if let uiImage = UIImage(named: name) ?? UIImage(named: "pictures/\(name).png") ?? UIImage(contentsOfFile: Bundle.main.path(forResource: name, ofType: "png") ?? "") {
                Image(uiImage: uiImage)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(color)
            } else {
                FourPointSparkleStar()
                    .fill(color)
            }
        }
        .frame(width: size, height: size)
    }

    private var wordsSheetView: some View {
        NavigationStack {
            ZStack {
                StamerleeTheme.backgroundDark
                    .ignoresSafeArea()

                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("\(selectedWords.count) of \(wordsList.count) selected")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(StamerleeTheme.textSecondaryDark)

                            Spacer()

                            Button(isAllSelected ? "Deselect all" : "Select all") {
                                toggleSelectAll()
                            }
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(StamerleeTheme.primaryBlue)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 12)

                        LazyVGrid(
                            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                            spacing: 12
                        ) {
                            ForEach(wordsList, id: \.self) { word in
                                let isSelected = selectedWords.contains(word)
                                wordButton(word: word, isSelected: isSelected) {
                                    toggleWordSelection(word)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Practice Words")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(StamerleeTheme.backgroundDark, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showAllWordsSheet = false
                    }
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(StamerleeTheme.primaryBlue)
                }
            }
        }
        .ignoresSafeArea()
    }

    private func toggleWordSelection(_ word: String) {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
            if selectedWords.contains(word) {
                selectedWords.remove(word)
            } else {
                selectedWords.insert(word)
            }
        }
    }

    // MARK: - Word Selection Pill (Older clean capsule design)
    private func wordButton(word: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(word)
                .font(.system(size: 13.5, weight: isSelected ? .bold : .medium, design: .rounded))
                .foregroundStyle(isSelected ? .white : StamerleeTheme.textSecondaryDark)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    Group {
                        if isSelected {
                            Color(red: 20 / 255, green: 45 / 255, blue: 105 / 255)
                        } else {
                            Color(red: 16 / 255, green: 18 / 255, blue: 36 / 255)
                        }
                    }
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? StamerleeTheme.primaryBlue : Color.white.opacity(0.06),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.haptic)
    }
}

// MARK: - 4-Point Sparkle Star Shape
public struct FourPointSparkleStar: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX
        let cy = rect.midY
        let rx = rect.width / 2
        let ry = rect.height / 2
        let innerRx = rx * 0.18
        let innerRy = ry * 0.18

        path.move(to: CGPoint(x: cx, y: cy - ry))
        path.addQuadCurve(to: CGPoint(x: cx + rx, y: cy), control: CGPoint(x: cx + innerRx, y: cy - innerRy))
        path.addQuadCurve(to: CGPoint(x: cx, y: cy + ry), control: CGPoint(x: cx + innerRx, y: cy + innerRy))
        path.addQuadCurve(to: CGPoint(x: cx - rx, y: cy), control: CGPoint(x: cx - innerRx, y: cy + innerRy))
        path.addQuadCurve(to: CGPoint(x: cx, y: cy - ry), control: CGPoint(x: cx - innerRx, y: cy - innerRy))
        path.closeSubpath()
        return path
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

// MARK: - Top & Bottom Background Images Decoration
public struct BackgroundImagesDecorationView: View {
    public var opacity: Double = 1.0

    public init(opacity: Double = 1.0) {
        self.opacity = opacity
    }

    public var body: some View {
        ZStack {
            // Top Background Image
            VStack(spacing: 0) {
                topImageItem
                    .scaledToFit()
                    .frame(maxWidth: .infinity, alignment: .top)
                    .opacity(opacity)

                Spacer()
            }

            // Bottom Background Image
            VStack(spacing: 0) {
                Spacer()

                bottomImageItem
                    .scaledToFit()
                    .frame(maxWidth: .infinity, alignment: .bottom)
                    .opacity(opacity)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var topImageItem: some View {
        if let uiImage = UIImage(named: "topimage") ?? UIImage(named: "pictures/topimage.png") ?? UIImage(contentsOfFile: Bundle.main.path(forResource: "topimage", ofType: "png") ?? "") {
            Image(uiImage: uiImage)
                .resizable()
        } else {
            Image("topimage")
                .resizable()
        }
    }

    @ViewBuilder
    private var bottomImageItem: some View {
        if let uiImage = UIImage(named: "bottomimage") ?? UIImage(named: "pictures/bottomimage.png") ?? UIImage(contentsOfFile: Bundle.main.path(forResource: "bottomimage", ofType: "png") ?? "") {
            Image(uiImage: uiImage)
                .resizable()
        } else {
            Image("bottomimage")
                .resizable()
        }
    }
}
