//
//  OnboardingReliefExperienceView.swift
//  anxietyapp
//
//  Created by Claude Code
//

import SwiftUI

struct OnboardingReliefExperienceView: View {
    @Binding var userProfile: UserProfile
    let onContinue: () -> Void

    @State private var currentSubStep: ReliefSubStep = .initialCheck
    @State private var anxietyBefore: Double = 5
    @State private var anxietyAfter: Double = 5
    @State private var selectedTechnique: TechniqueType? = nil

    enum ReliefSubStep {
        case initialCheck
        case explanation
        case countdown
        case sosBreathing
        case chooseExercise
        case exerciseDemo
        case wellDone
        case finalCheck
        case results
    }

    var body: some View {
        ZStack {
            switch currentSubStep {
            case .initialCheck:
                initialMoodCheckView
                    .transition(.opacity)

            case .explanation:
                explanationView
                    .transition(.opacity)

            case .countdown:
                countdownView
                    .transition(.opacity)

            case .sosBreathing:
                sosBreathingView
                    .transition(.opacity)

            case .chooseExercise:
                chooseTechniqueView
                    .transition(.opacity)

            case .exerciseDemo:
                if let technique = selectedTechnique {
                    techniqueDemo(for: technique)
                        .transition(.opacity)
                }

            case .wellDone:
                wellDoneView
                    .transition(.opacity)

            case .finalCheck:
                finalMoodCheckView
                    .transition(.opacity)

            case .results:
                resultsView
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentSubStep)
    }

    // MARK: - Initial Mood Check
    private var initialMoodCheckView: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            Spacer()

            VStack(spacing: DesignSystem.Spacing.medium) {
                Text("How anxious do you feel right now?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.textDark)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Be honest. We're here to help.")
                    .font(.system(size: 16))
                    .foregroundColor(.textMedium)
            }
            .padding(.horizontal, DesignSystem.Spacing.large)

            // Mood Slider with Emoji
            VStack(spacing: DesignSystem.Spacing.medium) {
                // Emoji + Number
                VStack(spacing: 8) {
                    Text(emojiForAnxiety(Int(anxietyBefore)))
                        .font(.system(size: 56))

                    Text("\(Int(anxietyBefore))")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(colorForAnxiety(Int(anxietyBefore)))

                    Text(labelForAnxiety(Int(anxietyBefore)))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(colorForAnxiety(Int(anxietyBefore)))
                }

                // Slider
                Slider(value: $anxietyBefore, in: 1...10, step: 1)
                    .tint(colorForAnxiety(Int(anxietyBefore)))
                    .padding(.horizontal, DesignSystem.Spacing.large)

                // Labels
                HStack {
                    Text("1 - Calm")
                        .font(.system(size: 13))
                        .foregroundColor(.textLight)

                    Spacer()

                    Text("10 - Very Anxious")
                        .font(.system(size: 13))
                        .foregroundColor(.textLight)
                }
                .padding(.horizontal, DesignSystem.Spacing.large)
            }

            Spacer()

            OnboardingButton(title: "Continue", action: {
                userProfile.anxietyBefore = Int(anxietyBefore)
                withAnimation {
                    currentSubStep = .explanation
                }
            })
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.bottom, DesignSystem.Spacing.medium)
        }
        .gradientBackground()
    }

    // MARK: - Explanation View (Physiological Sigh)
    private var explanationView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: DesignSystem.Spacing.large) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.primaryPurple.opacity(0.1))
                        .frame(width: 80, height: 80)

                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(.primaryPurple)
                }

                // Title
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text("The Physiological Sigh")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.textDark)
                        .multilineTextAlignment(.center)

                    Text("Neuroscience-backed relief in 10 seconds")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primaryPurple)
                        .multilineTextAlignment(.center)
                }

                // How it works
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    explanationPoint(
                        icon: "lungs.fill",
                        text: "Two quick inhales through your nose"
                    )

                    explanationPoint(
                        icon: "wind",
                        text: "Followed by one long exhale through your mouth"
                    )

                    explanationPoint(
                        icon: "sparkles",
                        text: "Instantly reduces stress by removing CO₂ from your bloodstream"
                    )
                }
                .padding(.horizontal, DesignSystem.Spacing.large)

                // Credibility
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text("Used by Navy SEALs & backed by")
                        .font(.system(size: 14))
                        .foregroundColor(.textMedium)

                    Text("Dr. Andrew Huberman")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.textDark)

                    Text("Stanford Neuroscientist")
                        .font(.system(size: 13))
                        .foregroundColor(.textLight)
                }
                .padding(.top, DesignSystem.Spacing.xs)

                // Source Citation
                Button(action: {
                    if let url = URL(string: "https://med.stanford.edu/news/insights/2023/02/cyclic-sighing-can-help-breathe-away-anxiety.html") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Text("Source:")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.textLight)
                            Text("Stanford Medicine Study (2023)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.primaryPurple)
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 11))
                                .foregroundColor(.primaryPurple)
                        }
                        Text("Cell Reports Medicine")
                            .font(.system(size: 11))
                            .foregroundColor(.textLight)
                            .italic()
                    }
                }
                .padding(.top, DesignSystem.Spacing.small)
            }
            .padding(.horizontal, DesignSystem.Spacing.large)

            Spacer()

            OnboardingButton(title: "Try it now", action: {
                withAnimation {
                    currentSubStep = .countdown
                }
            })
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.bottom, DesignSystem.Spacing.medium)
        }
        .gradientBackground()
    }

    private func explanationPoint(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.small) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.primaryPurple)
                .frame(width: 24)

            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.textDark)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Countdown View
    private var countdownView: some View {
        CountdownPreparationView(onComplete: {
            withAnimation {
                currentSubStep = .sosBreathing
            }
        })
    }

    // MARK: - SOS Breathing (Fixed timing from UnifiedSOSFlowView)
    private var sosBreathingView: some View {
        OnboardingDoubleInhaleView(onComplete: {
            withAnimation {
                currentSubStep = .chooseExercise
            }
        })
    }

    // MARK: - Choose Technique
    private var chooseTechniqueView: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            Spacer()

            VStack(spacing: DesignSystem.Spacing.medium) {
                // Progress icon
                ZStack {
                    Circle()
                        .fill(Color.success.opacity(0.15))
                        .frame(width: 64, height: 64)

                    Image(systemName: "sparkles")
                        .font(.system(size: 28))
                        .foregroundColor(.success)
                }

                Text("Great start!")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.textDark)
                    .multilineTextAlignment(.center)

                VStack(spacing: 4) {
                    Text("Different techniques work for different people.")
                        .font(.system(size: 16))
                        .foregroundColor(.textMedium)
                        .multilineTextAlignment(.center)

                    Text("Let's find what works best for you.")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primaryPurple)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.large)

            HStack(spacing: DesignSystem.Spacing.medium) {
                TechniqueChoiceCard(
                    type: .breathing,
                    isSelected: selectedTechnique == .breathing,
                    isRecommended: true,
                    onTap: {
                        selectedTechnique = .breathing
                    }
                )

                TechniqueChoiceCard(
                    type: .grounding,
                    isSelected: selectedTechnique == .grounding,
                    isRecommended: false,
                    onTap: {
                        selectedTechnique = .grounding
                    }
                )
            }
            .padding(.horizontal, DesignSystem.Spacing.medium)

            Spacer()

            OnboardingButton(
                title: "Try \(selectedTechnique?.rawValue ?? "Exercise")",
                action: {
                    if selectedTechnique != nil {
                        userProfile.chosenTechnique = selectedTechnique
                        withAnimation {
                            currentSubStep = .exerciseDemo
                        }
                    }
                }
            )
            .disabled(selectedTechnique == nil)
            .opacity(selectedTechnique == nil ? 0.5 : 1.0)
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.bottom, DesignSystem.Spacing.medium)
        }
        .gradientBackground()
    }

    // MARK: - Helper Functions for Anxiety Display
    private func emojiForAnxiety(_ level: Int) -> String {
        switch level {
        case 1...3: return "😌"
        case 4...6: return "😕"
        case 7...8: return "😰"
        case 9...10: return "😨"
        default: return "😕"
        }
    }

    private func labelForAnxiety(_ level: Int) -> String {
        switch level {
        case 1...3: return "Calm"
        case 4...6: return "Uneasy"
        case 7...8: return "Anxious"
        case 9...10: return "Very Anxious"
        default: return "Uneasy"
        }
    }

    private func colorForAnxiety(_ level: Int) -> Color {
        switch level {
        case 1...3: return .success  // Green for calm
        case 4...6: return .primaryPurple  // Purple for uneasy
        case 7...8: return Color.orange  // Orange for anxious
        case 9...10: return .emergencyRed  // Red for very anxious
        default: return .primaryPurple
        }
    }

    // MARK: - Technique Demo (Onboarding-specific versions)
    @ViewBuilder
    private func techniqueDemo(for technique: TechniqueType) -> some View {
        switch technique {
        case .breathing:
            OnboardingBreathingExercise(onComplete: {
                withAnimation {
                    currentSubStep = .wellDone
                }
            })
        case .grounding:
            OnboardingGroundingExercise(onComplete: {
                withAnimation {
                    currentSubStep = .wellDone
                }
            })
        }
    }

    // MARK: - Well Done View
    private var wellDoneView: some View {
        WellDoneCelebrationView(onComplete: {
            withAnimation {
                currentSubStep = .finalCheck
            }
        })
    }

    // MARK: - Final Mood Check
    private var finalMoodCheckView: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            Spacer()

            VStack(spacing: DesignSystem.Spacing.medium) {
                Text("How anxious do you feel now?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.textDark)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text("After the exercise")
                    .font(.system(size: 16))
                    .foregroundColor(.textMedium)
            }
            .padding(.horizontal, DesignSystem.Spacing.large)

            // Mood Slider with Emoji
            VStack(spacing: DesignSystem.Spacing.medium) {
                // Emoji + Number
                VStack(spacing: 8) {
                    Text(emojiForAnxiety(Int(anxietyAfter)))
                        .font(.system(size: 56))

                    Text("\(Int(anxietyAfter))")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(colorForAnxiety(Int(anxietyAfter)))

                    Text(labelForAnxiety(Int(anxietyAfter)))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(colorForAnxiety(Int(anxietyAfter)))
                }

                // Slider
                Slider(value: $anxietyAfter, in: 1...10, step: 1)
                    .tint(colorForAnxiety(Int(anxietyAfter)))
                    .padding(.horizontal, DesignSystem.Spacing.large)

                // Labels
                HStack {
                    Text("1 - Calm")
                        .font(.system(size: 13))
                        .foregroundColor(.textLight)

                    Spacer()

                    Text("10 - Very Anxious")
                        .font(.system(size: 13))
                        .foregroundColor(.textLight)
                }
                .padding(.horizontal, DesignSystem.Spacing.large)
            }

            Spacer()

            OnboardingButton(title: "See Results", action: {
                userProfile.anxietyAfter = Int(anxietyAfter)
                withAnimation {
                    currentSubStep = .results
                }
            })
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.bottom, DesignSystem.Spacing.medium)
        }
        .gradientBackground()
    }

    // MARK: - Results
    private var resultsView: some View {
        let before = Int(anxietyBefore)
        let after = Int(anxietyAfter)
        let improved = after < before
        let same = after == before

        return VStack(spacing: DesignSystem.Spacing.large) {
            Spacer()

            // Icon
            Image(systemName: improved ? "checkmark.circle.fill" : "info.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(improved ? .success : .primaryPurple)

            // Before/After Comparison
            HStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Before")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textLight)

                    Text("\(before)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.emergencyRed)
                }

                Image(systemName: "arrow.right")
                    .font(.system(size: 24))
                    .foregroundColor(.textLight)

                VStack(spacing: 8) {
                    Text("After")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textLight)

                    Text("\(after)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(improved ? .success : .primaryPurple)
                }
            }

            // Message based on results
            VStack(spacing: DesignSystem.Spacing.small) {
                if improved {
                    let improvement = before - after
                    let percentage = userProfile.anxietyImprovementPercentage

                    Text("Amazing!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.textDark)

                    Text("You reduced anxiety by \(improvement) points (\(percentage)%) in just 2 minutes!")
                        .font(.system(size: 16))
                        .foregroundColor(.textMedium)
                        .multilineTextAlignment(.center)

                    Text("Imagine having 10+ more techniques like this, always available in your pocket.")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primaryPurple)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                } else if same {
                    Text("That's okay!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.textDark)

                    Text("This technique isn't for everyone!")
                        .font(.system(size: 16))
                        .foregroundColor(.textMedium)
                        .multilineTextAlignment(.center)

                    Text("That's why Nuvin has 10+ other techniques. Let's find what works for YOU.")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primaryPurple)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                } else {
                    Text("Sometimes techniques take practice")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.textDark)
                        .multilineTextAlignment(.center)

                    Text("Nuvin has 10+ different techniques to try. We'll help you find your perfect match.")
                        .font(.system(size: 16))
                        .foregroundColor(.textMedium)
                        .multilineTextAlignment(.center)

                    Text("Everyone's anxiety is different, and that's okay.")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primaryPurple)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.large)

            Spacer()

            OnboardingButton(title: "Check your symptoms", action: onContinue)
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .padding(.bottom, DesignSystem.Spacing.medium)
        }
        .gradientBackground()
    }
}

// MARK: - Onboarding Double Inhale View (FIXED TIMING - 4 seconds like original)
struct OnboardingDoubleInhaleView: View {
    let onComplete: () -> Void
    @Environment(\.isDarkMode) var isDarkMode

    @State private var breathingPhase: BreathingPhase = .inhale1
    @State private var currentCycle = 0
    @State private var dotPosition: CGFloat = 0
    @State private var phaseText = "Inhale deep"
    @State private var startTime: Date?

    private let totalCycles = 2
    private let cycleDuration: TimeInterval = 4.0 // FIXED: Match original timing (1s + 1s + 2s = 4s)

    enum BreathingPhase {
        case inhale1, inhale2, exhale

        var text: String {
            switch self {
            case .inhale1: return "Inhale deep"
            case .inhale2: return "Inhale again"
            case .exhale: return "Exhale slow"
            }
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let visualizationHeight = min(320, screenHeight * 0.4)

            VStack(spacing: 0) {
                Spacer()
                    .frame(minHeight: screenHeight * 0.15)

                // Title and instruction
                VStack(spacing: 12) {
                    Text("Let's help you feel better")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.textDark)
                        .multilineTextAlignment(.center)

                    Text("Inhale through your nose • Exhale through your mouth")
                        .font(.system(size: 15))
                        .foregroundColor(.textMedium)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 32)

                Spacer()
                    .frame(minHeight: screenHeight * 0.08)

                // Breathing visualization
                curvePathVisualization(height: visualizationHeight)

                Spacer()
                    .frame(minHeight: screenHeight * 0.06)

                // Phase instruction
                VStack(spacing: 12) {
                    Text(phaseText)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.textDark)
                        .animation(.easeInOut(duration: 0.3), value: phaseText)

                    if currentCycle < totalCycles {
                        Text("Cycle \(currentCycle + 1) of \(totalCycles)")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.textMedium)
                    }
                }

                Spacer()
                    .frame(minHeight: screenHeight * 0.05)
            }
        }
        .gradientBackground()
        .onAppear {
            startBreathingCycle()
        }
    }

    private func curvePathVisualization(height: CGFloat) -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let curveHeight = geometry.size.height

            ZStack {
                // Breathing curve path
                BreathingCurvePath()
                    .stroke(
                        Color.primaryPurple.opacity(0.6),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: width * 0.85, height: curveHeight * 0.75)

                // Animated point
                Circle()
                    .fill(Color.primaryPurple)
                    .frame(width: 48, height: 48)
                    .offset(x: pointOffset(for: dotPosition, width: width * 0.85, height: curveHeight * 0.75).x,
                            y: pointOffset(for: dotPosition, width: width * 0.85, height: curveHeight * 0.75).y)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: height)
    }

    private func pointOffset(for progress: CGFloat, width: CGFloat, height: CGFloat) -> CGPoint {
        let totalWidth = width
        let amplitude = height * 0.55
        let x = (progress - 0.5) * totalWidth
        var y: CGFloat = 0

        // Match original: 0-25% inhale1, 25-50% inhale2, 50-100% exhale
        if progress < 0.25 {
            let localProgress = progress / 0.25
            let eased = 1 - cos(localProgress * .pi / 2)
            y = -eased * amplitude * 0.5
        } else if progress < 0.50 {
            let localProgress = (progress - 0.25) / 0.25
            let eased = 1 - cos(localProgress * .pi / 2)
            y = -(0.5 + eased * 0.5) * amplitude
        } else {
            let localProgress = (progress - 0.50) / 0.50
            let eased = sin((1 - localProgress) * .pi / 2)
            y = -eased * amplitude
        }

        return CGPoint(x: x, y: y)
    }

    private func startBreathingCycle() {
        startTime = Date()
        phaseText = "Inhale deep"
        HapticManager.shared.impact(.light)
        updateBreathingPosition()
    }

    private func updateBreathingPosition() {
        guard let startTime = startTime else { return }

        let elapsed = Date().timeIntervalSince(startTime)
        let progress = elapsed / cycleDuration

        if progress >= 1.0 {
            currentCycle += 1

            if currentCycle >= totalCycles {
                dotPosition = 1.0
                phaseText = "Great!"
                HapticManager.shared.impact(.medium)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onComplete()
                }
            } else {
                self.startTime = Date()
                dotPosition = 0
                breathingPhase = .inhale1
                phaseText = "Inhale deep"
                HapticManager.shared.impact(.light)
                updateBreathingPosition()
            }
            return
        }

        dotPosition = CGFloat(progress)
        updatePhaseForTime(elapsed)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0/60.0) {
            self.updateBreathingPosition()
        }
    }

    private func updatePhaseForTime(_ elapsed: TimeInterval) {
        // Match original timing: 0-1s inhale1, 1-2s inhale2, 2-4s exhale
        if elapsed < 1.0 {
            if breathingPhase != .inhale1 {
                breathingPhase = .inhale1
                phaseText = breathingPhase.text
                HapticManager.shared.impact(.light)
            }
        } else if elapsed < 2.0 {
            if breathingPhase != .inhale2 {
                breathingPhase = .inhale2
                phaseText = breathingPhase.text
                HapticManager.shared.impact(.light)
            }
        } else {
            if breathingPhase != .exhale {
                breathingPhase = .exhale
                phaseText = breathingPhase.text
                HapticManager.shared.impact(.medium)
            }
        }
    }
}

// MARK: - Onboarding Breathing Exercise (COPIED from BreathingExerciseView, no skip, no summary, auto-complete)
struct OnboardingBreathingExercise: View {
    let onComplete: () -> Void
    @Environment(\.isDarkMode) var isDarkMode
    @StateObject private var viewModel = BreathingViewModel()
    @State private var phaseTimeRemaining: Int = 4
    @State private var countdownTimer: Timer?
    @State private var animatedCircleSize: CGFloat = 120

    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let maxCircleSize = min(280, screenHeight * 0.35)
            let minCircleSize = min(120, screenHeight * 0.15)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
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
                    }

                    Spacer()
                        .frame(height: screenHeight * 0.05)

                    // Skip button
                    if viewModel.isActive {
                        skipButton
                            .padding(.bottom, 72)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: screenHeight)
            }
            .onChange(of: viewModel.currentPhase) { newPhase in
                HapticManager.shared.impact(.light)
                resetCountdown()

                withAnimation(.easeInOut(duration: 4.0)) {
                    animatedCircleSize = circleSize(maxSize: maxCircleSize, minSize: minCircleSize)
                }
            }
            .onChange(of: viewModel.isActive) { isActive in
                if isActive {
                    resetCountdown()
                    withAnimation(.easeInOut(duration: 4.0)) {
                        animatedCircleSize = circleSize(maxSize: maxCircleSize, minSize: minCircleSize)
                    }
                }
            }
            .onChange(of: viewModel.showingQuickMenu) { showing in
                if showing {
                    onComplete()
                }
            }
            .onAppear {
                animatedCircleSize = minCircleSize
            }
            .onDisappear {
                countdownTimer?.invalidate()
            }
            .gradientBackground(AppGradient.adaptiveBackground(isDark: isDarkMode))
        }
    }

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

            breathingPatternIllustration

            Text("Box breathing: 4 seconds each phase.")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))

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

    private var breathingPatternIllustration: some View {
        ZStack {
            Circle()
                .stroke(Color.softViolet.opacity(0.2), lineWidth: 3)
                .frame(width: 180, height: 180)

            ForEach(0..<4, id: \.self) { index in
                let angle = Double(index) * 90 + 45
                let radians = angle * .pi / 180
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.softViolet.opacity(0.6))
                    .rotationEffect(.degrees(angle))
                    .offset(x: cos(radians) * 90, y: sin(radians) * 90)
            }

            phasePoint("Inhale", offsetX: 0, offsetY: -65)
            phasePoint("Hold", offsetX: 65, offsetY: 0)
            phasePoint("Exhale", offsetX: 0, offsetY: 65)
            phasePoint("Hold", offsetX: -65, offsetY: 0)

            Image(systemName: "wind")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(Color.softViolet.opacity(0.4))
        }
        .frame(height: 200)
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

    private func breathingSection(maxSize: CGFloat, minSize: CGFloat) -> some View {
        VStack(spacing: 48) {
            breathingCircle
            phaseText
        }
    }

    private var breathingCircle: some View {
        ZStack {
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
        .frame(height: 280)
    }

    private var phaseText: some View {
        VStack(spacing: 16) {
            Text(viewModel.currentPhase.instruction)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            HStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(index <= currentPhaseIndex ? Color.softViolet : Color.adaptiveDivider(isDark: isDarkMode))
                        .frame(width: 8, height: 8)
                }
            }
        }
    }

    private var currentPhaseIndex: Int {
        switch viewModel.currentPhase {
        case .inhale: return 0
        case .holdIn: return 1
        case .exhale: return 2
        case .holdOut: return 3
        }
    }

    private func circleSize(maxSize: CGFloat, minSize: CGFloat) -> CGFloat {
        switch viewModel.currentPhase {
        case .inhale: return maxSize
        case .holdIn: return maxSize
        case .exhale: return minSize
        case .holdOut: return minSize
        }
    }

    private var skipButton: some View {
        Button(action: {
            HapticManager.shared.impact(.soft)
            viewModel.stopBreathing()
            onComplete()
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

// MARK: - Onboarding Grounding Exercise (COPIED from GroundingExerciseView, no skip, no summary, auto-complete)
struct OnboardingGroundingExercise: View {
    let onComplete: () -> Void
    @Environment(\.isDarkMode) var isDarkMode
    @StateObject private var viewModel = GroundingViewModel()
    @State private var contentScale: CGFloat = 0.95
    @State private var contentOpacity: Double = 0
    @State private var pulseAnimation: Bool = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()

                if !viewModel.isActive {
                    startContent
                } else {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        compactProgressSection

                        if !viewModel.isCompleted {
                            compactGroundingContent
                                .scaleEffect(contentScale)
                                .opacity(contentOpacity)
                                .padding(.horizontal, DesignSystem.Spacing.large)
                        }
                    }
                }

                Spacer()

                // Skip button
                if viewModel.isActive {
                    skipButton
                        .padding(.bottom, 72)
                }
            }
            .padding(.top, 60)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .gradientBackground(AppGradient.adaptiveBackground(isDark: isDarkMode))
        .onAppear {
            animateContentIn()
            startPulseAnimation()
        }
        .onChange(of: viewModel.currentStepIndex) { _ in
            animateContentTransition()
        }
        .onChange(of: viewModel.showingSummary) { showing in
            if showing {
                onComplete()
            }
        }
    }

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

            sensesIllustration

            Text("Use your five senses to reconnect with the present moment.")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                .padding(.top, 8)
                .multilineTextAlignment(.center)

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
            VStack(spacing: DesignSystem.Spacing.medium) {
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

            compactCheckboxesSection
        }
    }

    private var compactCheckboxesSection: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
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

            if !viewModel.allItemsChecked {
                Text("\(viewModel.itemsChecked.prefix(viewModel.currentStep.number).filter { $0 }.count) / \(viewModel.currentStep.number)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(viewModel.currentStep.color)
            } else {
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

    private func toggleCheckbox(at index: Int) {
        HapticManager.shared.impact(.light)
        viewModel.toggleItem(at: index)

        if viewModel.allItemsChecked {
            HapticManager.shared.notification(.success)
        }
    }

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

    private var skipButton: some View {
        Button(action: {
            HapticManager.shared.impact(.soft)
            onComplete()
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

    private func startPulseAnimation() {
        withAnimation(
            Animation.easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
        ) {
            pulseAnimation = true
        }
    }
}

// MARK: - Technique Choice Card
struct TechniqueChoiceCard: View {
    let type: TechniqueType
    let isSelected: Bool
    let isRecommended: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .top) {
                VStack(spacing: 12) {
                    // Unlock icon
                    ZStack {
                        Circle()
                            .fill(isSelected ? Color.white.opacity(0.2) : Color.primaryPurple.opacity(0.1))
                            .frame(width: 56, height: 56)

                        Image(systemName: type.icon)
                            .font(.system(size: 28))
                            .foregroundColor(isSelected ? .white : .primaryPurple)
                    }

                    Text(type.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .textDark)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(minHeight: 20)

                    Text(type.description)
                        .font(.system(size: 13))
                        .foregroundColor(isSelected ? .white.opacity(0.9) : .textMedium)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(minHeight: 36)
                }
                .frame(maxWidth: .infinity, minHeight: 180)
                .padding(20)
                .padding(.top, isRecommended ? 8 : 0)
                .background(isSelected ? Color.primaryPurple : Color.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.primaryPurple : Color.borderGray, lineWidth: 2)
                )

                // Recommended Badge on Border
                if isRecommended {
                    Text("Recommended")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.success)
                        .cornerRadius(12)
                        .offset(y: -10)
                }
            }
        }
    }
}

// MARK: - Countdown Preparation View
struct CountdownPreparationView: View {
    let onComplete: () -> Void
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var glowOpacity: Double = 0

    var body: some View {
        ZStack {
            // Background
            Color.white
                .ignoresSafeArea()

            // GO text with glow effect
            ZStack {
                // Glow effect
                Text("GO!")
                    .font(.system(size: 96, weight: .bold))
                    .foregroundColor(.primaryPurple)
                    .blur(radius: 20)
                    .opacity(glowOpacity)

                // Main text
                Text("GO!")
                    .font(.system(size: 96, weight: .bold))
                    .foregroundColor(.primaryPurple)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            showGO()
        }
    }

    private func showGO() {
        // Haptic feedback
        HapticManager.shared.impact(.heavy)

        // Animate in with glow
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            scale = 1.0
            opacity = 1.0
        }

        withAnimation(.easeOut(duration: 0.3)) {
            glowOpacity = 0.4
        }

        // After 0.8 seconds, start the breathing exercise
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            onComplete()
        }
    }
}

// MARK: - Well Done Celebration View
struct WellDoneCelebrationView: View {
    let onComplete: () -> Void
    @State private var checkmarkScale: CGFloat = 0
    @State private var checkmarkRotation: Double = -180
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 20
    @State private var circleScale: CGFloat = 0
    @State private var particlesOpacity: Double = 0

    var body: some View {
        ZStack {
            // Background
            Color.white
                .ignoresSafeArea()

            // Animated particles
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(Color.success.opacity(0.3))
                    .frame(width: 12, height: 12)
                    .offset(
                        x: cos(Double(index) * .pi / 4) * 100,
                        y: sin(Double(index) * .pi / 4) * 100
                    )
                    .scaleEffect(particlesOpacity)
                    .opacity(particlesOpacity)
            }

            VStack(spacing: 24) {
                // Checkmark circle
                ZStack {
                    // Background circle
                    Circle()
                        .fill(Color.success.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .scaleEffect(circleScale)

                    // Checkmark
                    Image(systemName: "checkmark")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundColor(.success)
                        .scaleEffect(checkmarkScale)
                        .rotationEffect(.degrees(checkmarkRotation))
                }

                // Well Done text
                VStack(spacing: 8) {
                    Text("Well Done!")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.textDark)

                    Text("You completed the exercise")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.textMedium)
                }
                .opacity(textOpacity)
                .offset(y: textOffset)
            }
        }
        .onAppear {
            animateCelebration()
        }
    }

    private func animateCelebration() {
        // Success haptic
        HapticManager.shared.notification(.success)

        // Circle appears first
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            circleScale = 1.0
        }

        // Checkmark with rotation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
            checkmarkScale = 1.0
            checkmarkRotation = 0
        }

        // Text appears
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3)) {
            textOpacity = 1.0
            textOffset = 0
        }

        // Particles burst out
        withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
            particlesOpacity = 1.0
        }

        // Fade out particles
        withAnimation(.easeOut(duration: 0.4).delay(0.6)) {
            particlesOpacity = 0
        }

        // Auto-proceed after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            onComplete()
        }
    }
}

#Preview {
    OnboardingReliefExperienceView(
        userProfile: .constant(UserProfile()),
        onContinue: {}
    )
}
