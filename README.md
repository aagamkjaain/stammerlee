# Stamerlee iOS App (SwiftUI)

A modern, high-fidelity iOS frontend implementation of **Stamerlee** built with modern Swift and SwiftUI (iOS 17+ / Swift 6), faithfully reproducing all screens from the design screenshots with fully functional navigation, interactive states, and sound selections.

---

## 📱 App Flow & Implemented Screens

1. **Launch Screen** (`OnboardingViews.swift`)
   - Deep midnight background (`#0B0C1E`) with bold centered "Stamerlee" typography and gentle breathing glow.
   - **Functional**: Automatically transitions after 1.8s or tap anywhere to enter immediately.

2. **Login / Get Started Screen** (`OnboardingViews.swift`)
   - Dark top section with brand title + curved light periwinkle/lavender bottom sheet.
   - **Functional Buttons**:
     - `Continue with Apple`: Authenticates with haptic feedback & navigates to onboarding.
     - `Continue with Google`: Authenticates with Google branding & navigates to onboarding.
     - `Continue with Email`: Opens an interactive email & password input sheet.
     - `Terms of Service` & `Privacy Policy`: Open interactive readable modal sheets.

3. **Onboarding Info 1: "Small steps, stronger speech"** (`OnboardingViews.swift`)
   - Page dots indicator (Step 1 active).
   - Dynamic headline with purple accent gradient text.
   - Uses uploaded image (`OnboardingHero1.png`).
   - **Functional**: "Begin" button advances to Onboarding Step 2.

4. **Onboarding Info 2: "Support on your schedule"** (`OnboardingViews.swift`)
   - Page dots indicator (Step 2 active).
   - Speech coach video call card illustration with quote bubble (`OnboardingHero2.png`).
   - **Functional**:
     - Circular back button `<` returns to Step 1.
     - "Continue" button advances to Challenging Sounds screen.

5. **Challenging Sounds** (`OnboardingViews.swift`)
   - Circular back button `<` to return to previous step.
   - White card container with question: *"What are the sounds you stutter on?"*
   - Options: `P, B`, `T, D`, `K, G`, and `Something else` (reveals smooth custom sound input field).
   - **Functional**: "Continue" button advances to **Explore Activities**.

6. **Explore Activities** (`OnboardingViews.swift`)
   - Circular back button `<` returns to Challenging Sounds.
   - Title: *"Explore activities designed for your stutter"*
   - 4 activity cards using uploaded images:
     - **Prolonged Speech**: *"Learn smooth pacing with prolonged speech and continuous airflow exercises"*
     - **Picture Description**: *"Build spontaneous fluency with picture description"*
     - **Dial Scene**: *"Simulate phone calls using dial scene to build conversational confidence"*
     - **Mirror Narration**: *"Monitor your physical tension during narration with mirror exercises"*
   - **Functional**: "Continue" button navigates to **Home / Welcome**.

7. **Home / Welcome Dashboard** (`HomeDashboardView.swift`)
   - Title: *"Welcome"*
   - **Daily Goal Banner**: Uses uploaded `ClockIllustration.png` with *"Practice for 10 minutes"* goal.
   - **Exercises Section**:
     - `Prolonged Speech` (Unlocked, chevron `>`): Tapping navigates to **Prolonged Speech Intro**.
     - `Picture Description`, `Dial Scene`, `Narration` (Locked with blue lock badge): Tapping displays unlock requirement alerts.
   - **Practice Section**:
     - `Beat Buddy` (Locked with blue lock badge).
   - **Floating Tab Bar**: Interactive Home, Insights, and Profile tabs.

8. **Prolonged Speech Intro** (`ProlongedSpeechIntroView.swift`)
   - Circular back button `<` returns to Home.
   - Title: *"Let's start with Prolonged Speech"*
   - Subtitle: *"Learn to gently stretch sounds and connect words smoothly. This technique can help reduce speech tension and improve fluency with practice"*
   - Hero Illustration: Uses uploaded `ProlongedSpeechHero.png`.
   - **Functional**: "Continue" button navigates to **Difficulty Selection**.

9. **Prolonged Speech Difficulty Selection** (`ProlongedSpeechDifficultyView.swift`)
   - Circular back button `<` returns to Prolonged Speech Intro.
   - Title: *"Prolonged Speech"*
   - Subtitle: *"Practice stretching sounds for smoother,more fluent speech."*
   - Cards:
     - `Easy` (Unlocked): Tapping navigates directly to the **Prolonged Easy Level** practice screen.
     - `Medium` (Locked with blue lock badge).
     - `Hard` (Locked with blue lock badge).

10. **Prolonged Easy Practice** (`ProlongedPracticeView.swift`) *(New "prolonged easy level")*
    - Circular back button `<` returns to Difficulty Selection.
    - **DAF Toggle Button**: Top right pill with headphones icon and active feedback state.
    - Title: *"Easy"*
    - Subtitle: *"Stretch the sounds gently as you speak, keeping each word slow, and relaxed"*
    - **Word Card**: Soft pill container with bold blue text: **“Wattttter...”** and 3-dot indicator.
    - **Concentric Mic Button**: Outer periwinkle ring + inner dark circle with pulsing soundwave animation.
    - **Functional**: "Finish" button navigates to **Analysis**.

11. **Analysis & Word Selection** (`ProlongedPracticeView.swift`) *(New "pro res")*
    - Title: *"Analysis"*
    - **Score**: *"YOU SCORED 86%"*
    - Subtitle: *"Choose the words to practice them using Beat Buddy"*
    - **Segmented Control**: *"Blocks"* / *"Repetition"*
    - **2-Column Word Grid**: Selectable pills for `Water`, `University`, `Breaking`, `Computer`, `Scale`, and `laptop`.
    - **Functional**: "Done" button returns to **Home Dashboard**.

---

## 🛠 Consolidated Project Structure

```
├── Stamerlee.xcodeproj/                # Xcode Project (Double-click to open in Xcode)
└── Stamerlee/
    ├── StamerleeApp.swift              # Modern @main entry point
    ├── ContentView.swift               # Root navigation host with slide transitions
    ├── ColorTheme.swift                # Design system color tokens
    ├── AppScreen.swift                 # @Observable state manager
    ├── Components.swift                # Reusable buttons, cards, tab bar, indicators
    ├── Illustrations.swift             # Safe asset loaders with local fallbacks
    ├── OnboardingViews.swift           # Consolidated onboarding screens (Launch, Login, Info1, Info2, Sounds, Explore)
    ├── HomeDashboardView.swift         # Home / Welcome dashboard
    ├── ProlongedSpeechIntroView.swift  # Prolonged Speech Intro
    ├── ProlongedSpeechDifficultyView.swift # Difficulty selection
    └── ProlongedPracticeView.swift     # Prolonged Easy Level ("Wattttter...") & Analysis ("86%")
```

---

## 🚀 How to Run

1. Open [Stamerlee.xcodeproj](file:///Users/user89/Documents/bitch/Stamerlee.xcodeproj) in Xcode.
2. Select any iPhone simulator (e.g. iPhone 15 / 16) or a connected iPhone.
3. Press **Cmd + R** to run.
4. **Quick Screen Jump**: **Double-tap anywhere with two fingers** to toggle the screen switcher bar and jump straight to any screen!
