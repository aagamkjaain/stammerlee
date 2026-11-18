import SwiftUI
import UIKit

// MARK: - Exercise Progress Detail View
/// Detailed progress analytics screen for an individual exercise (Picture Description, Prolonged Speech, Dial Scene, Narration).
/// Matches the high-score trophy card, weekly curved progress chart, progress overview card, and Practice Again CTA.
public struct ExerciseProgressDetailView: View {
    @Bindable public var state: AppState
    @State private var didAppearContent = false
    @State private var selectedWeekIndex: Int? = 2 // Default to Week 3 (highest, matching reference)
    @State private var selectedMonth: Int = min(Calendar.current.component(.month, from: Date()), 11) // 1–11 (Jan–Nov)
    @State private var prolongedCategory: String = "Words" // Only for Prolonged Speech
    
    public init(state: AppState) {
        self.state = state
    }
    
    private var exercise: ExerciseDetailType {
        state.selectedExerciseDetail
    }
    
    // MARK: - Month & category–aware data
    
    /// Overall highest score so far across all recorded months in the graph
    private var highScore: Double {
        let allScores: [Double]
        if exercise == .prolongedSpeech {
            allScores = (Self.prolongedMonthlyData[prolongedCategory] ?? []).flatMap { $0 }
        } else {
            allScores = (Self.exerciseMonthlyData[exercise] ?? []).flatMap { $0 }
        }
        return allScores.max() ?? exercise.defaultHighScore
    }
    
    /// Week scores for the selected month (and category for Prolonged Speech)
    private var monthlyScores: [Double] {
        currentMonthScores
    }
    
    /// Look up 4-week scores for the current exercise + month + category
    private var currentMonthScores: [Double] {
        let monthIdx = min(max(selectedMonth - 1, 0), 10)
        if exercise == .prolongedSpeech {
            return Self.prolongedMonthlyData[prolongedCategory]?[monthIdx] ?? [7.0, 7.0, 7.0, 7.0]
        }
        return Self.exerciseMonthlyData[exercise]?[monthIdx] ?? [7.0, 7.0, 7.0, 7.0]
    }
    
    // MARK: - Static score tables (11 months: Jan–Nov × 4 weeks each)
    
    /// Per-exercise, per-month scores (all exercises except Prolonged Speech categories)
    private static let exerciseMonthlyData: [ExerciseDetailType: [[Double]]] = [
        .pictureDescription: [
            [6.2, 6.5, 6.8, 7.0],  // Jan
            [6.8, 7.0, 7.2, 7.4],  // Feb
            [7.0, 7.3, 7.1, 7.5],  // Mar
            [7.2, 7.6, 7.8, 7.4],  // Apr
            [7.5, 7.8, 8.0, 7.9],  // May
            [7.8, 8.1, 8.3, 8.0],  // Jun
            [8.0, 8.2, 8.5, 8.3],  // Jul
            [8.1, 8.4, 8.6, 8.5],  // Aug
            [8.3, 8.6, 8.8, 8.7],  // Sep
            [8.5, 8.8, 9.2, 9.0],  // Oct
            [7.4, 8.2, 9.6, 8.8],  // Nov (current) - High score is 9.6
        ],
        .dialScene: [
            [5.0, 5.2, 5.5, 5.3],  // Jan
            [5.4, 5.6, 5.8, 5.7],  // Feb
            [5.8, 6.0, 6.2, 6.1],  // Mar
            [6.0, 6.3, 6.5, 6.4],  // Apr
            [6.2, 6.5, 6.8, 6.6],  // May
            [6.4, 6.7, 7.0, 6.8],  // Jun
            [6.6, 6.9, 7.2, 7.0],  // Jul
            [6.8, 7.1, 7.4, 7.2],  // Aug
            [7.0, 7.3, 7.5, 7.4],  // Sep
            [7.1, 7.4, 7.6, 7.5],  // Oct
            [6.2, 7.0, 7.8, 7.4],  // Nov (current) - High score is 7.8
        ],
        .narration: [
            [6.0, 6.3, 6.5, 6.4],  // Jan
            [6.5, 6.8, 7.0, 6.9],  // Feb
            [7.0, 7.2, 7.4, 7.3],  // Mar
            [7.2, 7.5, 7.8, 7.6],  // Apr
            [7.5, 7.8, 8.0, 7.9],  // May
            [7.8, 8.0, 8.3, 8.1],  // Jun
            [8.0, 8.3, 8.5, 8.4],  // Jul
            [8.2, 8.5, 8.7, 8.6],  // Aug
            [8.4, 8.6, 8.8, 8.7],  // Sep
            [8.5, 8.7, 8.8, 8.7],  // Oct
            [7.8, 8.4, 8.9, 8.6],  // Nov (current) - High score is 8.9
        ],
    ]
    
    /// Prolonged Speech: per-category, per-month scores
    private static let prolongedMonthlyData: [String: [[Double]]] = [
        "Words": [
            [6.0, 6.3, 6.5, 6.4],  // Jan
            [6.5, 6.8, 7.0, 6.9],  // Feb
            [6.8, 7.0, 7.2, 7.1],  // Mar
            [7.0, 7.3, 7.5, 7.4],  // Apr
            [7.2, 7.5, 7.8, 7.6],  // May
            [7.4, 7.7, 8.0, 7.8],  // Jun
            [7.6, 7.9, 8.2, 8.0],  // Jul
            [7.8, 8.1, 8.3, 8.2],  // Aug
            [8.0, 8.2, 8.4, 8.3],  // Sep
            [8.1, 8.3, 8.4, 8.3],  // Oct
            [7.0, 7.8, 8.5, 8.2],  // Nov (current) - High score is 8.5
        ],
        "Sentences": [
            [5.5, 5.8, 6.0, 5.9],  // Jan
            [6.0, 6.3, 6.5, 6.4],  // Feb
            [6.3, 6.5, 6.8, 6.6],  // Mar
            [6.5, 6.8, 7.0, 6.9],  // Apr
            [6.8, 7.0, 7.3, 7.1],  // May
            [7.0, 7.3, 7.5, 7.4],  // Jun
            [7.2, 7.5, 7.7, 7.6],  // Jul
            [7.4, 7.6, 7.8, 7.7],  // Aug
            [7.5, 7.7, 7.8, 7.7],  // Sep
            [7.6, 7.8, 7.9, 7.8],  // Oct
            [6.5, 7.2, 8.0, 7.6],  // Nov (current) - High score is 8.0
        ],
        "Paragraphs": [
            [5.0, 5.3, 5.5, 5.4],  // Jan
            [5.5, 5.8, 6.0, 5.9],  // Feb
            [5.8, 6.0, 6.2, 6.1],  // Mar
            [6.0, 6.3, 6.4, 6.3],  // Apr
            [6.3, 6.5, 6.7, 6.6],  // May
            [6.5, 6.7, 6.9, 6.8],  // Jun
            [6.7, 6.9, 7.1, 7.0],  // Jul
            [6.9, 7.1, 7.3, 7.2],  // Aug
            [7.0, 7.2, 7.4, 7.3],  // Sep
            [7.1, 7.3, 7.4, 7.3],  // Oct
            [6.0, 6.8, 7.5, 7.0],  // Nov (current) - High score is 7.5
        ],
    ]
    
    private let weekLabels = ["Week 1", "Week 2", "Week 3", "Week 4"]
    
    private let monthNames = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November"
    ]
    private let monthShort = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov"
    ]
    
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
                        .padding(.bottom, exercise == .prolongedSpeech ? 14 : 22)
                    
                    // Prolonged Speech category picker (affects entire screen)
                    if exercise == .prolongedSpeech {
                        prolongedCategoryPicker
                            .padding(.horizontal, 24)
                            .padding(.bottom, 18)
                    }
                    
                    // Content Cards
                    VStack(spacing: 20) {
                        // 1. High Score Card
                        highScoreCard

                        // 2. Exercise Progress Card (Line Chart)
                        exerciseProgressCard
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 36)
                }
            }
            .scrollIndicators(.hidden)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            updateSelectedWeek()
            withAnimation(.spring(response: 0.52, dampingFraction: 0.82)) {
                didAppearContent = true
            }
        }
    }
    
    // MARK: - Top Header Image
    @ViewBuilder
    private var headerImageView: some View {
        Group {
            if let uiImage = UIImage(named: "Header") ?? UIImage(named: "header") ?? UIImage(named: "header 1") {
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
                state.navigate(to: .profile, forward: false)
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
            Group {
                if let uiImage = UIImage(named: exercise.iconName) ?? UIImage(contentsOfFile: Bundle.main.path(forResource: exercise.iconName, ofType: "png") ?? "") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(exercise.iconName)
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(width: 64, height: 64)
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Prolonged Speech Category Picker
    private var prolongedCategoryPicker: some View {
        HStack(spacing: 0) {
            ForEach(["Words", "Sentences", "Paragraphs"], id: \.self) { category in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        prolongedCategory = category
                        updateSelectedWeek()
                    }
                } label: {
                    Text(category)
                        .font(.system(size: 14, weight: prolongedCategory == category ? .bold : .medium, design: .rounded))
                        .foregroundStyle(
                            prolongedCategory == category
                            ? .white
                            : Color(red: 195 / 255, green: 190 / 255, blue: 220 / 255)
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            prolongedCategory == category
                            ? Color(red: 139 / 255, green: 112 / 255, blue: 245 / 255)
                            : Color.clear
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(Color.white.opacity(0.08))
        .clipShape(Capsule())
    }
    
    // MARK: - 1. High Score Card
    private var highScoreCard: some View {
        HStack(alignment: .center, spacing: 14) {
            // Trophy Asset (trophy.png)
            trophyIconView
                .frame(width: 44, height: 44)
            
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
    
    private func updateSelectedWeek() {
        let scores = currentMonthScores
        if let maxVal = scores.max(), let idx = scores.firstIndex(of: maxVal) {
            selectedWeekIndex = idx
        }
    }

    @ViewBuilder
    private var trophyIconView: some View {
        if let uiImage = loadTrophyImage() {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            Image("trophy")
                .resizable()
                .scaledToFit()
        }
    }
    
    private func loadTrophyImage() -> UIImage? {
        if let image = UIImage(named: "trophy") ?? UIImage(named: "trophy.png") {
            return image
        }
        if let path = Bundle.main.path(forResource: "trophy", ofType: "png"),
           let image = UIImage(contentsOfFile: path) {
            return image
        }
        if let path = Bundle.main.path(forResource: "pictures/trophy", ofType: "png"),
           let image = UIImage(contentsOfFile: path) {
            return image
        }
        if let url = Bundle.main.url(forResource: "trophy", withExtension: "png"),
           let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            return image
        }
        
        // Direct local disk fallback for Xcode Previews & Canvas
        let fileUrl = URL(fileURLWithPath: #filePath)
        let projectDir = fileUrl.deletingLastPathComponent()
        let directPath = projectDir.appendingPathComponent("trophy.png").path
        if let image = UIImage(contentsOfFile: directPath) {
            return image
        }
        let picturesPath = projectDir.appendingPathComponent("pictures/trophy.png").path
        if let image = UIImage(contentsOfFile: picturesPath) {
            return image
        }
        
        return nil
    }
    
    
    // MARK: - 2. Exercise Progress Card (Bar Chart)
    private var exerciseProgressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Top Row: Title + Month Picker
            HStack {
                Text("Exercise Progress")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 25 / 255, green: 22 / 255, blue: 45 / 255))
                
                Spacer()
                
                Menu {
                    ForEach(1...11, id: \.self) { month in
                        Button {
                            selectedMonth = month
                            updateSelectedWeek()
                        } label: {
                            HStack {
                                Text(monthNames[month - 1])
                                if month == selectedMonth {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(monthShort[selectedMonth - 1])
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundStyle(Color(red: 125 / 255, green: 90 / 255, blue: 230 / 255))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(Color(red: 238 / 255, green: 232 / 255, blue: 254 / 255))
                    .clipShape(Capsule())
                }
            }
            
            // Static Bar Chart matching screenshot
            WeeklyBarChart(
                scores: monthlyScores,
                labels: weekLabels,
                selectedIndex: $selectedWeekIndex
            )
            .padding(.top, 4)
            .padding(.bottom, 2)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(glassCardBackground(cornerRadius: 22))
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
    
    
// MARK: - Weekly Bar Chart (Dynamic score-based gradient intensity)
private struct WeeklyBarChart: View {
    let scores: [Double]
    let labels: [String]
    @Binding var selectedIndex: Int?
    
    private let maxBarHeight: CGFloat = 130
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 14) {
            ForEach(0..<min(scores.count, labels.count), id: \.self) { index in
                let score = scores[index]
                let isSelected = selectedIndex == index
                let barHeight = computeBarHeight(score: score)
                
                VStack(spacing: 8) {
                    // 1. Score above bar
                    Text(String(format: "%.1f", score))
                        .font(.system(size: 16, weight: isSelected ? .heavy : .bold, design: .rounded))
                        .foregroundStyle(Color(red: 25 / 255, green: 22 / 255, blue: 45 / 255))
                    
                    // 2. Rounded Vertical Bar (color intensity scales low to high according to the score)
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(barGradient(for: score))
                            .frame(height: barHeight)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(
                                        Color.white.opacity(isSelected ? 0.5 : 0),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(
                                color: Color(red: 130 / 255, green: 50 / 255, blue: 240 / 255).opacity(isSelected ? 0.3 : 0),
                                radius: 8,
                                x: 0,
                                y: 3
                            )
                    }
                    .frame(height: maxBarHeight, alignment: .bottom)
                    .frame(maxWidth: .infinity)
                    
                    // 3. Week Label
                    Text(labels[index])
                        .font(.system(size: 13, weight: isSelected ? .bold : .medium, design: .rounded))
                        .foregroundStyle(
                            isSelected
                            ? Color(red: 30 / 255, green: 20 / 255, blue: 60 / 255)
                            : Color(red: 115 / 255, green: 110 / 255, blue: 148 / 255)
                        )
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedIndex = index
                    }
                }
            }
        }
    }
    
    /// Maps score from light lavender (low score) to deep vibrant purple (high score)
    private func barGradient(for score: Double) -> LinearGradient {
        let minScore = scores.min() ?? 5.0
        let maxScore = scores.max() ?? 10.0
        let scoreRange = max(maxScore - minScore, 0.4)
        
        let relFactor = CGFloat(max(0.0, min(1.0, (score - minScore) / scoreRange)))
        let absFactor = CGFloat(max(0.0, min(1.0, (score - 5.0) / 4.8)))
        
        // Blend 65% relative (to ensure distinct shades within the month) and 35% absolute
        let t = 0.35 * absFactor + 0.65 * relFactor
        
        // Light (t = 0.0): gentle soft lavender
        // Dark  (t = 1.0): rich deep violet purple
        let topR = 230.0 + (168.0 - 230.0) * Double(t)
        let topG = 220.0 + (96.0 - 220.0) * Double(t)
        let topB = 255.0 + (255.0 - 255.0) * Double(t)
        
        let botR = 212.0 + (130.0 - 212.0) * Double(t)
        let botG = 196.0 + (48.0 - 196.0) * Double(t)
        let botB = 252.0 + (242.0 - 252.0) * Double(t)
        
        return LinearGradient(
            colors: [
                Color(red: topR / 255, green: topG / 255, blue: topB / 255),
                Color(red: botR / 255, green: botG / 255, blue: botB / 255)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private func computeBarHeight(score: Double) -> CGFloat {
        let minH: CGFloat = 58
        let factor = CGFloat(max(0.0, min(1.0, (score - 5.0) / 4.8)))
        return minH + (maxBarHeight - minH) * factor
    }
}

