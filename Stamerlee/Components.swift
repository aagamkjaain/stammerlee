import SwiftUI

// MARK: - Primary Action Button
/// Vibrant blue pill button used for "Begin" and "Continue" actions across screens.
public struct PrimaryActionButton: View {
    public let title: String
    public let icon: String?
    public let isEnabled: Bool
    public let isLoading: Bool
    public let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    public init(
        title: String,
        icon: String? = nil,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            guard isEnabled && !isLoading else { return }
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .bold))
                    }
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                Group {
                    if isEnabled {
                        StamerleeTheme.primaryBlue
                    } else {
                        StamerleeTheme.primaryBlue.opacity(0.4)
                    }
                }
            )
            .clipShape(Capsule())
            .shadow(color: isEnabled ? StamerleeTheme.primaryBlue.opacity(0.3) : .clear, radius: 10, x: 0, y: 5)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
        }
        .disabled(!isEnabled || isLoading)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
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
    
    @State private var isPressed: Bool = false
    
    public init(type: SocialAuthType, action: @escaping () -> Void) {
        self.type = type
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 14) {
                // Leading Icon
                iconView
                    .frame(width: 24, height: 24)
                
                // Title
                Text(type.title)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(StamerleeTheme.textPrimaryLight)
                
                Spacer()
                
                // Trailing Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.gray.opacity(0.6))
            }
            .padding(.horizontal, 18)
            .frame(height: 65)
            .background(StamerleeTheme.cardLight)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: isPressed)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    @ViewBuilder
    private var iconView: some View {
        switch type {
        case .apple:
            Image(systemName: "applelogo")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)
        case .google:
            Image("googlesvg")
                .resizable()
                .frame(width: 20, height: 20)
    
            
        case .email:
            Image(systemName: "envelope")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(StamerleeTheme.primaryBlue)
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
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.14))
                    .frame(width: 38, height: 38)
                
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .accessibilityLabel("Go Back")
    }
}

// MARK: - Option Selection Row (Radio / Checkmark)
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
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            onSelect()
        }) {
            HStack(spacing: 12) {
                // Title and optional example subtitle
                VStack(alignment: .leading, spacing: 3) {
                    if let subtitle = option.subtitle {
                        HStack(spacing: 4) {
                            Text(option.title)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(StamerleeTheme.textPrimaryLight)
                            
                            Text("(\(subtitle))")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(StamerleeTheme.textSecondaryLight)
                        }
                    } else {
                        Text(option.title)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(StamerleeTheme.textPrimaryLight)
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
                            .foregroundColor(.white)
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
        .buttonStyle(.plain)
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
            let impact = UIImpactFeedbackGenerator(style: isLocked ? .light : .medium)
            impact.impactOccurred()
            action()
        } label: {
            ZStack {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.textPrimaryLight)

                HStack {
                    badge
                    Spacer()
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "chevron.right")
                        .font(.system(size: isCompleted ? 18 : 14, weight: .semibold))
                        .foregroundColor(
                            isCompleted ? StamerleeTheme.primaryBlue : .gray.opacity(0.5)
                        )
                        .frame(width: 30, alignment: .trailing)
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 72)
            .background(Color(red: 238 / 255, green: 240 / 255, blue: 250 / 255))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var badge: some View {
        if isLocked {
            Image(systemName: "lock.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
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
    public let heroFallbackPath: String
    public let systemIconFallback: String
    public let continueButtonTitle: String
    public let onBack: () -> Void
    public let onContinue: () -> Void

    @State private var breatheEffect: Bool = false

    public init(
        title: String,
        subtitle: String,
        heroImageName: String,
        heroFallbackPath: String,
        systemIconFallback: String = "waveform.and.mic",
        continueButtonTitle: String = "Continue",
        onBack: @escaping () -> Void,
        onContinue: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.heroImageName = heroImageName
        self.heroFallbackPath = heroFallbackPath
        self.systemIconFallback = systemIconFallback
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
                        .foregroundColor(StamerleeTheme.textPrimaryDark)
                        .lineSpacing(2)

                    Text(subtitle)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(StamerleeTheme.textSecondaryDark)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 22)

                // Hero Illustration
                ZStack {
                    if let uiImage = StamerleeImageLoader.loadHeroImage(
                        name: heroImageName,
                        fallbackPath: heroFallbackPath
                    ) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 360)
                            .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 10)
                            .scaleEffect(breatheEffect ? 1.015 : 0.985)
                            .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: breatheEffect)
                    } else {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(red: 25 / 255, green: 30 / 255, blue: 65 / 255))
                            .frame(width: 250, height: 230)
                            .overlay(
                                Image(systemName: systemIconFallback)
                                    .font(.system(size: 60))
                                    .foregroundColor(StamerleeTheme.primaryBlue)
                            )
                    }
                }
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
    public let wordsList: [String]
    @Binding public var selectedWords: Set<String>
    public let onDone: () -> Void

    @State private var showAllWordsSheet: Bool = false

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
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
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
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Top Title Bar
                Text("Analysis")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.textPrimaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                // Big Affirmation & Score Display
                VStack(spacing: 8) {
                    // Big Confidence Affirmation
                    Text(computedAffirmation)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 4)

                    Text("YOU SCORED")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textSecondaryDark)
                        .tracking(1.4)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(scoreText)
                            .font(.system(size: 54, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        if !maxScoreText.isEmpty {
                            Text(maxScoreText)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(StamerleeTheme.textSecondaryDark)
                        }
                    }
                }
                .frame(maxWidth: .infinity)

                // Spacer pushing the words section down
                Spacer(minLength: 24)

                // Instructions Subtitle
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(StamerleeTheme.textSecondaryDark)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 16)

                // Action Row: Counter + Single "Select all / Deselect all" Toggle Button
                HStack {
                    Text("\(selectedWords.count) selected")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textSecondaryDark)

                    Spacer()

                    Button(isAllSelected ? "Deselect all" : "Select all") {
                        toggleSelectAll()
                    }
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.primaryBlue)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 14)

                // 2-Column Word Grid (Capsule style like Beat Buddy, preview top 6)
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(Array(wordsList.prefix(6)), id: \.self) { word in
                        let isSelected = selectedWords.contains(word)
                        analysisWordButton(word: word, isSelected: isSelected) {
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
                        .foregroundColor(StamerleeTheme.primaryBlue)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 14)
                }

                Spacer(minLength: 24)

                // Bottom CTA Button ("Done")
                VStack {
                    PrimaryActionButton(title: "Done", action: onDone)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $showAllWordsSheet) {
            wordsSheetView
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(StamerleeTheme.backgroundDark)
                .ignoresSafeArea()
        }
    }

    private var wordsSheetView: some View {
        NavigationStack {
            ZStack {
                StamerleeTheme.backgroundDark
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("\(selectedWords.count) of \(wordsList.count) selected")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(StamerleeTheme.textSecondaryDark)

                            Spacer()

                            Button(isAllSelected ? "Deselect all" : "Select all") {
                                toggleSelectAll()
                            }
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(StamerleeTheme.primaryBlue)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 12)

                        LazyVGrid(
                            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                            spacing: 12
                        ) {
                            ForEach(wordsList, id: \.self) { word in
                                let isSelected = selectedWords.contains(word)
                                analysisWordButton(word: word, isSelected: isSelected) {
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
                    .foregroundColor(StamerleeTheme.primaryBlue)
                }
            }
        }
        .ignoresSafeArea()
    }

    private func toggleWordSelection(_ word: String) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
            if selectedWords.contains(word) {
                selectedWords.remove(word)
            } else {
                selectedWords.insert(word)
            }
        }
    }

    private func analysisWordButton(word: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(word)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? .white : StamerleeTheme.textPrimaryDark)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(StamerleeTheme.primaryBlue)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(
                Capsule().fill(
                    isSelected
                        ? StamerleeTheme.primaryBlue.opacity(0.38)
                        : Color.white.opacity(0.06)
                )
            )
            .overlay(
                Capsule().stroke(
                    isSelected
                        ? StamerleeTheme.primaryBlue
                        : Color.white.opacity(0.12),
                    lineWidth: isSelected ? 1.5 : 1
                )
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
