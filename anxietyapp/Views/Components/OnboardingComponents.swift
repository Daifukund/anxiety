//
//  OnboardingComponents.swift
//  anxietyapp
//
//  Created by Claude Code
//

import SwiftUI

// Selection Card (for quiz options)
struct SelectionCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var isDisabled: Bool = false

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(DesignSystem.Typography.answerText)
                    .foregroundColor(.textDark)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.primaryPurple)
                        .font(.system(size: 24))
                }
            }
            .padding(DesignSystem.Spacing.small)
            .background(isSelected ? Color.secondaryViolet : Color.white)
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(isSelected ? Color.primaryPurple : Color.borderGray, lineWidth: 2)
            )
            .opacity(isDisabled && !isSelected ? 0.5 : 1.0)
        }
        .disabled(isDisabled)
    }
}

// Multi-Selection Card (for symptoms, goals, etc.)
struct MultiSelectionCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var icon: String? = nil

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.small) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .primaryPurple : .borderGray)
                    .font(.system(size: 24))

                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(isSelected ? .primaryPurple : .textMedium)
                        .font(.system(size: 20))
                }

                Text(title)
                    .font(DesignSystem.Typography.answerText)
                    .foregroundColor(.textDark)
                Spacer()
            }
            .padding(DesignSystem.Spacing.small)
            .background(isSelected ? Color.secondaryViolet : Color.white)
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(isSelected ? Color.primaryPurple : Color.borderGray, lineWidth: 2)
            )
        }
    }
}

// Progress Bar
struct ProgressBar: View {
    let current: Int
    let total: Int

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.borderGray)
                    .frame(height: 4)
                    .cornerRadius(2)

                Rectangle()
                    .fill(Color.primaryPurple)
                    .frame(width: geometry.size.width * CGFloat(current) / CGFloat(total), height: 4)
                    .cornerRadius(2)
            }
        }
        .frame(height: 4)
    }
}

// Star Rating View with Laurel Leaves
struct StarRating: View {
    let count: Int

    var body: some View {
        HStack(spacing: 8) {
            // Left laurel leaf
            Image(systemName: "laurel.leading")
                .foregroundColor(.yellow)
                .font(.system(size: 24))

            // Stars
            HStack(spacing: 4) {
                ForEach(0..<count, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 20))
                }
            }

            // Right laurel leaf
            Image(systemName: "laurel.trailing")
                .foregroundColor(.yellow)
                .font(.system(size: 24))
        }
    }
}

// Full-width Primary Button for onboarding
struct OnboardingButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignSystem.Typography.button)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: DesignSystem.ButtonHeight.primary)
                .background(isEnabled ? Color.primaryPurple : Color.disabledBackground)
                .cornerRadius(DesignSystem.CornerRadius.pill)
        }
        .disabled(!isEnabled)
    }
}

// Secondary Button (Outline Style)
struct OnboardingSecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignSystem.Typography.button)
                .foregroundColor(.primaryPurple)
                .frame(maxWidth: .infinity)
                .frame(height: DesignSystem.ButtonHeight.primary)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.pill)
                        .stroke(Color.primaryPurple, lineWidth: 2)
                )
        }
    }
}
