# Stamerlee iOS App (SwiftUI)

A modern, high-fidelity iOS frontend implementation of **Stamerlee** built with modern Swift and SwiftUI (iOS 17+ / Swift 6), faithfully reproducing all screens from the design screenshots with fully functional navigation, interactive states, and sound selections.

---

## 📱 Flow & Implemented Screens

1. **Launch Screen** (`LaunchView.swift`)
   - Deep midnight background (`#0B0C1E`) with bold centered "Stamerlee" typography and gentle breathing glow.
   - **Functional**: Automatically transitions after 1.8s or tap anywhere to enter immediately.

2. **Login / Get Started Screen** (`LoginView.swift`)
   - Dark top section with brand title + curved light periwinkle/lavender bottom sheet.
   - **Functional Buttons**:
     - `Continue with Apple`: Authenticates with haptic feedback & navigates to onboarding.
     - `Continue with Google`: Authenticates with Google branding & navigates to onboarding.
     - `Continue with Email`: Opens an interactive email & password input sheet.
     - `Terms of Service` & `Privacy Policy`: Open interactive readable modal sheets.

3. **Onboarding Info 1: "Small steps, stronger speech"** (`OnboardingStepOneView.swift`)
   - Page dots indicator (Step 1 active).
   - Dynamic headline with purple accent gradient text.
   - Uses uploaded image (`OnboardingHero1.png`).
   - **Functional**: "Begin" button advances to Onboarding Step 2.

4. **Onboarding Info 2: "Support on your schedule"** (`OnboardingStepTwoView.swift`)
   - Page dots indicator (Step 2 active).
   - Speech coach video call card illustration with quote bubble (`OnboardingHero2.png`).
   - **Functional**:
     - Circular back button `<` returns to Step 1.
     - "Continue" button advances to Challenging Sounds screen.

5. **Challenging Sounds** (`ChallengingSoundsView.swift`)
   - Circular back button `<` to return to previous step.
   - White card container with question: *"What are the sounds you stutter on?"*
   - Options: `P, B`, `T, D`, `K, G`, and `Something else` (reveals smooth custom sound input field).
   - **Functional**: "Continue" button advances to **Explore Activities**.

6. **Explore Activities** (`ExploreActivitiesView.swift`) *(Screenshot 1)*
   - Circular back button `<` returns to Challenging Sounds.
   - Title: *"Explore activities designed for your stutter"*
   - 4 activity cards using uploaded images:
     - **Prolonged Speech**: *"Learn smooth pacing with prolonged speech and continuous airflow exercises"*
     - **Picture Description**: *"Build spontaneous fluency with picture description"*
     - **Dial Scene**: *"Simulate phone calls using dial scene to build conversational confidence"*
     - **Mirror Narration**: *"Monitor your physical tension during narration with mirror exercises"*
   - **Functional**: "Continue" button navigates to **Home / Welcome**.

7. **Home / Welcome Dashboard** (`HomeDashboardView.swift`) *(Screenshot 2)*
   - Title: *"Welcome"*
   - **Daily Goal Banner**: Uses uploaded `ClockIllustration.png` with *"Practice for 10 minutes"* goal.
   - **Exercises Section**:
     - `Prolonged Speech` (Unlocked, chevron `>`): Tapping navigates to **Prolonged Speech Intro**.
     - `Picture Description`, `Dial Scene`, `Narration` (Locked with blue lock badge): Tapping displays unlock requirement alerts.
   - **Practice Section**:
     - `Beat Buddy` (Locked with blue lock badge).
   - **Floating Tab Bar**: Interactive Home, Insights, and Profile tabs.

8. **Prolonged Speech Intro** (`ProlongedSpeechIntroView.swift`) *(Screenshot 3)*
   - Circular back button `<` returns to Home.
   - Title: *"Let's start with Prolonged Speech"*
   - Subtitle: *"Learn to gently stretch sounds and connect words smoothly. This technique can help reduce speech tension and improve fluency with practice"*
   - Hero Illustration: Uses uploaded `ProlongedSpeechHero.png` (girl practicing stretching speech).
   - **Functional**: "Continue" button navigates to **Difficulty Selection**.

9. **Prolonged Speech Difficulty Selection** (`ProlongedSpeechDifficultyView.swift`) *(Screenshot 4)*
   - Circular back button `<` returns to Prolonged Speech Intro.
   - Title: *"Prolonged Speech"*
   - Subtitle: *"Practice stretching sounds for smoother,more fluent speech."*
   - Cards:
     - `Easy` (Unlocked): Tapping opens the interactive audio speech practice session sheet with live waveform and mic recording!
     - `Medium` (Locked with blue lock badge).
     - `Hard` (Locked with blue lock badge).

---

## 🛠 Project Structure

```
├── Stamerlee.xcodeproj/                # Xcode Project (Double-click to open in Xcode)
└── Stamerlee/
    ├── StamerleeApp.swift              # Modern @main entry point
    ├── ContentView.swift               # Root navigation host with slide transitions
    ├── ColorTheme.swift                # Design system color tokens
    ├── AppScreen.swift                 # @Observable state manager
    ├── Components.swift                # Reusable buttons, cards, tab bar, indicators
    ├── Illustrations.swift             # Safe asset loaders with local fallbacks
    ├── LaunchView.swift                # Screen 1 (Launch)
    ├── LoginView.swift                 # Screen 2 (Login / Get Started)
    ├── OnboardingStepOneView.swift     # Screen 3 (Onboarding 1)
    ├── OnboardingStepTwoView.swift     # Screen 4 (Onboarding 2)
    ├── ChallengingSoundsView.swift     # Screen 5 (Challenging Sounds)
    ├── ExploreActivitiesView.swift     # Screen 6 (Explore Activities)
    ├── HomeDashboardView.swift         # Screen 7 (Home / Welcome)
    ├── ProlongedSpeechIntroView.swift  # Screen 8 (Prolonged Speech Intro)
    └── ProlongedSpeechDifficultyView.swift # Screen 9 (Difficulty Selection)
```

---

## 🚀 How to Run

1. Open [Stamerlee.xcodeproj](file:///Users/user89/Documents/bitch/Stamerlee.xcodeproj) in Xcode.
2. Select any iPhone simulator (e.g. iPhone 15 / 16) or a connected iPhone.
3. Press **Cmd + R** to run.
4. **Quick Screen Jump**: Double-tap anywhere with two fingers to reveal the screen switcher pill and jump directly to any screen!
