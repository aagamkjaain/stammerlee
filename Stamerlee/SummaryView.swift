import SwiftUI
import UIKit

// MARK: - Summary
/// Progress overview shown in the Summary tab.
public struct SummaryView: View {
    @Bindable public var state: AppState

    private let rowBackground = Color.white.opacity(0.62)
    private let summaryBlue = StamerleeTheme.primaryBlue
    private let streakCardBackground = Color(red: 232 / 255, green: 233 / 255, blue: 248 / 255)
    private let streakAccent = Color(red: 139 / 255, green: 112 / 255, blue: 245 / 255)
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
                    exerciseBlocksSection
                    Spacer(minLength: 86)
                }
                .padding(.horizontal, 24)
            }
        }
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

                Spacer()
            }

            HStack(spacing: 4) {
                ForEach(Array(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].enumerated()), id: \.offset) { index, day in
                    let completedDays = min(max(state.currentStreakDays, 0), 7)
                  
                    let isCurrent = completedDays > 0 && index == completedDays - 1

                    VStack(spacing: 9) {
                        Text(day)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(StamerleeTheme.textPrimaryLight)

                        if index < completedDays {
                            ZStack {
                                Circle()
                                    .fill(streakAccent)
                                    .frame(width: 28, height: 28)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        } else {
                            Circle()
                                .stroke(streakRing, lineWidth: 2)
                                .frame(width: 28, height: 28)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        isCurrent ? selectedDayBackground : Color.clear,
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(streakCardBackground, in: RoundedRectangle(cornerRadius: 18))
    }

    private struct ExerciseHighScoreItem: Identifiable {
        let id: String
        let title: String
        let displayTitle: String
        let iconName: String
        let score: Int
        let targetScreen: AppScreen
    }

    private var exerciseHighScoreItems: [ExerciseHighScoreItem] {
        [
            ExerciseHighScoreItem(
                id: "picture_desc",
                title: "Picture Description",
                displayTitle: "picture\ndescription",
                iconName: "IconPictureDesc",
                score: 86,
                targetScreen: state.hasSeenPictureDescriptionIntro ? .pictureDescriptionPractice : .pictureDescriptionIntro
            ),
            ExerciseHighScoreItem(
                id: "prolonged_speech",
                title: "Prolonged Speech",
                displayTitle: "prolonged\nspeech",
                iconName: "IconProlongedSpeech",
                score: 92,
                targetScreen: state.hasSeenProlongedSpeechIntro ? .prolongedSpeechDifficulty : .prolongedSpeechIntro
            ),
            ExerciseHighScoreItem(
                id: "dial_scene",
                title: "Dial Scene",
                displayTitle: "dial\nscene",
                iconName: "IconDialScene",
                score: 78,
                targetScreen: state.hasSeenDialSceneIntro ? .dialScene : .dialSceneIntro
            ),
            ExerciseHighScoreItem(
                id: "narration",
                title: "Narration",
                displayTitle: "mirror\nnarration",
                iconName: "IconMirrorNarration",
                score: 89,
                targetScreen: state.hasSeenNarrationIntro ? .narrationPractice : .narrationIntro
            )
        ]
    }

    private var exerciseBlocksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Exercises")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 14),
                    GridItem(.flexible(), spacing: 14)
                ],
                spacing: 14
            ) {
                ForEach(exerciseHighScoreItems) { item in
                    exerciseBlockCard(item: item)
                }
            }
        }
    }

    private func exerciseBlockCard(item: ExerciseHighScoreItem) -> some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            state.navigate(to: item.targetScreen)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Top Row: 3D Icon on left, Title on right
                HStack(alignment: .top) {
                    summaryAssetImage(named: item.iconName, size: 48)
                    Spacer(minLength: 4)
                    Text(item.displayTitle)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(-2)
                }

                Spacer(minLength: 16)

                // Large Score / 100
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\(item.score)")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundStyle(.black)
                    Text("/100")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 130 / 255, green: 134 / 255, blue: 170 / 255))
                }

                // Subtitle
                Text("Smooth speech score")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.top, 4)
                    .padding(.bottom, 12)

                // Gradient Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(red: 222 / 255, green: 224 / 255, blue: 242 / 255))
                            .frame(height: 8)

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
                                width: max(geo.size.width * CGFloat(item.score) / 100.0, 8),
                                height: 8
                            )
                    }
                }
                .frame(height: 8)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 184, alignment: .topLeading)
            .background(
                Color(red: 242 / 255, green: 243 / 255, blue: 252 / 255),
                in: RoundedRectangle(cornerRadius: 26, style: .continuous)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }

    private func summaryAssetImage(named name: String, size: CGFloat = 52) -> some View {
        Group {
            if let image = StamerleeImageLoader.loadHeroImage(
                name: name,
                fallbackPath: "/Users/user89/Documents/stammerlee/Stamerlee/\(name).png"
            ) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
            } else {
                Image(systemName: "photo")
                    .font(.system(size: size * 0.6))
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
