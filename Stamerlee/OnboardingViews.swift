import SwiftUI

// =============================================================================
// MARK: - ONBOARDING VIEWS (Consolidated)
// Contains: LaunchView, LoginView, OnboardingStepOneView,
//           OnboardingStepTwoView, DailyGoalView, ExploreActivitiesView
// =============================================================================

// MARK: - 1. Launch Screen
public struct LaunchView: View {
    @Bindable public var state: AppState

    @State private var logoOpacity: Double = 0.0
    @State private var logoScale: CGFloat = 0.94

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ZStack {
            StamerleeTheme.backgroundDark.ignoresSafeArea()

            VStack {
                Spacer()
                Text("Stamerlee")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.textPrimaryDark)
                    .opacity(logoOpacity)
                    .scaleEffect(logoScale)
                    .shadow(color: Color.white.opacity(0.15), radius: 16, x: 0, y: 0)
                Spacer()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            state.navigate(to: .login)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) {
                logoOpacity = 1.0
                logoScale = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                if state.currentScreen == .launch {
                    state.navigate(to: .login)
                }
            }
        }
    }
}

// MARK: - 2. Login Screen
public struct LoginView: View {
    @Bindable public var state: AppState

    @State private var emailInput: String = ""
    @State private var passwordInput: String = ""
    @State private var activeSheet: ActiveSheet? = nil

    private enum ActiveSheet: Identifiable {
        case emailSignIn, terms, privacy
        var id: Int { hashValue }
    }

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ZStack {
            StamerleeTheme.backgroundDark.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Branding
                VStack {
                    Spacer()
                    Text("Stamerlee")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryDark)
                        .padding(.bottom, 36)
                    Spacer()
                }
                .frame(maxHeight: .infinity)

                // Bottom Rounded Sheet
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Get started")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(StamerleeTheme.textPrimaryLight)

                        Text("Start your fluency journey.")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(StamerleeTheme.textSecondaryLight)
                    }
                    .padding(.top, 4)

                    VStack(spacing: 12) {
                        SocialAuthRow(type: .apple) { handleAuth(provider: "Apple") }
                        SocialAuthRow(type: .google) { handleAuth(provider: "Google") }

                        HStack(spacing: 12) {
                            Rectangle().fill(StamerleeTheme.dividerLight).frame(height: 1)
                            Text("OR")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(StamerleeTheme.textSecondaryLight.opacity(0.8))
                            Rectangle().fill(StamerleeTheme.dividerLight).frame(height: 1)
                        }
                        .padding(.vertical, 2)

                        SocialAuthRow(type: .email) { activeSheet = .emailSignIn }
                    }

                    // Terms & Privacy
                    VStack(spacing: 4) {
                        Text("By continuing, you agree to our")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(StamerleeTheme.textSecondaryLight)

                        HStack(spacing: 4) {
                            Button("Terms of Service") { activeSheet = .terms }
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(StamerleeTheme.primaryBlue)
                                .underline()

                            Text("and")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(StamerleeTheme.textSecondaryLight)

                            Button("Privacy Policy") { activeSheet = .privacy }
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(StamerleeTheme.primaryBlue)
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
                                topLeadingRadius: 36,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 36,
                                style: .continuous
                            )
                        )
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
        .sheet(item: $activeSheet) { sheet in
            sheetView(for: sheet)
        }
    }

    private func handleAuth(provider: String) {
        state.authMethod = provider
        state.isAuthenticated = true
        state.navigate(to: .onboarding1)
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
                .autocapitalization(.none)
                .padding()
                .background(Color(red: 242 / 255, green: 244 / 255, blue: 250 / 255))
                .cornerRadius(12)

            SecureField("Password", text: $passwordInput)
                .padding()
                .background(Color(red: 242 / 255, green: 244 / 255, blue: 250 / 255))
                .cornerRadius(12)

            PrimaryActionButton(title: "Continue") {
                state.userEmail = emailInput.isEmpty ? "user@stamerlee.com" : emailInput
                state.authMethod = "Email"
                state.isAuthenticated = true
                activeSheet = nil
                state.navigate(to: .onboarding1)
            }
            .padding(.top, 8)
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private func legalSheet(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title).font(.system(size: 22, weight: .bold, design: .rounded))
            Text(text).font(.system(size: 15)).foregroundColor(StamerleeTheme.textSecondaryLight)
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
        ZStack {
            StamerleeTheme.backgroundDark.ignoresSafeArea()

            VStack(spacing: 0) {
                PageIndicatorView(totalPages: 2, currentPage: 0)
                    .padding(.top, 12)

                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Small steps,")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(StamerleeTheme.textPrimaryDark)

                        Text("stronger speech")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [StamerleeTheme.accentPurpleLight, StamerleeTheme.accentPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }

                    Text("Practice at your own pace, build confidence, and celebrate every step forward.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(StamerleeTheme.textSecondaryDark)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28)
                .padding(.top, 24)

                Spacer()

                OnboardingStepOneIllustration()
                    .padding(.vertical, 10)

                Spacer()

                PrimaryActionButton(title: "Begin") {
                    state.navigate(to: .onboarding2)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 24)
            }
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
        ZStack {
            StamerleeTheme.backgroundDark.ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    PageIndicatorView(totalPages: 2, currentPage: 1)
                    HStack {
                        BackNavButton { state.navigate(to: .onboarding1, forward: false) }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 12)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Support on your\nschedule")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryDark)
                        .lineSpacing(2)

                    Text("Simple activities to practice fluency and become more comfortable speaking.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(StamerleeTheme.textSecondaryDark)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28)
                .padding(.top, 24)

                Spacer()

                OnboardingStepTwoIllustration()
                    .padding(.vertical, 8)

                Spacer()

                PrimaryActionButton(title: "Continue") {
                state.navigate(to: .dailyGoal)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 24)
            }
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
                    BackNavButton { state.navigate(to: .onboarding2, forward: false) }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Text("Set Your Goals")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.textPrimaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 34)

                VStack(alignment: .leading, spacing: 0) {
                    Text("Choose your daily goal")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryLight)
                        .padding(.horizontal, 20)
                        .padding(.top, 22)
                        .padding(.bottom, 14)

                    VStack(spacing: 0) {
                        ForEach(goalOptions, id: \.self) { minutes in
                            Button {
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                                state.dailyPracticeMinutes = minutes
                            } label: {
                                HStack {
                                    Text("\(minutes) min/day")
                                        .font(.system(
                                            size: 15,
                                            weight: state.dailyPracticeMinutes == minutes ? .semibold : .regular,
                                            design: .rounded
                                        ))
                                        .foregroundColor(StamerleeTheme.textPrimaryLight)

                                    Spacer()

                                    ZStack {
                                        if state.dailyPracticeMinutes == minutes {
                                            Circle()
                                                .fill(StamerleeTheme.primaryBlue)
                                                .frame(width: 22, height: 22)

                                            Image(systemName: "checkmark")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.white)
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
                                .frame(height: 64)
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
                    title: "Continue"
                ) {
                    state.navigate(to: .exploreActivities)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}

// MARK: - 6. Explore Activities View
public struct ExploreActivitiesView: View {
    @Bindable public var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    private struct ActivityCardItem: Identifiable {
        let id: String
        let iconName: String
        let fallbackFile: String
        let text: String
    }

    private let activities: [ActivityCardItem] = [
        ActivityCardItem(
            id: "prolonged",
            iconName: "IconProlongedSpeech",
            fallbackFile: "/Users/user89/Documents/bitch/Screenshot_2026-10-21_at_11.26.10_PM-removebg-preview 2.png",
            text: "Learn smooth pacing with prolonged speech and continuous airflow exercises"
        ),
        ActivityCardItem(
            id: "picture",
            iconName: "IconPictureDesc",
            fallbackFile: "/Users/user89/Documents/bitch/Screenshot_2026-10-21_at_11.46.28_PM-removebg-preview 2.png",
            text: "Build spontaneous fluency with picture description"
        ),
        ActivityCardItem(
            id: "dial",
            iconName: "IconDialScene",
            fallbackFile: "/Users/user89/Documents/bitch/Firefly_RemoveBackground 2.png",
            text: "Simulate phone calls using dial scene to build conversational confidence"
        ),
        ActivityCardItem(
            id: "mirror",
            iconName: "IconMirrorNarration",
            fallbackFile: "/Users/user89/Documents/bitch/Screenshot_2026-10-21_at_11.35.41_PM-removebg-preview 2.png",
            text: "Monitor your physical tension during narration with mirror exercises"
        )
    ]

    public var body: some View {
        ZStack {
            StamerleeTheme.backgroundDark.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    BackNavButton { state.navigate(to: .dailyGoal, forward: false) }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Text("Explore activities\ndesigned for your\nstutter")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.textPrimaryDark)
                    .lineSpacing(3)
                    .padding(.horizontal, 24)
                    .padding(.top, 22)
                    .padding(.bottom, 22)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(activities) { item in
                            activityCard(item)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }

                Spacer()

                PrimaryActionButton(title: "Continue") {
                    state.navigate(to: .homeDashboard)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }

    private func activityCard(_ item: ActivityCardItem) -> some View {
        HStack(spacing: 16) {
            Group {
                if let uiImage = StamerleeImageLoader.loadHeroImage(name: item.iconName, fallbackPath: item.fallbackFile) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                } else {
                    Circle()
                        .fill(StamerleeTheme.accentPurple.opacity(0.2))
                        .frame(width: 44, height: 44)
                        .overlay(Image(systemName: "sparkles").foregroundColor(StamerleeTheme.primaryBlue))
                }
            }
            .frame(width: 48, height: 48)

            Text(item.text)
                .font(.system(size: 13.5, weight: .semibold, design: .rounded))
                .foregroundColor(StamerleeTheme.textPrimaryLight)
                .lineSpacing(2.5)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(red: 238 / 255, green: 240 / 255, blue: 250 / 255))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}
