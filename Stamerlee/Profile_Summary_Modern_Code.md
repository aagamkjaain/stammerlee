# Profile and Summary Screens: Modern SwiftUI Review

This document reviews `ProfileView.swift` and `SummaryView.swift` shown in the supplied screenshot, with line-by-line explanations and a modern API/deprecation check.

## Screen responsibilities

| Screen | Responsibility | Main integrations |
|---|---|---|
| `ProfileView` | Profile identity, avatar editing, daily goal, reminders, account actions, and legal documents. | PhotosUI, UserNotifications, AppState, environment geometry reporting. |
| `SummaryView` | Practice streak, calendar, and exercise high-score cards. | LazyVGrid, UICalendarView via UIViewRepresentable, AppState navigation. |

## Modern-code check

Both screens use modern SwiftUI and Observation patterns. No definite deprecated API is present from source inspection.

- `@Bindable` with `AppState` is the current Observation-based shared-state pattern.
- `PhotosPicker` and `loadTransferable(type:)` are modern PhotosUI APIs.
- `.task(id:)` is appropriate for asynchronous photo loading tied to selection changes.
- `.onChange(of:)`, `.alert`, `.sheet`, `.sensoryFeedback`, `LazyVGrid`, and `NavigationStack`-compatible SwiftUI composition are current APIs.
- `UIViewRepresentable` with `UICalendarView` is an appropriate bridge when the native UIKit calendar is required.
- Potential behavior issue, not deprecation: notification scheduling should explicitly handle authorization denial and scheduling errors instead of relying only on UI state.
- Potential data issue, not deprecation: summary scores are hard-coded (`86`, `92`, `78`, `89`) rather than read from recorded AppState scores.
- Potential lifecycle issue, not deprecation: geometry reporting runs whenever layout changes; consider deduplicating identical frames if performance becomes an issue.
- `DateFormatter` is valid but recreated by the computed property; cache it or use modern format styles if formatting becomes frequent.

## Line-by-line explanation

### `Stamerlee/ProfileView.swift` (636 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports the framework needed by this source file. |
| 2 | `import PhotosUI` | Imports the framework needed by this source file. |
| 3 | `import UIKit` | Imports the framework needed by this source file. |
| 4 | `import UserNotifications` | Imports the framework needed by this source file. |
| 5 | `` | Blank line separating code sections. |
| 6 | `private struct ProfileAvatarFrameReportingModifier: ViewModifier {` | Declares a reusable SwiftUI view. |
| 7 | `    let slot: ProfileAvatarSlot` | Declares immutable configuration or local data. |
| 8 | `    @Environment(\.profileAvatarFrameReporter) private var report` | Reads a value passed through SwiftUI’s environment. |
| 9 | `` | Blank line separating code sections. |
| 10 | `    func body(content: Content) -> some View {` | Opens or closes a Swift scope or view-builder block. |
| 11 | `        content.background {` | Opens or closes a Swift scope or view-builder block. |
| 12 | `            GeometryReader { proxy in` | Reads layout geometry for avatar frame reporting. |
| 13 | `                Color.clear` | Implements the surrounding profile, summary, or view-builder expression. |
| 14 | `                    .onGeometryChange(for: CGRect.self) {` | Opens or closes a Swift scope or view-builder block. |
| 15 | `                        $0.frame(in: .global)` | Implements the surrounding profile, summary, or view-builder expression. |
| 16 | `                    } action: { frame in` | Implements the surrounding profile, summary, or view-builder expression. |
| 17 | `                        report?(slot, frame)` | Implements the surrounding profile, summary, or view-builder expression. |
| 18 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 19 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 20 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 21 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 22 | `}` | Opens or closes a Swift scope or view-builder block. |
| 23 | `` | Blank line separating code sections. |
| 24 | `extension View {` | Adds functionality to an existing type. |
| 25 | `    func reportProfileAvatarFrame(_ slot: ProfileAvatarSlot) -> some View {` | Opens or closes a Swift scope or view-builder block. |
| 26 | `        modifier(ProfileAvatarFrameReportingModifier(slot: slot))` | Implements the surrounding profile, summary, or view-builder expression. |
| 27 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 28 | `` | Blank line separating code sections. |
| 29 | `    func dropIn(_ shown: Bool, index: Int) -> some View {` | Opens or closes a Swift scope or view-builder block. |
| 30 | `        offset(y: shown ? 0 : -48)` | Implements the surrounding profile, summary, or view-builder expression. |
| 31 | `            .opacity(shown ? 1 : 0)` | Applies a SwiftUI modifier to the preceding view. |
| 32 | `            .animation(` | Applies a SwiftUI modifier to the preceding view. |
| 33 | `                .spring(response: 0.52, dampingFraction: 0.84)` | Applies a SwiftUI modifier to the preceding view. |
| 34 | `                    .delay(Double(index) * 0.09),` | Applies a SwiftUI modifier to the preceding view. |
| 35 | `                value: shown` | Implements the surrounding profile, summary, or view-builder expression. |
| 36 | `            )` | Implements the surrounding profile, summary, or view-builder expression. |
| 37 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 38 | `}` | Opens or closes a Swift scope or view-builder block. |
| 39 | `` | Blank line separating code sections. |
| 40 | `// MARK: - Profile` | Section marker organizing the screen implementation. |
| 41 | `/// Personal progress and settings screen presented from the dashboard's Profile tab.` | Comment describing the purpose of the following code. |
| 42 | `public struct ProfileView: View {` | Declares a reusable SwiftUI view. |
| 43 | `    @Bindable public var state: AppState` | Connects the view to the observable AppState for two-way mutation. |
| 44 | `    @Environment(\.profileAvatarFrameReporter) private var reportAvatarFrame` | Reads a value passed through SwiftUI’s environment. |
| 45 | `    @State private var isEditingProfile = false` | Stores view-local state managed by SwiftUI. |
| 46 | `    @State private var selectedPhoto: PhotosPickerItem?` | Stores view-local state managed by SwiftUI. |
| 47 | `    @State private var didAppearContent = false` | Stores view-local state managed by SwiftUI. |
| 48 | `` | Blank line separating code sections. |
| 49 | `    // Alerts and sheets` | Comment describing the purpose of the following code. |
| 50 | `    @State private var showLogoutConfirmation = false` | Stores view-local state managed by SwiftUI. |
| 51 | `    @State private var showDeleteConfirmation = false` | Stores view-local state managed by SwiftUI. |
| 52 | `    @State private var showLegalSheet = false` | Stores view-local state managed by SwiftUI. |
| 53 | `    @State private var legalSheetTitle = "Terms of Service"` | Stores view-local state managed by SwiftUI. |
| 54 | `    @State private var legalSheetContent = ""` | Stores view-local state managed by SwiftUI. |
| 55 | `    @State private var reminderSuccessTrigger = 0` | Stores view-local state managed by SwiftUI. |
| 56 | `` | Blank line separating code sections. |
| 57 | `    public init(state: AppState) {` | Initializes the view with shared state or configuration. |
| 58 | `        self.state = state` | Implements the surrounding profile, summary, or view-builder expression. |
| 59 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 60 | `` | Blank line separating code sections. |
| 61 | `    private var formattedReminderTime: String {` | Defines a computed helper view or value. |
| 62 | `        let formatter = DateFormatter()` | Declares immutable configuration or local data. |
| 63 | `        formatter.timeStyle = .short` | Implements the surrounding profile, summary, or view-builder expression. |
| 64 | `        return formatter.string(from: state.reminderTime)` | Returns the computed value or view. |
| 65 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 66 | `` | Blank line separating code sections. |
| 67 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 68 | `        ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 69 | `            StamerleeTheme.backgroundDark` | Implements the surrounding profile, summary, or view-builder expression. |
| 70 | `                .ignoresSafeArea()` | Extends the background into safe-area regions. |
| 71 | `` | Blank line separating code sections. |
| 72 | `            ScrollView(showsIndicators: false) {` | Opens or closes a Swift scope or view-builder block. |
| 73 | `                VStack(spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 74 | `                    profileHeader` | Implements the surrounding profile, summary, or view-builder expression. |
| 75 | `` | Blank line separating code sections. |
| 76 | `                    VStack(alignment: .leading, spacing: 22) {` | Opens or closes a Swift scope or view-builder block. |
| 77 | `//                        statsSection` | Comment describing the purpose of the following code. |
| 78 | `` | Blank line separating code sections. |
| 79 | `                        dailyGoalCard` | Implements the surrounding profile, summary, or view-builder expression. |
| 80 | `                            .dropIn(didAppearContent, index: 0)` | Applies a SwiftUI modifier to the preceding view. |
| 81 | `` | Blank line separating code sections. |
| 82 | `                        reminderCard` | Implements the surrounding profile, summary, or view-builder expression. |
| 83 | `                            .dropIn(didAppearContent, index: 1)` | Applies a SwiftUI modifier to the preceding view. |
| 84 | `` | Blank line separating code sections. |
| 85 | `                        accountSection` | Implements the surrounding profile, summary, or view-builder expression. |
| 86 | `                            .dropIn(didAppearContent, index: 2)` | Applies a SwiftUI modifier to the preceding view. |
| 87 | `` | Blank line separating code sections. |
| 88 | `                        legalHypertextSection` | Implements the surrounding profile, summary, or view-builder expression. |
| 89 | `                            .dropIn(didAppearContent, index: 3)` | Applies a SwiftUI modifier to the preceding view. |
| 90 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 91 | `                    .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 92 | `                    .padding(.top, 22)` | Adds layout spacing around the view. |
| 93 | `                    .padding(.bottom, 36)` | Adds layout spacing around the view. |
| 94 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 95 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 96 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 97 | `        .preferredColorScheme(.dark)` | Applies a SwiftUI modifier to the preceding view. |
| 98 | `        .onAppear {` | Runs setup when the view appears. |
| 99 | `            withAnimation(.spring(response: 0.48, dampingFraction: 0.84)) {` | Animates the enclosed state mutation. |
| 100 | `                didAppearContent = true` | Implements the surrounding profile, summary, or view-builder expression. |
| 101 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 102 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 103 | `        .alert("Log Out", isPresented: $showLogoutConfirmation) {` | Presents an alert controlled by a Boolean binding. |
| 104 | `            Button("Cancel", role: .cancel) {}` | Creates an interactive button. |
| 105 | `            Button("Log Out", role: .destructive) {` | Creates an interactive button. |
| 106 | `                state.logout()` | Implements the surrounding profile, summary, or view-builder expression. |
| 107 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 108 | `        } message: {` | Opens or closes a Swift scope or view-builder block. |
| 109 | `            Text("Are you sure you want to log out of your account?")` | Displays a text label. |
| 110 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 111 | `        .alert("Delete Account", isPresented: $showDeleteConfirmation) {` | Presents an alert controlled by a Boolean binding. |
| 112 | `            Button("Cancel", role: .cancel) {}` | Creates an interactive button. |
| 113 | `            Button("Delete Account", role: .destructive) {` | Creates an interactive button. |
| 114 | `                state.deleteAccount()` | Implements the surrounding profile, summary, or view-builder expression. |
| 115 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 116 | `        } message: {` | Opens or closes a Swift scope or view-builder block. |
| 117 | `            Text("This action is permanent and will remove your practice streak, exercise progress, and personal settings.")` | Displays a text label. |
| 118 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 119 | `        .sheet(isPresented: $showLegalSheet) {` | Presents modal content controlled by a Boolean binding. |
| 120 | `            LegalDocumentSheet(` | Implements the surrounding profile, summary, or view-builder expression. |
| 121 | `                title: legalSheetTitle,` | Implements the surrounding profile, summary, or view-builder expression. |
| 122 | `                content: legalSheetContent,` | Implements the surrounding profile, summary, or view-builder expression. |
| 123 | `                isPresented: $showLegalSheet` | Implements the surrounding profile, summary, or view-builder expression. |
| 124 | `            )` | Implements the surrounding profile, summary, or view-builder expression. |
| 125 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 126 | `        .sensoryFeedback(.success, trigger: reminderSuccessTrigger)` | Adds system haptic feedback driven by a state trigger. |
| 127 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 128 | `` | Blank line separating code sections. |
| 129 | `    // MARK: - Profile Header` | Section marker organizing the screen implementation. |
| 130 | `    private var profileHeader: some View {` | Defines a computed helper view or value. |
| 131 | `        ZStack(alignment: .topTrailing) {` | Opens or closes a Swift scope or view-builder block. |
| 132 | `            StamerleeTheme.profileHeaderBase` | Implements the surrounding profile, summary, or view-builder expression. |
| 133 | `                .frame(height: 184)` | Constrains the view size or alignment. |
| 134 | `` | Blank line separating code sections. |
| 135 | `            BackNavButton {` | Opens or closes a Swift scope or view-builder block. |
| 136 | `                state.navigate(to: .homeDashboard, forward: false)` | Implements the surrounding profile, summary, or view-builder expression. |
| 137 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 138 | `            .padding(.top, 18)` | Adds layout spacing around the view. |
| 139 | `            .padding(.leading, 20)` | Adds layout spacing around the view. |
| 140 | `            .frame(maxWidth: .infinity, alignment: .topLeading)` | Constrains the view size or alignment. |
| 141 | `` | Blank line separating code sections. |
| 142 | `            VStack(spacing: 9) {` | Opens or closes a Swift scope or view-builder block. |
| 143 | `                ProfileAvatar(` | Implements the surrounding profile, summary, or view-builder expression. |
| 144 | `                    style: state.profileAvatarStyle,` | Implements the surrounding profile, summary, or view-builder expression. |
| 145 | `                    imageData: state.profileAvatarData,` | Implements the surrounding profile, summary, or view-builder expression. |
| 146 | `                    size: 84` | Implements the surrounding profile, summary, or view-builder expression. |
| 147 | `                )` | Implements the surrounding profile, summary, or view-builder expression. |
| 148 | `                .opacity(state.isHeroAvatarTransitionActive ? 0 : 1)` | Applies a SwiftUI modifier to the preceding view. |
| 149 | `                .reportProfileAvatarFrame(.profile)` | Applies a SwiftUI modifier to the preceding view. |
| 150 | `` | Blank line separating code sections. |
| 151 | `                if isEditingProfile {` | Conditionally selects this behavior or view. |
| 152 | `                    avatarStylePicker` | Implements the surrounding profile, summary, or view-builder expression. |
| 153 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 154 | `` | Blank line separating code sections. |
| 155 | `                Group {` | Opens or closes a Swift scope or view-builder block. |
| 156 | `                    if isEditingProfile {` | Conditionally selects this behavior or view. |
| 157 | `                        TextField("Username", text: $state.profileName)` | Implements the surrounding profile, summary, or view-builder expression. |
| 158 | `                            .font(.system(size: 22, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 159 | `                            .foregroundStyle(StamerleeTheme.textPrimaryLight)` | Sets the foreground color or style. |
| 160 | `                            .multilineTextAlignment(.center)` | Applies a SwiftUI modifier to the preceding view. |
| 161 | `                            .textInputAutocapitalization(.words)` | Applies a SwiftUI modifier to the preceding view. |
| 162 | `                            .autocorrectionDisabled()` | Applies a SwiftUI modifier to the preceding view. |
| 163 | `                            .padding(.horizontal, 14)` | Adds layout spacing around the view. |
| 164 | `                            .frame(height: 38)` | Constrains the view size or alignment. |
| 165 | `                            .background(StamerleeTheme.profileCard)` | Adds a background behind the content. |
| 166 | `                            .clipShape(Capsule())` | Clips content to a supplied shape. |
| 167 | `                            .padding(.horizontal, 48)` | Adds layout spacing around the view. |
| 168 | `                    } else {` | Opens or closes a Swift scope or view-builder block. |
| 169 | `                        Text(state.profileName)` | Displays a text label. |
| 170 | `                            .font(.system(size: 28, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 171 | `                            .foregroundStyle(StamerleeTheme.textPrimaryDark)` | Sets the foreground color or style. |
| 172 | `                            .minimumScaleFactor(0.8)` | Applies a SwiftUI modifier to the preceding view. |
| 173 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 174 | `` | Blank line separating code sections. |
| 175 | `                    Text("Joined in October 2026")` | Displays a text label. |
| 176 | `                        .font(.system(size: 14, weight: .regular, design: .rounded))` | Sets typography, size, weight, and design. |
| 177 | `                        .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 178 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 179 | `                .offset(y: didAppearContent ? 0 : 8)` | Applies a SwiftUI modifier to the preceding view. |
| 180 | `                .opacity(didAppearContent ? 1 : 0)` | Applies a SwiftUI modifier to the preceding view. |
| 181 | `                .animation(` | Applies a SwiftUI modifier to the preceding view. |
| 182 | `                    .spring(response: 0.44, dampingFraction: 0.84).delay(0.08),` | Applies a SwiftUI modifier to the preceding view. |
| 183 | `                    value: didAppearContent` | Implements the surrounding profile, summary, or view-builder expression. |
| 184 | `                )` | Implements the surrounding profile, summary, or view-builder expression. |
| 185 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 186 | `            .frame(maxWidth: .infinity)` | Constrains the view size or alignment. |
| 187 | `            .padding(.top, 44)` | Adds layout spacing around the view. |
| 188 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 189 | `        .task(id: selectedPhoto) {` | Runs asynchronous work tied to the view lifecycle. |
| 190 | `            guard let selectedPhoto else { return }` | Requires a condition and exits early when it fails. |
| 191 | `            guard let data = try? await selectedPhoto.loadTransferable(type: Data.self) else { return }` | Requires a condition and exits early when it fails. |
| 192 | `            state.profileAvatarData = data` | Implements the surrounding profile, summary, or view-builder expression. |
| 193 | `            state.profileAvatarStyle = 0` | Implements the surrounding profile, summary, or view-builder expression. |
| 194 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 195 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 196 | `` | Blank line separating code sections. |
| 197 | `    private var avatarStylePicker: some View {` | Defines a computed helper view or value. |
| 198 | `        HStack(spacing: 12) {` | Opens or closes a Swift scope or view-builder block. |
| 199 | `            ForEach(0..<3, id: \.self) { style in` | Creates repeated SwiftUI views from a collection. |
| 200 | `                Button {` | Creates an interactive button. |
| 201 | `                    state.profileAvatarData = nil` | Implements the surrounding profile, summary, or view-builder expression. |
| 202 | `                    state.profileAvatarStyle = style` | Implements the surrounding profile, summary, or view-builder expression. |
| 203 | `                } label: {` | Opens or closes a Swift scope or view-builder block. |
| 204 | `                    ProfileAvatar(style: style, imageData: nil)` | Implements the surrounding profile, summary, or view-builder expression. |
| 205 | `                        .scaleEffect(0.42)` | Applies a SwiftUI modifier to the preceding view. |
| 206 | `                        .frame(width: 42, height: 42)` | Constrains the view size or alignment. |
| 207 | `                        .background(` | Adds a background behind the content. |
| 208 | `                            Circle()` | Implements the surrounding profile, summary, or view-builder expression. |
| 209 | `                                .stroke(` | Applies a SwiftUI modifier to the preceding view. |
| 210 | `                                    state.profileAvatarStyle == style` | Implements the surrounding profile, summary, or view-builder expression. |
| 211 | `                                        ? StamerleeTheme.primaryBlue` | Implements the surrounding profile, summary, or view-builder expression. |
| 212 | `                                        : Color.clear,` | Implements the surrounding profile, summary, or view-builder expression. |
| 213 | `                                    lineWidth: 3` | Implements the surrounding profile, summary, or view-builder expression. |
| 214 | `                                )` | Implements the surrounding profile, summary, or view-builder expression. |
| 215 | `                        )` | Implements the surrounding profile, summary, or view-builder expression. |
| 216 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 217 | `                .accessibilityLabel("Avatar style \(style + 1)")` | Applies a SwiftUI modifier to the preceding view. |
| 218 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 219 | `` | Blank line separating code sections. |
| 220 | `            PhotosPicker(selection: $selectedPhoto, matching: .images) {` | Creates a modern PhotosUI photo picker. |
| 221 | `                Image(systemName: "photo")` | Displays an image asset or SF Symbol. |
| 222 | `                    .font(.system(size: 17, weight: .semibold))` | Sets typography, size, weight, and design. |
| 223 | `                    .foregroundStyle(StamerleeTheme.textPrimaryLight)` | Sets the foreground color or style. |
| 224 | `                    .frame(width: 42, height: 42)` | Constrains the view size or alignment. |
| 225 | `                    .background(StamerleeTheme.profileCard)` | Adds a background behind the content. |
| 226 | `                    .clipShape(Circle())` | Clips content to a supplied shape. |
| 227 | `                    .overlay(` | Draws an additional view above the content. |
| 228 | `                        Circle()` | Implements the surrounding profile, summary, or view-builder expression. |
| 229 | `                            .stroke(` | Applies a SwiftUI modifier to the preceding view. |
| 230 | `                                state.profileAvatarData != nil` | Implements the surrounding profile, summary, or view-builder expression. |
| 231 | `                                    ? StamerleeTheme.primaryBlue` | Implements the surrounding profile, summary, or view-builder expression. |
| 232 | `                                    : Color.clear,` | Implements the surrounding profile, summary, or view-builder expression. |
| 233 | `                                lineWidth: 3` | Implements the surrounding profile, summary, or view-builder expression. |
| 234 | `                            )` | Implements the surrounding profile, summary, or view-builder expression. |
| 235 | `                    )` | Implements the surrounding profile, summary, or view-builder expression. |
| 236 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 237 | `            .accessibilityLabel("Choose avatar photo")` | Applies a SwiftUI modifier to the preceding view. |
| 238 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 239 | `        .frame(height: 42)` | Constrains the view size or alignment. |
| 240 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 241 | `` | Blank line separating code sections. |
| 242 | `//    // MARK: - Stats Section` | Comment describing the purpose of the following code. |
| 243 | `//    private var statsSection: some View {` | Comment describing the purpose of the following code. |
| 244 | `//        VStack(alignment: .leading, spacing: 12) {` | Comment describing the purpose of the following code. |
| 245 | `//            HStack {` | Comment describing the purpose of the following code. |
| 246 | `//                sectionTitle("Stats")` | Comment describing the purpose of the following code. |
| 247 | `//` | Comment describing the purpose of the following code. |
| 248 | `//                Spacer()` | Comment describing the purpose of the following code. |
| 249 | `//` | Comment describing the purpose of the following code. |
| 250 | `//                Button {` | Comment describing the purpose of the following code. |
| 251 | `//                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {` | Comment describing the purpose of the following code. |
| 252 | `//                        isEditingProfile.toggle()` | Comment describing the purpose of the following code. |
| 253 | `//                    }` | Comment describing the purpose of the following code. |
| 254 | `//                } label: {` | Comment describing the purpose of the following code. |
| 255 | `//                    HStack(spacing: 5) {` | Comment describing the purpose of the following code. |
| 256 | `//                        Image(systemName: isEditingProfile ? "checkmark" : "pencil")` | Comment describing the purpose of the following code. |
| 257 | `//                            .font(.system(size: 11, weight: .bold))` | Comment describing the purpose of the following code. |
| 258 | `//                        Text(isEditingProfile ? "Done" : "Edit")` | Comment describing the purpose of the following code. |
| 259 | `//                            .font(.system(size: 13, weight: .bold, design: .rounded))` | Comment describing the purpose of the following code. |
| 260 | `//                    }` | Comment describing the purpose of the following code. |
| 261 | `//                    .foregroundStyle(isEditingProfile ? Color.white : StamerleeTheme.primaryBlue)` | Comment describing the purpose of the following code. |
| 262 | `//                    .padding(.horizontal, 12)` | Comment describing the purpose of the following code. |
| 263 | `//                    .padding(.vertical, 6)` | Comment describing the purpose of the following code. |
| 264 | `//                    .background(` | Comment describing the purpose of the following code. |
| 265 | `//                        isEditingProfile` | Comment describing the purpose of the following code. |
| 266 | `//                            ? StamerleeTheme.primaryBlue` | Comment describing the purpose of the following code. |
| 267 | `//                            : StamerleeTheme.profileCard,` | Comment describing the purpose of the following code. |
| 268 | `//                        in: Capsule()` | Comment describing the purpose of the following code. |
| 269 | `//                    )` | Comment describing the purpose of the following code. |
| 270 | `//                }` | Comment describing the purpose of the following code. |
| 271 | `//                .buttonStyle(.plain)` | Comment describing the purpose of the following code. |
| 272 | `//                .accessibilityLabel(isEditingProfile ? "Done editing profile" : "Edit name and avatar")` | Comment describing the purpose of the following code. |
| 273 | `//            }` | Comment describing the purpose of the following code. |
| 274 | `//` | Comment describing the purpose of the following code. |
| 275 | `//            VStack(alignment: .leading, spacing: 15) {` | Comment describing the purpose of the following code. |
| 276 | `//                stat(title: "8 minutes", subtitle: "Average session length")` | Comment describing the purpose of the following code. |
| 277 | `//                stat(title: "2 sessions", subtitle: "Sessions completed")` | Comment describing the purpose of the following code. |
| 278 | `//            }` | Comment describing the purpose of the following code. |
| 279 | `//            .padding(.horizontal, 16)` | Comment describing the purpose of the following code. |
| 280 | `//            .padding(.vertical, 16)` | Comment describing the purpose of the following code. |
| 281 | `//            .frame(maxWidth: .infinity, alignment: .leading)` | Comment describing the purpose of the following code. |
| 282 | `//            .background(StamerleeTheme.profileCard)` | Comment describing the purpose of the following code. |
| 283 | `//            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))` | Comment describing the purpose of the following code. |
| 284 | `//        }` | Comment describing the purpose of the following code. |
| 285 | `//    }` | Comment describing the purpose of the following code. |
| 286 | `` | Blank line separating code sections. |
| 287 | `    // MARK: - Daily Goal Card` | Section marker organizing the screen implementation. |
| 288 | `    private var dailyGoalCard: some View {` | Defines a computed helper view or value. |
| 289 | `        VStack(alignment: .leading, spacing: 12) {` | Opens or closes a Swift scope or view-builder block. |
| 290 | `            Text("Daily goal")` | Displays a text label. |
| 291 | `                .font(.system(size: 18, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 292 | `                .foregroundStyle(StamerleeTheme.textPrimaryLight)` | Sets the foreground color or style. |
| 293 | `` | Blank line separating code sections. |
| 294 | `            Picker("Daily practice time", selection: $state.dailyPracticeMinutes) {` | Creates a selection control bound to app state. |
| 295 | `                ForEach([5, 10, 15, 20], id: \.self) { minutes in` | Creates repeated SwiftUI views from a collection. |
| 296 | `                    Text("\(minutes) minutes")` | Displays a text label. |
| 297 | `                        .tag(minutes)` | Applies a SwiftUI modifier to the preceding view. |
| 298 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 299 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 300 | `            .pickerStyle(.menu)` | Applies a SwiftUI modifier to the preceding view. |
| 301 | `            .tint(StamerleeTheme.textSecondaryLight)` | Applies a SwiftUI modifier to the preceding view. |
| 302 | `            .font(.system(size: 15, weight: .semibold, design: .rounded))` | Sets typography, size, weight, and design. |
| 303 | `            .frame(maxWidth: .infinity, alignment: .leading)` | Constrains the view size or alignment. |
| 304 | `            .padding(.horizontal, 12)` | Adds layout spacing around the view. |
| 305 | `            .frame(height: 40)` | Constrains the view size or alignment. |
| 306 | `            .background(Color.white.opacity(0.72))` | Adds a background behind the content. |
| 307 | `            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))` | Clips content to a supplied shape. |
| 308 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 309 | `        .padding(.horizontal, 18)` | Adds layout spacing around the view. |
| 310 | `        .padding(.vertical, 16)` | Adds layout spacing around the view. |
| 311 | `        .background(StamerleeTheme.profileCard)` | Adds a background behind the content. |
| 312 | `        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))` | Clips content to a supplied shape. |
| 313 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 314 | `` | Blank line separating code sections. |
| 315 | `    // MARK: - Practice Reminder Card` | Section marker organizing the screen implementation. |
| 316 | `    private var reminderCard: some View {` | Defines a computed helper view or value. |
| 317 | `        VStack(alignment: .leading, spacing: 14) {` | Opens or closes a Swift scope or view-builder block. |
| 318 | `            HStack {` | Opens or closes a Swift scope or view-builder block. |
| 319 | `                HStack(spacing: 8) {` | Opens or closes a Swift scope or view-builder block. |
| 320 | `                    Image(systemName: "bell.badge.fill")` | Displays an image asset or SF Symbol. |
| 321 | `                        .font(.system(size: 18, weight: .bold))` | Sets typography, size, weight, and design. |
| 322 | `                        .foregroundStyle(StamerleeTheme.primaryBlue)` | Sets the foreground color or style. |
| 323 | `` | Blank line separating code sections. |
| 324 | `                    Text("Practice Reminder")` | Displays a text label. |
| 325 | `                        .font(.system(size: 18, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 326 | `                        .foregroundStyle(StamerleeTheme.textPrimaryLight)` | Sets the foreground color or style. |
| 327 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 328 | `` | Blank line separating code sections. |
| 329 | `                Spacer()` | Implements the surrounding profile, summary, or view-builder expression. |
| 330 | `` | Blank line separating code sections. |
| 331 | `                Toggle("", isOn: $state.reminderEnabled)` | Creates a Boolean toggle bound to app state. |
| 332 | `                    .labelsHidden()` | Applies a SwiftUI modifier to the preceding view. |
| 333 | `                    .tint(StamerleeTheme.primaryBlue)` | Applies a SwiftUI modifier to the preceding view. |
| 334 | `                    .onChange(of: state.reminderEnabled) { _, isEnabled in` | Observes a value and responds when it changes. |
| 335 | `                        if isEnabled {` | Conditionally selects this behavior or view. |
| 336 | `                            requestAndScheduleReminder(at: state.reminderTime)` | Implements the surrounding profile, summary, or view-builder expression. |
| 337 | `                        } else {` | Opens or closes a Swift scope or view-builder block. |
| 338 | `                            cancelReminders()` | Implements the surrounding profile, summary, or view-builder expression. |
| 339 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 340 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 341 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 342 | `` | Blank line separating code sections. |
| 343 | `            Text("Choose what time we should send a notification to remind you to practice.")` | Displays a text label. |
| 344 | `                .font(.system(size: 13, weight: .regular, design: .rounded))` | Sets typography, size, weight, and design. |
| 345 | `                .foregroundStyle(StamerleeTheme.textSecondaryLight)` | Sets the foreground color or style. |
| 346 | `` | Blank line separating code sections. |
| 347 | `            if state.reminderEnabled {` | Conditionally selects this behavior or view. |
| 348 | `                HStack {` | Opens or closes a Swift scope or view-builder block. |
| 349 | `                    Text("Reminder Time")` | Displays a text label. |
| 350 | `                        .font(.system(size: 15, weight: .semibold, design: .rounded))` | Sets typography, size, weight, and design. |
| 351 | `                        .foregroundStyle(StamerleeTheme.textPrimaryLight)` | Sets the foreground color or style. |
| 352 | `` | Blank line separating code sections. |
| 353 | `                    Spacer()` | Implements the surrounding profile, summary, or view-builder expression. |
| 354 | `` | Blank line separating code sections. |
| 355 | `                    DatePicker(` | Creates a date/time selection control. |
| 356 | `                        "",` | Implements the surrounding profile, summary, or view-builder expression. |
| 357 | `                        selection: $state.reminderTime,` | Implements the surrounding profile, summary, or view-builder expression. |
| 358 | `                        displayedComponents: .hourAndMinute` | Implements the surrounding profile, summary, or view-builder expression. |
| 359 | `                    )` | Implements the surrounding profile, summary, or view-builder expression. |
| 360 | `                    .labelsHidden()` | Applies a SwiftUI modifier to the preceding view. |
| 361 | `                    .tint(StamerleeTheme.primaryBlue)` | Applies a SwiftUI modifier to the preceding view. |
| 362 | `                    .onChange(of: state.reminderTime) { _, newTime in` | Observes a value and responds when it changes. |
| 363 | `                        requestAndScheduleReminder(at: newTime)` | Implements the surrounding profile, summary, or view-builder expression. |
| 364 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 365 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 366 | `                .padding(.horizontal, 14)` | Adds layout spacing around the view. |
| 367 | `                .frame(height: 48)` | Constrains the view size or alignment. |
| 368 | `                .background(Color.white.opacity(0.85))` | Adds a background behind the content. |
| 369 | `                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))` | Clips content to a supplied shape. |
| 370 | `` | Blank line separating code sections. |
| 371 | `                HStack(spacing: 6) {` | Opens or closes a Swift scope or view-builder block. |
| 372 | `                    Image(systemName: "checkmark.circle.fill")` | Displays an image asset or SF Symbol. |
| 373 | `                        .font(.system(size: 13, weight: .bold))` | Sets typography, size, weight, and design. |
| 374 | `                        .foregroundStyle(.green)` | Sets the foreground color or style. |
| 375 | `                    Text("Reminder set for \(formattedReminderTime) daily")` | Displays a text label. |
| 376 | `                        .font(.system(size: 12, weight: .medium, design: .rounded))` | Sets typography, size, weight, and design. |
| 377 | `                        .foregroundStyle(StamerleeTheme.textSecondaryLight)` | Sets the foreground color or style. |
| 378 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 379 | `                .padding(.top, 2)` | Adds layout spacing around the view. |
| 380 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 381 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 382 | `        .padding(18)` | Adds layout spacing around the view. |
| 383 | `        .background(StamerleeTheme.profileCard)` | Adds a background behind the content. |
| 384 | `        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))` | Clips content to a supplied shape. |
| 385 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 386 | `` | Blank line separating code sections. |
| 387 | `    // MARK: - Account Section (Log Out & Delete Account)` | Section marker organizing the screen implementation. |
| 388 | `    private var accountSection: some View {` | Defines a computed helper view or value. |
| 389 | `        VStack(alignment: .leading, spacing: 12) {` | Opens or closes a Swift scope or view-builder block. |
| 390 | `            sectionTitle("Account")` | Implements the surrounding profile, summary, or view-builder expression. |
| 391 | `` | Blank line separating code sections. |
| 392 | `            VStack(spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 393 | `                // Log Out Row` | Comment describing the purpose of the following code. |
| 394 | `                Button {` | Creates an interactive button. |
| 395 | `                    showLogoutConfirmation = true` | Implements the surrounding profile, summary, or view-builder expression. |
| 396 | `                } label: {` | Opens or closes a Swift scope or view-builder block. |
| 397 | `                    HStack(spacing: 12) {` | Opens or closes a Swift scope or view-builder block. |
| 398 | `                        Image(systemName: "rectangle.portrait.and.arrow.right")` | Displays an image asset or SF Symbol. |
| 399 | `                            .font(.system(size: 17, weight: .semibold))` | Sets typography, size, weight, and design. |
| 400 | `                            .foregroundStyle(StamerleeTheme.textPrimaryLight)` | Sets the foreground color or style. |
| 401 | `                            .frame(width: 28)` | Constrains the view size or alignment. |
| 402 | `` | Blank line separating code sections. |
| 403 | `                        VStack(alignment: .leading, spacing: 2) {` | Opens or closes a Swift scope or view-builder block. |
| 404 | `                            Text("Log Out")` | Displays a text label. |
| 405 | `                                .font(.system(size: 15, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 406 | `                                .foregroundStyle(StamerleeTheme.textPrimaryLight)` | Sets the foreground color or style. |
| 407 | `                            Text(state.userEmail.isEmpty ? "Sign out of your active session" : "Signed in as \(state.userEmail)")` | Displays a text label. |
| 408 | `                                .font(.system(size: 12, weight: .regular, design: .rounded))` | Sets typography, size, weight, and design. |
| 409 | `                                .foregroundStyle(StamerleeTheme.textSecondaryLight)` | Sets the foreground color or style. |
| 410 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 411 | `` | Blank line separating code sections. |
| 412 | `                        Spacer()` | Implements the surrounding profile, summary, or view-builder expression. |
| 413 | `` | Blank line separating code sections. |
| 414 | `                        Image(systemName: "chevron.right")` | Displays an image asset or SF Symbol. |
| 415 | `                            .font(.system(size: 13, weight: .semibold))` | Sets typography, size, weight, and design. |
| 416 | `                            .foregroundStyle(StamerleeTheme.textSecondaryLight)` | Sets the foreground color or style. |
| 417 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 418 | `                    .padding(.horizontal, 16)` | Adds layout spacing around the view. |
| 419 | `                    .frame(height: 58)` | Constrains the view size or alignment. |
| 420 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 421 | `                .buttonStyle(.haptic)` | Applies a SwiftUI modifier to the preceding view. |
| 422 | `` | Blank line separating code sections. |
| 423 | `                Divider()` | Implements the surrounding profile, summary, or view-builder expression. |
| 424 | `                    .padding(.horizontal, 16)` | Adds layout spacing around the view. |
| 425 | `` | Blank line separating code sections. |
| 426 | `                // Delete Account Row` | Comment describing the purpose of the following code. |
| 427 | `                Button {` | Creates an interactive button. |
| 428 | `                    showDeleteConfirmation = true` | Implements the surrounding profile, summary, or view-builder expression. |
| 429 | `                } label: {` | Opens or closes a Swift scope or view-builder block. |
| 430 | `                    HStack(spacing: 12) {` | Opens or closes a Swift scope or view-builder block. |
| 431 | `                        Image(systemName: "trash.fill")` | Displays an image asset or SF Symbol. |
| 432 | `                            .font(.system(size: 16, weight: .semibold))` | Sets typography, size, weight, and design. |
| 433 | `                            .foregroundStyle(Color.red)` | Sets the foreground color or style. |
| 434 | `                            .frame(width: 28)` | Constrains the view size or alignment. |
| 435 | `` | Blank line separating code sections. |
| 436 | `                        VStack(alignment: .leading, spacing: 2) {` | Opens or closes a Swift scope or view-builder block. |
| 437 | `                            Text("Delete Account")` | Displays a text label. |
| 438 | `                                .font(.system(size: 15, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 439 | `                                .foregroundStyle(Color.red)` | Sets the foreground color or style. |
| 440 | `                            ` | Blank line separating code sections. |
| 441 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 442 | `` | Blank line separating code sections. |
| 443 | `                        Spacer()` | Implements the surrounding profile, summary, or view-builder expression. |
| 444 | `` | Blank line separating code sections. |
| 445 | `                        Image(systemName: "chevron.right")` | Displays an image asset or SF Symbol. |
| 446 | `                            .font(.system(size: 13, weight: .semibold))` | Sets typography, size, weight, and design. |
| 447 | `                            .foregroundStyle(Color.red.opacity(0.6))` | Sets the foreground color or style. |
| 448 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 449 | `                    .padding(.horizontal, 16)` | Adds layout spacing around the view. |
| 450 | `                    .frame(height: 58)` | Constrains the view size or alignment. |
| 451 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 452 | `                .buttonStyle(.haptic)` | Applies a SwiftUI modifier to the preceding view. |
| 453 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 454 | `            .background(StamerleeTheme.profileCard)` | Adds a background behind the content. |
| 455 | `            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))` | Clips content to a supplied shape. |
| 456 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 457 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 458 | `` | Blank line separating code sections. |
| 459 | `    // MARK: - Legal Hypertext Section` | Section marker organizing the screen implementation. |
| 460 | `    private var legalHypertextSection: some View {` | Defines a computed helper view or value. |
| 461 | `        VStack(spacing: 8) {` | Opens or closes a Swift scope or view-builder block. |
| 462 | `            HStack(spacing: 8) {` | Opens or closes a Swift scope or view-builder block. |
| 463 | `                Button {` | Creates an interactive button. |
| 464 | `                    openTerms()` | Implements the surrounding profile, summary, or view-builder expression. |
| 465 | `                } label: {` | Opens or closes a Swift scope or view-builder block. |
| 466 | `                    Text("Terms of Service")` | Displays a text label. |
| 467 | `                        .font(.system(size: 13, weight: .semibold, design: .rounded))` | Sets typography, size, weight, and design. |
| 468 | `                        .underline()` | Applies a SwiftUI modifier to the preceding view. |
| 469 | `                        .foregroundStyle(StamerleeTheme.primaryBlue)` | Sets the foreground color or style. |
| 470 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 471 | `` | Blank line separating code sections. |
| 472 | `                Text("•")` | Displays a text label. |
| 473 | `                    .font(.system(size: 12))` | Sets typography, size, weight, and design. |
| 474 | `                    .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 475 | `` | Blank line separating code sections. |
| 476 | `                Button {` | Creates an interactive button. |
| 477 | `                    openPrivacyPolicy()` | Implements the surrounding profile, summary, or view-builder expression. |
| 478 | `                } label: {` | Opens or closes a Swift scope or view-builder block. |
| 479 | `                    Text("Privacy Policy")` | Displays a text label. |
| 480 | `                        .font(.system(size: 13, weight: .semibold, design: .rounded))` | Sets typography, size, weight, and design. |
| 481 | `                        .underline()` | Applies a SwiftUI modifier to the preceding view. |
| 482 | `                        .foregroundStyle(StamerleeTheme.primaryBlue)` | Sets the foreground color or style. |
| 483 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 484 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 485 | `            .padding(.top, 8)` | Adds layout spacing around the view. |
| 486 | `` | Blank line separating code sections. |
| 487 | `            Text("Stamerlee v1.0.0 • All rights reserved")` | Displays a text label. |
| 488 | `                .font(.system(size: 11, weight: .regular, design: .rounded))` | Sets typography, size, weight, and design. |
| 489 | `                .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 490 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 491 | `        .frame(maxWidth: .infinity, alignment: .center)` | Constrains the view size or alignment. |
| 492 | `        .padding(.top, 4)` | Adds layout spacing around the view. |
| 493 | `        .padding(.bottom, 16)` | Adds layout spacing around the view. |
| 494 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 495 | `` | Blank line separating code sections. |
| 496 | `    // MARK: - Notification Helpers` | Section marker organizing the screen implementation. |
| 497 | `    private func requestAndScheduleReminder(at time: Date) {` | Defines a private helper for UI or notification behavior. |
| 498 | `        let center = UNUserNotificationCenter.current()` | Declares immutable configuration or local data. |
| 499 | `        Task { @MainActor in` | Implements the surrounding profile, summary, or view-builder expression. |
| 500 | `            let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false` | Declares immutable configuration or local data. |
| 501 | `            if granted {` | Conditionally selects this behavior or view. |
| 502 | `                scheduleNotification(at: time)` | Implements the surrounding profile, summary, or view-builder expression. |
| 503 | `            } else {` | Opens or closes a Swift scope or view-builder block. |
| 504 | `                state.reminderEnabled = false` | Implements the surrounding profile, summary, or view-builder expression. |
| 505 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 506 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 507 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 508 | `` | Blank line separating code sections. |
| 509 | `    private func scheduleNotification(at time: Date) {` | Defines a private helper for UI or notification behavior. |
| 510 | `        let center = UNUserNotificationCenter.current()` | Declares immutable configuration or local data. |
| 511 | `        center.removeAllPendingNotificationRequests()` | Implements the surrounding profile, summary, or view-builder expression. |
| 512 | `` | Blank line separating code sections. |
| 513 | `        let content = UNMutableNotificationContent()` | Declares immutable configuration or local data. |
| 514 | `        content.title = "Time for your speech practice! 🎯"` | Implements the surrounding profile, summary, or view-builder expression. |
| 515 | `        content.body = "A quick 5-10 minute session with Beat Buddy helps keep your speech steady and confident."` | Implements the surrounding profile, summary, or view-builder expression. |
| 516 | `        content.sound = .default` | Implements the surrounding profile, summary, or view-builder expression. |
| 517 | `` | Blank line separating code sections. |
| 518 | `        let components = Calendar.current.dateComponents([.hour, .minute], from: time)` | Declares immutable configuration or local data. |
| 519 | `        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)` | Declares immutable configuration or local data. |
| 520 | `        let request = UNNotificationRequest(identifier: "daily_practice_reminder", content: content, trigger: trigger)` | Declares immutable configuration or local data. |
| 521 | `        center.add(request)` | Implements the surrounding profile, summary, or view-builder expression. |
| 522 | `` | Blank line separating code sections. |
| 523 | `        reminderSuccessTrigger += 1` | Implements the surrounding profile, summary, or view-builder expression. |
| 524 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 525 | `` | Blank line separating code sections. |
| 526 | `    private func cancelReminders() {` | Defines a private helper for UI or notification behavior. |
| 527 | `        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()` | Implements the surrounding profile, summary, or view-builder expression. |
| 528 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 529 | `` | Blank line separating code sections. |
| 530 | `    private func openTerms() {` | Defines a private helper for UI or notification behavior. |
| 531 | `        legalSheetTitle = "Terms of Service"` | Implements the surrounding profile, summary, or view-builder expression. |
| 532 | `        legalSheetContent = """` | Implements the surrounding profile, summary, or view-builder expression. |
| 533 | `        Welcome to Stamerlee. By using our application, you agree to these Terms of Service.` | Implements the surrounding profile, summary, or view-builder expression. |
| 534 | `` | Blank line separating code sections. |
| 535 | `        1. Scope of Service: Stamerlee provides speech pacing, fluency exercises, and auditory feedback tools designed for personal fluency training and practice.` | Implements the surrounding profile, summary, or view-builder expression. |
| 536 | `        2. Personal Practice: Stamerlee is an educational and supportive tool. It does not replace clinical medical diagnosis or direct guidance from certified speech-language pathologists.` | Implements the surrounding profile, summary, or view-builder expression. |
| 537 | `        3. Your Account: You are responsible for safeguarding your credentials and the practice data associated with your session.` | Implements the surrounding profile, summary, or view-builder expression. |
| 538 | `        4. Usage Rights: You are granted a personal, non-exclusive license to use Stamerlee for personal fluency exercises.` | Implements the surrounding profile, summary, or view-builder expression. |
| 539 | `        5. Contact & Support: For questions regarding these terms, contact us through our official support portal.` | Implements the surrounding profile, summary, or view-builder expression. |
| 540 | `        """` | Implements the surrounding profile, summary, or view-builder expression. |
| 541 | `        showLegalSheet = true` | Implements the surrounding profile, summary, or view-builder expression. |
| 542 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 543 | `` | Blank line separating code sections. |
| 544 | `    private func openPrivacyPolicy() {` | Defines a private helper for UI or notification behavior. |
| 545 | `        legalSheetTitle = "Privacy Policy"` | Implements the surrounding profile, summary, or view-builder expression. |
| 546 | `        legalSheetContent = """` | Implements the surrounding profile, summary, or view-builder expression. |
| 547 | `        Your privacy is paramount. Stamerlee is committed to protecting your personal information and speech data.` | Implements the surrounding profile, summary, or view-builder expression. |
| 548 | `` | Blank line separating code sections. |
| 549 | `        1. Audio & Camera Privacy: Voice recordings and camera previews used during practice are processed locally on your device for immediate pacing feedback and are not sold or transmitted to third parties.` | Implements the surrounding profile, summary, or view-builder expression. |
| 550 | `        2. Account Information: If you register with an email, it is used solely for authentication and session recovery.` | Implements the surrounding profile, summary, or view-builder expression. |
| 551 | `        3. Practice Analytics: Progress statistics (e.g. streak count, practice duration, selected sounds) are stored locally to help customize your training recommendations.` | Implements the surrounding profile, summary, or view-builder expression. |
| 552 | `        4. Data Deletion: You can permanently erase your account, speech data, and progress anytime directly from this Profile screen using the "Delete Account" button.` | Implements the surrounding profile, summary, or view-builder expression. |
| 553 | `        """` | Implements the surrounding profile, summary, or view-builder expression. |
| 554 | `        showLegalSheet = true` | Implements the surrounding profile, summary, or view-builder expression. |
| 555 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 556 | `` | Blank line separating code sections. |
| 557 | `    private func sectionTitle(_ title: String) -> some View {` | Defines a private helper for UI or notification behavior. |
| 558 | `        Text(title)` | Displays a text label. |
| 559 | `            .font(.system(size: 18, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 560 | `            .foregroundStyle(.white.opacity(0.9))` | Sets the foreground color or style. |
| 561 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 562 | `` | Blank line separating code sections. |
| 563 | `    private func stat(title: String, subtitle: String) -> some View {` | Defines a private helper for UI or notification behavior. |
| 564 | `        VStack(alignment: .leading, spacing: 2) {` | Opens or closes a Swift scope or view-builder block. |
| 565 | `            Text(title)` | Displays a text label. |
| 566 | `                .font(.system(size: 17, weight: .semibold, design: .rounded))` | Sets typography, size, weight, and design. |
| 567 | `                .foregroundStyle(StamerleeTheme.textPrimaryLight)` | Sets the foreground color or style. |
| 568 | `            Text(subtitle)` | Displays a text label. |
| 569 | `                .font(.system(size: 13, weight: .regular, design: .rounded))` | Sets typography, size, weight, and design. |
| 570 | `                .foregroundStyle(StamerleeTheme.textSecondaryLight)` | Sets the foreground color or style. |
| 571 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 572 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 573 | `}` | Opens or closes a Swift scope or view-builder block. |
| 574 | `` | Blank line separating code sections. |
| 575 | `// MARK: - Legal Document Viewer Sheet` | Section marker organizing the screen implementation. |
| 576 | `private struct LegalDocumentSheet: View {` | Declares a reusable SwiftUI view. |
| 577 | `    let title: String` | Declares immutable configuration or local data. |
| 578 | `    let content: String` | Declares immutable configuration or local data. |
| 579 | `    @Binding var isPresented: Bool` | Creates a two-way connection to state owned by another view. |
| 580 | `` | Blank line separating code sections. |
| 581 | `    var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 582 | `        NavigationStack {` | Opens or closes a Swift scope or view-builder block. |
| 583 | `            ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 584 | `                StamerleeTheme.backgroundDark.ignoresSafeArea()` | Implements the surrounding profile, summary, or view-builder expression. |
| 585 | `` | Blank line separating code sections. |
| 586 | `                ScrollView(showsIndicators: false) {` | Opens or closes a Swift scope or view-builder block. |
| 587 | `                    VStack(alignment: .leading, spacing: 14) {` | Opens or closes a Swift scope or view-builder block. |
| 588 | `                        Text(content)` | Displays a text label. |
| 589 | `                            .font(.system(size: 14, weight: .regular, design: .rounded))` | Sets typography, size, weight, and design. |
| 590 | `                            .lineSpacing(5)` | Applies a SwiftUI modifier to the preceding view. |
| 591 | `                            .foregroundStyle(Color.white.opacity(0.85))` | Sets the foreground color or style. |
| 592 | `                            .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 593 | `                            .padding(.top, 16)` | Adds layout spacing around the view. |
| 594 | `                            .padding(.bottom, 36)` | Adds layout spacing around the view. |
| 595 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 596 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 597 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 598 | `            .navigationTitle(title)` | Applies a SwiftUI modifier to the preceding view. |
| 599 | `            .navigationBarTitleDisplayMode(.inline)` | Applies a SwiftUI modifier to the preceding view. |
| 600 | `            .toolbarBackground(StamerleeTheme.backgroundDark, for: .navigationBar)` | Applies a SwiftUI modifier to the preceding view. |
| 601 | `            .toolbarColorScheme(.dark, for: .navigationBar)` | Applies a SwiftUI modifier to the preceding view. |
| 602 | `            .toolbar {` | Opens or closes a Swift scope or view-builder block. |
| 603 | `                ToolbarItem(placement: .topBarTrailing) {` | Opens or closes a Swift scope or view-builder block. |
| 604 | `                    Button {` | Creates an interactive button. |
| 605 | `                        isPresented = false` | Implements the surrounding profile, summary, or view-builder expression. |
| 606 | `                    } label: {` | Opens or closes a Swift scope or view-builder block. |
| 607 | `                        Image(systemName: "xmark.circle.fill")` | Displays an image asset or SF Symbol. |
| 608 | `                            .font(.system(size: 24))` | Sets typography, size, weight, and design. |
| 609 | `                            .symbolRenderingMode(.hierarchical)` | Applies a SwiftUI modifier to the preceding view. |
| 610 | `                            .foregroundStyle(Color.white.opacity(0.6))` | Sets the foreground color or style. |
| 611 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 612 | `                    .accessibilityLabel("Close")` | Applies a SwiftUI modifier to the preceding view. |
| 613 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 614 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 615 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 616 | `        .presentationBackground(StamerleeTheme.backgroundDark)` | Applies a SwiftUI modifier to the preceding view. |
| 617 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 618 | `}` | Opens or closes a Swift scope or view-builder block. |
| 619 | `` | Blank line separating code sections. |
| 620 | `private struct StreakSpark: View {` | Declares a reusable SwiftUI view. |
| 621 | `    var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 622 | `        ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 623 | `            Image(systemName: "sparkle")` | Displays an image asset or SF Symbol. |
| 624 | `                .font(.system(size: 42, weight: .bold))` | Sets typography, size, weight, and design. |
| 625 | `                .foregroundStyle(.yellow)` | Sets the foreground color or style. |
| 626 | `            Image(systemName: "sparkle")` | Displays an image asset or SF Symbol. |
| 627 | `                .font(.system(size: 12, weight: .bold))` | Sets typography, size, weight, and design. |
| 628 | `                .foregroundStyle(.yellow)` | Sets the foreground color or style. |
| 629 | `                .offset(x: 25, y: -22)` | Applies a SwiftUI modifier to the preceding view. |
| 630 | `            Image(systemName: "sparkle")` | Displays an image asset or SF Symbol. |
| 631 | `                .font(.system(size: 10, weight: .bold))` | Sets typography, size, weight, and design. |
| 632 | `                .foregroundStyle(.yellow)` | Sets the foreground color or style. |
| 633 | `                .offset(x: 27, y: 25)` | Applies a SwiftUI modifier to the preceding view. |
| 634 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 635 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 636 | `}` | Opens or closes a Swift scope or view-builder block. |

### `Stamerlee/SummaryView.swift` (357 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports the framework needed by this source file. |
| 2 | `import UIKit` | Imports the framework needed by this source file. |
| 3 | `` | Blank line separating code sections. |
| 4 | `// MARK: - Summary` | Section marker organizing the screen implementation. |
| 5 | `/// Progress overview shown in the Summary tab.` | Comment describing the purpose of the following code. |
| 6 | `public struct SummaryView: View {` | Declares a reusable SwiftUI view. |
| 7 | `    @Bindable public var state: AppState` | Connects the view to the observable AppState for two-way mutation. |
| 8 | `` | Blank line separating code sections. |
| 9 | `    private let rowBackground = Color.white.opacity(0.62)` | Declares immutable configuration or local data. |
| 10 | `    private let summaryBlue = StamerleeTheme.primaryBlue` | Declares immutable configuration or local data. |
| 11 | `    private let streakCardBackground = Color(red: 242 / 255, green: 243 / 255, blue: 252 / 255)` | Declares immutable configuration or local data. |
| 12 | `    private let streakAccent = Color(red: 139 / 255, green: 112 / 255, blue: 245 / 255)` | Declares immutable configuration or local data. |
| 13 | `    private let streakRing = Color(red: 205 / 255, green: 200 / 255, blue: 232 / 255)` | Declares immutable configuration or local data. |
| 14 | `    private let selectedDayBackground = Color(red: 228 / 255, green: 222 / 255, blue: 252 / 255)` | Declares immutable configuration or local data. |
| 15 | `` | Blank line separating code sections. |
| 16 | `    public init(state: AppState) {` | Initializes the view with shared state or configuration. |
| 17 | `        self.state = state` | Implements the surrounding profile, summary, or view-builder expression. |
| 18 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 19 | `` | Blank line separating code sections. |
| 20 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 21 | `        ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 22 | `            StamerleeTheme.backgroundDark.ignoresSafeArea()` | Implements the surrounding profile, summary, or view-builder expression. |
| 23 | `` | Blank line separating code sections. |
| 24 | `            ScrollView(showsIndicators: false) {` | Opens or closes a Swift scope or view-builder block. |
| 25 | `                VStack(alignment: .leading, spacing: 28) {` | Opens or closes a Swift scope or view-builder block. |
| 26 | `                    Text("Summary")` | Displays a text label. |
| 27 | `                        .font(.system(size: 32, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 28 | `                        .foregroundStyle(.white)` | Sets the foreground color or style. |
| 29 | `                        .padding(.top, 18)` | Adds layout spacing around the view. |
| 30 | `` | Blank line separating code sections. |
| 31 | `                    practiceStreakCard` | Implements the surrounding profile, summary, or view-builder expression. |
| 32 | `                    exerciseBlocksSection` | Implements the surrounding profile, summary, or view-builder expression. |
| 33 | `                    Spacer(minLength: 86)` | Implements the surrounding profile, summary, or view-builder expression. |
| 34 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 35 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 36 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 37 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 38 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 39 | `` | Blank line separating code sections. |
| 40 | `    private var practiceStreakCard: some View {` | Defines a computed helper view or value. |
| 41 | `        VStack(alignment: .leading, spacing: 16) {` | Opens or closes a Swift scope or view-builder block. |
| 42 | `            HStack(spacing: 12) {` | Opens or closes a Swift scope or view-builder block. |
| 43 | `                Image(systemName: "flame")` | Displays an image asset or SF Symbol. |
| 44 | `                    .font(.system(size: 22, weight: .semibold))` | Sets typography, size, weight, and design. |
| 45 | `                    .foregroundStyle(streakAccent)` | Sets the foreground color or style. |
| 46 | `                    .frame(width: 48, height: 48)` | Constrains the view size or alignment. |
| 47 | `                    .background(streakAccent.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))` | Adds a background behind the content. |
| 48 | `` | Blank line separating code sections. |
| 49 | `                VStack(alignment: .leading, spacing: 2) {` | Opens or closes a Swift scope or view-builder block. |
| 50 | `                    Text("Daily Practice")` | Displays a text label. |
| 51 | `                        .font(.system(size: 20, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 52 | `                        .foregroundStyle(Color(red: 20 / 255, green: 18 / 255, blue: 38 / 255))` | Sets the foreground color or style. |
| 53 | `                    Text("Streak: \(max(state.currentStreakDays, 0)) Days")` | Displays a text label. |
| 54 | `                        .font(.system(size: 15, weight: .medium, design: .rounded))` | Sets typography, size, weight, and design. |
| 55 | `                        .foregroundStyle(Color(red: 105 / 255, green: 98 / 255, blue: 142 / 255))` | Sets the foreground color or style. |
| 56 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 57 | `` | Blank line separating code sections. |
| 58 | `                Spacer()` | Implements the surrounding profile, summary, or view-builder expression. |
| 59 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 60 | `` | Blank line separating code sections. |
| 61 | `            HStack(spacing: 4) {` | Opens or closes a Swift scope or view-builder block. |
| 62 | `                ForEach(Array(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].enumerated()), id: \.offset) { index, day in` | Creates repeated SwiftUI views from a collection. |
| 63 | `                    let completedDays = min(max(state.currentStreakDays, 0), 7)` | Declares immutable configuration or local data. |
| 64 | `                  ` | Blank line separating code sections. |
| 65 | `                    let isCurrent = completedDays > 0 && index == completedDays - 1` | Declares immutable configuration or local data. |
| 66 | `` | Blank line separating code sections. |
| 67 | `                    VStack(spacing: 9) {` | Opens or closes a Swift scope or view-builder block. |
| 68 | `                        Text(day)` | Displays a text label. |
| 69 | `                            .font(.system(size: 14, weight: .semibold, design: .rounded))` | Sets typography, size, weight, and design. |
| 70 | `                            .foregroundStyle(Color(red: 35 / 255, green: 30 / 255, blue: 55 / 255))` | Sets the foreground color or style. |
| 71 | `` | Blank line separating code sections. |
| 72 | `                        if index < completedDays {` | Conditionally selects this behavior or view. |
| 73 | `                            ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 74 | `                                Circle()` | Implements the surrounding profile, summary, or view-builder expression. |
| 75 | `                                    .fill(streakAccent)` | Applies a SwiftUI modifier to the preceding view. |
| 76 | `                                    .frame(width: 28, height: 28)` | Constrains the view size or alignment. |
| 77 | `                                Image(systemName: "checkmark")` | Displays an image asset or SF Symbol. |
| 78 | `                                    .font(.system(size: 12, weight: .bold))` | Sets typography, size, weight, and design. |
| 79 | `                                    .foregroundStyle(.white)` | Sets the foreground color or style. |
| 80 | `                            }` | Opens or closes a Swift scope or view-builder block. |
| 81 | `                        } else {` | Opens or closes a Swift scope or view-builder block. |
| 82 | `                            Circle()` | Implements the surrounding profile, summary, or view-builder expression. |
| 83 | `                                .stroke(streakRing, lineWidth: 2)` | Applies a SwiftUI modifier to the preceding view. |
| 84 | `                                .frame(width: 28, height: 28)` | Constrains the view size or alignment. |
| 85 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 86 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 87 | `                    .frame(maxWidth: .infinity)` | Constrains the view size or alignment. |
| 88 | `                    .padding(.vertical, 8)` | Adds layout spacing around the view. |
| 89 | `                    .background(` | Adds a background behind the content. |
| 90 | `                        isCurrent ? selectedDayBackground : Color.clear,` | Implements the surrounding profile, summary, or view-builder expression. |
| 91 | `                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)` | Implements the surrounding profile, summary, or view-builder expression. |
| 92 | `                    )` | Implements the surrounding profile, summary, or view-builder expression. |
| 93 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 94 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 95 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 96 | `        .padding(.horizontal, 18)` | Adds layout spacing around the view. |
| 97 | `        .padding(.vertical, 18)` | Adds layout spacing around the view. |
| 98 | `        .background(` | Adds a background behind the content. |
| 99 | `            streakCardBackground,` | Implements the surrounding profile, summary, or view-builder expression. |
| 100 | `            in: RoundedRectangle(cornerRadius: 26, style: .continuous)` | Implements the surrounding profile, summary, or view-builder expression. |
| 101 | `        )` | Implements the surrounding profile, summary, or view-builder expression. |
| 102 | `        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)` | Adds visual depth with a shadow. |
| 103 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 104 | `` | Blank line separating code sections. |
| 105 | `    private struct ExerciseHighScoreItem: Identifiable {` | Declares a reusable SwiftUI view. |
| 106 | `        let id: String` | Declares immutable configuration or local data. |
| 107 | `        let title: String` | Declares immutable configuration or local data. |
| 108 | `        let displayTitle: String` | Declares immutable configuration or local data. |
| 109 | `        let iconName: String` | Declares immutable configuration or local data. |
| 110 | `        let score: Int` | Declares immutable configuration or local data. |
| 111 | `        let targetScreen: AppScreen` | Declares immutable configuration or local data. |
| 112 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 113 | `` | Blank line separating code sections. |
| 114 | `    private var exerciseHighScoreItems: [ExerciseHighScoreItem] {` | Defines a computed helper view or value. |
| 115 | `        [` | Implements the surrounding profile, summary, or view-builder expression. |
| 116 | `            ExerciseHighScoreItem(` | Implements the surrounding profile, summary, or view-builder expression. |
| 117 | `                id: "picture_desc",` | Implements the surrounding profile, summary, or view-builder expression. |
| 118 | `                title: "Picture Description",` | Implements the surrounding profile, summary, or view-builder expression. |
| 119 | `                displayTitle: "Picture\nDescription",` | Implements the surrounding profile, summary, or view-builder expression. |
| 120 | `                iconName: "IconPictureDesc",` | Implements the surrounding profile, summary, or view-builder expression. |
| 121 | `                score: 86,` | Implements the surrounding profile, summary, or view-builder expression. |
| 122 | `                targetScreen: state.hasSeenPictureDescriptionIntro ? .pictureDescriptionPractice : .pictureDescriptionIntro` | Implements the surrounding profile, summary, or view-builder expression. |
| 123 | `            ),` | Implements the surrounding profile, summary, or view-builder expression. |
| 124 | `            ExerciseHighScoreItem(` | Implements the surrounding profile, summary, or view-builder expression. |
| 125 | `                id: "prolonged_speech",` | Implements the surrounding profile, summary, or view-builder expression. |
| 126 | `                title: "Prolonged Speech",` | Implements the surrounding profile, summary, or view-builder expression. |
| 127 | `                displayTitle: "Prolonged\nSpeech",` | Implements the surrounding profile, summary, or view-builder expression. |
| 128 | `                iconName: "IconProlongedSpeech",` | Implements the surrounding profile, summary, or view-builder expression. |
| 129 | `                score: 92,` | Implements the surrounding profile, summary, or view-builder expression. |
| 130 | `                targetScreen: state.hasSeenProlongedSpeechIntro ? .prolongedSpeechDifficulty : .prolongedSpeechIntro` | Implements the surrounding profile, summary, or view-builder expression. |
| 131 | `            ),` | Implements the surrounding profile, summary, or view-builder expression. |
| 132 | `            ExerciseHighScoreItem(` | Implements the surrounding profile, summary, or view-builder expression. |
| 133 | `                id: "dial_scene",` | Implements the surrounding profile, summary, or view-builder expression. |
| 134 | `                title: "Dial Scene",` | Implements the surrounding profile, summary, or view-builder expression. |
| 135 | `                displayTitle: "Dial\nScene",` | Implements the surrounding profile, summary, or view-builder expression. |
| 136 | `                iconName: "IconDialScene",` | Implements the surrounding profile, summary, or view-builder expression. |
| 137 | `                score: 78,` | Implements the surrounding profile, summary, or view-builder expression. |
| 138 | `                targetScreen: state.hasSeenDialSceneIntro ? .dialScene : .dialSceneIntro` | Implements the surrounding profile, summary, or view-builder expression. |
| 139 | `            ),` | Implements the surrounding profile, summary, or view-builder expression. |
| 140 | `            ExerciseHighScoreItem(` | Implements the surrounding profile, summary, or view-builder expression. |
| 141 | `                id: "narration",` | Implements the surrounding profile, summary, or view-builder expression. |
| 142 | `                title: "Narration",` | Implements the surrounding profile, summary, or view-builder expression. |
| 143 | `                displayTitle: "Narration",` | Implements the surrounding profile, summary, or view-builder expression. |
| 144 | `                iconName: "IconMirrorNarration",` | Implements the surrounding profile, summary, or view-builder expression. |
| 145 | `                score: 89,` | Implements the surrounding profile, summary, or view-builder expression. |
| 146 | `                targetScreen: state.hasSeenNarrationIntro ? .narrationPractice : .narrationIntro` | Implements the surrounding profile, summary, or view-builder expression. |
| 147 | `            )` | Implements the surrounding profile, summary, or view-builder expression. |
| 148 | `        ]` | Implements the surrounding profile, summary, or view-builder expression. |
| 149 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 150 | `` | Blank line separating code sections. |
| 151 | `    private var exerciseBlocksSection: some View {` | Defines a computed helper view or value. |
| 152 | `        VStack(alignment: .leading, spacing: 14) {` | Opens or closes a Swift scope or view-builder block. |
| 153 | `            Text("Exercises")` | Displays a text label. |
| 154 | `                .font(.system(size: 22, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 155 | `                .foregroundStyle(.white)` | Sets the foreground color or style. |
| 156 | `` | Blank line separating code sections. |
| 157 | `            LazyVGrid(` | Lays out cards lazily in a vertical grid. |
| 158 | `                columns: [` | Implements the surrounding profile, summary, or view-builder expression. |
| 159 | `                    GridItem(.flexible(), spacing: 14),` | Implements the surrounding profile, summary, or view-builder expression. |
| 160 | `                    GridItem(.flexible(), spacing: 14)` | Implements the surrounding profile, summary, or view-builder expression. |
| 161 | `                ],` | Implements the surrounding profile, summary, or view-builder expression. |
| 162 | `                spacing: 14` | Implements the surrounding profile, summary, or view-builder expression. |
| 163 | `            ) {` | Opens or closes a Swift scope or view-builder block. |
| 164 | `                ForEach(exerciseHighScoreItems) { item in` | Creates repeated SwiftUI views from a collection. |
| 165 | `                    exerciseBlockCard(item: item)` | Implements the surrounding profile, summary, or view-builder expression. |
| 166 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 167 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 168 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 169 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 170 | `` | Blank line separating code sections. |
| 171 | `    private func exerciseBlockCard(item: ExerciseHighScoreItem) -> some View {` | Defines a private helper for UI or notification behavior. |
| 172 | `        Button {` | Creates an interactive button. |
| 173 | `            state.navigate(to: item.targetScreen)` | Implements the surrounding profile, summary, or view-builder expression. |
| 174 | `        } label: {` | Opens or closes a Swift scope or view-builder block. |
| 175 | `            VStack(alignment: .leading, spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 176 | `                // Top Row: 3D Icon on left, Title on right` | Comment describing the purpose of the following code. |
| 177 | `                HStack(alignment: .top) {` | Opens or closes a Swift scope or view-builder block. |
| 178 | `                    summaryAssetImage(named: item.iconName, size: 56)` | Implements the surrounding profile, summary, or view-builder expression. |
| 179 | `                    Spacer(minLength: 6)` | Implements the surrounding profile, summary, or view-builder expression. |
| 180 | `                    Text(item.displayTitle)` | Displays a text label. |
| 181 | `                        .font(.system(size: 14, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 182 | `                        .foregroundStyle(.black)` | Sets the foreground color or style. |
| 183 | `                        .multilineTextAlignment(.leading)` | Applies a SwiftUI modifier to the preceding view. |
| 184 | `                        .lineSpacing(-1)` | Applies a SwiftUI modifier to the preceding view. |
| 185 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 186 | `` | Blank line separating code sections. |
| 187 | `                Spacer(minLength: 16)` | Implements the surrounding profile, summary, or view-builder expression. |
| 188 | `` | Blank line separating code sections. |
| 189 | `                // Large Score / 100` | Comment describing the purpose of the following code. |
| 190 | `                HStack(alignment: .lastTextBaseline, spacing: 2) {` | Opens or closes a Swift scope or view-builder block. |
| 191 | `                    Text("\(item.score)")` | Displays a text label. |
| 192 | `                        .font(.system(size: 36, weight: .heavy, design: .rounded))` | Sets typography, size, weight, and design. |
| 193 | `                        .foregroundStyle(.black)` | Sets the foreground color or style. |
| 194 | `                    Text("/100")` | Displays a text label. |
| 195 | `                        .font(.system(size: 18, weight: .medium, design: .rounded))` | Sets typography, size, weight, and design. |
| 196 | `                        .foregroundStyle(Color(red: 130 / 255, green: 134 / 255, blue: 170 / 255))` | Sets the foreground color or style. |
| 197 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 198 | `` | Blank line separating code sections. |
| 199 | `                // Subtitle` | Comment describing the purpose of the following code. |
| 200 | `                Text("Smooth speech score")` | Displays a text label. |
| 201 | `                    .font(.system(size: 12, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 202 | `                    .foregroundStyle(.black)` | Sets the foreground color or style. |
| 203 | `                    .lineLimit(1)` | Applies a SwiftUI modifier to the preceding view. |
| 204 | `                    .minimumScaleFactor(0.8)` | Applies a SwiftUI modifier to the preceding view. |
| 205 | `                    .padding(.top, 4)` | Adds layout spacing around the view. |
| 206 | `                    .padding(.bottom, 12)` | Adds layout spacing around the view. |
| 207 | `` | Blank line separating code sections. |
| 208 | `                // Gradient Progress Bar` | Comment describing the purpose of the following code. |
| 209 | `                GeometryReader { geo in` | Reads layout geometry for avatar frame reporting. |
| 210 | `                    ZStack(alignment: .leading) {` | Opens or closes a Swift scope or view-builder block. |
| 211 | `                        Capsule()` | Implements the surrounding profile, summary, or view-builder expression. |
| 212 | `                            .fill(Color(red: 222 / 255, green: 224 / 255, blue: 242 / 255))` | Applies a SwiftUI modifier to the preceding view. |
| 213 | `                            .frame(height: 8)` | Constrains the view size or alignment. |
| 214 | `` | Blank line separating code sections. |
| 215 | `                        Capsule()` | Implements the surrounding profile, summary, or view-builder expression. |
| 216 | `                            .fill(` | Applies a SwiftUI modifier to the preceding view. |
| 217 | `                                LinearGradient(` | Implements the surrounding profile, summary, or view-builder expression. |
| 218 | `                                    colors: [` | Implements the surrounding profile, summary, or view-builder expression. |
| 219 | `                                        Color(red: 88 / 255, green: 44 / 255, blue: 204 / 255),` | Implements the surrounding profile, summary, or view-builder expression. |
| 220 | `                                        Color(red: 168 / 255, green: 110 / 255, blue: 255 / 255)` | Implements the surrounding profile, summary, or view-builder expression. |
| 221 | `                                    ],` | Implements the surrounding profile, summary, or view-builder expression. |
| 222 | `                                    startPoint: .leading,` | Implements the surrounding profile, summary, or view-builder expression. |
| 223 | `                                    endPoint: .trailing` | Implements the surrounding profile, summary, or view-builder expression. |
| 224 | `                                )` | Implements the surrounding profile, summary, or view-builder expression. |
| 225 | `                            )` | Implements the surrounding profile, summary, or view-builder expression. |
| 226 | `                            .frame(` | Constrains the view size or alignment. |
| 227 | `                                width: max(geo.size.width * CGFloat(item.score) / 100.0, 8),` | Implements the surrounding profile, summary, or view-builder expression. |
| 228 | `                                height: 8` | Implements the surrounding profile, summary, or view-builder expression. |
| 229 | `                            )` | Implements the surrounding profile, summary, or view-builder expression. |
| 230 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 231 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 232 | `                .frame(height: 8)` | Constrains the view size or alignment. |
| 233 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 234 | `            .padding(16)` | Adds layout spacing around the view. |
| 235 | `            .frame(maxWidth: .infinity, minHeight: 184, alignment: .topLeading)` | Constrains the view size or alignment. |
| 236 | `            .background(` | Adds a background behind the content. |
| 237 | `                Color(red: 242 / 255, green: 243 / 255, blue: 252 / 255),` | Implements the surrounding profile, summary, or view-builder expression. |
| 238 | `                in: RoundedRectangle(cornerRadius: 26, style: .continuous)` | Implements the surrounding profile, summary, or view-builder expression. |
| 239 | `            )` | Implements the surrounding profile, summary, or view-builder expression. |
| 240 | `            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)` | Adds visual depth with a shadow. |
| 241 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 242 | `        .buttonStyle(.haptic)` | Applies a SwiftUI modifier to the preceding view. |
| 243 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 244 | `` | Blank line separating code sections. |
| 245 | `    private func summaryAssetImage(named name: String, size: CGFloat = 52) -> some View {` | Defines a private helper for UI or notification behavior. |
| 246 | `        Image(name)` | Displays an image asset or SF Symbol. |
| 247 | `            .resizable()` | Applies a SwiftUI modifier to the preceding view. |
| 248 | `            .scaledToFit()` | Applies a SwiftUI modifier to the preceding view. |
| 249 | `            .frame(width: size, height: size)` | Constrains the view size or alignment. |
| 250 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 251 | `}` | Opens or closes a Swift scope or view-builder block. |
| 252 | `` | Blank line separating code sections. |
| 253 | `private struct PracticeCalendarSheet: View {` | Declares a reusable SwiftUI view. |
| 254 | `    let streakDays: Int` | Declares immutable configuration or local data. |
| 255 | `    @State private var selectedDate = Date()` | Stores view-local state managed by SwiftUI. |
| 256 | `` | Blank line separating code sections. |
| 257 | `    var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 258 | `        VStack(alignment: .leading, spacing: 18) {` | Opens or closes a Swift scope or view-builder block. |
| 259 | `            HStack {` | Opens or closes a Swift scope or view-builder block. |
| 260 | `                VStack(alignment: .leading, spacing: 4) {` | Opens or closes a Swift scope or view-builder block. |
| 261 | `                    Text("Practice calendar")` | Displays a text label. |
| 262 | `                        .font(.system(size: 24, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 263 | `                        .foregroundStyle(.black)` | Sets the foreground color or style. |
| 264 | `                    Text("Your practice days are marked below")` | Displays a text label. |
| 265 | `                        .font(.system(size: 13, weight: .medium, design: .rounded))` | Sets typography, size, weight, and design. |
| 266 | `                        .foregroundStyle(.black.opacity(0.55))` | Sets the foreground color or style. |
| 267 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 268 | `                Spacer()` | Implements the surrounding profile, summary, or view-builder expression. |
| 269 | `                Image(systemName: "calendar")` | Displays an image asset or SF Symbol. |
| 270 | `                    .font(.system(size: 18, weight: .semibold))` | Sets typography, size, weight, and design. |
| 271 | `                    .foregroundStyle(.black.opacity(0.65))` | Sets the foreground color or style. |
| 272 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 273 | `` | Blank line separating code sections. |
| 274 | `            NativePracticeCalendar(streakDays: streakDays, selectedDate: $selectedDate)` | Implements the surrounding profile, summary, or view-builder expression. |
| 275 | `                .frame(height: 300)` | Constrains the view size or alignment. |
| 276 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 277 | `        .padding(.horizontal, 20)` | Adds layout spacing around the view. |
| 278 | `        .padding(.top, 22)` | Adds layout spacing around the view. |
| 279 | `        .padding(.bottom, 18)` | Adds layout spacing around the view. |
| 280 | `        .frame(maxWidth: .infinity, alignment: .leading)` | Constrains the view size or alignment. |
| 281 | `        .background(Color.white)` | Adds a background behind the content. |
| 282 | `        .presentationBackground(Color.white)` | Applies a SwiftUI modifier to the preceding view. |
| 283 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 284 | `` | Blank line separating code sections. |
| 285 | `}` | Opens or closes a Swift scope or view-builder block. |
| 286 | `` | Blank line separating code sections. |
| 287 | `private struct NativePracticeCalendar: UIViewRepresentable {` | Declares a reusable SwiftUI view. |
| 288 | `    let streakDays: Int` | Declares immutable configuration or local data. |
| 289 | `    @Binding var selectedDate: Date` | Creates a two-way connection to state owned by another view. |
| 290 | `` | Blank line separating code sections. |
| 291 | `    func makeCoordinator() -> Coordinator {` | Opens or closes a Swift scope or view-builder block. |
| 292 | `        Coordinator(streakDays: streakDays, selectedDate: $selectedDate)` | Implements the surrounding profile, summary, or view-builder expression. |
| 293 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 294 | `` | Blank line separating code sections. |
| 295 | `    func makeUIView(context: Context) -> UICalendarView {` | Opens or closes a Swift scope or view-builder block. |
| 296 | `        let calendarView = UICalendarView()` | Declares immutable configuration or local data. |
| 297 | `        calendarView.calendar = Calendar.current` | Implements the surrounding profile, summary, or view-builder expression. |
| 298 | `        calendarView.locale = Locale.current` | Implements the surrounding profile, summary, or view-builder expression. |
| 299 | `        calendarView.fontDesign = .rounded` | Implements the surrounding profile, summary, or view-builder expression. |
| 300 | `        calendarView.wantsDateDecorations = true` | Implements the surrounding profile, summary, or view-builder expression. |
| 301 | `        calendarView.delegate = context.coordinator` | Implements the surrounding profile, summary, or view-builder expression. |
| 302 | `        calendarView.overrideUserInterfaceStyle = .light` | Implements the surrounding profile, summary, or view-builder expression. |
| 303 | `        calendarView.backgroundColor = .clear` | Implements the surrounding profile, summary, or view-builder expression. |
| 304 | `        return calendarView` | Returns the computed value or view. |
| 305 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 306 | `` | Blank line separating code sections. |
| 307 | `    func updateUIView(_ calendarView: UICalendarView, context: Context) {` | Opens or closes a Swift scope or view-builder block. |
| 308 | `        context.coordinator.streakDays = streakDays` | Implements the surrounding profile, summary, or view-builder expression. |
| 309 | `        calendarView.reloadDecorations(forDateComponents: context.coordinator.practiceDateComponents(), animated: true)` | Implements the surrounding profile, summary, or view-builder expression. |
| 310 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 311 | `` | Blank line separating code sections. |
| 312 | `    final class Coordinator: NSObject, UICalendarViewDelegate {` | Opens or closes a Swift scope or view-builder block. |
| 313 | `        var streakDays: Int` | Declares a computed or mutable value. |
| 314 | `        var selectedDate: Binding<Date>` | Declares a computed or mutable value. |
| 315 | `` | Blank line separating code sections. |
| 316 | `        init(streakDays: Int, selectedDate: Binding<Date>) {` | Initializes the view with shared state or configuration. |
| 317 | `            self.streakDays = streakDays` | Implements the surrounding profile, summary, or view-builder expression. |
| 318 | `            self.selectedDate = selectedDate` | Implements the surrounding profile, summary, or view-builder expression. |
| 319 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 320 | `` | Blank line separating code sections. |
| 321 | `        func calendarView(` | Implements the surrounding profile, summary, or view-builder expression. |
| 322 | `            _ calendarView: UICalendarView,` | Implements the surrounding profile, summary, or view-builder expression. |
| 323 | `            decorationFor dateComponents: DateComponents` | Implements the surrounding profile, summary, or view-builder expression. |
| 324 | `        ) -> UICalendarView.Decoration? {` | Opens or closes a Swift scope or view-builder block. |
| 325 | `            guard let date = calendarView.calendar.date(from: dateComponents),` | Requires a condition and exits early when it fails. |
| 326 | `                  isPracticeDay(date, calendar: calendarView.calendar) else {` | Opens or closes a Swift scope or view-builder block. |
| 327 | `                return nil` | Returns the computed value or view. |
| 328 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 329 | `` | Blank line separating code sections. |
| 330 | `            return .image(` | Returns the computed value or view. |
| 331 | `                UIImage(systemName: "checkmark.circle.fill"),` | Implements the surrounding profile, summary, or view-builder expression. |
| 332 | `                color: .systemGreen,` | Implements the surrounding profile, summary, or view-builder expression. |
| 333 | `                size: .medium` | Implements the surrounding profile, summary, or view-builder expression. |
| 334 | `            )` | Implements the surrounding profile, summary, or view-builder expression. |
| 335 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 336 | `` | Blank line separating code sections. |
| 337 | `        func practiceDateComponents() -> [DateComponents] {` | Opens or closes a Swift scope or view-builder block. |
| 338 | `            let calendar = Calendar.current` | Declares immutable configuration or local data. |
| 339 | `            return (0..<max(streakDays, 0)).compactMap { offset in` | Returns the computed value or view. |
| 340 | `                guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else {` | Requires a condition and exits early when it fails. |
| 341 | `                    return nil` | Returns the computed value or view. |
| 342 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 343 | `                return calendar.dateComponents([.year, .month, .day], from: date)` | Returns the computed value or view. |
| 344 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 345 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 346 | `` | Blank line separating code sections. |
| 347 | `        private func isPracticeDay(_ date: Date, calendar: Calendar) -> Bool {` | Defines a private helper for UI or notification behavior. |
| 348 | `            let today = calendar.startOfDay(for: Date())` | Declares immutable configuration or local data. |
| 349 | `            let dayOffset = calendar.dateComponents(` | Declares immutable configuration or local data. |
| 350 | `                [.day],` | Implements the surrounding profile, summary, or view-builder expression. |
| 351 | `                from: calendar.startOfDay(for: date),` | Implements the surrounding profile, summary, or view-builder expression. |
| 352 | `                to: today` | Implements the surrounding profile, summary, or view-builder expression. |
| 353 | `            ).day ?? Int.max` | Implements the surrounding profile, summary, or view-builder expression. |
| 354 | `            return dayOffset >= 0 && dayOffset < max(streakDays, 0)` | Returns the computed value or view. |
| 355 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 356 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 357 | `}` | Opens or closes a Swift scope or view-builder block. |

## Recommendations

- Bind summary card scores to recorded exercise results in `AppState`.
- Surface camera/photo and notification permission failures with actionable messages.
- Replace repeated RGB literals with named `StamerleeTheme` tokens.
- Prefer typed exercise identifiers over string IDs and raw target-screen decisions when the summary grows.
