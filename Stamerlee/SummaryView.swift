import SwiftUI
import UIKit

// MARK: - Summary
/// Progress overview shown in the Summary tab.
public struct SummaryView: View {
    @Bindable public var state: AppState

    private let lavender = StamerleeTheme.profileCard
    private let rowBackground = Color.white.opacity(0.62)
    private let summaryBlue = StamerleeTheme.primaryBlue
    private let streakCardBackground = Color(red: 232 / 255, green: 233 / 255, blue: 248 / 255)
    private let streakAccent = Color(red: 101 / 255, green: 120 / 255, blue: 223 / 255)
    private let streakRing = Color(red: 165 / 255, green: 175 / 255, blue: 232 / 255)
    private let selectedDayBackground = Color(red: 215 / 255, green: 217 / 255, blue: 243 / 255)

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
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 10) {
                Image(systemName: "flame")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(streakAccent)
                    .frame(width: 48, height: 48)
                    .background(streakAccent.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 1) {
                    Text("Daily Practice")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textPrimaryLight)
                    Text("Streak: \(max(state.currentStreakDays, 0)) Days")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textSecondaryLight)
                }

                
            }

            HStack(spacing: 0) {
                ForEach(Array(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].enumerated()), id: \.offset) { index, day in
                    let completedDays = min(max(state.currentStreakDays, 0), 7)
                 
                    let isCurrent = completedDays > 0 && index == completedDays - 1

                    VStack(spacing: 8) {
                        Text(day)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(StamerleeTheme.textPrimaryLight)

                        
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                    .background(isCurrent ? selectedDayBackground : .clear, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(streakCardBackground, in: RoundedRectangle(cornerRadius: 18))
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
            masteryRow(assetName: "IconProlongedSpeech", title: "Prolonged Speech", score: state.completedProlongedDifficulties.count * 33)
            masteryRow(assetName: "IconPictureDesc", title: "Picture Description", score: state.completedPictureDescriptionDifficulties.count * 33)
            masteryRow(assetName: "IconDialScene", title: "Dial Scene", score: state.hasCompletedDialScene ? 74 : 0)
            masteryRow(assetName: "IconMirrorNarration", title: "Narration with Mirror", score: state.completedNarrationDifficulties.count * 33)
            Text("Smooth speech percentages based on level performance.")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(summaryBlue.opacity(0.7))
                .padding(.top, 2)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(lavender, in: RoundedRectangle(cornerRadius: 16))
    }

    private func masteryRow(assetName: String, title: String, score: Int) -> some View {
        HStack(spacing: 12) {
            summaryAssetImage(named: assetName)
                .frame(width: 36)
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

    private func summaryAssetImage(named name: String) -> some View {
        Group {
            if let image = StamerleeImageLoader.loadHeroImage(
                name: name,
                fallbackPath: "/Users/user89/Documents/stammerlee/Stamerlee/\(name).png"
            ) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 20))
                    .foregroundStyle(summaryBlue)
            }
        }
    }
}

private struct PracticeCalendarSheet: View {
    let streakDays: Int
    @State private var selectedDate = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Practice calendar")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                    Text("Your practice days are marked below")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.black.opacity(0.55))
                }
                Spacer()
                Image(systemName: "calendar")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.65))
            }

            NativePracticeCalendar(streakDays: streakDays, selectedDate: $selectedDate)
                .frame(height: 300)
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .presentationBackground(Color.white)
    }

}

private struct NativePracticeCalendar: UIViewRepresentable {
    let streakDays: Int
    @Binding var selectedDate: Date

    func makeCoordinator() -> Coordinator {
        Coordinator(streakDays: streakDays, selectedDate: $selectedDate)
    }

    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.calendar = Calendar.current
        calendarView.locale = Locale.current
        calendarView.fontDesign = .rounded
        calendarView.wantsDateDecorations = true
        calendarView.delegate = context.coordinator
        calendarView.overrideUserInterfaceStyle = .light
        calendarView.backgroundColor = .clear
        return calendarView
    }

    func updateUIView(_ calendarView: UICalendarView, context: Context) {
        context.coordinator.streakDays = streakDays
        calendarView.reloadDecorations(forDateComponents: context.coordinator.practiceDateComponents(), animated: true)
    }

    final class Coordinator: NSObject, UICalendarViewDelegate {
        var streakDays: Int
        var selectedDate: Binding<Date>

        init(streakDays: Int, selectedDate: Binding<Date>) {
            self.streakDays = streakDays
            self.selectedDate = selectedDate
        }

        func calendarView(
            _ calendarView: UICalendarView,
            decorationFor dateComponents: DateComponents
        ) -> UICalendarView.Decoration? {
            guard let date = calendarView.calendar.date(from: dateComponents),
                  isPracticeDay(date, calendar: calendarView.calendar) else {
                return nil
            }

            return .image(
                UIImage(systemName: "checkmark.circle.fill"),
                color: .systemGreen,
                size: .medium
            )
        }

        func practiceDateComponents() -> [DateComponents] {
            let calendar = Calendar.current
            return (0..<max(streakDays, 0)).compactMap { offset in
                guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else {
                    return nil
                }
                return calendar.dateComponents([.year, .month, .day], from: date)
            }
        }

        private func isPracticeDay(_ date: Date, calendar: Calendar) -> Bool {
            let today = calendar.startOfDay(for: Date())
            let dayOffset = calendar.dateComponents(
                [.day],
                from: calendar.startOfDay(for: date),
                to: today
            ).day ?? Int.max
            return dayOffset >= 0 && dayOffset < max(streakDays, 0)
        }
    }
}
