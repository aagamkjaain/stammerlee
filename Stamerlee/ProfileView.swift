import SwiftUI

// MARK: - Profile
/// Personal progress screen presented from the dashboard's Profile tab.
public struct ProfileView: View {
    @Bindable public var state: AppState

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

                    VStack(alignment: .leading, spacing: 25) {
                        statsSection
                        streakSection
                        dailyGoalCard
                    }
                    .padding(.horizontal, 26)
                    .padding(.top, 26)
                    .padding(.bottom, 38)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var profileHeader: some View {
        ZStack(alignment: .topTrailing) {
            ProfileHeaderWaves()
                .fill(StamerleeTheme.profileHeaderBase)
                .frame(height: 178)
                .overlay {
                    ProfileHeaderWaves()
                        .stroke(StamerleeTheme.profileHeaderHighlight, lineWidth: 1)
                        .opacity(0.28)
                }

            // The reference uses this as a visual settings affordance. Settings
            // navigation is intentionally left out until that destination exists.
            Image(systemName: "gearshape.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white.opacity(0.86))
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.12))
                .clipShape(Circle())
                .padding(.top, 19)
                .padding(.trailing, 18)

            VStack(spacing: 9) {
                ProfileAvatar()

                Text("John doe")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textPrimaryDark)

                Text("Joined in October 2026")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textSecondaryDark)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 54)
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Stats")

            VStack(alignment: .leading, spacing: 18) {
                stat(title: "8 minutes", subtitle: "Average session length")
                stat(title: "2 sessions", subtitle: "Sessions completed")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(StamerleeTheme.profileCard)
            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        }
    }

    private var streakSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Streak")

            HStack(alignment: .center, spacing: 19) {
                VStack(spacing: 2) {
                    StreakSpark()
                        .frame(width: 66, height: 63)

                    Text("\(state.currentStreakDays) days")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .frame(width: 66)

                Text("You've got this. All you need is a few\nminutes a day to get your streak\ngoing.")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textSecondaryDark)
                    .lineSpacing(7)

                Spacer(minLength: 0)
            }
        }
    }

    private var dailyGoalCard: some View {
        HStack {
            Text("Daily goal")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Spacer()
        }
        .padding(.horizontal, 24)
        .frame(height: 145)
        .background(StamerleeTheme.profileCard)
        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundStyle(.white.opacity(0.9))
    }

    private func stat(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 19, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
            Text(subtitle)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(StamerleeTheme.textSecondaryDark)
        }
    }
}

private struct ProfileAvatar: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(StamerleeTheme.profileAvatarBlue)
                .padding(8)

            Circle()
                .fill(Color.black)
                .frame(width: 22, height: 22)
                .offset(y: -13)

            Capsule()
                .fill(Color.black)
                .frame(width: 59, height: 33)
                .offset(y: 25)
        }
        .frame(width: 84, height: 84)
        .background(Color.black)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.black.opacity(0.55), lineWidth: 7))
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

private struct ProfileHeaderWaves: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.25))
        path.addCurve(
            to: CGPoint(x: 0, y: rect.height * 0.25),
            control1: CGPoint(x: rect.width * 0.67, y: -rect.height * 0.04),
            control2: CGPoint(x: rect.width * 0.3, y: -rect.height * 0.04)
        )
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}
