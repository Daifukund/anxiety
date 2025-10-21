//
//  BreathingExerciseView.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import SwiftUI

struct BreathingExerciseView: View {
    @Environment(\.isDarkMode) var isDarkMode
    let navigateToDashboard: () -> Void
    @StateObject private var viewModel = BreathingViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var phaseTimeRemaining: Int = 4
    @State private var countdownTimer: Timer?
    @State private var animatedCircleSize: CGFloat = 120 // Start at exhale size
    @State private var showingSummary = false

    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let maxCircleSize = min(280, screenHeight * 0.35) // Max 35% of screen height
            let minCircleSize = min(120, screenHeight * 0.15) // Min 15% of screen height

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header with close button
                    headerSection
                        .padding(.horizontal, DesignSystem.Spacing.medium)
                        .padding(.top, DesignSystem.Spacing.small)
                        .padding(.bottom, DesignSystem.Spacing.small)

                    // Top section: Cycle counter
                    if viewModel.isActive {
                        HStack {
                            Spacer()
                            Text("Cycle \(viewModel.cycleCount + 1) / 4")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                            Spacer()
                        }
                        .padding(.top, 16)
                        .accessibilityLabel("Breathing cycle \(viewModel.cycleCount + 1) of 4")
                    }

                    Spacer()
                        .frame(height: screenHeight * 0.05)

                    if !viewModel.isActive && !viewModel.showingQuickMenu {
                        startSection
                    } else if viewModel.isActive {
                        breathingSection(maxSize: maxCircleSize, minSize: minCircleSize)
                    } else {
                        EmptyView()
                    }

                    Spacer()
                        .frame(height: screenHeight * 0.05)

                    // Bottom button
                    if viewModel.isActive {
                        skipButton
                            .padding(.bottom, 72) // 8px * 9
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: screenHeight)
            }
            .onChange(of: viewModel.currentPhase) { newPhase in
                HapticManager.shared.impact(.light)
                resetCountdown()

                // Update animated circle size
                withAnimation(.easeInOut(duration: 4.0)) {
                    animatedCircleSize = circleSize(maxSize: maxCircleSize, minSize: minCircleSize)
                }
            }
            .onChange(of: viewModel.isActive) { isActive in
                if isActive {
                    // Start countdown when breathing starts
                    resetCountdown()
                    // Animate to first phase size
                    withAnimation(.easeInOut(duration: 4.0)) {
                        animatedCircleSize = circleSize(maxSize: maxCircleSize, minSize: minCircleSize)
                    }
                }
            }
            .onAppear {
                // Set initial size
                animatedCircleSize = minCircleSize
            }
            .onDisappear {
                countdownTimer?.invalidate()
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
                    completedTechnique: "Box Breathing",
                    onTryAnother: {
                        showingSummary = false
                        viewModel.stopBreathing()
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
            .onChange(of: viewModel.showingQuickMenu) { showing in
                if showing {
                    showingSummary = true
                    viewModel.showingQuickMenu = false
                }
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
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
    }

    // MARK: - Start Section
    private var startSection: some View {
        VStack(spacing: 24) {
            Text("Take a moment\nto breathe")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text("4 breathing cycles • 16 seconds each")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))

            // Breathing pattern illustration
            breathingPatternIllustration

            // Explanation text
            Text("Box breathing: 4 seconds each phase.")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))

            // Start button
            Button(action: {
                HapticManager.shared.impact(.medium)
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    viewModel.startBreathing()
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
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Breathing Pattern Illustration
    private var breathingPatternIllustration: some View {
        ZStack {
            circularPath
            directionArrows
            phaseLabels
            centerIcon
        }
        .frame(height: 200)
    }

    private var circularPath: some View {
        Circle()
            .stroke(Color.softViolet.opacity(0.2), lineWidth: 3)
            .frame(width: 180, height: 180)
    }

    private var directionArrows: some View {
        ForEach(0..<4, id: \.self) { index in
            let angle = Double(index) * 90 + 45
            let radians = angle * .pi / 180
            Image(systemName: "arrow.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.softViolet.opacity(0.6))
                .rotationEffect(.degrees(angle))
                .offset(x: cos(radians) * 90, y: sin(radians) * 90)
        }
    }

    private var phaseLabels: some View {
        Group {
            phasePoint("Inhale", offsetX: 0, offsetY: -65)
            phasePoint("Hold", offsetX: 65, offsetY: 0)
            phasePoint("Exhale", offsetX: 0, offsetY: 65)
            phasePoint("Hold", offsetX: -65, offsetY: 0)
        }
    }

    private func phasePoint(_ label: String, offsetX: CGFloat, offsetY: CGFloat) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
            Text("4s")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color.softViolet)
        }
        .offset(x: offsetX, y: offsetY)
    }

    private var centerIcon: some View {
        Image(systemName: "wind")
            .font(.system(size: 32, weight: .light))
            .foregroundColor(Color.softViolet.opacity(0.4))
    }

    // MARK: - Breathing Section
    private func breathingSection(maxSize: CGFloat, minSize: CGFloat) -> some View {
        VStack(spacing: 48) { // 8px * 6
            breathingCircle
            phaseText
        }
    }

    private var breathingCircle: some View {
        ZStack {
            // Animated main circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.softViolet.opacity(0.6),
                            Color.softViolet.opacity(0.4)
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 120
                    )
                )
                .frame(width: animatedCircleSize, height: animatedCircleSize)

            // Center content
            VStack(spacing: 12) {
                Text(viewModel.currentPhase.displayText)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                    .accessibilityLabel(viewModel.currentPhase.instruction)

                Text("\(phaseTimeRemaining)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                    .monospacedDigit()
                    .accessibilityHidden(true)
            }
        }
        .frame(height: 280) // 8px * 35
    }

    private var phaseText: some View {
        VStack(spacing: 16) {
            Text(viewModel.currentPhase.instruction)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Progress dots - track phases within current cycle
            HStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(index <= currentPhaseIndex ? Color.softViolet : Color.adaptiveDivider(isDark: isDarkMode))
                        .frame(width: 8, height: 8)
                }
            }
        }
    }

    private var skipButton: some View {
        Button(action: {
            HapticManager.shared.impact(.soft)
            viewModel.stopBreathing()
            showingSummary = true
        }) {
            Text("Skip")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                .frame(height: 48)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 24)
        .accessibilityLabel("Skip breathing exercise")
    }

    // MARK: - Computed Properties
    private func circleSize(maxSize: CGFloat, minSize: CGFloat) -> CGFloat {
        switch viewModel.currentPhase {
        case .inhale:
            return maxSize // Dramatic expansion
        case .holdIn:
            return maxSize
        case .exhale:
            return minSize // Dramatic contraction
        case .holdOut:
            return minSize
        }
    }

    private var currentPhaseIndex: Int {
        switch viewModel.currentPhase {
        case .inhale:
            return 0
        case .holdIn:
            return 1
        case .exhale:
            return 2
        case .holdOut:
            return 3
        }
    }

    // MARK: - Countdown Logic
    private func resetCountdown() {
        countdownTimer?.invalidate()
        phaseTimeRemaining = 4

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if phaseTimeRemaining > 1 {
                phaseTimeRemaining -= 1
            } else {
                phaseTimeRemaining = 4
            }
        }
    }
}

#Preview {
    BreathingExerciseView(navigateToDashboard: {})
}
