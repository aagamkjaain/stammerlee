
import SwiftUI
import UIKit

// MARK: - Summary
/// Progress overview shown in the Summary tab.
public struct SummaryView: View {
    @Bindable public var state: AppState

    private let rowBackground = Color.white.opacity(0.62)
    private let summaryBlue = StamerleeTheme.primaryBlue
    private let streakCardBackground = Color(red: 242 / 255, green: 243 / 255, blue: 252 / 255)
    private let streakAccent = Color(red: 139 / 255, green: 112 / 255, blue: 245 / 255)
    private let streakRing = Color(red: 205 / 255, green: 200 / 255, blue: 232 / 255)
    private let selectedDayBackground = Color(red: 228 / 255, green: 222 / 255, blue: 252 / 255)

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ZStack(alignment: .top) {
            StamerleeTheme.backgroundDark.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Top Header Banner
                headerImageView

                // Title
                HStack {
                    Text("Summary")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, -48)
                .padding(.bottom, 10)

                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        practiceStreakCard
                        exerciseBlocksSection
                        Spacer(minLength: 86)
                    }
                    .padding(.horizontal, 24)
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    // MARK: - Top Header Image
    @ViewBuilder
    private var headerImageView: some View {
        if let uiImage = UIImage(named: "header") ?? UIImage(named: "Header") {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .top)
        } else {
            Image("Header")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .top)
        }
    }

    // MARK: - Streak Fire Asset Image
    @ViewBuilder
    private var fireImageView: some View {
        if let uiImage = UIImage(named: "fire") ?? UIImage(contentsOfFile: Bundle.main.path(forResource: "fire", ofType: "png") ?? "") {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            Image("fire")
                .resizable()
                .scaledToFit()
        }
    }

    private var practiceStreakCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                fireImageView
                    .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Practice")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 20 / 255, green: 18 / 255, blue: 38 / 255))
                    Text("Streak: \(max(state.currentStreakDays, 0)) Days")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 105 / 255, green: 98 / 255, blue: 142 / 255))
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
                            .foregroundStyle(Color(red: 35 / 255, green: 30 / 255, blue: 55 / 255))

                        if index < completedDays {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 76/255, green: 175/255, blue: 80/255))
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
        .padding(.vertical, 18)
        .background(
            streakCardBackground,
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

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
                type: .pictureDescription,
                displayTitle: "Picture\nDescription",
                score: 8.8
            ),
            ExerciseHighScoreItem(
                type: .prolongedSpeech,
                displayTitle: "Prolonged\nSpeech",
                score: state.prolongedEasyScore ?? 7.9
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

    private var exerciseBlocksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Smooth Speech Score")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Based on your last attempt, here's your score for words spoken without stuttering.")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
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
                    Button {
                        state.selectedExerciseDetail = item.type
                        state.navigate(to: .exerciseProgressDetail)
                    } label: {
                        exerciseBlockCard(item: item)
                    }
                    .buttonStyle(PopSpringButtonStyle(pressedScale: 0.94))
                    .accessibilityLabel("\(item.title) card, score \(String(format: "%.1f", item.score)) of 10")
                }
            }
        }
    }

    private func exerciseBlockCard(item: ExerciseHighScoreItem) -> some View {
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

            Spacer(minLength: 8)

            // Large Score / 10
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(String(format: "%.1f", item.score))
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(red: 22 / 255, green: 18 / 255, blue: 40 / 255))
                Text("/10")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 125 / 255, green: 110 / 255, blue: 180 / 255))
            }

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
                            width: max(geo.size.width * CGFloat(item.score) / 10.0, 8),
                            height: 8
                        )
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

    private func summaryAssetImage(named name: String, size: CGFloat = 52) -> some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
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

