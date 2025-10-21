//
//  GroundingExerciseView.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import SwiftUI

struct GroundingExerciseView: View {
    @Environment(\.isDarkMode) var isDarkMode
    let navigateToDashboard: () -> Void
    @StateObject private var viewModel = GroundingViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var contentScale: CGFloat = 0.95
    @State private var contentOpacity: Double = 0
    @State private var pulseAnimation: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main content - independent layout
                VStack(spacing: 0) {
                    Spacer()

                    if !viewModel.isActive {
                        // Start screen content
                        startContent
                    } else {
                        // Main content - centered
                        VStack(spacing: DesignSystem.Spacing.xl) {
                            // Progress indicators
                            compactProgressSection

                            if !viewModel.isCompleted {
                                // Main content area
                                compactGroundingContent
                                    .scaleEffect(contentScale)
                                    .opacity(contentOpacity)
                                    .padding(.horizontal, DesignSystem.Spacing.large)
                            }
                        }
                    }

                    Spacer()

                    // Skip button at bottom - only during exercise
                    if viewModel.isActive {
                        skipButton
                            .padding(.bottom, 72) // 8px * 9
                    }
                }
                .padding(.top, 60) // Space for header
                .frame(width: geometry.size.width, height: geometry.size.height)

                // Header - ABSOLUTE POSITIONING at top-left
                Button(action: {
                    HapticManager.shared.impact(.light)
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                }
                .position(
                    x: DesignSystem.Spacing.medium + 16, // padding + half button width
                    y: geometry.safeAreaInsets.top + DesignSystem.Spacing.small + 16 // safe area + padding + half button height
                )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
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
        .sheet(isPresented: $viewModel.showingSummary) {
            ReliefSummaryView(
                completedTechnique: "5-4-3-2-1 Grounding",
                onTryAnother: {
                    viewModel.reset()
                    dismiss()
                },
                onFinish: {
                    viewModel.showingSummary = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismiss()
                    }
                },
                navigateToDashboard: navigateToDashboard
            )
            .interactiveDismissDisabled()
        }
        .onAppear {
            animateContentIn()
            startPulseAnimation()
        }
        .onChange(of: viewModel.currentStepIndex) { _ in
            animateContentTransition()
        }
    }

    // MARK: - Start Content
    private var startContent: some View {
        VStack(spacing: 32) {
                Text("Ground yourself\nin the present")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text("5-4-3-2-1 sensory technique • 2 minutes")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))

                // Five senses illustration
                sensesIllustration

                // Explanation text
                Text("Use your five senses to reconnect with the present moment.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                    .padding(.top, 8)
                    .multilineTextAlignment(.center)

                // Start button
                Button(action: {
                    HapticManager.shared.impact(.medium)
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        viewModel.start()
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
                .padding(.top, 8)
        }
        .padding(.horizontal, DesignSystem.Spacing.large)
    }

    private var sensesIllustration: some View {
        HStack(spacing: 16) {
            ForEach(GroundingStep.allSteps) { step in
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(step.color.opacity(0.15))
                            .frame(width: 48, height: 48)

                        Image(systemName: step.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(step.color)
                            .symbolRenderingMode(.hierarchical)
                    }

                    Text("\(step.number)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(step.color)
                }
            }
        }
    }

    private var compactProgressSection: some View {
        HStack(spacing: 10) {
            ForEach(0..<5) { index in
                ZStack {
                    // Background circle
                    Circle()
                        .fill(
                            viewModel.completedSteps.contains(index) ?
                            GroundingStep.allSteps[index].color.opacity(0.2) :
                            Color.secondaryText.opacity(0.15)
                        )
                        .frame(width: index == viewModel.currentStepIndex ? 36 : 32,
                               height: index == viewModel.currentStepIndex ? 36 : 32)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    index == viewModel.currentStepIndex ?
                                    GroundingStep.allSteps[index].color :
                                    Color.clear,
                                    lineWidth: 2
                                )
                        )

                    // Icon
                    if viewModel.completedSteps.contains(index) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(GroundingStep.allSteps[index].color)
                    } else {
                        Image(systemName: GroundingStep.allSteps[index].icon)
                            .font(.system(size: index == viewModel.currentStepIndex ? 16 : 14, weight: .semibold))
                            .foregroundColor(
                                index == viewModel.currentStepIndex ?
                                GroundingStep.allSteps[index].color :
                                Color.adaptiveSecondaryText(isDark: isDarkMode).opacity(0.5)
                            )
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.currentStepIndex)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.completedSteps.count)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.medium)
    }

    private var compactGroundingContent: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Main prompt - centered and large
            VStack(spacing: DesignSystem.Spacing.medium) {
                // Large icon
                ZStack {
                    Circle()
                        .fill(viewModel.currentStep.color.opacity(0.15))
                        .frame(width: 80, height: 80)
                        .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                        .opacity(pulseAnimation ? 0.7 : 1.0)

                    Image(systemName: viewModel.currentStep.icon)
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(viewModel.currentStep.color)
                        .symbolRenderingMode(.hierarchical)
                }

                // Number and sense
                VStack(spacing: 8) {
                    Text("\(viewModel.currentStep.number)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(viewModel.currentStep.color)

                    Text(viewModel.currentStep.sense)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                        .multilineTextAlignment(.center)

                    Text(viewModel.currentStep.instruction)
                        .font(.system(size: 15))
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignSystem.Spacing.small)
                }
            }
            .frame(maxWidth: .infinity)

            // Checkboxes
            compactCheckboxesSection
        }
    }

    private var compactCheckboxesSection: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            // Horizontal checkboxes
            HStack(spacing: DesignSystem.Spacing.medium) {
                ForEach(0..<viewModel.currentStep.number, id: \.self) { index in
                    HorizontalCheckbox(
                        number: index + 1,
                        isChecked: viewModel.itemsChecked[index],
                        color: viewModel.currentStep.color
                    ) {
                        toggleCheckbox(at: index)
                    }
                }
            }
            .frame(maxWidth: .infinity)

            // Simple progress text
            if !viewModel.allItemsChecked {
                Text("\(viewModel.itemsChecked.prefix(viewModel.currentStep.number).filter { $0 }.count) / \(viewModel.currentStep.number)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(viewModel.currentStep.color)
            } else {
                // Success checkmark
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(viewModel.currentStep.color)

                    Text("Complete")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(viewModel.currentStep.color)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private var skipButton: some View {
        Button(action: {
            HapticManager.shared.impact(.soft)
            viewModel.showingSummary = true
        }) {
            Text("Skip")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                .frame(height: 48)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 24)
        .accessibilityLabel("Skip grounding exercise")
    }

    // MARK: - Helper Functions

    private func toggleCheckbox(at index: Int) {
        HapticManager.shared.impact(.light)
        viewModel.toggleItem(at: index)

        if viewModel.allItemsChecked {
            HapticManager.shared.notification(.success)
        }
    }

    // MARK: - Animation Helpers

    private func animateContentIn() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            contentScale = 1.0
            contentOpacity = 1.0
        }
    }

    private func animateContentTransition() {
        withAnimation(.easeOut(duration: 0.2)) {
            contentScale = 0.92
            contentOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                contentScale = 1.0
                contentOpacity = 1.0
            }
        }
    }

    private func startPulseAnimation() {
        withAnimation(
            Animation.easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
        ) {
            pulseAnimation = true
        }
    }

}

// MARK: - Horizontal Checkbox Component

struct HorizontalCheckbox: View {
    @Environment(\.isDarkMode) var isDarkMode
    let number: Int
    let isChecked: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isChecked ? color : Color.adaptiveSupportGray(isDark: isDarkMode).opacity(0.5))
                    .frame(width: 56, height: 56)

                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(number)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    GroundingExerciseView(navigateToDashboard: {})
}
