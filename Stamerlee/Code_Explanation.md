# Stamerlee SwiftUI Code Explanation

Generated from the current source on 2026-11-11. The explanations preserve source line numbers and begin with the requested root content view and color theme.

## Scope

- [ContentView.swift](./ContentView.swift): root navigation, screen transitions, avatar hero animation, and test navigation overlay.
- [ColorTheme.swift](./ColorTheme.swift): shared palette and hexadecimal color conversion.
- [Components.swift](./Components.swift): reusable controls, exercise templates, analysis UI, avatars, button styles, and geometry helpers.

## Compatibility and deprecation summary

No definite deprecated API was identified from the source alone. The code primarily uses current SwiftUI APIs. Items worth validating against the project deployment target are listed below.

| Location | API or pattern | Assessment | Suggested action |
|---|---|---|---|
| [Components.swift](./Components.swift):57,128 | `buttonStyle(.glass(...))` with `#available(iOS 26.0, *)` | Availability-gated, not deprecated. | Keep the fallback path and verify the deployment target/Xcode SDK. |
| [Components.swift](./Components.swift):72 | `CircularProgressViewStyle(tint:)` | Not known to be deprecated, but it is an older explicit style spelling. | Consider `.tint(.white)` if the project target supports it and snapshot behavior remains correct. |
| [ContentView.swift](./ContentView.swift):205 | `DispatchQueue.main.asyncAfter` retry | Not deprecated, but less idiomatic than structured concurrency. | Consider a cancellable `Task` only if repeated retries or view lifetime become a concern. |
| [ColorTheme.swift](./ColorTheme.swift):56 | Ignored `scanHexInt64` result | Not deprecated; malformed strings silently become a transparent/near-black fallback. | Validate input and expose an optional/failable initializer if invalid hex is possible. |
| [Components.swift](./Components.swift):797 | `UIImage(data:)` | Current UIKit API, but the file relies on UIKit types through the project imports. | Add an explicit `import UIKit` if this target does not re-export it through SwiftUI. |

## Line-by-line explanation

### `Stamerlee/ContentView.swift` (299 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports SwiftUI, including views, state, transitions, colors, and layout primitives. |
| 2 | `` | Blank line used to separate declarations or visual sections. |
| 3 | `enum ProfileAvatarSlot {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 4 | `    case home` | Defines or handles one case of the surrounding enumeration or switch. |
| 5 | `    case profile` | Defines or handles one case of the surrounding enumeration or switch. |
| 6 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 7 | `` | Blank line used to separate declarations or visual sections. |
| 8 | `private struct ProfileAvatarFrameReporterKey: EnvironmentKey {` | Defines a file-private implementation detail that is not exposed as public API. |
| 9 | `    static let defaultValue: ((ProfileAvatarSlot, CGRect) -> Void)? = nil` | Implements the surrounding declaration or view-builder expression. |
| 10 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 11 | `` | Blank line used to separate declarations or visual sections. |
| 12 | `extension EnvironmentValues {` | Extends SwiftUI’s environment-value container with app-specific data. |
| 13 | `    var profileAvatarFrameReporter: ((ProfileAvatarSlot, CGRect) -> Void)? {` | Declares a mutable local or stored value. |
| 14 | `        get { self[ProfileAvatarFrameReporterKey.self] }` | Implements the surrounding declaration or view-builder expression. |
| 15 | `        set { self[ProfileAvatarFrameReporterKey.self] = newValue }` | Implements the surrounding declaration or view-builder expression. |
| 16 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 17 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 18 | `` | Blank line used to separate declarations or visual sections. |
| 19 | `// MARK: - Root Content View` | Section marker used to organize related declarations in Xcode. |
| 20 | `/// Master container managing transitions across all onboarding, exploration, and practice screens.` | Documentation comment describing the following public API. |
| 21 | `public struct ContentView: View {` | Defines a public reusable Swift type, usually a SwiftUI view or button style. |
| 22 | `    @State private var appState = AppState()` | Defines a private computed or stored property used only by the enclosing type. |
| 23 | `    @State private var showScreenPicker: Bool = false` | Defines a private computed or stored property used only by the enclosing type. |
| 24 | `    @State private var homeAvatarFrame: CGRect = .zero` | Defines a private computed or stored property used only by the enclosing type. |
| 25 | `    @State private var profileAvatarFrame: CGRect = .zero` | Defines a private computed or stored property used only by the enclosing type. |
| 26 | `    @State private var avatarHeroFrame: CGRect = .zero` | Defines a private computed or stored property used only by the enclosing type. |
| 27 | `    @State private var avatarHeroVisible = false` | Defines a private computed or stored property used only by the enclosing type. |
| 28 | `    ` | Blank line used to separate declarations or visual sections. |
| 29 | `    public init() {}` | Initializes the type and assigns its configurable inputs. |
| 30 | `    ` | Blank line used to separate declarations or visual sections. |
| 31 | `    public var body: some View {` | Defines the SwiftUI view hierarchy rendered by this type. |
| 32 | `        ZStack(alignment: .top) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 33 | `            // Active Screen with directional transition` | Inline comment documenting the intent of the following code. |
| 34 | `            Group {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 35 | `                switch appState.currentScreen {` | Selects behavior based on the value being switched over. |
| 36 | `                case .launch:` | Defines or handles one case of the surrounding enumeration or switch. |
| 37 | `                    LaunchView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 38 | `                        .transition(` | Defines how a view enters or leaves the hierarchy. |
| 39 | `                            .asymmetric(` | Applies a SwiftUI modifier to the preceding view. |
| 40 | `                                insertion: .opacity,` | Implements the surrounding declaration or view-builder expression. |
| 41 | `                                removal: .opacity.combined(with: .scale(scale: 1.04))` | Implements the surrounding declaration or view-builder expression. |
| 42 | `                            )` | Implements the surrounding declaration or view-builder expression. |
| 43 | `                        )` | Implements the surrounding declaration or view-builder expression. |
| 44 | `                case .login:` | Defines or handles one case of the surrounding enumeration or switch. |
| 45 | `                    LoginView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 46 | `                        .transition(` | Defines how a view enters or leaves the hierarchy. |
| 47 | `                            .asymmetric(` | Applies a SwiftUI modifier to the preceding view. |
| 48 | `                                insertion: .opacity,` | Implements the surrounding declaration or view-builder expression. |
| 49 | `                                removal: slideTransition(for: appState.navigationDirection)` | Implements the surrounding declaration or view-builder expression. |
| 50 | `                            )` | Implements the surrounding declaration or view-builder expression. |
| 51 | `                        )` | Implements the surrounding declaration or view-builder expression. |
| 52 | `                case .onboarding1:` | Defines or handles one case of the surrounding enumeration or switch. |
| 53 | `                    OnboardingStepOneView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 54 | `                        .transition(slideTransition(for: appState.navigationDirection))` | Defines how a view enters or leaves the hierarchy. |
| 55 | `                case .onboarding2:` | Defines or handles one case of the surrounding enumeration or switch. |
| 56 | `                    OnboardingStepTwoView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 57 | `                        .transition(slideTransition(for: appState.navigationDirection))` | Defines how a view enters or leaves the hierarchy. |
| 58 | `                case .dailyGoal:` | Defines or handles one case of the surrounding enumeration or switch. |
| 59 | `                    DailyGoalView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 60 | `                        .transition(slideTransition(for: appState.navigationDirection))` | Defines how a view enters or leaves the hierarchy. |
| 61 | `                case .exploreActivities:` | Defines or handles one case of the surrounding enumeration or switch. |
| 62 | `                    ExploreActivitiesView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 63 | `                        .transition(slideTransition(for: appState.navigationDirection))` | Defines how a view enters or leaves the hierarchy. |
| 64 | `                case .homeDashboard, .profile:` | Defines or handles one case of the surrounding enumeration or switch. |
| 65 | `                    DashboardTabView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 66 | `                        .zIndex(1)` | Applies a SwiftUI modifier to the preceding view. |
| 67 | `                        .transition(.identity)` | Defines how a view enters or leaves the hierarchy. |
| 68 | `                case .fluencyLap:` | Defines or handles one case of the surrounding enumeration or switch. |
| 69 | `                    FluencyLapView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 70 | `                        .transition(slideTransition(for: appState.navigationDirection))` | Defines how a view enters or leaves the hierarchy. |
| 71 | `                case .fluencyLapPractice:` | Defines or handles one case of the surrounding enumeration or switch. |
| 72 | `                    FluencyLapPracticeView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 73 | `                        .transition(slideTransition(for: appState.navigationDirection))` | Defines how a view enters or leaves the hierarchy. |
| 74 | `                case .prolongedSpeechIntro:` | Defines or handles one case of the surrounding enumeration or switch. |
| 75 | `                    ProlongedSpeechIntroView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 76 | `                        .transition(slideTransition(for: appState.navigationDirection))` | Defines how a view enters or leaves the hierarchy. |
| 77 | `                case .prolongedSpeechDifficulty:` | Defines or handles one case of the surrounding enumeration or switch. |
| 78 | `                    ProlongedSpeechDifficultyView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 79 | `                        .transition(slideTransition(for: appState.navigationDirection))` | Defines how a view enters or leaves the hierarchy. |
| 80 | `                case .prolongedPractice:` | Defines or handles one case of the surrounding enumeration or switch. |
| 81 | `                    ProlongedPracticeView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 82 | `                        .transition(slideTransition(for: appState.navigationDirection))` | Defines how a view enters or leaves the hierarchy. |
| 83 | `                case .prolongedAnalysis:` | Defines or handles one case of the surrounding enumeration or switch. |
| 84 | `                    ProlongedAnalysisView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 85 | `                        .transition(` | Defines how a view enters or leaves the hierarchy. |
| 86 | `                            .asymmetric(` | Applies a SwiftUI modifier to the preceding view. |
| 87 | `                                insertion: .opacity.combined(with: .scale(scale: 0.98)),` | Implements the surrounding declaration or view-builder expression. |
| 88 | `                                removal: .opacity` | Implements the surrounding declaration or view-builder expression. |
| 89 | `                            )` | Implements the surrounding declaration or view-builder expression. |
| 90 | `                        )` | Implements the surrounding declaration or view-builder expression. |
| 91 | `                case .pictureDescriptionIntro:` | Defines or handles one case of the surrounding enumeration or switch. |
| 92 | `                    PictureDescriptionIntroView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 93 | `                        .transition(slideTransition(for: appState.navigationDirection))` | Defines how a view enters or leaves the hierarchy. |
| 94 | `                case .pictureDescriptionDifficulty, .pictureDescriptionPractice:` | Defines or handles one case of the surrounding enumeration or switch. |
| 95 | `                    PictureDescriptionEasyView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 96 | `                        .transition(slideTransition(for: appState.navigationDirection))` | Defines how a view enters or leaves the hierarchy. |
| 97 | `                case .dialSceneIntro:` | Defines or handles one case of the surrounding enumeration or switch. |
| 98 | `                    DialSceneIntroView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 99 | `                        .transition(slideTransition(for: appState.navigationDirection))` | Defines how a view enters or leaves the hierarchy. |
| 100 | `                case .dialScene:` | Defines or handles one case of the surrounding enumeration or switch. |
| 101 | `                    DialSceneView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 102 | `                        .transition(slideTransition(for: appState.navigationDirection))` | Defines how a view enters or leaves the hierarchy. |
| 103 | `                case .narrationIntro:` | Defines or handles one case of the surrounding enumeration or switch. |
| 104 | `                    NarrationIntroView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 105 | `                        .transition(slideTransition(for: appState.navigationDirection))` | Defines how a view enters or leaves the hierarchy. |
| 106 | `                case .narrationDifficulty, .narrationPractice:` | Defines or handles one case of the surrounding enumeration or switch. |
| 107 | `                    NarrationPracticeView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 108 | `                        .transition(slideTransition(for: appState.navigationDirection))` | Defines how a view enters or leaves the hierarchy. |
| 109 | `                case .beatBuddyPracticeType:` | Defines or handles one case of the surrounding enumeration or switch. |
| 110 | `                    BeatBuddyWordsView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 111 | `                        .transition(slideTransition(for: appState.navigationDirection))` | Defines how a view enters or leaves the hierarchy. |
| 112 | `                case .beatBuddyWords:` | Defines or handles one case of the surrounding enumeration or switch. |
| 113 | `                    BeatBuddyWordsView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 114 | `                        .transition(slideTransition(for: appState.navigationDirection))` | Defines how a view enters or leaves the hierarchy. |
| 115 | `                case .beatBuddyBPM:` | Defines or handles one case of the surrounding enumeration or switch. |
| 116 | `                    BeatBuddyBPMView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 117 | `                        .transition(slideTransition(for: appState.navigationDirection))` | Defines how a view enters or leaves the hierarchy. |
| 118 | `                case .beatBuddyPractice:` | Defines or handles one case of the surrounding enumeration or switch. |
| 119 | `                    BeatBuddyPracticeView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 120 | `                        .transition(slideTransition(for: appState.navigationDirection))` | Defines how a view enters or leaves the hierarchy. |
| 121 | `                }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 122 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 123 | `            .animation(` | Attaches an animation that responds to changes in the supplied value. |
| 124 | `                appState.isProfileTransition` | Implements the surrounding declaration or view-builder expression. |
| 125 | `                    ? .spring(response: 0.44, dampingFraction: 0.82)` | Implements the surrounding declaration or view-builder expression. |
| 126 | `                    : .spring(response: 0.45, dampingFraction: 0.88),` | Implements the surrounding declaration or view-builder expression. |
| 127 | `                value: appState.currentScreen` | Implements the surrounding declaration or view-builder expression. |
| 128 | `            )` | Implements the surrounding declaration or view-builder expression. |
| 129 | `            ` | Blank line used to separate declarations or visual sections. |
| 130 | `            // Quick Screen Navigation Pill (for easy previewing & testing)` | Inline comment documenting the intent of the following code. |
| 131 | `            if showScreenPicker {` | Conditionally includes this branch when the Boolean or availability condition is true. |
| 132 | `                screenPickerOverlay` | Implements the surrounding declaration or view-builder expression. |
| 133 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 134 | `` | Blank line used to separate declarations or visual sections. |
| 135 | `            if appState.currentScreen == .profile {` | Conditionally includes this branch when the Boolean or availability condition is true. |
| 136 | `                ProfileView(state: appState)` | Implements the surrounding declaration or view-builder expression. |
| 137 | `                    .zIndex(2)` | Applies a SwiftUI modifier to the preceding view. |
| 138 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 139 | `` | Blank line used to separate declarations or visual sections. |
| 140 | `            if avatarHeroVisible, avatarHeroFrame != .zero {` | Conditionally includes this branch when the Boolean or availability condition is true. |
| 141 | `                GeometryReader { proxy in` | Reads available geometry so the avatar overlay can be positioned in global coordinates. |
| 142 | `                    ProfileAvatar(` | Implements the surrounding declaration or view-builder expression. |
| 143 | `                        style: appState.profileAvatarStyle,` | Implements the surrounding declaration or view-builder expression. |
| 144 | `                        imageData: appState.profileAvatarData,` | Implements the surrounding declaration or view-builder expression. |
| 145 | `                        size: avatarHeroFrame.width` | Implements the surrounding declaration or view-builder expression. |
| 146 | `                    )` | Implements the surrounding declaration or view-builder expression. |
| 147 | `                    .frame(` | Constrains or expands the view’s size and alignment. |
| 148 | `                        width: avatarHeroFrame.width,` | Implements the surrounding declaration or view-builder expression. |
| 149 | `                        height: avatarHeroFrame.height` | Implements the surrounding declaration or view-builder expression. |
| 150 | `                    )` | Implements the surrounding declaration or view-builder expression. |
| 151 | `                    .position(` | Applies a SwiftUI modifier to the preceding view. |
| 152 | `                        x: avatarHeroFrame.midX - proxy.frame(in: .global).minX,` | Implements the surrounding declaration or view-builder expression. |
| 153 | `                        y: avatarHeroFrame.midY - proxy.frame(in: .global).minY` | Implements the surrounding declaration or view-builder expression. |
| 154 | `                    )` | Implements the surrounding declaration or view-builder expression. |
| 155 | `                    .allowsHitTesting(false)` | Applies a SwiftUI modifier to the preceding view. |
| 156 | `                }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 157 | `                .zIndex(10)` | Applies a SwiftUI modifier to the preceding view. |
| 158 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 159 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 160 | `        .environment(\.profileAvatarFrameReporter) { slot, frame in` | Applies a SwiftUI modifier to the preceding view. |
| 161 | `            switch slot {` | Selects behavior based on the value being switched over. |
| 162 | `            case .home:` | Defines or handles one case of the surrounding enumeration or switch. |
| 163 | `                homeAvatarFrame = frame` | Implements the surrounding declaration or view-builder expression. |
| 164 | `            case .profile:` | Defines or handles one case of the surrounding enumeration or switch. |
| 165 | `                profileAvatarFrame = frame` | Implements the surrounding declaration or view-builder expression. |
| 166 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 167 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 168 | `        .preferredColorScheme(.dark)` | Requests dark appearance for this view hierarchy. |
| 169 | `        // Two finger tap anywhere to toggle the quick screen jump bar` | Inline comment documenting the intent of the following code. |
| 170 | `        .onTapGesture(count: 2) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 171 | `            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {` | Animates state mutations performed inside the closure. |
| 172 | `                showScreenPicker.toggle()` | Implements the surrounding declaration or view-builder expression. |
| 173 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 174 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 175 | `        .onChange(of: appState.currentScreen) { oldScreen, newScreen in` | Observes screen changes using the iOS 17 two-parameter onChange overload. |
| 176 | `            guard oldScreen != newScreen else { return }` | Requires the condition to be true and exits early when it is not. |
| 177 | `` | Blank line used to separate declarations or visual sections. |
| 178 | `            let isProfileAvatarTransition = (oldScreen == .homeDashboard && newScreen == .profile) \|\|` | Declares an immutable local value. |
| 179 | `                (oldScreen == .profile && newScreen == .homeDashboard)` | Implements the surrounding declaration or view-builder expression. |
| 180 | `` | Blank line used to separate declarations or visual sections. |
| 181 | `            guard isProfileAvatarTransition else {` | Requires the condition to be true and exits early when it is not. |
| 182 | `                avatarHeroVisible = false` | Implements the surrounding declaration or view-builder expression. |
| 183 | `                appState.heroAvatarHiddenSlot = nil` | Implements the surrounding declaration or view-builder expression. |
| 184 | `                appState.isHeroAvatarTransitionActive = false` | Implements the surrounding declaration or view-builder expression. |
| 185 | `                return` | Implements the surrounding declaration or view-builder expression. |
| 186 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 187 | `` | Blank line used to separate declarations or visual sections. |
| 188 | `            let sourceSlot: ProfileAvatarSlot = oldScreen == .homeDashboard ? .home : .profile` | Declares an immutable local value. |
| 189 | `            let sourceFrame = sourceSlot == .home ? homeAvatarFrame : profileAvatarFrame` | Declares an immutable local value. |
| 190 | `            let destinationSlot: ProfileAvatarSlot = newScreen == .profile ? .profile : .home` | Declares an immutable local value. |
| 191 | `` | Blank line used to separate declarations or visual sections. |
| 192 | `            guard sourceFrame != .zero else { return }` | Requires the condition to be true and exits early when it is not. |
| 193 | `` | Blank line used to separate declarations or visual sections. |
| 194 | `            avatarHeroFrame = sourceFrame` | Implements the surrounding declaration or view-builder expression. |
| 195 | `            avatarHeroVisible = true` | Implements the surrounding declaration or view-builder expression. |
| 196 | `` | Blank line used to separate declarations or visual sections. |
| 197 | `            animateAvatarHero(to: destinationSlot)` | Implements the surrounding declaration or view-builder expression. |
| 198 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 199 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 200 | `` | Blank line used to separate declarations or visual sections. |
| 201 | `    private func animateAvatarHero(to destinationSlot: ProfileAvatarSlot) {` | Declares a helper function used by the surrounding type. |
| 202 | `        let targetFrame = destinationSlot == .home ? homeAvatarFrame : profileAvatarFrame` | Declares an immutable local value. |
| 203 | `` | Blank line used to separate declarations or visual sections. |
| 204 | `        if targetFrame == .zero {` | Conditionally includes this branch when the Boolean or availability condition is true. |
| 205 | `            DispatchQueue.main.asyncAfter(deadline: .now() + 0.016) {` | Schedules a retry on the main queue; this is valid but structured concurrency can be clearer for new code. |
| 206 | `                animateAvatarHero(to: destinationSlot)` | Implements the surrounding declaration or view-builder expression. |
| 207 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 208 | `            return` | Implements the surrounding declaration or view-builder expression. |
| 209 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 210 | `` | Blank line used to separate declarations or visual sections. |
| 211 | `        withAnimation(` | Animates state mutations performed inside the closure. |
| 212 | `            .spring(response: 0.52, dampingFraction: 0.82),` | Applies a SwiftUI modifier to the preceding view. |
| 213 | `            completionCriteria: .logicallyComplete` | Implements the surrounding declaration or view-builder expression. |
| 214 | `        ) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 215 | `            avatarHeroFrame = targetFrame` | Implements the surrounding declaration or view-builder expression. |
| 216 | `        } completion: {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 217 | `            avatarHeroVisible = false` | Implements the surrounding declaration or view-builder expression. |
| 218 | `            appState.heroAvatarHiddenSlot = nil` | Implements the surrounding declaration or view-builder expression. |
| 219 | `            appState.isHeroAvatarTransitionActive = false` | Implements the surrounding declaration or view-builder expression. |
| 220 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 221 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 222 | `    ` | Blank line used to separate declarations or visual sections. |
| 223 | `    // MARK: - Directional Slide with Depth Transition` | Section marker used to organize related declarations in Xcode. |
| 224 | `    private func slideTransition(for edge: Edge) -> AnyTransition {` | Declares a helper function used by the surrounding type. |
| 225 | `        let oppositeEdge: Edge = (edge == .trailing ? .leading : .trailing)` | Declares an immutable local value. |
| 226 | `        return .asymmetric(` | Returns a transition with different insertion and removal effects. |
| 227 | `            insertion: .move(edge: edge)` | Implements the surrounding declaration or view-builder expression. |
| 228 | `                .combined(with: .opacity)` | Applies a SwiftUI modifier to the preceding view. |
| 229 | `                .combined(with: .scale(scale: 0.96)),` | Applies a SwiftUI modifier to the preceding view. |
| 230 | `            removal: .move(edge: oppositeEdge)` | Implements the surrounding declaration or view-builder expression. |
| 231 | `                .combined(with: .opacity)` | Applies a SwiftUI modifier to the preceding view. |
| 232 | `                .combined(with: .scale(scale: 0.96))` | Applies a SwiftUI modifier to the preceding view. |
| 233 | `        )` | Implements the surrounding declaration or view-builder expression. |
| 234 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 235 | `    ` | Blank line used to separate declarations or visual sections. |
| 236 | `    // MARK: - Quick Screen Jump Bar` | Section marker used to organize related declarations in Xcode. |
| 237 | `    private var screenPickerOverlay: some View {` | Defines a private computed or stored property used only by the enclosing type. |
| 238 | `        VStack(spacing: 8) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 239 | `            HStack {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 240 | `                Text("Screen Jump (Tap to test):")` | Displays a localized or literal text label. |
| 241 | `                    .font(.system(size: 11, weight: .bold))` | Sets the text font, size, weight, and design. |
| 242 | `                    .foregroundStyle(.white.opacity(0.8))` | Sets the foreground color or style of the view. |
| 243 | `                ` | Blank line used to separate declarations or visual sections. |
| 244 | `                Spacer()` | Implements the surrounding declaration or view-builder expression. |
| 245 | `                ` | Blank line used to separate declarations or visual sections. |
| 246 | `                Button(action: {` | Creates an accessible interactive button and executes its action when activated. |
| 247 | `                    withAnimation { showScreenPicker = false }` | Animates state mutations performed inside the closure. |
| 248 | `                }) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 249 | `                    Image(systemName: "xmark.circle.fill")` | Displays an asset or SF Symbol image. |
| 250 | `                        .foregroundStyle(.white.opacity(0.7))` | Sets the foreground color or style of the view. |
| 251 | `                }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 252 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 253 | `            ` | Blank line used to separate declarations or visual sections. |
| 254 | `            ScrollView(.horizontal, showsIndicators: false) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 255 | `                HStack(spacing: 8) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 256 | `                    jumpButton(title: "Launch", screen: .launch)` | Implements the surrounding declaration or view-builder expression. |
| 257 | `                    jumpButton(title: "Login", screen: .login)` | Implements the surrounding declaration or view-builder expression. |
| 258 | `                    jumpButton(title: "Info 1", screen: .onboarding1)` | Implements the surrounding declaration or view-builder expression. |
| 259 | `                    jumpButton(title: "Info 2", screen: .onboarding2)` | Implements the surrounding declaration or view-builder expression. |
| 260 | `                    jumpButton(title: "Daily Goal", screen: .dailyGoal)` | Implements the surrounding declaration or view-builder expression. |
| 261 | `                    jumpButton(title: "Explore", screen: .exploreActivities)` | Implements the surrounding declaration or view-builder expression. |
| 262 | `                    jumpButton(title: "Home", screen: .homeDashboard)` | Implements the surrounding declaration or view-builder expression. |
| 263 | `                    jumpButton(title: "Pro Speech", screen: .prolongedSpeechIntro)` | Implements the surrounding declaration or view-builder expression. |
| 264 | `                    jumpButton(title: "Pic Intro", screen: .pictureDescriptionIntro)` | Implements the surrounding declaration or view-builder expression. |
| 265 | `                    jumpButton(title: "Dial Intro", screen: .dialSceneIntro)` | Implements the surrounding declaration or view-builder expression. |
| 266 | `                    jumpButton(title: "Narr Intro", screen: .narrationIntro)` | Implements the surrounding declaration or view-builder expression. |
| 267 | `                    jumpButton(title: "Dial Scene", screen: .dialScene)` | Implements the surrounding declaration or view-builder expression. |
| 268 | `                    jumpButton(title: "Difficulty", screen: .prolongedSpeechDifficulty)` | Implements the surrounding declaration or view-builder expression. |
| 269 | `                    jumpButton(title: "Practice", screen: .prolongedPractice)` | Implements the surrounding declaration or view-builder expression. |
| 270 | `                    jumpButton(title: "Analysis", screen: .prolongedAnalysis)` | Implements the surrounding declaration or view-builder expression. |
| 271 | `                }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 272 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 273 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 274 | `        .padding(12)` | Adds spacing around the view’s content. |
| 275 | `        .background(.ultraThinMaterial)` | Adds a background view behind the content. |
| 276 | `        .clipShape(RoundedRectangle(cornerRadius: 16))` | Clips the view to the supplied shape. |
| 277 | `        .padding(.horizontal, 16)` | Adds spacing around the view’s content. |
| 278 | `        .padding(.top, 48)` | Adds spacing around the view’s content. |
| 279 | `        .transition(.move(edge: .top).combined(with: .opacity))` | Defines how a view enters or leaves the hierarchy. |
| 280 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 281 | `    ` | Blank line used to separate declarations or visual sections. |
| 282 | `    private func jumpButton(title: String, screen: AppScreen) -> some View {` | Declares a helper function used by the surrounding type. |
| 283 | `        Button(action: {` | Creates an accessible interactive button and executes its action when activated. |
| 284 | `            appState.navigate(to: screen)` | Implements the surrounding declaration or view-builder expression. |
| 285 | `        }) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 286 | `            Text(title)` | Displays a localized or literal text label. |
| 287 | `                .font(.system(size: 12, weight: appState.currentScreen == screen ? .bold : .medium))` | Sets the text font, size, weight, and design. |
| 288 | `                .foregroundStyle(appState.currentScreen == screen ? .white : .white.opacity(0.7))` | Sets the foreground color or style of the view. |
| 289 | `                .padding(.horizontal, 10)` | Adds spacing around the view’s content. |
| 290 | `                .padding(.vertical, 6)` | Adds spacing around the view’s content. |
| 291 | `                .background(appState.currentScreen == screen ? StamerleeTheme.primaryBlue : Color.white.opacity(0.12))` | Adds a background view behind the content. |
| 292 | `                .clipShape(Capsule())` | Clips the view to the supplied shape. |
| 293 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 294 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 295 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 296 | `` | Blank line used to separate declarations or visual sections. |
| 297 | `#Preview {` | Declares a modern SwiftUI preview provider for Xcode. |
| 298 | `    ContentView()` | Implements the surrounding declaration or view-builder expression. |
| 299 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |

### `Stamerlee/ColorTheme.swift` (81 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports SwiftUI, including views, state, transitions, colors, and layout primitives. |
| 2 | `` | Blank line used to separate declarations or visual sections. |
| 3 | `// MARK: - App Color Theme` | Section marker used to organize related declarations in Xcode. |
| 4 | `/// Curated color palette matching the Stamerlee design system.` | Documentation comment describing the following public API. |
| 5 | `public enum StamerleeTheme {` | Defines a public enumeration for a closed set of app states or options. |
| 6 | `    /// Deep midnight background: #0B0C1E` | Documentation comment describing the following public API. |
| 7 | `    public static let backgroundDark = Color(red: 11 / 255, green: 12 / 255, blue: 30 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 8 | `    ` | Blank line used to separate declarations or visual sections. |
| 9 | `    /// Slightly lighter navy for cards or overlays` | Documentation comment describing the following public API. |
| 10 | `    public static let cardDark = Color(red: 19 / 255, green: 21 / 255, blue: 44 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 11 | `    ` | Blank line used to separate declarations or visual sections. |
| 12 | `    /// Light periwinkle / lavender sheet background: #ECEFF9` | Documentation comment describing the following public API. |
| 13 | `    public static let sheetBackground = Color(red: 236 / 255, green: 239 / 255, blue: 249 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 14 | `    ` | Blank line used to separate declarations or visual sections. |
| 15 | `    /// Pure white for cards and buttons` | Documentation comment describing the following public API. |
| 16 | `    public static let cardLight = Color.white` | Implements the surrounding declaration or view-builder expression. |
| 17 | `    ` | Blank line used to separate declarations or visual sections. |
| 18 | `    /// Vibrant primary brand purple: #8b70f5` | Documentation comment describing the following public API. |
| 19 | `    public static let primaryPurple = Color(red: 139 / 255, green: 112 / 255, blue: 245 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 20 | `    public static let primaryPurpleDark = Color(red: 118 / 255, green: 90 / 255, blue: 228 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 21 | `    ` | Blank line used to separate declarations or visual sections. |
| 22 | `    /// Vibrant primary brand purple used for all primary action buttons, highlights, and interactive states: #8b70f5` | Documentation comment describing the following public API. |
| 23 | `    public static let primaryBlue = Color(red: 139 / 255, green: 112 / 255, blue: 245 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 24 | `    ` | Blank line used to separate declarations or visual sections. |
| 25 | `    /// Deep interactive purple for pressed states` | Documentation comment describing the following public API. |
| 26 | `    public static let primaryBlueDark = Color(red: 118 / 255, green: 90 / 255, blue: 228 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 27 | `    ` | Blank line used to separate declarations or visual sections. |
| 28 | `    /// Accent purple gradient for headline highlights` | Documentation comment describing the following public API. |
| 29 | `    public static let accentPurpleLight = Color(red: 192 / 255, green: 132 / 255, blue: 252 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 30 | `    public static let accentPurple = Color(red: 167 / 255, green: 139 / 255, blue: 250 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 31 | `    ` | Blank line used to separate declarations or visual sections. |
| 32 | `    /// Text colors` | Documentation comment describing the following public API. |
| 33 | `    public static let textPrimaryDark = Color.white` | Implements the surrounding declaration or view-builder expression. |
| 34 | `    public static let textSecondaryDark = Color(red: 160 / 255, green: 168 / 255, blue: 188 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 35 | `    ` | Blank line used to separate declarations or visual sections. |
| 36 | `    public static let textPrimaryLight = Color(red: 22 / 255, green: 24 / 255, blue: 35 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 37 | `    public static let textSecondaryLight = Color(red: 110 / 255, green: 115 / 255, blue: 132 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 38 | `    ` | Blank line used to separate declarations or visual sections. |
| 39 | `    /// Border & separator colors` | Documentation comment describing the following public API. |
| 40 | `    public static let dividerLight = Color(red: 218 / 255, green: 222 / 255, blue: 235 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 41 | `    public static let subtleBorder = Color.white.opacity(0.12)` | Implements the surrounding declaration or view-builder expression. |
| 42 | `    ` | Blank line used to separate declarations or visual sections. |
| 43 | `    /// Illustration accents` | Documentation comment describing the following public API. |
| 44 | `    public static let illustrationLilac = Color(red: 202 / 255, green: 206 / 255, blue: 244 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 45 | `    public static let illustrationPurple = Color(red: 147 / 255, green: 140 / 255, blue: 220 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 46 | `    public static let illustrationCardBg = Color(red: 24 / 255, green: 30 / 255, blue: 68 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 47 | `` | Blank line used to separate declarations or visual sections. |
| 48 | `    /// Profile card color shared with the homepage's light lavender cards.` | Documentation comment describing the following public API. |
| 49 | `    public static let profileCard = Color(red: 238 / 255, green: 240 / 255, blue: 250 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 50 | `    public static let profileHeaderBase = Color(red: 13 / 255, green: 14 / 255, blue: 32 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 51 | `    public static let profileHeaderHighlight = Color(red: 29 / 255, green: 31 / 255, blue: 60 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 52 | `    public static let profileArcDark = Color(red: 7 / 255, green: 8 / 255, blue: 22 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 53 | `    public static let profileAvatarDark = Color(red: 43 / 255, green: 45 / 255, blue: 66 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 54 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 55 | `` | Blank line used to separate declarations or visual sections. |
| 56 | `// MARK: - Color Hex Initializer Extension` | Section marker used to organize related declarations in Xcode. |
| 57 | `extension Color {` | Adds functionality to an existing type without changing its original declaration. |
| 58 | `    init(hex: String) {` | Initializes the type and assigns its configurable inputs. |
| 59 | `        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)` | Declares an immutable local value. |
| 60 | `        var int: UInt64 = 0` | Declares a mutable local or stored value. |
| 61 | `        Scanner(string: hex).scanHexInt64(&int)` | Parses hexadecimal color text; the Boolean result is ignored, so malformed input silently falls back to the default branch. |
| 62 | `        let a, r, g, b: UInt64` | Declares an immutable local value. |
| 63 | `        switch hex.count {` | Selects behavior based on the value being switched over. |
| 64 | `        case 3: // RGB (12-bit)` | Defines or handles one case of the surrounding enumeration or switch. |
| 65 | `            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)` | Implements the surrounding declaration or view-builder expression. |
| 66 | `        case 6: // RGB (24-bit)` | Defines or handles one case of the surrounding enumeration or switch. |
| 67 | `            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)` | Implements the surrounding declaration or view-builder expression. |
| 68 | `        case 8: // ARGB (32-bit)` | Defines or handles one case of the surrounding enumeration or switch. |
| 69 | `            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)` | Implements the surrounding declaration or view-builder expression. |
| 70 | `        default:` | Handles unsupported input or an unmatched switch case. |
| 71 | `            (a, r, g, b) = (1, 1, 1, 0)` | Implements the surrounding declaration or view-builder expression. |
| 72 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 73 | `        self.init(` | Implements the surrounding declaration or view-builder expression. |
| 74 | `            .sRGB,` | Applies a SwiftUI modifier to the preceding view. |
| 75 | `            red: Double(r) / 255,` | Implements the surrounding declaration or view-builder expression. |
| 76 | `            green: Double(g) / 255,` | Implements the surrounding declaration or view-builder expression. |
| 77 | `            blue: Double(b) / 255,` | Implements the surrounding declaration or view-builder expression. |
| 78 | `            opacity: Double(a) / 255` | Implements the surrounding declaration or view-builder expression. |
| 79 | `        )` | Implements the surrounding declaration or view-builder expression. |
| 80 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 81 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |

### `Stamerlee/Components.swift` (879 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports SwiftUI, including views, state, transitions, colors, and layout primitives. |
| 2 | `` | Blank line used to separate declarations or visual sections. |
| 3 | `// MARK: - Haptic Button Style` | Section marker used to organize related declarations in Xcode. |
| 4 | `/// Native button style that plays a haptic when the button is pressed and optionally` | Documentation comment describing the following public API. |
| 5 | `/// scales the label while pressed. Uses \`configuration.isPressed\` and \`.sensoryFeedback\`` | Documentation comment describing the following public API. |
| 6 | `/// instead of UIKit feedback generators or custom drag gestures.` | Documentation comment describing the following public API. |
| 7 | `public struct HapticButtonStyle: ButtonStyle {` | Defines a public reusable Swift type, usually a SwiftUI view or button style. |
| 8 | `    public var weight: SensoryFeedback.Weight` | Declares a stored property that holds configuration or view state. |
| 9 | `    public var pressedScale: CGFloat` | Declares a stored property that holds configuration or view state. |
| 10 | `` | Blank line used to separate declarations or visual sections. |
| 11 | `    public init(weight: SensoryFeedback.Weight = .light, pressedScale: CGFloat = 1) {` | Initializes the type and assigns its configurable inputs. |
| 12 | `        self.weight = weight` | Implements the surrounding declaration or view-builder expression. |
| 13 | `        self.pressedScale = pressedScale` | Implements the surrounding declaration or view-builder expression. |
| 14 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 15 | `` | Blank line used to separate declarations or visual sections. |
| 16 | `    public func makeBody(configuration: Configuration) -> some View {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 17 | `        configuration.label` | Implements the surrounding declaration or view-builder expression. |
| 18 | `            .scaleEffect(configuration.isPressed ? pressedScale : 1)` | Applies a SwiftUI modifier to the preceding view. |
| 19 | `            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)` | Attaches an animation that responds to changes in the supplied value. |
| 20 | `            .sensoryFeedback(trigger: configuration.isPressed) { _, isPressed in` | Adds system haptic feedback driven by a state trigger. |
| 21 | `                isPressed ? .impact(weight: weight) : nil` | Implements the surrounding declaration or view-builder expression. |
| 22 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 23 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 24 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 25 | `` | Blank line used to separate declarations or visual sections. |
| 26 | `public extension ButtonStyle where Self == HapticButtonStyle {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 27 | `    /// Light haptic on press, no scaling (drop-in replacement for \`.plain\`).` | Documentation comment describing the following public API. |
| 28 | `    static var haptic: HapticButtonStyle { HapticButtonStyle() }` | Implements the surrounding declaration or view-builder expression. |
| 29 | `` | Blank line used to separate declarations or visual sections. |
| 30 | `    static func haptic(weight: SensoryFeedback.Weight = .light, pressedScale: CGFloat = 1) -> HapticButtonStyle {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 31 | `        HapticButtonStyle(weight: weight, pressedScale: pressedScale)` | Implements the surrounding declaration or view-builder expression. |
| 32 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 33 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 34 | `` | Blank line used to separate declarations or visual sections. |
| 35 | `// MARK: - Primary Action Button` | Section marker used to organize related declarations in Xcode. |
| 36 | `/// Vibrant blue pill button used for "Begin" and "Continue" actions across screens.` | Documentation comment describing the following public API. |
| 37 | `public struct PrimaryActionButton: View {` | Defines a public reusable Swift type, usually a SwiftUI view or button style. |
| 38 | `    public let title: String` | Declares a stored property that holds configuration or view state. |
| 39 | `    public let icon: String?` | Declares a stored property that holds configuration or view state. |
| 40 | `    public let isEnabled: Bool` | Declares a stored property that holds configuration or view state. |
| 41 | `    public let isLoading: Bool` | Declares a stored property that holds configuration or view state. |
| 42 | `    public let compact: Bool` | Declares a stored property that holds configuration or view state. |
| 43 | `    public let action: () -> Void` | Declares a stored property that holds configuration or view state. |
| 44 | `` | Blank line used to separate declarations or visual sections. |
| 45 | `    public init(` | Initializes the type and assigns its configurable inputs. |
| 46 | `        title: String,` | Implements the surrounding declaration or view-builder expression. |
| 47 | `        icon: String? = nil,` | Implements the surrounding declaration or view-builder expression. |
| 48 | `        isEnabled: Bool = true,` | Implements the surrounding declaration or view-builder expression. |
| 49 | `        isLoading: Bool = false,` | Implements the surrounding declaration or view-builder expression. |
| 50 | `        compact: Bool = false,` | Implements the surrounding declaration or view-builder expression. |
| 51 | `        action: @escaping () -> Void` | Implements the surrounding declaration or view-builder expression. |
| 52 | `    ) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 53 | `        self.title = title` | Implements the surrounding declaration or view-builder expression. |
| 54 | `        self.icon = icon` | Implements the surrounding declaration or view-builder expression. |
| 55 | `        self.isEnabled = isEnabled` | Implements the surrounding declaration or view-builder expression. |
| 56 | `        self.isLoading = isLoading` | Implements the surrounding declaration or view-builder expression. |
| 57 | `        self.compact = compact` | Implements the surrounding declaration or view-builder expression. |
| 58 | `        self.action = action` | Implements the surrounding declaration or view-builder expression. |
| 59 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 60 | `` | Blank line used to separate declarations or visual sections. |
| 61 | `    public var body: some View {` | Defines the SwiftUI view hierarchy rendered by this type. |
| 62 | `        if #available(iOS 26.0, *) {` | Conditionally compiles/runs the newer glass-button path for iOS 26 and later. |
| 63 | `            Button(action: action) { label }` | Creates an accessible interactive button and executes its action when activated. |
| 64 | `                .buttonStyle(.glass(.regular.tint(StamerleeTheme.primaryBlue).interactive()))` | Uses the glass button style available on the stated deployment target branch. |
| 65 | `                .buttonBorderShape(.capsule)` | Applies a SwiftUI modifier to the preceding view. |
| 66 | `                .frame(maxWidth: .infinity)` | Constrains or expands the view’s size and alignment. |
| 67 | `                .disabled(!isEnabled \|\| isLoading)` | Applies a SwiftUI modifier to the preceding view. |
| 68 | `        } else {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 69 | `            Button(action: action) { label }` | Creates an accessible interactive button and executes its action when activated. |
| 70 | `                .buttonStyle(.haptic(weight: .medium, pressedScale: 0.97))` | Applies a SwiftUI modifier to the preceding view. |
| 71 | `                .disabled(!isEnabled \|\| isLoading)` | Applies a SwiftUI modifier to the preceding view. |
| 72 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 73 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 74 | `` | Blank line used to separate declarations or visual sections. |
| 75 | `    private var label: some View {` | Defines a private computed or stored property used only by the enclosing type. |
| 76 | `        HStack(spacing: compact ? 6 : 8) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 77 | `            if isLoading {` | Conditionally includes this branch when the Boolean or availability condition is true. |
| 78 | `                ProgressView()` | Implements the surrounding declaration or view-builder expression. |
| 79 | `                    .progressViewStyle(CircularProgressViewStyle(tint: .white))` | Applies a circular progress indicator with a white tint; the style is still supported, though newer tint APIs may be preferable. |
| 80 | `                    .scaleEffect(compact ? 0.8 : 0.9)` | Applies a SwiftUI modifier to the preceding view. |
| 81 | `            } else {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 82 | `                if let icon = icon {` | Conditionally includes this branch when the Boolean or availability condition is true. |
| 83 | `                    Image(systemName: icon)` | Displays an asset or SF Symbol image. |
| 84 | `                        .font(.system(size: compact ? 13 : 16, weight: .bold))` | Sets the text font, size, weight, and design. |
| 85 | `                }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 86 | `                Text(title)` | Displays a localized or literal text label. |
| 87 | `                    .font(.system(size: compact ? 15 : 16, weight: .semibold, design: .rounded))` | Sets the text font, size, weight, and design. |
| 88 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 89 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 90 | `        .foregroundStyle(.white)` | Sets the foreground color or style of the view. |
| 91 | `        .frame(maxWidth: .infinity, minHeight: compact ? 44 : 52)` | Constrains or expands the view’s size and alignment. |
| 92 | `        .background {` | Adds a background view behind the content. |
| 93 | `            if #available(iOS 26.0, *) {` | Conditionally compiles/runs the newer glass-button path for iOS 26 and later. |
| 94 | `                // glass style owns the background` | Inline comment documenting the intent of the following code. |
| 95 | `                Color.clear` | Implements the surrounding declaration or view-builder expression. |
| 96 | `            } else {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 97 | `                Group {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 98 | `                    if isEnabled {` | Conditionally includes this branch when the Boolean or availability condition is true. |
| 99 | `                        StamerleeTheme.primaryBlue` | Implements the surrounding declaration or view-builder expression. |
| 100 | `                    } else {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 101 | `                        StamerleeTheme.primaryBlue.opacity(0.4)` | Implements the surrounding declaration or view-builder expression. |
| 102 | `                    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 103 | `                }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 104 | `                .clipShape(Capsule())` | Clips the view to the supplied shape. |
| 105 | `                .shadow(color: isEnabled ? StamerleeTheme.primaryBlue.opacity(0.3) : .clear, radius: 10, x: 0, y: 5)` | Adds a drop shadow to improve visual separation. |
| 106 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 107 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 108 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 109 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 110 | `` | Blank line used to separate declarations or visual sections. |
| 111 | `// MARK: - Social Auth Button Style` | Section marker used to organize related declarations in Xcode. |
| 112 | `public enum SocialAuthType {` | Defines a public enumeration for a closed set of app states or options. |
| 113 | `    case apple` | Defines or handles one case of the surrounding enumeration or switch. |
| 114 | `    case google` | Defines or handles one case of the surrounding enumeration or switch. |
| 115 | `    case email` | Defines or handles one case of the surrounding enumeration or switch. |
| 116 | `    ` | Blank line used to separate declarations or visual sections. |
| 117 | `    var title: String {` | Declares a mutable local or stored value. |
| 118 | `        switch self {` | Selects behavior based on the value being switched over. |
| 119 | `        case .apple: return "Continue with Apple"` | Defines or handles one case of the surrounding enumeration or switch. |
| 120 | `        case .google: return "Continue with Google"` | Defines or handles one case of the surrounding enumeration or switch. |
| 121 | `        case .email: return "Continue with Email"` | Defines or handles one case of the surrounding enumeration or switch. |
| 122 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 123 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 124 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 125 | `` | Blank line used to separate declarations or visual sections. |
| 126 | `// MARK: - Social Auth Button` | Section marker used to organize related declarations in Xcode. |
| 127 | `public struct SocialAuthRow: View {` | Defines a public reusable Swift type, usually a SwiftUI view or button style. |
| 128 | `    public let type: SocialAuthType` | Declares a stored property that holds configuration or view state. |
| 129 | `    public let action: () -> Void` | Declares a stored property that holds configuration or view state. |
| 130 | `` | Blank line used to separate declarations or visual sections. |
| 131 | `    public init(type: SocialAuthType, action: @escaping () -> Void) {` | Initializes the type and assigns its configurable inputs. |
| 132 | `        self.type = type` | Implements the surrounding declaration or view-builder expression. |
| 133 | `        self.action = action` | Implements the surrounding declaration or view-builder expression. |
| 134 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 135 | `` | Blank line used to separate declarations or visual sections. |
| 136 | `    public var body: some View {` | Defines the SwiftUI view hierarchy rendered by this type. |
| 137 | `        if #available(iOS 26.0, *) {` | Conditionally compiles/runs the newer glass-button path for iOS 26 and later. |
| 138 | `            Button(action: action) { rowContent }` | Creates an accessible interactive button and executes its action when activated. |
| 139 | `                .buttonStyle(.glass(.regular.tint(StamerleeTheme.cardLight).interactive()))` | Uses the glass button style available on the stated deployment target branch. |
| 140 | `                .buttonBorderShape(.roundedRectangle(radius: 14))` | Applies a SwiftUI modifier to the preceding view. |
| 141 | `                .frame(maxWidth: .infinity)` | Constrains or expands the view’s size and alignment. |
| 142 | `        } else {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 143 | `            Button(action: action) { rowContent }` | Creates an accessible interactive button and executes its action when activated. |
| 144 | `                .buttonStyle(.haptic(pressedScale: 0.98))` | Applies a SwiftUI modifier to the preceding view. |
| 145 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 146 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 147 | `` | Blank line used to separate declarations or visual sections. |
| 148 | `    private var rowContent: some View {` | Defines a private computed or stored property used only by the enclosing type. |
| 149 | `        HStack(spacing: 14) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 150 | `            // Leading Icon` | Inline comment documenting the intent of the following code. |
| 151 | `            iconView` | Implements the surrounding declaration or view-builder expression. |
| 152 | `                .frame(width: 24, height: 24)` | Constrains or expands the view’s size and alignment. |
| 153 | `` | Blank line used to separate declarations or visual sections. |
| 154 | `            // Title` | Inline comment documenting the intent of the following code. |
| 155 | `            Text(type.title)` | Displays a localized or literal text label. |
| 156 | `                .font(.system(size: 15, weight: .medium, design: .rounded))` | Sets the text font, size, weight, and design. |
| 157 | `                .foregroundStyle(StamerleeTheme.textPrimaryLight)` | Sets the foreground color or style of the view. |
| 158 | `` | Blank line used to separate declarations or visual sections. |
| 159 | `            Spacer()` | Implements the surrounding declaration or view-builder expression. |
| 160 | `` | Blank line used to separate declarations or visual sections. |
| 161 | `            // Trailing Chevron` | Inline comment documenting the intent of the following code. |
| 162 | `            Image(systemName: "chevron.right")` | Displays an asset or SF Symbol image. |
| 163 | `                .font(.system(size: 13, weight: .semibold))` | Sets the text font, size, weight, and design. |
| 164 | `                .foregroundStyle(Color.gray.opacity(0.6))` | Sets the foreground color or style of the view. |
| 165 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 166 | `        .padding(.horizontal, 18)` | Adds spacing around the view’s content. |
| 167 | `        .frame(maxWidth: .infinity, minHeight: 65, alignment: .leading)` | Constrains or expands the view’s size and alignment. |
| 168 | `        .background {` | Adds a background view behind the content. |
| 169 | `            if #available(iOS 26.0, *) {` | Conditionally compiles/runs the newer glass-button path for iOS 26 and later. |
| 170 | `                Color.clear` | Implements the surrounding declaration or view-builder expression. |
| 171 | `            } else {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 172 | `                RoundedRectangle(cornerRadius: 14, style: .continuous)` | Implements the surrounding declaration or view-builder expression. |
| 173 | `                    .fill(StamerleeTheme.cardLight)` | Applies a SwiftUI modifier to the preceding view. |
| 174 | `                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)` | Adds a drop shadow to improve visual separation. |
| 175 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 176 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 177 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 178 | `    ` | Blank line used to separate declarations or visual sections. |
| 179 | `    @ViewBuilder` | Enables conditional and multi-view result-builder syntax for a view-producing property or function. |
| 180 | `    private var iconView: some View {` | Defines a private computed or stored property used only by the enclosing type. |
| 181 | `        switch type {` | Selects behavior based on the value being switched over. |
| 182 | `        case .apple:` | Defines or handles one case of the surrounding enumeration or switch. |
| 183 | `            Image(systemName: "applelogo")` | Displays an asset or SF Symbol image. |
| 184 | `                .font(.system(size: 20, weight: .semibold))` | Sets the text font, size, weight, and design. |
| 185 | `                .foregroundStyle(.black)` | Sets the foreground color or style of the view. |
| 186 | `        case .google:` | Defines or handles one case of the surrounding enumeration or switch. |
| 187 | `            Image("googlesvg")` | Displays an asset or SF Symbol image. |
| 188 | `                .resizable()` | Applies a SwiftUI modifier to the preceding view. |
| 189 | `                .frame(width: 20, height: 20)` | Constrains or expands the view’s size and alignment. |
| 190 | `    ` | Blank line used to separate declarations or visual sections. |
| 191 | `            ` | Blank line used to separate declarations or visual sections. |
| 192 | `        case .email:` | Defines or handles one case of the surrounding enumeration or switch. |
| 193 | `            Image(systemName: "envelope")` | Displays an asset or SF Symbol image. |
| 194 | `                .font(.system(size: 17, weight: .semibold))` | Sets the text font, size, weight, and design. |
| 195 | `                .foregroundStyle(StamerleeTheme.primaryBlue)` | Sets the foreground color or style of the view. |
| 196 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 197 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 198 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 199 | `` | Blank line used to separate declarations or visual sections. |
| 200 | `// MARK: - Back Navigation Button` | Section marker used to organize related declarations in Xcode. |
| 201 | `public struct BackNavButton: View {` | Defines a public reusable Swift type, usually a SwiftUI view or button style. |
| 202 | `    public let action: () -> Void` | Declares a stored property that holds configuration or view state. |
| 203 | `    ` | Blank line used to separate declarations or visual sections. |
| 204 | `    public init(action: @escaping () -> Void) {` | Initializes the type and assigns its configurable inputs. |
| 205 | `        self.action = action` | Implements the surrounding declaration or view-builder expression. |
| 206 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 207 | `    ` | Blank line used to separate declarations or visual sections. |
| 208 | `    public var body: some View {` | Defines the SwiftUI view hierarchy rendered by this type. |
| 209 | `        Button(action: action) {` | Creates an accessible interactive button and executes its action when activated. |
| 210 | `            ZStack {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 211 | `                Circle()` | Implements the surrounding declaration or view-builder expression. |
| 212 | `                    .fill(Color.white.opacity(0.14))` | Applies a SwiftUI modifier to the preceding view. |
| 213 | `                    .frame(width: 38, height: 38)` | Constrains or expands the view’s size and alignment. |
| 214 | `                ` | Blank line used to separate declarations or visual sections. |
| 215 | `                Image(systemName: "chevron.left")` | Displays an asset or SF Symbol image. |
| 216 | `                    .font(.system(size: 15, weight: .bold))` | Sets the text font, size, weight, and design. |
| 217 | `                    .foregroundStyle(.white)` | Sets the foreground color or style of the view. |
| 218 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 219 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 220 | `        .buttonStyle(.haptic)` | Applies a SwiftUI modifier to the preceding view. |
| 221 | `        .accessibilityLabel("Go Back")` | Provides or adjusts accessibility semantics for assistive technologies. |
| 222 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 223 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 224 | `` | Blank line used to separate declarations or visual sections. |
| 225 | `// MARK: - Option Selection Row (Radio / Checkmark)` | Section marker used to organize related declarations in Xcode. |
| 226 | `public struct SoundOption: Hashable {` | Defines a public reusable Swift type, usually a SwiftUI view or button style. |
| 227 | `    public let title: String` | Declares a stored property that holds configuration or view state. |
| 228 | `    public let subtitle: String?` | Declares a stored property that holds configuration or view state. |
| 229 | `` | Blank line used to separate declarations or visual sections. |
| 230 | `    public init(title: String, subtitle: String? = nil) {` | Initializes the type and assigns its configurable inputs. |
| 231 | `        self.title = title` | Implements the surrounding declaration or view-builder expression. |
| 232 | `        self.subtitle = subtitle` | Implements the surrounding declaration or view-builder expression. |
| 233 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 234 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 235 | `` | Blank line used to separate declarations or visual sections. |
| 236 | `public struct OptionSelectRow: View {` | Defines a public reusable Swift type, usually a SwiftUI view or button style. |
| 237 | `    public let option: SoundOption` | Declares a stored property that holds configuration or view state. |
| 238 | `    public let isSelected: Bool` | Declares a stored property that holds configuration or view state. |
| 239 | `    public let onSelect: () -> Void` | Declares a stored property that holds configuration or view state. |
| 240 | `    ` | Blank line used to separate declarations or visual sections. |
| 241 | `    public init(option: SoundOption, isSelected: Bool, onSelect: @escaping () -> Void) {` | Initializes the type and assigns its configurable inputs. |
| 242 | `        self.option = option` | Implements the surrounding declaration or view-builder expression. |
| 243 | `        self.isSelected = isSelected` | Implements the surrounding declaration or view-builder expression. |
| 244 | `        self.onSelect = onSelect` | Implements the surrounding declaration or view-builder expression. |
| 245 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 246 | `` | Blank line used to separate declarations or visual sections. |
| 247 | `    public var body: some View {` | Defines the SwiftUI view hierarchy rendered by this type. |
| 248 | `        Button(action: {` | Creates an accessible interactive button and executes its action when activated. |
| 249 | `            onSelect()` | Implements the surrounding declaration or view-builder expression. |
| 250 | `        }) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 251 | `            HStack(spacing: 12) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 252 | `                // Title and optional example subtitle` | Inline comment documenting the intent of the following code. |
| 253 | `                VStack(alignment: .leading, spacing: 3) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 254 | `                    if let subtitle = option.subtitle {` | Conditionally includes this branch when the Boolean or availability condition is true. |
| 255 | `                        HStack(spacing: 4) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 256 | `                            Text(option.title)` | Displays a localized or literal text label. |
| 257 | `                                .font(.system(size: 15, weight: .semibold, design: .rounded))` | Sets the text font, size, weight, and design. |
| 258 | `                                .foregroundStyle(StamerleeTheme.textPrimaryLight)` | Sets the foreground color or style of the view. |
| 259 | `                            ` | Blank line used to separate declarations or visual sections. |
| 260 | `                            Text("(\(subtitle))")` | Displays a localized or literal text label. |
| 261 | `                                .font(.system(size: 14, weight: .regular, design: .rounded))` | Sets the text font, size, weight, and design. |
| 262 | `                                .foregroundStyle(StamerleeTheme.textSecondaryLight)` | Sets the foreground color or style of the view. |
| 263 | `                        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 264 | `                    } else {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 265 | `                        Text(option.title)` | Displays a localized or literal text label. |
| 266 | `                            .font(.system(size: 15, weight: .medium, design: .rounded))` | Sets the text font, size, weight, and design. |
| 267 | `                            .foregroundStyle(StamerleeTheme.textPrimaryLight)` | Sets the foreground color or style of the view. |
| 268 | `                    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 269 | `                }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 270 | `                ` | Blank line used to separate declarations or visual sections. |
| 271 | `                Spacer()` | Implements the surrounding declaration or view-builder expression. |
| 272 | `                ` | Blank line used to separate declarations or visual sections. |
| 273 | `                // Custom Radio / Checked Indicator` | Inline comment documenting the intent of the following code. |
| 274 | `                ZStack {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 275 | `                    if isSelected {` | Conditionally includes this branch when the Boolean or availability condition is true. |
| 276 | `                        Circle()` | Implements the surrounding declaration or view-builder expression. |
| 277 | `                            .fill(StamerleeTheme.primaryBlue)` | Applies a SwiftUI modifier to the preceding view. |
| 278 | `                            .frame(width: 22, height: 22)` | Constrains or expands the view’s size and alignment. |
| 279 | `                        ` | Blank line used to separate declarations or visual sections. |
| 280 | `                        Image(systemName: "checkmark")` | Displays an asset or SF Symbol image. |
| 281 | `                            .font(.system(size: 11, weight: .bold))` | Sets the text font, size, weight, and design. |
| 282 | `                            .foregroundStyle(.white)` | Sets the foreground color or style of the view. |
| 283 | `                            .transition(.scale.combined(with: .opacity))` | Defines how a view enters or leaves the hierarchy. |
| 284 | `                    } else {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 285 | `                        Circle()` | Implements the surrounding declaration or view-builder expression. |
| 286 | `                            .stroke(Color(red: 210 / 255, green: 215 / 255, blue: 228 / 255), lineWidth: 1.8)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 287 | `                            .frame(width: 22, height: 22)` | Constrains or expands the view’s size and alignment. |
| 288 | `                    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 289 | `                }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 290 | `                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)` | Attaches an animation that responds to changes in the supplied value. |
| 291 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 292 | `            .padding(.vertical, 14)` | Adds spacing around the view’s content. |
| 293 | `            .padding(.horizontal, 16)` | Adds spacing around the view’s content. |
| 294 | `            .background(` | Adds a background view behind the content. |
| 295 | `                RoundedRectangle(cornerRadius: 12, style: .continuous)` | Implements the surrounding declaration or view-builder expression. |
| 296 | `                    .fill(isSelected ? StamerleeTheme.primaryBlue.opacity(0.06) : Color.clear)` | Applies a SwiftUI modifier to the preceding view. |
| 297 | `            )` | Implements the surrounding declaration or view-builder expression. |
| 298 | `            .contentShape(Rectangle())` | Applies a SwiftUI modifier to the preceding view. |
| 299 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 300 | `        .buttonStyle(.haptic)` | Applies a SwiftUI modifier to the preceding view. |
| 301 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 302 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 303 | `` | Blank line used to separate declarations or visual sections. |
| 304 | `// MARK: - Universal Difficulty Card` | Section marker used to organize related declarations in Xcode. |
| 305 | `public struct DifficultyCard: View {` | Defines a public reusable Swift type, usually a SwiftUI view or button style. |
| 306 | `    public let title: String` | Declares a stored property that holds configuration or view state. |
| 307 | `    public let isLocked: Bool` | Declares a stored property that holds configuration or view state. |
| 308 | `    public let isCompleted: Bool` | Declares a stored property that holds configuration or view state. |
| 309 | `    public let action: () -> Void` | Declares a stored property that holds configuration or view state. |
| 310 | `` | Blank line used to separate declarations or visual sections. |
| 311 | `    public init(` | Initializes the type and assigns its configurable inputs. |
| 312 | `        title: String,` | Implements the surrounding declaration or view-builder expression. |
| 313 | `        isLocked: Bool,` | Implements the surrounding declaration or view-builder expression. |
| 314 | `        isCompleted: Bool,` | Implements the surrounding declaration or view-builder expression. |
| 315 | `        action: @escaping () -> Void` | Implements the surrounding declaration or view-builder expression. |
| 316 | `    ) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 317 | `        self.title = title` | Implements the surrounding declaration or view-builder expression. |
| 318 | `        self.isLocked = isLocked` | Implements the surrounding declaration or view-builder expression. |
| 319 | `        self.isCompleted = isCompleted` | Implements the surrounding declaration or view-builder expression. |
| 320 | `        self.action = action` | Implements the surrounding declaration or view-builder expression. |
| 321 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 322 | `` | Blank line used to separate declarations or visual sections. |
| 323 | `    public var body: some View {` | Defines the SwiftUI view hierarchy rendered by this type. |
| 324 | `        Button {` | Creates an accessible interactive button and executes its action when activated. |
| 325 | `            action()` | Implements the surrounding declaration or view-builder expression. |
| 326 | `        } label: {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 327 | `            ZStack {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 328 | `                Text(title)` | Displays a localized or literal text label. |
| 329 | `                    .font(.system(size: 16, weight: .bold, design: .rounded))` | Sets the text font, size, weight, and design. |
| 330 | `                    .foregroundStyle(StamerleeTheme.textPrimaryLight)` | Sets the foreground color or style of the view. |
| 331 | `` | Blank line used to separate declarations or visual sections. |
| 332 | `                HStack {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 333 | `                    badge` | Implements the surrounding declaration or view-builder expression. |
| 334 | `                    Spacer()` | Implements the surrounding declaration or view-builder expression. |
| 335 | `                    if isCompleted {` | Conditionally includes this branch when the Boolean or availability condition is true. |
| 336 | `                        Image(systemName: "checkmark.circle.fill")` | Displays an asset or SF Symbol image. |
| 337 | `                            .font(.system(size: 18, weight: .semibold))` | Sets the text font, size, weight, and design. |
| 338 | `                            .foregroundStyle(StamerleeTheme.primaryBlue)` | Sets the foreground color or style of the view. |
| 339 | `                            .frame(width: 30, alignment: .trailing)` | Constrains or expands the view’s size and alignment. |
| 340 | `                    } else if !isLocked {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 341 | `                        Image(systemName: "chevron.right")` | Displays an asset or SF Symbol image. |
| 342 | `                            .font(.system(size: 14, weight: .semibold))` | Sets the text font, size, weight, and design. |
| 343 | `                            .foregroundStyle(.gray.opacity(0.5))` | Sets the foreground color or style of the view. |
| 344 | `                            .frame(width: 30, alignment: .trailing)` | Constrains or expands the view’s size and alignment. |
| 345 | `                    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 346 | `                }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 347 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 348 | `            .padding(.horizontal, 14)` | Adds spacing around the view’s content. |
| 349 | `            .frame(height: 72)` | Constrains or expands the view’s size and alignment. |
| 350 | `            .background(Color(red: 238 / 255, green: 240 / 255, blue: 250 / 255))` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 351 | `            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))` | Clips the view to the supplied shape. |
| 352 | `            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)` | Adds a drop shadow to improve visual separation. |
| 353 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 354 | `        .buttonStyle(.haptic)` | Applies a SwiftUI modifier to the preceding view. |
| 355 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 356 | `` | Blank line used to separate declarations or visual sections. |
| 357 | `    @ViewBuilder` | Enables conditional and multi-view result-builder syntax for a view-producing property or function. |
| 358 | `    private var badge: some View {` | Defines a private computed or stored property used only by the enclosing type. |
| 359 | `        if isLocked {` | Conditionally includes this branch when the Boolean or availability condition is true. |
| 360 | `            Image(systemName: "lock.fill")` | Displays an asset or SF Symbol image. |
| 361 | `                .font(.system(size: 15, weight: .bold))` | Sets the text font, size, weight, and design. |
| 362 | `                .foregroundStyle(.white)` | Sets the foreground color or style of the view. |
| 363 | `                .frame(width: 38, height: 38)` | Constrains or expands the view’s size and alignment. |
| 364 | `                .background(Color(red: 90 / 255, green: 105 / 255, blue: 180 / 255))` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 365 | `                .clipShape(Circle())` | Clips the view to the supplied shape. |
| 366 | `        } else {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 367 | `            Color.clear` | Implements the surrounding declaration or view-builder expression. |
| 368 | `                .frame(width: 38, height: 38)` | Constrains or expands the view’s size and alignment. |
| 369 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 370 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 371 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 372 | `` | Blank line used to separate declarations or visual sections. |
| 373 | `// MARK: - Exercise Intro Skeleton View` | Section marker used to organize related declarations in Xcode. |
| 374 | `/// Standardized intro template for all exercises (Prolonged Speech, Dial Scene, Picture Description, Narration).` | Documentation comment describing the following public API. |
| 375 | `public struct ExerciseIntroSkeletonView: View {` | Defines a public reusable Swift type, usually a SwiftUI view or button style. |
| 376 | `    public let title: String` | Declares a stored property that holds configuration or view state. |
| 377 | `    public let subtitle: String` | Declares a stored property that holds configuration or view state. |
| 378 | `    public let heroImageName: String` | Declares a stored property that holds configuration or view state. |
| 379 | `    public let continueButtonTitle: String` | Declares a stored property that holds configuration or view state. |
| 380 | `    public let onBack: () -> Void` | Declares a stored property that holds configuration or view state. |
| 381 | `    public let onContinue: () -> Void` | Declares a stored property that holds configuration or view state. |
| 382 | `` | Blank line used to separate declarations or visual sections. |
| 383 | `    @State private var breatheEffect: Bool = false` | Defines a private computed or stored property used only by the enclosing type. |
| 384 | `` | Blank line used to separate declarations or visual sections. |
| 385 | `    public init(` | Initializes the type and assigns its configurable inputs. |
| 386 | `        title: String,` | Implements the surrounding declaration or view-builder expression. |
| 387 | `        subtitle: String,` | Implements the surrounding declaration or view-builder expression. |
| 388 | `        heroImageName: String,` | Implements the surrounding declaration or view-builder expression. |
| 389 | `        continueButtonTitle: String = "Continue",` | Implements the surrounding declaration or view-builder expression. |
| 390 | `        onBack: @escaping () -> Void,` | Implements the surrounding declaration or view-builder expression. |
| 391 | `        onContinue: @escaping () -> Void` | Implements the surrounding declaration or view-builder expression. |
| 392 | `    ) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 393 | `        self.title = title` | Implements the surrounding declaration or view-builder expression. |
| 394 | `        self.subtitle = subtitle` | Implements the surrounding declaration or view-builder expression. |
| 395 | `        self.heroImageName = heroImageName` | Implements the surrounding declaration or view-builder expression. |
| 396 | `        self.continueButtonTitle = continueButtonTitle` | Implements the surrounding declaration or view-builder expression. |
| 397 | `        self.onBack = onBack` | Implements the surrounding declaration or view-builder expression. |
| 398 | `        self.onContinue = onContinue` | Implements the surrounding declaration or view-builder expression. |
| 399 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 400 | `` | Blank line used to separate declarations or visual sections. |
| 401 | `    public var body: some View {` | Defines the SwiftUI view hierarchy rendered by this type. |
| 402 | `        ZStack {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 403 | `            StamerleeTheme.backgroundDark` | Implements the surrounding declaration or view-builder expression. |
| 404 | `                .ignoresSafeArea()` | Allows the view to extend into safe-area regions such as under the status bar. |
| 405 | `` | Blank line used to separate declarations or visual sections. |
| 406 | `            VStack(alignment: .leading, spacing: 0) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 407 | `                // Top Navigation Bar` | Inline comment documenting the intent of the following code. |
| 408 | `                HStack {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 409 | `                    BackNavButton(action: onBack)` | Implements the surrounding declaration or view-builder expression. |
| 410 | `                    Spacer()` | Implements the surrounding declaration or view-builder expression. |
| 411 | `                }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 412 | `                .padding(.horizontal, 24)` | Adds spacing around the view’s content. |
| 413 | `                .padding(.top, 16)` | Adds spacing around the view’s content. |
| 414 | `` | Blank line used to separate declarations or visual sections. |
| 415 | `                // Headings Section` | Inline comment documenting the intent of the following code. |
| 416 | `                VStack(alignment: .leading, spacing: 12) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 417 | `                    Text(title)` | Displays a localized or literal text label. |
| 418 | `                        .font(.system(size: 32, weight: .bold, design: .rounded))` | Sets the text font, size, weight, and design. |
| 419 | `                        .foregroundStyle(StamerleeTheme.textPrimaryDark)` | Sets the foreground color or style of the view. |
| 420 | `                        .lineSpacing(2)` | Applies a SwiftUI modifier to the preceding view. |
| 421 | `` | Blank line used to separate declarations or visual sections. |
| 422 | `                    Text(subtitle)` | Displays a localized or literal text label. |
| 423 | `                        .font(.system(size: 16, weight: .regular, design: .rounded))` | Sets the text font, size, weight, and design. |
| 424 | `                        .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style of the view. |
| 425 | `                        .lineSpacing(4)` | Applies a SwiftUI modifier to the preceding view. |
| 426 | `                }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 427 | `                .padding(.horizontal, 24)` | Adds spacing around the view’s content. |
| 428 | `                .padding(.top, 22)` | Adds spacing around the view’s content. |
| 429 | `` | Blank line used to separate declarations or visual sections. |
| 430 | `                // Hero Illustration` | Inline comment documenting the intent of the following code. |
| 431 | `                Image(heroImageName)` | Displays an asset or SF Symbol image. |
| 432 | `                    .resizable()` | Applies a SwiftUI modifier to the preceding view. |
| 433 | `                    .scaledToFit()` | Applies a SwiftUI modifier to the preceding view. |
| 434 | `                    .frame(maxHeight: 360)` | Constrains or expands the view’s size and alignment. |
| 435 | `                    .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 10)` | Adds a drop shadow to improve visual separation. |
| 436 | `                    .scaleEffect(breatheEffect ? 1.015 : 0.985)` | Applies a SwiftUI modifier to the preceding view. |
| 437 | `                    .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: breatheEffect)` | Attaches an animation that responds to changes in the supplied value. |
| 438 | `                    .accessibilityHidden(true)` | Provides or adjusts accessibility semantics for assistive technologies. |
| 439 | `                .frame(maxWidth: .infinity)` | Constrains or expands the view’s size and alignment. |
| 440 | `                .padding(.vertical, 14)` | Adds spacing around the view’s content. |
| 441 | `` | Blank line used to separate declarations or visual sections. |
| 442 | `                Spacer()` | Implements the surrounding declaration or view-builder expression. |
| 443 | `` | Blank line used to separate declarations or visual sections. |
| 444 | `                // Bottom CTA Button ("Continue")` | Inline comment documenting the intent of the following code. |
| 445 | `                VStack {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 446 | `                    PrimaryActionButton(title: continueButtonTitle, action: onContinue)` | Implements the surrounding declaration or view-builder expression. |
| 447 | `                }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 448 | `                .padding(.horizontal, 24)` | Adds spacing around the view’s content. |
| 449 | `                .padding(.bottom, 24)` | Adds spacing around the view’s content. |
| 450 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 451 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 452 | `        .onAppear {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 453 | `            breatheEffect = true` | Implements the surrounding declaration or view-builder expression. |
| 454 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 455 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 456 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 457 | `` | Blank line used to separate declarations or visual sections. |
| 458 | `// MARK: - Speech Microphone Button` | Section marker used to organize related declarations in Xcode. |
| 459 | `public struct SpeechMicrophoneButton: View {` | Defines a public reusable Swift type, usually a SwiftUI view or button style. |
| 460 | `    @Binding public var isListening: Bool` | Creates a two-way connection to state owned by another view. |
| 461 | `    public let action: () -> Void` | Declares a stored property that holds configuration or view state. |
| 462 | `` | Blank line used to separate declarations or visual sections. |
| 463 | `    public init(isListening: Binding<Bool>, action: @escaping () -> Void) {` | Initializes the type and assigns its configurable inputs. |
| 464 | `        self._isListening = isListening` | Implements the surrounding declaration or view-builder expression. |
| 465 | `        self.action = action` | Implements the surrounding declaration or view-builder expression. |
| 466 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 467 | `` | Blank line used to separate declarations or visual sections. |
| 468 | `    public var body: some View {` | Defines the SwiftUI view hierarchy rendered by this type. |
| 469 | `        Button(action: action) {` | Creates an accessible interactive button and executes its action when activated. |
| 470 | `            HStack(spacing: 10) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 471 | `                Image(systemName: isListening ? "waveform" : "mic.fill")` | Displays an asset or SF Symbol image. |
| 472 | `                    .font(.system(size: 18, weight: .bold))` | Sets the text font, size, weight, and design. |
| 473 | `` | Blank line used to separate declarations or visual sections. |
| 474 | `                Text(isListening ? "Listening..." : "Tap to speak")` | Displays a localized or literal text label. |
| 475 | `                    .font(.system(size: 16, weight: .semibold, design: .rounded))` | Sets the text font, size, weight, and design. |
| 476 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 477 | `            .foregroundStyle(.white)` | Sets the foreground color or style of the view. |
| 478 | `            .frame(maxWidth: .infinity, minHeight: 52)` | Constrains or expands the view’s size and alignment. |
| 479 | `            .background(StamerleeTheme.primaryBlue)` | Adds a background view behind the content. |
| 480 | `            .clipShape(Capsule())` | Clips the view to the supplied shape. |
| 481 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 482 | `        .buttonStyle(.haptic(weight: .medium, pressedScale: 0.97))` | Applies a SwiftUI modifier to the preceding view. |
| 483 | `        .padding(.horizontal, 24)` | Adds spacing around the view’s content. |
| 484 | `        .accessibilityLabel(isListening ? "Listening" : "Tap to speak")` | Provides or adjusts accessibility semantics for assistive technologies. |
| 485 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 486 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 487 | `` | Blank line used to separate declarations or visual sections. |
| 488 | `// MARK: - Exercise Analysis Skeleton View` | Section marker used to organize related declarations in Xcode. |
| 489 | `/// Standardized result/analysis screen matching the Prolonged Speech design for all exercises.` | Documentation comment describing the following public API. |
| 490 | `public struct ExerciseAnalysisSkeletonView: View {` | Defines a public reusable Swift type, usually a SwiftUI view or button style. |
| 491 | `    public let scoreText: String` | Declares a stored property that holds configuration or view state. |
| 492 | `    public let maxScoreText: String` | Declares a stored property that holds configuration or view state. |
| 493 | `    public let subtitle: String` | Declares a stored property that holds configuration or view state. |
| 494 | `    public let affirmation: String?` | Declares a stored property that holds configuration or view state. |
| 495 | `    public let wordsList: [String]` | Declares a stored property that holds configuration or view state. |
| 496 | `    @Binding public var selectedWords: Set<String>` | Creates a two-way connection to state owned by another view. |
| 497 | `    public let onDone: () -> Void` | Declares a stored property that holds configuration or view state. |
| 498 | `` | Blank line used to separate declarations or visual sections. |
| 499 | `    @State private var showAllWordsSheet: Bool = false` | Defines a private computed or stored property used only by the enclosing type. |
| 500 | `` | Blank line used to separate declarations or visual sections. |
| 501 | `    public init(` | Initializes the type and assigns its configurable inputs. |
| 502 | `        scoreText: String,` | Implements the surrounding declaration or view-builder expression. |
| 503 | `        maxScoreText: String = "/ 10",` | Implements the surrounding declaration or view-builder expression. |
| 504 | `        subtitle: String = "Tap words you want Beat Buddy to revisit",` | Implements the surrounding declaration or view-builder expression. |
| 505 | `        affirmation: String? = nil,` | Implements the surrounding declaration or view-builder expression. |
| 506 | `        wordsList: [String],` | Implements the surrounding declaration or view-builder expression. |
| 507 | `        selectedWords: Binding<Set<String>>,` | Implements the surrounding declaration or view-builder expression. |
| 508 | `        onDone: @escaping () -> Void` | Implements the surrounding declaration or view-builder expression. |
| 509 | `    ) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 510 | `        self.scoreText = scoreText` | Implements the surrounding declaration or view-builder expression. |
| 511 | `        self.maxScoreText = maxScoreText` | Implements the surrounding declaration or view-builder expression. |
| 512 | `        self.subtitle = subtitle` | Implements the surrounding declaration or view-builder expression. |
| 513 | `        self.affirmation = affirmation` | Implements the surrounding declaration or view-builder expression. |
| 514 | `        self.wordsList = wordsList` | Implements the surrounding declaration or view-builder expression. |
| 515 | `        self._selectedWords = selectedWords` | Implements the surrounding declaration or view-builder expression. |
| 516 | `        self.onDone = onDone` | Implements the surrounding declaration or view-builder expression. |
| 517 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 518 | `` | Blank line used to separate declarations or visual sections. |
| 519 | `    public init(` | Initializes the type and assigns its configurable inputs. |
| 520 | `        scoreText: String,` | Implements the surrounding declaration or view-builder expression. |
| 521 | `        maxScoreText: String = "/ 10",` | Implements the surrounding declaration or view-builder expression. |
| 522 | `        subtitle: String = "Here's a summary of this exercise.",` | Implements the surrounding declaration or view-builder expression. |
| 523 | `        affirmation: String? = nil,` | Implements the surrounding declaration or view-builder expression. |
| 524 | `        onDone: @escaping () -> Void` | Implements the surrounding declaration or view-builder expression. |
| 525 | `    ) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 526 | `        self.init(` | Implements the surrounding declaration or view-builder expression. |
| 527 | `            scoreText: scoreText,` | Implements the surrounding declaration or view-builder expression. |
| 528 | `            maxScoreText: maxScoreText,` | Implements the surrounding declaration or view-builder expression. |
| 529 | `            subtitle: subtitle,` | Implements the surrounding declaration or view-builder expression. |
| 530 | `            affirmation: affirmation,` | Implements the surrounding declaration or view-builder expression. |
| 531 | `            wordsList: [],` | Implements the surrounding declaration or view-builder expression. |
| 532 | `            selectedWords: .constant([]),` | Implements the surrounding declaration or view-builder expression. |
| 533 | `            onDone: onDone` | Implements the surrounding declaration or view-builder expression. |
| 534 | `        )` | Implements the surrounding declaration or view-builder expression. |
| 535 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 536 | `` | Blank line used to separate declarations or visual sections. |
| 537 | `    private var computedAffirmation: String {` | Defines a private computed or stored property used only by the enclosing type. |
| 538 | `        if let custom = affirmation, !custom.isEmpty {` | Conditionally includes this branch when the Boolean or availability condition is true. |
| 539 | `            return custom` | Returns the computed value from the current function or computed property. |
| 540 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 541 | `        let clean = scoreText.replacingOccurrences(of: "%", with: "").trimmingCharacters(in: .whitespaces)` | Declares an immutable local value. |
| 542 | `        let value = Double(clean) ?? 8.0` | Declares an immutable local value. |
| 543 | `        if value >= 8.5 {` | Conditionally includes this branch when the Boolean or availability condition is true. |
| 544 | `            return "You did great today!!"` | Returns the computed value from the current function or computed property. |
| 545 | `        } else if value >= 7.5 {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 546 | `            return "Great progress today!"` | Returns the computed value from the current function or computed property. |
| 547 | `        } else {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 548 | `            return "You can improve, keep practicing!"` | Returns the computed value from the current function or computed property. |
| 549 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 550 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 551 | `` | Blank line used to separate declarations or visual sections. |
| 552 | `    private var isAllSelected: Bool {` | Defines a private computed or stored property used only by the enclosing type. |
| 553 | `        !wordsList.isEmpty && selectedWords.count >= wordsList.count` | Implements the surrounding declaration or view-builder expression. |
| 554 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 555 | `` | Blank line used to separate declarations or visual sections. |
| 556 | `    private func toggleSelectAll() {` | Declares a helper function used by the surrounding type. |
| 557 | `        withAnimation(.easeInOut(duration: 0.2)) {` | Animates state mutations performed inside the closure. |
| 558 | `            if isAllSelected {` | Conditionally includes this branch when the Boolean or availability condition is true. |
| 559 | `                selectedWords.removeAll()` | Implements the surrounding declaration or view-builder expression. |
| 560 | `            } else {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 561 | `                selectedWords = Set(wordsList)` | Implements the surrounding declaration or view-builder expression. |
| 562 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 563 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 564 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 565 | `` | Blank line used to separate declarations or visual sections. |
| 566 | `    public var body: some View {` | Defines the SwiftUI view hierarchy rendered by this type. |
| 567 | `        ZStack {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 568 | `            StamerleeTheme.backgroundDark` | Implements the surrounding declaration or view-builder expression. |
| 569 | `                .ignoresSafeArea()` | Allows the view to extend into safe-area regions such as under the status bar. |
| 570 | `` | Blank line used to separate declarations or visual sections. |
| 571 | `            VStack(alignment: .leading, spacing: 0) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 572 | `                // Top Title Bar` | Inline comment documenting the intent of the following code. |
| 573 | `                Text("Analysis")` | Displays a localized or literal text label. |
| 574 | `                    .font(.system(size: 32, weight: .bold, design: .rounded))` | Sets the text font, size, weight, and design. |
| 575 | `                    .foregroundStyle(StamerleeTheme.textPrimaryDark)` | Sets the foreground color or style of the view. |
| 576 | `                    .padding(.horizontal, 24)` | Adds spacing around the view’s content. |
| 577 | `                    .padding(.top, 24)` | Adds spacing around the view’s content. |
| 578 | `                    .padding(.bottom, 16)` | Adds spacing around the view’s content. |
| 579 | `` | Blank line used to separate declarations or visual sections. |
| 580 | `                // Big Affirmation & Prominent Score Display (Made bigger to occupy the upper area)` | Inline comment documenting the intent of the following code. |
| 581 | `                VStack(spacing: 12) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 582 | `                    Text(computedAffirmation)` | Displays a localized or literal text label. |
| 583 | `                        .font(.system(size: 30, weight: .bold, design: .rounded))` | Sets the text font, size, weight, and design. |
| 584 | `                        .foregroundStyle(.white)` | Sets the foreground color or style of the view. |
| 585 | `                        .multilineTextAlignment(.center)` | Applies a SwiftUI modifier to the preceding view. |
| 586 | `                        .padding(.horizontal, 24)` | Adds spacing around the view’s content. |
| 587 | `` | Blank line used to separate declarations or visual sections. |
| 588 | `                    Text("YOU SCORED")` | Displays a localized or literal text label. |
| 589 | `                        .font(.system(size: 20, weight: .bold, design: .rounded))` | Sets the text font, size, weight, and design. |
| 590 | `                        .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style of the view. |
| 591 | `                        .tracking(1.4)` | Applies a SwiftUI modifier to the preceding view. |
| 592 | `                        .padding(.top, 4)` | Adds spacing around the view’s content. |
| 593 | `` | Blank line used to separate declarations or visual sections. |
| 594 | `                    HStack(alignment: .firstTextBaseline, spacing: 6) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 595 | `                        Text(scoreText)` | Displays a localized or literal text label. |
| 596 | `                            .font(.system(size: 72, weight: .bold, design: .rounded))` | Sets the text font, size, weight, and design. |
| 597 | `                            .foregroundStyle(.white)` | Sets the foreground color or style of the view. |
| 598 | `                        if !maxScoreText.isEmpty {` | Conditionally includes this branch when the Boolean or availability condition is true. |
| 599 | `                            Text(maxScoreText)` | Displays a localized or literal text label. |
| 600 | `                                .font(.system(size: 28, weight: .bold, design: .rounded))` | Sets the text font, size, weight, and design. |
| 601 | `                                .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style of the view. |
| 602 | `                        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 603 | `                    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 604 | `                }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 605 | `                .frame(maxWidth: .infinity)` | Constrains or expands the view’s size and alignment. |
| 606 | `                .padding(.top, 36)` | Adds spacing around the view’s content. |
| 607 | `                .padding(.bottom, 48)` | Adds spacing around the view’s content. |
| 608 | `` | Blank line used to separate declarations or visual sections. |
| 609 | `                // Instructions Subtitle` | Inline comment documenting the intent of the following code. |
| 610 | `                Text(subtitle)` | Displays a localized or literal text label. |
| 611 | `                    .font(.system(size: 13, weight: .regular, design: .rounded))` | Sets the text font, size, weight, and design. |
| 612 | `                    .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style of the view. |
| 613 | `                    .frame(maxWidth: .infinity, alignment: .center)` | Constrains or expands the view’s size and alignment. |
| 614 | `                    .padding(.bottom, 18)` | Adds spacing around the view’s content. |
| 615 | `` | Blank line used to separate declarations or visual sections. |
| 616 | `                // Action Row: Counter + Single "Select all / Deselect all" Toggle Button` | Inline comment documenting the intent of the following code. |
| 617 | `                HStack {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 618 | `                    Text("\(selectedWords.count) selected")` | Displays a localized or literal text label. |
| 619 | `                        .font(.system(size: 13, weight: .semibold, design: .rounded))` | Sets the text font, size, weight, and design. |
| 620 | `                        .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style of the view. |
| 621 | `` | Blank line used to separate declarations or visual sections. |
| 622 | `                    Spacer()` | Implements the surrounding declaration or view-builder expression. |
| 623 | `` | Blank line used to separate declarations or visual sections. |
| 624 | `                    Button(isAllSelected ? "Deselect all" : "Select all") {` | Creates an accessible interactive button and executes its action when activated. |
| 625 | `                        toggleSelectAll()` | Implements the surrounding declaration or view-builder expression. |
| 626 | `                    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 627 | `                    .font(.system(size: 13, weight: .bold, design: .rounded))` | Sets the text font, size, weight, and design. |
| 628 | `                    .foregroundStyle(StamerleeTheme.primaryBlue)` | Sets the foreground color or style of the view. |
| 629 | `                }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 630 | `                .padding(.horizontal, 24)` | Adds spacing around the view’s content. |
| 631 | `                .padding(.bottom, 14)` | Adds spacing around the view’s content. |
| 632 | `` | Blank line used to separate declarations or visual sections. |
| 633 | `                // 2-Column Word Grid (Older sleek capsule design)` | Inline comment documenting the intent of the following code. |
| 634 | `                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {` | Lays out children in a lazily created vertical grid. |
| 635 | `                    ForEach(Array(wordsList.prefix(6)), id: \.self) { word in` | Creates repeated child views for each identifiable element in a collection. |
| 636 | `                        let isSelected = selectedWords.contains(word)` | Declares an immutable local value. |
| 637 | `                        wordButton(word: word, isSelected: isSelected) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 638 | `                            toggleWordSelection(word)` | Implements the surrounding declaration or view-builder expression. |
| 639 | `                        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 640 | `                    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 641 | `                }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 642 | `                .padding(.horizontal, 24)` | Adds spacing around the view’s content. |
| 643 | `` | Blank line used to separate declarations or visual sections. |
| 644 | `                // Hyperlink-style "View more" button` | Inline comment documenting the intent of the following code. |
| 645 | `                if wordsList.count > 6 {` | Conditionally includes this branch when the Boolean or availability condition is true. |
| 646 | `                    Button {` | Creates an accessible interactive button and executes its action when activated. |
| 647 | `                        showAllWordsSheet = true` | Implements the surrounding declaration or view-builder expression. |
| 648 | `                    } label: {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 649 | `                        HStack(spacing: 4) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 650 | `                            Text("View more")` | Displays a localized or literal text label. |
| 651 | `                                .underline()` | Applies a SwiftUI modifier to the preceding view. |
| 652 | `                            Image(systemName: "chevron.right")` | Displays an asset or SF Symbol image. |
| 653 | `                                .font(.system(size: 11, weight: .semibold))` | Sets the text font, size, weight, and design. |
| 654 | `                        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 655 | `                        .font(.system(size: 13.5, weight: .semibold, design: .rounded))` | Sets the text font, size, weight, and design. |
| 656 | `                        .foregroundStyle(StamerleeTheme.primaryBlue)` | Sets the foreground color or style of the view. |
| 657 | `                    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 658 | `                    .frame(maxWidth: .infinity, alignment: .center)` | Constrains or expands the view’s size and alignment. |
| 659 | `                    .padding(.top, 14)` | Adds spacing around the view’s content. |
| 660 | `                }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 661 | `` | Blank line used to separate declarations or visual sections. |
| 662 | `                Spacer(minLength: 20)` | Implements the surrounding declaration or view-builder expression. |
| 663 | `` | Blank line used to separate declarations or visual sections. |
| 664 | `                // Bottom CTA Button ("Done")` | Inline comment documenting the intent of the following code. |
| 665 | `                VStack {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 666 | `                    PrimaryActionButton(title: "Done", action: onDone)` | Implements the surrounding declaration or view-builder expression. |
| 667 | `                }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 668 | `                .padding(.horizontal, 24)` | Adds spacing around the view’s content. |
| 669 | `                .padding(.bottom, 24)` | Adds spacing around the view’s content. |
| 670 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 671 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 672 | `        .sensoryFeedback(.selection, trigger: selectedWords)` | Adds system haptic feedback driven by a state trigger. |
| 673 | `        .sheet(isPresented: $showAllWordsSheet) {` | Presents modal content controlled by a Boolean binding. |
| 674 | `            wordsSheetView` | Implements the surrounding declaration or view-builder expression. |
| 675 | `                .presentationDetents([.medium, .large])` | Sets the supported heights for the presented sheet. |
| 676 | `                .presentationDragIndicator(.visible)` | Applies a SwiftUI modifier to the preceding view. |
| 677 | `                .presentationBackground(StamerleeTheme.backgroundDark)` | Applies a SwiftUI modifier to the preceding view. |
| 678 | `                .ignoresSafeArea()` | Allows the view to extend into safe-area regions such as under the status bar. |
| 679 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 680 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 681 | `` | Blank line used to separate declarations or visual sections. |
| 682 | `    private var wordsSheetView: some View {` | Defines a private computed or stored property used only by the enclosing type. |
| 683 | `        NavigationStack {` | Provides stack-based navigation state and navigation-bar behavior. |
| 684 | `            ZStack {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 685 | `                StamerleeTheme.backgroundDark` | Implements the surrounding declaration or view-builder expression. |
| 686 | `                    .ignoresSafeArea()` | Allows the view to extend into safe-area regions such as under the status bar. |
| 687 | `` | Blank line used to separate declarations or visual sections. |
| 688 | `                ScrollView(.vertical, showsIndicators: true) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 689 | `                    VStack(alignment: .leading, spacing: 16) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 690 | `                        HStack {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 691 | `                            Text("\(selectedWords.count) of \(wordsList.count) selected")` | Displays a localized or literal text label. |
| 692 | `                                .font(.system(size: 13, weight: .medium, design: .rounded))` | Sets the text font, size, weight, and design. |
| 693 | `                                .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style of the view. |
| 694 | `` | Blank line used to separate declarations or visual sections. |
| 695 | `                            Spacer()` | Implements the surrounding declaration or view-builder expression. |
| 696 | `` | Blank line used to separate declarations or visual sections. |
| 697 | `                            Button(isAllSelected ? "Deselect all" : "Select all") {` | Creates an accessible interactive button and executes its action when activated. |
| 698 | `                                toggleSelectAll()` | Implements the surrounding declaration or view-builder expression. |
| 699 | `                            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 700 | `                            .font(.system(size: 13, weight: .bold, design: .rounded))` | Sets the text font, size, weight, and design. |
| 701 | `                            .foregroundStyle(StamerleeTheme.primaryBlue)` | Sets the foreground color or style of the view. |
| 702 | `                        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 703 | `                        .padding(.horizontal, 24)` | Adds spacing around the view’s content. |
| 704 | `                        .padding(.top, 12)` | Adds spacing around the view’s content. |
| 705 | `` | Blank line used to separate declarations or visual sections. |
| 706 | `                        LazyVGrid(` | Lays out children in a lazily created vertical grid. |
| 707 | `                            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],` | Implements the surrounding declaration or view-builder expression. |
| 708 | `                            spacing: 12` | Implements the surrounding declaration or view-builder expression. |
| 709 | `                        ) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 710 | `                            ForEach(wordsList, id: \.self) { word in` | Creates repeated child views for each identifiable element in a collection. |
| 711 | `                                let isSelected = selectedWords.contains(word)` | Declares an immutable local value. |
| 712 | `                                wordButton(word: word, isSelected: isSelected) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 713 | `                                    toggleWordSelection(word)` | Implements the surrounding declaration or view-builder expression. |
| 714 | `                                }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 715 | `                            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 716 | `                        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 717 | `                        .padding(.horizontal, 24)` | Adds spacing around the view’s content. |
| 718 | `                        .padding(.bottom, 32)` | Adds spacing around the view’s content. |
| 719 | `                    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 720 | `                }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 721 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 722 | `            .navigationTitle("Practice Words")` | Applies a SwiftUI modifier to the preceding view. |
| 723 | `            .navigationBarTitleDisplayMode(.inline)` | Uses the compact inline navigation-bar title presentation. |
| 724 | `            .toolbarBackground(StamerleeTheme.backgroundDark, for: .navigationBar)` | Adds toolbar content or toolbar configuration to the current view. |
| 725 | `            .toolbarColorScheme(.dark, for: .navigationBar)` | Adds toolbar content or toolbar configuration to the current view. |
| 726 | `            .toolbar {` | Adds toolbar content or toolbar configuration to the current view. |
| 727 | `                ToolbarItem(placement: .topBarTrailing) {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 728 | `                    Button("Done") {` | Creates an accessible interactive button and executes its action when activated. |
| 729 | `                        showAllWordsSheet = false` | Implements the surrounding declaration or view-builder expression. |
| 730 | `                    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 731 | `                    .font(.system(size: 15, weight: .bold, design: .rounded))` | Sets the text font, size, weight, and design. |
| 732 | `                    .foregroundStyle(StamerleeTheme.primaryBlue)` | Sets the foreground color or style of the view. |
| 733 | `                }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 734 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 735 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 736 | `        .ignoresSafeArea()` | Allows the view to extend into safe-area regions such as under the status bar. |
| 737 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 738 | `` | Blank line used to separate declarations or visual sections. |
| 739 | `    private func toggleWordSelection(_ word: String) {` | Declares a helper function used by the surrounding type. |
| 740 | `        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {` | Animates state mutations performed inside the closure. |
| 741 | `            if selectedWords.contains(word) {` | Conditionally includes this branch when the Boolean or availability condition is true. |
| 742 | `                selectedWords.remove(word)` | Implements the surrounding declaration or view-builder expression. |
| 743 | `            } else {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 744 | `                selectedWords.insert(word)` | Implements the surrounding declaration or view-builder expression. |
| 745 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 746 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 747 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 748 | `` | Blank line used to separate declarations or visual sections. |
| 749 | `    // MARK: - Word Selection Pill (Older clean capsule design)` | Section marker used to organize related declarations in Xcode. |
| 750 | `    private func wordButton(word: String, isSelected: Bool, action: @escaping () -> Void) -> some View {` | Declares a helper function used by the surrounding type. |
| 751 | `        Button(action: action) {` | Creates an accessible interactive button and executes its action when activated. |
| 752 | `            Text(word)` | Displays a localized or literal text label. |
| 753 | `                .font(.system(size: 13.5, weight: isSelected ? .bold : .medium, design: .rounded))` | Sets the text font, size, weight, and design. |
| 754 | `                .foregroundStyle(isSelected ? .white : StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style of the view. |
| 755 | `                .frame(maxWidth: .infinity)` | Constrains or expands the view’s size and alignment. |
| 756 | `                .frame(height: 44)` | Constrains or expands the view’s size and alignment. |
| 757 | `                .background(` | Adds a background view behind the content. |
| 758 | `                    Group {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 759 | `                        if isSelected {` | Conditionally includes this branch when the Boolean or availability condition is true. |
| 760 | `                            Color(red: 20 / 255, green: 45 / 255, blue: 105 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 761 | `                        } else {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 762 | `                            Color(red: 16 / 255, green: 18 / 255, blue: 36 / 255)` | Creates a color from normalized RGB channel values; dividing 0–255 values by 255 produces the expected 0–1 range. |
| 763 | `                        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 764 | `                    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 765 | `                )` | Implements the surrounding declaration or view-builder expression. |
| 766 | `                .overlay(` | Draws an additional view above the current view. |
| 767 | `                    Capsule()` | Implements the surrounding declaration or view-builder expression. |
| 768 | `                        .stroke(` | Applies a SwiftUI modifier to the preceding view. |
| 769 | `                            isSelected ? StamerleeTheme.primaryBlue : Color.white.opacity(0.06),` | Implements the surrounding declaration or view-builder expression. |
| 770 | `                            lineWidth: isSelected ? 2 : 1` | Implements the surrounding declaration or view-builder expression. |
| 771 | `                        )` | Implements the surrounding declaration or view-builder expression. |
| 772 | `                )` | Implements the surrounding declaration or view-builder expression. |
| 773 | `                .clipShape(Capsule())` | Clips the view to the supplied shape. |
| 774 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 775 | `        .buttonStyle(.haptic)` | Applies a SwiftUI modifier to the preceding view. |
| 776 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 777 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 778 | `` | Blank line used to separate declarations or visual sections. |
| 779 | `// MARK: - Reusable Profile Avatar` | Section marker used to organize related declarations in Xcode. |
| 780 | `public struct ProfileAvatar: View {` | Defines a public reusable Swift type, usually a SwiftUI view or button style. |
| 781 | `    public let style: Int` | Declares a stored property that holds configuration or view state. |
| 782 | `    public let imageData: Data?` | Declares a stored property that holds configuration or view state. |
| 783 | `    public var size: CGFloat` | Declares a stored property that holds configuration or view state. |
| 784 | `` | Blank line used to separate declarations or visual sections. |
| 785 | `    public init(style: Int, imageData: Data?, size: CGFloat = 84) {` | Initializes the type and assigns its configurable inputs. |
| 786 | `        self.style = style` | Implements the surrounding declaration or view-builder expression. |
| 787 | `        self.imageData = imageData` | Implements the surrounding declaration or view-builder expression. |
| 788 | `        self.size = size` | Implements the surrounding declaration or view-builder expression. |
| 789 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 790 | `` | Blank line used to separate declarations or visual sections. |
| 791 | `    public var body: some View {` | Defines the SwiftUI view hierarchy rendered by this type. |
| 792 | `        avatarArtwork` | Implements the surrounding declaration or view-builder expression. |
| 793 | `            .scaleEffect(size / 84.0)` | Applies a SwiftUI modifier to the preceding view. |
| 794 | `            .frame(width: size, height: size)` | Constrains or expands the view’s size and alignment. |
| 795 | `            .contentShape(Circle())` | Applies a SwiftUI modifier to the preceding view. |
| 796 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 797 | `` | Blank line used to separate declarations or visual sections. |
| 798 | `    private var avatarArtwork: some View {` | Defines a private computed or stored property used only by the enclosing type. |
| 799 | `        ZStack {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 800 | `            if let imageData, let image = UIImage(data: imageData) {` | Conditionally includes this branch when the Boolean or availability condition is true. |
| 801 | `                Image(uiImage: image)` | Displays an asset or SF Symbol image. |
| 802 | `                    .resizable()` | Applies a SwiftUI modifier to the preceding view. |
| 803 | `                    .scaledToFill()` | Applies a SwiftUI modifier to the preceding view. |
| 804 | `            } else {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 805 | `                Circle()` | Implements the surrounding declaration or view-builder expression. |
| 806 | `                    .fill(backgroundColor)` | Applies a SwiftUI modifier to the preceding view. |
| 807 | `                    .padding(8)` | Adds spacing around the view’s content. |
| 808 | `` | Blank line used to separate declarations or visual sections. |
| 809 | `                Circle()` | Implements the surrounding declaration or view-builder expression. |
| 810 | `                    .fill(foregroundColor)` | Applies a SwiftUI modifier to the preceding view. |
| 811 | `                    .frame(width: 22, height: 22)` | Constrains or expands the view’s size and alignment. |
| 812 | `                    .offset(y: -13)` | Applies a SwiftUI modifier to the preceding view. |
| 813 | `` | Blank line used to separate declarations or visual sections. |
| 814 | `                Capsule()` | Implements the surrounding declaration or view-builder expression. |
| 815 | `                    .fill(foregroundColor)` | Applies a SwiftUI modifier to the preceding view. |
| 816 | `                    .frame(width: 59, height: 33)` | Constrains or expands the view’s size and alignment. |
| 817 | `                    .offset(y: 25)` | Applies a SwiftUI modifier to the preceding view. |
| 818 | `            }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 819 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 820 | `        .frame(width: 84, height: 84)` | Constrains or expands the view’s size and alignment. |
| 821 | `        .background(Color.black)` | Adds a background view behind the content. |
| 822 | `        .clipShape(Circle())` | Clips the view to the supplied shape. |
| 823 | `        .overlay(` | Draws an additional view above the current view. |
| 824 | `            Circle()` | Implements the surrounding declaration or view-builder expression. |
| 825 | `                .stroke(StamerleeTheme.profileCard, lineWidth: 2)` | Applies a SwiftUI modifier to the preceding view. |
| 826 | `        )` | Implements the surrounding declaration or view-builder expression. |
| 827 | `        .shadow(color: Color.black.opacity(0.18), radius: 4, x: 0, y: 2)` | Adds a drop shadow to improve visual separation. |
| 828 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 829 | `` | Blank line used to separate declarations or visual sections. |
| 830 | `    private var backgroundColor: Color {` | Defines a private computed or stored property used only by the enclosing type. |
| 831 | `        switch style {` | Selects behavior based on the value being switched over. |
| 832 | `        case 1: return StamerleeTheme.accentPurple` | Defines or handles one case of the surrounding enumeration or switch. |
| 833 | `        case 2: return StamerleeTheme.primaryBlue` | Defines or handles one case of the surrounding enumeration or switch. |
| 834 | `        default: return StamerleeTheme.profileAvatarDark` | Handles unsupported input or an unmatched switch case. |
| 835 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 836 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 837 | `` | Blank line used to separate declarations or visual sections. |
| 838 | `    private var foregroundColor: Color {` | Defines a private computed or stored property used only by the enclosing type. |
| 839 | `        style == 2 ? StamerleeTheme.profileCard : StamerleeTheme.backgroundDark` | Implements the surrounding declaration or view-builder expression. |
| 840 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 841 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 842 | `` | Blank line used to separate declarations or visual sections. |
| 843 | `// MARK: - Avatar Interactive Button Style` | Section marker used to organize related declarations in Xcode. |
| 844 | `public struct AvatarInteractiveButtonStyle: ButtonStyle {` | Defines a public reusable Swift type, usually a SwiftUI view or button style. |
| 845 | `    public init() {}` | Initializes the type and assigns its configurable inputs. |
| 846 | `    public func makeBody(configuration: Configuration) -> some View {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 847 | `        configuration.label` | Implements the surrounding declaration or view-builder expression. |
| 848 | `            .scaleEffect(configuration.isPressed ? 0.90 : 1.0)` | Applies a SwiftUI modifier to the preceding view. |
| 849 | `            .animation(.spring(response: 0.22, dampingFraction: 0.68), value: configuration.isPressed)` | Attaches an animation that responds to changes in the supplied value. |
| 850 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 851 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 852 | `` | Blank line used to separate declarations or visual sections. |
| 853 | `// MARK: - Bouncy Card Button Style` | Section marker used to organize related declarations in Xcode. |
| 854 | `public struct BouncyCardButtonStyle: ButtonStyle {` | Defines a public reusable Swift type, usually a SwiftUI view or button style. |
| 855 | `    public init() {}` | Initializes the type and assigns its configurable inputs. |
| 856 | `    public func makeBody(configuration: Configuration) -> some View {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 857 | `        configuration.label` | Implements the surrounding declaration or view-builder expression. |
| 858 | `            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)` | Applies a SwiftUI modifier to the preceding view. |
| 859 | `            .animation(.spring(response: 0.24, dampingFraction: 0.64), value: configuration.isPressed)` | Attaches an animation that responds to changes in the supplied value. |
| 860 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 861 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 862 | `` | Blank line used to separate declarations or visual sections. |
| 863 | `// MARK: - Matched Geometry View Helper` | Section marker used to organize related declarations in Xcode. |
| 864 | `extension View {` | Adds functionality to an existing type without changing its original declaration. |
| 865 | `    @ViewBuilder` | Enables conditional and multi-view result-builder syntax for a view-producing property or function. |
| 866 | `    public func matchedGeometryEffectIfPresent<ID: Hashable>(` | Implements the surrounding declaration or view-builder expression. |
| 867 | `        id: ID,` | Implements the surrounding declaration or view-builder expression. |
| 868 | `        in namespace: Namespace.ID?,` | Implements the surrounding declaration or view-builder expression. |
| 869 | `        properties: MatchedGeometryProperties = .frame,` | Implements the surrounding declaration or view-builder expression. |
| 870 | `        anchor: UnitPoint = .center,` | Implements the surrounding declaration or view-builder expression. |
| 871 | `        isSource: Bool = true` | Implements the surrounding declaration or view-builder expression. |
| 872 | `    ) -> some View {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 873 | `        if let namespace {` | Conditionally includes this branch when the Boolean or availability condition is true. |
| 874 | `            self.matchedGeometryEffect(id: id, in: namespace, properties: properties, anchor: anchor, isSource: isSource)` | Implements the surrounding declaration or view-builder expression. |
| 875 | `        } else {` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 876 | `            self` | Implements the surrounding declaration or view-builder expression. |
| 877 | `        }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 878 | `    }` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |
| 879 | `}` | Opens or closes a Swift/SwiftUI scope such as a type, closure, or builder block. |

## Maintenance notes

- Keep `StamerleeTheme` as the single source of truth for shared colors; avoid introducing duplicate RGB literals in new views.
- Keep availability checks around iOS 26 glass controls unless the app raises its minimum deployment target.
- Re-test accessibility labels, Dynamic Type behavior, and reduced-motion behavior when changing these reusable components.
- If this document is regenerated, update the source date and re-check the compatibility table against the project deployment target.
