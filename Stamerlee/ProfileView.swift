import SwiftUI
import PhotosUI
import UIKit
import UserNotifications

private struct ProfileAvatarFrameReportingModifier: ViewModifier {
    let slot: ProfileAvatarSlot
    @Environment(\.profileAvatarFrameReporter) private var report

    func body(content: Content) -> some View {
        content.background {
            GeometryReader { proxy in
                Color.clear
                    .onGeometryChange(for: CGRect.self) {
                        $0.frame(in: .global)
                    } action: { frame in
                        report?(slot, frame)
                    }
            }
        }
    }
}

extension View {
    func reportProfileAvatarFrame(_ slot: ProfileAvatarSlot) -> some View {
        modifier(ProfileAvatarFrameReportingModifier(slot: slot))
    }

    func dropIn(_ shown: Bool, index: Int) -> some View {
        offset(y: shown ? 0 : 20)
            .opacity(shown ? 1 : 0)
            .animation(
                .spring(response: 0.48, dampingFraction: 0.84)
                    .delay(Double(index) * 0.06),
                value: shown
            )
    }
}

// MARK: - Profile
/// Personal progress and settings screen presented from the dashboard's Profile tab.
public struct ProfileView: View {
    @Bindable public var state: AppState
    @State private var isEditingName = false
    @State private var tempName = ""
    @FocusState private var isNameFieldFocused: Bool
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var didAppearContent = false

    // Alerts and sheets
    @State private var showLogoutConfirmation = false
    @State private var showDeleteConfirmation = false
    @State private var showLegalSheet = false
    @State private var legalSheetTitle = "Terms of Service"
    @State private var legalSheetContent = ""
    @State private var reminderSuccessTrigger = 0
    @State private var showNotAttemptedAlert = false
    @State private var notAttemptedAlertTitle = "Exercise Not Attempted"
    @State private var notAttemptedAlertMessage = "This exercise has not been attempted yet."

    public init(state: AppState) {
        self.state = state
    }

    private var formattedReminderTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: state.reminderTime)
    }

    public var body: some View {
        ZStack(alignment: .top) {
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()

            headerImageView
                .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(spacing: 0) {
                    profileHeader

                    VStack(alignment: .leading, spacing: 22) {
                        statsSection
                            .dropIn(didAppearContent, index: 0)

                        reminderCard
                            .dropIn(didAppearContent, index: 1)

                        accountSection
                            .dropIn(didAppearContent, index: 2)

                        legalHypertextSection
                            .dropIn(didAppearContent, index: 3)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 22)
                    .padding(.bottom, 36)
                }
            }
            .scrollIndicators(.hidden)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.spring(response: 0.48, dampingFraction: 0.84)) {
                didAppearContent = true
            }
        }
        .alert(notAttemptedAlertTitle, isPresented: $showNotAttemptedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(notAttemptedAlertMessage)
        }
        .alert("Log Out", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) {
                state.logout()
            }
        } message: {
            Text("Are you sure you want to log out of your account?")
        }
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete Account", role: .destructive) {
                state.deleteAccount()
            }
        } message: {
            Text("This action is permanent and will remove your practice streak, exercise progress, and personal settings.")
        }
        .sheet(isPresented: $showLegalSheet) {
            LegalDocumentSheet(
                title: legalSheetTitle,
                content: legalSheetContent,
                isPresented: $showLegalSheet
            )
        }
        .sensoryFeedback(.success, trigger: reminderSuccessTrigger)
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        ZStack(alignment: .topTrailing) {
            Color.clear
                .frame(height: 184)

            // Top Bar: Back Chevron (left) and Single Edit Pen (right)
            HStack {
                BackNavButton {
                    if isEditingName {
                        commitName()
                    }
                    state.navigate(to: .homeDashboard, forward: false)
                }

                Spacer()

                Button {
                    if isEditingName {
                        commitName()
                    } else {
                        tempName = state.profileName
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) {
                            isEditingName = true
                        }
                        isNameFieldFocused = true
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.14))
                            .frame(width: 38, height: 38)

                        Image(systemName: isEditingName ? "checkmark" : "pencil")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isEditingName ? "Save name" : "Edit profile")
            }
            .padding(.top, 18)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .top)
            .zIndex(2)

            VStack(spacing: 12) {
                // Profile Avatar with PhotosPicker (tap to change photo)
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    ProfileAvatar(
                        style: state.profileAvatarStyle,
                        imageData: state.profileAvatarData,
                        size: 84
                    )
                    .opacity(state.isHeroAvatarTransitionActive ? 0 : 1)
                    .reportProfileAvatarFrame(.profile)
                }
                .buttonStyle(AvatarInteractiveButtonStyle())
                .accessibilityLabel("Change profile photo")
                .contextMenu {
                    if state.profileAvatarData != nil {
                        Button(role: .destructive) {
                            withAnimation {
                                state.profileAvatarData = nil
                            }
                        } label: {
                            Label("Remove Photo", systemImage: "trash")
                        }
                    }
                }

                // Name section with inline editing
                Group {
                    if isEditingName {
                        HStack(spacing: 8) {
                            TextField("Enter name", text: $tempName)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
                                .focused($isNameFieldFocused)
                                .submitLabel(.done)
                                .onSubmit {
                                    commitName()
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.white.opacity(0.12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .stroke(StamerleeTheme.primaryBlue.opacity(0.7), lineWidth: 1.5)
                                        )
                                )
                                .frame(maxWidth: 220)

                            Button {
                                commitName()
                            } label: {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 155 / 255, green: 125 / 255, blue: 255 / 255),
                                                StamerleeTheme.primaryBlueDark
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(Circle())
                                    .shadow(color: StamerleeTheme.primaryBlue.opacity(0.4), radius: 4, x: 0, y: 2)
                            }
                            .accessibilityLabel("Save name")
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    } else {
                        Button {
                            tempName = state.profileName
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) {
                                isEditingName = true
                            }
                            isNameFieldFocused = true
                        } label: {
                            Text(state.profileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Your Name" : state.profileName)
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundStyle(StamerleeTheme.textPrimaryDark)
                                .minimumScaleFactor(0.8)
                                .lineLimit(1)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Edit name")
                    }

                    Text("Joined in October 2026")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textSecondaryDark)
                }
                .offset(y: didAppearContent ? 0 : 8)
                .opacity(didAppearContent ? 1 : 0)
                .animation(
                    .spring(response: 0.44, dampingFraction: 0.84).delay(0.08),
                    value: didAppearContent
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
        }
        .task(id: selectedPhoto) {
            guard let selectedPhoto else { return }
            guard let data = try? await selectedPhoto.loadTransferable(type: Data.self) else { return }
            if let uiImage = UIImage(data: data), let compressed = uiImage.jpegData(compressionQuality: 0.85) {
                state.profileAvatarData = compressed
            } else {
                state.profileAvatarData = data
            }
            state.profileAvatarStyle = 0
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    private var headerImageView: some View {
        Group {
            if let uiImage = UIImage(named: "profile") ?? UIImage(named: "ProfileHeader") ?? UIImage(contentsOfFile: Bundle.main.path(forResource: "profile", ofType: "png") ?? "") {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
            } else {
                Image("profile")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .clipped()
        .overlay(
            LinearGradient(
                colors: [
                    Color.clear,
                    Color(red: 10 / 255, green: 13 / 255, blue: 31 / 255).opacity(0.15),
                    Color(red: 10 / 255, green: 13 / 255, blue: 31 / 255).opacity(0.7),
                    Color(red: 10 / 255, green: 13 / 255, blue: 31 / 255)
                ],
                startPoint: .init(x: 0.5, y: 0.55),
                endPoint: .bottom
            )
        )
    }

    private func commitName() {
        let trimmed = tempName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            state.profileName = trimmed
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) {
            isEditingName = false
            isNameFieldFocused = false
        }
    }

    // MARK: - Practice Reminder Card
    private var reminderCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(StamerleeTheme.primaryBlue)

                    Text("Practice Reminder")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textPrimaryLight)
                }

                Spacer()

                Toggle("", isOn: $state.reminderEnabled)
                    .labelsHidden()
                    .tint(StamerleeTheme.primaryBlue)
                    .onChange(of: state.reminderEnabled) { _, isEnabled in
                        if isEnabled {
                            requestAndScheduleReminder(at: state.reminderTime)
                        } else {
                            cancelReminders()
                        }
                    }
            }

            Text("Choose what time we should send a notification to remind you to practice.")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(StamerleeTheme.textSecondaryLight)

            if state.reminderEnabled {
                HStack {
                    Text("Reminder Time")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textPrimaryLight)

                    Spacer()

                    DatePicker(
                        "",
                        selection: $state.reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .tint(StamerleeTheme.primaryBlue)
                    .onChange(of: state.reminderTime) { _, newTime in
                        requestAndScheduleReminder(at: newTime)
                    }
                }
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(Color.white.opacity(0.85))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.green)
                    Text("Reminder set for \(formattedReminderTime) daily")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textSecondaryLight)
                }
                .padding(.top, 2)
            }
        }
        .padding(18)
        .background(StamerleeTheme.profileCard)
        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
    }

    // MARK: - Account Section (Log Out & Delete Account Buttons)
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Account")

            VStack(spacing: 12) {
                // Log Out Button
                Button {
                    showLogoutConfirmation = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 15, weight: .bold))
                        Text("Log Out")
                            .font(.system(size: 15.5, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(StamerleeTheme.textPrimaryLight)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(StamerleeTheme.profileCard)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.haptic)

                // Delete Account Button
                Button {
                    showDeleteConfirmation = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "trash")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Delete Account")
                            .font(.system(size: 15.5, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(Color(red: 235 / 255, green: 70 / 255, blue: 70 / 255))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.red.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.red.opacity(0.24), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.haptic)
            }
        }
    }

    // MARK: - Legal Hypertext Section
    private var legalHypertextSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Button {
                    openTerms()
                } label: {
                    Text("Terms of Service")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .underline()
                        .foregroundStyle(StamerleeTheme.primaryBlue)
                }

                Text("•")
                    .font(.system(size: 12))
                    .foregroundStyle(StamerleeTheme.textSecondaryDark)

                Button {
                    openPrivacyPolicy()
                } label: {
                    Text("Privacy Policy")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .underline()
                        .foregroundStyle(StamerleeTheme.primaryBlue)
                }
            }
            .padding(.top, 8)

            Text("Stamerlee v1.0.0 • All rights reserved")
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .foregroundStyle(StamerleeTheme.textSecondaryDark)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 4)
        .padding(.bottom, 16)
    }

    // MARK: - Notification Helpers
    private func requestAndScheduleReminder(at time: Date) {
        let center = UNUserNotificationCenter.current()
        Task { @MainActor in
            let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
            if granted {
                scheduleNotification(at: time)
            } else {
                state.reminderEnabled = false
            }
        }
    }

    private func scheduleNotification(at time: Date) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = "Time for your speech practice! 🎯"
        content.body = "A quick 5-10 minute session with Beat Buddy helps keep your speech steady and confident."
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_practice_reminder", content: content, trigger: trigger)
        center.add(request)

        reminderSuccessTrigger += 1
    }

    private func cancelReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private func openTerms() {
        legalSheetTitle = "Terms of Service"
        legalSheetContent = """
        Welcome to Stamerlee. By using our application, you agree to these Terms of Service.

        1. Scope of Service: Stamerlee provides speech pacing, fluency exercises, and auditory feedback tools designed for personal fluency training and practice.
        2. Personal Practice: Stamerlee is an educational and supportive tool. It does not replace clinical medical diagnosis or direct guidance from certified speech-language pathologists.
        3. Your Account: You are responsible for safeguarding your credentials and the practice data associated with your session.
        4. Usage Rights: You are granted a personal, non-exclusive license to use Stamerlee for personal fluency exercises.
        5. Contact & Support: For questions regarding these terms, contact us through our official support portal.
        """
        showLegalSheet = true
    }

    private func openPrivacyPolicy() {
        legalSheetTitle = "Privacy Policy"
        legalSheetContent = """
        Your privacy is paramount. Stamerlee is committed to protecting your personal information and speech data.

        1. Audio & Camera Privacy: Voice recordings and camera previews used during practice are processed locally on your device for immediate pacing feedback and are not sold or transmitted to third parties.
        2. Account Information: If you register with an email, it is used solely for authentication and session recovery.
        3. Practice Analytics: Progress statistics (e.g. streak count, practice duration, selected sounds) are stored locally to help customize your training recommendations.
        4. Data Deletion: You can permanently erase your account, speech data, and progress anytime directly from this Profile screen using the "Delete Account" button.
        """
        showLegalSheet = true
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundStyle(.white.opacity(0.9))
    }

    // MARK: - Stats Section (Smooth Speech Score)
    private struct ExerciseHighScoreItem: Identifiable {
        let type: ExerciseDetailType
        let displayTitle: String
        let score: Double

        var id: String { type.id }
        var title: String { type.title }
        var iconName: String { type.iconName }
    }

    private var exerciseHighScoreItems: [ExerciseHighScoreItem] {
        [
            ExerciseHighScoreItem(
                type: .prolongedSpeech,
                displayTitle: "Prolonged\nSpeech",
                score: state.prolongedEasyScore ?? 7.9
            ),
            ExerciseHighScoreItem(
                type: .pictureDescription,
                displayTitle: "Picture\nDescription",
                score: 8.8
            ),
            ExerciseHighScoreItem(
                type: .dialScene,
                displayTitle: "Dial\nScene",
                score: 6.3
            ),
            ExerciseHighScoreItem(
                type: .narration,
                displayTitle: "Narration",
                score: 7.2
            )
        ]
    }

    private func isExercisePerformed(_ type: ExerciseDetailType) -> Bool {
        switch type {
        case .prolongedSpeech:
            return true
        case .pictureDescription:
            return state.hasCompletedPictureDescription || !state.completedPictureDescriptionDifficulties.isEmpty || state.hasAttemptedPictureDescription
        case .dialScene:
            return state.hasCompletedDialScene || state.hasAttemptedDialScene
        case .narration:
            return !state.completedNarrationDifficulties.isEmpty
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Summary")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Based on your last attempt, here's your score for words spoken without stuttering.")
                    .font(.system(size: 13.5, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(red: 195 / 255, green: 190 / 255, blue: 220 / 255))
                    .fixedSize(horizontal: false, vertical: true)
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 14),
                    GridItem(.flexible(), spacing: 14)
                ],
                spacing: 14
            ) {
                ForEach(exerciseHighScoreItems) { item in
                    let isPerformed = isExercisePerformed(item.type)
                    Button {
                        if !isPerformed {
                            notAttemptedAlertTitle = item.title
                            notAttemptedAlertMessage = "This exercise has not been attempted yet."
                            showNotAttemptedAlert = true
                        } else {
                            state.selectedExerciseDetail = item.type
                            state.navigate(to: .exerciseProgressDetail)
                        }
                    } label: {
                        exerciseBlockCard(item: item, isPerformed: isPerformed)
                    }
                    .buttonStyle(PopSpringButtonStyle(pressedScale: 0.94))
                    .accessibilityLabel("\(item.title) card, score \(isPerformed ? String(format: "%.1f", item.score) : "not performed") of 10")
                }
            }
        }
    }

    private func exerciseBlockCard(item: ExerciseHighScoreItem, isPerformed: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top Row: 3D Icon on left, Title on right
            HStack(alignment: .center, spacing: 8) {
                summaryAssetImage(named: item.iconName, size: 48)

                Text(item.displayTitle)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 22 / 255, green: 18 / 255, blue: 40 / 255))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 48)

            Spacer(minLength: 8)

            // Large Score / 10 (or hyphen when not performed yet)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                if isPerformed {
                    Text(String(format: "%.1f", item.score))
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 22 / 255, green: 18 / 255, blue: 40 / 255))
                    Text("/10")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 125 / 255, green: 110 / 255, blue: 180 / 255))
                } else {
                    Text("—")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 120 / 255, green: 115 / 255, blue: 140 / 255))
                    Text("/10")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 160 / 255, green: 155 / 255, blue: 180 / 255))
                }
            }

            // Gradient Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(red: 222 / 255, green: 224 / 255, blue: 242 / 255))
                        .frame(height: 8)

                    if isPerformed {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 88 / 255, green: 44 / 255, blue: 204 / 255),
                                        Color(red: 168 / 255, green: 110 / 255, blue: 255 / 255)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: max(geo.size.width * CGFloat(item.score) / 10.0, 8),
                                height: 8
                            )
                    }
                }
            }
            .frame(height: 8)
            .padding(.top, 4)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 138, alignment: .topLeading)
        .background(
            Color(red: 246 / 255, green: 247 / 255, blue: 254 / 255).opacity(0.92),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color.white.opacity(0.35)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
    }

    private func summaryAssetImage(named name: String, size: CGFloat = 48) -> some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}

// MARK: - Legal Document Viewer Sheet
private struct LegalDocumentSheet: View {
    let title: String
    let content: String
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            StamerleeTheme.backgroundDark.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Header with perfectly centered title and single clean circular cross button
                HStack {
                    // Balance spacer on left matching the close button width
                    Color.clear
                        .frame(width: 30, height: 30)

                    Spacer()

                    Text(title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Spacer()

                    Button {
                        isPresented = false
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(red: 48 / 255, green: 50 / 255, blue: 68 / 255))
                            Circle()
                                .stroke(Color.white.opacity(0.24), lineWidth: 1)
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .frame(width: 30, height: 30)
                        .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close")
                }
                .padding(.horizontal, 20)
                .padding(.top, 22)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(content)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .lineSpacing(5)
                            .foregroundStyle(Color.white.opacity(0.85))
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                            .padding(.bottom, 36)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .presentationBackground(StamerleeTheme.backgroundDark)
    }
}
