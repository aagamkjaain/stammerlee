import SwiftUI
import UIKit

// MARK: - Exercise Progress Detail View
/// Detailed progress analytics screen for an individual exercise (Picture Description, Prolonged Speech, Dial Scene, Narration).
/// Matches the high-score trophy card, weekly curved progress chart, progress overview card, and Practice Again CTA.
public struct ExerciseProgressDetailView: View {
    @Bindable public var state: AppState
    @State private var didAppearContent = false
    @State private var chartAnimationProgress: CGFloat = 0.0
    @State private var selectedDayIndex: Int? = 6 // Default to Sunday (latest)

    public init(state: AppState) {
        self.state = state
    }

    private var exercise: ExerciseDetailType {
        state.selectedExerciseDetail
    }

    private var highScore: Double {
        if exercise == .prolongedSpeech, let score = state.prolongedEasyScore, score > 0 {
            return max(score, exercise.defaultHighScore)
        }
        return exercise.defaultHighScore
    }

    private var weeklyScores: [Double] {
        var scores = exercise.weeklyScores
        if exercise == .prolongedSpeech, let score = state.prolongedEasyScore, score > 0 {
            scores[scores.count - 1] = score
        }
        return scores
    }

    private let dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    public var body: some View {
        ZStack(alignment: .top) {
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()

            // Header Background Illustration
            headerImageView
                .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(spacing: 0) {
                    // Top Bar (Back Button)
                    topBar
                        .padding(.top, 14)
                        .padding(.horizontal, 24)

                    // Header Info (Icon + Title + Subtitle)
                    headerSection
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 22)

                    // Content Cards
                    VStack(spacing: 20) {
                        // 1. High Score Card
                        highScoreCard

                        // 2. Exercise Progress Card (Line Chart)
                        exerciseProgressCard

                        // 3. Progress Overview Section
                        progressOverviewSection

                        // 4. Practice Again Button
                        practiceAgainButton
                            .padding(.top, 6)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 36)
                }
            }
            .scrollIndicators(.hidden)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.spring(response: 0.52, dampingFraction: 0.82)) {
                didAppearContent = true
            }
            withAnimation(.easeInOut(duration: 0.9).delay(0.15)) {
                chartAnimationProgress = 1.0
            }
        }
    }

    // MARK: - Top Header Image
    @ViewBuilder
    private var headerImageView: some View {
        Group {
            if let uiImage = UIImage(named: "header") ?? UIImage(named: "Header") {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
            } else {
                Image("Header")
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
                    StamerleeTheme.backgroundDark.opacity(0.35),
                    StamerleeTheme.backgroundDark
                ],
                startPoint: .init(x: 0.5, y: 0.55),
                endPoint: .bottom
            )
        )
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button {
                state.selectedTab = .summary
                state.navigate(to: .homeDashboard, forward: false)
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.16))
                        .frame(width: 40, height: 40)
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(PopSpringButtonStyle(pressedScale: 0.92))
            .accessibilityLabel("Go back to summary")

            Spacer()
        }
    }

    // MARK: - Header Info
    private var headerSection: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(exercise.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(exercise.subtitle)
                    .font(.system(size: 13.5, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(red: 175 / 255, green: 170 / 255, blue: 215 / 255))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - 1. High Score Card
    private var highScoreCard: some View {
        HStack(alignment: .center, spacing: 14) {
            // Trophy Asset (with Sparkles)
            Group {
                if let uiImage = UIImage(named: "trophy") ?? UIImage(contentsOfFile: Bundle.main.path(forResource: "trophy", ofType: "png") ?? "") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 46, height: 46)
                } else {
                    HStack(spacing: 3) {
                        Text("✨")
                            .font(.system(size: 13))
                            .offset(y: -4)
                        Text("🏆")
                            .font(.system(size: 32))
                        Text("✨")
                            .font(.system(size: 13))
                            .offset(y: -4)
                    }
                }
            }
            .frame(width: 50, height: 50)

            Text("High Score")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 25 / 255, green: 22 / 255, blue: 45 / 255))

            Spacer()

            // Lavender Score Badge
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(String(format: "%.1f", highScore))
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(red: 20 / 255, green: 15 / 255, blue: 40 / 255))
                Text("/10")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 139 / 255, green: 112 / 255, blue: 245 / 255))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 7)
            .background(Color(red: 236 / 255, green: 228 / 255, blue: 254 / 255))
            .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(glassCardBackground(cornerRadius: 22))
    }

    // MARK: - 2. Exercise Progress Card (Line Chart)
    private var exerciseProgressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Top Row: Title + Weekly Pill
            HStack {
                Text("Excersise Progress")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 25 / 255, green: 22 / 255, blue: 45 / 255))

                Spacer()

                Text("weekly")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 125 / 255, green: 90 / 255, blue: 230 / 255))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(Color(red: 238 / 255, green: 232 / 255, blue: 254 / 255))
                    .clipShape(Capsule())
            }

            // Interactive Line Chart
            WeeklyLineChart(
                scores: weeklyScores,
                dayLabels: dayLabels,
                progress: chartAnimationProgress,
                selectedIndex: $selectedDayIndex
            )
            .frame(height: 160)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(glassCardBackground(cornerRadius: 22))
    }

    // MARK: - 3. Progress Overview Section
    private var progressOverviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress overview")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            HStack(spacing: 16) {
                // Glowing Star Badge
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 135 / 255, green: 90 / 255, blue: 245 / 255),
                                    Color(red: 95 / 255, green: 55 / 255, blue: 215 / 255)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .shadow(color: Color(red: 135 / 255, green: 90 / 255, blue: 245 / 255).opacity(0.5), radius: 8, x: 0, y: 3)

                    Image(systemName: "star.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.overviewTitle)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 25 / 255, green: 20 / 255, blue: 45 / 255))

                    Text(exercise.overviewSubtitle)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(Color(red: 105 / 255, green: 85 / 255, blue: 175 / 255))
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(glassCardBackground(cornerRadius: 22))
        }
    }

    // MARK: - 4. Practice Again Button
    private var practiceAgainButton: some View {
        Button {
            state.navigate(to: exercise.targetScreen(for: state))
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "play.fill")
                    .font(.system(size: 15, weight: .bold))
                Text("Practice Again")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 172 / 255, green: 125 / 255, blue: 255 / 255),
                        Color(red: 138 / 255, green: 78 / 255, blue: 242 / 255)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: Color(red: 138 / 255, green: 78 / 255, blue: 242 / 255).opacity(0.42), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(PopSpringButtonStyle(pressedScale: 0.96))
        .accessibilityLabel("Practice \(exercise.title) again")
    }

    // MARK: - Glass Card Styling Helper
    private func glassCardBackground(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color(red: 248 / 255, green: 249 / 255, blue: 255 / 255).opacity(0.94))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white,
                                Color.white.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Smooth Weekly Line Chart
private struct WeeklyLineChart: View {
    let scores: [Double]
    let dayLabels: [String]
    let progress: CGFloat
    @Binding var selectedIndex: Int?

    private let yAxisLabels = [10, 8, 6, 4, 2, 0]

    var body: some View {
        GeometryReader { geo in
            let yAxisWidth: CGFloat = 22
            let bottomLabelHeight: CGFloat = 22
            let plotWidth = geo.size.width - yAxisWidth - 8
            let plotHeight = geo.size.height - bottomLabelHeight

            ZStack(alignment: .topLeading) {
                // Y-Axis Labels
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(yAxisLabels, id: \.self) { val in
                        Text("\(val)")
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundStyle(Color(red: 140 / 255, green: 135 / 255, blue: 165 / 255))
                            .frame(width: yAxisWidth, alignment: .leading)
                        if val != 0 {
                            Spacer()
                        }
                    }
                }
                .frame(width: yAxisWidth, height: plotHeight)

                // Chart Plot Area
                let points = computePoints(plotWidth: plotWidth, plotHeight: plotHeight, xOffset: yAxisWidth + 8)

                // Gradient Area Fill under curve
                if points.count > 1 {
                    chartAreaPath(points: points, plotHeight: plotHeight, xOffset: yAxisWidth + 8, width: plotWidth)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 175 / 255, green: 125 / 255, blue: 250 / 255).opacity(0.40 * progress),
                                    Color(red: 235 / 255, green: 220 / 255, blue: 255 / 255).opacity(0.04 * progress)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    // Line Stroke
                    chartCurvePath(points: points)
                        .trim(from: 0, to: progress)
                        .stroke(
                            Color(red: 168 / 255, green: 118 / 255, blue: 246 / 255),
                            style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round)
                        )

                    // Data Point Circles
                    ForEach(0..<points.count, id: \.self) { index in
                        let pt = points[index]
                        let isSelected = selectedIndex == index

                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: isSelected ? 10 : 8, height: isSelected ? 10 : 8)
                                .overlay(
                                    Circle()
                                        .stroke(Color(red: 168 / 255, green: 118 / 255, blue: 246 / 255), lineWidth: isSelected ? 2.5 : 2)
                                )

                            if isSelected {
                                Circle()
                                    .fill(Color(red: 139 / 255, green: 112 / 255, blue: 245 / 255))
                                    .frame(width: 4, height: 4)
                            }
                        }
                        .scaleEffect(progress)
                        .position(pt)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            selectedIndex = index
                        }
                    }
                }

                // X-Axis Day Labels
                HStack(spacing: 0) {
                    ForEach(0..<dayLabels.count, id: \.self) { index in
                        let isSelected = selectedIndex == index
                        Text(dayLabels[index])
                            .font(.system(size: 11.5, weight: isSelected ? .bold : .medium, design: .rounded))
                            .foregroundStyle(
                                isSelected
                                    ? Color(red: 30 / 255, green: 20 / 255, blue: 60 / 255)
                                    : Color(red: 110 / 255, green: 105 / 255, blue: 135 / 255)
                            )
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                selectedIndex = index
                            }
                    }
                }
                .padding(.leading, yAxisWidth + 8)
                .frame(width: geo.size.width, height: bottomLabelHeight)
                .position(x: geo.size.width / 2, y: geo.size.height - bottomLabelHeight / 2)
            }
        }
    }

    private func computePoints(plotWidth: CGFloat, plotHeight: CGFloat, xOffset: CGFloat) -> [CGPoint] {
        guard !scores.isEmpty else { return [] }
        let count = scores.count
        let stepX = plotWidth / CGFloat(count - 1)

        return scores.enumerated().map { index, score in
            let x = xOffset + CGFloat(index) * stepX
            let normalizedY = CGFloat(max(0.0, min(10.0, score))) / 10.0
            let y = plotHeight - (normalizedY * (plotHeight - 16)) - 8
            return CGPoint(x: x, y: y)
        }
    }

    private func chartCurvePath(points: [CGPoint]) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }

        path.move(to: points[0])
        for i in 0..<(points.count - 1) {
            let p0 = i > 0 ? points[i - 1] : points[i]
            let p1 = points[i]
            let p2 = points[i + 1]
            let p3 = i < points.count - 2 ? points[i + 2] : p2

            let cp1 = CGPoint(
                x: p1.x + (p2.x - p0.x) / 6.0,
                y: p1.y + (p2.y - p0.y) / 6.0
            )
            let cp2 = CGPoint(
                x: p2.x - (p3.x - p1.x) / 6.0,
                y: p2.y - (p3.y - p1.y) / 6.0
            )
            path.addCurve(to: p2, control1: cp1, control2: cp2)
        }
        return path
    }

    private func chartAreaPath(points: [CGPoint], plotHeight: CGFloat, xOffset: CGFloat, width: CGFloat) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }

        let baseline = plotHeight

        path.move(to: CGPoint(x: points[0].x, y: baseline))
        path.addLine(to: points[0])

        for i in 0..<(points.count - 1) {
            let p0 = i > 0 ? points[i - 1] : points[i]
            let p1 = points[i]
            let p2 = points[i + 1]
            let p3 = i < points.count - 2 ? points[i + 2] : p2

            let cp1 = CGPoint(
                x: p1.x + (p2.x - p0.x) / 6.0,
                y: p1.y + (p2.y - p0.y) / 6.0
            )
            let cp2 = CGPoint(
                x: p2.x - (p3.x - p1.x) / 6.0,
                y: p2.y - (p3.y - p1.y) / 6.0
            )
            path.addCurve(to: p2, control1: cp1, control2: cp2)
        }

        path.addLine(to: CGPoint(x: points.last!.x, y: baseline))
        path.closeSubpath()
        return path
    }
}
