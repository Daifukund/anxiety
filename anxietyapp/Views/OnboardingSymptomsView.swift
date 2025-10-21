//
//  OnboardingSymptomsView.swift
//  anxietyapp
//
//  Created by Claude Code
//

import SwiftUI
import Combine

struct OnboardingSymptomsView: View {
    @Binding var userProfile: UserProfile
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
                    // Header
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        Text("Which of these do you experience most often?")
                            .font(DesignSystem.Typography.questionTitle)
                            .foregroundColor(.textDark)

                        Text("Choose all that apply")
                            .font(DesignSystem.Typography.helperText)
                            .foregroundColor(.textLight)
                    }
                    .padding(.top, DesignSystem.Spacing.medium)

                    // Symptoms list
                    VStack(spacing: DesignSystem.Spacing.small) {
                        ForEach(Symptom.allCases, id: \.self) { symptom in
                            MultiSelectionCard(
                                title: symptom.rawValue,
                                isSelected: userProfile.symptoms.contains(symptom),
                                action: {
                                    if userProfile.symptoms.contains(symptom) {
                                        userProfile.symptoms.removeAll { $0 == symptom }
                                    } else {
                                        userProfile.symptoms.append(symptom)
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(DesignSystem.Spacing.medium)
            }

            // Continue button
            if !userProfile.symptoms.isEmpty {
                OnboardingButton(title: "Continue", action: onContinue)
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    .padding(.bottom, DesignSystem.Spacing.medium)
            }
        }
        .gradientBackground()
    }
}

#Preview {
    OnboardingSymptomsView(
        userProfile: .constant(UserProfile()),
        onContinue: {}
    )
}
