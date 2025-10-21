//
//  OnboardingReminderSetupView.swift
//  anxietyapp
//
//  Created by Claude Code
//

import SwiftUI
import Combine

struct OnboardingReminderSetupView: View {
    @Binding var userProfile: UserProfile
    let onContinue: () -> Void

    @State private var selectedTime: Date = {
        // Default to 8:00 PM (20:00) - research shows evening has highest completion rates
        var components = DateComponents()
        components.hour = 20
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    @State private var enableReminders = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                            // Header
                            VStack(spacing: DesignSystem.Spacing.small) {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.primaryPurple)

                                Text("Set Your Daily Mood Check-In")
                                    .font(DesignSystem.Typography.questionTitle)
                                    .foregroundColor(.textDark)
                                    .multilineTextAlignment(.center)

                                Text("Users who track their mood daily are 3x more likely to reduce anxiety")
                                    .font(.system(size: 15))
                                    .foregroundColor(.textMedium)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 4)
                            }
                            .padding(.top, DesignSystem.Spacing.xl)
                            .padding(.horizontal, DesignSystem.Spacing.large)

                            // Benefits list
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                                BenefitRow(icon: "checkmark.circle.fill", text: "Build consistent tracking habits")
                                BenefitRow(icon: "checkmark.circle.fill", text: "Monitor your progress over time")
                                BenefitRow(icon: "checkmark.circle.fill", text: "Stay accountable to yourself")
                            }
                            .padding(.horizontal, DesignSystem.Spacing.large)

                            // Time picker section
                            VStack(spacing: DesignSystem.Spacing.medium) {
                                // Custom flat toggle
                                HStack {
                                    Text("Enable daily mood check-in reminder")
                                        .font(DesignSystem.Typography.bodyFont)
                                        .foregroundColor(.textDark)

                                    Spacer()

                                    // Custom flat toggle button
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            enableReminders.toggle()
                                        }
                                    }) {
                                        ZStack {
                                            // Background track
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(enableReminders ? Color.accentViolet : Color.gray.opacity(0.3))
                                                .frame(width: 51, height: 31)

                                            // Sliding circle
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 27, height: 27)
                                                .offset(x: enableReminders ? 10 : -10)
                                        }
                                    }
                                }
                                .padding(.horizontal, DesignSystem.Spacing.medium)

                                if enableReminders {
                                    // Custom flat time picker container
                                    HStack {
                                        Text("Reminder time")
                                            .font(DesignSystem.Typography.bodyFont)
                                            .foregroundColor(.textMedium)

                                        Spacer()

                                        // Flat time display button
                                        DatePicker(
                                            "",
                                            selection: $selectedTime,
                                            displayedComponents: .hourAndMinute
                                        )
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .accentColor(.accentViolet)
                                        .onChange(of: selectedTime) { newValue in
                                            userProfile.notificationTime = newValue
                                        }
                                    }
                                    .padding(DesignSystem.Spacing.medium)
                                    .background(
                                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                            .fill(Color(red: 0.95, green: 0.95, blue: 0.98))
                                    )
                                    .padding(.horizontal, DesignSystem.Spacing.medium)
                                }
                            }
                            .padding(.vertical, DesignSystem.Spacing.medium)
                        }
                    }

                    // Buttons - Fixed to bottom
                    VStack(spacing: DesignSystem.Spacing.small) {
                        OnboardingButton(
                            title: enableReminders ? "Enable Reminder" : "Continue",
                            action: {
                                if enableReminders {
                                    userProfile.notificationTime = selectedTime
                                } else {
                                    userProfile.notificationTime = nil
                                }
                                onContinue()
                            }
                        )

                        Button(action: {
                            userProfile.notificationTime = nil
                            onContinue()
                        }) {
                            Text("Maybe later")
                                .font(DesignSystem.Typography.button)
                                .foregroundColor(.textLight)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    .padding(.bottom, DesignSystem.Spacing.medium)
                }
            }
        }
    }


// MARK: - Benefit Row Component
struct BenefitRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.primaryPurple)

            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.textDark)

            Spacer()
        }
    }
}

#Preview {
    OnboardingReminderSetupView(
        userProfile: .constant(UserProfile()),
        onContinue: {}
    )
}
