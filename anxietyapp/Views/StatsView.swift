//
//  StatsView.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import SwiftUI

struct StatsView: View {
    @Environment(\.isDarkMode) var isDarkMode
    @ObservedObject private var userDataService = UserDataService.shared

    var body: some View {
        ZStack {
            // Background gradient
            AppGradient.adaptiveBackground(isDark: isDarkMode)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                        .padding(.top, 16)

                    // Key stats cards
                    statsCardsSection

                    // Monthly mood chart
                    WeeklyMoodChart()

                    // Medical disclaimer
                    Text("This is for personal tracking only and not medical advice. Consult a healthcare professional for diagnosis or treatment.")
                        .font(.system(size: 11))
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode).opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Your Progress")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

            Text("Track your wellness journey")
                .font(.system(size: 15))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
    }

    private var statsCardsSection: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            StatCard(
                title: "Current Streak",
                value: "\(userDataService.userStats.currentStreak)",
                subtitle: "days",
                icon: "flame.fill",
                color: Color.warning
            )

            StatCard(
                title: "Total Sessions",
                value: "\(userDataService.userStats.totalSessions)",
                subtitle: "completed",
                icon: "heart.fill",
                color: Color.sosRed
            )
        }
    }

}

struct StatCard: View {
    @Environment(\.isDarkMode) var isDarkMode
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            // Icon with colored background
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }

            // Value and subtitle
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(color)
            }

            // Title
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: isDarkMode ? [
                            Color.adaptiveSecondaryBackground(isDark: true).opacity(0.6),
                            Color.adaptiveSecondaryBackground(isDark: true).opacity(0.4)
                        ] : [
                            Color.white.opacity(0.95),
                            Color.white.opacity(0.85)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isDarkMode ? Color.adaptiveDivider(isDark: true).opacity(0.3) : Color.white.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(isDarkMode ? 0.3 : 0.08), radius: 12, x: 0, y: 6)
    }
}

#Preview {
    StatsView()
}