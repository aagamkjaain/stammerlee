# Stamerlee: A Complete Beginner's Guide to My SwiftUI App
# Part 2: Components, Illustrations, Onboarding, Dashboard, Summary & Profile

---

> **Who this is for**: Someone who is new to Swift and SwiftUI and wants to understand the Stamerlee codebase thoroughly. Each section explains *what* the code does and *why* it was written that way.

---

## File 6: `Components.swift` (879 lines)

`Components.swift` is the **design system** of the entire app. Instead of writing the same button or card shape in every screen file, all the shared building blocks live here. This is the same idea behind a design library — build it once, use it everywhere. When you want to change the look of every back button in the app, you only change one place.

---

### What is `ButtonStyle`?

In SwiftUI, a `ButtonStyle` is a **protocol** (a contract) that lets you define exactly how a `Button` looks and behaves when it is pressed. The protocol requires you to implement one function:

```swift
func makeBody(configuration: Configuration) -> some View
```

`Configuration` is a value SwiftUI hands you that contains:
- `configuration.label` — the button's content (its text, icon, etc.)
- `configuration.isPressed` — a `Bool` that is `true` while the user's finger is touching the button

Think of `makeBody` as saying: *"Given this button's contents and whether it's being pressed, return the view that should actually appear on screen."*

---

### `HapticButtonStyle`

```swift
public struct HapticButtonStyle: ButtonStyle {
    public var weight: SensoryFeedback.Weight
    public var pressedScale: CGFloat

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
            .sensoryFeedback(trigger: configuration.isPressed) { _, isPressed in
                isPressed ? .impact(weight: weight) : nil
            }
    }
}
```

**What it does, step by step:**

| Part | Meaning |
|------|---------|
| `.scaleEffect(configuration.isPressed ? pressedScale : 1)` | If the button is pressed, shrink it to `pressedScale` (e.g., 0.97); otherwise keep at full size (1.0). |
| `.animation(.easeInOut(duration: 0.15), ...)` | Animate the scale change over 0.15 seconds with a smooth ease-in-out curve. |
| `.sensoryFeedback(trigger: configuration.isPressed) { ... }` | Fire haptic feedback when `isPressed` changes. Returns `.impact(weight:)` only when pressing down; returns `nil` on release. |

**What is `SensoryFeedback`?**

`SensoryFeedback` is a SwiftUI API (available from iOS 17) that triggers the phone's **Taptic Engine** — the physical vibration motor. `.impact(weight: .light)` gives a subtle click feeling. `.impact(weight: .medium)` is slightly stronger. This makes buttons feel physically responsive without you having to touch UIKit's `UIImpactFeedbackGenerator` directly.

**What is `@escaping` on a closure?**

Throughout this file you see action closures defined like this:

```swift
public let action: () -> Void
```

When a closure is passed to a function and stored to be called *later* (not immediately), it must be marked `@escaping`:

```swift
public init(..., action: @escaping () -> Void)
```

The `@escaping` keyword tells Swift: *"This closure will outlive this function call — it will be stored and called later."* Without it, Swift assumes the closure is used only while the function runs and can skip certain memory bookkeeping. For button actions (which fire only when tapped), the action clearly needs to outlive the initializer, so `@escaping` is required.

**The convenience extension:**

```swift
public extension ButtonStyle where Self == HapticButtonStyle {
    static var haptic: HapticButtonStyle { HapticButtonStyle() }
    static func haptic(weight:pressedScale:) -> HapticButtonStyle { ... }
}
```

This lets you write `.buttonStyle(.haptic)` or `.buttonStyle(.haptic(weight: .medium, pressedScale: 0.97))` instead of `.buttonStyle(HapticButtonStyle(...))`. It's just shorthand that SwiftUI's dot-syntax allows for static members on a type.

---

### `PrimaryActionButton`

This is the main call-to-action button used on nearly every screen — the pill-shaped purple/blue button.

```swift
public struct PrimaryActionButton: View {
    public let title: String
    public let icon: String?
    public let isEnabled: Bool
    public let isLoading: Bool
    public let compact: Bool
    public let action: () -> Void
}
```

**View hierarchy tree:**

```
PrimaryActionButton
└── Button (action: action)
    └── label (private computed var)
        └── HStack
            ├── Image(systemName: icon)   ← only if icon != nil
            ├── Text(title)
            └── ProgressView()            ← only if isLoading == true
```

**What is `#available(iOS 26.0, *)`?**

```swift
if #available(iOS 26.0, *) {
    Button(action: action) { label }
        .buttonStyle(.glass(.regular.tint(StamerleeTheme.primaryBlue).interactive()))
        .buttonBorderShape(.capsule)
} else {
    Button(action: action) { label }
        .buttonStyle(.haptic(weight: .medium, pressedScale: 0.97))
}
```

`#available` is a **runtime check** that asks: *"Is the device running at least this iOS version?"* The `*` means "and any other platform" (macOS, tvOS, etc.).

iOS 26 introduced **Liquid Glass** — Apple's new translucent, real-time blurred material UI style. The `.glass(...)` button style gives the button this frosted-glass appearance. Because older iPhones can't render Liquid Glass, the code falls back to the custom `HapticButtonStyle` with a scale press on those devices. This pattern — checking availability and using a newer API when possible — is essential for shipping to a wide range of devices.

**What is `some View`?**

You'll see `-> some View` as the return type of `body` and many computed properties throughout this file. This is called an **opaque return type**. It means: *"I'm returning something that is a View, but I'm not going to tell you the exact type."*

This matters because SwiftUI views have deeply nested generic types. `some View` lets the compiler do the work of tracking the exact type while you just write readable code. The key rule is: the function must always return the *same kind* of view (you can't return a `Text` in one branch and an `Image` in another without wrapping them).

---

### `SocialAuthRow`

```swift
public enum SocialAuthType { case apple, google, email }
public struct SocialAuthRow: View {
    public let type: SocialAuthType
    public let action: () -> Void
}
```

**Why an enum?** The three auth types (Apple, Google, Email) each need a different icon and label. Rather than passing a raw `String` and risking typos, an `enum` guarantees you can only pass one of three valid values.

**View hierarchy:**
```
SocialAuthRow
└── Button (action: action)
    └── HStack
        ├── Image (Apple logo / Google SVG / envelope icon)
        └── Text(type.title)
```

The button also uses `#available(iOS 26.0, *)` to apply the glass style on newer systems.

---

### `BackNavButton`

```swift
public struct BackNavButton: View {
    public let action: () -> Void
}
```

A simple circular back button with a left chevron. **Why make this a component?** Because if every screen defines its own back button slightly differently, the app feels inconsistent. One component, used everywhere, keeps the experience uniform.

**View hierarchy:**
```
BackNavButton
└── Button (action: action)
    └── Circle (background)
        └── Image(systemName: "chevron.left")
```

---

### `OptionSelectRow` and `SoundOption`

```swift
public struct SoundOption: Hashable {
    let title: String
    let subtitle: String?
}

public struct OptionSelectRow: View {
    // Shows a row with title + subtitle, and an animated checkmark/radio circle on the right
}
```

**What is `Hashable`?** `Hashable` is a protocol that means the type can be converted to an integer hash — which allows it to be used in `Set`s or as dictionary keys. SwiftUI's `ForEach` also requires items to be `Hashable` or `Identifiable`.

**View hierarchy:**
```
OptionSelectRow
└── Button
    └── HStack
        ├── VStack
        │   ├── Text(option.title)
        │   └── Text(option.subtitle)   ← only if subtitle != nil
        └── ZStack (radio circle)
            ├── Circle (outline)
            └── Image("checkmark")      ← animated in when selected
```

The checkmark is animated with a scale + opacity effect when the selection changes.

---

### `DifficultyCard`

```swift
public struct DifficultyCard: View {
    public let title: String
    public let isLocked: Bool
    public let isCompleted: Bool
    public let action: () -> Void
}
```

Used on difficulty selection screens (Easy / Medium / Hard). Depending on `isLocked` and `isCompleted`, the card shows different badges.

**View hierarchy:**
```
DifficultyCard
└── Button
    └── HStack
        ├── ZStack (left icon area)
        │   ├── Circle (background)
        │   └── Image (lock if locked, checkmark if completed, nothing otherwise)
        ├── Text(title)
        └── Image("chevron.right")   ← only if NOT locked
```

---

### `ExerciseIntroSkeletonView`

This is a **template** for every exercise intro screen. Rather than repeating the same layout in `ProlongedSpeechIntroView`, `NarrationIntroView`, etc., they all use this one component and pass their specific content via parameters.

```swift
public struct ExerciseIntroSkeletonView: View {
    public let title: String
    public let subtitle: String
    public let heroImageName: String
    public let continueButtonTitle: String
    public let onBack: () -> Void
    public let onContinue: () -> Void
    @State private var breatheEffect: Bool = false
}
```

**The breathing animation:**
```swift
.scaleEffect(breatheEffect ? 1.03 : 0.97)
.animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: breatheEffect)
.onAppear { breatheEffect = true }
```

When the view appears, `breatheEffect` flips to `true`. The animation continuously oscillates between scale 0.97 and 1.03 — creating a gentle "breathing" pulse on the hero image. This is purely decorative but adds life to an otherwise static screen.

**View hierarchy:**
```
ExerciseIntroSkeletonView
└── ZStack
    ├── StamerleeTheme.backgroundDark (background color)
    └── VStack
        ├── BackNavButton (calls onBack)
        ├── Text(title)
        ├── Text(subtitle)
        ├── Image(heroImageName)
        │   └── [breathing scale animation]
        └── PrimaryActionButton(title: continueButtonTitle, action: onContinue)
```

---

### `SpeechMicrophoneButton`

```swift
public struct SpeechMicrophoneButton: View {
    @Binding public var isListening: Bool
    public let action: () -> Void
}
```

**What is `@Binding`? How is it different from `@State`?**

`@State` is **local** state — the view owns it and nobody else can change it directly:

```swift
@State private var count = 0   // only this view controls count
```

`@Binding` is a **reference into someone else's state**. It lets a child view read and *write* a value that actually lives in a parent view:

```swift
// Parent
@State private var listening = false
SpeechMicrophoneButton(isListening: $listening, action: { ... })

// Inside SpeechMicrophoneButton:
@Binding var isListening: Bool
// When isListening changes here, it also changes in the parent
```

The `$` prefix creates a `Binding` from a `@State` variable. Think of `@Binding` as a two-way tunnel: the child can both read the current value AND push changes back to the parent.

**Why use `@Binding` here?** The practice view (parent) needs to know if the microphone is active (to show a timer, disable other buttons, etc.). So the microphone button doesn't own the `isListening` state — the parent does, and the button just reads/writes through a binding.

**View hierarchy:**
```
SpeechMicrophoneButton
└── Button (action: action)
    └── HStack
        ├── Image(systemName: isListening ? "waveform" : "mic")
        └── Text(isListening ? "Listening..." : "Tap to speak")
```

---

### `ExerciseAnalysisSkeletonView`

This is the template for the results/analysis screen shown after every exercise.

```swift
public struct ExerciseAnalysisSkeletonView: View {
    public let scoreText: String
    public let maxScoreText: String
    public let subtitle: String
    public let affirmation: String?
    public let wordsList: [String]
    @Binding public var selectedWords: Set<String>
    public let onDone: () -> Void
    @State private var showAllWordsSheet: Bool = false
}
```

**Two initializers:** The component offers two `init` functions — one for exercises that have word selection (passing in `wordsList` and a `selectedWords` binding), and one for exercises that don't (using the convenient `.constant([])` default).

**What is `.constant([])`?** `.constant(value)` creates a `Binding` whose value is always fixed and never changes. It's used when a component requires a `@Binding` parameter but the caller doesn't actually need two-way updates — it's just a "dummy" binding to satisfy the API.

**What is `LazyVGrid` and `GridItem(.flexible())`?**

```swift
LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
    ForEach(wordsList.prefix(6), id: \.self) { word in
        // word pill button
    }
}
```

`LazyVGrid` is SwiftUI's grid layout. `Lazy` means it only creates views that are currently visible — important for performance when lists are long. `GridItem(.flexible())` means: *"Make this column as wide as possible, sharing available space equally with other flexible columns."* Two `GridItem(.flexible())` items → two equal-width columns.

**What is `.sensoryFeedback(.selection, trigger: selectedWords)`?**

This fires a selection haptic (a soft tick) every time `selectedWords` changes — i.e., every time the user taps a word pill to select or deselect it. It makes the selection feel tactile without any extra code.

**View hierarchy:**
```
ExerciseAnalysisSkeletonView
└── ZStack
    ├── Background
    └── VStack
        ├── Text("Analysis")            ← title
        ├── Text(affirmation)           ← motivational phrase
        ├── Text("YOU SCORED")
        ├── Text(scoreText)             ← big score number
        ├── Text(subtitle)
        ├── Text("N words selected")
        ├── HStack (select-all toggle)
        ├── LazyVGrid (2 columns)
        │   └── ForEach wordsList.prefix(6)
        │       └── word pill Button
        ├── Button("View more")         ← only if wordsList.count > 6
        └── PrimaryActionButton("Done", action: onDone)
    └── sheet(isPresented: $showAllWordsSheet)
        └── wordsSheetView (all words in NavigationStack)
```

---

### `ProfileAvatar`

```swift
public struct ProfileAvatar: View {
    public let style: Int
    public let imageData: Data?
    public var size: CGFloat
}
```

**What is `UIImage(data:)`?**

`UIImage` is UIKit's image class. `UIImage(data: someData)` tries to decode raw image bytes (e.g., from a camera photo) into an image. If the data is valid JPEG/PNG, it returns a `UIImage`; if not, it returns `nil`. Here, the avatar first tries to show a user-uploaded photo. If `imageData` is `nil` or invalid, it falls back to a drawn avatar (circles and capsule shapes in SwiftUI).

**Scaling trick:**

```swift
.scaleEffect(size / 84.0)
```

The avatar is designed at 84pt base size. To display it at any other size, the whole view is scaled proportionally. This avoids having to recalculate every internal measurement — just design once, scale everywhere.

---

### `AvatarInteractiveButtonStyle` and `BouncyCardButtonStyle`

These are simpler custom button styles similar to `HapticButtonStyle`, but without haptics:

| Style | Scale when pressed | Used on |
|-------|-------------------|---------|
| `AvatarInteractiveButtonStyle` | 0.90 (strong press) | Profile avatar button |
| `BouncyCardButtonStyle` | 0.96 (subtle press) | Exercise cards on older iOS |

---

### The `matchedGeometryEffectIfPresent` Extension

```swift
extension View {
    @ViewBuilder
    public func matchedGeometryEffectIfPresent<ID: Hashable>(
        id: ID,
        in namespace: Namespace.ID?,
        ...
    ) -> some View { ... }
}
```

**What is `@ViewBuilder`?**

`@ViewBuilder` is a special attribute that lets a function return multiple views using an implicit result builder — the same mechanism that lets `body` contain multiple views without wrapping them in a container. When you mark a function or computed property with `@ViewBuilder`, you can write `if/else` branches that return different view types and SwiftUI handles the resulting conditional type for you.

**What are generics? The `<ID: Hashable>` syntax:**

A **generic** is a placeholder for a type that will be filled in later. `<ID: Hashable>` means: *"This function accepts any type `ID`, as long as that type conforms to `Hashable`."*

```swift
// Works with Int:
.matchedGeometryEffectIfPresent(id: 42, in: namespace)

// Also works with String:
.matchedGeometryEffectIfPresent(id: "avatar", in: namespace)
```

Without generics, you'd need a separate function for every type. With generics, one function handles all `Hashable` types.

**Why optional `Namespace.ID?`?** Matched geometry effect requires a namespace from a `@Namespace` property. Some callers may not have one (or don't want the effect). By accepting an optional, the function can silently skip the effect when `namespace` is `nil` — returning the unmodified view. This keeps the call site clean.

---

### Why put all components in one file?

Having all reusable UI in one file means:
1. **Discoverability** — a developer looking for a button opens `Components.swift`.
2. **Consistency** — one source of truth; every screen uses the same exact component.
3. **Maintainability** — change the pill button's corner radius once, it updates everywhere.

---

## File 7: `Illustrations.swift` (47 lines)

This file holds two animated SVG-alternative views that display onboarding hero images.

```swift
public struct OnboardingStepOneIllustration: View {
    @State private var floatBadge: Bool = false

    public var body: some View {
        Image("OnboardingHero1")
            .resizable().scaledToFit().frame(maxHeight: 270)
            .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 10)
            .scaleEffect(floatBadge ? 1.015 : 0.985)
            .animation(
                .easeInOut(duration: 2.6).repeatForever(autoreverses: true),
                value: floatBadge
            )
            .frame(height: 290)
            .accessibilityHidden(true)
            .onAppear { floatBadge = true }
    }
}
```

---

### How the floating animation works

The `@State private var floatBadge: Bool = false` starts as `false` (image at scale 0.985). When `.onAppear` fires (the view becomes visible), `floatBadge` becomes `true`. SwiftUI detects the change in `floatBadge` and runs the animation.

The animation is:
- **`.easeInOut(duration: 2.6)`** — a 2.6-second smooth ramp up and ramp down
- **`.repeatForever(autoreverses: true)`** — loops endlessly, reversing direction each time

Result: the image gently pulses between scale 0.985 → 1.015 → 0.985 → … forever. It gives the static image the feeling of breathing or floating.

---

### `.scaleEffect()` vs `.offset()`

| Modifier | What it does | Visual effect |
|----------|-------------|---------------|
| `.scaleEffect(1.015)` | Makes the view larger or smaller from its center | Grows/shrinks in place |
| `.offset(y: -4)` | Moves the view up/down without changing its size | Floats up/down |

`OnboardingStepOneIllustration` uses `.scaleEffect` for a breathing-in feeling.  
`OnboardingStepTwoIllustration` uses `.offset(y: subtleFloat ? -4 : 4)` for a gentle up-down float.

Both achieve a lively, premium feel — the design choice depends on which motion matches the image content better.

---

### What `.accessibilityHidden(true)` does and why

This modifier tells iOS's **VoiceOver** screen reader to completely ignore this view. VoiceOver reads content aloud for people who are visually impaired. A decorative hero illustration has no informational value when heard — it would just say "image" and confuse the user. By hiding it from accessibility, the experience for VoiceOver users is cleaner.

**Rule of thumb:** Always hide purely decorative images from accessibility.

---

### Why a separate file?

Putting illustrations in their own file is **separation of concerns** — keeping code organized by what it does:
- `Components.swift` → reusable UI controls (buttons, cards)
- `Illustrations.swift` → decorative animated art
- `OnboardingViews.swift` → onboarding screen logic

If an illustrator wants to swap out animations, they know exactly where to look.

---

## File 8: `OnboardingViews.swift` (585 lines)

This file contains the entire onboarding flow: six views in sequence.

---

### What is `@Bindable`?

```swift
@Bindable public var state: AppState
```

`@Bindable` is an iOS 17 property wrapper for use with **`@Observable`** classes. It's the modern replacement for `@ObservedObject`. When you mark a property `@Bindable`, you can derive `Binding`s from it using `$state.someProperty` — letting child views read and write individual properties on the shared `AppState`.

> **`@Bindable` vs `@ObservedObject`:** `@Observable` (the class macro) + `@Bindable` (the property wrapper) is the iOS 17+ way. The older approach used `ObservableObject` + `@Published` on each property + `@ObservedObject` in views. The new system is simpler: just mark the class `@Observable` and use `@Bindable` in views.

---

### View 1: `LaunchView`

```swift
public struct LaunchView: View {
    @Bindable public var state: AppState
    @State private var logoOpacity: Double = 0.0
    @State private var logoScale: CGFloat = 0.94
}
```

**What `withAnimation` does:**
```swift
.onAppear {
    withAnimation(.easeOut(duration: 2.5)) {
        logoOpacity = 1.0
        logoScale = 1.0
    }
}
```

`withAnimation` tells SwiftUI: *"Any state changes inside this block should be animated."* The logo fades in (`opacity 0 → 1`) and scales up (`0.94 → 1.0`) over 2.5 seconds. Without `withAnimation`, the change would be instant.

**What `Task { @MainActor in ... }` does:**
```swift
Task { @MainActor in
    try? await Task.sleep(for: .seconds(1.8))
    if state.currentScreen == .launch {
        state.navigate(to: .login)
    }
}
```

`Task` creates an **asynchronous task** — work that runs concurrently without blocking the UI. `@MainActor` ensures the code after the sleep runs on the **main thread**, which is required for any UI update. `Task.sleep(for: .seconds(1.8))` pauses execution for 1.8 seconds (this is Swift's modern `async/await` sleep — it doesn't block the thread, it just suspends this task). After the wait, if the user hasn't manually tapped to advance, the app navigates automatically to login.

**What `.contentShape(Rectangle())` does:**

By default, SwiftUI only registers taps on visible (non-transparent) parts of a view. A `ZStack` with mostly empty `Spacer`s has very little tappable area. `.contentShape(Rectangle())` says: *"Make the entire rectangular bounds of this view tappable, even if it's invisible."* This makes the whole splash screen tappable.

**View hierarchy:**
```
LaunchView
└── ZStack
    ├── StamerleeTheme.backgroundDark.ignoresSafeArea()
    └── VStack
        ├── Spacer
        ├── Text("Stamerlee")
        │   └── [opacity + scaleEffect animation]
        └── Spacer
```

---

### View 2: `LoginView`

This is the most complex onboarding view. It handles three auth paths and two legal sheets.

**Private enum inside a struct:**
```swift
private enum ActiveSheet: Identifiable {
    case emailSignIn, terms, privacy
    var id: Int { hashValue }
}
```

A `private enum` inside a `struct` is a type that only the enclosing struct can see. This keeps `ActiveSheet` from polluting the global namespace — it's an implementation detail of `LoginView`, so it belongs inside it.

**What `Identifiable` requires:**

The `Identifiable` protocol requires one property: `id`. SwiftUI's `sheet(item:)` needs the item to be `Identifiable` so it can tell when the sheet identity changes (and therefore needs to present a different sheet). Here, `hashValue` is used as the `id` — each enum case has a unique hash.

**`sheet(item:)` vs `sheet(isPresented:)`:**

| Method | When to use | How it works |
|--------|-------------|-------------|
| `sheet(isPresented: $bool)` | One sheet, two states (shown/hidden) | A `Bool` toggle |
| `sheet(item: $optionalItem)` | Multiple different sheets | An `Optional<Identifiable>` — nil = no sheet, non-nil = show sheet matching the item |

`LoginView` can show three different sheets (email form, terms, privacy), so `sheet(item:)` is the right choice — one binding covers all three cases.

**What is `LinearGradient`?**

```swift
LinearGradient(
    colors: [StamerleeTheme.primaryPurple, StamerleeTheme.primaryBlue],
    startPoint: .leading,
    endPoint: .trailing
)
```

A `LinearGradient` blends two or more colors in a straight line from one point to another. Here it creates the purple-to-blue gradient text used for the app's tagline ("stronger speech").

**What is `UnevenRoundedRectangle`?** (iOS 16+)

A rectangle shape where each corner can have a different radius. Used here for the email login form sheet to have a rounded top but square bottom corners (since it slides up from the bottom of the screen).

**What `presentationDetents([.medium])` does:**

This controls how tall a **sheet** can be dragged. `.medium` means the sheet takes up roughly half the screen. Without this, sheets default to filling most of the screen.

**View hierarchy:**
```
LoginView
└── ZStack
    ├── Background
    └── VStack
        ├── Spacer
        ├── Text("Stamerlee") [gradient]
        ├── Text("Welcome back")
        ├── Spacer
        ├── SocialAuthRow(.apple)
        ├── SocialAuthRow(.google)
        ├── SocialAuthRow(.email)
        └── Text(terms link)
└── sheet(item: $activeSheet)
    ├── [case .emailSignIn] → email form view
    ├── [case .terms]       → LegalDocumentSheet(terms)
    └── [case .privacy]     → LegalDocumentSheet(privacy)
```

---

### View 3: `OnboardingStepOneView`

```swift
public struct OnboardingStepOneView: View {
    @Bindable public var state: AppState
}
```

Simple layout: back button, gradient title text, `OnboardingStepOneIllustration`, and a "Next" button that navigates to `onboarding2`.

**View hierarchy:**
```
OnboardingStepOneView
└── ZStack
    ├── Background
    └── VStack
        ├── BackNavButton → state.navigate(to: .login)
        ├── Text("Build") + Text("stronger speech") [gradient]
        ├── OnboardingStepOneIllustration
        └── PrimaryActionButton("Next") → state.navigate(to: .onboarding2)
```

---

### View 4: `OnboardingStepTwoView`

Identical structure to StepOneView but with `OnboardingStepTwoIllustration` and navigates to `.dailyGoal`.

**View hierarchy:**
```
OnboardingStepTwoView
└── ZStack
    ├── Background
    └── VStack
        ├── BackNavButton → state.navigate(to: .onboarding1)
        ├── Headline text
        ├── OnboardingStepTwoIllustration
        └── PrimaryActionButton("Next") → state.navigate(to: .dailyGoal)
```

---

### View 5: `DailyGoalView`

```swift
public struct DailyGoalView: View {
    @Bindable public var state: AppState
    let goalOptions = [5, 10, 15, 20]
}
```

The user picks how many minutes per day they want to practice.

**`.sensoryFeedback(.selection, trigger: state.dailyPracticeMinutes)`**

Each time the user selects a different goal, `dailyPracticeMinutes` changes, triggering a soft selection haptic. This makes the selection feel responsive and confirms the tap without needing any visual confirmation.

**View hierarchy:**
```
DailyGoalView
└── ZStack
    ├── Background
    └── VStack
        ├── BackNavButton
        ├── Text("Daily Goal")
        ├── ForEach(goalOptions)
        │   └── OptionSelectRow(option: ..., isSelected: state.dailyPracticeMinutes == goal)
        └── PrimaryActionButton("Continue") → state.navigate(to: .exploreActivities)
```

---

### View 6: `ExploreActivitiesView`

```swift
public struct ExploreActivitiesView: View {
    @Bindable public var state: AppState
    @State private var cardsVisible: Bool = false

    private struct ActivityCardItem: Identifiable {
        let id: UUID = UUID()
        // title, icon, etc.
    }
    let activities: [ActivityCardItem] = [...]
}
```

**What `ForEach(Array(activities.enumerated()), id: \.element.id)` does:**

Normally `ForEach` over an array gives you each element. `enumerated()` gives you pairs of `(index, element)`. `Array(...)` converts the `EnumeratedSequence` into a plain array. The result: you get both the item *and* its position, which lets you calculate the **staggered animation delay**:

```swift
.opacity(cardsVisible ? 1 : 0)
.offset(y: cardsVisible ? 0 : 20)
.animation(
    .spring(response: 0.5, dampingFraction: 0.8)
        .delay(0.08 + Double(index) * 0.06),
    value: cardsVisible
)
```

Card 0 animates after 0.08s, card 1 after 0.14s, card 2 after 0.20s, etc. This creates a **cascade / staggered** entrance where each card slides in slightly after the previous one — a polished animation pattern.

**What `.ignoresSafeArea()` and `.ignoresSafeArea(edges: .bottom)` do:**

The iPhone has "safe areas" — insets at the top (Dynamic Island / notch) and bottom (home indicator bar) that Apple recommends not covering. `.ignoresSafeArea()` lets a view extend behind those areas. Using it on a background color makes the color fill the entire screen edge-to-edge. `.ignoresSafeArea(edges: .bottom)` only extends into the bottom safe area (useful for backgrounds that should bleed to the bottom but not the top).

**View hierarchy:**
```
ExploreActivitiesView
└── ZStack
    ├── Background.ignoresSafeArea()
    └── VStack
        ├── Text("Explore Activities")
        ├── ScrollView
        │   └── VStack
        │       └── ForEach(activities.enumerated())
        │           └── ActivityCard [staggered animation]
        └── PrimaryActionButton("Get Started") → state.navigate(to: .homeDashboard)
```

---

## File 9: `HomeDashboardView.swift` (429 lines)

This file contains the main home screen, the row cards for exercises, and the tab bar container.

---

### `HomeDashboardView`

```swift
public struct HomeDashboardView: View {
    @Bindable public var state: AppState
    @State private var showLockedAlert: Bool = false
    @State private var lockedAlertMessage: String = ""
    @State private var cardsAppeared: Bool = false
}
```

**The header:**

```swift
Button { state.navigate(to: .profile) } label: {
    ProfileAvatar(style: state.profileAvatarStyle, imageData: state.profileAvatarData, size: 42)
        .reportProfileAvatarFrame(.home)
}
.buttonStyle(AvatarInteractiveButtonStyle())
.opacity(state.isHeroAvatarTransitionActive ? 0 : 1)
```

`.reportProfileAvatarFrame(.home)` is a custom modifier (defined in `ProfileView.swift`) that uses a `GeometryReader` to report the avatar's on-screen position to a shared environment value. This position is used by the hero avatar transition — a **matched geometry animation** that makes the avatar appear to fly from the home header to the profile screen. During that animation, `isHeroAvatarTransitionActive` is `true`, so the original avatar is hidden (opacity 0) to avoid seeing two avatars at once.

**Staggered card animation:**

```swift
.onAppear {
    cardsAppeared = false
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.75)) {
            cardsAppeared = true
        }
    }
}
```

Each exercise row card has a different `.delay()`:
```swift
// Card 1: .delay(0.04)
// Card 2: .delay(0.08)
// Card 3: .delay(0.12)
// etc.
```

The cards cascade in with spring bounce, one after another, giving the home screen a lively entrance. `.onChange(of: state.currentScreen)` resets and replays this animation every time the user returns to the dashboard.

**View hierarchy:**
```
HomeDashboardView
└── ScrollView
    └── VStack
        ├── HStack (header)
        │   ├── Text("Welcome, [name]")
        │   └── Button → ProfileAvatar (.reportProfileAvatarFrame(.home))
        ├── fluencyLapCard
        │   └── HStack: calendar icon, VStack title/subtitle, Button "Start Fluency Lap"
        ├── Text("Exercises") [section header]
        ├── ExerciseRowCard (Prolonged Speech)
        ├── ExerciseRowCard (Picture Description)
        ├── ExerciseRowCard (Dial Scene)
        ├── ExerciseRowCard (Narration)
        ├── Text("Practice") [section header]
        └── ExerciseRowCard (Beat Buddy)
```

---

### `ExerciseRowCard` (private struct)

```swift
private struct ExerciseRowCard: View {
    // ...
    var body: some View {
        if #available(iOS 26.0, *) {
            Button { action() } label: { cardContent }
                .buttonStyle(.glass(...))
        } else {
            Button { action() } label: { cardContent }
                .buttonStyle(BouncyCardButtonStyle())
        }
    }
}
```

Again, `#available(iOS 26.0, *)` for Liquid Glass on newer devices with a bouncy card fallback on older ones.

**Card content hierarchy:**
```
cardContent
└── HStack
    ├── ZStack (icon area)
    │   ├── RoundedRectangle (background)
    │   └── Image(systemName: iconName) OR lock badge
    ├── VStack
    │   ├── Text(title)
    │   └── Text(subtitle)
    └── Image(systemName: "chevron.right")
```

---

### `DashboardTabView`

This wraps the app's two tabs: Home and Summary.

**What `Tab` type is (iOS 18):**

iOS 18 introduced a new `Tab` type for `TabView` that uses a declarative syntax:

```swift
// iOS 18+ (modernTabView):
TabView(selection: state.selectedTabBinding) {
    Tab("Home", systemImage: "house.fill", value: AppTab.home) {
        HomeDashboardView(state: state)
    }
    Tab("Summary", systemImage: "chart.bar.fill", value: AppTab.summary) {
        SummaryView(state: state)
    }
}
```

```swift
// iOS 17 and below (legacyTabView):
TabView(selection: state.selectedTabBinding) {
    HomeDashboardView(state: state)
        .tabItem { Label("Home", systemImage: "house.fill") }
        .tag(AppTab.home)

    SummaryView(state: state)
        .tabItem { Label("Summary", systemImage: "chart.bar.fill") }
        .tag(AppTab.summary)
}
```

**What `.tabItem {}` and `.tag()` do (older API):**

`.tabItem {}` defines the icon and label shown in the tab bar at the bottom. `.tag(AppTab.home)` associates this tab's view with a value — when `selection` equals `.home`, this tab is active.

**What `selectedTabBinding` provides:**

This is a computed `Binding<AppTab>` defined in `AppScreen.swift`. It reads from and writes to `state.selectedTab`, but also fires the tab-change haptic. The indirection lets `AppState` intercept tab switches to perform side effects.

**What `.toolbarBackground` and `.toolbarColorScheme` do:**

`.toolbarBackground(.visible, for: .tabBar)` forces the tab bar background to be visible (not transparent). `.toolbarColorScheme(.dark, for: .tabBar)` forces the tab bar to use the dark color scheme even if the user's system is in light mode.

**View hierarchy:**
```
DashboardTabView
└── TabView(selection: state.selectedTabBinding)
    ├── Tab/tabItem "Home"   → HomeDashboardView(state: state)
    └── Tab/tabItem "Summary" → SummaryView(state: state)
```

---

## File 10: `SummaryView.swift` (357 lines)

The Summary tab shows the user's streak, high scores, and navigation to their exercise history.

---

### `SummaryView`

```swift
public struct SummaryView: View {
    @Bindable public var state: AppState

    private struct ExerciseHighScoreItem: Identifiable {
        let id: UUID
        let title: String
        let displayTitle: String
        let iconName: String
        let score: Int
        let targetScreen: AppScreen
    }
}
```

**The hardcoded scores:**

```swift
let exerciseHighScoreItems: [ExerciseHighScoreItem] = [
    ExerciseHighScoreItem(..., score: 86, ...),
    ExerciseHighScoreItem(..., score: 92, ...),
    ExerciseHighScoreItem(..., score: 78, ...),
    ExerciseHighScoreItem(..., score: 89, ...),
]
```

These scores are **placeholder data** — they don't reflect actual user performance. In a production app, they would be read from a database or computed from stored practice history. This is noted as a known limitation in the codebase.

**GeometryReader for the progress bar:**

```swift
GeometryReader { geo in
    Rectangle()
        .fill(StamerleeTheme.primaryPurple)
        .frame(width: geo.size.width * Double(item.score) / 100.0)
}
```

`GeometryReader` is a container that exposes the size of the space available to it via a `GeometryProxy` (`geo`). Here, `geo.size.width` is the full width of the card. Multiplying by `score / 100.0` gives the correct pixel width for the progress fill. This is the standard SwiftUI technique for drawing proportional bars when you need actual pixel dimensions.

**View hierarchy:**
```
SummaryView
└── ScrollView
    └── VStack
        ├── Text("Summary")
        ├── practiceStreakCard
        │   └── VStack
        │       ├── HStack: flame icon, streak count
        │       └── HStack (7 days)
        │           └── ForEach (7 days) → Circle (filled if practiced, highlighted if today)
        └── exerciseBlocksSection
            └── LazyVGrid(columns: 2 × GridItem(.flexible()))
                └── ForEach(exerciseHighScoreItems)
                    └── exerciseBlockCard
                        └── Button → state.navigate(to: item.targetScreen)
                            └── VStack
                                ├── Image(systemName: item.iconName)
                                ├── Text(item.displayTitle)
                                └── GeometryReader → progress bar
```

---

### `PracticeCalendarSheet` and `NativePracticeCalendar` (unused)

These two private structs exist in the file but are **never called** — no sheet binding in `SummaryView` triggers them.

**What `UIViewRepresentable` is:**

SwiftUI and UIKit are two different UI frameworks. Sometimes you need a UIKit component (like `UICalendarView`) that doesn't yet have a SwiftUI equivalent. `UIViewRepresentable` is a **bridge protocol** that wraps a UIKit view so it can be used in a SwiftUI layout.

You implement three methods:

| Method | Purpose |
|--------|---------|
| `makeUIView(context:)` | Create and return the UIKit view once |
| `updateUIView(_:context:)` | Called when SwiftUI state changes — sync SwiftUI data into the UIKit view |
| `makeCoordinator()` | Create a `Coordinator` object that acts as the UIKit delegate |

**What `Coordinator` / `NSObject` is:**

UIKit uses the **delegate pattern** — you pass an object to a UIKit view, and that view calls methods on your object when things happen (e.g., the user taps a date). The `Coordinator` class is the SwiftUI wrapper's delegate. It inherits from `NSObject` because UIKit delegates must be Objective-C compatible.

**What `UICalendarView` is:**

`UICalendarView` is a UIKit calendar widget introduced in iOS 16. It shows a monthly calendar grid and can highlight specific dates. Here, it would highlight the days the user practiced, but since this sheet is never shown, it's effectively dead code.

**Why it's unused:** A likely explanation is that this calendar feature was planned but deprioritized. The code is kept in case it's needed later, but no UI element in `SummaryView` triggers `sheet(isPresented:)` with this content.

---

## File 11: `ProfileView.swift` (636 lines)

The most complex view in the app. It manages profile photo selection, avatar customization, daily goal, reminder notifications, account management, and legal documents.

---

### `ProfileAvatarFrameReportingModifier`

```swift
private struct ProfileAvatarFrameReportingModifier: ViewModifier {
    let slot: AvatarHeroSlot
    @Environment(\.profileAvatarFrameReporter) private var reporter

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onGeometryChange(for: CGRect.self) { geo.frame(in: .global) }
                        perform: { reporter?(slot, $0) }
                }
            )
    }
}
```

**What `ViewModifier` is and when to use it vs a custom view:**

A `ViewModifier` adds behavior to an *existing* view without replacing it. The difference:

| Approach | Use when |
|----------|----------|
| Custom `View` struct | You are creating a standalone UI component (a button, a card) |
| `ViewModifier` | You are adding optional behavior to any existing view (a reporting side-effect, a border, a badge) |

Here, `ProfileAvatarFrameReportingModifier` is a modifier because it adds frame-reporting behavior *on top of* whatever view it's applied to — it doesn't replace the view.

**What `@Environment(\.profileAvatarFrameReporter)` is:**

SwiftUI's `@Environment` reads values from a global key-value store passed down through the view hierarchy. Custom environment values (defined with `@EnvironmentKey`) let you inject any value from a parent view and read it anywhere below without passing it through every layer. Here, `profileAvatarFrameReporter` is a custom closure that receives avatar frames.

**What `GeometryReader + onGeometryChange(for: CGRect.self)` does:**

`onGeometryChange` (iOS 17+) fires a callback whenever the view's geometry changes. Here it passes the view's frame in global (screen) coordinates to the reporter closure. This is how the app knows the exact pixel position of the avatar — needed to animate it flying from home to profile.

**The `dropIn(_:index:)` extension:**

```swift
extension View {
    func dropIn(_ shown: Bool, index: Int = 0) -> some View {
        self
            .offset(y: shown ? 0 : -48)
            .opacity(shown ? 1 : 0)
            .animation(
                .spring(response: 0.45, dampingFraction: 0.72)
                    .delay(Double(index) * 0.06),
                value: shown
            )
    }
}
```

A convenience modifier for the staggered drop-in animation. Setting `shown = true` makes the view slide down from -48pt above and fade in. Each section of the profile screen has a different `index`, creating a cascade entrance.

---

### `ProfileView` — The Main View

```swift
public struct ProfileView: View {
    @Bindable public var state: AppState
    @Environment(\.profileAvatarFrameReporter) private var reporter
    @State private var isEditingProfile: Bool = false
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var didAppearContent: Bool = false
    // Alert states
    @State private var showLogoutConfirmation: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var showLegalSheet: Bool = false
    @State private var legalSheetTitle: String = ""
    @State private var legalSheetContent: String = ""
    @State private var reminderSuccessTrigger: Bool = false
}
```

**What `PhotosPickerItem` is:**

`PhotosPickerItem` is SwiftUI's (iOS 16+) way to represent a photo the user has selected from their library. It's not the actual image — it's a **handle** to the photo. You load the actual data separately using `.loadTransferable(type: Data.self)`.

**Loading the selected photo:**

```swift
.task(id: selectedPhoto) {
    guard let photo = selectedPhoto else { return }
    if let data = try? await photo.loadTransferable(type: Data.self) {
        state.profileAvatarData = data
    }
}
```

`.task(id: selectedPhoto)` is a SwiftUI modifier that creates an async task **every time `selectedPhoto` changes**. When the user picks a photo, the task fires, loads the raw image bytes asynchronously, and stores them in `state.profileAvatarData`. The UI updates automatically because `AppState` is `@Observable`.

**What `PhotosPicker` is:**

`PhotosPicker` is SwiftUI's built-in photo library picker (iOS 16+). It presents the system Photos UI and updates the `selection` binding when the user picks an image.

```swift
PhotosPicker(selection: $selectedPhoto, matching: .images) {
    Image(systemName: "camera")
}
```

---

### The `profileHeader`

```swift
// ZStack with:
// - dark background
// - BackNavButton
// - VStack:
//   - ProfileAvatar (.reportProfileAvatarFrame(.profile))
//   - [optional] avatarStylePicker
//   - name text or TextField
//   - joined date
```

Tapping the avatar enters edit mode (`isEditingProfile = true`), which reveals the `avatarStylePicker`.

**View hierarchy:**
```
profileHeader
└── ZStack
    ├── StamerleeTheme.backgroundDark
    ├── BackNavButton
    └── VStack
        ├── Button → ProfileAvatar.reportProfileAvatarFrame(.profile)
        ├── [if isEditingProfile] avatarStylePicker
        │   └── HStack
        │       ├── Button (style 0) → avatar swatch
        │       ├── Button (style 1) → avatar swatch
        │       ├── Button (style 2) → avatar swatch
        │       └── PhotosPicker → camera icon
        ├── [if isEditingProfile] TextField (profile name)
        │   else Text(state.profileName)
        └── Text("Member since...")
```

---

### `dailyGoalCard`

```swift
Picker("Daily Goal", selection: $state.dailyPracticeMinutes) {
    ForEach([5, 10, 15, 20], id: \.self) { minutes in
        Text("\(minutes) min").tag(minutes)
    }
}
.pickerStyle(.menu)
```

**What `DatePicker` is and `.displayedComponents`:**

`DatePicker` is SwiftUI's time/date selector. `.displayedComponents: .hourAndMinute` shows only the hour and minute wheels, hiding the date calendar — perfect for picking a reminder time.

**What `Toggle` is and how `$state.reminderEnabled` works:**

`Toggle` is a switch (on/off control). `$state.reminderEnabled` is a `Binding<Bool>` derived from the `@Bindable` state — when the user flips the toggle, `state.reminderEnabled` is updated directly. Because `AppState` is `@Observable`, any view reading `reminderEnabled` automatically re-renders.

---

### The reminder system (`UNUserNotificationCenter`)

```swift
func requestAndScheduleReminder() async {
    let center = UNUserNotificationCenter.current()
    let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    if granted == true {
        scheduleNotification()
        reminderSuccessTrigger.toggle()
    }
}
```

**What `UNUserNotificationCenter` is:**

Part of the `UserNotifications` framework, `UNUserNotificationCenter` is the iOS system for scheduling and managing local and remote notifications. Steps to send a local reminder:

1. **Request authorization** — `requestAuthorization` shows the system prompt ("Allow Stamerlee to send notifications?"). The user must grant permission.
2. **Build content** — `UNMutableNotificationContent` holds the title, body, and sound.
3. **Build trigger** — `UNCalendarNotificationTrigger` fires the notification at a specific calendar time (every day at the reminder hour/minute).
4. **Create request** — `UNNotificationRequest` bundles the content and trigger with a unique identifier.
5. **Add request** — `center.add(request)` schedules it.

```swift
func scheduleNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Time to practice!"
    content.body = "Your daily speech practice is waiting."
    content.sound = .default

    var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: state.reminderTime)
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

    let request = UNNotificationRequest(
        identifier: "daily-reminder",
        content: content,
        trigger: trigger
    )
    UNUserNotificationCenter.current().add(request)
}
```

**What `cancelReminders` does:**

```swift
UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-reminder"])
```

Removes the scheduled notification by its identifier. Called when the user turns off the reminder toggle.

**What `.sensoryFeedback(.success, trigger: reminderSuccessTrigger)` does:**

`.success` is a distinct haptic pattern (two quick taps) that iOS uses to confirm a completed action. It fires every time `reminderSuccessTrigger` changes value. The trigger is `toggle()`d after the notification is successfully scheduled — giving the user a satisfying confirmation tap.

---

### `accountSection`

```swift
// Log Out row: Button → showLogoutConfirmation = true
// .confirmationDialog or .alert → calls state.logout()

// Delete Account row: Button → showDeleteConfirmation = true
// .alert → calls state.deleteAccount()
```

Both destructive actions use an `alert` (a pop-up requiring confirmation) before actually performing the action — an important UX pattern to prevent accidental account deletion.

---

### `LegalDocumentSheet` (private struct)

A simple sheet view that displays a wall of legal text (Terms of Service or Privacy Policy) in a `ScrollView` inside a `NavigationStack`, with an ✕ close button in the toolbar.

**View hierarchy:**
```
LegalDocumentSheet
└── NavigationStack
    └── ScrollView
        └── Text(content)  ← legal text
    .toolbar
        └── Button("✕") → dismiss
```

---

### `StreakSpark` (private struct) — DEFINED BUT NEVER USED

```swift
private struct StreakSpark: View {
    var body: some View {
        ZStack {
            Image(systemName: "sparkle").font(.system(size: 24))
            Image(systemName: "sparkle").font(.system(size: 16)).offset(x: 10, y: -8)
            Image(systemName: "sparkle").font(.system(size: 12)).offset(x: -8, y: 10)
        }
    }
}
```

This struct is fully defined — three overlapping sparkle icons to celebrate a streak — but **no view in the codebase ever uses it**. It was probably designed for a "streak milestone" celebration animation that wasn't implemented. It is dead code and could be safely removed without affecting anything.

---

### The commented-out `statsSection`

A section showing practice statistics is present in the file but wrapped in `/* ... */` comments, meaning it's excluded from compilation. This is placeholder code for a future feature.

---

### Full `ProfileView` hierarchy:

```
ProfileView
└── ZStack
    ├── Background
    └── ScrollView
        └── VStack
            ├── profileHeader              [dropIn(didAppearContent, index: 0)]
            │   └── ZStack: BackNavButton, avatar, avatarPicker?, name, date
            ├── dailyGoalCard              [dropIn(didAppearContent, index: 1)]
            │   └── Picker(.menu) for minutes
            ├── reminderCard               [dropIn(didAppearContent, index: 2)]
            │   └── Toggle (reminder on/off)
            │       └── [if enabled] DatePicker(.hourAndMinute)
            ├── accountSection             [dropIn(didAppearContent, index: 3)]
            │   ├── Button "Log Out" → showLogoutConfirmation
            │   └── Button "Delete Account" → showDeleteConfirmation
            └── legalHypertextSection      [dropIn(didAppearContent, index: 4)]
                ├── Button "Terms of Service" → openTerms()
                ├── Button "Privacy Policy" → openPrivacyPolicy()
                └── Text("Version 1.0.0")
```

---

## Summary Table: Files 6–11

| File | Lines | Purpose | Key Concepts |
|------|-------|---------|--------------|
| `Components.swift` | 879 | Design system: all reusable UI components | `ButtonStyle`, `@Binding`, generics, `LazyVGrid`, `UIImage`, `@ViewBuilder` |
| `Illustrations.swift` | 47 | Animated onboarding hero images | `@State` animation, `.scaleEffect`, `.offset`, `accessibilityHidden` |
| `OnboardingViews.swift` | 585 | Full onboarding flow (6 screens) | `@Bindable`, `sheet(item:)`, `Task`, `withAnimation`, `LinearGradient`, `ForEach(enumerated())` |
| `HomeDashboardView.swift` | 429 | Home tab + tab bar container | `#available`, staggered animations, `TabView`, `Tab` (iOS 18), matched geometry |
| `SummaryView.swift` | 357 | Summary tab with streaks and scores | `GeometryReader`, `UIViewRepresentable`, `UICalendarView`, hardcoded placeholder data |
| `ProfileView.swift` | 636 | Profile editing, photo, reminders, account | `ViewModifier`, `PhotosPicker`, `UNUserNotificationCenter`, async/await, `Toggle`, `DatePicker` |
