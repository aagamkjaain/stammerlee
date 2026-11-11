# Stamerlee Onboarding App Screens

This document explains the onboarding flow beginning at launch and ending at the home dashboard. It covers [OnboardingViews.swift](./OnboardingViews.swift) and the supporting hero illustrations in [Illustrations.swift](./Illustrations.swift).

## Screen flow

```text
Launch
  -> Login
  -> OnboardingStepOneView
  -> OnboardingStepTwoView
  -> DailyGoalView
  -> ExploreActivitiesView
  -> HomeDashboard
```

| Screen | Purpose | Forward action | Back action |
|---|---|---|---|
| `LaunchView` | Shows the brand logo and starts the app. | Tap or 1.8-second timer -> login. | None. |
| `LoginView` | Offers Apple, Google, and email sign-in plus legal sheets. | Successful sign-in -> onboarding step 1. | None in the main screen. |
| `OnboardingStepOneView` | Introduces gradual speech practice. | Next -> onboarding step 2. | Back -> login. |
| `OnboardingStepTwoView` | Explains flexible support and activities. | Next -> daily goal. | Back -> onboarding step 1. |
| `DailyGoalView` | Selects 5, 10, 15, or 20 minutes per day. | Next -> explore activities. | Back -> onboarding step 2. |
| `ExploreActivitiesView` | Summarizes the available practice activities. | Begin -> home dashboard. | Back -> daily goal. |

## Compatibility and possible deprecations

No definite deprecated API can be confirmed from source inspection alone. These items should be checked against the project deployment target and Xcode SDK:

- `@Bindable` and `@Observable` require the Observation framework and modern OS/toolchain support; they are current APIs, not deprecated ones.
- `UnevenRoundedRectangle` and `presentationDetents` require newer SwiftUI availability than basic layout APIs; keep deployment checks if older iOS versions are supported.
- `Task.sleep(for:)` is modern structured concurrency. Its `try?` intentionally ignores cancellation in the launch delay; use explicit cancellation handling if the timer must be cancelled on disappearance.
- `textInputAutocapitalization(.never)` and `.autocorrectionDisabled()` are current SwiftUI modifiers.
- `.animation(..., value:)` is current. For new code, prefer explicit animation around state changes when possible, but this usage is not deprecated.

## Line-by-line explanation

### `Stamerlee/OnboardingViews.swift` (585 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports the framework used by this file. |
| 2 | `` | Blank line separating code sections. |
| 3 | `// =============================================================================` | Section marker organizing the onboarding implementation. |
| 4 | `// MARK: - ONBOARDING VIEWS (Consolidated)` | Section marker organizing the onboarding implementation. |
| 5 | `// Contains: LaunchView, LoginView, OnboardingStepOneView,` | Comment describing the purpose of the following UI block. |
| 6 | `//           OnboardingStepTwoView, DailyGoalView, ExploreActivitiesView` | Comment describing the purpose of the following UI block. |
| 7 | `// =============================================================================` | Section marker organizing the onboarding implementation. |
| 8 | `` | Blank line separating code sections. |
| 9 | `// MARK: - 1. Launch Screen` | Section marker organizing the onboarding implementation. |
| 10 | `public struct LaunchView: View {` | Declares a reusable SwiftUI view or private supporting model. |
| 11 | `    @Bindable public var state: AppState` | Allows this view to mutate the observable AppState through bindings. |
| 12 | `` | Blank line separating code sections. |
| 13 | `    @State private var logoOpacity: Double = 0.0` | Stores local UI state managed by SwiftUI. |
| 14 | `    @State private var logoScale: CGFloat = 0.94` | Stores local UI state managed by SwiftUI. |
| 15 | `` | Blank line separating code sections. |
| 16 | `    public init(state: AppState) {` | Initializes the view and receives shared app state or configuration. |
| 17 | `        self.state = state` | Implements the surrounding screen, model, or view-builder expression. |
| 18 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 19 | `` | Blank line separating code sections. |
| 20 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy for the screen. |
| 21 | `        ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 22 | `            StamerleeTheme.backgroundDark.ignoresSafeArea()` | Implements the surrounding screen, model, or view-builder expression. |
| 23 | `` | Blank line separating code sections. |
| 24 | `            VStack {` | Opens or closes a Swift scope or view-builder block. |
| 25 | `                Spacer()` | Implements the surrounding screen, model, or view-builder expression. |
| 26 | `                Text("Stamerlee")` | Displays a text label or explanatory copy. |
| 27 | `                    .font(.system(size: 44, weight: .bold, design: .rounded))` | Sets typography, weight, size, and design. |
| 28 | `                    .foregroundStyle(StamerleeTheme.textPrimaryDark)` | Sets the foreground color or gradient. |
| 29 | `                    .opacity(logoOpacity)` | Controls visibility during an animation. |
| 30 | `                    .scaleEffect(logoScale)` | Applies a SwiftUI modifier to the preceding view. |
| 31 | `                    .shadow(color: Color.white.opacity(0.15), radius: 16, x: 0, y: 0)` | Adds visual depth around the logo, illustration, or card. |
| 32 | `                Spacer()` | Implements the surrounding screen, model, or view-builder expression. |
| 33 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 34 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 35 | `        .contentShape(Rectangle())` | Applies a SwiftUI modifier to the preceding view. |
| 36 | `        .onTapGesture {` | Opens or closes a Swift scope or view-builder block. |
| 37 | `            state.navigate(to: .login)` | Moves the shared app state to the named screen and records navigation direction. |
| 38 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 39 | `        .onAppear {` | Runs setup or starts the entrance animation when the view appears. |
| 40 | `            withAnimation(.easeOut(duration: 2.5)) {` | Animates the enclosed state change. |
| 41 | `                logoOpacity = 1.0` | Implements the surrounding screen, model, or view-builder expression. |
| 42 | `                logoScale = 1.0` | Implements the surrounding screen, model, or view-builder expression. |
| 43 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 44 | `            Task { @MainActor in` | Starts asynchronous work without blocking the main UI. |
| 45 | `                try? await Task.sleep(for: .seconds(1.8))` | Waits asynchronously before continuing the launch flow. |
| 46 | `                if state.currentScreen == .launch {` | Conditionally renders or executes this branch. |
| 47 | `                    state.navigate(to: .login)` | Moves the shared app state to the named screen and records navigation direction. |
| 48 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 49 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 50 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 51 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 52 | `}` | Opens or closes a Swift scope or view-builder block. |
| 53 | `` | Blank line separating code sections. |
| 54 | `// MARK: - 2. Login Screen` | Section marker organizing the onboarding implementation. |
| 55 | `public struct LoginView: View {` | Declares a reusable SwiftUI view or private supporting model. |
| 56 | `    @Bindable public var state: AppState` | Allows this view to mutate the observable AppState through bindings. |
| 57 | `` | Blank line separating code sections. |
| 58 | `    @State private var emailInput: String = ""` | Stores local UI state managed by SwiftUI. |
| 59 | `    @State private var passwordInput: String = ""` | Stores local UI state managed by SwiftUI. |
| 60 | `    @State private var activeSheet: ActiveSheet? = nil` | Stores local UI state managed by SwiftUI. |
| 61 | `    @State private var sheetAppeared: Bool = false` | Stores local UI state managed by SwiftUI. |
| 62 | `` | Blank line separating code sections. |
| 63 | `    private enum ActiveSheet: Identifiable {` | Declares private sheet state used only by the login screen. |
| 64 | `        case emailSignIn, terms, privacy` | Defines or handles one enum case. |
| 65 | `        var id: Int { hashValue }` | Defines a computed property or mutable value. |
| 66 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 67 | `` | Blank line separating code sections. |
| 68 | `    public init(state: AppState) {` | Initializes the view and receives shared app state or configuration. |
| 69 | `        self.state = state` | Implements the surrounding screen, model, or view-builder expression. |
| 70 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 71 | `` | Blank line separating code sections. |
| 72 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy for the screen. |
| 73 | `        ZStack(alignment: .bottom) {` | Opens or closes a Swift scope or view-builder block. |
| 74 | `            StamerleeTheme.backgroundDark.ignoresSafeArea()` | Implements the surrounding screen, model, or view-builder expression. |
| 75 | `` | Blank line separating code sections. |
| 76 | `            // Logo — slides up from center in sync with the sheet rising from below` | Comment describing the purpose of the following UI block. |
| 77 | `            VStack {` | Opens or closes a Swift scope or view-builder block. |
| 78 | `                Spacer()` | Implements the surrounding screen, model, or view-builder expression. |
| 79 | `                Text("Stamerlee")` | Displays a text label or explanatory copy. |
| 80 | `                    .font(.system(size: 44, weight: .bold, design: .rounded))` | Sets typography, weight, size, and design. |
| 81 | `                    .foregroundStyle(StamerleeTheme.textPrimaryDark)` | Sets the foreground color or gradient. |
| 82 | `                    .shadow(color: Color.white.opacity(0.15), radius: 16, x: 0, y: 0)` | Adds visual depth around the logo, illustration, or card. |
| 83 | `                Spacer()` | Implements the surrounding screen, model, or view-builder expression. |
| 84 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 85 | `            .frame(maxWidth: .infinity, maxHeight: .infinity)` | Sets the view size or alignment constraints. |
| 86 | `            .offset(y: sheetAppeared ? -190 : 0)` | Moves the view for the entrance or floating animation. |
| 87 | `            .animation(.spring(response: 0.65, dampingFraction: 0.82), value: sheetAppeared)` | Associates an animation with changes to the supplied state value. |
| 88 | `` | Blank line separating code sections. |
| 89 | `            // "Get started" tab/sheet — slides up from below` | Comment describing the purpose of the following UI block. |
| 90 | `            VStack(alignment: .leading, spacing: 20) {` | Opens or closes a Swift scope or view-builder block. |
| 91 | `                VStack(alignment: .leading, spacing: 6) {` | Opens or closes a Swift scope or view-builder block. |
| 92 | `                    Text("Get started")` | Displays a text label or explanatory copy. |
| 93 | `                        .font(.system(size: 26, weight: .bold, design: .rounded))` | Sets typography, weight, size, and design. |
| 94 | `                        .foregroundStyle(StamerleeTheme.textPrimaryLight)` | Sets the foreground color or gradient. |
| 95 | `` | Blank line separating code sections. |
| 96 | `                    Text("Start your fluency journey.")` | Displays a text label or explanatory copy. |
| 97 | `                        .font(.system(size: 14, weight: .regular, design: .rounded))` | Sets typography, weight, size, and design. |
| 98 | `                        .foregroundStyle(StamerleeTheme.textSecondaryLight)` | Sets the foreground color or gradient. |
| 99 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 100 | `                .padding(.top, 4)` | Adds layout spacing around the view. |
| 101 | `` | Blank line separating code sections. |
| 102 | `                VStack(spacing: 12) {` | Opens or closes a Swift scope or view-builder block. |
| 103 | `                    SocialAuthRow(type: .apple) { handleAuth(provider: "Apple") }` | Implements the surrounding screen, model, or view-builder expression. |
| 104 | `                    SocialAuthRow(type: .google) { handleAuth(provider: "Google") }` | Implements the surrounding screen, model, or view-builder expression. |
| 105 | `` | Blank line separating code sections. |
| 106 | `                    HStack(spacing: 12) {` | Opens or closes a Swift scope or view-builder block. |
| 107 | `                        Rectangle().fill(StamerleeTheme.dividerLight).frame(height: 1)` | Implements the surrounding screen, model, or view-builder expression. |
| 108 | `                        Text("OR")` | Displays a text label or explanatory copy. |
| 109 | `                            .font(.system(size: 11, weight: .semibold))` | Sets typography, weight, size, and design. |
| 110 | `                            .foregroundStyle(StamerleeTheme.textSecondaryLight.opacity(0.8))` | Sets the foreground color or gradient. |
| 111 | `                        Rectangle().fill(StamerleeTheme.dividerLight).frame(height: 1)` | Implements the surrounding screen, model, or view-builder expression. |
| 112 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 113 | `                    .padding(.vertical, 2)` | Adds layout spacing around the view. |
| 114 | `` | Blank line separating code sections. |
| 115 | `                    SocialAuthRow(type: .email) { activeSheet = .emailSignIn }` | Implements the surrounding screen, model, or view-builder expression. |
| 116 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 117 | `` | Blank line separating code sections. |
| 118 | `                VStack(spacing: 4) {` | Opens or closes a Swift scope or view-builder block. |
| 119 | `                    Text("By continuing, you agree to our")` | Displays a text label or explanatory copy. |
| 120 | `                        .font(.system(size: 11, weight: .regular))` | Sets typography, weight, size, and design. |
| 121 | `                        .foregroundStyle(StamerleeTheme.textSecondaryLight)` | Sets the foreground color or gradient. |
| 122 | `` | Blank line separating code sections. |
| 123 | `                    HStack(spacing: 4) {` | Opens or closes a Swift scope or view-builder block. |
| 124 | `                        Button("Terms of Service") { activeSheet = .terms }` | Creates an interactive control that runs the supplied action. |
| 125 | `                            .font(.system(size: 11, weight: .semibold))` | Sets typography, weight, size, and design. |
| 126 | `                            .foregroundStyle(StamerleeTheme.primaryBlue)` | Sets the foreground color or gradient. |
| 127 | `                            .underline()` | Applies a SwiftUI modifier to the preceding view. |
| 128 | `` | Blank line separating code sections. |
| 129 | `                        Text("and")` | Displays a text label or explanatory copy. |
| 130 | `                            .font(.system(size: 11, weight: .regular))` | Sets typography, weight, size, and design. |
| 131 | `                            .foregroundStyle(StamerleeTheme.textSecondaryLight)` | Sets the foreground color or gradient. |
| 132 | `` | Blank line separating code sections. |
| 133 | `                        Button("Privacy Policy") { activeSheet = .privacy }` | Creates an interactive control that runs the supplied action. |
| 134 | `                            .font(.system(size: 11, weight: .semibold))` | Sets typography, weight, size, and design. |
| 135 | `                            .foregroundStyle(StamerleeTheme.primaryBlue)` | Sets the foreground color or gradient. |
| 136 | `                            .underline()` | Applies a SwiftUI modifier to the preceding view. |
| 137 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 138 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 139 | `                .frame(maxWidth: .infinity)` | Sets the view size or alignment constraints. |
| 140 | `                .padding(.top, 6)` | Adds layout spacing around the view. |
| 141 | `                .padding(.bottom, 12)` | Adds layout spacing around the view. |
| 142 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 143 | `            .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 144 | `            .padding(.top, 28)` | Adds layout spacing around the view. |
| 145 | `            .background(` | Adds the light card or sheet background behind the content. |
| 146 | `                StamerleeTheme.sheetBackground` | Implements the surrounding screen, model, or view-builder expression. |
| 147 | `                    .clipShape(` | Clips content to a rounded shape. |
| 148 | `                        UnevenRoundedRectangle(` | Implements the surrounding screen, model, or view-builder expression. |
| 149 | `                            topLeadingRadius: 32,` | Implements the surrounding screen, model, or view-builder expression. |
| 150 | `                            bottomLeadingRadius: 0,` | Implements the surrounding screen, model, or view-builder expression. |
| 151 | `                            bottomTrailingRadius: 0,` | Implements the surrounding screen, model, or view-builder expression. |
| 152 | `                            topTrailingRadius: 32,` | Implements the surrounding screen, model, or view-builder expression. |
| 153 | `                            style: .continuous` | Implements the surrounding screen, model, or view-builder expression. |
| 154 | `                        )` | Implements the surrounding screen, model, or view-builder expression. |
| 155 | `                    )` | Implements the surrounding screen, model, or view-builder expression. |
| 156 | `                    .ignoresSafeArea(edges: .bottom)` | Allows the background to extend under system safe areas. |
| 157 | `            )` | Implements the surrounding screen, model, or view-builder expression. |
| 158 | `            .offset(y: sheetAppeared ? 0 : 520)` | Moves the view for the entrance or floating animation. |
| 159 | `            .animation(.spring(response: 0.65, dampingFraction: 0.82), value: sheetAppeared)` | Associates an animation with changes to the supplied state value. |
| 160 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 161 | `        .onAppear {` | Runs setup or starts the entrance animation when the view appears. |
| 162 | `            sheetAppeared = false` | Implements the surrounding screen, model, or view-builder expression. |
| 163 | `            withAnimation(.spring(response: 0.65, dampingFraction: 0.82).delay(0.06)) {` | Animates the enclosed state change. |
| 164 | `                sheetAppeared = true` | Implements the surrounding screen, model, or view-builder expression. |
| 165 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 166 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 167 | `        .sheet(item: $activeSheet) { sheet in` | Presents modal content using the active sheet binding. |
| 168 | `            sheetView(for: sheet)` | Implements the surrounding screen, model, or view-builder expression. |
| 169 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 170 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 171 | `` | Blank line separating code sections. |
| 172 | `    private func handleAuth(provider: String) {` | Defines a private helper used to build or handle this screen. |
| 173 | `        state.signIn(method: provider)` | Records the selected authentication method in AppState. |
| 174 | `        state.navigate(to: .onboarding1, forward: true)` | Moves the shared app state to the named screen and records navigation direction. |
| 175 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 176 | `` | Blank line separating code sections. |
| 177 | `    @ViewBuilder` | Implements the surrounding screen, model, or view-builder expression. |
| 178 | `    private func sheetView(for sheet: ActiveSheet) -> some View {` | Defines a private helper used to build or handle this screen. |
| 179 | `        NavigationStack {` | Opens or closes a Swift scope or view-builder block. |
| 180 | `            Group {` | Opens or closes a Swift scope or view-builder block. |
| 181 | `                switch sheet {` | Selects content based on the current enum value. |
| 182 | `                case .emailSignIn:` | Defines or handles one enum case. |
| 183 | `                    emailForm` | Implements the surrounding screen, model, or view-builder expression. |
| 184 | `                case .terms:` | Defines or handles one enum case. |
| 185 | `                    legalSheet(title: "Terms of Service", text: "Stamerlee provides personalized fluency exercises.")` | Implements the surrounding screen, model, or view-builder expression. |
| 186 | `                case .privacy:` | Defines or handles one enum case. |
| 187 | `                    legalSheet(title: "Privacy Policy", text: "Your voice data is processed privately and securely.")` | Implements the surrounding screen, model, or view-builder expression. |
| 188 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 189 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 190 | `            .toolbar {` | Opens or closes a Swift scope or view-builder block. |
| 191 | `                ToolbarItem(placement: .cancellationAction) {` | Opens or closes a Swift scope or view-builder block. |
| 192 | `                    Button("Close") { activeSheet = nil }` | Creates an interactive control that runs the supplied action. |
| 193 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 194 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 195 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 196 | `        .presentationDetents([.medium])` | Limits the modal sheet to the specified height. |
| 197 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 198 | `` | Blank line separating code sections. |
| 199 | `    private var emailForm: some View {` | Defines a private computed view or value. |
| 200 | `        VStack(spacing: 16) {` | Opens or closes a Swift scope or view-builder block. |
| 201 | `            Text("Sign in with Email")` | Displays a text label or explanatory copy. |
| 202 | `                .font(.system(size: 20, weight: .bold, design: .rounded))` | Sets typography, weight, size, and design. |
| 203 | `                .padding(.top, 16)` | Adds layout spacing around the view. |
| 204 | `` | Blank line separating code sections. |
| 205 | `            TextField("Email address", text: $emailInput)` | Implements the surrounding screen, model, or view-builder expression. |
| 206 | `                .keyboardType(.emailAddress)` | Applies a SwiftUI modifier to the preceding view. |
| 207 | `                .textContentType(.emailAddress)` | Applies a SwiftUI modifier to the preceding view. |
| 208 | `                .textInputAutocapitalization(.never)` | Applies a SwiftUI modifier to the preceding view. |
| 209 | `                .autocorrectionDisabled()` | Applies a SwiftUI modifier to the preceding view. |
| 210 | `                .padding()` | Adds layout spacing around the view. |
| 211 | `                .background(Color(red: 242 / 255, green: 244 / 255, blue: 250 / 255))` | Adds the light card or sheet background behind the content. |
| 212 | `                .clipShape(RoundedRectangle(cornerRadius: 12))` | Clips content to a rounded shape. |
| 213 | `` | Blank line separating code sections. |
| 214 | `            SecureField("Password", text: $passwordInput)` | Implements the surrounding screen, model, or view-builder expression. |
| 215 | `                .textContentType(.password)` | Applies a SwiftUI modifier to the preceding view. |
| 216 | `                .padding()` | Adds layout spacing around the view. |
| 217 | `                .background(Color(red: 242 / 255, green: 244 / 255, blue: 250 / 255))` | Adds the light card or sheet background behind the content. |
| 218 | `                .clipShape(RoundedRectangle(cornerRadius: 12))` | Clips content to a rounded shape. |
| 219 | `` | Blank line separating code sections. |
| 220 | `            PrimaryActionButton(title: "Continue") {` | Uses the shared primary call-to-action component. |
| 221 | `                state.signIn(method: "Email", email: emailInput.isEmpty ? "user@stamerlee.com" : emailInput)` | Records the selected authentication method in AppState. |
| 222 | `                passwordInput = ""` | Implements the surrounding screen, model, or view-builder expression. |
| 223 | `                activeSheet = nil` | Implements the surrounding screen, model, or view-builder expression. |
| 224 | `                state.navigate(to: .onboarding1, forward: true)` | Moves the shared app state to the named screen and records navigation direction. |
| 225 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 226 | `            .padding(.top, 8)` | Adds layout spacing around the view. |
| 227 | `            Spacer()` | Implements the surrounding screen, model, or view-builder expression. |
| 228 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 229 | `        .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 230 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 231 | `` | Blank line separating code sections. |
| 232 | `    private func legalSheet(title: String, text: String) -> some View {` | Defines a private helper used to build or handle this screen. |
| 233 | `        VStack(alignment: .leading, spacing: 14) {` | Opens or closes a Swift scope or view-builder block. |
| 234 | `            Text(title).font(.system(size: 22, weight: .bold, design: .rounded))` | Displays a text label or explanatory copy. |
| 235 | `            Text(text).font(.system(size: 15)).foregroundStyle(StamerleeTheme.textSecondaryLight)` | Displays a text label or explanatory copy. |
| 236 | `            Spacer()` | Implements the surrounding screen, model, or view-builder expression. |
| 237 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 238 | `        .padding(24)` | Adds layout spacing around the view. |
| 239 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 240 | `}` | Opens or closes a Swift scope or view-builder block. |
| 241 | `` | Blank line separating code sections. |
| 242 | `// MARK: - 3. Onboarding Info 1` | Section marker organizing the onboarding implementation. |
| 243 | `public struct OnboardingStepOneView: View {` | Declares a reusable SwiftUI view or private supporting model. |
| 244 | `    @Bindable public var state: AppState` | Allows this view to mutate the observable AppState through bindings. |
| 245 | `` | Blank line separating code sections. |
| 246 | `    public init(state: AppState) {` | Initializes the view and receives shared app state or configuration. |
| 247 | `        self.state = state` | Implements the surrounding screen, model, or view-builder expression. |
| 248 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 249 | `` | Blank line separating code sections. |
| 250 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy for the screen. |
| 251 | `        ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 252 | `            StamerleeTheme.backgroundDark.ignoresSafeArea()` | Implements the surrounding screen, model, or view-builder expression. |
| 253 | `` | Blank line separating code sections. |
| 254 | `            VStack(spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 255 | `                HStack {` | Opens or closes a Swift scope or view-builder block. |
| 256 | `                    BackNavButton {` | Opens or closes a Swift scope or view-builder block. |
| 257 | `                        state.navigate(to: .login, forward: false)` | Moves the shared app state to the named screen and records navigation direction. |
| 258 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 259 | `                    Spacer()` | Implements the surrounding screen, model, or view-builder expression. |
| 260 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 261 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 262 | `                .padding(.top, 16)` | Adds layout spacing around the view. |
| 263 | `` | Blank line separating code sections. |
| 264 | `                VStack(alignment: .leading, spacing: 10) {` | Opens or closes a Swift scope or view-builder block. |
| 265 | `                    VStack(alignment: .leading, spacing: 4) {` | Opens or closes a Swift scope or view-builder block. |
| 266 | `                        Text("Small steps,")` | Displays a text label or explanatory copy. |
| 267 | `                            .font(.system(size: 32, weight: .bold, design: .rounded))` | Sets typography, weight, size, and design. |
| 268 | `                            .foregroundStyle(StamerleeTheme.textPrimaryDark)` | Sets the foreground color or gradient. |
| 269 | `` | Blank line separating code sections. |
| 270 | `                        Text("stronger speech")` | Displays a text label or explanatory copy. |
| 271 | `                            .font(.system(size: 32, weight: .bold, design: .rounded))` | Sets typography, weight, size, and design. |
| 272 | `                            .foregroundStyle(` | Sets the foreground color or gradient. |
| 273 | `                                LinearGradient(` | Implements the surrounding screen, model, or view-builder expression. |
| 274 | `                                    colors: [StamerleeTheme.accentPurpleLight, StamerleeTheme.accentPurple],` | Implements the surrounding screen, model, or view-builder expression. |
| 275 | `                                    startPoint: .leading,` | Implements the surrounding screen, model, or view-builder expression. |
| 276 | `                                    endPoint: .trailing` | Implements the surrounding screen, model, or view-builder expression. |
| 277 | `                                )` | Implements the surrounding screen, model, or view-builder expression. |
| 278 | `                            )` | Implements the surrounding screen, model, or view-builder expression. |
| 279 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 280 | `` | Blank line separating code sections. |
| 281 | `                    Text("Practice at your own pace, build confidence, and celebrate every step forward.")` | Displays a text label or explanatory copy. |
| 282 | `                        .font(.system(size: 15, weight: .regular, design: .rounded))` | Sets typography, weight, size, and design. |
| 283 | `                        .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or gradient. |
| 284 | `                        .lineSpacing(4)` | Applies a SwiftUI modifier to the preceding view. |
| 285 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 286 | `                .frame(maxWidth: .infinity, alignment: .leading)` | Sets the view size or alignment constraints. |
| 287 | `                .padding(.horizontal, 28)` | Adds layout spacing around the view. |
| 288 | `                .padding(.top, 16)` | Adds layout spacing around the view. |
| 289 | `` | Blank line separating code sections. |
| 290 | `                Spacer()` | Implements the surrounding screen, model, or view-builder expression. |
| 291 | `` | Blank line separating code sections. |
| 292 | `                OnboardingStepOneIllustration()` | Implements the surrounding screen, model, or view-builder expression. |
| 293 | `                    .padding(.vertical, 10)` | Adds layout spacing around the view. |
| 294 | `` | Blank line separating code sections. |
| 295 | `                Spacer()` | Implements the surrounding screen, model, or view-builder expression. |
| 296 | `` | Blank line separating code sections. |
| 297 | `                PrimaryActionButton(title: "Next", compact: true) {` | Uses the shared primary call-to-action component. |
| 298 | `                    state.navigate(to: .onboarding2, forward: true)` | Moves the shared app state to the named screen and records navigation direction. |
| 299 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 300 | `                .padding(.horizontal, 28)` | Adds layout spacing around the view. |
| 301 | `                .padding(.bottom, 24)` | Adds layout spacing around the view. |
| 302 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 303 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 304 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 305 | `}` | Opens or closes a Swift scope or view-builder block. |
| 306 | `` | Blank line separating code sections. |
| 307 | `// MARK: - 4. Onboarding Info 2` | Section marker organizing the onboarding implementation. |
| 308 | `public struct OnboardingStepTwoView: View {` | Declares a reusable SwiftUI view or private supporting model. |
| 309 | `    @Bindable public var state: AppState` | Allows this view to mutate the observable AppState through bindings. |
| 310 | `` | Blank line separating code sections. |
| 311 | `    public init(state: AppState) {` | Initializes the view and receives shared app state or configuration. |
| 312 | `        self.state = state` | Implements the surrounding screen, model, or view-builder expression. |
| 313 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 314 | `` | Blank line separating code sections. |
| 315 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy for the screen. |
| 316 | `        ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 317 | `            StamerleeTheme.backgroundDark.ignoresSafeArea()` | Implements the surrounding screen, model, or view-builder expression. |
| 318 | `` | Blank line separating code sections. |
| 319 | `            VStack(spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 320 | `                HStack {` | Opens or closes a Swift scope or view-builder block. |
| 321 | `                    BackNavButton {` | Opens or closes a Swift scope or view-builder block. |
| 322 | `                        state.navigate(to: .onboarding1, forward: false)` | Moves the shared app state to the named screen and records navigation direction. |
| 323 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 324 | `                    Spacer()` | Implements the surrounding screen, model, or view-builder expression. |
| 325 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 326 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 327 | `                .padding(.top, 16)` | Adds layout spacing around the view. |
| 328 | `` | Blank line separating code sections. |
| 329 | `                VStack(alignment: .leading, spacing: 10) {` | Opens or closes a Swift scope or view-builder block. |
| 330 | `                    Text("Support on your\nschedule")` | Displays a text label or explanatory copy. |
| 331 | `                        .font(.system(size: 32, weight: .bold, design: .rounded))` | Sets typography, weight, size, and design. |
| 332 | `                        .foregroundStyle(StamerleeTheme.textPrimaryDark)` | Sets the foreground color or gradient. |
| 333 | `                        .lineSpacing(2)` | Applies a SwiftUI modifier to the preceding view. |
| 334 | `` | Blank line separating code sections. |
| 335 | `                    Text("Simple activities to practice fluency and become more comfortable speaking.")` | Displays a text label or explanatory copy. |
| 336 | `                        .font(.system(size: 15, weight: .regular, design: .rounded))` | Sets typography, weight, size, and design. |
| 337 | `                        .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or gradient. |
| 338 | `                        .lineSpacing(4)` | Applies a SwiftUI modifier to the preceding view. |
| 339 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 340 | `                .frame(maxWidth: .infinity, alignment: .leading)` | Sets the view size or alignment constraints. |
| 341 | `                .padding(.horizontal, 28)` | Adds layout spacing around the view. |
| 342 | `                .padding(.top, 16)` | Adds layout spacing around the view. |
| 343 | `` | Blank line separating code sections. |
| 344 | `                Spacer()` | Implements the surrounding screen, model, or view-builder expression. |
| 345 | `` | Blank line separating code sections. |
| 346 | `                OnboardingStepTwoIllustration()` | Implements the surrounding screen, model, or view-builder expression. |
| 347 | `                    .padding(.vertical, 8)` | Adds layout spacing around the view. |
| 348 | `` | Blank line separating code sections. |
| 349 | `                Spacer()` | Implements the surrounding screen, model, or view-builder expression. |
| 350 | `` | Blank line separating code sections. |
| 351 | `                PrimaryActionButton(title: "Next", compact: true) {` | Uses the shared primary call-to-action component. |
| 352 | `                    state.navigate(to: .dailyGoal, forward: true)` | Moves the shared app state to the named screen and records navigation direction. |
| 353 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 354 | `                .padding(.horizontal, 28)` | Adds layout spacing around the view. |
| 355 | `                .padding(.bottom, 24)` | Adds layout spacing around the view. |
| 356 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 357 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 358 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 359 | `}` | Opens or closes a Swift scope or view-builder block. |
| 360 | `` | Blank line separating code sections. |
| 361 | `// MARK: - 5. Daily Goal View` | Section marker organizing the onboarding implementation. |
| 362 | `public struct DailyGoalView: View {` | Declares a reusable SwiftUI view or private supporting model. |
| 363 | `    @Bindable public var state: AppState` | Allows this view to mutate the observable AppState through bindings. |
| 364 | `` | Blank line separating code sections. |
| 365 | `    private let goalOptions = [5, 10, 15, 20]` | Implements the surrounding screen, model, or view-builder expression. |
| 366 | `` | Blank line separating code sections. |
| 367 | `    public init(state: AppState) {` | Initializes the view and receives shared app state or configuration. |
| 368 | `        self.state = state` | Implements the surrounding screen, model, or view-builder expression. |
| 369 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 370 | `` | Blank line separating code sections. |
| 371 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy for the screen. |
| 372 | `        ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 373 | `            StamerleeTheme.backgroundDark.ignoresSafeArea()` | Implements the surrounding screen, model, or view-builder expression. |
| 374 | `` | Blank line separating code sections. |
| 375 | `            VStack(alignment: .leading, spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 376 | `                HStack {` | Opens or closes a Swift scope or view-builder block. |
| 377 | `                    BackNavButton {` | Opens or closes a Swift scope or view-builder block. |
| 378 | `                        state.navigate(to: .onboarding2, forward: false)` | Moves the shared app state to the named screen and records navigation direction. |
| 379 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 380 | `                    Spacer()` | Implements the surrounding screen, model, or view-builder expression. |
| 381 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 382 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 383 | `                .padding(.top, 16)` | Adds layout spacing around the view. |
| 384 | `` | Blank line separating code sections. |
| 385 | `                Text("Set Your Goals")` | Displays a text label or explanatory copy. |
| 386 | `                    .font(.system(size: 32, weight: .bold, design: .rounded))` | Sets typography, weight, size, and design. |
| 387 | `                    .foregroundStyle(StamerleeTheme.textPrimaryDark)` | Sets the foreground color or gradient. |
| 388 | `                    .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 389 | `                    .padding(.top, 16)` | Adds layout spacing around the view. |
| 390 | `                    .padding(.bottom, 28)` | Adds layout spacing around the view. |
| 391 | `` | Blank line separating code sections. |
| 392 | `                VStack(alignment: .leading, spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 393 | `                    Text("Choose your daily goal")` | Displays a text label or explanatory copy. |
| 394 | `                        .font(.system(size: 16, weight: .bold, design: .rounded))` | Sets typography, weight, size, and design. |
| 395 | `                        .foregroundStyle(StamerleeTheme.textPrimaryLight)` | Sets the foreground color or gradient. |
| 396 | `                        .padding(.horizontal, 20)` | Adds layout spacing around the view. |
| 397 | `                        .padding(.top, 22)` | Adds layout spacing around the view. |
| 398 | `                        .padding(.bottom, 14)` | Adds layout spacing around the view. |
| 399 | `` | Blank line separating code sections. |
| 400 | `                    VStack(spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 401 | `                        ForEach(goalOptions, id: \.self) { minutes in` | Generates repeated views from the supplied collection. |
| 402 | `                            Button {` | Creates an interactive control that runs the supplied action. |
| 403 | `                                withAnimation(.easeInOut(duration: 0.2)) {` | Animates the enclosed state change. |
| 404 | `                                    state.dailyPracticeMinutes = minutes` | Implements the surrounding screen, model, or view-builder expression. |
| 405 | `                                }` | Opens or closes a Swift scope or view-builder block. |
| 406 | `                            } label: {` | Opens or closes a Swift scope or view-builder block. |
| 407 | `                                HStack {` | Opens or closes a Swift scope or view-builder block. |
| 408 | `                                    Text("\(minutes) min/day")` | Displays a text label or explanatory copy. |
| 409 | `                                        .font(.system(` | Sets typography, weight, size, and design. |
| 410 | `                                            size: 15,` | Implements the surrounding screen, model, or view-builder expression. |
| 411 | `                                            weight: state.dailyPracticeMinutes == minutes ? .semibold : .regular,` | Implements the surrounding screen, model, or view-builder expression. |
| 412 | `                                            design: .rounded` | Implements the surrounding screen, model, or view-builder expression. |
| 413 | `                                        ))` | Implements the surrounding screen, model, or view-builder expression. |
| 414 | `                                        .foregroundStyle(StamerleeTheme.textPrimaryLight)` | Sets the foreground color or gradient. |
| 415 | `` | Blank line separating code sections. |
| 416 | `                                    Spacer()` | Implements the surrounding screen, model, or view-builder expression. |
| 417 | `` | Blank line separating code sections. |
| 418 | `                                    ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 419 | `                                        if state.dailyPracticeMinutes == minutes {` | Conditionally renders or executes this branch. |
| 420 | `                                            Circle()` | Implements the surrounding screen, model, or view-builder expression. |
| 421 | `                                                .fill(StamerleeTheme.primaryBlue)` | Applies a SwiftUI modifier to the preceding view. |
| 422 | `                                                .frame(width: 22, height: 22)` | Sets the view size or alignment constraints. |
| 423 | `` | Blank line separating code sections. |
| 424 | `                                            Image(systemName: "checkmark")` | Displays an asset or system image. |
| 425 | `                                                .font(.system(size: 11, weight: .bold))` | Sets typography, weight, size, and design. |
| 426 | `                                                .foregroundStyle(.white)` | Sets the foreground color or gradient. |
| 427 | `                                        } else {` | Opens or closes a Swift scope or view-builder block. |
| 428 | `                                            Circle()` | Implements the surrounding screen, model, or view-builder expression. |
| 429 | `                                                .stroke(` | Applies a SwiftUI modifier to the preceding view. |
| 430 | `                                                    Color(red: 210 / 255, green: 215 / 255, blue: 228 / 255),` | Implements the surrounding screen, model, or view-builder expression. |
| 431 | `                                                    lineWidth: 1.8` | Implements the surrounding screen, model, or view-builder expression. |
| 432 | `                                                )` | Implements the surrounding screen, model, or view-builder expression. |
| 433 | `                                                .frame(width: 22, height: 22)` | Sets the view size or alignment constraints. |
| 434 | `                                        }` | Opens or closes a Swift scope or view-builder block. |
| 435 | `                                    }` | Opens or closes a Swift scope or view-builder block. |
| 436 | `                                }` | Opens or closes a Swift scope or view-builder block. |
| 437 | `                                .padding(.horizontal, 16)` | Adds layout spacing around the view. |
| 438 | `                                .frame(minHeight: 64)` | Sets the view size or alignment constraints. |
| 439 | `                                .background(` | Adds the light card or sheet background behind the content. |
| 440 | `                                    state.dailyPracticeMinutes == minutes` | Implements the surrounding screen, model, or view-builder expression. |
| 441 | `                                        ? StamerleeTheme.primaryBlue.opacity(0.08)` | Implements the surrounding screen, model, or view-builder expression. |
| 442 | `                                        : Color.clear` | Implements the surrounding screen, model, or view-builder expression. |
| 443 | `                                )` | Implements the surrounding screen, model, or view-builder expression. |
| 444 | `                            }` | Opens or closes a Swift scope or view-builder block. |
| 445 | `` | Blank line separating code sections. |
| 446 | `                            if minutes != goalOptions.last {` | Conditionally renders or executes this branch. |
| 447 | `                                Divider()` | Implements the surrounding screen, model, or view-builder expression. |
| 448 | `                                    .padding(.horizontal, 16)` | Adds layout spacing around the view. |
| 449 | `                            }` | Opens or closes a Swift scope or view-builder block. |
| 450 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 451 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 452 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 453 | `                .background(StamerleeTheme.cardLight)` | Adds the light card or sheet background behind the content. |
| 454 | `                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))` | Clips content to a rounded shape. |
| 455 | `                .shadow(color: Color.black.opacity(0.18), radius: 16, x: 0, y: 8)` | Adds visual depth around the logo, illustration, or card. |
| 456 | `                .padding(.horizontal, 20)` | Adds layout spacing around the view. |
| 457 | `` | Blank line separating code sections. |
| 458 | `                Spacer()` | Implements the surrounding screen, model, or view-builder expression. |
| 459 | `` | Blank line separating code sections. |
| 460 | `                PrimaryActionButton(` | Uses the shared primary call-to-action component. |
| 461 | `                    title: "Next",` | Implements the surrounding screen, model, or view-builder expression. |
| 462 | `                    compact: true` | Implements the surrounding screen, model, or view-builder expression. |
| 463 | `                ) {` | Opens or closes a Swift scope or view-builder block. |
| 464 | `                    state.navigate(to: .exploreActivities, forward: true)` | Moves the shared app state to the named screen and records navigation direction. |
| 465 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 466 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 467 | `                .padding(.bottom, 24)` | Adds layout spacing around the view. |
| 468 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 469 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 470 | `        .sensoryFeedback(.selection, trigger: state.dailyPracticeMinutes)` | Applies a SwiftUI modifier to the preceding view. |
| 471 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 472 | `}` | Opens or closes a Swift scope or view-builder block. |
| 473 | `` | Blank line separating code sections. |
| 474 | `// MARK: - 6. Explore Activities View` | Section marker organizing the onboarding implementation. |
| 475 | `public struct ExploreActivitiesView: View {` | Declares a reusable SwiftUI view or private supporting model. |
| 476 | `    @Bindable public var state: AppState` | Allows this view to mutate the observable AppState through bindings. |
| 477 | `` | Blank line separating code sections. |
| 478 | `    @State private var cardsVisible = false` | Stores local UI state managed by SwiftUI. |
| 479 | `` | Blank line separating code sections. |
| 480 | `    public init(state: AppState) {` | Initializes the view and receives shared app state or configuration. |
| 481 | `        self.state = state` | Implements the surrounding screen, model, or view-builder expression. |
| 482 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 483 | `` | Blank line separating code sections. |
| 484 | `    private struct ActivityCardItem: Identifiable {` | Declares a reusable SwiftUI view or private supporting model. |
| 485 | `        let id: String` | Defines an immutable configuration value or collection. |
| 486 | `        let iconName: String` | Defines an immutable configuration value or collection. |
| 487 | `        let text: String` | Defines an immutable configuration value or collection. |
| 488 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 489 | `` | Blank line separating code sections. |
| 490 | `    private let activities: [ActivityCardItem] = [` | Implements the surrounding screen, model, or view-builder expression. |
| 491 | `        ActivityCardItem(` | Implements the surrounding screen, model, or view-builder expression. |
| 492 | `            id: "prolonged",` | Implements the surrounding screen, model, or view-builder expression. |
| 493 | `            iconName: "IconProlongedSpeech",` | Implements the surrounding screen, model, or view-builder expression. |
| 494 | `            text: "Learn smooth pacing with prolonged speech and continuous airflow exercises"` | Implements the surrounding screen, model, or view-builder expression. |
| 495 | `        ),` | Implements the surrounding screen, model, or view-builder expression. |
| 496 | `        ActivityCardItem(` | Implements the surrounding screen, model, or view-builder expression. |
| 497 | `            id: "picture",` | Implements the surrounding screen, model, or view-builder expression. |
| 498 | `            iconName: "IconPictureDesc",` | Implements the surrounding screen, model, or view-builder expression. |
| 499 | `            text: "Build spontaneous fluency with picture description"` | Implements the surrounding screen, model, or view-builder expression. |
| 500 | `        ),` | Implements the surrounding screen, model, or view-builder expression. |
| 501 | `        ActivityCardItem(` | Implements the surrounding screen, model, or view-builder expression. |
| 502 | `            id: "dial",` | Implements the surrounding screen, model, or view-builder expression. |
| 503 | `            iconName: "IconDialScene",` | Implements the surrounding screen, model, or view-builder expression. |
| 504 | `            text: "Simulate phone calls using dial scene to build conversational confidence"` | Implements the surrounding screen, model, or view-builder expression. |
| 505 | `        ),` | Implements the surrounding screen, model, or view-builder expression. |
| 506 | `        ActivityCardItem(` | Implements the surrounding screen, model, or view-builder expression. |
| 507 | `            id: "mirror",` | Implements the surrounding screen, model, or view-builder expression. |
| 508 | `            iconName: "IconMirrorNarration",` | Implements the surrounding screen, model, or view-builder expression. |
| 509 | `            text: "Monitor your physical tension during narration with mirror exercises"` | Implements the surrounding screen, model, or view-builder expression. |
| 510 | `        )` | Implements the surrounding screen, model, or view-builder expression. |
| 511 | `    ]` | Implements the surrounding screen, model, or view-builder expression. |
| 512 | `` | Blank line separating code sections. |
| 513 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy for the screen. |
| 514 | `        ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 515 | `            StamerleeTheme.backgroundDark.ignoresSafeArea()` | Implements the surrounding screen, model, or view-builder expression. |
| 516 | `` | Blank line separating code sections. |
| 517 | `            VStack(alignment: .leading, spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 518 | `                HStack {` | Opens or closes a Swift scope or view-builder block. |
| 519 | `                    BackNavButton {` | Opens or closes a Swift scope or view-builder block. |
| 520 | `                        state.navigate(to: .dailyGoal, forward: false)` | Moves the shared app state to the named screen and records navigation direction. |
| 521 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 522 | `                    Spacer()` | Implements the surrounding screen, model, or view-builder expression. |
| 523 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 524 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 525 | `                .padding(.top, 16)` | Adds layout spacing around the view. |
| 526 | `` | Blank line separating code sections. |
| 527 | `                Text("Explore activities\ndesigned for your\nstutter")` | Displays a text label or explanatory copy. |
| 528 | `                    .font(.system(size: 28, weight: .bold, design: .rounded))` | Sets typography, weight, size, and design. |
| 529 | `                    .foregroundStyle(StamerleeTheme.textPrimaryDark)` | Sets the foreground color or gradient. |
| 530 | `                    .lineSpacing(3)` | Applies a SwiftUI modifier to the preceding view. |
| 531 | `                    .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 532 | `                    .padding(.top, 16)` | Adds layout spacing around the view. |
| 533 | `                    .padding(.bottom, 22)` | Adds layout spacing around the view. |
| 534 | `` | Blank line separating code sections. |
| 535 | `                ScrollView(showsIndicators: false) {` | Opens or closes a Swift scope or view-builder block. |
| 536 | `                    VStack(spacing: 12) {` | Opens or closes a Swift scope or view-builder block. |
| 537 | `                        ForEach(Array(activities.enumerated()), id: \.element.id) { index, item in` | Generates repeated views from the supplied collection. |
| 538 | `                            activityCard(item)` | Implements the surrounding screen, model, or view-builder expression. |
| 539 | `                                .opacity(cardsVisible ? 1 : 0)` | Controls visibility during an animation. |
| 540 | `                                .offset(y: cardsVisible ? 0 : 20)` | Moves the view for the entrance or floating animation. |
| 541 | `                                .animation(` | Associates an animation with changes to the supplied state value. |
| 542 | `                                    .spring(response: 0.5, dampingFraction: 0.85)` | Applies a SwiftUI modifier to the preceding view. |
| 543 | `                                        .delay(0.08 + Double(index) * 0.06),` | Applies a SwiftUI modifier to the preceding view. |
| 544 | `                                    value: cardsVisible` | Implements the surrounding screen, model, or view-builder expression. |
| 545 | `                                )` | Implements the surrounding screen, model, or view-builder expression. |
| 546 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 547 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 548 | `                    .padding(.horizontal, 20)` | Adds layout spacing around the view. |
| 549 | `                    .padding(.bottom, 16)` | Adds layout spacing around the view. |
| 550 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 551 | `` | Blank line separating code sections. |
| 552 | `                Spacer()` | Implements the surrounding screen, model, or view-builder expression. |
| 553 | `` | Blank line separating code sections. |
| 554 | `                PrimaryActionButton(title: "Begin", compact: true) {` | Uses the shared primary call-to-action component. |
| 555 | `                    state.navigate(to: .homeDashboard, forward: true)` | Moves the shared app state to the named screen and records navigation direction. |
| 556 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 557 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 558 | `                .padding(.bottom, 24)` | Adds layout spacing around the view. |
| 559 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 560 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 561 | `        .onAppear { cardsVisible = true }` | Runs setup or starts the entrance animation when the view appears. |
| 562 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 563 | `` | Blank line separating code sections. |
| 564 | `    private func activityCard(_ item: ActivityCardItem) -> some View {` | Defines a private helper used to build or handle this screen. |
| 565 | `        HStack(spacing: 16) {` | Opens or closes a Swift scope or view-builder block. |
| 566 | `            Image(item.iconName)` | Displays an asset or system image. |
| 567 | `                .resizable()` | Applies a SwiftUI modifier to the preceding view. |
| 568 | `                .scaledToFit()` | Applies a SwiftUI modifier to the preceding view. |
| 569 | `                .frame(width: 44, height: 44)` | Sets the view size or alignment constraints. |
| 570 | `` | Blank line separating code sections. |
| 571 | `            Text(item.text)` | Displays a text label or explanatory copy. |
| 572 | `                .font(.system(size: 13.5, weight: .semibold, design: .rounded))` | Sets typography, weight, size, and design. |
| 573 | `                .foregroundStyle(StamerleeTheme.textPrimaryLight)` | Sets the foreground color or gradient. |
| 574 | `                .lineSpacing(2.5)` | Applies a SwiftUI modifier to the preceding view. |
| 575 | `                .multilineTextAlignment(.leading)` | Applies a SwiftUI modifier to the preceding view. |
| 576 | `` | Blank line separating code sections. |
| 577 | `            Spacer(minLength: 4)` | Implements the surrounding screen, model, or view-builder expression. |
| 578 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 579 | `        .padding(.horizontal, 16)` | Adds layout spacing around the view. |
| 580 | `        .padding(.vertical, 14)` | Adds layout spacing around the view. |
| 581 | `        .background(Color(red: 238 / 255, green: 240 / 255, blue: 250 / 255))` | Adds the light card or sheet background behind the content. |
| 582 | `        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))` | Clips content to a rounded shape. |
| 583 | `        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)` | Adds visual depth around the logo, illustration, or card. |
| 584 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 585 | `}` | Opens or closes a Swift scope or view-builder block. |

### `Stamerlee/Illustrations.swift` (47 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports the framework used by this file. |
| 2 | `` | Blank line separating code sections. |
| 3 | `// MARK: - Onboarding Step 1 Hero Image` | Section marker organizing the onboarding implementation. |
| 4 | `/// Girl with headphones and mic badge (asset catalog: \`OnboardingHero1\`).` | Documentation comment describing the following public API or asset. |
| 5 | `public struct OnboardingStepOneIllustration: View {` | Declares a reusable SwiftUI view or private supporting model. |
| 6 | `    @State private var floatBadge: Bool = false` | Stores local UI state managed by SwiftUI. |
| 7 | `    ` | Blank line separating code sections. |
| 8 | `    public init() {}` | Initializes the view and receives shared app state or configuration. |
| 9 | `    ` | Blank line separating code sections. |
| 10 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy for the screen. |
| 11 | `        Image("OnboardingHero1")` | Displays an asset or system image. |
| 12 | `            .resizable()` | Applies a SwiftUI modifier to the preceding view. |
| 13 | `            .scaledToFit()` | Applies a SwiftUI modifier to the preceding view. |
| 14 | `            .frame(maxHeight: 270)` | Sets the view size or alignment constraints. |
| 15 | `            .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 10)` | Adds visual depth around the logo, illustration, or card. |
| 16 | `            .scaleEffect(floatBadge ? 1.015 : 0.985)` | Applies a SwiftUI modifier to the preceding view. |
| 17 | `            .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true), value: floatBadge)` | Associates an animation with changes to the supplied state value. |
| 18 | `            .frame(height: 290)` | Sets the view size or alignment constraints. |
| 19 | `            .accessibilityHidden(true)` | Removes decorative artwork from the accessibility tree. |
| 20 | `            .onAppear {` | Runs setup or starts the entrance animation when the view appears. |
| 21 | `                floatBadge = true` | Implements the surrounding screen, model, or view-builder expression. |
| 22 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 23 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 24 | `}` | Opens or closes a Swift scope or view-builder block. |
| 25 | `` | Blank line separating code sections. |
| 26 | `// MARK: - Onboarding Step 2 Hero Image` | Section marker organizing the onboarding implementation. |
| 27 | `/// Coach video call card with speech bubble (asset catalog: \`OnboardingHero2\`).` | Documentation comment describing the following public API or asset. |
| 28 | `public struct OnboardingStepTwoIllustration: View {` | Declares a reusable SwiftUI view or private supporting model. |
| 29 | `    @State private var subtleFloat: Bool = false` | Stores local UI state managed by SwiftUI. |
| 30 | `    ` | Blank line separating code sections. |
| 31 | `    public init() {}` | Initializes the view and receives shared app state or configuration. |
| 32 | `    ` | Blank line separating code sections. |
| 33 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy for the screen. |
| 34 | `        Image("OnboardingHero2")` | Displays an asset or system image. |
| 35 | `            .resizable()` | Applies a SwiftUI modifier to the preceding view. |
| 36 | `            .scaledToFit()` | Applies a SwiftUI modifier to the preceding view. |
| 37 | `            .frame(maxHeight: 310)` | Sets the view size or alignment constraints. |
| 38 | `            .shadow(color: Color.black.opacity(0.38), radius: 24, x: 0, y: 12)` | Adds visual depth around the logo, illustration, or card. |
| 39 | `            .offset(y: subtleFloat ? -4 : 4)` | Moves the view for the entrance or floating animation. |
| 40 | `            .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: subtleFloat)` | Associates an animation with changes to the supplied state value. |
| 41 | `            .frame(height: 330)` | Sets the view size or alignment constraints. |
| 42 | `            .accessibilityHidden(true)` | Removes decorative artwork from the accessibility tree. |
| 43 | `            .onAppear {` | Runs setup or starts the entrance animation when the view appears. |
| 44 | `                subtleFloat = true` | Implements the surrounding screen, model, or view-builder expression. |
| 45 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 46 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 47 | `}` | Opens or closes a Swift scope or view-builder block. |

## Review notes

- Authentication is currently demo-oriented: empty email input falls back to `user@stamerlee.com`, and legal content is placeholder text.
- The launch screen starts a new asynchronous delay every time it appears; consider cancellation if the screen can appear repeatedly during rapid navigation.
- The activity list uses asset names such as `IconProlongedSpeech`; all referenced assets must exist in the asset catalog.
- The illustrations are hidden from VoiceOver because they are decorative; retain meaningful text descriptions if the artwork conveys essential information.
