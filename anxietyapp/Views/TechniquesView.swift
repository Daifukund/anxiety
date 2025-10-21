//
//  TechniquesView.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import SwiftUI

struct TechniquesView: View {
    @Environment(\.isDarkMode) var isDarkMode
    @Binding var selectedTab: Int

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerSection

                techniquesList

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .gradientBackground(AppGradient.adaptiveBackground(isDark: isDarkMode))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        VStack(alignment: .center, spacing: 6) {
            Text("Relief Techniques")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

            Text("Science-backed tools for calm")
                .font(.system(size: 14))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 32)
        .padding(.bottom, 16)
    }

    private var techniquesList: some View {
        VStack(spacing: 12) {
            NavigationLink(destination: BreathingExerciseView(navigateToDashboard: { selectedTab = 0 })) {
                TechniqueListItemContent(
                    icon: "wind",
                    title: "Breathing",
                    subtitle: "Instant calming",
                    color: Color(red: 0.40, green: 0.70, blue: 0.95)
                )
            }
            .buttonStyle(PlainButtonStyle())

            NavigationLink(destination: GroundingExerciseView(navigateToDashboard: { selectedTab = 0 })) {
                TechniqueListItemContent(
                    icon: "leaf.fill",
                    title: "Grounding",
                    subtitle: "Break racing thoughts",
                    color: Color(red: 0.45, green: 0.75, blue: 0.55)
                )
            }
            .buttonStyle(PlainButtonStyle())

            NavigationLink(destination: PhysicalResetView(navigateToDashboard: { selectedTab = 0 })) {
                TechniqueListItemContent(
                    icon: "bolt.fill",
                    title: "Physical Reset",
                    subtitle: "Release tension fast",
                    color: Color(red: 0.95, green: 0.65, blue: 0.35)
                )
            }
            .buttonStyle(PlainButtonStyle())

            NavigationLink(destination: PerspectiveShiftView(navigateToDashboard: { selectedTab = 0 })) {
                TechniqueListItemContent(
                    icon: "sparkles",
                    title: "Zoom Out",
                    subtitle: "Shift perspective",
                    color: Color(red: 0.75, green: 0.60, blue: 0.90)
                )
            }
            .buttonStyle(PlainButtonStyle())

            NavigationLink(destination: QuickJournalView(navigateToDashboard: { selectedTab = 0 })) {
                TechniqueListItemContent(
                    icon: "pencil.line",
                    title: "Quick Dump",
                    subtitle: "Empty thoughts in 60s",
                    color: Color(red: 0.95, green: 0.55, blue: 0.65)
                )
            }
            .buttonStyle(PlainButtonStyle())

            NavigationLink(destination: ReframeStressView(navigateToDashboard: { selectedTab = 0 })) {
                TechniqueListItemContent(
                    icon: "brain.head.profile",
                    title: "Reframe Stress",
                    subtitle: "Change the story",
                    color: Color(red: 0.55, green: 0.70, blue: 0.95)
                )
            }
            .buttonStyle(PlainButtonStyle())

            NavigationLink(destination: EmotionResetView(navigateToDashboard: { selectedTab = 0 })) {
                TechniqueListItemContent(
                    icon: "heart.text.square.fill",
                    title: "Emotion Reset",
                    subtitle: "Heal, release, and grow",
                    color: Color(red: 0.85, green: 0.45, blue: 0.75)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// Compact list item content for techniques (used with NavigationLink)
struct TechniqueListItemContent: View {
    @Environment(\.isDarkMode) var isDarkMode
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(color)
                )

            // Text content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode).opacity(0.4))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isDarkMode ? Color.adaptiveSecondaryBackground(isDark: true).opacity(0.8) : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isDarkMode ? Color.clear : Color.black.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(isDarkMode ? 0.3 : 0.12), radius: 12, x: 0, y: 4)
    }
}

#Preview {
    TechniquesView(selectedTab: .constant(1))
}
