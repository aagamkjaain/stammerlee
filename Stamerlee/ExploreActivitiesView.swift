import SwiftUI

// MARK: - Explore Activities View (Screenshot 1)
/// Screen showcasing speech activities tailored to the user's stutter patterns.
public struct ExploreActivitiesView: View {
    @Bindable public var state: AppState
    
    public init(state: AppState) {
        self.state = state
    }
    
    private struct ActivityCardItem: Identifiable {
        let id: String
        let iconName: String
        let fallbackFile: String
        let text: String
    }
    
    private let activities: [ActivityCardItem] = [
        ActivityCardItem(
            id: "prolonged",
            iconName: "IconProlongedSpeech",
            fallbackFile: "/Users/user89/Documents/bitch/Screenshot_2026-10-21_at_11.26.10_PM-removebg-preview 2.png",
            text: "Learn smooth pacing with prolonged speech and continuous airflow exercises"
        ),
        ActivityCardItem(
            id: "picture",
            iconName: "IconPictureDesc",
            fallbackFile: "/Users/user89/Documents/bitch/Screenshot_2026-10-21_at_11.46.28_PM-removebg-preview 2.png",
            text: "Build spontaneous fluency with picture description"
        ),
        ActivityCardItem(
            id: "dial",
            iconName: "IconDialScene",
            fallbackFile: "/Users/user89/Documents/bitch/Firefly_RemoveBackground 2.png",
            text: "Simulate phone calls using dial scene to build conversational confidence"
        ),
        ActivityCardItem(
            id: "mirror",
            iconName: "IconMirrorNarration",
            fallbackFile: "/Users/user89/Documents/bitch/Screenshot_2026-10-21_at_11.35.41_PM-removebg-preview 2.png",
            text: "Monitor your physical tension during narration with mirror exercises"
        )
    ]
    
    public var body: some View {
        ZStack {
            // Dark Background
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Top Navigation Bar
                HStack {
                    BackNavButton {
                        state.navigate(to: .challengingSounds, forward: false)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Screen Title
                Text("Explore activities\ndesigned for your\nstutter")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.textPrimaryDark)
                    .lineSpacing(3)
                    .padding(.horizontal, 24)
                    .padding(.top, 22)
                    .padding(.bottom, 22)
                
                // Activities List
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(activities) { item in
                            activityCard(item)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
                
                Spacer()
                
                // Bottom CTA Button ("Continue")
                VStack {
                    PrimaryActionButton(title: "Continue") {
                        state.navigate(to: .homeDashboard)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
    
    // MARK: - Activity Card
    private func activityCard(_ item: ActivityCardItem) -> some View {
        HStack(spacing: 16) {
            // Activity Icon from user's uploaded assets
            Group {
                if let uiImage = StamerleeImageLoader.loadHeroImage(name: item.iconName, fallbackPath: item.fallbackFile) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                } else {
                    Circle()
                        .fill(StamerleeTheme.accentPurple.opacity(0.2))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "sparkles")
                                .foregroundColor(StamerleeTheme.primaryBlue)
                        )
                }
            }
            .frame(width: 48, height: 48)
            
            // Description Text
            Text(item.text)
                .font(.system(size: 13.5, weight: .semibold, design: .rounded))
                .foregroundColor(StamerleeTheme.textPrimaryLight)
                .lineSpacing(2.5)
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(red: 238 / 255, green: 240 / 255, blue: 250 / 255) // Pale periwinkle/lavender matching screenshot
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}
