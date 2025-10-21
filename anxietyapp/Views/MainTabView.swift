//
//  MainTabView.swift
//  anxietyapp
//
//  Custom navigation bar from scratch - no default animations
//

import SwiftUI

struct MainTabView: View {
    @Environment(\.isDarkMode) var isDarkMode
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var selectedTab = 0
    @State private var showMoodCheckIn = false
    @State private var showDailyQuote = false
    @State private var showSOSFlow = false
    @ObservedObject private var notificationService = NotificationService.shared

    var body: some View {
        ZStack {
            // Content area
            Group {
                switch selectedTab {
                case 0:
                    DashboardView(
                        onNavigateToStats: {
                            selectedTab = 3
                        },
                        showMoodCheckIn: $showMoodCheckIn,
                        showDailyQuote: $showDailyQuote
                    )
                case 1:
                    NavigationStack {
                        TechniquesView(selectedTab: $selectedTab)
                    }
                case 2:
                    AffirmationsView()
                case 3:
                    StatsView()
                default:
                    DashboardView(
                        onNavigateToStats: {
                            selectedTab = 3
                        },
                        showMoodCheckIn: $showMoodCheckIn,
                        showDailyQuote: $showDailyQuote
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom bottom navigation bar
            VStack {
                Spacer()

                customNavBar
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .fullScreenCover(isPresented: $showSOSFlow) {
            UnifiedSOSFlowView(navigateToDashboard: {
                showSOSFlow = false
                navigationManager.dismissSOS()
            })
        }
        .onReceive(notificationService.$selectedNotificationAction) { action in
            guard let action = action else { return }

            switch action {
            case .openMoodCheckIn:
                // Navigate to  home tab and trigger mood check-in
                selectedTab = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showMoodCheckIn = true
                }
                // Clear the action
                notificationService.selectedNotificationAction = nil

            case .openDailyQuote:
                // Navigate to home tab and show daily quote popup
                selectedTab = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showDailyQuote = true
                }
                // Clear the action
                notificationService.selectedNotificationAction = nil
            }
        }
        .onReceive(navigationManager.$shouldShowSOS) { shouldShow in
            if shouldShow {
                // Navigate to home tab first
                selectedTab = 0
                // Show SOS flow
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    showSOSFlow = true
                }
            }
        }
    }

    // MARK: - Custom Navigation Bar
    private var customNavBar: some View {
        HStack(spacing: 0) {
            // Home
            NavBarItem(
                icon: "house.fill",
                title: "Home",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }

            // Techniques
            NavBarItem(
                icon: "wand.and.stars",
                title: "Techniques",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }

            // Affirmations
            NavBarItem(
                icon: "heart.fill",
                title: "Affirmations",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }

            // Stats
            NavBarItem(
                icon: "chart.bar.fill",
                title: "Stats",
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(
            Color.adaptiveBackground(isDark: isDarkMode)
                .shadow(color: Color.black.opacity(isDarkMode ? 0.5 : 0.05), radius: 8, x: 0, y: -2)
        )
    }
}

// MARK: - Custom Nav Bar Item
struct NavBarItem: View {
    @Environment(\.isDarkMode) var isDarkMode
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color.primaryPurple : Color.adaptiveTertiaryText(isDark: isDarkMode))

                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color.primaryPurple : Color.adaptiveTertiaryText(isDark: isDarkMode))
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MainTabView()
        .environmentObject(ThemeManager())
}
