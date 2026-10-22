import SwiftUI

// MARK: - Challenging Sounds View (Screenshot 5)
/// Selection card for identifying specific stuttering phonemes & sound challenges.
public struct ChallengingSoundsView: View {
    @Bindable public var state: AppState
    
    @State private var options = SoundOption.sampleOptions
    @FocusState private var isCustomFieldFocused: Bool
    
    public init(state: AppState) {
        self.state = state
    }
    
    public var body: some View {
        ZStack {
            // Dark Background
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Top Bar with Circular Back Navigation
                HStack {
                    BackNavButton {
                        state.navigate(to: .onboarding2, forward: false)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Screen Title
                Text("Challenging\nSounds")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.textPrimaryDark)
                    .lineSpacing(2)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 28)
                
                // Main Content Card (White with Rounded Corners)
                VStack(alignment: .leading, spacing: 0) {
                    // Question Header
                    Text("What are the sounds you stutter on?")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryLight)
                        .padding(.horizontal, 20)
                        .padding(.top, 22)
                        .padding(.bottom, 14)
                    
                    // Options List
                    VStack(spacing: 0) {
                        ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                            OptionSelectRow(
                                option: option,
                                isSelected: state.isSoundSelected(id: option.id)
                            ) {
                                state.toggleSound(id: option.id)
                            }
                            
                            // Custom input field if "Something else" is selected
                            if option.isCustom && state.isSoundSelected(id: option.id) {
                                HStack(spacing: 10) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(StamerleeTheme.primaryBlue)
                                    
                                    TextField("e.g. S, R, or specific vowels...", text: $state.customSoundInput)
                                        .font(.system(size: 14))
                                        .focused($isCustomFieldFocused)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color(red: 245 / 255, green: 247 / 255, blue: 252 / 255))
                                .cornerRadius(10)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                            
                            // Separator line (except for last item)
                            if index < options.count - 1 {
                                Divider()
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.bottom, 10)
                }
                .background(StamerleeTheme.cardLight)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: Color.black.opacity(0.18), radius: 16, x: 0, y: 8)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Bottom CTA Button ("Continue")
                VStack {
                    PrimaryActionButton(
                        title: "Continue",
                        isEnabled: !state.selectedSoundIds.isEmpty
                    ) {
                        state.navigate(to: .exploreActivities)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}
