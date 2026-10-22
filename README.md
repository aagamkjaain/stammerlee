# Stamerlee iOS App (SwiftUI)

A modern, high-fidelity iOS frontend implementation of **Stamerlee** built with modern Swift and SwiftUI (iOS 17+ / Swift 6), faithfully reproducing the UI from the design screenshots with fully functional navigation, interactive states, and sound selections.

---

## 📱 Included Screens & Functional Flows

1. **Launch Screen** (`LaunchView.swift`)
   - Deep midnight background (`#0B0C1E`) with bold centered "Stamerlee" typography and gentle breathing glow.
   - **Functional**: Automatically transitions after 1.8s or tap anywhere to enter immediately.

2. **Login / Get Started Screen** (`LoginView.swift`)
   - Dark top section with brand title + curved light lavender/periwinkle bottom sheet.
   - **Functional Buttons**:
     - `Continue with Apple`: Authenticates with haptic feedback & navigates to onboarding.
     - `Continue with Google`: Authenticates with Google branding & navigates to onboarding.
     - `Continue with Email`: Opens an interactive email & password input sheet.
     - `Terms of Service` & `Privacy Policy`: Open interactive readable modal sheets.

3. **Onboarding Info 1: "Small steps, stronger speech"** (`OnboardingStepOneView.swift`)
   - Page dots indicator (Step 1 active).
   - Dynamic headline with purple accent gradient text.
   - Custom native SwiftUI vector illustration: serene listener with headphones and floating microphone badge with animated pulse rings.
   - **Functional**: "Begin" button advances to Onboarding Step 2.

4. **Onboarding Info 2: "Support on your schedule"** (`OnboardingStepTwoView.swift`)
   - Page dots indicator (Step 2 active).
   - Custom native SwiftUI vector illustration: Video call card with speech coach waving, speech bubble quote: *"You don't have to rush. Take your time, one word at a time."*, and call audio controls.
   - **Functional**:
     - Circular back button `<` returns to Step 1.
     - "Continue" button advances to Challenging Sounds screen.

5. **Challenging Sounds** (`ChallengingSoundsView.swift`)
   - Circular back button `<` to return to previous step.
   - White card container with question: *"What are the sounds you stutter on?"*
   - **Functional Interactive Options**:
     - `P, B (Please, book)`
     - `T, D (Today, do)` (selected by default with active radio checkmark)
     - `K, G (Come, go)`
     - `Something else`: selecting this reveals a smooth animated custom text field for typing custom sounds/phonemes.
   - **Functional**: "Continue" button is enabled based on selection and advances to the plan completion view.

6. **Plan Ready Screen** (`PlanReadyView.swift`)
   - Celebratory completion view presenting the user's customized daily fluency plan.
   - Displays dynamic tags for the selected sounds.
   - Includes an interactive practice simulator with live timer and a "Restart" button to test the flow again.

---

## 🛠 Project Structure

```
├── Stamerlee.xcodeproj/        # Xcode Project (Open directly in Xcode)
└── Stamerlee/
    ├── StamerleeApp.swift      # Modern @main entry point
    ├── ContentView.swift       # Navigation host with directional slide animations
    ├── ColorTheme.swift        # Palette matching screenshots (Dark #0B0C1E, #0A84FF, etc.)
    ├── AppScreen.swift         # @Observable state manager & data models
    ├── Components.swift        # PrimaryActionButton, SocialAuthRow, PageIndicatorView, OptionSelectRow
    ├── Illustrations.swift     # Vector illustrations for headphone listener & speech coach
    ├── LaunchView.swift        # Screenshot 1 (Launch Screen)
    ├── LoginView.swift         # Screenshot 2 (Login Screen)
    ├── OnboardingStepOneView.swift # Screenshot 3 (Onboarding 1)
    ├── OnboardingStepTwoView.swift # Screenshot 4 (Onboarding 2)
    ├── ChallengingSoundsView.swift # Screenshot 5 (Challenging Sounds)
    └── PlanReadyView.swift     # Final personalized plan & practice simulator
```

---

## 🚀 How to Run

### In Xcode:
1. Double-click [Stamerlee.xcodeproj](file:///Users/user89/Documents/bitch/Stamerlee.xcodeproj) to open it in Xcode.
2. Select any iOS Simulator (e.g., iPhone 15 / iPhone 16) or a connected iPhone.
3. Press **Cmd + R** to run.
4. You can also view interactive previews in Xcode Previews using `#Preview`.

### Quick Screen Jump (Testing):
- While running the app, **double-tap anywhere with two fingers** to reveal the quick screen jump bar to instantly switch between any of the 5 screens!
