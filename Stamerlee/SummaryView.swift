import SwiftUI
import UIKit

// MARK: - Summary
/// Progress overview shown in the Summary tab.
public struct SummaryView: View {
    @Bindable public var state: AppState
    @State private var showAllSoundsSheet: Bool = false

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
        .sheet(isPresented: $showAllSoundsSheet) {
            AllSoundsNavigationSheet(state: state, isPresented: $showAllSoundsSheet)
                .ignoresSafeArea()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(streakCardBackground)
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

    private var challengingSoundsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                Text("Challenging Sounds")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textPrimaryLight)

                Spacer()

                Button {
                    state.navigate(to: .beatBuddyWords)
                } label: {
                    HStack(spacing: 3) {
                        Text("Practice")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .underline()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundStyle(streakAccent)
                }
                .buttonStyle(.plain)
            }

            Button {
                showAllSoundsSheet = true
            } label: {
                soundSummaryRow(letter: "K", title: "K / G sounds")
            }
            .buttonStyle(.plain)

            Button {
                showAllSoundsSheet = true
            } label: {
                soundSummaryRow(letter: "S", title: "S sounds")
            }
            .buttonStyle(.plain)

            HStack {
                Text("Based on your last 20 sessions.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textSecondaryLight)

                Spacer()

                Button {
                    showAllSoundsSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Text("View more")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .underline()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundStyle(streakAccent)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 2)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(streakCardBackground, in: RoundedRectangle(cornerRadius: 18))
    }

    private func soundSummaryRow(letter: String, title: String) -> some View {
        HStack(spacing: 14) {
            Text(letter)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(streakAccent)
                .frame(width: 48, height: 48)
                .background(selectedDayBackground, in: Circle())
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(StamerleeTheme.textPrimaryLight)
            Spacer(minLength: 4)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(streakAccent.opacity(0.7))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(rowBackground, in: RoundedRectangle(cornerRadius: 14))
    }

    private var exerciseMasteryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Exercise Mastery")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(StamerleeTheme.textPrimaryLight)
            Text("Your current exercise levels, at a glance.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(StamerleeTheme.textSecondaryLight)
                .padding(.bottom, 4)
            masteryRow(
                assetName: "IconProlongedSpeech",
                title: "Prolonged Speech",
                score: state.completedProlongedDifficulties.count * 33
            )
            masteryRow(
                assetName: "IconPictureDesc",
                title: "Picture Description",
                score: state.completedPictureDescriptionDifficulties.count * 33
            )
            masteryRow(
                assetName: "IconDialScene",
                title: "Dial Scene",
                score: state.hasCompletedDialScene ? 74 : 0
            )
            masteryRow(
                assetName: "IconMirrorNarration",
                title: "Narration with Mirror",
                score: state.completedNarrationDifficulties.count * 33
            )
            Text("Smooth speech progress based on level performance.")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(StamerleeTheme.textSecondaryLight)
                .padding(.top, 2)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(streakCardBackground, in: RoundedRectangle(cornerRadius: 18))
    }

    private func masteryRow(assetName: String, title: String, score: Int) -> some View {
        HStack(spacing: 12) {
            summaryAssetImage(named: assetName)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textPrimaryLight)
                Text("\(min(max(score, 0), 100))% progress")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textSecondaryLight)
            }
            Spacer(minLength: 8)

            // Progress Bar Box
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(selectedDayBackground)
                        .frame(height: 7)

                    Capsule()
                        .fill(streakAccent)
                        .frame(
                            width: max(geo.size.width * CGFloat(min(max(score, 0), 100)) / 100.0, score > 0 ? 6 : 0),
                            height: 7
                        )
                }
            }
            .frame(width: 76, height: 7)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
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

// MARK: - All Sounds Navigation Sheet
private struct SoundDetailItem: Identifiable, Hashable {
    let id: String
    let letter: String
    let title: String
    let category: String
    let examples: String
    let mastery: Int
    let sessionCount: Int
    let isChallenging: Bool
}

private struct AllSoundsNavigationSheet: View {
    @Bindable var state: AppState
    @Binding var isPresented: Bool

    private let streakCardBackground = Color(red: 232 / 255, green: 233 / 255, blue: 248 / 255)
    private let streakAccent = Color(red: 101 / 255, green: 120 / 255, blue: 223 / 255)
    private let selectedDayBackground = Color(red: 215 / 255, green: 217 / 255, blue: 243 / 255)
    private let rowBackground = Color.white.opacity(0.85)

    private let sounds: [SoundDetailItem] = [
        SoundDetailItem(
            id: "kg",
            letter: "K",
            title: "K / G sounds",
            category: "Velar Plosives",
            examples: "Come, go, keep, great",
            mastery: 42,
            sessionCount: 16,
            isChallenging: true
        ),
        SoundDetailItem(
            id: "td",
            letter: "T",
            title: "T / D sounds",
            category: "Alveolar Plosives",
            examples: "Today, time, do, day",
            mastery: 52,
            sessionCount: 14,
            isChallenging: true
        ),
        SoundDetailItem(
            id: "chj",
            letter: "CH",
            title: "CH / J sounds",
            category: "Affricates",
            examples: "Choice, change, joy, jump",
            mastery: 48,
            sessionCount: 9,
            isChallenging: true
        ),
        SoundDetailItem(
            id: "th",
            letter: "TH",
            title: "TH sounds",
            category: "Dental Fricatives",
            examples: "Think, thanks, that, there",
            mastery: 56,
            sessionCount: 12,
            isChallenging: true
        ),
        SoundDetailItem(
            id: "rl",
            letter: "R",
            title: "R / L sounds",
            category: "Liquids",
            examples: "Right, real, light, level",
            mastery: 64,
            sessionCount: 11,
            isChallenging: true
        )
    ]

    private var challengingSounds: [SoundDetailItem] {
        sounds.filter { $0.isChallenging }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                streakCardBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        // Header subtitle
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Challenging Sounds")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(StamerleeTheme.textPrimaryLight)

                            Text("Review phoneme groups that need extra attention and pacing practice.")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(StamerleeTheme.textSecondaryLight)
                        }
                        .padding(.top, 4)

                        // Sounds list
                        VStack(spacing: 12) {
                            ForEach(challengingSounds) { sound in
                                soundCard(for: sound)
                            }
                        }

                        // Practice blue hyperlink button
                        practiceHyperlinkButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("Challenging Sounds")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(streakCardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.black.opacity(0.45))
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
        .presentationBackground(streakCardBackground)
        .ignoresSafeArea()
    }

    private func soundCard(for item: SoundDetailItem) -> some View {
        Button {
            isPresented = false
            state.navigate(to: .beatBuddyWords)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    Text(item.letter)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(streakAccent)
                        .frame(width: 44, height: 44)
                        .background(selectedDayBackground, in: Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(item.title)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(StamerleeTheme.textPrimaryLight)

                            Text("• \(item.category)")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(StamerleeTheme.textSecondaryLight)
                        }

                        Text("Words: \(item.examples)")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(StamerleeTheme.textSecondaryLight)
                    }

                    Spacer(minLength: 4)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(streakAccent.opacity(0.6))
                }

                // Progress bar & sessions
                HStack(spacing: 10) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(selectedDayBackground)
                                .frame(height: 6)

                            Capsule()
                                .fill(streakAccent)
                                .frame(
                                    width: geo.size.width * CGFloat(item.mastery) / 100.0,
                                    height: 6
                                )
                        }
                    }
                    .frame(height: 6)

                    Text("\(item.mastery)% mastery")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(streakAccent)

                    Text("•")
                        .font(.system(size: 11))
                        .foregroundStyle(StamerleeTheme.textSecondaryLight)

                    Text("\(item.sessionCount) sessions")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textSecondaryLight)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(rowBackground, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private var practiceHyperlinkButton: some View {
        Button {
            isPresented = false
            state.navigate(to: .beatBuddyWords)
        } label: {
            HStack(spacing: 4) {
                Text("Practice in Beat Buddy")
                    .underline()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .bold))
            }
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(StamerleeTheme.primaryBlue)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
}
