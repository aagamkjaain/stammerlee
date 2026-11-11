# Home Dashboard and Prolonged Speech Intro

This document explains the home dashboard and the Prolonged Speech introduction screen, including the shared tab binding that hosts the dashboard.

## Screen relationship

```text
DashboardTabView
  -> HomeDashboardView
       -> Prolonged Speech row
            -> ProlongedSpeechIntroView (first visit)
            -> ProlongedSpeechDifficultyView (after intro seen)
       -> other exercises / Beat Buddy / Fluency Lap
```

| Area | Behavior | State involved |
|---|---|---|
| Dashboard header | Shows “Welcome” and an interactive profile avatar. | `profileAvatarStyle`, `profileAvatarData`, `isHeroAvatarTransitionActive`. |
| Fluency Lap | Opens the focused fluency session card. | `currentScreen`. |
| Exercise rows | Routes each exercise to its intro or returning practice screen. | `hasSeen...Intro` flags and `currentScreen`. |
| Prolonged Speech intro | Presents shared title, subtitle, hero image, back, and continue actions. | `hasSeenProlongedSpeechIntro`. |
| Tab navigation | Selects Home or Summary using an `AppState` binding. | `selectedTab`. |

## Compatibility and possible deprecations

No definite deprecated API is confirmed from source inspection alone. Review these availability-sensitive areas:

- `@Bindable` works with the Observation-based `AppState`; it is modern rather than deprecated, but requires the project’s supported Swift/OS toolchain.
- The iOS 26 `.glass` button style in `ExerciseRowCard` is availability-gated and therefore not a deprecation issue. Keep the `BouncyCardButtonStyle` fallback for older systems.
- `Tab`-based tab declarations are used only in the iOS 18 branch; the legacy branch should remain tested if older iOS versions are supported.
- `.onChange(of: state.currentScreen) { _, newScreen in ... }` is the current two-parameter observation form.
- `import UIKit` is present because the dashboard’s broader module uses UIKit-backed types elsewhere; remove it only after confirming the complete file no longer needs it.

## Line-by-line explanation

### `Stamerlee/HomeDashboardView.swift` (429 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports the framework needed by this source file. |
| 2 | `import UIKit` | Imports the framework needed by this source file. |
| 3 | `` | Blank line separating code sections. |
| 4 | `// MARK: - Home Dashboard View (Screenshot 2: "Welcome")` | Section marker organizing the dashboard or exercise code. |
| 5 | `/// Main application hub with daily goals, exercise modules, and bottom tab bar.` | Documentation comment describing the following reusable API. |
| 6 | `public struct HomeDashboardView: View {` | Declares a reusable SwiftUI view or private supporting view. |
| 7 | `    @Bindable public var state: AppState` | Allows the view to read and mutate the observable AppState. |
| 8 | `    ` | Blank line separating code sections. |
| 9 | `    @State private var showLockedAlert: Bool = false` | Stores local view state managed by SwiftUI. |
| 10 | `    @State private var lockedAlertMessage: String = ""` | Stores local view state managed by SwiftUI. |
| 11 | `    @State private var cardsAppeared: Bool = false` | Stores local view state managed by SwiftUI. |
| 12 | `    ` | Blank line separating code sections. |
| 13 | `    public init(state: AppState) {` | Initializes the view with shared state or configuration. |
| 14 | `        self.state = state` | Implements the surrounding dashboard, intro, or navigation expression. |
| 15 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 16 | `    ` | Blank line separating code sections. |
| 17 | `    public var body: some View {` | Defines the rendered SwiftUI view hierarchy. |
| 18 | `       ` | Blank line separating code sections. |
| 19 | `        ZStack(alignment: .bottom) {` | Opens or closes a Swift scope or view-builder block. |
| 20 | `            // Dark Background` | Comment describing the purpose of the following UI block. |
| 21 | `            StamerleeTheme.backgroundDark` | Implements the surrounding dashboard, intro, or navigation expression. |
| 22 | `                .ignoresSafeArea()` | Applies a SwiftUI modifier to the preceding view. |
| 23 | `            ` | Blank line separating code sections. |
| 24 | `            VStack(alignment: .leading, spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 25 | `                // Header Bar` | Comment describing the purpose of the following UI block. |
| 26 | `                HStack {` | Opens or closes a Swift scope or view-builder block. |
| 27 | `                    Text("Welcome")` | Displays a text label or explanatory copy. |
| 28 | `                        .font(.system(size: 32, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 29 | `                        .foregroundStyle(StamerleeTheme.textPrimaryDark)` | Sets the foreground color, opacity, or gradient. |
| 30 | `                    ` | Blank line separating code sections. |
| 31 | `                    Spacer()` | Implements the surrounding dashboard, intro, or navigation expression. |
| 32 | `` | Blank line separating code sections. |
| 33 | `                    Button {` | Creates an interactive button that invokes the supplied action. |
| 34 | `                        state.navigate(to: .profile)` | Changes the shared app screen and records the navigation direction. |
| 35 | `                    } label: {` | Opens or closes a Swift scope or view-builder block. |
| 36 | `                        ProfileAvatar(` | Implements the surrounding dashboard, intro, or navigation expression. |
| 37 | `                            style: state.profileAvatarStyle,` | Implements the surrounding dashboard, intro, or navigation expression. |
| 38 | `                            imageData: state.profileAvatarData,` | Implements the surrounding dashboard, intro, or navigation expression. |
| 39 | `                            size: 38` | Implements the surrounding dashboard, intro, or navigation expression. |
| 40 | `                        )` | Implements the surrounding dashboard, intro, or navigation expression. |
| 41 | `                        .opacity(state.isHeroAvatarTransitionActive ? 0 : 1)` | Controls visibility during the entrance or avatar transition. |
| 42 | `                        .reportProfileAvatarFrame(.home)` | Applies a SwiftUI modifier to the preceding view. |
| 43 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 44 | `                    .buttonStyle(AvatarInteractiveButtonStyle())` | Applies a button interaction style. |
| 45 | `                    .accessibilityLabel("Open profile")` | Adds accessibility semantics or hides decorative content. |
| 46 | `                    ` | Blank line separating code sections. |
| 47 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 48 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 49 | `                .padding(.top, 16)` | Adds layout spacing around the view. |
| 50 | `                .padding(.bottom, 14)` | Adds layout spacing around the view. |
| 51 | `                ` | Blank line separating code sections. |
| 52 | `                // Scrollable Body Content` | Comment describing the purpose of the following UI block. |
| 53 | `                ScrollView(showsIndicators: false) {` | Opens or closes a Swift scope or view-builder block. |
| 54 | `                    VStack(alignment: .leading, spacing: 20) {` | Opens or closes a Swift scope or view-builder block. |
| 55 | `                        // Fluency Lap Card` | Comment describing the purpose of the following UI block. |
| 56 | `                        fluencyLapCard` | Implements the surrounding dashboard, intro, or navigation expression. |
| 57 | `                            .offset(y: cardsAppeared ? 0 : 36)` | Moves the view during the entrance animation. |
| 58 | `                            .scaleEffect(cardsAppeared ? 1.0 : 0.94)` | Scales the view for the entrance or press animation. |
| 59 | `                            .opacity(cardsAppeared ? 1 : 0)` | Controls visibility during the entrance or avatar transition. |
| 60 | `                            .animation(` | Associates an animation with changes to the supplied state value. |
| 61 | `                                .spring(response: 0.52, dampingFraction: 0.65).delay(0.04),` | Applies a SwiftUI modifier to the preceding view. |
| 62 | `                                value: cardsAppeared` | Implements the surrounding dashboard, intro, or navigation expression. |
| 63 | `                            )` | Implements the surrounding dashboard, intro, or navigation expression. |
| 64 | `                        ` | Blank line separating code sections. |
| 65 | `                        // Exercises Section` | Comment describing the purpose of the following UI block. |
| 66 | `                        VStack(alignment: .leading, spacing: 8) {` | Opens or closes a Swift scope or view-builder block. |
| 67 | `                            Text("Exercises")` | Displays a text label or explanatory copy. |
| 68 | `                                .font(.system(size: 17, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 69 | `                                .foregroundStyle(StamerleeTheme.textPrimaryDark)` | Sets the foreground color, opacity, or gradient. |
| 70 | `                            ` | Blank line separating code sections. |
| 71 | `                            // 1. Prolonged Speech (UNLOCKED - Primary action)` | Comment describing the purpose of the following UI block. |
| 72 | `                            exerciseRow(` | Implements the surrounding dashboard, intro, or navigation expression. |
| 73 | `                                title: "Prolonged Speech",` | Implements the surrounding dashboard, intro, or navigation expression. |
| 74 | `                                subtitle: "Practice gently stretching sounds while speaking slowly.",` | Implements the surrounding dashboard, intro, or navigation expression. |
| 75 | `                                isLocked: false,` | Implements the surrounding dashboard, intro, or navigation expression. |
| 76 | `                                iconName: "IconProlongedSpeech"` | Implements the surrounding dashboard, intro, or navigation expression. |
| 77 | `                            ) {` | Opens or closes a Swift scope or view-builder block. |
| 78 | `                                state.navigate(` | Implements the surrounding dashboard, intro, or navigation expression. |
| 79 | `                                    to: state.hasSeenProlongedSpeechIntro` | Chooses the difficulty screen after the intro has been completed, otherwise opens the intro. |
| 80 | `                                        ? .prolongedSpeechDifficulty` | Implements the surrounding dashboard, intro, or navigation expression. |
| 81 | `                                        : .prolongedSpeechIntro` | Implements the surrounding dashboard, intro, or navigation expression. |
| 82 | `                                )` | Implements the surrounding dashboard, intro, or navigation expression. |
| 83 | `                            }` | Opens or closes a Swift scope or view-builder block. |
| 84 | `                            ` | Blank line separating code sections. |
| 85 | `                            // 2. Picture Description` | Comment describing the purpose of the following UI block. |
| 86 | `                            exerciseRow(` | Implements the surrounding dashboard, intro, or navigation expression. |
| 87 | `                                title: "Picture Description",` | Implements the surrounding dashboard, intro, or navigation expression. |
| 88 | `                                subtitle: "Describe real-world scenes in detail to practice spontaneous speech flow",` | Implements the surrounding dashboard, intro, or navigation expression. |
| 89 | `                                isLocked: false,` | Implements the surrounding dashboard, intro, or navigation expression. |
| 90 | `                                iconName: "IconPictureDesc"` | Implements the surrounding dashboard, intro, or navigation expression. |
| 91 | `                            ) {` | Opens or closes a Swift scope or view-builder block. |
| 92 | `                                state.navigate(` | Implements the surrounding dashboard, intro, or navigation expression. |
| 93 | `                                    to: state.hasSeenPictureDescriptionIntro` | Uses an intro-completion flag to choose the appropriate destination. |
| 94 | `                                        ? .pictureDescriptionPractice` | Implements the surrounding dashboard, intro, or navigation expression. |
| 95 | `                                        : .pictureDescriptionIntro` | Implements the surrounding dashboard, intro, or navigation expression. |
| 96 | `                                )` | Implements the surrounding dashboard, intro, or navigation expression. |
| 97 | `                            }` | Opens or closes a Swift scope or view-builder block. |
| 98 | `                            ` | Blank line separating code sections. |
| 99 | `                            // 3. Dial Scene` | Comment describing the purpose of the following UI block. |
| 100 | `                            exerciseRow(` | Implements the surrounding dashboard, intro, or navigation expression. |
| 101 | `                                title: "Dial Scene",` | Implements the surrounding dashboard, intro, or navigation expression. |
| 102 | `                                subtitle: "Practice interactive scenario-based phone calls and service counter chats",` | Implements the surrounding dashboard, intro, or navigation expression. |
| 103 | `                                isLocked: false,` | Implements the surrounding dashboard, intro, or navigation expression. |
| 104 | `                                iconName: "IconDialScene"` | Implements the surrounding dashboard, intro, or navigation expression. |
| 105 | `                            ) {` | Opens or closes a Swift scope or view-builder block. |
| 106 | `                                state.navigate(` | Implements the surrounding dashboard, intro, or navigation expression. |
| 107 | `                                    to: state.hasSeenDialSceneIntro` | Uses an intro-completion flag to choose the appropriate destination. |
| 108 | `                                        ? .dialScene` | Implements the surrounding dashboard, intro, or navigation expression. |
| 109 | `                                        : .dialSceneIntro` | Implements the surrounding dashboard, intro, or navigation expression. |
| 110 | `                                )` | Implements the surrounding dashboard, intro, or navigation expression. |
| 111 | `                            }` | Opens or closes a Swift scope or view-builder block. |
| 112 | `                            ` | Blank line separating code sections. |
| 113 | `                            // 4. Narration` | Comment describing the purpose of the following UI block. |
| 114 | `                            exerciseRow(` | Implements the surrounding dashboard, intro, or navigation expression. |
| 115 | `                                title: "Narration",` | Implements the surrounding dashboard, intro, or navigation expression. |
| 116 | `                                subtitle: "Practice reading and telling longer stories while watching yourself in the mirror",` | Implements the surrounding dashboard, intro, or navigation expression. |
| 117 | `                                isLocked: false,` | Implements the surrounding dashboard, intro, or navigation expression. |
| 118 | `                                iconName: "IconMirrorNarration"` | Implements the surrounding dashboard, intro, or navigation expression. |
| 119 | `                            ) {` | Opens or closes a Swift scope or view-builder block. |
| 120 | `                                state.navigate(` | Implements the surrounding dashboard, intro, or navigation expression. |
| 121 | `                                    to: state.hasSeenNarrationIntro` | Uses an intro-completion flag to choose the appropriate destination. |
| 122 | `                                        ? .narrationPractice` | Implements the surrounding dashboard, intro, or navigation expression. |
| 123 | `                                        : .narrationIntro` | Implements the surrounding dashboard, intro, or navigation expression. |
| 124 | `                                )` | Implements the surrounding dashboard, intro, or navigation expression. |
| 125 | `                            }` | Opens or closes a Swift scope or view-builder block. |
| 126 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 127 | `                        .offset(y: cardsAppeared ? 0 : 40)` | Moves the view during the entrance animation. |
| 128 | `                        .scaleEffect(cardsAppeared ? 1.0 : 0.94)` | Scales the view for the entrance or press animation. |
| 129 | `                        .opacity(cardsAppeared ? 1 : 0)` | Controls visibility during the entrance or avatar transition. |
| 130 | `                        .animation(` | Associates an animation with changes to the supplied state value. |
| 131 | `                            .spring(response: 0.54, dampingFraction: 0.67).delay(0.08),` | Applies a SwiftUI modifier to the preceding view. |
| 132 | `                            value: cardsAppeared` | Implements the surrounding dashboard, intro, or navigation expression. |
| 133 | `                        )` | Implements the surrounding dashboard, intro, or navigation expression. |
| 134 | `                        ` | Blank line separating code sections. |
| 135 | `                        // Practice Section` | Comment describing the purpose of the following UI block. |
| 136 | `                        VStack(alignment: .leading, spacing: 8) {` | Opens or closes a Swift scope or view-builder block. |
| 137 | `                            Text("Practice")` | Displays a text label or explanatory copy. |
| 138 | `                                .font(.system(size: 17, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 139 | `                                .foregroundStyle(StamerleeTheme.textPrimaryDark)` | Sets the foreground color, opacity, or gradient. |
| 140 | `                            ` | Blank line separating code sections. |
| 141 | `                            // Beat Buddy` | Comment describing the purpose of the following UI block. |
| 142 | `                            exerciseRow(` | Implements the surrounding dashboard, intro, or navigation expression. |
| 143 | `                                title: "Beat Buddy",` | Implements the surrounding dashboard, intro, or navigation expression. |
| 144 | `                                subtitle: "Practice speaking to a steady, rhythmic beat using an interactive metronome",` | Implements the surrounding dashboard, intro, or navigation expression. |
| 145 | `                                isLocked: false,` | Implements the surrounding dashboard, intro, or navigation expression. |
| 146 | `                                iconName: "BeatBuddyLogo"` | Implements the surrounding dashboard, intro, or navigation expression. |
| 147 | `                            ) {` | Opens or closes a Swift scope or view-builder block. |
| 148 | `                                state.navigate(to: .beatBuddyPracticeType)` | Changes the shared app screen and records the navigation direction. |
| 149 | `                            }` | Opens or closes a Swift scope or view-builder block. |
| 150 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 151 | `                        .offset(y: cardsAppeared ? 0 : 44)` | Moves the view during the entrance animation. |
| 152 | `                        .scaleEffect(cardsAppeared ? 1.0 : 0.94)` | Scales the view for the entrance or press animation. |
| 153 | `                        .opacity(cardsAppeared ? 1 : 0)` | Controls visibility during the entrance or avatar transition. |
| 154 | `                        .animation(` | Associates an animation with changes to the supplied state value. |
| 155 | `                            .spring(response: 0.56, dampingFraction: 0.69).delay(0.12),` | Applies a SwiftUI modifier to the preceding view. |
| 156 | `                            value: cardsAppeared` | Implements the surrounding dashboard, intro, or navigation expression. |
| 157 | `                        )` | Implements the surrounding dashboard, intro, or navigation expression. |
| 158 | `                        ` | Blank line separating code sections. |
| 159 | `                        // Extra bottom padding for floating tab bar` | Comment describing the purpose of the following UI block. |
| 160 | `                        Spacer().frame(height: 90)` | Implements the surrounding dashboard, intro, or navigation expression. |
| 161 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 162 | `                    .padding(.horizontal, 20)` | Adds layout spacing around the view. |
| 163 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 164 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 165 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 166 | `        .onAppear {` | Runs entrance-state setup when the view appears. |
| 167 | `            cardsAppeared = false` | Implements the surrounding dashboard, intro, or navigation expression. |
| 168 | `            withAnimation {` | Animates the enclosed state mutation. |
| 169 | `                cardsAppeared = true` | Implements the surrounding dashboard, intro, or navigation expression. |
| 170 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 171 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 172 | `        .onChange(of: state.currentScreen) { _, newScreen in` | Replays the dashboard entrance animation when the selected screen becomes home. |
| 173 | `            if newScreen == .homeDashboard {` | Conditionally renders or executes this branch. |
| 174 | `                cardsAppeared = false` | Implements the surrounding dashboard, intro, or navigation expression. |
| 175 | `                withAnimation {` | Animates the enclosed state mutation. |
| 176 | `                    cardsAppeared = true` | Implements the surrounding dashboard, intro, or navigation expression. |
| 177 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 178 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 179 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 180 | `        .alert("Module Locked", isPresented: $showLockedAlert) {` | Presents an alert controlled by the local Boolean state. |
| 181 | `            Button("OK", role: .cancel) {}` | Creates an interactive button that invokes the supplied action. |
| 182 | `        } message: {` | Opens or closes a Swift scope or view-builder block. |
| 183 | `            Text(lockedAlertMessage)` | Displays a text label or explanatory copy. |
| 184 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 185 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 186 | `    ` | Blank line separating code sections. |
| 187 | `    // MARK: - Fluency Lap Card` | Section marker organizing the dashboard or exercise code. |
| 188 | `    private var fluencyLapCard: some View {` | Defines a private computed view used by the dashboard. |
| 189 | `        Button(action: {` | Creates an interactive button that invokes the supplied action. |
| 190 | `            state.navigate(to: .fluencyLap)` | Changes the shared app screen and records the navigation direction. |
| 191 | `        }) {` | Opens or closes a Swift scope or view-builder block. |
| 192 | `            VStack(alignment: .leading, spacing: 14) {` | Opens or closes a Swift scope or view-builder block. |
| 193 | `                HStack(alignment: .center, spacing: 16) {` | Opens or closes a Swift scope or view-builder block. |
| 194 | `                    ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 195 | `                        RoundedRectangle(cornerRadius: 20, style: .continuous)` | Implements the surrounding dashboard, intro, or navigation expression. |
| 196 | `                            .fill(Color(red: 226 / 255, green: 224 / 255, blue: 252 / 255).opacity(0.85))` | Applies a SwiftUI modifier to the preceding view. |
| 197 | `                            .frame(width: 68, height: 68)` | Constrains the size or alignment of the view. |
| 198 | `                            .rotationEffect(.degrees(-5))` | Applies a SwiftUI modifier to the preceding view. |
| 199 | `` | Blank line separating code sections. |
| 200 | `                        Image(systemName: "calendar.badge.checkmark")` | Displays an image asset or SF Symbol. |
| 201 | `                            .font(.system(size: 24, weight: .semibold))` | Sets typography, size, weight, and design. |
| 202 | `                            .foregroundStyle(StamerleeTheme.primaryPurple)` | Sets the foreground color, opacity, or gradient. |
| 203 | `                            .frame(width: 48, height: 48)` | Constrains the size or alignment of the view. |
| 204 | `                            .background(Color.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 15, style: .continuous))` | Adds the card or fallback background behind the content. |
| 205 | `                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)` | Applies a SwiftUI modifier to the preceding view. |
| 206 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 207 | `                    .frame(width: 68, height: 68)` | Constrains the size or alignment of the view. |
| 208 | `` | Blank line separating code sections. |
| 209 | `                    VStack(alignment: .leading, spacing: 4) {` | Opens or closes a Swift scope or view-builder block. |
| 210 | `                        Text("Fluency Lap")` | Displays a text label or explanatory copy. |
| 211 | `                            .font(.system(size: 20, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 212 | `                            .foregroundStyle(Color(red: 20 / 255, green: 22 / 255, blue: 35 / 255))` | Sets the foreground color, opacity, or gradient. |
| 213 | `` | Blank line separating code sections. |
| 214 | `                        Text("A short, focused practice session to build fluency and confidence in your speech.")` | Displays a text label or explanatory copy. |
| 215 | `                            .font(.system(size: 13, weight: .medium, design: .rounded))` | Sets typography, size, weight, and design. |
| 216 | `                            .foregroundStyle(StamerleeTheme.textSecondaryLight)` | Sets the foreground color, opacity, or gradient. |
| 217 | `                            .lineSpacing(2)` | Applies a SwiftUI modifier to the preceding view. |
| 218 | `                            .lineLimit(3)` | Applies a SwiftUI modifier to the preceding view. |
| 219 | `                            .fixedSize(horizontal: false, vertical: true)` | Applies a SwiftUI modifier to the preceding view. |
| 220 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 221 | `                    .frame(maxWidth: .infinity, alignment: .leading)` | Constrains the size or alignment of the view. |
| 222 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 223 | `` | Blank line separating code sections. |
| 224 | `                HStack(spacing: 8) {` | Opens or closes a Swift scope or view-builder block. |
| 225 | `                    Text("Start Fluency Lap")` | Displays a text label or explanatory copy. |
| 226 | `                        .font(.system(size: 15, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 227 | `                    Image(systemName: "chevron.right")` | Displays an image asset or SF Symbol. |
| 228 | `                        .font(.system(size: 12, weight: .bold))` | Sets typography, size, weight, and design. |
| 229 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 230 | `                .foregroundStyle(.white)` | Sets the foreground color, opacity, or gradient. |
| 231 | `                .frame(maxWidth: .infinity)` | Constrains the size or alignment of the view. |
| 232 | `                .frame(height: 46)` | Constrains the size or alignment of the view. |
| 233 | `                .background(Color(red: 35 / 255, green: 37 / 255, blue: 62 / 255))` | Adds the card or fallback background behind the content. |
| 234 | `                .clipShape(Capsule())` | Applies a SwiftUI modifier to the preceding view. |
| 235 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 236 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 237 | `        .buttonStyle(.plain)` | Applies a button interaction style. |
| 238 | `        .padding(18)` | Adds layout spacing around the view. |
| 239 | `        .background(Color(red: 242 / 255, green: 243 / 255, blue: 252 / 255), in: RoundedRectangle(cornerRadius: 24, style: .continuous))` | Adds the card or fallback background behind the content. |
| 240 | `        .shadow(color: Color.black.opacity(0.06), radius: 7, x: 0, y: 3)` | Applies a SwiftUI modifier to the preceding view. |
| 241 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 242 | `    ` | Blank line separating code sections. |
| 243 | `    private func exerciseRow(` | Defines a private helper for card creation or alert behavior. |
| 244 | `        title: String,` | Implements the surrounding dashboard, intro, or navigation expression. |
| 245 | `        subtitle: String,` | Implements the surrounding dashboard, intro, or navigation expression. |
| 246 | `        isLocked: Bool,` | Implements the surrounding dashboard, intro, or navigation expression. |
| 247 | `        iconName: String? = nil,` | Implements the surrounding dashboard, intro, or navigation expression. |
| 248 | `        action: @escaping () -> Void` | Implements the surrounding dashboard, intro, or navigation expression. |
| 249 | `    ) -> some View {` | Opens or closes a Swift scope or view-builder block. |
| 250 | `        ExerciseRowCard(` | Implements the surrounding dashboard, intro, or navigation expression. |
| 251 | `            title: title,` | Implements the surrounding dashboard, intro, or navigation expression. |
| 252 | `            subtitle: subtitle,` | Implements the surrounding dashboard, intro, or navigation expression. |
| 253 | `            isLocked: isLocked,` | Implements the surrounding dashboard, intro, or navigation expression. |
| 254 | `            iconName: iconName,` | Implements the surrounding dashboard, intro, or navigation expression. |
| 255 | `            action: action` | Implements the surrounding dashboard, intro, or navigation expression. |
| 256 | `        )` | Implements the surrounding dashboard, intro, or navigation expression. |
| 257 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 258 | `    ` | Blank line separating code sections. |
| 259 | `    private func triggerLockedAlert(title: String) {` | Defines a private helper for card creation or alert behavior. |
| 260 | `        if title == "Beat Buddy" {` | Conditionally renders or executes this branch. |
| 261 | `            lockedAlertMessage = "Complete Prolonged Speech Easy and receive a score to unlock Beat Buddy!"` | Implements the surrounding dashboard, intro, or navigation expression. |
| 262 | `        } else {` | Opens or closes a Swift scope or view-builder block. |
| 263 | `            lockedAlertMessage = "\(title) will unlock as you complete the Prolonged Speech foundation exercises!"` | Implements the surrounding dashboard, intro, or navigation expression. |
| 264 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 265 | `        showLockedAlert = true` | Implements the surrounding dashboard, intro, or navigation expression. |
| 266 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 267 | `}` | Opens or closes a Swift scope or view-builder block. |
| 268 | `` | Blank line separating code sections. |
| 269 | `// MARK: - Exercise Row Card` | Section marker organizing the dashboard or exercise code. |
| 270 | `/// Card that keeps the original lavender look but gains the native iOS 26 glass` | Documentation comment describing the following reusable API. |
| 271 | `/// "bumpy" press physics via .buttonStyle(.glass). Falls back to BouncyCardButtonStyle` | Documentation comment describing the following reusable API. |
| 272 | `/// on iOS < 26 so the card colour is always identical.` | Documentation comment describing the following reusable API. |
| 273 | `private struct ExerciseRowCard: View {` | Declares a reusable SwiftUI view or private supporting view. |
| 274 | `    let title: String` | Declares an immutable local or stored value. |
| 275 | `    let subtitle: String` | Declares an immutable local or stored value. |
| 276 | `    let isLocked: Bool` | Declares an immutable local or stored value. |
| 277 | `    let iconName: String?` | Declares an immutable local or stored value. |
| 278 | `    let action: () -> Void` | Declares an immutable local or stored value. |
| 279 | `` | Blank line separating code sections. |
| 280 | `    // The original card colour that matches every other card in the app` | Comment describing the purpose of the following UI block. |
| 281 | `    private let cardColor = Color(red: 238 / 255, green: 240 / 255, blue: 250 / 255)` | Implements the surrounding dashboard, intro, or navigation expression. |
| 282 | `` | Blank line separating code sections. |
| 283 | `    var body: some View {` | Defines the rendered SwiftUI view hierarchy. |
| 284 | `        if #available(iOS 26.0, *) {` | Selects an implementation based on the operating-system availability. |
| 285 | `            // Native glass button — .interactive() gives the bumpy spring press` | Comment describing the purpose of the following UI block. |
| 286 | `            // .tint(cardColor) preserves the existing lavender look` | Comment describing the purpose of the following UI block. |
| 287 | `            Button(action: action) { cardContent }` | Creates an interactive button that invokes the supplied action. |
| 288 | `                .buttonStyle(.glass(.regular.tint(cardColor).interactive()))` | Applies a button interaction style. |
| 289 | `                .buttonBorderShape(.roundedRectangle(radius: 16))` | Applies a SwiftUI modifier to the preceding view. |
| 290 | `                .frame(maxWidth: .infinity)` | Constrains the size or alignment of the view. |
| 291 | `        } else {` | Opens or closes a Swift scope or view-builder block. |
| 292 | `            Button(action: action) { cardContent }` | Creates an interactive button that invokes the supplied action. |
| 293 | `                .buttonStyle(BouncyCardButtonStyle())` | Applies a button interaction style. |
| 294 | `                .frame(maxWidth: .infinity)` | Constrains the size or alignment of the view. |
| 295 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 296 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 297 | `` | Blank line separating code sections. |
| 298 | `    private var cardContent: some View {` | Defines a private computed view used by the dashboard. |
| 299 | `        HStack(alignment: .center, spacing: 12) {` | Opens or closes a Swift scope or view-builder block. |
| 300 | `            // Leading Icon — fixed width so text always starts at the same X` | Comment describing the purpose of the following UI block. |
| 301 | `            if isLocked {` | Conditionally renders or executes this branch. |
| 302 | `                ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 303 | `                    Circle()` | Implements the surrounding dashboard, intro, or navigation expression. |
| 304 | `                        .fill(Color(red: 90 / 255, green: 105 / 255, blue: 180 / 255))` | Applies a SwiftUI modifier to the preceding view. |
| 305 | `                        .frame(width: 38, height: 38)` | Constrains the size or alignment of the view. |
| 306 | `                    Image(systemName: "lock.fill")` | Displays an image asset or SF Symbol. |
| 307 | `                        .font(.system(size: 15, weight: .bold))` | Sets typography, size, weight, and design. |
| 308 | `                        .foregroundStyle(.white)` | Sets the foreground color, opacity, or gradient. |
| 309 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 310 | `                .frame(width: 56, height: 56)` | Constrains the size or alignment of the view. |
| 311 | `            } else if let iconName {` | Opens or closes a Swift scope or view-builder block. |
| 312 | `                Image(iconName)` | Displays an image asset or SF Symbol. |
| 313 | `                    .resizable()` | Applies a SwiftUI modifier to the preceding view. |
| 314 | `                    .aspectRatio(contentMode: .fit)` | Applies a SwiftUI modifier to the preceding view. |
| 315 | `                    .frame(width: 56, height: 56)` | Constrains the size or alignment of the view. |
| 316 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 317 | `` | Blank line separating code sections. |
| 318 | `            // Title + Subtitle — explicitly left-aligned and expanding` | Comment describing the purpose of the following UI block. |
| 319 | `            VStack(alignment: .leading, spacing: 2) {` | Opens or closes a Swift scope or view-builder block. |
| 320 | `                Text(title)` | Displays a text label or explanatory copy. |
| 321 | `                    .font(.system(size: 14, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 322 | `                    .foregroundStyle(StamerleeTheme.textPrimaryLight)` | Sets the foreground color, opacity, or gradient. |
| 323 | `                    .multilineTextAlignment(.leading)` | Applies a SwiftUI modifier to the preceding view. |
| 324 | `                Text(subtitle)` | Displays a text label or explanatory copy. |
| 325 | `                    .font(.system(size: 11, weight: .regular, design: .rounded))` | Sets typography, size, weight, and design. |
| 326 | `                    .foregroundStyle(StamerleeTheme.textSecondaryLight)` | Sets the foreground color, opacity, or gradient. |
| 327 | `                    .multilineTextAlignment(.leading)` | Applies a SwiftUI modifier to the preceding view. |
| 328 | `                    .lineLimit(2)` | Applies a SwiftUI modifier to the preceding view. |
| 329 | `                    .fixedSize(horizontal: false, vertical: true)` | Applies a SwiftUI modifier to the preceding view. |
| 330 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 331 | `            .frame(maxWidth: .infinity, alignment: .leading)` | Constrains the size or alignment of the view. |
| 332 | `` | Blank line separating code sections. |
| 333 | `            // Chevron` | Comment describing the purpose of the following UI block. |
| 334 | `            if !isLocked {` | Conditionally renders or executes this branch. |
| 335 | `                Image(systemName: "chevron.right")` | Displays an image asset or SF Symbol. |
| 336 | `                    .font(.system(size: 11, weight: .semibold))` | Sets typography, size, weight, and design. |
| 337 | `                    .foregroundStyle(Color.gray.opacity(0.5))` | Sets the foreground color, opacity, or gradient. |
| 338 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 339 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 340 | `        .padding(.horizontal, 12)` | Adds layout spacing around the view. |
| 341 | `        .padding(.vertical, 8)` | Adds layout spacing around the view. |
| 342 | `        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)` | Constrains the size or alignment of the view. |
| 343 | `        // On iOS < 26 draw the card background manually; on iOS 26 the glass style owns rendering` | Comment describing the purpose of the following UI block. |
| 344 | `        .background {` | Adds the card or fallback background behind the content. |
| 345 | `            if #available(iOS 26.0, *) {` | Selects an implementation based on the operating-system availability. |
| 346 | `                Color.clear` | Implements the surrounding dashboard, intro, or navigation expression. |
| 347 | `            } else {` | Opens or closes a Swift scope or view-builder block. |
| 348 | `                RoundedRectangle(cornerRadius: 16, style: .continuous)` | Implements the surrounding dashboard, intro, or navigation expression. |
| 349 | `                    .fill(cardColor)` | Applies a SwiftUI modifier to the preceding view. |
| 350 | `                    .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)` | Applies a SwiftUI modifier to the preceding view. |
| 351 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 352 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 353 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 354 | `}` | Opens or closes a Swift scope or view-builder block. |
| 355 | `` | Blank line separating code sections. |
| 356 | `` | Blank line separating code sections. |
| 357 | `` | Blank line separating code sections. |
| 358 | `` | Blank line separating code sections. |
| 359 | `public struct DashboardTabView: View {` | Declares a reusable SwiftUI view or private supporting view. |
| 360 | `    @Bindable public var state: AppState` | Allows the view to read and mutate the observable AppState. |
| 361 | `` | Blank line separating code sections. |
| 362 | `    public init(state: AppState) {` | Initializes the view with shared state or configuration. |
| 363 | `        self.state = state` | Implements the surrounding dashboard, intro, or navigation expression. |
| 364 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 365 | `` | Blank line separating code sections. |
| 366 | `    public var body: some View {` | Defines the rendered SwiftUI view hierarchy. |
| 367 | `        Group {` | Opens or closes a Swift scope or view-builder block. |
| 368 | `            if #available(iOS 18.0, *) {` | Selects an implementation based on the operating-system availability. |
| 369 | `                modernTabView` | Implements the surrounding dashboard, intro, or navigation expression. |
| 370 | `            } else {` | Opens or closes a Swift scope or view-builder block. |
| 371 | `                legacyTabView` | Implements the surrounding dashboard, intro, or navigation expression. |
| 372 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 373 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 374 | `        .preferredColorScheme(.dark)` | Requests dark appearance for this view hierarchy. |
| 375 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 376 | `` | Blank line separating code sections. |
| 377 | `    @available(iOS 18.0, *)` | Implements the surrounding dashboard, intro, or navigation expression. |
| 378 | `    private var modernTabView: some View {` | Defines a private computed view used by the dashboard. |
| 379 | `        TabView(selection: state.selectedTabBinding) {` | Builds the dashboard tab navigation and binds the selected tab. |
| 380 | `            Tab(` | Builds the dashboard tab navigation and binds the selected tab. |
| 381 | `                AppTab.home.title,` | Implements the surrounding dashboard, intro, or navigation expression. |
| 382 | `                systemImage: AppTab.home.systemImage,` | Implements the surrounding dashboard, intro, or navigation expression. |
| 383 | `                value: AppTab.home` | Implements the surrounding dashboard, intro, or navigation expression. |
| 384 | `            ) {` | Opens or closes a Swift scope or view-builder block. |
| 385 | `                HomeDashboardView(state: state)` | Implements the surrounding dashboard, intro, or navigation expression. |
| 386 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 387 | `` | Blank line separating code sections. |
| 388 | `            Tab(` | Builds the dashboard tab navigation and binds the selected tab. |
| 389 | `                AppTab.summary.title,` | Implements the surrounding dashboard, intro, or navigation expression. |
| 390 | `                systemImage: AppTab.summary.systemImage,` | Implements the surrounding dashboard, intro, or navigation expression. |
| 391 | `                value: AppTab.summary` | Implements the surrounding dashboard, intro, or navigation expression. |
| 392 | `            ) {` | Opens or closes a Swift scope or view-builder block. |
| 393 | `                SummaryView(state: state)` | Implements the surrounding dashboard, intro, or navigation expression. |
| 394 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 395 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 396 | `        .tint(StamerleeTheme.primaryBlue)` | Applies a SwiftUI modifier to the preceding view. |
| 397 | `        .sensoryFeedback(.selection, trigger: state.selectedTab)` | Applies a SwiftUI modifier to the preceding view. |
| 398 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 399 | `` | Blank line separating code sections. |
| 400 | `    private var legacyTabView: some View {` | Defines a private computed view used by the dashboard. |
| 401 | `        TabView(selection: state.selectedTabBinding) {` | Builds the dashboard tab navigation and binds the selected tab. |
| 402 | `            HomeDashboardView(state: state)` | Implements the surrounding dashboard, intro, or navigation expression. |
| 403 | `                .tabItem {` | Opens or closes a Swift scope or view-builder block. |
| 404 | `                    Label(` | Implements the surrounding dashboard, intro, or navigation expression. |
| 405 | `                        AppTab.home.title,` | Implements the surrounding dashboard, intro, or navigation expression. |
| 406 | `                        systemImage: AppTab.home.systemImage` | Implements the surrounding dashboard, intro, or navigation expression. |
| 407 | `                    )` | Implements the surrounding dashboard, intro, or navigation expression. |
| 408 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 409 | `                .tag(AppTab.home)` | Applies a SwiftUI modifier to the preceding view. |
| 410 | `` | Blank line separating code sections. |
| 411 | `            SummaryView(state: state)` | Implements the surrounding dashboard, intro, or navigation expression. |
| 412 | `                .tabItem {` | Opens or closes a Swift scope or view-builder block. |
| 413 | `                    Label(` | Implements the surrounding dashboard, intro, or navigation expression. |
| 414 | `                        AppTab.summary.title,` | Implements the surrounding dashboard, intro, or navigation expression. |
| 415 | `                        systemImage: AppTab.summary.systemImage` | Implements the surrounding dashboard, intro, or navigation expression. |
| 416 | `                    )` | Implements the surrounding dashboard, intro, or navigation expression. |
| 417 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 418 | `                .tag(AppTab.summary)` | Applies a SwiftUI modifier to the preceding view. |
| 419 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 420 | `        .tint(StamerleeTheme.primaryBlue)` | Applies a SwiftUI modifier to the preceding view. |
| 421 | `        .toolbarBackground(` | Applies a SwiftUI modifier to the preceding view. |
| 422 | `            StamerleeTheme.backgroundDark,` | Implements the surrounding dashboard, intro, or navigation expression. |
| 423 | `            for: .tabBar` | Implements the surrounding dashboard, intro, or navigation expression. |
| 424 | `        )` | Implements the surrounding dashboard, intro, or navigation expression. |
| 425 | `        .toolbarBackground(.visible, for: .tabBar)` | Applies a SwiftUI modifier to the preceding view. |
| 426 | `        .toolbarColorScheme(.dark, for: .tabBar)` | Applies a SwiftUI modifier to the preceding view. |
| 427 | `        .sensoryFeedback(.selection, trigger: state.selectedTab)` | Applies a SwiftUI modifier to the preceding view. |
| 428 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 429 | `}` | Opens or closes a Swift scope or view-builder block. |

### `Stamerlee/ProlongedSpeechIntroView.swift` (26 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports the framework needed by this source file. |
| 2 | `` | Blank line separating code sections. |
| 3 | `// MARK: - Prolonged Speech Intro View (Screenshot 3: "prolonged speech")` | Section marker organizing the dashboard or exercise code. |
| 4 | `/// Introduces the Prolonged Speech stretch and smoothing technique.` | Documentation comment describing the following reusable API. |
| 5 | `public struct ProlongedSpeechIntroView: View {` | Declares a reusable SwiftUI view or private supporting view. |
| 6 | `    @Bindable public var state: AppState` | Allows the view to read and mutate the observable AppState. |
| 7 | `` | Blank line separating code sections. |
| 8 | `    public init(state: AppState) {` | Initializes the view with shared state or configuration. |
| 9 | `        self.state = state` | Implements the surrounding dashboard, intro, or navigation expression. |
| 10 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 11 | `` | Blank line separating code sections. |
| 12 | `    public var body: some View {` | Defines the rendered SwiftUI view hierarchy. |
| 13 | `        ExerciseIntroSkeletonView(` | Reuses the shared exercise-introduction layout with screen-specific content and actions. |
| 14 | `            title: "Let's start with\nProlonged Speech",` | Implements the surrounding dashboard, intro, or navigation expression. |
| 15 | `            subtitle: "Learn to gently stretch sounds and connect words smoothly. This technique can help reduce speech tension and improve fluency with practice",` | Implements the surrounding dashboard, intro, or navigation expression. |
| 16 | `            heroImageName: "ProlongedSpeechHero",` | Implements the surrounding dashboard, intro, or navigation expression. |
| 17 | `            onBack: {` | Opens or closes a Swift scope or view-builder block. |
| 18 | `                state.navigate(to: .homeDashboard, forward: false)` | Changes the shared app screen and records the navigation direction. |
| 19 | `            },` | Implements the surrounding dashboard, intro, or navigation expression. |
| 20 | `            onContinue: {` | Opens or closes a Swift scope or view-builder block. |
| 21 | `                state.hasSeenProlongedSpeechIntro = true` | Chooses the difficulty screen after the intro has been completed, otherwise opens the intro. |
| 22 | `                state.navigate(to: .prolongedSpeechDifficulty)` | Changes the shared app screen and records the navigation direction. |
| 23 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 24 | `        )` | Implements the surrounding dashboard, intro, or navigation expression. |
| 25 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 26 | `}` | Opens or closes a Swift scope or view-builder block. |

### `Stamerlee/AppTabNavigation.swift` (11 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports the framework needed by this source file. |
| 2 | `` | Blank line separating code sections. |
| 3 | `// MARK: - Shared Tab Navigation` | Section marker organizing the dashboard or exercise code. |
| 4 | `public extension AppState {` | Adds shared functionality to the existing public type. |
| 5 | `    var selectedTabBinding: Binding<AppTab> {` | Declares a computed or mutable value. |
| 6 | `        Binding(` | Implements the surrounding dashboard, intro, or navigation expression. |
| 7 | `            get: { self.selectedTab },` | Implements the surrounding dashboard, intro, or navigation expression. |
| 8 | `            set: { self.selectTab($0) }` | Implements the surrounding dashboard, intro, or navigation expression. |
| 9 | `        )` | Implements the surrounding dashboard, intro, or navigation expression. |
| 10 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 11 | `}` | Opens or closes a Swift scope or view-builder block. |

## Review notes

- `showLockedAlert`, `lockedAlertMessage`, and `triggerLockedAlert` exist, but the currently shown dashboard rows all pass `isLocked: false`; locked-alert behavior is therefore prepared but not exercised by these rows.
- `ExerciseRowCard` duplicates the lavender card color as a local literal instead of using a theme constant. A future theme refactor should centralize that color.
- `ProlongedSpeechIntroView` intentionally marks the intro as seen before navigating to difficulty, so returning users bypass the intro.
- The shared `ExerciseIntroSkeletonView` starts its breathing animation in `onAppear`; verify reduced-motion behavior if accessibility requirements expand.
