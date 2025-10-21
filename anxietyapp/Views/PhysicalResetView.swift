//
//  PhysicalResetView.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct PhysicalResetView: View {
    @Environment(\.isDarkMode) var isDarkMode
    let navigateToDashboard: () -> Void
    @State private var isActive = false
    @State private var currentStepIndex = 0
    @State private var timeRemaining: Int = 0
    @State private var timer: Timer?
    @State private var showingSummary = false
    @Environment(\.dismiss) private var dismiss

    let steps = PhysicalExercise.unifiedReset.steps

    var currentStep: PhysicalResetStep {
        steps[currentStepIndex]
    }

    var isLastStep: Bool {
        currentStepIndex == steps.count - 1
    }

    var body: some View {
        VStack(spacing: 0) {
            if !isActive {
                // Intro screen
                introScreen
            } else {
                // Exercise sequence
                exerciseScreen
            }
        }
        .gradientBackground(AppGradient.adaptiveBackground(isDark: isDarkMode))
        .navigationBarHidden(true)
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    // Swipe from left edge to go back
                    if gesture.startLocation.x < 50 && gesture.translation.width > 100 {
                        HapticManager.shared.impact(.light)
                        dismiss()
                    }
                }
        )
        .sheet(isPresented: $showingSummary) {
            ReliefSummaryView(
                completedTechnique: "Physical Reset",
                onTryAnother: {
                    showingSummary = false
                    dismiss()
                },
                onFinish: {
                    showingSummary = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismiss()
                    }
                },
                navigateToDashboard: navigateToDashboard
            )
            .interactiveDismissDisabled()
        }
    }

    private var introScreen: some View {
        VStack(spacing: 0) {
            // Header with close button
            HStack {
                Button(action: {
                    HapticManager.shared.impact(.light)
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                }
                Spacer()
            }
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.top, DesignSystem.Spacing.small)
            .padding(.bottom, DesignSystem.Spacing.small)

            Spacer()

            VStack(spacing: 32) {
                Text("Reset your body\nfrom tension")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text("3-step sequence • 30 seconds")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))

                // Steps illustration
                stepsIllustration

                // Explanation text
                Text("Stand, tense, and release to break anxiety's physical grip.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                    .padding(.top, 8)
                    .multilineTextAlignment(.center)

                // Start button
                Button(action: {
                    HapticManager.shared.impact(.medium)
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isActive = true
                        startStep()
                    }
                }) {
                    HStack(spacing: 12) {
                        Text("Begin")
                            .font(.system(size: 17, weight: .bold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.primaryPurple)
                    )
                }
                .padding(.horizontal, DesignSystem.Spacing.large)
                .padding(.top, 8)
            }
            .padding(.horizontal, DesignSystem.Spacing.large)

            Spacer()
        }
    }

    private var exerciseScreen: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    HapticManager.shared.impact(.light)
                    stopTimer()
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.adaptiveSecondaryText(isDark: isDarkMode).opacity(0.1))
                        )
                }

                Spacer()
            }
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.top, DesignSystem.Spacing.small)
            .padding(.bottom, DesignSystem.Spacing.small)

            // Progress indicator
            HStack(spacing: 8) {
                ForEach(0..<steps.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentStepIndex ? currentStep.color : Color.adaptiveDivider(isDark: isDarkMode).opacity(0.3))
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.top, 16)

            Spacer()

            // Active step content
            activeStepContent

            Spacer()

            // Skip button
            skipButton
                .padding(.bottom, 72)
        }
    }

    private var stepsIllustration: some View {
        HStack(spacing: 20) {
            ForEach(Array(PhysicalExercise.unifiedReset.steps.enumerated()), id: \.element.id) { index, step in
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(step.color.opacity(0.15))
                            .frame(width: 56, height: 56)

                        Image(systemName: step.icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(step.color)
                            .symbolRenderingMode(.hierarchical)
                    }

                    Text(step.title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(step.color)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(width: 70)
                }
            }
        }
    }

    private var activeStepContent: some View {
        VStack(spacing: 48) {
            // Step title
            Text(currentStep.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

            // Timer circle
            ZStack {
                Circle()
                    .stroke(Color.adaptiveDivider(isDark: isDarkMode).opacity(0.3), lineWidth: 8)
                    .frame(width: 200, height: 200)

                Circle()
                    .trim(from: 0, to: CGFloat(Double(currentStep.duration - timeRemaining) / Double(currentStep.duration)))
                    .stroke(currentStep.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: timeRemaining)

                VStack {
                    Text("\(timeRemaining)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(currentStep.color)

                    Text("seconds")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                }
            }

            // Instructions
            Text(currentStep.instruction)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)
        }
    }

    private var skipButton: some View {
        Button(action: {
            HapticManager.shared.impact(.soft)
            stopTimer()
            showingSummary = true
        }) {
            Text("Skip")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                .frame(height: 48)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 24)
        .accessibilityLabel("Skip physical reset")
    }

    private func startStep() {
        timeRemaining = currentStep.duration

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                completeStep()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        timeRemaining = 0
    }

    private func completeStep() {
        stopTimer()

        // Haptic feedback
        HapticManager.shared.impact(.medium)

        if isLastStep {
            // Completed all steps
            showingSummary = true
            HapticManager.shared.notification(.success)
        } else {
            // Move to next step and start timer immediately
            currentStepIndex += 1
            startStep()
        }
    }
}

#Preview {
    PhysicalResetView(navigateToDashboard: {})
}
