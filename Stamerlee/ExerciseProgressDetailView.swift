import SwiftUI
import UIKit

// MARK: - Exercise Progress Detail View
/// Detailed progress analytics screen for an individual exercise (Picture Description, Prolonged Speech, Dial Scene, Narration).
/// Matches the high-score trophy card, weekly curved progress chart, progress overview card, and Practice Again CTA.
public struct ExerciseProgressDetailView: View {
    @Bindable public var state: AppState
    @State private var didAppearContent = false
    @State private var selectedWeekIndex: Int? = 2 // Default to Week 3 (highest, matching reference)
    
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
    
    private var monthlyScores: [Double] {
        var scores = exercise.monthlyWeekScores
        if exercise == .prolongedSpeech, let score = state.prolongedEasyScore, score > 0 {
            scores[scores.count - 1] = score
        }
        return scores
    }
    
    private let weekLabels = ["Week 1", "Week 2", "Week 3", "Week 4"]
    
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
            // Top Row: Title + Weekly Pill
            HStack {
                Text("Exercise Progress")
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
    
    // MARK: - 3. Progress Overview Section
    private var progressOverviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress overview")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            HStack(spacing: 16) {
                // Purple Circular Star Badge
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 135 / 255, green: 80 / 255, blue: 245 / 255),
                                    Color(red: 95 / 255, green: 45 / 255, blue: 215 / 255)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .shadow(color: Color(red: 135 / 255, green: 80 / 255, blue: 245 / 255).opacity(0.4), radius: 8, x: 0, y: 3)

                    Image(systemName: "star.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.overviewTitle)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 25 / 255, green: 20 / 255, blue: 45 / 255))

                    Text(exercise.overviewSubtitle)
                        .font(.system(size: 13.5, weight: .regular, design: .rounded))
                        .foregroundStyle(Color(red: 110 / 255, green: 90 / 255, blue: 180 / 255))
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
    
    
// MARK: - Weekly Bar Chart (Static)
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
                    // 1. Score above bar (Static)
                    Text(String(format: "%.1f", score))
                        .font(.system(size: 16, weight: isSelected ? .heavy : .bold, design: .rounded))
                        .foregroundStyle(Color(red: 25 / 255, green: 22 / 255, blue: 45 / 255))
                    
                    // 2. Rounded Vertical Bar (Static)
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                isSelected
                                ? LinearGradient(
                                    colors: [
                                        Color(red: 172 / 255, green: 104 / 255, blue: 255 / 255),
                                        Color(red: 133 / 255, green: 54 / 255, blue: 242 / 255)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                : LinearGradient(
                                    colors: [
                                        Color(red: 216 / 255, green: 196 / 255, blue: 254 / 255),
                                        Color(red: 198 / 255, green: 175 / 255, blue: 252 / 255)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: barHeight)
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
    
    private func computeBarHeight(score: Double) -> CGFloat {
        let clamped = max(6.5, min(10.0, score))
        let minH: CGFloat = 84
        let factor = CGFloat(max(0.0, min(1.0, (clamped - 7.0) / 2.3)))
        return minH + (maxBarHeight - minH) * factor
    }
}

