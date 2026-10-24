import SwiftUI

// MARK: - Summary
/// Progress overview shown in the Summary tab.
public struct SummaryView: View {
    @Bindable public var state: AppState

    private let lavender = Color(red: 230 / 255, green: 229 / 255, blue: 255 / 255)
    private let rowBackground = Color.white.opacity(0.48)
    private let summaryBlue = Color(red: 73 / 255, green: 111 / 255, blue: 245 / 255)

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ZStack {
            StamerleeTheme.backgroundDark.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    Text("Summary")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.top, 18)

                    practiceStreakCard
                    challengingSoundsCard
                    exerciseMasteryCard
                    Spacer(minLength: 86)
                }
                .padding(.horizontal, 24)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var practiceStreakCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color(red: 117 / 255, green: 113 / 255, blue: 231 / 255))
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.35), in: Circle())
                Text("Practice Streak")
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textPrimaryLight)
                Spacer()
                Text("Apr 24 - Apr 28 ⌄")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textPrimaryLight)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.38), in: Capsule())
            }

            HStack(spacing: 14) {
                ForEach(Array(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].enumerated()), id: \.offset) { index, day in
                    let isCompleted = index < min(max(state.currentStreakDays, 0), 5)
                    let isCurrent = index == 4

                    VStack(spacing: 7) {
                        ZStack {
                            Circle()
                                .stroke(summaryBlue.opacity(0.35), lineWidth: isCurrent ? 5 : 1.5)
                                .frame(width: 24, height: 24)
                            if isCompleted {
                                Circle().fill(summaryBlue).frame(width: 24, height: 24)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        Text(day)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(isCurrent ? StamerleeTheme.textPrimaryLight : summaryBlue.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(lavender, in: RoundedRectangle(cornerRadius: 16))
    }

    private var challengingSoundsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Challenging Sounds")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(StamerleeTheme.textPrimaryLight)
            soundSummaryRow(letter: "K", title: "K / G sounds", status: "Worth exploring")
            soundSummaryRow(letter: "S", title: "S sounds", status: "Getting more comfortable")
            Text("Based on your last 20 sessions.")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(summaryBlue.opacity(0.68))
                .padding(.top, 2)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(lavender, in: RoundedRectangle(cornerRadius: 16))
    }

    private func soundSummaryRow(letter: String, title: String, status: String) -> some View {
        HStack(spacing: 14) {
            Text(letter)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(summaryBlue)
                .frame(width: 48, height: 48)
                .background(Color(red: 220 / 255, green: 227 / 255, blue: 255 / 255), in: Circle())
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(StamerleeTheme.textPrimaryLight)
            Spacer(minLength: 4)
            Text(status)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(summaryBlue)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(red: 218 / 255, green: 226 / 255, blue: 255 / 255), in: Capsule())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(rowBackground, in: RoundedRectangle(cornerRadius: 14))
    }

    private var exerciseMasteryCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Exercise Mastery")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(StamerleeTheme.textPrimaryLight)
            Text("Your current exercise levels, at a glance.")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(summaryBlue.opacity(0.7))
                .padding(.bottom, 4)
            masteryRow(icon: "📖", title: "Prolonged Speech", score: state.completedProlongedDifficulties.count * 33)
            masteryRow(icon: "🖼️", title: "Picture Description", score: state.completedPictureDescriptionDifficulties.count * 33)
            masteryRow(icon: "📞", title: "Dial Scene", score: state.hasCompletedDialScene ? 74 : 0)
            masteryRow(icon: "💜", title: "Narration with Mirror", score: state.completedNarrationDifficulties.count * 33)
            Text("Smooth speech percentages based on level performance.")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(summaryBlue.opacity(0.7))
                .padding(.top, 2)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(lavender, in: RoundedRectangle(cornerRadius: 16))
    }

    private func masteryRow(icon: String, title: String, score: Int) -> some View {
        HStack(spacing: 12) {
            Text(icon).font(.system(size: 24)).frame(width: 36)
            Text(title)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(StamerleeTheme.textPrimaryLight)
            Spacer()
            Text("\(score) / 100")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(summaryBlue)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(red: 218 / 255, green: 226 / 255, blue: 255 / 255), in: Capsule())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(rowBackground, in: RoundedRectangle(cornerRadius: 14))
    }
}


#Preview("Summary Screen") {
    @Previewable @State var state = AppState()

    SummaryView(state: state)
}
