//
//  OnboardingQuizView.swift
//  anxietyapp
//
//  Created by Claude Code
//

import SwiftUI
import Combine

struct OnboardingQuizView: View {
    @Binding var userProfile: UserProfile
    let onComplete: () -> Void

    @State private var currentQuestionIndex = 0
    @State private var nameText = ""
    @State private var stressLevel = 5
    @State private var isAnswerLocked = false
    @State private var scrollViewProxy: ScrollViewProxy?

    private var totalQuestions: Int { 8 }

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar with back button
            VStack(spacing: DesignSystem.Spacing.xs) {
                HStack(spacing: DesignSystem.Spacing.small) {
                    // Back button
                    if currentQuestionIndex > 0 {
                        Button(action: handleBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.textDark)
                                .frame(width: 44, height: 44)
                        }
                    } else {
                        // Spacer to maintain alignment when no back button
                        Color.clear.frame(width: 44, height: 44)
                    }

                    // Progress bar
                    ProgressBar(current: currentQuestionIndex + 1, total: totalQuestions)

                    // Right spacer for symmetry
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .padding(.top, DesignSystem.Spacing.small)

                Text("\(currentQuestionIndex + 1) of \(totalQuestions)")
                    .font(DesignSystem.Typography.helperText)
                    .foregroundColor(.textLight)
            }

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.large) {
                        questionView(for: currentQuestionIndex)

                        // Spacer to ensure CTA is always visible when scrolled
                        Color.clear.frame(height: 100)
                    }
                    .padding(DesignSystem.Spacing.medium)
                }
                .id(currentQuestionIndex) // Force view refresh on question change
                .onAppear {
                    scrollViewProxy = proxy
                }
                .onChange(of: currentQuestionIndex) { _ in
                    scrollViewProxy = proxy
                }
            }

            // Next button
            if canProceed {
                OnboardingButton(title: currentQuestionIndex == totalQuestions - 1 ? "Continue" : "Next", action: handleNext)
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    .padding(.bottom, DesignSystem.Spacing.medium)
                    .id("nextButton")
            }
        }
        .gradientBackground()
    }

    @ViewBuilder
    private func questionView(for index: Int) -> some View {
        switch index {
        case 0:
            nameQuestion
        case 1:
            ageQuestion
        case 2:
            goalsQuestion
        case 3:
            stressBaselineQuestion
        case 4:
            stressCausesQuestion
        case 5:
            lifeSatisfactionQuestion
        case 6:
            exerciseExperienceQuestion
        case 7:
            therapistQuestion
        default:
            EmptyView()
        }
    }

    // MARK: - Question 1: Name
    private var nameQuestion: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("What is your name?")
                .font(DesignSystem.Typography.questionTitle)
                .foregroundColor(.textDark)

            TextField("Your name", text: $nameText)
                .font(DesignSystem.Typography.answerText)
                .padding(DesignSystem.Spacing.small)
                .background(Color.secondaryViolet)
                .cornerRadius(DesignSystem.CornerRadius.medium)
                .onChange(of: nameText) { newValue in
                    userProfile.name = newValue
                }
        }
    }

    // MARK: - Question 2: Age
    private var ageQuestion: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("How old are you?")
                .font(DesignSystem.Typography.questionTitle)
                .foregroundColor(.textDark)

            ForEach(AgeRange.allCases, id: \.self) { age in
                SelectionCard(
                    title: age.rawValue,
                    isSelected: userProfile.ageRange == age,
                    action: {
                        handleSingleSelectAnswer {
                            userProfile.ageRange = age
                        }
                    },
                    isDisabled: isAnswerLocked
                )
            }
        }
    }

    // MARK: - Question 3: Goals
    private var goalsQuestion: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("Why are you here?")
                .font(DesignSystem.Typography.questionTitle)
                .foregroundColor(.textDark)

            ForEach(OnboardingGoal.allCases, id: \.self) { goal in
                SelectionCard(
                    title: goal.rawValue,
                    isSelected: userProfile.goals.contains(goal),
                    action: {
                        if userProfile.goals.contains(goal) {
                            userProfile.goals.removeAll { $0 == goal }
                        } else {
                            userProfile.goals.append(goal)
                        }
                    }
                )
            }
        }
    }

    // MARK: - Question 4: Stress Baseline
    private var stressBaselineQuestion: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("On a scale of 0-10, how anxious do you feel most days?")
                .font(DesignSystem.Typography.questionTitle)
                .foregroundColor(.textDark)

            VStack(spacing: DesignSystem.Spacing.medium) {
                // Anxiety animation (constant, not linked to value)
                AnxietyPulseAnimation(intensity: 0.5)
                    .frame(height: 80)

                Text("\(userProfile.stressBaseline)")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundColor(.primaryPurple)
                    .frame(maxWidth: .infinity)

                HStack {
                    Text("Not anxious")
                        .font(DesignSystem.Typography.helperText)
                        .foregroundColor(.textLight)
                    Spacer()
                    Text("Very anxious")
                        .font(DesignSystem.Typography.helperText)
                        .foregroundColor(.textLight)
                }

                VStack(spacing: 8) {
                    SolidSlider(value: $userProfile.stressBaseline, range: 0...10, step: 1)
                        .frame(height: 44)

                    // Tick marks
                    HStack(spacing: 0) {
                        ForEach(0...10, id: \.self) { index in
                            Rectangle()
                                .fill(Color.primaryPurple.opacity(0.3))
                                .frame(width: 2, height: 8)
                            if index < 10 {
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Question 5: Stress Causes
    private var stressCausesQuestion: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("What do you think is making you feel that way?")
                .font(DesignSystem.Typography.questionTitle)
                .foregroundColor(.textDark)

            ForEach(StressCause.allCases, id: \.self) { cause in
                SelectionCard(
                    title: cause.rawValue,
                    isSelected: userProfile.stressCauses.contains(cause),
                    action: {
                        if userProfile.stressCauses.contains(cause) {
                            userProfile.stressCauses.removeAll { $0 == cause }
                        } else {
                            userProfile.stressCauses.append(cause)
                        }
                    }
                )
            }
        }
    }

    // MARK: - Question 6: Life Satisfaction
    private var lifeSatisfactionQuestion: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("How satisfied are you with your life?")
                .font(DesignSystem.Typography.questionTitle)
                .foregroundColor(.textDark)

            ForEach(LifeSatisfaction.allCases, id: \.self) { satisfaction in
                SelectionCard(
                    title: satisfaction.rawValue,
                    isSelected: userProfile.lifeSatisfaction == satisfaction,
                    action: {
                        handleSingleSelectAnswer {
                            userProfile.lifeSatisfaction = satisfaction
                        }
                    },
                    isDisabled: isAnswerLocked
                )
            }
        }
    }

    // MARK: - Question 7: Exercise Experience
    private var exerciseExperienceQuestion: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("Have you tried calming exercises before?")
                .font(DesignSystem.Typography.questionTitle)
                .foregroundColor(.textDark)

            ForEach(ExerciseExperience.allCases, id: \.self) { experience in
                SelectionCard(
                    title: experience.rawValue,
                    isSelected: userProfile.exerciseExperience == experience,
                    action: {
                        handleSingleSelectAnswer {
                            userProfile.exerciseExperience = experience
                        }
                    },
                    isDisabled: isAnswerLocked
                )
            }
        }
    }

    // MARK: - Question 8: Therapist
    private var therapistQuestion: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("Did you hear about Nuvin from a therapist?")
                .font(DesignSystem.Typography.questionTitle)
                .foregroundColor(.textDark)

            SelectionCard(
                title: "Yes",
                isSelected: userProfile.heardFromTherapist ?? false == true,
                action: {
                    handleSingleSelectAnswer {
                        userProfile.heardFromTherapist = true
                    }
                },
                isDisabled: isAnswerLocked
            )

            SelectionCard(
                title: "No",
                isSelected: userProfile.heardFromTherapist ?? true == false,
                action: {
                    handleSingleSelectAnswer {
                        userProfile.heardFromTherapist = false
                    }
                },
                isDisabled: isAnswerLocked
            )
        }
    }

    // MARK: - Navigation Logic
    private var canProceed: Bool {
        switch currentQuestionIndex {
        case 0: return !userProfile.name.isEmpty
        case 1: return userProfile.ageRange != nil
        case 2: return !userProfile.goals.isEmpty
        case 3: return true // Stress baseline always has a value
        case 4: return !userProfile.stressCauses.isEmpty
        case 5: return userProfile.lifeSatisfaction != nil
        case 6: return userProfile.exerciseExperience != nil
        case 7: return userProfile.heardFromTherapist != nil
        default: return false
        }
    }

    private func handleNext() {
        if currentQuestionIndex < totalQuestions - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentQuestionIndex += 1
            }
        } else {
            onComplete()
        }
    }

    private func handleBack() {
        if currentQuestionIndex > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentQuestionIndex -= 1
            }
            isAnswerLocked = false // Unlock when going back
        }
    }

    // MARK: - Helper Functions
    private func handleSingleSelectAnswer(action: @escaping () -> Void) {
        guard !isAnswerLocked else { return }

        // Execute the selection action
        action()

        // Lock further interactions
        isAnswerLocked = true

        // Trigger haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        // Scroll to next button with smooth animation
        withAnimation(.easeInOut(duration: 0.3)) {
            scrollViewProxy?.scrollTo("nextButton", anchor: .bottom)
        }

        // Auto-advance after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if isAnswerLocked { // Only advance if still locked (user didn't go back)
                handleNext()
                isAnswerLocked = false // Reset for next question
            }
        }
    }

    private func isQuestionMultiSelect(_ index: Int) -> Bool {
        // Questions that allow multiple selections
        return index == 2 || index == 4 // Goals and Stress Causes
    }
}

// MARK: - Anxiety Wave Animation
struct AnxietyPulseAnimation: View {
    let intensity: Double // 0.0 to 1.0
    @State private var wavePhase: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient - gets more saturated with higher anxiety
                LinearGradient(
                    colors: [
                        Color.primaryPurple.opacity(0.08 + intensity * 0.12),
                        Color.primaryPurple.opacity(0.04 + intensity * 0.06)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .cornerRadius(16)

                // Animated waves representing anxiety - more waves = more anxiety
                ForEach(0..<7, id: \.self) { index in
                    if index < Int(2 + intensity * 5) {
                        WavePath(
                            phase: wavePhase + CGFloat(index) * 0.3,
                            frequency: 1.5 + Double(index) * 0.3,
                            amplitude: 6 + intensity * CGFloat(index) * 3.5
                        )
                        .stroke(
                            Color.primaryPurple.opacity(0.4 - Double(index) * 0.05),
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round)
                        )
                        .offset(y: CGFloat(index) * 10)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(
                Animation.linear(duration: 3.5 - intensity * 1.8)
                    .repeatForever(autoreverses: false)
            ) {
                wavePhase = .pi * 2
            }
        }
        .onChange(of: intensity) { _ in
            // Restart animation with new speed when intensity changes
            wavePhase = 0
            withAnimation(
                Animation.linear(duration: 3.5 - intensity * 1.8)
                    .repeatForever(autoreverses: false)
            ) {
                wavePhase = .pi * 2
            }
        }
    }
}

struct WavePath: Shape {
    var phase: CGFloat
    let frequency: Double
    let amplitude: CGFloat

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height / 2

        path.move(to: CGPoint(x: 0, y: midHeight))

        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let sine = sin((relativeX * frequency * .pi * 2) + phase)
            let y = midHeight + sine * amplitude

            path.addLine(to: CGPoint(x: x, y: y))
        }

        return path
    }
}

// MARK: - Custom Slider
struct SolidSlider: UIViewRepresentable {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int

    func makeUIView(context: Context) -> UISlider {
        let slider = UISlider()
        slider.minimumValue = Float(range.lowerBound)
        slider.maximumValue = Float(range.upperBound)
        slider.value = Float(value)
        slider.minimumTrackTintColor = UIColor(Color.primaryPurple)
        slider.maximumTrackTintColor = UIColor(Color.primaryPurple.opacity(0.2))
        slider.isContinuous = true // Smooth updates

        // Create solid white thumb without glass effect
        let thumbImage = createThumbImage()
        slider.setThumbImage(thumbImage, for: .normal)
        slider.setThumbImage(thumbImage, for: .highlighted)
        slider.setThumbImage(thumbImage, for: .selected)
        slider.setThumbImage(thumbImage, for: .focused)

        slider.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged), for: .valueChanged)

        return slider
    }

    func updateUIView(_ uiView: UISlider, context: Context) {
        uiView.value = Float(value)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(value: $value, step: step)
    }

    private func createThumbImage() -> UIImage {
        let size = CGSize(width: 36, height: 36)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let ctx = context.cgContext

            // Enable anti-aliasing for smooth circle
            ctx.setAllowsAntialiasing(true)
            ctx.setShouldAntialias(true)

            // Draw white filled circle (no shadow)
            let circlePath = UIBezierPath(ovalIn: CGRect(x: 3, y: 3, width: 30, height: 30))
            UIColor.white.setFill()
            circlePath.fill()

            // Draw purple border
            UIColor(Color.primaryPurple).setStroke()
            let borderPath = UIBezierPath(ovalIn: CGRect(x: 4, y: 4, width: 28, height: 28))
            borderPath.lineWidth = 3
            borderPath.stroke()
        }
    }

    class Coordinator: NSObject {
        var value: Binding<Int>
        let step: Int

        init(value: Binding<Int>, step: Int) {
            self.value = value
            self.step = step
        }

        @objc func valueChanged(_ sender: UISlider) {
            let steppedValue = round(sender.value / Float(step)) * Float(step)
            value.wrappedValue = Int(steppedValue)
        }
    }
}

#Preview {
    OnboardingQuizView(
        userProfile: .constant(UserProfile()),
        onComplete: {}
    )
}
