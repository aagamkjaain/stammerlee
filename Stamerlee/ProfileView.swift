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
        offset(y: shown ? 0 : -48)
            .opacity(shown ? 1 : 0)
            .animation(
                .spring(response: 0.52, dampingFraction: 0.84)
                    .delay(Double(index) * 0.09),
                value: shown
            )
    }
}

// MARK: - Profile
/// Personal progress and settings screen presented from the dashboard's Profile tab.
public struct ProfileView: View {
    @Bindable public var state: AppState
    @Environment(\.profileAvatarFrameReporter) private var reportAvatarFrame
    @State private var isEditingProfile = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var didAppearContent = false

    // Alerts and sheets
    @State private var showLogoutConfirmation = false
    @State private var showDeleteConfirmation = false
    @State private var showLegalSheet = false
    @State private var legalSheetTitle = "Terms of Service"
    @State private var legalSheetContent = ""
    @State private var reminderSuccessTrigger = 0

    public init(state: AppState) {
        self.state = state
    }

    private var formattedReminderTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: state.reminderTime)
    }

    public var body: some View {
        ZStack {
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    profileHeader

                    VStack(alignment: .leading, spacing: 22) {
//                        statsSection

                        dailyGoalCard
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
            StamerleeTheme.profileHeaderBase
                .frame(height: 184)

            BackNavButton {
                state.navigate(to: .homeDashboard, forward: false)
            }
            .padding(.top, 18)
            .padding(.leading, 20)
            .frame(maxWidth: .infinity, alignment: .topLeading)

            VStack(spacing: 9) {
                ProfileAvatar(
                    style: state.profileAvatarStyle,
                    imageData: state.profileAvatarData,
                    size: 84
                )
                .opacity(state.isHeroAvatarTransitionActive ? 0 : 1)
                .reportProfileAvatarFrame(.profile)

                if isEditingProfile {
                    avatarStylePicker
                }

                Group {
                    if isEditingProfile {
                        TextField("Username", text: $state.profileName)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(StamerleeTheme.textPrimaryLight)
                            .multilineTextAlignment(.center)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .padding(.horizontal, 14)
                            .frame(height: 38)
                            .background(StamerleeTheme.profileCard)
                            .clipShape(Capsule())
                            .padding(.horizontal, 48)
                    } else {
                        Text(state.profileName)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(StamerleeTheme.textPrimaryDark)
                            .minimumScaleFactor(0.8)
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
            .padding(.top, 44)
        }
        .task(id: selectedPhoto) {
            guard let selectedPhoto else { return }
            guard let data = try? await selectedPhoto.loadTransferable(type: Data.self) else { return }
            state.profileAvatarData = data
            state.profileAvatarStyle = 0
        }
    }

    private var avatarStylePicker: some View {
        HStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { style in
                Button {
                    state.profileAvatarData = nil
                    state.profileAvatarStyle = style
                } label: {
                    ProfileAvatar(style: style, imageData: nil)
                        .scaleEffect(0.42)
                        .frame(width: 42, height: 42)
                        .background(
                            Circle()
                                .stroke(
                                    state.profileAvatarStyle == style
                                        ? StamerleeTheme.primaryBlue
                                        : Color.clear,
                                    lineWidth: 3
                                )
                        )
                }
                .accessibilityLabel("Avatar style \(style + 1)")
            }

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Image(systemName: "photo")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(StamerleeTheme.textPrimaryLight)
                    .frame(width: 42, height: 42)
                    .background(StamerleeTheme.profileCard)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                state.profileAvatarData != nil
                                    ? StamerleeTheme.primaryBlue
                                    : Color.clear,
                                lineWidth: 3
                            )
                    )
            }
            .accessibilityLabel("Choose avatar photo")
        }
        .frame(height: 42)
    }

//    // MARK: - Stats Section
//    private var statsSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack {
//                sectionTitle("Stats")
//
//                Spacer()
//
//                Button {
//                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
//                        isEditingProfile.toggle()
//                    }
//                } label: {
//                    HStack(spacing: 5) {
//                        Image(systemName: isEditingProfile ? "checkmark" : "pencil")
//                            .font(.system(size: 11, weight: .bold))
//                        Text(isEditingProfile ? "Done" : "Edit")
//                            .font(.system(size: 13, weight: .bold, design: .rounded))
//                    }
//                    .foregroundStyle(isEditingProfile ? Color.white : StamerleeTheme.primaryBlue)
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 6)
//                    .background(
//                        isEditingProfile
//                            ? StamerleeTheme.primaryBlue
//                            : StamerleeTheme.profileCard,
//                        in: Capsule()
//                    )
//                }
//                .buttonStyle(.plain)
//                .accessibilityLabel(isEditingProfile ? "Done editing profile" : "Edit name and avatar")
//            }
//
//            VStack(alignment: .leading, spacing: 15) {
//                stat(title: "8 minutes", subtitle: "Average session length")
//                stat(title: "2 sessions", subtitle: "Sessions completed")
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 16)
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .background(StamerleeTheme.profileCard)
//            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
//        }
//    }

    // MARK: - Daily Goal Card
    private var dailyGoalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily goal")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(StamerleeTheme.textPrimaryLight)

            Picker("Daily practice time", selection: $state.dailyPracticeMinutes) {
                ForEach([5, 10, 15, 20], id: \.self) { minutes in
                    Text("\(minutes) minutes")
                        .tag(minutes)
                }
            }
            .pickerStyle(.menu)
            .tint(StamerleeTheme.textSecondaryLight)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(Color.white.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(StamerleeTheme.profileCard)
        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
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

    // MARK: - Account Section (Log Out & Delete Account)
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Account")

            VStack(spacing: 0) {
                // Log Out Row
                Button {
                    showLogoutConfirmation = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(StamerleeTheme.textPrimaryLight)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Log Out")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(StamerleeTheme.textPrimaryLight)
                            Text(state.userEmail.isEmpty ? "Sign out of your active session" : "Signed in as \(state.userEmail)")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundStyle(StamerleeTheme.textSecondaryLight)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(StamerleeTheme.textSecondaryLight)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 58)
                }
                .buttonStyle(.haptic)

                Divider()
                    .padding(.horizontal, 16)

                // Delete Account Row
                Button {
                    showDeleteConfirmation = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.red)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Delete Account")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.red)
                            
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.red.opacity(0.6))
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 58)
                }
                .buttonStyle(.haptic)
            }
            .background(StamerleeTheme.profileCard)
            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
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

    private func stat(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(StamerleeTheme.textPrimaryLight)
            Text(subtitle)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(StamerleeTheme.textSecondaryLight)
        }
    }
}

// MARK: - Legal Document Viewer Sheet
private struct LegalDocumentSheet: View {
    let title: String
    let content: String
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                StamerleeTheme.backgroundDark.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(content)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .lineSpacing(5)
                            .foregroundStyle(Color.white.opacity(0.85))
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            .padding(.bottom, 36)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(StamerleeTheme.backgroundDark, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.white.opacity(0.6))
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
        .presentationBackground(StamerleeTheme.backgroundDark)
    }
}

private struct StreakSpark: View {
    var body: some View {
        ZStack {
            Image(systemName: "sparkle")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(.yellow)
            Image(systemName: "sparkle")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.yellow)
                .offset(x: 25, y: -22)
            Image(systemName: "sparkle")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.yellow)
                .offset(x: 27, y: 25)
        }
    }
}
