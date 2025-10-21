//
//  OnboardingSetGoalsView.swift
//  anxietyapp
//
//  Created by Claude Code
//

import SwiftUI
import Combine

struct OnboardingSetGoalsView: View {
    @Binding var userProfile: UserProfile
    let onContinue: () -> Void

    let columns = [
        GridItem(.flexible(), spacing: DesignSystem.Spacing.small),
        GridItem(.flexible(), spacing: DesignSystem.Spacing.small)
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
                    // Header
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        Text("Let's set your goals")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.textDark)

                        Text("Choose what matters most to you")
                            .font(DesignSystem.Typography.bodyFont)
                            .foregroundColor(.textMedium)
                    }
                    .padding(.top, DesignSystem.Spacing.medium)

                    // Goals grid
                    LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.small) {
                        ForEach(UserGoal.allCases, id: \.self) { goal in
                            GoalCard(
                                goal: goal,
                                isSelected: userProfile.selectedGoals.contains(goal),
                                action: {
                                    if userProfile.selectedGoals.contains(goal) {
                                        userProfile.selectedGoals.removeAll { $0 == goal }
                                    } else {
                                        userProfile.selectedGoals.append(goal)
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(DesignSystem.Spacing.medium)
            }

            // Continue button
            if !userProfile.selectedGoals.isEmpty {
                OnboardingButton(title: "Track my goals", action: onContinue)
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    .padding(.bottom, DesignSystem.Spacing.medium)
            }
        }
        .gradientBackground()
    }
}

// MARK: - Goal Card Component
struct GoalCard: View {
    let goal: UserGoal
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.small) {
                // Icon
                Image(systemName: goal.icon)
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? goal.color : goal.color.opacity(0.6))
                    .frame(height: 50)

                // Text
                Text(goal.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textDark)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minHeight: 44)

                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? goal.color : .borderGray)
            }
            .padding(.vertical, DesignSystem.Spacing.medium)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .frame(maxWidth: .infinity)
            .background(isSelected ? goal.color.opacity(0.15) : goal.color.opacity(0.05))
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(isSelected ? goal.color : goal.color.opacity(0.3), lineWidth: 2)
            )
        }
    }
}

#Preview {
    OnboardingSetGoalsView(
        userProfile: .constant(UserProfile()),
        onContinue: {}
    )
}
