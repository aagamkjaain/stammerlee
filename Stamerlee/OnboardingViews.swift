import SwiftUI

// =============================================================================
// MARK: - ONBOARDING VIEWS (Consolidated)
// Contains: LoginView, OnboardingStepOneView,
//           OnboardingStepTwoView, DailyGoalView, ExploreActivitiesView
// (LaunchView lives in LaunchView.swift)
// =============================================================================

// MARK: - 2. Login Screen
public struct LoginView: View {
    @Bindable public var state: AppState

    /// When shown as an overlay over the onboarding screen, blur the content behind
    /// with a glass material. When shown standalone (e.g. after logging out), use a
    /// solid dark background instead.
    public var blurBackground: Bool = true

    @State private var emailInput: String = ""
    @State private var passwordInput: String = ""
    @State private var activeSheet: ActiveSheet? = nil
    @State private var sheetAppeared: Bool = false

    private enum ActiveSheet: Identifiable {
        case emailSignIn, terms, privacy
        var id: Int { hashValue }
    }

    public init(state: AppState, blurBackground: Bool = true) {
        self.state = state
        self.blurBackground = blurBackground
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            if blurBackground {
                // Glass blur over the onboarding screen behind, plus a dark tint
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .background(StamerleeTheme.backgroundDark.opacity(0.35))
                    .ignoresSafeArea()
            } else {
                StamerleeTheme.backgroundDark.ignoresSafeArea()
            }

            // "Get started" tab/sheet — slides up from below
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Get started")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textPrimaryLight)

                    Text("Start your fluency journey.")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textSecondaryLight)
                }
                .padding(.top, 4)

                VStack(spacing: 12) {
                    SocialAuthRow(type: .apple) { handleAuth(provider: "Apple") }
                    SocialAuthRow(type: .google) { handleAuth(provider: "Google") }

                    HStack(spacing: 12) {
                        Rectangle().fill(StamerleeTheme.dividerLight).frame(height: 1)
                        Text("OR")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(StamerleeTheme.textSecondaryLight.opacity(0.8))
                        Rectangle().fill(StamerleeTheme.dividerLight).frame(height: 1)
                    }
                    .padding(.vertical, 2)

                    SocialAuthRow(type: .email) { activeSheet = .emailSignIn }
                }

                VStack(spacing: 4) {
                    Text("By continuing, you agree to our")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(StamerleeTheme.textSecondaryLight)

                    HStack(spacing: 4) {
                        Button("Terms of Service") { activeSheet = .terms }
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(StamerleeTheme.primaryBlue)
                            .underline()

                        Text("and")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(StamerleeTheme.textSecondaryLight)

                        Button("Privacy Policy") { activeSheet = .privacy }
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(StamerleeTheme.primaryBlue)
                            .underline()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 6)
                .padding(.bottom, 12)
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)
            .background(
                StamerleeTheme.sheetBackground
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 32,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 32,
                            style: .continuous
                        )
                    )
                    .ignoresSafeArea(edges: .bottom)
            )
            .offset(y: sheetAppeared ? 0 : 520)
            .animation(.spring(response: 0.65, dampingFraction: 0.82), value: sheetAppeared)
        }
        .onAppear {
            sheetAppeared = false
            withAnimation(.spring(response: 0.65, dampingFraction: 0.82).delay(0.06)) {
                sheetAppeared = true
            }
        }
        .sheet(item: $activeSheet) { sheet in
            sheetView(for: sheet)
        }
    }

    private func handleAuth(provider: String) {
        state.signIn(method: provider)
        state.isSigningIn = false
        activeSheet = nil
        state.navigate(to: .nameInput, forward: true)
    }

    @ViewBuilder
    private func sheetView(for sheet: ActiveSheet) -> some View {
        NavigationStack {
            Group {
                switch sheet {
                case .emailSignIn:
                    emailForm
                case .terms:
                    legalSheet(title: "Terms of Service", text: "Stamerlee provides personalized fluency exercises.")
                case .privacy:
                    legalSheet(title: "Privacy Policy", text: "Your voice data is processed privately and securely.")
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { activeSheet = nil }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var emailForm: some View {
        VStack(spacing: 16) {
            Text("Sign in with Email")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding(.top, 16)

            TextField("Email address", text: $emailInput)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(Color(red: 242 / 255, green: 244 / 255, blue: 250 / 255))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            SecureField("Password", text: $passwordInput)
                .textContentType(.password)
                .padding()
                .background(Color(red: 242 / 255, green: 244 / 255, blue: 250 / 255))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            PrimaryActionButton(title: "Continue") {
                state.signIn(method: "Email", email: emailInput.isEmpty ? "user@stamerlee.com" : emailInput)
                passwordInput = ""
                activeSheet = nil
                state.isSigningIn = false
                state.navigate(to: .nameInput, forward: true)
            }
            .padding(.top, 8)
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private func legalSheet(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title).font(.system(size: 22, weight: .bold, design: .rounded))
            Text(text).font(.system(size: 15)).foregroundStyle(StamerleeTheme.textSecondaryLight)
            Spacer()
        }
        .padding(24)
    }
}

// MARK: - 3. Onboarding Info 1
public struct OnboardingStepOneView: View {
    @Bindable public var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // Dark Background (Full bleed)
                StamerleeTheme.backgroundDark
                    .ignoresSafeArea()

                // Foreground Content strictly constrained to screen width
                VStack(spacing: 0) {
                    // Top Navigation Bar
                    HStack {
                        BackNavButton {
                            state.navigate(to: .welcome, forward: false)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                    // Headings & Explanatory Copy
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Small steps,")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            Text("stronger speech")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 195 / 255, green: 175 / 255, blue: 255 / 255))
                        }

                        Text("Stuttering can be tough, but you’re not alone. Practice at your own pace, build confidence, and celebrate every step forward with your personal speech coach.")
                            .font(.system(size: 14.5, weight: .regular, design: .rounded))
                            .foregroundStyle(Color(red: 218 / 255, green: 222 / 255, blue: 245 / 255).opacity(0.88))
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 14)

                    Spacer(minLength: 8)

                    // Centered Hero Illustration (Girl with headphones - nicely sized)
                    OnboardingStepOneIllustration()
                        .padding(.vertical, 6)

                    Spacer(minLength: 8)

                    // Signature Purple Action Button (Pinned over the rolling hills)
                    PrimaryActionButton(title: "Next", compact: false) {
                        state.navigate(to: .onboarding2, forward: true)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .frame(width: geo.size.width)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - 4. Onboarding Info 2
public struct OnboardingStepTwoView: View {
    @Bindable public var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // Dark Background (Full bleed)
                StamerleeTheme.backgroundDark
                    .ignoresSafeArea()

                // Foreground Content strictly constrained to screen width
                VStack(spacing: 0) {
                    // Top Navigation Bar
                    HStack {
                        BackNavButton {
                            state.navigate(to: .onboarding1, forward: false)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                    // Headings & Explanatory Copy
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Support on your")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            Text("schedule")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 195 / 255, green: 175 / 255, blue: 255 / 255))
                        }

                        Text("Simple activities to practice fluency and become more comfortable speaking whenever and wherever it fits your day.")
                            .font(.system(size: 14.5, weight: .regular, design: .rounded))
                            .foregroundStyle(Color(red: 218 / 255, green: 222 / 255, blue: 245 / 255).opacity(0.88))
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 14)

                    Spacer(minLength: 8)

                    // Centered Hero Illustration (Coach video call card)
                    OnboardingStepTwoIllustration()
                        .padding(.vertical, 6)

                    Spacer(minLength: 8)

                    // Signature Purple Action Button — pops the glass sign-in up over this screen
                    PrimaryActionButton(title: "Next", compact: false) {
                        state.isSigningIn = true
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .frame(width: geo.size.width)
            }
            .frame(width: geo.size.width, height: geo.size.height)

            // Glass sign-in sheet overlaying Onboarding 2
            if state.isSigningIn {
                LoginView(state: state, blurBackground: true)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(20)
            }
        }
        .animation(.spring(response: 0.65, dampingFraction: 0.82), value: state.isSigningIn)
    }
}

// MARK: - 4b. Sign-in name capture (asked after the sign-in sheet)
public struct OnboardingNameView: View {
    @Bindable public var state: AppState

    @State private var nameInput: String = ""
    @State private var showWelcome: Bool = false
    @State private var welcomeRevealed: Bool = false
    @State private var welcomeText: String = ""
    @State private var hasCommitted: Bool = false
    @FocusState private var nameFieldFocused: Bool

    public init(state: AppState) {
        self.state = state
    }

    /// The trimmed, usable value of what's typed so far.
    private var trimmedName: String {
        nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var body: some View {
        ZStack {
            StamerleeTheme.backgroundDark.ignoresSafeArea()

            if showWelcome {
                // Animated welcome interstitial
                ZStack {
                    BackgroundImagesDecorationView()
                        .opacity(0.7)

                    HStack(spacing: 12) {
                        Text("Welcome \(welcomeText)")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 32)
                    .opacity(welcomeRevealed ? 1 : 0)
                    .scaleEffect(welcomeRevealed ? 1.0 : 0.6)
                    .offset(y: welcomeRevealed ? 0 : 20)
                }
                .transition(.opacity)
                .animation(.spring(response: 0.7, dampingFraction: 0.85), value: welcomeRevealed)
            } else {
                VStack(spacing: 0) {
                    Text("What should we\ncall you?")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 96)


                    // Underline input (no white box)
                    TextField("Your name", text: $nameInput)
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .tint(StamerleeTheme.primaryBlue)
                        .keyboardType(.default)
                        .autocapitalization(.words)
                        .submitLabel(.continue)
                        .focused($nameFieldFocused)
                        .onSubmit { commitName() }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 28)
                        .padding(.top, 40)
                        .padding(.bottom, 10)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(trimmedName.isEmpty ? Color.white.opacity(0.35) : StamerleeTheme.accentPurple)
                                .frame(height: trimmedName.isEmpty ? 1.5 : 3)
                                .animation(.easeInOut(duration: 0.25), value: trimmedName.isEmpty)
                        }
                        .padding(.horizontal, 24)

                    Spacer()

                    PrimaryActionButton(
                        title: "Continue",
                        isEnabled: !trimmedName.isEmpty
                    ) {
                        commitName()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                }
            }
        }
        .onAppear {
            nameInput = state.userName
            // Open the keyboard and place the cursor in the field immediately.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                nameFieldFocused = true
            }
        }
    }

    /// Saves the entered name to the profile, then shows the animated
    /// "Welcome {name}" card before moving on to the explore screen.
    private func commitName() {
        guard !hasCommitted else { return }

        let trimmed = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        // Nothing entered yet — keep them on this screen and refocus the field.
        guard !trimmed.isEmpty else {
            nameInput = ""
            return
        }

        hasCommitted = true
        state.userName = trimmed
        state.profileName = trimmed      // used later in the profile
        welcomeText = trimmed

        withAnimation {
            showWelcome = true
        }
        // Reveal the text once the welcome card is mounted, so it pops in.
        DispatchQueue.main.async {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.85)) {
                welcomeRevealed = true
            }
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.4))
            guard !Task.isCancelled else { return }
            state.navigate(to: .exploreActivities, forward: true)
        }
    }
}

// MARK: - 5. Daily Goal View
public struct DailyGoalView: View {
    @Bindable public var state: AppState

    private let goalOptions = [5, 10, 15, 20]

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ZStack {
            StamerleeTheme.backgroundDark.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    BackNavButton {
                        state.navigate(to: .onboarding2, forward: false)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Text("Set Your Goals")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textPrimaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 28)

                VStack(alignment: .leading, spacing: 0) {
                    

                    VStack(spacing: 0) {
                        ForEach(goalOptions, id: \.self) { minutes in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    state.dailyPracticeMinutes = minutes
                                }
                            } label: {
                                HStack {
                                    Text("\(minutes) min/day")
                                        .font(.system(
                                            size: 15,
                                            weight: state.dailyPracticeMinutes == minutes ? .semibold : .regular,
                                            design: .rounded
                                        ))
                                        .foregroundStyle(StamerleeTheme.textPrimaryLight)

                                    Spacer()

                                    ZStack {
                                        if state.dailyPracticeMinutes == minutes {
                                            Circle()
                                                .fill(StamerleeTheme.primaryBlue)
                                                .frame(width: 22, height: 22)

                                            Image(systemName: "checkmark")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundStyle(.white)
                                        } else {
                                            Circle()
                                                .stroke(
                                                    Color(red: 210 / 255, green: 215 / 255, blue: 228 / 255),
                                                    lineWidth: 1.8
                                                )
                                                .frame(width: 22, height: 22)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .frame(minHeight: 64)
                                .background(
                                    state.dailyPracticeMinutes == minutes
                                        ? StamerleeTheme.primaryBlue.opacity(0.08)
                                        : Color.clear
                                )
                            }

                            if minutes != goalOptions.last {
                                Divider()
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                }
                .background(StamerleeTheme.cardLight)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: Color.black.opacity(0.18), radius: 16, x: 0, y: 8)
                .padding(.horizontal, 20)

                Spacer()

                PrimaryActionButton(
                    title: "Next",
                    compact: true
                ) {
                    state.navigate(to: .exploreActivities, forward: true)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .sensoryFeedback(.selection, trigger: state.dailyPracticeMinutes)
    }
}

// MARK: - 6. Explore Activities View
public struct ExploreActivitiesView: View {
    @Bindable public var state: AppState

    @State private var cardsVisible = false

    public init(state: AppState) {
        self.state = state
    }

    private struct ActivityCardItem: Identifiable {
        let id: String
        let iconName: String
        let text: String
    }

    private let activities: [ActivityCardItem] = [
        ActivityCardItem(
            id: "prolonged",
            iconName: "IconProlongedSpeech",
            text: "Learn smooth pacing with prolonged speech and continuous airflow exercises"
        ),
        ActivityCardItem(
            id: "picture",
            iconName: "IconPictureDesc",
            text: "Build spontaneous fluency with picture description"
        ),
        ActivityCardItem(
            id: "dial",
            iconName: "IconDialScene",
            text: "Simulate phone calls using dial scene to build conversational confidence"
        ),
        ActivityCardItem(
            id: "mirror",
            iconName: "IconMirrorNarration",
            text: "Monitor your physical tension during narration with mirror exercises"
        )
    ]

    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // Dark Background (Full bleed)
                StamerleeTheme.backgroundDark
                    .ignoresSafeArea()

                // Foreground Content strictly constrained to screen width
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        BackNavButton {
                            state.navigate(to: .nameInput, forward: false)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                    Text("Explore activities\ndesigned for your\nstutter")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineSpacing(3)
                        .padding(.horizontal, 24)
                        .padding(.top, 14)
                        .padding(.bottom, 16)

                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(Array(activities.enumerated()), id: \.element.id) { index, item in
                                activityCard(item)
                                    .opacity(cardsVisible ? 1 : 0)
                                    .offset(y: cardsVisible ? 0 : 20)
                                    .animation(
                                        .spring(response: 0.5, dampingFraction: 0.85)
                                            .delay(0.08 + Double(index) * 0.06),
                                        value: cardsVisible
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    }
                    .scrollIndicators(.hidden)

                    Spacer(minLength: 4)

                    PrimaryActionButton(title: "Begin", compact: false) {
                        state.navigate(to: .homeDashboard, forward: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .frame(width: geo.size.width)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onAppear { cardsVisible = true }
    }

    private func activityCard(_ item: ActivityCardItem) -> some View {
        HStack(spacing: 16) {
            Image(item.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)

            Text(item.text)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(StamerleeTheme.textPrimaryLight)
                .lineSpacing(3)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 4)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(minHeight: 92)
        .background(Color(red: 238 / 255, green: 240 / 255, blue: 250 / 255))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}
