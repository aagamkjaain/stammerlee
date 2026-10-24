import SwiftUI

// MARK: - Profile
/// Personal progress screen presented from the dashboard's Profile tab.
public struct ProfileView: View {
    @Bindable public var state: AppState
    @State private var isEditingProfile = false

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ZStack {
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    profileHeader

                    VStack(alignment: .leading, spacing: 22) {
                        statsSection
                        streakSection
                        dailyGoalCard
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 22)
                    .padding(.bottom, 32)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var profileHeader: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                StamerleeTheme.profileHeaderBase
                ProfileArc(fill: StamerleeTheme.profileHeaderHighlight, height: 142, yOffset: 28)
                ProfileArc(fill: StamerleeTheme.profileArcDark, height: 120, yOffset: 57)
            }
            .frame(height: 184)

            // The reference uses this as a visual settings affordance. Settings
            // navigation is intentionally left out until that destination exists.

            VStack(spacing: 9) {
                ProfileAvatar(style: state.profileAvatarStyle)

                if isEditingProfile {
                    avatarStylePicker
                }

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
            .frame(maxWidth: .infinity)
            .padding(.top, 44)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isEditingProfile.toggle()
                }
            } label: {
                Image(systemName: isEditingProfile ? "checkmark" : "pencil")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(StamerleeTheme.textPrimaryLight)
                    .frame(width: 38, height: 38)
                    .background(StamerleeTheme.profileCard)
                    .clipShape(Circle())
            }
            .padding(.top, 18)
            .padding(.trailing, 20)
            .accessibilityLabel(isEditingProfile ? "Save profile" : "Edit profile")
        }
    }

    private var avatarStylePicker: some View {
        HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { style in
                Button {
                    state.profileAvatarStyle = style
                } label: {
                    ProfileAvatar(style: style)
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
        }
        .frame(height: 42)
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Stats")

            VStack(alignment: .leading, spacing: 15) {
                stat(title: "8 minutes", subtitle: "Average session length")
                stat(title: "2 sessions", subtitle: "Sessions completed")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(StamerleeTheme.profileCard)
            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        }
    }

    private var streakSection: some View {
        VStack(alignment: .leading, spacing: 11) {
            sectionTitle("Streak")

            HStack(alignment: .center, spacing: 14) {
                VStack(spacing: 2) {
                    StreakSpark()
                        .frame(width: 66, height: 63)

                    Text("\(state.currentStreakDays) days")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .frame(width: 66)

                Text("You've got this. All you need is a few\nminutes a day to get your streak\ngoing.")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textSecondaryDark)
                    .lineSpacing(4)

                Spacer(minLength: 0)
            }
        }
    }

    private var dailyGoalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily goal")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(StamerleeTheme.textPrimaryLight)

            Picker("Daily practice time", selection: $state.dailyPracticeMinutes) {
                ForEach([5, 10, 15, 20, 30], id: \.self) { minutes in
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
        .frame(height: 128)
        .background(StamerleeTheme.profileCard)
        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
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

private struct ProfileAvatar: View {
    let style: Int

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .padding(8)

            Circle()
                .fill(foregroundColor)
                .frame(width: 22, height: 22)
                .offset(y: -13)

            Capsule()
                .fill(foregroundColor)
                .frame(width: 59, height: 33)
                .offset(y: 25)
        }
        .frame(width: 84, height: 84)
        .background(Color.black)
        .clipShape(Circle())
        .overlay(Circle().stroke(StamerleeTheme.profileCard))
    }

    private var backgroundColor: Color {
        switch style {
        case 1: return StamerleeTheme.accentPurple
        case 2: return StamerleeTheme.primaryBlue
        default: return StamerleeTheme.profileAvatarDark
        }
    }

    private var foregroundColor: Color {
        style == 2 ? StamerleeTheme.profileCard : StamerleeTheme.backgroundDark
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

private struct ProfileArc: View {
    let fill: Color
    let height: CGFloat
    let yOffset: CGFloat

    var body: some View {
        ProfileArcShape()
            .fill(fill)
            .frame(height: height)
            .offset(y: yOffset)
    }
}

private struct ProfileArcShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height * 0.4))
        path.addCurve(
            to: CGPoint(x: rect.width, y: rect.height * 0.4),
            control1: CGPoint(x: rect.width * 0.26, y: -rect.height * 0.03),
            control2: CGPoint(x: rect.width * 0.74, y: -rect.height * 0.03)
        )
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}
