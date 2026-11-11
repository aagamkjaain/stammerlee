# Dial Scene and Narration Screens: Modern SwiftUI Review

This document reviews the screens shown in the supplied screenshot. Note that `NarrationDifficultyView.swift` declares `NarrationIntroView`; it is not currently a difficulty selector.

## Screen flow

```text
HomeDashboardView
  -> DialSceneIntroView
       -> DialSceneView
            -> scenarios -> conversation -> analysis
  -> NarrationIntroView
       -> NarrationPracticeView
```

## Modern-code check

The requested files use modern SwiftUI and Observation patterns. No definite deprecated API is present in these files.

- `@Bindable` with `AppState` is the current Observation-based shared-state pattern.
- The Dial Scene `Stage` enum is a clear local state machine for intro, scenario, conversation, and analysis states.
- `Task.sleep(for:)` is modern structured concurrency and avoids blocking the main thread.
- `.sensoryFeedback` is a modern system-feedback API and avoids manual UIKit haptic generators.
- `ForEach`, computed `some View` properties, `@ViewBuilder`-style composition through SwiftUI, and `#Preview` are current SwiftUI patterns.
- Optional `onBack` and `onContinue` callbacks make `DialSceneIntroView` reusable while retaining AppState defaults.
- Potential behavior issue, not deprecation: `isListening` is set true and reset after 500 ms, but the task is not stored/cancelled if the view disappears.
- Potential behavior issue, not deprecation: `conversationStep` advances immediately without a real speech-recognition result.
- Naming issue: `NarrationDifficultyView.swift` should be renamed to `NarrationIntroView.swift` or the type should be renamed for consistency.

## Line-by-line explanation

### `Stamerlee/DialSceneView.swift` (339 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports the framework needed by this source file. |
| 2 | `` | Blank line separating code sections. |
| 3 | `// MARK: - Dial Scene Intro View` | Section marker organizing the screen implementation. |
| 4 | `/// Introduces the Dial Scene scenario-based phone practice technique.` | Comment describing the purpose of the following code. |
| 5 | `public struct DialSceneIntroView: View {` | Declares a reusable public SwiftUI screen. |
| 6 | `    @Bindable public var state: AppState` | Connects the screen to the observable AppState for two-way mutation. |
| 7 | `    public var onBack: (() -> Void)? = nil` | Implements the surrounding screen or view-builder expression. |
| 8 | `    public var onContinue: (() -> Void)? = nil` | Implements the surrounding screen or view-builder expression. |
| 9 | `` | Blank line separating code sections. |
| 10 | `    @State private var breatheEffect: Bool = false` | Stores view-local state managed by SwiftUI. |
| 11 | `` | Blank line separating code sections. |
| 12 | `    public init(` | Initializes the screen with shared state and optional callbacks. |
| 13 | `        state: AppState,` | Implements the surrounding screen or view-builder expression. |
| 14 | `        onBack: (() -> Void)? = nil,` | Implements the surrounding screen or view-builder expression. |
| 15 | `        onContinue: (() -> Void)? = nil` | Implements the surrounding screen or view-builder expression. |
| 16 | `    ) {` | Opens or closes a Swift scope or view-builder block. |
| 17 | `        self.state = state` | Implements the surrounding screen or view-builder expression. |
| 18 | `        self.onBack = onBack` | Implements the surrounding screen or view-builder expression. |
| 19 | `        self.onContinue = onContinue` | Implements the surrounding screen or view-builder expression. |
| 20 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 21 | `` | Blank line separating code sections. |
| 22 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 23 | `        ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 24 | `            // Dark Background` | Comment describing the purpose of the following code. |
| 25 | `            StamerleeTheme.backgroundDark` | Implements the surrounding screen or view-builder expression. |
| 26 | `                .ignoresSafeArea()` | Extends the background into safe-area regions. |
| 27 | `` | Blank line separating code sections. |
| 28 | `            VStack(alignment: .leading, spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 29 | `                // Top Navigation Bar` | Comment describing the purpose of the following code. |
| 30 | `                HStack {` | Opens or closes a Swift scope or view-builder block. |
| 31 | `                    BackNavButton {` | Opens or closes a Swift scope or view-builder block. |
| 32 | `                        if let onBack {` | Conditionally uses an optional value when it exists. |
| 33 | `                            onBack()` | Implements the surrounding screen or view-builder expression. |
| 34 | `                        } else {` | Opens or closes a Swift scope or view-builder block. |
| 35 | `                            state.navigate(to: .homeDashboard, forward: false)` | Updates shared navigation state and moves to the requested screen. |
| 36 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 37 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 38 | `                    Spacer()` | Implements the surrounding screen or view-builder expression. |
| 39 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 40 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 41 | `                .padding(.top, 16)` | Adds layout spacing around the view. |
| 42 | `` | Blank line separating code sections. |
| 43 | `                // Headings Section` | Comment describing the purpose of the following code. |
| 44 | `                VStack(alignment: .leading, spacing: 12) {` | Opens or closes a Swift scope or view-builder block. |
| 45 | `                    Text("Let's start with\nDial Scene")` | Displays a text label. |
| 46 | `                        .font(.system(size: 32, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 47 | `                        .foregroundStyle(StamerleeTheme.textPrimaryDark)` | Sets the foreground color or style. |
| 48 | `                        .lineSpacing(2)` | Applies a SwiftUI modifier to the preceding view. |
| 49 | `` | Blank line separating code sections. |
| 50 | `                    Text("Dial Scene helps you practice real-life phone conversations, manage speaking challenges and build confidence in communicating smoothly during everyday calls.")` | Displays a text label. |
| 51 | `                        .font(.system(size: 16, weight: .regular, design: .rounded))` | Sets typography, size, weight, and design. |
| 52 | `                        .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 53 | `                        .lineSpacing(4)` | Applies a SwiftUI modifier to the preceding view. |
| 54 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 55 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 56 | `                .padding(.top, 22)` | Adds layout spacing around the view. |
| 57 | `` | Blank line separating code sections. |
| 58 | `                // Hero Illustration` | Comment describing the purpose of the following code. |
| 59 | `                Image("DialSceneHero")` | Displays a system symbol or asset. |
| 60 | `                    .resizable()` | Applies a SwiftUI modifier to the preceding view. |
| 61 | `                    .scaledToFit()` | Applies a SwiftUI modifier to the preceding view. |
| 62 | `                    .frame(maxHeight: 360)` | Constrains the view size or alignment. |
| 63 | `                    .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 10)` | Adds visual depth with a shadow. |
| 64 | `                    .scaleEffect(breatheEffect ? 1.015 : 0.985)` | Applies a SwiftUI modifier to the preceding view. |
| 65 | `                    .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: breatheEffect)` | Applies a SwiftUI modifier to the preceding view. |
| 66 | `                    .accessibilityHidden(true)` | Adds or removes accessibility semantics. |
| 67 | `                .frame(maxWidth: .infinity)` | Constrains the view size or alignment. |
| 68 | `                .padding(.vertical, 14)` | Adds layout spacing around the view. |
| 69 | `` | Blank line separating code sections. |
| 70 | `                Spacer()` | Implements the surrounding screen or view-builder expression. |
| 71 | `` | Blank line separating code sections. |
| 72 | `                // Bottom CTA Button ("Continue")` | Comment describing the purpose of the following code. |
| 73 | `                VStack {` | Opens or closes a Swift scope or view-builder block. |
| 74 | `                    PrimaryActionButton(title: "Continue") {` | Uses the shared primary call-to-action component. |
| 75 | `                        state.hasSeenDialSceneIntro = true` | Records that the Dial Scene introduction has been completed. |
| 76 | `                        if let onContinue {` | Conditionally uses an optional value when it exists. |
| 77 | `                            onContinue()` | Implements the surrounding screen or view-builder expression. |
| 78 | `                        } else {` | Opens or closes a Swift scope or view-builder block. |
| 79 | `                            state.navigate(to: .dialScene)` | Updates shared navigation state and moves to the requested screen. |
| 80 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 81 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 82 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 83 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 84 | `                .padding(.bottom, 24)` | Adds layout spacing around the view. |
| 85 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 86 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 87 | `        .onAppear {` | Runs initialization when the view appears. |
| 88 | `            breatheEffect = true` | Implements the surrounding screen or view-builder expression. |
| 89 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 90 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 91 | `}` | Opens or closes a Swift scope or view-builder block. |
| 92 | `` | Blank line separating code sections. |
| 93 | `// MARK: - Dial Scene` | Section marker organizing the screen implementation. |
| 94 | `/// Conversation practice unlocked alongside Picture Description.` | Comment describing the purpose of the following code. |
| 95 | `public struct DialSceneView: View {` | Declares a reusable public SwiftUI screen. |
| 96 | `    @Bindable public var state: AppState` | Connects the screen to the observable AppState for two-way mutation. |
| 97 | `` | Blank line separating code sections. |
| 98 | `    @State private var selectedScenario = "Ordering at a Café"` | Stores view-local state managed by SwiftUI. |
| 99 | `    @State private var stage: Stage` | Stores view-local state managed by SwiftUI. |
| 100 | `    @State private var isDAFActive: Bool = false` | Stores view-local state managed by SwiftUI. |
| 101 | `    @State private var isListening: Bool = false` | Stores view-local state managed by SwiftUI. |
| 102 | `    @State private var conversationStep = 0` | Stores view-local state managed by SwiftUI. |
| 103 | `` | Blank line separating code sections. |
| 104 | `    private enum Stage {` | Defines a private state-machine enum for the screen stages. |
| 105 | `        case intro` | Handles one state-machine or enum case. |
| 106 | `        case scenarios` | Handles one state-machine or enum case. |
| 107 | `        case conversation` | Handles one state-machine or enum case. |
| 108 | `        case analysis` | Handles one state-machine or enum case. |
| 109 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 110 | `` | Blank line separating code sections. |
| 111 | `    private let scenarios = [` | Declares immutable screen configuration data. |
| 112 | `        ("Ordering at a Café", "Practice placing your order.", "cup.and.saucer.fill"),` | Implements the surrounding screen or view-builder expression. |
| 113 | `        ("Ordering at a Restaurant", "Practice ordering a meal.", "fork.knife"),` | Implements the surrounding screen or view-builder expression. |
| 114 | `        ("Checking into a Hotel", "Build confidence checking in.", "building.2.fill"),` | Implements the surrounding screen or view-builder expression. |
| 115 | `        ("At a Hair Salon", "Practice common salon phrases.", "scissors"),` | Implements the surrounding screen or view-builder expression. |
| 116 | `        ("At a Grocery Store", "Practice asking for items.", "basket.fill")` | Implements the surrounding screen or view-builder expression. |
| 117 | `    ]` | Implements the surrounding screen or view-builder expression. |
| 118 | `` | Blank line separating code sections. |
| 119 | `    private let sampleWords = [` | Declares immutable screen configuration data. |
| 120 | `        "Medium", "Latte", "Vanilla", "Special", "Order", "Whole", "Please", "Morning"` | Implements the surrounding screen or view-builder expression. |
| 121 | `    ]` | Implements the surrounding screen or view-builder expression. |
| 122 | `` | Blank line separating code sections. |
| 123 | `    public init(state: AppState) {` | Initializes the screen with shared state and optional callbacks. |
| 124 | `        self.state = state` | Implements the surrounding screen or view-builder expression. |
| 125 | `        _stage = State(initialValue: state.hasSeenDialSceneIntro ? .scenarios : .intro)` | Records that the Dial Scene introduction has been completed. |
| 126 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 127 | `` | Blank line separating code sections. |
| 128 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 129 | `        ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 130 | `            StamerleeTheme.backgroundDark.ignoresSafeArea()` | Implements the surrounding screen or view-builder expression. |
| 131 | `            switch stage {` | Selects UI based on the current stage or value. |
| 132 | `            case .intro:` | Handles one state-machine or enum case. |
| 133 | `                DialSceneIntroView(` | Implements the surrounding screen or view-builder expression. |
| 134 | `                    state: state,` | Implements the surrounding screen or view-builder expression. |
| 135 | `                    onBack: {` | Opens or closes a Swift scope or view-builder block. |
| 136 | `                        state.navigate(to: .homeDashboard, forward: false)` | Updates shared navigation state and moves to the requested screen. |
| 137 | `                    },` | Implements the surrounding screen or view-builder expression. |
| 138 | `                    onContinue: {` | Opens or closes a Swift scope or view-builder block. |
| 139 | `                        state.hasSeenDialSceneIntro = true` | Records that the Dial Scene introduction has been completed. |
| 140 | `                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {` | Animates the enclosed state mutation. |
| 141 | `                            stage = .scenarios` | Implements the surrounding screen or view-builder expression. |
| 142 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 143 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 144 | `                )` | Implements the surrounding screen or view-builder expression. |
| 145 | `            case .scenarios:` | Handles one state-machine or enum case. |
| 146 | `                scenarioView` | Implements the surrounding screen or view-builder expression. |
| 147 | `            case .conversation:` | Handles one state-machine or enum case. |
| 148 | `                conversationView` | Implements the surrounding screen or view-builder expression. |
| 149 | `            case .analysis:` | Handles one state-machine or enum case. |
| 150 | `                analysisView` | Implements the surrounding screen or view-builder expression. |
| 151 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 152 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 153 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 154 | `` | Blank line separating code sections. |
| 155 | `    private var header: some View {` | Defines a computed helper view or value. |
| 156 | `        HStack {` | Opens or closes a Swift scope or view-builder block. |
| 157 | `            BackNavButton {` | Opens or closes a Swift scope or view-builder block. |
| 158 | `                if stage == .scenarios {` | Conditionally selects this behavior or view. |
| 159 | `                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {` | Animates the enclosed state mutation. |
| 160 | `                        stage = .intro` | Implements the surrounding screen or view-builder expression. |
| 161 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 162 | `                } else {` | Opens or closes a Swift scope or view-builder block. |
| 163 | `                    stage = .scenarios` | Implements the surrounding screen or view-builder expression. |
| 164 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 165 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 166 | `            Spacer()` | Implements the surrounding screen or view-builder expression. |
| 167 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 168 | `        .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 169 | `        .padding(.top, 16)` | Adds layout spacing around the view. |
| 170 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 171 | `` | Blank line separating code sections. |
| 172 | `    private var scenarioView: some View {` | Defines a computed helper view or value. |
| 173 | `        VStack(alignment: .leading, spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 174 | `            header` | Implements the surrounding screen or view-builder expression. |
| 175 | `            Text("Dial Scene")` | Displays a text label. |
| 176 | `                .font(.system(size: 30, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 177 | `                .foregroundStyle(.white)` | Sets the foreground color or style. |
| 178 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 179 | `                .padding(.top, 22)` | Adds layout spacing around the view. |
| 180 | `            Text("Practice real life conversations through\ninteractive scenarios.")` | Displays a text label. |
| 181 | `                .font(.system(size: 14, design: .rounded))` | Sets typography, size, weight, and design. |
| 182 | `                .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 183 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 184 | `                .padding(.top, 10)` | Adds layout spacing around the view. |
| 185 | `                .padding(.bottom, 24)` | Adds layout spacing around the view. |
| 186 | `` | Blank line separating code sections. |
| 187 | `            ScrollView(showsIndicators: false) {` | Opens or closes a Swift scope or view-builder block. |
| 188 | `                VStack(spacing: 10) {` | Opens or closes a Swift scope or view-builder block. |
| 189 | `                    ForEach(scenarios, id: \.0) { scenario in` | Creates repeated views from the scenario or message collection. |
| 190 | `                        Button {` | Creates an interactive button. |
| 191 | `                            selectedScenario = scenario.0` | Implements the surrounding screen or view-builder expression. |
| 192 | `                            stage = .conversation` | Implements the surrounding screen or view-builder expression. |
| 193 | `                        } label: {` | Opens or closes a Swift scope or view-builder block. |
| 194 | `                            HStack(spacing: 14) {` | Opens or closes a Swift scope or view-builder block. |
| 195 | `                                Image(systemName: scenario.2)` | Displays a system symbol or asset. |
| 196 | `                                    .font(.system(size: 20, weight: .semibold))` | Sets typography, size, weight, and design. |
| 197 | `                                    .foregroundStyle(.white)` | Sets the foreground color or style. |
| 198 | `                                    .frame(width: 36)` | Constrains the view size or alignment. |
| 199 | `                                VStack(alignment: .leading, spacing: 3) {` | Opens or closes a Swift scope or view-builder block. |
| 200 | `                                    Text(scenario.0)` | Displays a text label. |
| 201 | `                                        .font(.system(size: 14, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 202 | `                                    Text(scenario.1)` | Displays a text label. |
| 203 | `                                        .font(.system(size: 11, design: .rounded))` | Sets typography, size, weight, and design. |
| 204 | `                                        .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 205 | `                                }` | Opens or closes a Swift scope or view-builder block. |
| 206 | `                                .foregroundStyle(.white)` | Sets the foreground color or style. |
| 207 | `                                Spacer()` | Implements the surrounding screen or view-builder expression. |
| 208 | `                                Image(systemName: "phone.fill")` | Displays a system symbol or asset. |
| 209 | `                                    .foregroundStyle(.white)` | Sets the foreground color or style. |
| 210 | `                                    .padding(8)` | Adds layout spacing around the view. |
| 211 | `                                    .background(Color(red: 73 / 255, green: 65 / 255, blue: 174 / 255))` | Adds a background behind the content. |
| 212 | `                                    .clipShape(Circle())` | Clips content to a supplied shape. |
| 213 | `                            }` | Opens or closes a Swift scope or view-builder block. |
| 214 | `                            .padding(.horizontal, 16)` | Adds layout spacing around the view. |
| 215 | `                            .frame(height: 62)` | Constrains the view size or alignment. |
| 216 | `                            .background(Color.white.opacity(0.07))` | Adds a background behind the content. |
| 217 | `                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08)))` | Draws an additional view above the current view. |
| 218 | `                            .clipShape(RoundedRectangle(cornerRadius: 14))` | Clips content to a supplied shape. |
| 219 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 220 | `                        .buttonStyle(.haptic)` | Applies a SwiftUI modifier to the preceding view. |
| 221 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 222 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 223 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 224 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 225 | `            Spacer()` | Implements the surrounding screen or view-builder expression. |
| 226 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 227 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 228 | `` | Blank line separating code sections. |
| 229 | `    private var conversationView: some View {` | Defines a computed helper view or value. |
| 230 | `        VStack(alignment: .leading, spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 231 | `            HStack {` | Opens or closes a Swift scope or view-builder block. |
| 232 | `                header` | Implements the surrounding screen or view-builder expression. |
| 233 | `                Spacer()` | Implements the surrounding screen or view-builder expression. |
| 234 | `                Button {` | Creates an interactive button. |
| 235 | `                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {` | Animates the enclosed state mutation. |
| 236 | `                        isDAFActive.toggle()` | Implements the surrounding screen or view-builder expression. |
| 237 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 238 | `                } label: {` | Opens or closes a Swift scope or view-builder block. |
| 239 | `                    HStack(spacing: 5) {` | Opens or closes a Swift scope or view-builder block. |
| 240 | `                        Image(systemName: "headphones")` | Displays a system symbol or asset. |
| 241 | `                            .font(.system(size: 12, weight: .bold))` | Sets typography, size, weight, and design. |
| 242 | `                        Text("DAF")` | Displays a text label. |
| 243 | `                            .font(.system(size: 12, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 244 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 245 | `                    .foregroundStyle(.white)` | Sets the foreground color or style. |
| 246 | `                    .padding(.horizontal, 14)` | Adds layout spacing around the view. |
| 247 | `                    .padding(.vertical, 7)` | Adds layout spacing around the view. |
| 248 | `                    .background(isDAFActive ? StamerleeTheme.primaryBlue : StamerleeTheme.primaryBlueDark)` | Adds a background behind the content. |
| 249 | `                    .clipShape(Capsule())` | Clips content to a supplied shape. |
| 250 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 251 | `                .padding(.trailing, 24)` | Adds layout spacing around the view. |
| 252 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 253 | `            Text(selectedScenario)` | Displays a text label. |
| 254 | `                .font(.system(size: 22, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 255 | `                .foregroundStyle(.white)` | Sets the foreground color or style. |
| 256 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 257 | `                .padding(.top, 20)` | Adds layout spacing around the view. |
| 258 | `` | Blank line separating code sections. |
| 259 | `            VStack(alignment: .leading, spacing: 14) {` | Opens or closes a Swift scope or view-builder block. |
| 260 | `                ForEach(Array(conversationMessages.prefix(conversationStep + 1).enumerated()), id: \.offset) { _, message in` | Creates repeated views from the scenario or message collection. |
| 261 | `                    bubble(message.speaker, message.text, isUser: message.isUser)` | Implements the surrounding screen or view-builder expression. |
| 262 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 263 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 264 | `            .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 265 | `            .padding(.top, 24)` | Adds layout spacing around the view. |
| 266 | `` | Blank line separating code sections. |
| 267 | `            Spacer()` | Implements the surrounding screen or view-builder expression. |
| 268 | `` | Blank line separating code sections. |
| 269 | `            SpeechMicrophoneButton(isListening: $isListening) {` | Uses the shared microphone/listening control. |
| 270 | `                guard conversationStep + 1 < conversationMessages.count else { return }` | Requires a condition and exits early when it is false. |
| 271 | `                isListening = true` | Implements the surrounding screen or view-builder expression. |
| 272 | `                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {` | Animates the enclosed state mutation. |
| 273 | `                    conversationStep += 1` | Implements the surrounding screen or view-builder expression. |
| 274 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 275 | `                Task { @MainActor in` | Starts asynchronous work without blocking the UI. |
| 276 | `                    try? await Task.sleep(for: .milliseconds(500))` | Waits asynchronously before changing the listening state. |
| 277 | `                    isListening = false` | Implements the surrounding screen or view-builder expression. |
| 278 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 279 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 280 | `            .frame(maxWidth: .infinity)` | Constrains the view size or alignment. |
| 281 | `            .padding(.bottom, 24)` | Adds layout spacing around the view. |
| 282 | `` | Blank line separating code sections. |
| 283 | `            PrimaryActionButton(title: "Finish") {` | Uses the shared primary call-to-action component. |
| 284 | `                state.hasCompletedDialScene = true` | Implements the surrounding screen or view-builder expression. |
| 285 | `                stage = .analysis` | Implements the surrounding screen or view-builder expression. |
| 286 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 287 | `            .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 288 | `            .padding(.bottom, 24)` | Adds layout spacing around the view. |
| 289 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 290 | `        .sensoryFeedback(.impact(weight: .light), trigger: isDAFActive)` | Adds system haptic feedback driven by a state trigger. |
| 291 | `        .sensoryFeedback(.impact(weight: .heavy), trigger: isListening)` | Adds system haptic feedback driven by a state trigger. |
| 292 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 293 | `` | Blank line separating code sections. |
| 294 | `    private var conversationMessages: [(speaker: String, text: String, isUser: Bool)] {` | Defines a computed helper view or value. |
| 295 | `        [` | Implements the surrounding screen or view-builder expression. |
| 296 | `            ("Barista", "Hi! What can I get for you today?", false),` | Implements the surrounding screen or view-builder expression. |
| 297 | `            ("You", "A medium iced latte with whole milk and one pump of vanilla, please.", true),` | Implements the surrounding screen or view-builder expression. |
| 298 | `            ("Barista", "Of course! One medium iced vanilla latte. Anything else on the side?", false),` | Implements the surrounding screen or view-builder expression. |
| 299 | `            ("You", "What about today's special?", true)` | Implements the surrounding screen or view-builder expression. |
| 300 | `        ]` | Implements the surrounding screen or view-builder expression. |
| 301 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 302 | `` | Blank line separating code sections. |
| 303 | `    private func bubble(_ speaker: String, _ text: String, isUser: Bool) -> some View {` | Defines a private helper for view construction or behavior. |
| 304 | `        HStack {` | Opens or closes a Swift scope or view-builder block. |
| 305 | `            if isUser { Spacer() }` | Conditionally selects this behavior or view. |
| 306 | `            VStack(alignment: .leading, spacing: 4) {` | Opens or closes a Swift scope or view-builder block. |
| 307 | `                Text(speaker)` | Displays a text label. |
| 308 | `                    .font(.system(size: 11, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 309 | `                Text(text)` | Displays a text label. |
| 310 | `                    .font(.system(size: 13, design: .rounded))` | Sets typography, size, weight, and design. |
| 311 | `                    .lineSpacing(2)` | Applies a SwiftUI modifier to the preceding view. |
| 312 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 313 | `            .foregroundStyle(isUser ? .black : .white)` | Sets the foreground color or style. |
| 314 | `            .padding(14)` | Adds layout spacing around the view. |
| 315 | `            .background(isUser ? Color(red: 226 / 255, green: 229 / 255, blue: 250 / 255) : Color(red: 35 / 255, green: 39 / 255, blue: 78 / 255))` | Adds a background behind the content. |
| 316 | `            .clipShape(RoundedRectangle(cornerRadius: 14))` | Clips content to a supplied shape. |
| 317 | `            if !isUser { Spacer() }` | Conditionally selects this behavior or view. |
| 318 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 319 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 320 | `` | Blank line separating code sections. |
| 321 | `    private var analysisView: some View {` | Defines a computed helper view or value. |
| 322 | `        ExerciseAnalysisSkeletonView(` | Uses the shared analysis/results component. |
| 323 | `            scoreText: "8.4",` | Implements the surrounding screen or view-builder expression. |
| 324 | `            maxScoreText: "/ 10",` | Implements the surrounding screen or view-builder expression. |
| 325 | `            subtitle: "Here's a summary of your conversation.",` | Implements the surrounding screen or view-builder expression. |
| 326 | `            affirmation: "Great progress today!",` | Implements the surrounding screen or view-builder expression. |
| 327 | `            onDone: {` | Opens or closes a Swift scope or view-builder block. |
| 328 | `                state.navigate(to: .homeDashboard)` | Updates shared navigation state and moves to the requested screen. |
| 329 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 330 | `        )` | Implements the surrounding screen or view-builder expression. |
| 331 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 332 | `}` | Opens or closes a Swift scope or view-builder block. |
| 333 | `` | Blank line separating code sections. |
| 334 | `` | Blank line separating code sections. |
| 335 | `#Preview("Dial Scene") {` | Declares a modern SwiftUI preview. |
| 336 | `    DialSceneView(` | Implements the surrounding screen or view-builder expression. |
| 337 | `        state: AppState()` | Implements the surrounding screen or view-builder expression. |
| 338 | `    )` | Implements the surrounding screen or view-builder expression. |
| 339 | `}` | Opens or closes a Swift scope or view-builder block. |

### `Stamerlee/NarrationDifficultyView.swift` (26 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports the framework needed by this source file. |
| 2 | `` | Blank line separating code sections. |
| 3 | `// MARK: - Narration Intro View` | Section marker organizing the screen implementation. |
| 4 | `/// Introduces the Narration with Mirror practice technique.` | Comment describing the purpose of the following code. |
| 5 | `public struct NarrationIntroView: View {` | Declares a reusable public SwiftUI screen. |
| 6 | `    @Bindable public var state: AppState` | Connects the screen to the observable AppState for two-way mutation. |
| 7 | `` | Blank line separating code sections. |
| 8 | `    public init(state: AppState) {` | Initializes the screen with shared state and optional callbacks. |
| 9 | `        self.state = state` | Implements the surrounding screen or view-builder expression. |
| 10 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 11 | `` | Blank line separating code sections. |
| 12 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 13 | `        ExerciseIntroSkeletonView(` | Implements the surrounding screen or view-builder expression. |
| 14 | `            title: "Let's start with\nNarration with Mirror",` | Implements the surrounding screen or view-builder expression. |
| 15 | `            subtitle: "Look at yourself in the mirror and narrate your thoughts aloud to practice self-expression, become more comfortable speaking and build confidence.",` | Implements the surrounding screen or view-builder expression. |
| 16 | `            heroImageName: "NarrationHero",` | Implements the surrounding screen or view-builder expression. |
| 17 | `            onBack: {` | Opens or closes a Swift scope or view-builder block. |
| 18 | `                state.navigate(to: .homeDashboard, forward: false)` | Updates shared navigation state and moves to the requested screen. |
| 19 | `            },` | Implements the surrounding screen or view-builder expression. |
| 20 | `            onContinue: {` | Opens or closes a Swift scope or view-builder block. |
| 21 | `                state.hasSeenNarrationIntro = true` | Implements the surrounding screen or view-builder expression. |
| 22 | `                state.navigate(to: .narrationPractice)` | Updates shared navigation state and moves to the requested screen. |
| 23 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 24 | `        )` | Implements the surrounding screen or view-builder expression. |
| 25 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 26 | `}` | Opens or closes a Swift scope or view-builder block. |

## Related modern-code note

`DialSceneView` and `NarrationIntroView` rely on shared components in [Components.swift](./Components.swift), especially `BackNavButton`, `PrimaryActionButton`, `SpeechMicrophoneButton`, and `ExerciseAnalysisSkeletonView`. The narration practice screen additionally uses AVFoundation through `UIViewRepresentable`; that camera implementation should keep session start/stop work off the main thread and handle denied permission explicitly.

## Recommendations

- Move scenario tuples into a typed `Scenario` model with stable IDs instead of using tuple offsets and `\.0` identity.
- Store the speech task in a cancellable `Task` property if real listening becomes asynchronous.
- Add a user-facing permission-denied state for camera/microphone access.
- Rename `NarrationDifficultyView.swift` to match `NarrationIntroView`.
