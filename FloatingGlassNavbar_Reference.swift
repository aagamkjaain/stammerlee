import SwiftUI

// MARK: - Reusable Floating Glass Navbar Reference
// Source: branch `ui-changes` (commit 17c20cf)
// Use this exact implementation for DashboardTabView whenever you need the floating glass navbar on any branch.

public struct DashboardTabView: View {
    @Bindable public var state: AppState
    public var profileNamespace: Namespace.ID? = nil

    public init(state: AppState, profileNamespace: Namespace.ID? = nil) {
        self.state = state
        self.profileNamespace = profileNamespace
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Contents
            Group {
                switch state.selectedTab {
                case .home:
                    HomeDashboardView(state: state, profileNamespace: profileNamespace)
                case .summary:
                    SummaryView(state: state)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Floating Glass Navbar
            floatingGlassTabBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .preferredColorScheme(.dark)
    }

    // MARK: - Floating Glass Navbar
    private var floatingGlassTabBar: some View {
        HStack(spacing: 8) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                let isSelected = state.selectedTab == tab
                Button {
                    state.selectTab(tab)
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: tab.systemImage)
                            .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                        Text(tab.title)
                            .font(.system(size: 11, weight: isSelected ? .semibold : .regular, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundStyle(isSelected ? StamerleeTheme.primaryBlue : Color.white.opacity(0.80))
                    .background {
                        if #available(iOS 26.0, *), isSelected {
                            Capsule()
                                .fill(.clear)
                                .glassEffect(.regular.tint(StamerleeTheme.primaryBlue.opacity(0.25)).interactive(), in: .capsule)
                        } else if isSelected {
                            Capsule()
                                .fill(StamerleeTheme.primaryBlue.opacity(0.20))
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay {
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.30),
                            Color.white.opacity(0.10)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .shadow(color: Color.black.opacity(0.35), radius: 18, x: 0, y: 9)
        .padding(.horizontal, 24)
        .padding(.bottom, 10)
        .sensoryFeedback(.selection, trigger: state.selectedTab)
    }
}

