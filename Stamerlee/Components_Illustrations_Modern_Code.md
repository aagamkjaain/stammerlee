# Components and Illustrations: Modern SwiftUI Review

This document explains the reusable controls and illustration views shown in the supplied screenshot. It includes a line-by-line explanation and a compatibility review.

## Modern-code check

The files use current SwiftUI patterns overall. No definite deprecated API is identifiable from source inspection alone.

- `ButtonStyle`, `View`, `@State`, `@Binding`, `@ViewBuilder`, `NavigationStack`, `LazyVGrid`, and `sensoryFeedback` are modern SwiftUI constructs.
- `.sensoryFeedback` is preferable to manually creating UIKit haptic generators for these interactions.
- `@available(iOS 26.0, *)` branches for `.buttonStyle(.glass(...))` are appropriate availability handling; retain the older fallback.
- `CircularProgressViewStyle(tint:)` is not definitely deprecated, but `.tint(.white)` may be a simpler modern alternative when the deployment target supports it.
- `UIImage(data:)` is a current UIKit API. The explicit `import UIKit` dependency should be retained if this file is compiled independently.
- `MatchedGeometryProperties`, `Namespace.ID`, and `matchedGeometryEffect` remain appropriate for optional matched-geometry transitions.
- The illustration views correctly mark decorative images with `.accessibilityHidden(true)`; add accessible labels only if the artwork conveys information not present in nearby text.

## Component inventory

| Component | Purpose |
|---|---|
| `HapticButtonStyle` | Press scaling and system haptic feedback. |
| `PrimaryActionButton` | Shared Continue/Begin/Done CTA with loading and availability-aware styling. |
| `SocialAuthRow` | Apple, Google, and email sign-in rows. |
| `BackNavButton` | Consistent back navigation control. |
| `OptionSelectRow` / `DifficultyCard` | Selection and difficulty UI. |
| `ExerciseIntroSkeletonView` | Shared exercise introduction layout. |
| `SpeechMicrophoneButton` | Speech start/listening control. |
| `ExerciseAnalysisSkeletonView` | Score, word selection, sheet, and completion UI. |
| `ProfileAvatar` | Image-backed or generated profile avatar. |
| `OnboardingStepOneIllustration` / `OnboardingStepTwoIllustration` | Animated decorative onboarding artwork. |

## Line-by-line explanation

### `Stamerlee/Components.swift` (879 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports SwiftUI for declarative views and modifiers. |
| 2 | `` | Blank line separating code sections. |
| 3 | `// MARK: - Haptic Button Style` | Section marker organizing the reusable component code. |
| 4 | `/// Native button style that plays a haptic when the button is pressed and optionally` | Comment describing the purpose of the following code. |
| 5 | `/// scales the label while pressed. Uses \`configuration.isPressed\` and \`.sensoryFeedback\`` | Comment describing the purpose of the following code. |
| 6 | `/// instead of UIKit feedback generators or custom drag gestures.` | Comment describing the purpose of the following code. |
| 7 | `public struct HapticButtonStyle: ButtonStyle {` | Declares a reusable public SwiftUI view or button style. |
| 8 | `    public var weight: SensoryFeedback.Weight` | Declares public component configuration or state. |
| 9 | `    public var pressedScale: CGFloat` | Declares public component configuration or state. |
| 10 | `` | Blank line separating code sections. |
| 11 | `    public init(weight: SensoryFeedback.Weight = .light, pressedScale: CGFloat = 1) {` | Initializes the component and assigns its configuration values. |
| 12 | `        self.weight = weight` | Implements the surrounding component or view-builder expression. |
| 13 | `        self.pressedScale = pressedScale` | Implements the surrounding component or view-builder expression. |
| 14 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 15 | `` | Blank line separating code sections. |
| 16 | `    public func makeBody(configuration: Configuration) -> some View {` | Opens or closes a Swift scope or view-builder block. |
| 17 | `        configuration.label` | Implements the surrounding component or view-builder expression. |
| 18 | `            .scaleEffect(configuration.isPressed ? pressedScale : 1)` | Applies a SwiftUI modifier to the preceding view. |
| 19 | `            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)` | Associates an animation with changes to the supplied value. |
| 20 | `            .sensoryFeedback(trigger: configuration.isPressed) { _, isPressed in` | Adds system haptic feedback driven by a state trigger. |
| 21 | `                isPressed ? .impact(weight: weight) : nil` | Implements the surrounding component or view-builder expression. |
| 22 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 23 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 24 | `}` | Opens or closes a Swift scope or view-builder block. |
| 25 | `` | Blank line separating code sections. |
| 26 | `public extension ButtonStyle where Self == HapticButtonStyle {` | Adds public convenience API to an existing SwiftUI type. |
| 27 | `    /// Light haptic on press, no scaling (drop-in replacement for \`.plain\`).` | Comment describing the purpose of the following code. |
| 28 | `    static var haptic: HapticButtonStyle { HapticButtonStyle() }` | Implements the surrounding component or view-builder expression. |
| 29 | `` | Blank line separating code sections. |
| 30 | `    static func haptic(weight: SensoryFeedback.Weight = .light, pressedScale: CGFloat = 1) -> HapticButtonStyle {` | Opens or closes a Swift scope or view-builder block. |
| 31 | `        HapticButtonStyle(weight: weight, pressedScale: pressedScale)` | Implements the surrounding component or view-builder expression. |
| 32 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 33 | `}` | Opens or closes a Swift scope or view-builder block. |
| 34 | `` | Blank line separating code sections. |
| 35 | `// MARK: - Primary Action Button` | Section marker organizing the reusable component code. |
| 36 | `/// Vibrant blue pill button used for "Begin" and "Continue" actions across screens.` | Comment describing the purpose of the following code. |
| 37 | `public struct PrimaryActionButton: View {` | Declares a reusable public SwiftUI view or button style. |
| 38 | `    public let title: String` | Declares public component configuration or state. |
| 39 | `    public let icon: String?` | Declares public component configuration or state. |
| 40 | `    public let isEnabled: Bool` | Declares public component configuration or state. |
| 41 | `    public let isLoading: Bool` | Declares public component configuration or state. |
| 42 | `    public let compact: Bool` | Declares public component configuration or state. |
| 43 | `    public let action: () -> Void` | Declares public component configuration or state. |
| 44 | `` | Blank line separating code sections. |
| 45 | `    public init(` | Initializes the component and assigns its configuration values. |
| 46 | `        title: String,` | Implements the surrounding component or view-builder expression. |
| 47 | `        icon: String? = nil,` | Implements the surrounding component or view-builder expression. |
| 48 | `        isEnabled: Bool = true,` | Implements the surrounding component or view-builder expression. |
| 49 | `        isLoading: Bool = false,` | Implements the surrounding component or view-builder expression. |
| 50 | `        compact: Bool = false,` | Implements the surrounding component or view-builder expression. |
| 51 | `        action: @escaping () -> Void` | Implements the surrounding component or view-builder expression. |
| 52 | `    ) {` | Opens or closes a Swift scope or view-builder block. |
| 53 | `        self.title = title` | Implements the surrounding component or view-builder expression. |
| 54 | `        self.icon = icon` | Implements the surrounding component or view-builder expression. |
| 55 | `        self.isEnabled = isEnabled` | Implements the surrounding component or view-builder expression. |
| 56 | `        self.isLoading = isLoading` | Implements the surrounding component or view-builder expression. |
| 57 | `        self.compact = compact` | Implements the surrounding component or view-builder expression. |
| 58 | `        self.action = action` | Implements the surrounding component or view-builder expression. |
| 59 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 60 | `` | Blank line separating code sections. |
| 61 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 62 | `        if #available(iOS 26.0, *) {` | Selects an implementation based on operating-system availability. |
| 63 | `            Button(action: action) { label }` | Creates an accessible interactive button. |
| 64 | `                .buttonStyle(.glass(.regular.tint(StamerleeTheme.primaryBlue).interactive()))` | Applies a SwiftUI modifier to the preceding view. |
| 65 | `                .buttonBorderShape(.capsule)` | Applies a SwiftUI modifier to the preceding view. |
| 66 | `                .frame(maxWidth: .infinity)` | Constrains the view’s size or alignment. |
| 67 | `                .disabled(!isEnabled \|\| isLoading)` | Applies a SwiftUI modifier to the preceding view. |
| 68 | `        } else {` | Opens or closes a Swift scope or view-builder block. |
| 69 | `            Button(action: action) { label }` | Creates an accessible interactive button. |
| 70 | `                .buttonStyle(.haptic(weight: .medium, pressedScale: 0.97))` | Applies a SwiftUI modifier to the preceding view. |
| 71 | `                .disabled(!isEnabled \|\| isLoading)` | Applies a SwiftUI modifier to the preceding view. |
| 72 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 73 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 74 | `` | Blank line separating code sections. |
| 75 | `    private var label: some View {` | Defines a private computed property used by the component. |
| 76 | `        HStack(spacing: compact ? 6 : 8) {` | Opens or closes a Swift scope or view-builder block. |
| 77 | `            if isLoading {` | Conditionally renders or executes this branch. |
| 78 | `                ProgressView()` | Displays progress while an operation is loading. |
| 79 | `                    .progressViewStyle(CircularProgressViewStyle(tint: .white))` | Applies a SwiftUI modifier to the preceding view. |
| 80 | `                    .scaleEffect(compact ? 0.8 : 0.9)` | Applies a SwiftUI modifier to the preceding view. |
| 81 | `            } else {` | Opens or closes a Swift scope or view-builder block. |
| 82 | `                if let icon = icon {` | Conditionally renders or executes this branch. |
| 83 | `                    Image(systemName: icon)` | Displays an image asset or SF Symbol. |
| 84 | `                        .font(.system(size: compact ? 13 : 16, weight: .bold))` | Sets typography, size, weight, and design. |
| 85 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 86 | `                Text(title)` | Displays a text label. |
| 87 | `                    .font(.system(size: compact ? 15 : 16, weight: .semibold, design: .rounded))` | Sets typography, size, weight, and design. |
| 88 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 89 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 90 | `        .foregroundStyle(.white)` | Sets the foreground color or style. |
| 91 | `        .frame(maxWidth: .infinity, minHeight: compact ? 44 : 52)` | Constrains the view’s size or alignment. |
| 92 | `        .background {` | Adds a background view behind the content. |
| 93 | `            if #available(iOS 26.0, *) {` | Selects an implementation based on operating-system availability. |
| 94 | `                // glass style owns the background` | Comment describing the purpose of the following code. |
| 95 | `                Color.clear` | Implements the surrounding component or view-builder expression. |
| 96 | `            } else {` | Opens or closes a Swift scope or view-builder block. |
| 97 | `                Group {` | Opens or closes a Swift scope or view-builder block. |
| 98 | `                    if isEnabled {` | Conditionally renders or executes this branch. |
| 99 | `                        StamerleeTheme.primaryBlue` | Implements the surrounding component or view-builder expression. |
| 100 | `                    } else {` | Opens or closes a Swift scope or view-builder block. |
| 101 | `                        StamerleeTheme.primaryBlue.opacity(0.4)` | Implements the surrounding component or view-builder expression. |
| 102 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 103 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 104 | `                .clipShape(Capsule())` | Clips the view to the supplied shape. |
| 105 | `                .shadow(color: isEnabled ? StamerleeTheme.primaryBlue.opacity(0.3) : .clear, radius: 10, x: 0, y: 5)` | Adds visual depth with a shadow. |
| 106 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 107 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 108 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 109 | `}` | Opens or closes a Swift scope or view-builder block. |
| 110 | `` | Blank line separating code sections. |
| 111 | `// MARK: - Social Auth Button Style` | Section marker organizing the reusable component code. |
| 112 | `public enum SocialAuthType {` | Declares a public enum representing a closed set of UI options. |
| 113 | `    case apple` | Handles one enum case. |
| 114 | `    case google` | Handles one enum case. |
| 115 | `    case email` | Handles one enum case. |
| 116 | `    ` | Blank line separating code sections. |
| 117 | `    var title: String {` | Declares a mutable or computed value. |
| 118 | `        switch self {` | Selects behavior based on the current enum or style value. |
| 119 | `        case .apple: return "Continue with Apple"` | Handles one enum case. |
| 120 | `        case .google: return "Continue with Google"` | Handles one enum case. |
| 121 | `        case .email: return "Continue with Email"` | Handles one enum case. |
| 122 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 123 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 124 | `}` | Opens or closes a Swift scope or view-builder block. |
| 125 | `` | Blank line separating code sections. |
| 126 | `// MARK: - Social Auth Button` | Section marker organizing the reusable component code. |
| 127 | `public struct SocialAuthRow: View {` | Declares a reusable public SwiftUI view or button style. |
| 128 | `    public let type: SocialAuthType` | Declares public component configuration or state. |
| 129 | `    public let action: () -> Void` | Declares public component configuration or state. |
| 130 | `` | Blank line separating code sections. |
| 131 | `    public init(type: SocialAuthType, action: @escaping () -> Void) {` | Initializes the component and assigns its configuration values. |
| 132 | `        self.type = type` | Implements the surrounding component or view-builder expression. |
| 133 | `        self.action = action` | Implements the surrounding component or view-builder expression. |
| 134 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 135 | `` | Blank line separating code sections. |
| 136 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 137 | `        if #available(iOS 26.0, *) {` | Selects an implementation based on operating-system availability. |
| 138 | `            Button(action: action) { rowContent }` | Creates an accessible interactive button. |
| 139 | `                .buttonStyle(.glass(.regular.tint(StamerleeTheme.cardLight).interactive()))` | Applies a SwiftUI modifier to the preceding view. |
| 140 | `                .buttonBorderShape(.roundedRectangle(radius: 14))` | Applies a SwiftUI modifier to the preceding view. |
| 141 | `                .frame(maxWidth: .infinity)` | Constrains the view’s size or alignment. |
| 142 | `        } else {` | Opens or closes a Swift scope or view-builder block. |
| 143 | `            Button(action: action) { rowContent }` | Creates an accessible interactive button. |
| 144 | `                .buttonStyle(.haptic(pressedScale: 0.98))` | Applies a SwiftUI modifier to the preceding view. |
| 145 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 146 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 147 | `` | Blank line separating code sections. |
| 148 | `    private var rowContent: some View {` | Defines a private computed property used by the component. |
| 149 | `        HStack(spacing: 14) {` | Opens or closes a Swift scope or view-builder block. |
| 150 | `            // Leading Icon` | Comment describing the purpose of the following code. |
| 151 | `            iconView` | Implements the surrounding component or view-builder expression. |
| 152 | `                .frame(width: 24, height: 24)` | Constrains the view’s size or alignment. |
| 153 | `` | Blank line separating code sections. |
| 154 | `            // Title` | Comment describing the purpose of the following code. |
| 155 | `            Text(type.title)` | Displays a text label. |
| 156 | `                .font(.system(size: 15, weight: .medium, design: .rounded))` | Sets typography, size, weight, and design. |
| 157 | `                .foregroundStyle(StamerleeTheme.textPrimaryLight)` | Sets the foreground color or style. |
| 158 | `` | Blank line separating code sections. |
| 159 | `            Spacer()` | Implements the surrounding component or view-builder expression. |
| 160 | `` | Blank line separating code sections. |
| 161 | `            // Trailing Chevron` | Comment describing the purpose of the following code. |
| 162 | `            Image(systemName: "chevron.right")` | Displays an image asset or SF Symbol. |
| 163 | `                .font(.system(size: 13, weight: .semibold))` | Sets typography, size, weight, and design. |
| 164 | `                .foregroundStyle(Color.gray.opacity(0.6))` | Sets the foreground color or style. |
| 165 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 166 | `        .padding(.horizontal, 18)` | Adds spacing around the view. |
| 167 | `        .frame(maxWidth: .infinity, minHeight: 65, alignment: .leading)` | Constrains the view’s size or alignment. |
| 168 | `        .background {` | Adds a background view behind the content. |
| 169 | `            if #available(iOS 26.0, *) {` | Selects an implementation based on operating-system availability. |
| 170 | `                Color.clear` | Implements the surrounding component or view-builder expression. |
| 171 | `            } else {` | Opens or closes a Swift scope or view-builder block. |
| 172 | `                RoundedRectangle(cornerRadius: 14, style: .continuous)` | Implements the surrounding component or view-builder expression. |
| 173 | `                    .fill(StamerleeTheme.cardLight)` | Applies a SwiftUI modifier to the preceding view. |
| 174 | `                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)` | Adds visual depth with a shadow. |
| 175 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 176 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 177 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 178 | `    ` | Blank line separating code sections. |
| 179 | `    @ViewBuilder` | Enables conditional and multi-view result-builder syntax. |
| 180 | `    private var iconView: some View {` | Defines a private computed property used by the component. |
| 181 | `        switch type {` | Selects behavior based on the current enum or style value. |
| 182 | `        case .apple:` | Handles one enum case. |
| 183 | `            Image(systemName: "applelogo")` | Displays an image asset or SF Symbol. |
| 184 | `                .font(.system(size: 20, weight: .semibold))` | Sets typography, size, weight, and design. |
| 185 | `                .foregroundStyle(.black)` | Sets the foreground color or style. |
| 186 | `        case .google:` | Handles one enum case. |
| 187 | `            Image("googlesvg")` | Displays an image asset or SF Symbol. |
| 188 | `                .resizable()` | Applies a SwiftUI modifier to the preceding view. |
| 189 | `                .frame(width: 20, height: 20)` | Constrains the view’s size or alignment. |
| 190 | `    ` | Blank line separating code sections. |
| 191 | `            ` | Blank line separating code sections. |
| 192 | `        case .email:` | Handles one enum case. |
| 193 | `            Image(systemName: "envelope")` | Displays an image asset or SF Symbol. |
| 194 | `                .font(.system(size: 17, weight: .semibold))` | Sets typography, size, weight, and design. |
| 195 | `                .foregroundStyle(StamerleeTheme.primaryBlue)` | Sets the foreground color or style. |
| 196 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 197 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 198 | `}` | Opens or closes a Swift scope or view-builder block. |
| 199 | `` | Blank line separating code sections. |
| 200 | `// MARK: - Back Navigation Button` | Section marker organizing the reusable component code. |
| 201 | `public struct BackNavButton: View {` | Declares a reusable public SwiftUI view or button style. |
| 202 | `    public let action: () -> Void` | Declares public component configuration or state. |
| 203 | `    ` | Blank line separating code sections. |
| 204 | `    public init(action: @escaping () -> Void) {` | Initializes the component and assigns its configuration values. |
| 205 | `        self.action = action` | Implements the surrounding component or view-builder expression. |
| 206 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 207 | `    ` | Blank line separating code sections. |
| 208 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 209 | `        Button(action: action) {` | Creates an accessible interactive button. |
| 210 | `            ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 211 | `                Circle()` | Implements the surrounding component or view-builder expression. |
| 212 | `                    .fill(Color.white.opacity(0.14))` | Applies a SwiftUI modifier to the preceding view. |
| 213 | `                    .frame(width: 38, height: 38)` | Constrains the view’s size or alignment. |
| 214 | `                ` | Blank line separating code sections. |
| 215 | `                Image(systemName: "chevron.left")` | Displays an image asset or SF Symbol. |
| 216 | `                    .font(.system(size: 15, weight: .bold))` | Sets typography, size, weight, and design. |
| 217 | `                    .foregroundStyle(.white)` | Sets the foreground color or style. |
| 218 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 219 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 220 | `        .buttonStyle(.haptic)` | Applies a SwiftUI modifier to the preceding view. |
| 221 | `        .accessibilityLabel("Go Back")` | Provides or adjusts accessibility semantics. |
| 222 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 223 | `}` | Opens or closes a Swift scope or view-builder block. |
| 224 | `` | Blank line separating code sections. |
| 225 | `// MARK: - Option Selection Row (Radio / Checkmark)` | Section marker organizing the reusable component code. |
| 226 | `public struct SoundOption: Hashable {` | Declares a reusable public SwiftUI view or button style. |
| 227 | `    public let title: String` | Declares public component configuration or state. |
| 228 | `    public let subtitle: String?` | Declares public component configuration or state. |
| 229 | `` | Blank line separating code sections. |
| 230 | `    public init(title: String, subtitle: String? = nil) {` | Initializes the component and assigns its configuration values. |
| 231 | `        self.title = title` | Implements the surrounding component or view-builder expression. |
| 232 | `        self.subtitle = subtitle` | Implements the surrounding component or view-builder expression. |
| 233 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 234 | `}` | Opens or closes a Swift scope or view-builder block. |
| 235 | `` | Blank line separating code sections. |
| 236 | `public struct OptionSelectRow: View {` | Declares a reusable public SwiftUI view or button style. |
| 237 | `    public let option: SoundOption` | Declares public component configuration or state. |
| 238 | `    public let isSelected: Bool` | Declares public component configuration or state. |
| 239 | `    public let onSelect: () -> Void` | Declares public component configuration or state. |
| 240 | `    ` | Blank line separating code sections. |
| 241 | `    public init(option: SoundOption, isSelected: Bool, onSelect: @escaping () -> Void) {` | Initializes the component and assigns its configuration values. |
| 242 | `        self.option = option` | Implements the surrounding component or view-builder expression. |
| 243 | `        self.isSelected = isSelected` | Implements the surrounding component or view-builder expression. |
| 244 | `        self.onSelect = onSelect` | Implements the surrounding component or view-builder expression. |
| 245 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 246 | `` | Blank line separating code sections. |
| 247 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 248 | `        Button(action: {` | Creates an accessible interactive button. |
| 249 | `            onSelect()` | Implements the surrounding component or view-builder expression. |
| 250 | `        }) {` | Opens or closes a Swift scope or view-builder block. |
| 251 | `            HStack(spacing: 12) {` | Opens or closes a Swift scope or view-builder block. |
| 252 | `                // Title and optional example subtitle` | Comment describing the purpose of the following code. |
| 253 | `                VStack(alignment: .leading, spacing: 3) {` | Opens or closes a Swift scope or view-builder block. |
| 254 | `                    if let subtitle = option.subtitle {` | Conditionally renders or executes this branch. |
| 255 | `                        HStack(spacing: 4) {` | Opens or closes a Swift scope or view-builder block. |
| 256 | `                            Text(option.title)` | Displays a text label. |
| 257 | `                                .font(.system(size: 15, weight: .semibold, design: .rounded))` | Sets typography, size, weight, and design. |
| 258 | `                                .foregroundStyle(StamerleeTheme.textPrimaryLight)` | Sets the foreground color or style. |
| 259 | `                            ` | Blank line separating code sections. |
| 260 | `                            Text("(\(subtitle))")` | Displays a text label. |
| 261 | `                                .font(.system(size: 14, weight: .regular, design: .rounded))` | Sets typography, size, weight, and design. |
| 262 | `                                .foregroundStyle(StamerleeTheme.textSecondaryLight)` | Sets the foreground color or style. |
| 263 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 264 | `                    } else {` | Opens or closes a Swift scope or view-builder block. |
| 265 | `                        Text(option.title)` | Displays a text label. |
| 266 | `                            .font(.system(size: 15, weight: .medium, design: .rounded))` | Sets typography, size, weight, and design. |
| 267 | `                            .foregroundStyle(StamerleeTheme.textPrimaryLight)` | Sets the foreground color or style. |
| 268 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 269 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 270 | `                ` | Blank line separating code sections. |
| 271 | `                Spacer()` | Implements the surrounding component or view-builder expression. |
| 272 | `                ` | Blank line separating code sections. |
| 273 | `                // Custom Radio / Checked Indicator` | Comment describing the purpose of the following code. |
| 274 | `                ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 275 | `                    if isSelected {` | Conditionally renders or executes this branch. |
| 276 | `                        Circle()` | Implements the surrounding component or view-builder expression. |
| 277 | `                            .fill(StamerleeTheme.primaryBlue)` | Applies a SwiftUI modifier to the preceding view. |
| 278 | `                            .frame(width: 22, height: 22)` | Constrains the view’s size or alignment. |
| 279 | `                        ` | Blank line separating code sections. |
| 280 | `                        Image(systemName: "checkmark")` | Displays an image asset or SF Symbol. |
| 281 | `                            .font(.system(size: 11, weight: .bold))` | Sets typography, size, weight, and design. |
| 282 | `                            .foregroundStyle(.white)` | Sets the foreground color or style. |
| 283 | `                            .transition(.scale.combined(with: .opacity))` | Applies a SwiftUI modifier to the preceding view. |
| 284 | `                    } else {` | Opens or closes a Swift scope or view-builder block. |
| 285 | `                        Circle()` | Implements the surrounding component or view-builder expression. |
| 286 | `                            .stroke(Color(red: 210 / 255, green: 215 / 255, blue: 228 / 255), lineWidth: 1.8)` | Applies a SwiftUI modifier to the preceding view. |
| 287 | `                            .frame(width: 22, height: 22)` | Constrains the view’s size or alignment. |
| 288 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 289 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 290 | `                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)` | Associates an animation with changes to the supplied value. |
| 291 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 292 | `            .padding(.vertical, 14)` | Adds spacing around the view. |
| 293 | `            .padding(.horizontal, 16)` | Adds spacing around the view. |
| 294 | `            .background(` | Adds a background view behind the content. |
| 295 | `                RoundedRectangle(cornerRadius: 12, style: .continuous)` | Implements the surrounding component or view-builder expression. |
| 296 | `                    .fill(isSelected ? StamerleeTheme.primaryBlue.opacity(0.06) : Color.clear)` | Applies a SwiftUI modifier to the preceding view. |
| 297 | `            )` | Implements the surrounding component or view-builder expression. |
| 298 | `            .contentShape(Rectangle())` | Applies a SwiftUI modifier to the preceding view. |
| 299 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 300 | `        .buttonStyle(.haptic)` | Applies a SwiftUI modifier to the preceding view. |
| 301 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 302 | `}` | Opens or closes a Swift scope or view-builder block. |
| 303 | `` | Blank line separating code sections. |
| 304 | `// MARK: - Universal Difficulty Card` | Section marker organizing the reusable component code. |
| 305 | `public struct DifficultyCard: View {` | Declares a reusable public SwiftUI view or button style. |
| 306 | `    public let title: String` | Declares public component configuration or state. |
| 307 | `    public let isLocked: Bool` | Declares public component configuration or state. |
| 308 | `    public let isCompleted: Bool` | Declares public component configuration or state. |
| 309 | `    public let action: () -> Void` | Declares public component configuration or state. |
| 310 | `` | Blank line separating code sections. |
| 311 | `    public init(` | Initializes the component and assigns its configuration values. |
| 312 | `        title: String,` | Implements the surrounding component or view-builder expression. |
| 313 | `        isLocked: Bool,` | Implements the surrounding component or view-builder expression. |
| 314 | `        isCompleted: Bool,` | Implements the surrounding component or view-builder expression. |
| 315 | `        action: @escaping () -> Void` | Implements the surrounding component or view-builder expression. |
| 316 | `    ) {` | Opens or closes a Swift scope or view-builder block. |
| 317 | `        self.title = title` | Implements the surrounding component or view-builder expression. |
| 318 | `        self.isLocked = isLocked` | Implements the surrounding component or view-builder expression. |
| 319 | `        self.isCompleted = isCompleted` | Implements the surrounding component or view-builder expression. |
| 320 | `        self.action = action` | Implements the surrounding component or view-builder expression. |
| 321 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 322 | `` | Blank line separating code sections. |
| 323 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 324 | `        Button {` | Creates an accessible interactive button. |
| 325 | `            action()` | Implements the surrounding component or view-builder expression. |
| 326 | `        } label: {` | Opens or closes a Swift scope or view-builder block. |
| 327 | `            ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 328 | `                Text(title)` | Displays a text label. |
| 329 | `                    .font(.system(size: 16, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 330 | `                    .foregroundStyle(StamerleeTheme.textPrimaryLight)` | Sets the foreground color or style. |
| 331 | `` | Blank line separating code sections. |
| 332 | `                HStack {` | Opens or closes a Swift scope or view-builder block. |
| 333 | `                    badge` | Implements the surrounding component or view-builder expression. |
| 334 | `                    Spacer()` | Implements the surrounding component or view-builder expression. |
| 335 | `                    if isCompleted {` | Conditionally renders or executes this branch. |
| 336 | `                        Image(systemName: "checkmark.circle.fill")` | Displays an image asset or SF Symbol. |
| 337 | `                            .font(.system(size: 18, weight: .semibold))` | Sets typography, size, weight, and design. |
| 338 | `                            .foregroundStyle(StamerleeTheme.primaryBlue)` | Sets the foreground color or style. |
| 339 | `                            .frame(width: 30, alignment: .trailing)` | Constrains the view’s size or alignment. |
| 340 | `                    } else if !isLocked {` | Opens or closes a Swift scope or view-builder block. |
| 341 | `                        Image(systemName: "chevron.right")` | Displays an image asset or SF Symbol. |
| 342 | `                            .font(.system(size: 14, weight: .semibold))` | Sets typography, size, weight, and design. |
| 343 | `                            .foregroundStyle(.gray.opacity(0.5))` | Sets the foreground color or style. |
| 344 | `                            .frame(width: 30, alignment: .trailing)` | Constrains the view’s size or alignment. |
| 345 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 346 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 347 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 348 | `            .padding(.horizontal, 14)` | Adds spacing around the view. |
| 349 | `            .frame(height: 72)` | Constrains the view’s size or alignment. |
| 350 | `            .background(Color(red: 238 / 255, green: 240 / 255, blue: 250 / 255))` | Adds a background view behind the content. |
| 351 | `            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))` | Clips the view to the supplied shape. |
| 352 | `            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)` | Adds visual depth with a shadow. |
| 353 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 354 | `        .buttonStyle(.haptic)` | Applies a SwiftUI modifier to the preceding view. |
| 355 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 356 | `` | Blank line separating code sections. |
| 357 | `    @ViewBuilder` | Enables conditional and multi-view result-builder syntax. |
| 358 | `    private var badge: some View {` | Defines a private computed property used by the component. |
| 359 | `        if isLocked {` | Conditionally renders or executes this branch. |
| 360 | `            Image(systemName: "lock.fill")` | Displays an image asset or SF Symbol. |
| 361 | `                .font(.system(size: 15, weight: .bold))` | Sets typography, size, weight, and design. |
| 362 | `                .foregroundStyle(.white)` | Sets the foreground color or style. |
| 363 | `                .frame(width: 38, height: 38)` | Constrains the view’s size or alignment. |
| 364 | `                .background(Color(red: 90 / 255, green: 105 / 255, blue: 180 / 255))` | Adds a background view behind the content. |
| 365 | `                .clipShape(Circle())` | Clips the view to the supplied shape. |
| 366 | `        } else {` | Opens or closes a Swift scope or view-builder block. |
| 367 | `            Color.clear` | Implements the surrounding component or view-builder expression. |
| 368 | `                .frame(width: 38, height: 38)` | Constrains the view’s size or alignment. |
| 369 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 370 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 371 | `}` | Opens or closes a Swift scope or view-builder block. |
| 372 | `` | Blank line separating code sections. |
| 373 | `// MARK: - Exercise Intro Skeleton View` | Section marker organizing the reusable component code. |
| 374 | `/// Standardized intro template for all exercises (Prolonged Speech, Dial Scene, Picture Description, Narration).` | Comment describing the purpose of the following code. |
| 375 | `public struct ExerciseIntroSkeletonView: View {` | Declares a reusable public SwiftUI view or button style. |
| 376 | `    public let title: String` | Declares public component configuration or state. |
| 377 | `    public let subtitle: String` | Declares public component configuration or state. |
| 378 | `    public let heroImageName: String` | Declares public component configuration or state. |
| 379 | `    public let continueButtonTitle: String` | Declares public component configuration or state. |
| 380 | `    public let onBack: () -> Void` | Declares public component configuration or state. |
| 381 | `    public let onContinue: () -> Void` | Declares public component configuration or state. |
| 382 | `` | Blank line separating code sections. |
| 383 | `    @State private var breatheEffect: Bool = false` | Stores view-local state managed by SwiftUI. |
| 384 | `` | Blank line separating code sections. |
| 385 | `    public init(` | Initializes the component and assigns its configuration values. |
| 386 | `        title: String,` | Implements the surrounding component or view-builder expression. |
| 387 | `        subtitle: String,` | Implements the surrounding component or view-builder expression. |
| 388 | `        heroImageName: String,` | Implements the surrounding component or view-builder expression. |
| 389 | `        continueButtonTitle: String = "Continue",` | Implements the surrounding component or view-builder expression. |
| 390 | `        onBack: @escaping () -> Void,` | Implements the surrounding component or view-builder expression. |
| 391 | `        onContinue: @escaping () -> Void` | Implements the surrounding component or view-builder expression. |
| 392 | `    ) {` | Opens or closes a Swift scope or view-builder block. |
| 393 | `        self.title = title` | Implements the surrounding component or view-builder expression. |
| 394 | `        self.subtitle = subtitle` | Implements the surrounding component or view-builder expression. |
| 395 | `        self.heroImageName = heroImageName` | Implements the surrounding component or view-builder expression. |
| 396 | `        self.continueButtonTitle = continueButtonTitle` | Implements the surrounding component or view-builder expression. |
| 397 | `        self.onBack = onBack` | Implements the surrounding component or view-builder expression. |
| 398 | `        self.onContinue = onContinue` | Implements the surrounding component or view-builder expression. |
| 399 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 400 | `` | Blank line separating code sections. |
| 401 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 402 | `        ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 403 | `            StamerleeTheme.backgroundDark` | Implements the surrounding component or view-builder expression. |
| 404 | `                .ignoresSafeArea()` | Allows the view to extend into safe-area regions. |
| 405 | `` | Blank line separating code sections. |
| 406 | `            VStack(alignment: .leading, spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 407 | `                // Top Navigation Bar` | Comment describing the purpose of the following code. |
| 408 | `                HStack {` | Opens or closes a Swift scope or view-builder block. |
| 409 | `                    BackNavButton(action: onBack)` | Implements the surrounding component or view-builder expression. |
| 410 | `                    Spacer()` | Implements the surrounding component or view-builder expression. |
| 411 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 412 | `                .padding(.horizontal, 24)` | Adds spacing around the view. |
| 413 | `                .padding(.top, 16)` | Adds spacing around the view. |
| 414 | `` | Blank line separating code sections. |
| 415 | `                // Headings Section` | Comment describing the purpose of the following code. |
| 416 | `                VStack(alignment: .leading, spacing: 12) {` | Opens or closes a Swift scope or view-builder block. |
| 417 | `                    Text(title)` | Displays a text label. |
| 418 | `                        .font(.system(size: 32, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 419 | `                        .foregroundStyle(StamerleeTheme.textPrimaryDark)` | Sets the foreground color or style. |
| 420 | `                        .lineSpacing(2)` | Applies a SwiftUI modifier to the preceding view. |
| 421 | `` | Blank line separating code sections. |
| 422 | `                    Text(subtitle)` | Displays a text label. |
| 423 | `                        .font(.system(size: 16, weight: .regular, design: .rounded))` | Sets typography, size, weight, and design. |
| 424 | `                        .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 425 | `                        .lineSpacing(4)` | Applies a SwiftUI modifier to the preceding view. |
| 426 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 427 | `                .padding(.horizontal, 24)` | Adds spacing around the view. |
| 428 | `                .padding(.top, 22)` | Adds spacing around the view. |
| 429 | `` | Blank line separating code sections. |
| 430 | `                // Hero Illustration` | Comment describing the purpose of the following code. |
| 431 | `                Image(heroImageName)` | Displays an image asset or SF Symbol. |
| 432 | `                    .resizable()` | Applies a SwiftUI modifier to the preceding view. |
| 433 | `                    .scaledToFit()` | Applies a SwiftUI modifier to the preceding view. |
| 434 | `                    .frame(maxHeight: 360)` | Constrains the view’s size or alignment. |
| 435 | `                    .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 10)` | Adds visual depth with a shadow. |
| 436 | `                    .scaleEffect(breatheEffect ? 1.015 : 0.985)` | Applies a SwiftUI modifier to the preceding view. |
| 437 | `                    .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: breatheEffect)` | Associates an animation with changes to the supplied value. |
| 438 | `                    .accessibilityHidden(true)` | Provides or adjusts accessibility semantics. |
| 439 | `                .frame(maxWidth: .infinity)` | Constrains the view’s size or alignment. |
| 440 | `                .padding(.vertical, 14)` | Adds spacing around the view. |
| 441 | `` | Blank line separating code sections. |
| 442 | `                Spacer()` | Implements the surrounding component or view-builder expression. |
| 443 | `` | Blank line separating code sections. |
| 444 | `                // Bottom CTA Button ("Continue")` | Comment describing the purpose of the following code. |
| 445 | `                VStack {` | Opens or closes a Swift scope or view-builder block. |
| 446 | `                    PrimaryActionButton(title: continueButtonTitle, action: onContinue)` | Implements the surrounding component or view-builder expression. |
| 447 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 448 | `                .padding(.horizontal, 24)` | Adds spacing around the view. |
| 449 | `                .padding(.bottom, 24)` | Adds spacing around the view. |
| 450 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 451 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 452 | `        .onAppear {` | Opens or closes a Swift scope or view-builder block. |
| 453 | `            breatheEffect = true` | Implements the surrounding component or view-builder expression. |
| 454 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 455 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 456 | `}` | Opens or closes a Swift scope or view-builder block. |
| 457 | `` | Blank line separating code sections. |
| 458 | `// MARK: - Speech Microphone Button` | Section marker organizing the reusable component code. |
| 459 | `public struct SpeechMicrophoneButton: View {` | Declares a reusable public SwiftUI view or button style. |
| 460 | `    @Binding public var isListening: Bool` | Creates a two-way connection to state owned by another view. |
| 461 | `    public let action: () -> Void` | Declares public component configuration or state. |
| 462 | `` | Blank line separating code sections. |
| 463 | `    public init(isListening: Binding<Bool>, action: @escaping () -> Void) {` | Initializes the component and assigns its configuration values. |
| 464 | `        self._isListening = isListening` | Implements the surrounding component or view-builder expression. |
| 465 | `        self.action = action` | Implements the surrounding component or view-builder expression. |
| 466 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 467 | `` | Blank line separating code sections. |
| 468 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 469 | `        Button(action: action) {` | Creates an accessible interactive button. |
| 470 | `            HStack(spacing: 10) {` | Opens or closes a Swift scope or view-builder block. |
| 471 | `                Image(systemName: isListening ? "waveform" : "mic.fill")` | Displays an image asset or SF Symbol. |
| 472 | `                    .font(.system(size: 18, weight: .bold))` | Sets typography, size, weight, and design. |
| 473 | `` | Blank line separating code sections. |
| 474 | `                Text(isListening ? "Listening..." : "Tap to speak")` | Displays a text label. |
| 475 | `                    .font(.system(size: 16, weight: .semibold, design: .rounded))` | Sets typography, size, weight, and design. |
| 476 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 477 | `            .foregroundStyle(.white)` | Sets the foreground color or style. |
| 478 | `            .frame(maxWidth: .infinity, minHeight: 52)` | Constrains the view’s size or alignment. |
| 479 | `            .background(StamerleeTheme.primaryBlue)` | Adds a background view behind the content. |
| 480 | `            .clipShape(Capsule())` | Clips the view to the supplied shape. |
| 481 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 482 | `        .buttonStyle(.haptic(weight: .medium, pressedScale: 0.97))` | Applies a SwiftUI modifier to the preceding view. |
| 483 | `        .padding(.horizontal, 24)` | Adds spacing around the view. |
| 484 | `        .accessibilityLabel(isListening ? "Listening" : "Tap to speak")` | Provides or adjusts accessibility semantics. |
| 485 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 486 | `}` | Opens or closes a Swift scope or view-builder block. |
| 487 | `` | Blank line separating code sections. |
| 488 | `// MARK: - Exercise Analysis Skeleton View` | Section marker organizing the reusable component code. |
| 489 | `/// Standardized result/analysis screen matching the Prolonged Speech design for all exercises.` | Comment describing the purpose of the following code. |
| 490 | `public struct ExerciseAnalysisSkeletonView: View {` | Declares a reusable public SwiftUI view or button style. |
| 491 | `    public let scoreText: String` | Declares public component configuration or state. |
| 492 | `    public let maxScoreText: String` | Declares public component configuration or state. |
| 493 | `    public let subtitle: String` | Declares public component configuration or state. |
| 494 | `    public let affirmation: String?` | Declares public component configuration or state. |
| 495 | `    public let wordsList: [String]` | Declares public component configuration or state. |
| 496 | `    @Binding public var selectedWords: Set<String>` | Creates a two-way connection to state owned by another view. |
| 497 | `    public let onDone: () -> Void` | Declares public component configuration or state. |
| 498 | `` | Blank line separating code sections. |
| 499 | `    @State private var showAllWordsSheet: Bool = false` | Stores view-local state managed by SwiftUI. |
| 500 | `` | Blank line separating code sections. |
| 501 | `    public init(` | Initializes the component and assigns its configuration values. |
| 502 | `        scoreText: String,` | Implements the surrounding component or view-builder expression. |
| 503 | `        maxScoreText: String = "/ 10",` | Implements the surrounding component or view-builder expression. |
| 504 | `        subtitle: String = "Tap words you want Beat Buddy to revisit",` | Implements the surrounding component or view-builder expression. |
| 505 | `        affirmation: String? = nil,` | Implements the surrounding component or view-builder expression. |
| 506 | `        wordsList: [String],` | Implements the surrounding component or view-builder expression. |
| 507 | `        selectedWords: Binding<Set<String>>,` | Implements the surrounding component or view-builder expression. |
| 508 | `        onDone: @escaping () -> Void` | Implements the surrounding component or view-builder expression. |
| 509 | `    ) {` | Opens or closes a Swift scope or view-builder block. |
| 510 | `        self.scoreText = scoreText` | Implements the surrounding component or view-builder expression. |
| 511 | `        self.maxScoreText = maxScoreText` | Implements the surrounding component or view-builder expression. |
| 512 | `        self.subtitle = subtitle` | Implements the surrounding component or view-builder expression. |
| 513 | `        self.affirmation = affirmation` | Implements the surrounding component or view-builder expression. |
| 514 | `        self.wordsList = wordsList` | Implements the surrounding component or view-builder expression. |
| 515 | `        self._selectedWords = selectedWords` | Implements the surrounding component or view-builder expression. |
| 516 | `        self.onDone = onDone` | Implements the surrounding component or view-builder expression. |
| 517 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 518 | `` | Blank line separating code sections. |
| 519 | `    public init(` | Initializes the component and assigns its configuration values. |
| 520 | `        scoreText: String,` | Implements the surrounding component or view-builder expression. |
| 521 | `        maxScoreText: String = "/ 10",` | Implements the surrounding component or view-builder expression. |
| 522 | `        subtitle: String = "Here's a summary of this exercise.",` | Implements the surrounding component or view-builder expression. |
| 523 | `        affirmation: String? = nil,` | Implements the surrounding component or view-builder expression. |
| 524 | `        onDone: @escaping () -> Void` | Implements the surrounding component or view-builder expression. |
| 525 | `    ) {` | Opens or closes a Swift scope or view-builder block. |
| 526 | `        self.init(` | Implements the surrounding component or view-builder expression. |
| 527 | `            scoreText: scoreText,` | Implements the surrounding component or view-builder expression. |
| 528 | `            maxScoreText: maxScoreText,` | Implements the surrounding component or view-builder expression. |
| 529 | `            subtitle: subtitle,` | Implements the surrounding component or view-builder expression. |
| 530 | `            affirmation: affirmation,` | Implements the surrounding component or view-builder expression. |
| 531 | `            wordsList: [],` | Implements the surrounding component or view-builder expression. |
| 532 | `            selectedWords: .constant([]),` | Implements the surrounding component or view-builder expression. |
| 533 | `            onDone: onDone` | Implements the surrounding component or view-builder expression. |
| 534 | `        )` | Implements the surrounding component or view-builder expression. |
| 535 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 536 | `` | Blank line separating code sections. |
| 537 | `    private var computedAffirmation: String {` | Defines a private computed property used by the component. |
| 538 | `        if let custom = affirmation, !custom.isEmpty {` | Conditionally renders or executes this branch. |
| 539 | `            return custom` | Returns the computed value or view. |
| 540 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 541 | `        let clean = scoreText.replacingOccurrences(of: "%", with: "").trimmingCharacters(in: .whitespaces)` | Declares an immutable local value. |
| 542 | `        let value = Double(clean) ?? 8.0` | Declares an immutable local value. |
| 543 | `        if value >= 8.5 {` | Conditionally renders or executes this branch. |
| 544 | `            return "You did great today!!"` | Returns the computed value or view. |
| 545 | `        } else if value >= 7.5 {` | Opens or closes a Swift scope or view-builder block. |
| 546 | `            return "Great progress today!"` | Returns the computed value or view. |
| 547 | `        } else {` | Opens or closes a Swift scope or view-builder block. |
| 548 | `            return "You can improve, keep practicing!"` | Returns the computed value or view. |
| 549 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 550 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 551 | `` | Blank line separating code sections. |
| 552 | `    private var isAllSelected: Bool {` | Defines a private computed property used by the component. |
| 553 | `        !wordsList.isEmpty && selectedWords.count >= wordsList.count` | Implements the surrounding component or view-builder expression. |
| 554 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 555 | `` | Blank line separating code sections. |
| 556 | `    private func toggleSelectAll() {` | Defines a private helper used by the component. |
| 557 | `        withAnimation(.easeInOut(duration: 0.2)) {` | Animates the enclosed state mutation. |
| 558 | `            if isAllSelected {` | Conditionally renders or executes this branch. |
| 559 | `                selectedWords.removeAll()` | Implements the surrounding component or view-builder expression. |
| 560 | `            } else {` | Opens or closes a Swift scope or view-builder block. |
| 561 | `                selectedWords = Set(wordsList)` | Implements the surrounding component or view-builder expression. |
| 562 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 563 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 564 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 565 | `` | Blank line separating code sections. |
| 566 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 567 | `        ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 568 | `            StamerleeTheme.backgroundDark` | Implements the surrounding component or view-builder expression. |
| 569 | `                .ignoresSafeArea()` | Allows the view to extend into safe-area regions. |
| 570 | `` | Blank line separating code sections. |
| 571 | `            VStack(alignment: .leading, spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 572 | `                // Top Title Bar` | Comment describing the purpose of the following code. |
| 573 | `                Text("Analysis")` | Displays a text label. |
| 574 | `                    .font(.system(size: 32, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 575 | `                    .foregroundStyle(StamerleeTheme.textPrimaryDark)` | Sets the foreground color or style. |
| 576 | `                    .padding(.horizontal, 24)` | Adds spacing around the view. |
| 577 | `                    .padding(.top, 24)` | Adds spacing around the view. |
| 578 | `                    .padding(.bottom, 16)` | Adds spacing around the view. |
| 579 | `` | Blank line separating code sections. |
| 580 | `                // Big Affirmation & Prominent Score Display (Made bigger to occupy the upper area)` | Comment describing the purpose of the following code. |
| 581 | `                VStack(spacing: 12) {` | Opens or closes a Swift scope or view-builder block. |
| 582 | `                    Text(computedAffirmation)` | Displays a text label. |
| 583 | `                        .font(.system(size: 30, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 584 | `                        .foregroundStyle(.white)` | Sets the foreground color or style. |
| 585 | `                        .multilineTextAlignment(.center)` | Applies a SwiftUI modifier to the preceding view. |
| 586 | `                        .padding(.horizontal, 24)` | Adds spacing around the view. |
| 587 | `` | Blank line separating code sections. |
| 588 | `                    Text("YOU SCORED")` | Displays a text label. |
| 589 | `                        .font(.system(size: 20, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 590 | `                        .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 591 | `                        .tracking(1.4)` | Applies a SwiftUI modifier to the preceding view. |
| 592 | `                        .padding(.top, 4)` | Adds spacing around the view. |
| 593 | `` | Blank line separating code sections. |
| 594 | `                    HStack(alignment: .firstTextBaseline, spacing: 6) {` | Opens or closes a Swift scope or view-builder block. |
| 595 | `                        Text(scoreText)` | Displays a text label. |
| 596 | `                            .font(.system(size: 72, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 597 | `                            .foregroundStyle(.white)` | Sets the foreground color or style. |
| 598 | `                        if !maxScoreText.isEmpty {` | Conditionally renders or executes this branch. |
| 599 | `                            Text(maxScoreText)` | Displays a text label. |
| 600 | `                                .font(.system(size: 28, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 601 | `                                .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 602 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 603 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 604 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 605 | `                .frame(maxWidth: .infinity)` | Constrains the view’s size or alignment. |
| 606 | `                .padding(.top, 36)` | Adds spacing around the view. |
| 607 | `                .padding(.bottom, 48)` | Adds spacing around the view. |
| 608 | `` | Blank line separating code sections. |
| 609 | `                // Instructions Subtitle` | Comment describing the purpose of the following code. |
| 610 | `                Text(subtitle)` | Displays a text label. |
| 611 | `                    .font(.system(size: 13, weight: .regular, design: .rounded))` | Sets typography, size, weight, and design. |
| 612 | `                    .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 613 | `                    .frame(maxWidth: .infinity, alignment: .center)` | Constrains the view’s size or alignment. |
| 614 | `                    .padding(.bottom, 18)` | Adds spacing around the view. |
| 615 | `` | Blank line separating code sections. |
| 616 | `                // Action Row: Counter + Single "Select all / Deselect all" Toggle Button` | Comment describing the purpose of the following code. |
| 617 | `                HStack {` | Opens or closes a Swift scope or view-builder block. |
| 618 | `                    Text("\(selectedWords.count) selected")` | Displays a text label. |
| 619 | `                        .font(.system(size: 13, weight: .semibold, design: .rounded))` | Sets typography, size, weight, and design. |
| 620 | `                        .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 621 | `` | Blank line separating code sections. |
| 622 | `                    Spacer()` | Implements the surrounding component or view-builder expression. |
| 623 | `` | Blank line separating code sections. |
| 624 | `                    Button(isAllSelected ? "Deselect all" : "Select all") {` | Creates an accessible interactive button. |
| 625 | `                        toggleSelectAll()` | Implements the surrounding component or view-builder expression. |
| 626 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 627 | `                    .font(.system(size: 13, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 628 | `                    .foregroundStyle(StamerleeTheme.primaryBlue)` | Sets the foreground color or style. |
| 629 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 630 | `                .padding(.horizontal, 24)` | Adds spacing around the view. |
| 631 | `                .padding(.bottom, 14)` | Adds spacing around the view. |
| 632 | `` | Blank line separating code sections. |
| 633 | `                // 2-Column Word Grid (Older sleek capsule design)` | Comment describing the purpose of the following code. |
| 634 | `                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {` | Lays out children lazily in a vertical grid. |
| 635 | `                    ForEach(Array(wordsList.prefix(6)), id: \.self) { word in` | Creates repeated child views from a collection. |
| 636 | `                        let isSelected = selectedWords.contains(word)` | Declares an immutable local value. |
| 637 | `                        wordButton(word: word, isSelected: isSelected) {` | Opens or closes a Swift scope or view-builder block. |
| 638 | `                            toggleWordSelection(word)` | Implements the surrounding component or view-builder expression. |
| 639 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 640 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 641 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 642 | `                .padding(.horizontal, 24)` | Adds spacing around the view. |
| 643 | `` | Blank line separating code sections. |
| 644 | `                // Hyperlink-style "View more" button` | Comment describing the purpose of the following code. |
| 645 | `                if wordsList.count > 6 {` | Conditionally renders or executes this branch. |
| 646 | `                    Button {` | Creates an accessible interactive button. |
| 647 | `                        showAllWordsSheet = true` | Implements the surrounding component or view-builder expression. |
| 648 | `                    } label: {` | Opens or closes a Swift scope or view-builder block. |
| 649 | `                        HStack(spacing: 4) {` | Opens or closes a Swift scope or view-builder block. |
| 650 | `                            Text("View more")` | Displays a text label. |
| 651 | `                                .underline()` | Applies a SwiftUI modifier to the preceding view. |
| 652 | `                            Image(systemName: "chevron.right")` | Displays an image asset or SF Symbol. |
| 653 | `                                .font(.system(size: 11, weight: .semibold))` | Sets typography, size, weight, and design. |
| 654 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 655 | `                        .font(.system(size: 13.5, weight: .semibold, design: .rounded))` | Sets typography, size, weight, and design. |
| 656 | `                        .foregroundStyle(StamerleeTheme.primaryBlue)` | Sets the foreground color or style. |
| 657 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 658 | `                    .frame(maxWidth: .infinity, alignment: .center)` | Constrains the view’s size or alignment. |
| 659 | `                    .padding(.top, 14)` | Adds spacing around the view. |
| 660 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 661 | `` | Blank line separating code sections. |
| 662 | `                Spacer(minLength: 20)` | Implements the surrounding component or view-builder expression. |
| 663 | `` | Blank line separating code sections. |
| 664 | `                // Bottom CTA Button ("Done")` | Comment describing the purpose of the following code. |
| 665 | `                VStack {` | Opens or closes a Swift scope or view-builder block. |
| 666 | `                    PrimaryActionButton(title: "Done", action: onDone)` | Implements the surrounding component or view-builder expression. |
| 667 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 668 | `                .padding(.horizontal, 24)` | Adds spacing around the view. |
| 669 | `                .padding(.bottom, 24)` | Adds spacing around the view. |
| 670 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 671 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 672 | `        .sensoryFeedback(.selection, trigger: selectedWords)` | Adds system haptic feedback driven by a state trigger. |
| 673 | `        .sheet(isPresented: $showAllWordsSheet) {` | Presents modal content using a Boolean binding. |
| 674 | `            wordsSheetView` | Implements the surrounding component or view-builder expression. |
| 675 | `                .presentationDetents([.medium, .large])` | Configures the presented sheet’s size, drag indicator, or background. |
| 676 | `                .presentationDragIndicator(.visible)` | Configures the presented sheet’s size, drag indicator, or background. |
| 677 | `                .presentationBackground(StamerleeTheme.backgroundDark)` | Configures the presented sheet’s size, drag indicator, or background. |
| 678 | `                .ignoresSafeArea()` | Allows the view to extend into safe-area regions. |
| 679 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 680 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 681 | `` | Blank line separating code sections. |
| 682 | `    private var wordsSheetView: some View {` | Defines a private computed property used by the component. |
| 683 | `        NavigationStack {` | Provides stack-based navigation for the sheet content. |
| 684 | `            ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 685 | `                StamerleeTheme.backgroundDark` | Implements the surrounding component or view-builder expression. |
| 686 | `                    .ignoresSafeArea()` | Allows the view to extend into safe-area regions. |
| 687 | `` | Blank line separating code sections. |
| 688 | `                ScrollView(.vertical, showsIndicators: true) {` | Opens or closes a Swift scope or view-builder block. |
| 689 | `                    VStack(alignment: .leading, spacing: 16) {` | Opens or closes a Swift scope or view-builder block. |
| 690 | `                        HStack {` | Opens or closes a Swift scope or view-builder block. |
| 691 | `                            Text("\(selectedWords.count) of \(wordsList.count) selected")` | Displays a text label. |
| 692 | `                                .font(.system(size: 13, weight: .medium, design: .rounded))` | Sets typography, size, weight, and design. |
| 693 | `                                .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 694 | `` | Blank line separating code sections. |
| 695 | `                            Spacer()` | Implements the surrounding component or view-builder expression. |
| 696 | `` | Blank line separating code sections. |
| 697 | `                            Button(isAllSelected ? "Deselect all" : "Select all") {` | Creates an accessible interactive button. |
| 698 | `                                toggleSelectAll()` | Implements the surrounding component or view-builder expression. |
| 699 | `                            }` | Opens or closes a Swift scope or view-builder block. |
| 700 | `                            .font(.system(size: 13, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 701 | `                            .foregroundStyle(StamerleeTheme.primaryBlue)` | Sets the foreground color or style. |
| 702 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 703 | `                        .padding(.horizontal, 24)` | Adds spacing around the view. |
| 704 | `                        .padding(.top, 12)` | Adds spacing around the view. |
| 705 | `` | Blank line separating code sections. |
| 706 | `                        LazyVGrid(` | Lays out children lazily in a vertical grid. |
| 707 | `                            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],` | Implements the surrounding component or view-builder expression. |
| 708 | `                            spacing: 12` | Implements the surrounding component or view-builder expression. |
| 709 | `                        ) {` | Opens or closes a Swift scope or view-builder block. |
| 710 | `                            ForEach(wordsList, id: \.self) { word in` | Creates repeated child views from a collection. |
| 711 | `                                let isSelected = selectedWords.contains(word)` | Declares an immutable local value. |
| 712 | `                                wordButton(word: word, isSelected: isSelected) {` | Opens or closes a Swift scope or view-builder block. |
| 713 | `                                    toggleWordSelection(word)` | Implements the surrounding component or view-builder expression. |
| 714 | `                                }` | Opens or closes a Swift scope or view-builder block. |
| 715 | `                            }` | Opens or closes a Swift scope or view-builder block. |
| 716 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 717 | `                        .padding(.horizontal, 24)` | Adds spacing around the view. |
| 718 | `                        .padding(.bottom, 32)` | Adds spacing around the view. |
| 719 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 720 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 721 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 722 | `            .navigationTitle("Practice Words")` | Applies a SwiftUI modifier to the preceding view. |
| 723 | `            .navigationBarTitleDisplayMode(.inline)` | Applies a SwiftUI modifier to the preceding view. |
| 724 | `            .toolbarBackground(StamerleeTheme.backgroundDark, for: .navigationBar)` | Adds or configures navigation-bar toolbar content. |
| 725 | `            .toolbarColorScheme(.dark, for: .navigationBar)` | Adds or configures navigation-bar toolbar content. |
| 726 | `            .toolbar {` | Adds or configures navigation-bar toolbar content. |
| 727 | `                ToolbarItem(placement: .topBarTrailing) {` | Opens or closes a Swift scope or view-builder block. |
| 728 | `                    Button("Done") {` | Creates an accessible interactive button. |
| 729 | `                        showAllWordsSheet = false` | Implements the surrounding component or view-builder expression. |
| 730 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 731 | `                    .font(.system(size: 15, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 732 | `                    .foregroundStyle(StamerleeTheme.primaryBlue)` | Sets the foreground color or style. |
| 733 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 734 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 735 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 736 | `        .ignoresSafeArea()` | Allows the view to extend into safe-area regions. |
| 737 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 738 | `` | Blank line separating code sections. |
| 739 | `    private func toggleWordSelection(_ word: String) {` | Defines a private helper used by the component. |
| 740 | `        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {` | Animates the enclosed state mutation. |
| 741 | `            if selectedWords.contains(word) {` | Conditionally renders or executes this branch. |
| 742 | `                selectedWords.remove(word)` | Implements the surrounding component or view-builder expression. |
| 743 | `            } else {` | Opens or closes a Swift scope or view-builder block. |
| 744 | `                selectedWords.insert(word)` | Implements the surrounding component or view-builder expression. |
| 745 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 746 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 747 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 748 | `` | Blank line separating code sections. |
| 749 | `    // MARK: - Word Selection Pill (Older clean capsule design)` | Section marker organizing the reusable component code. |
| 750 | `    private func wordButton(word: String, isSelected: Bool, action: @escaping () -> Void) -> some View {` | Defines a private helper used by the component. |
| 751 | `        Button(action: action) {` | Creates an accessible interactive button. |
| 752 | `            Text(word)` | Displays a text label. |
| 753 | `                .font(.system(size: 13.5, weight: isSelected ? .bold : .medium, design: .rounded))` | Sets typography, size, weight, and design. |
| 754 | `                .foregroundStyle(isSelected ? .white : StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 755 | `                .frame(maxWidth: .infinity)` | Constrains the view’s size or alignment. |
| 756 | `                .frame(height: 44)` | Constrains the view’s size or alignment. |
| 757 | `                .background(` | Adds a background view behind the content. |
| 758 | `                    Group {` | Opens or closes a Swift scope or view-builder block. |
| 759 | `                        if isSelected {` | Conditionally renders or executes this branch. |
| 760 | `                            Color(red: 20 / 255, green: 45 / 255, blue: 105 / 255)` | Implements the surrounding component or view-builder expression. |
| 761 | `                        } else {` | Opens or closes a Swift scope or view-builder block. |
| 762 | `                            Color(red: 16 / 255, green: 18 / 255, blue: 36 / 255)` | Implements the surrounding component or view-builder expression. |
| 763 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 764 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 765 | `                )` | Implements the surrounding component or view-builder expression. |
| 766 | `                .overlay(` | Draws an additional view above the current view. |
| 767 | `                    Capsule()` | Implements the surrounding component or view-builder expression. |
| 768 | `                        .stroke(` | Applies a SwiftUI modifier to the preceding view. |
| 769 | `                            isSelected ? StamerleeTheme.primaryBlue : Color.white.opacity(0.06),` | Implements the surrounding component or view-builder expression. |
| 770 | `                            lineWidth: isSelected ? 2 : 1` | Implements the surrounding component or view-builder expression. |
| 771 | `                        )` | Implements the surrounding component or view-builder expression. |
| 772 | `                )` | Implements the surrounding component or view-builder expression. |
| 773 | `                .clipShape(Capsule())` | Clips the view to the supplied shape. |
| 774 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 775 | `        .buttonStyle(.haptic)` | Applies a SwiftUI modifier to the preceding view. |
| 776 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 777 | `}` | Opens or closes a Swift scope or view-builder block. |
| 778 | `` | Blank line separating code sections. |
| 779 | `// MARK: - Reusable Profile Avatar` | Section marker organizing the reusable component code. |
| 780 | `public struct ProfileAvatar: View {` | Declares a reusable public SwiftUI view or button style. |
| 781 | `    public let style: Int` | Declares public component configuration or state. |
| 782 | `    public let imageData: Data?` | Declares public component configuration or state. |
| 783 | `    public var size: CGFloat` | Declares public component configuration or state. |
| 784 | `` | Blank line separating code sections. |
| 785 | `    public init(style: Int, imageData: Data?, size: CGFloat = 84) {` | Initializes the component and assigns its configuration values. |
| 786 | `        self.style = style` | Implements the surrounding component or view-builder expression. |
| 787 | `        self.imageData = imageData` | Implements the surrounding component or view-builder expression. |
| 788 | `        self.size = size` | Implements the surrounding component or view-builder expression. |
| 789 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 790 | `` | Blank line separating code sections. |
| 791 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 792 | `        avatarArtwork` | Implements the surrounding component or view-builder expression. |
| 793 | `            .scaleEffect(size / 84.0)` | Applies a SwiftUI modifier to the preceding view. |
| 794 | `            .frame(width: size, height: size)` | Constrains the view’s size or alignment. |
| 795 | `            .contentShape(Circle())` | Applies a SwiftUI modifier to the preceding view. |
| 796 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 797 | `` | Blank line separating code sections. |
| 798 | `    private var avatarArtwork: some View {` | Defines a private computed property used by the component. |
| 799 | `        ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 800 | `            if let imageData, let image = UIImage(data: imageData) {` | Conditionally renders or executes this branch. |
| 801 | `                Image(uiImage: image)` | Displays an image asset or SF Symbol. |
| 802 | `                    .resizable()` | Applies a SwiftUI modifier to the preceding view. |
| 803 | `                    .scaledToFill()` | Applies a SwiftUI modifier to the preceding view. |
| 804 | `            } else {` | Opens or closes a Swift scope or view-builder block. |
| 805 | `                Circle()` | Implements the surrounding component or view-builder expression. |
| 806 | `                    .fill(backgroundColor)` | Applies a SwiftUI modifier to the preceding view. |
| 807 | `                    .padding(8)` | Adds spacing around the view. |
| 808 | `` | Blank line separating code sections. |
| 809 | `                Circle()` | Implements the surrounding component or view-builder expression. |
| 810 | `                    .fill(foregroundColor)` | Applies a SwiftUI modifier to the preceding view. |
| 811 | `                    .frame(width: 22, height: 22)` | Constrains the view’s size or alignment. |
| 812 | `                    .offset(y: -13)` | Applies a SwiftUI modifier to the preceding view. |
| 813 | `` | Blank line separating code sections. |
| 814 | `                Capsule()` | Implements the surrounding component or view-builder expression. |
| 815 | `                    .fill(foregroundColor)` | Applies a SwiftUI modifier to the preceding view. |
| 816 | `                    .frame(width: 59, height: 33)` | Constrains the view’s size or alignment. |
| 817 | `                    .offset(y: 25)` | Applies a SwiftUI modifier to the preceding view. |
| 818 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 819 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 820 | `        .frame(width: 84, height: 84)` | Constrains the view’s size or alignment. |
| 821 | `        .background(Color.black)` | Adds a background view behind the content. |
| 822 | `        .clipShape(Circle())` | Clips the view to the supplied shape. |
| 823 | `        .overlay(` | Draws an additional view above the current view. |
| 824 | `            Circle()` | Implements the surrounding component or view-builder expression. |
| 825 | `                .stroke(StamerleeTheme.profileCard, lineWidth: 2)` | Applies a SwiftUI modifier to the preceding view. |
| 826 | `        )` | Implements the surrounding component or view-builder expression. |
| 827 | `        .shadow(color: Color.black.opacity(0.18), radius: 4, x: 0, y: 2)` | Adds visual depth with a shadow. |
| 828 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 829 | `` | Blank line separating code sections. |
| 830 | `    private var backgroundColor: Color {` | Defines a private computed property used by the component. |
| 831 | `        switch style {` | Selects behavior based on the current enum or style value. |
| 832 | `        case 1: return StamerleeTheme.accentPurple` | Handles one enum case. |
| 833 | `        case 2: return StamerleeTheme.primaryBlue` | Handles one enum case. |
| 834 | `        default: return StamerleeTheme.profileAvatarDark` | Implements the surrounding component or view-builder expression. |
| 835 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 836 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 837 | `` | Blank line separating code sections. |
| 838 | `    private var foregroundColor: Color {` | Defines a private computed property used by the component. |
| 839 | `        style == 2 ? StamerleeTheme.profileCard : StamerleeTheme.backgroundDark` | Implements the surrounding component or view-builder expression. |
| 840 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 841 | `}` | Opens or closes a Swift scope or view-builder block. |
| 842 | `` | Blank line separating code sections. |
| 843 | `// MARK: - Avatar Interactive Button Style` | Section marker organizing the reusable component code. |
| 844 | `public struct AvatarInteractiveButtonStyle: ButtonStyle {` | Declares a reusable public SwiftUI view or button style. |
| 845 | `    public init() {}` | Initializes the component and assigns its configuration values. |
| 846 | `    public func makeBody(configuration: Configuration) -> some View {` | Opens or closes a Swift scope or view-builder block. |
| 847 | `        configuration.label` | Implements the surrounding component or view-builder expression. |
| 848 | `            .scaleEffect(configuration.isPressed ? 0.90 : 1.0)` | Applies a SwiftUI modifier to the preceding view. |
| 849 | `            .animation(.spring(response: 0.22, dampingFraction: 0.68), value: configuration.isPressed)` | Associates an animation with changes to the supplied value. |
| 850 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 851 | `}` | Opens or closes a Swift scope or view-builder block. |
| 852 | `` | Blank line separating code sections. |
| 853 | `// MARK: - Bouncy Card Button Style` | Section marker organizing the reusable component code. |
| 854 | `public struct BouncyCardButtonStyle: ButtonStyle {` | Declares a reusable public SwiftUI view or button style. |
| 855 | `    public init() {}` | Initializes the component and assigns its configuration values. |
| 856 | `    public func makeBody(configuration: Configuration) -> some View {` | Opens or closes a Swift scope or view-builder block. |
| 857 | `        configuration.label` | Implements the surrounding component or view-builder expression. |
| 858 | `            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)` | Applies a SwiftUI modifier to the preceding view. |
| 859 | `            .animation(.spring(response: 0.24, dampingFraction: 0.64), value: configuration.isPressed)` | Associates an animation with changes to the supplied value. |
| 860 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 861 | `}` | Opens or closes a Swift scope or view-builder block. |
| 862 | `` | Blank line separating code sections. |
| 863 | `// MARK: - Matched Geometry View Helper` | Section marker organizing the reusable component code. |
| 864 | `extension View {` | Adds functionality to an existing type. |
| 865 | `    @ViewBuilder` | Enables conditional and multi-view result-builder syntax. |
| 866 | `    public func matchedGeometryEffectIfPresent<ID: Hashable>(` | Implements the surrounding component or view-builder expression. |
| 867 | `        id: ID,` | Implements the surrounding component or view-builder expression. |
| 868 | `        in namespace: Namespace.ID?,` | Implements the surrounding component or view-builder expression. |
| 869 | `        properties: MatchedGeometryProperties = .frame,` | Implements the surrounding component or view-builder expression. |
| 870 | `        anchor: UnitPoint = .center,` | Implements the surrounding component or view-builder expression. |
| 871 | `        isSource: Bool = true` | Implements the surrounding component or view-builder expression. |
| 872 | `    ) -> some View {` | Opens or closes a Swift scope or view-builder block. |
| 873 | `        if let namespace {` | Conditionally renders or executes this branch. |
| 874 | `            self.matchedGeometryEffect(id: id, in: namespace, properties: properties, anchor: anchor, isSource: isSource)` | Implements the surrounding component or view-builder expression. |
| 875 | `        } else {` | Opens or closes a Swift scope or view-builder block. |
| 876 | `            self` | Implements the surrounding component or view-builder expression. |
| 877 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 878 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 879 | `}` | Opens or closes a Swift scope or view-builder block. |

### `Stamerlee/Illustrations.swift` (47 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports SwiftUI for declarative views and modifiers. |
| 2 | `` | Blank line separating code sections. |
| 3 | `// MARK: - Onboarding Step 1 Hero Image` | Section marker organizing the reusable component code. |
| 4 | `/// Girl with headphones and mic badge (asset catalog: \`OnboardingHero1\`).` | Comment describing the purpose of the following code. |
| 5 | `public struct OnboardingStepOneIllustration: View {` | Declares a reusable public SwiftUI view or button style. |
| 6 | `    @State private var floatBadge: Bool = false` | Stores view-local state managed by SwiftUI. |
| 7 | `    ` | Blank line separating code sections. |
| 8 | `    public init() {}` | Initializes the component and assigns its configuration values. |
| 9 | `    ` | Blank line separating code sections. |
| 10 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 11 | `        Image("OnboardingHero1")` | Displays an image asset or SF Symbol. |
| 12 | `            .resizable()` | Applies a SwiftUI modifier to the preceding view. |
| 13 | `            .scaledToFit()` | Applies a SwiftUI modifier to the preceding view. |
| 14 | `            .frame(maxHeight: 270)` | Constrains the view’s size or alignment. |
| 15 | `            .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 10)` | Adds visual depth with a shadow. |
| 16 | `            .scaleEffect(floatBadge ? 1.015 : 0.985)` | Applies a SwiftUI modifier to the preceding view. |
| 17 | `            .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true), value: floatBadge)` | Associates an animation with changes to the supplied value. |
| 18 | `            .frame(height: 290)` | Constrains the view’s size or alignment. |
| 19 | `            .accessibilityHidden(true)` | Provides or adjusts accessibility semantics. |
| 20 | `            .onAppear {` | Opens or closes a Swift scope or view-builder block. |
| 21 | `                floatBadge = true` | Implements the surrounding component or view-builder expression. |
| 22 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 23 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 24 | `}` | Opens or closes a Swift scope or view-builder block. |
| 25 | `` | Blank line separating code sections. |
| 26 | `// MARK: - Onboarding Step 2 Hero Image` | Section marker organizing the reusable component code. |
| 27 | `/// Coach video call card with speech bubble (asset catalog: \`OnboardingHero2\`).` | Comment describing the purpose of the following code. |
| 28 | `public struct OnboardingStepTwoIllustration: View {` | Declares a reusable public SwiftUI view or button style. |
| 29 | `    @State private var subtleFloat: Bool = false` | Stores view-local state managed by SwiftUI. |
| 30 | `    ` | Blank line separating code sections. |
| 31 | `    public init() {}` | Initializes the component and assigns its configuration values. |
| 32 | `    ` | Blank line separating code sections. |
| 33 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 34 | `        Image("OnboardingHero2")` | Displays an image asset or SF Symbol. |
| 35 | `            .resizable()` | Applies a SwiftUI modifier to the preceding view. |
| 36 | `            .scaledToFit()` | Applies a SwiftUI modifier to the preceding view. |
| 37 | `            .frame(maxHeight: 310)` | Constrains the view’s size or alignment. |
| 38 | `            .shadow(color: Color.black.opacity(0.38), radius: 24, x: 0, y: 12)` | Adds visual depth with a shadow. |
| 39 | `            .offset(y: subtleFloat ? -4 : 4)` | Applies a SwiftUI modifier to the preceding view. |
| 40 | `            .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: subtleFloat)` | Associates an animation with changes to the supplied value. |
| 41 | `            .frame(height: 330)` | Constrains the view’s size or alignment. |
| 42 | `            .accessibilityHidden(true)` | Provides or adjusts accessibility semantics. |
| 43 | `            .onAppear {` | Opens or closes a Swift scope or view-builder block. |
| 44 | `                subtleFloat = true` | Implements the surrounding component or view-builder expression. |
| 45 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 46 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 47 | `}` | Opens or closes a Swift scope or view-builder block. |

## Recommendations

- Replace repeated hard-coded RGB literals with named `StamerleeTheme` colors where the values represent shared design tokens.
- Consider adding reduced-motion behavior for the breathing and floating animations.
- Validate duplicate-word behavior in `Set<String>` selection: repeated entries in `wordsList` cannot be independently selected because the identity is the word text.
- Keep the iOS 26 glass-button availability branches synchronized with the project deployment target and SDK.
