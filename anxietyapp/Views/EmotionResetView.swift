//
//  EmotionResetView.swift
//  anxietyapp
//
//  Created by Claude Code on 30/09/2025.
//

import SwiftUI
import Foundation

struct EmotionResetView: View {
    @Environment(\.isDarkMode) var isDarkMode
    let navigateToDashboard: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var hasStarted = false
    @State private var currentStep = 0
    @State private var selectedEmoji = ""
    @State private var emotionName = ""
    @State private var selectedOrigin: EmotionOrigin?
    @State private var reflectionText = ""
    @State private var showCompletion = false
    @State private var isEmotionReleased = false
    @State private var isHolding = false
    @State private var holdProgress: CGFloat = 0
    @State private var explosionParticles: [ExplosionParticle] = []
    @State private var transformedEmoji = ""
    @State private var showTransformed = false
    @State private var holdTask: Task<Void, Never>?
    @State private var showingSummary = false

    let steps = ["Identify", "Origin", "Release", "Compassion"]

    var body: some View {
        ZStack {
            Color.adaptiveBackground(isDark: isDarkMode).ignoresSafeArea()

            if !hasStarted {
                introductionView
            } else {
                exerciseView
            }
        }
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
        .onDisappear {
            holdTask?.cancel()
        }
        .sheet(isPresented: $showingSummary) {
            ReliefSummaryView(
                completedTechnique: "Emotion Reset",
                onTryAnother: {
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

    // MARK: - Introduction View
    private var introductionView: some View {
        VStack(spacing: 0) {
            // Header with X button
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
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)

            Spacer()

            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    // Title
                    Text("Emotion Reset")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                    // Time
                    Text("Let go and return to peace . 1-2 minutes")
                        .font(.system(size: 17))
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                        .multilineTextAlignment(.center)
                }

                // Icon
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 72))
                    .foregroundColor(Color.primaryPurple)
                    .padding(.top, 8)

                // Description
                Text("Identify → Understand → Release → Heal")
                    .font(.system(size: 15))
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode).opacity(isDarkMode ? 0.9 : 0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            Spacer()

            // Begin button
            Button(action: {
                HapticManager.shared.impact(.medium)
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    hasStarted = true
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
            .padding(.horizontal, 24)
            .padding(.bottom, 120)
        }
        .gradientBackground()
    }

    // MARK: - Exercise View
    private var exerciseView: some View {
        VStack(spacing: 0) {
            // Header
            headerSection

            // Progress indicator
            progressIndicator

            // Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    switch currentStep {
                    case 0:
                        identifyStep
                    case 1:
                        originStep
                    case 2:
                        releaseStep
                    case 3:
                        compassionStep
                    default:
                        EmptyView()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity)
            }
            .scrollDisabled(currentStep == 2)
        }
    }

    // MARK: - Header
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

            Text("Emotion Reset")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

            Spacer()

            if currentStep > 0 && currentStep <= 2 {
                Button(action: {
                    HapticManager.shared.impact(.soft)
                    showingSummary = true
                }) {
                    Text("Skip")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                }
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Progress Indicator
    private var progressIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<steps.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index <= currentStep ? Color.primaryPurple : Color.adaptiveDivider(isDark: isDarkMode))
                    .frame(height: 3)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }

    // MARK: - Step 1: Identify
    private var identifyStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("What are you feeling?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(typicalEmotions, id: \.name) { emotion in
                    Button(action: {
                        HapticManager.shared.impact(.medium)

                        selectedEmoji = emotion.emoji
                        emotionName = emotion.name

                        // Auto-advance to next step after selection
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                currentStep += 1
                            }
                        }
                    }) {
                        VStack(spacing: 6) {
                            Text(emotion.emoji)
                                .font(.system(size: 36))

                            Text(emotion.name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(
                                    selectedEmoji == emotion.emoji && emotionName == emotion.name
                                    ? Color.adaptiveText(isDark: isDarkMode)
                                    : (isDarkMode ? Color.adaptiveText(isDark: isDarkMode).opacity(0.85) : Color.adaptiveSecondaryText(isDark: isDarkMode))
                                )
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 90)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedEmoji == emotion.emoji && emotionName == emotion.name ? Color.primaryPurple.opacity(0.12) : Color.adaptiveSupportGray(isDark: isDarkMode))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedEmoji == emotion.emoji && emotionName == emotion.name ? Color.primaryPurple : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    // MARK: - Step 2: Origin
    private var originStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Where does this come from?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

            VStack(spacing: 10) {
                ForEach(EmotionOrigin.allCases, id: \.self) { origin in
                    Button(action: {
                        HapticManager.shared.impact(.medium)

                        selectedOrigin = origin

                        // Auto-advance to next step after selection
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                currentStep += 1
                            }
                        }
                    }) {
                        HStack(spacing: 14) {
                            Image(systemName: origin.icon)
                                .font(.system(size: 18))
                                .foregroundColor(selectedOrigin == origin ? .white : Color.primaryPurple)
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(selectedOrigin == origin ? Color.primaryPurple : Color.primaryPurple.opacity(0.1))
                                )

                            Text(origin.rawValue)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedOrigin == origin ? Color.primaryPurple.opacity(0.08) : Color.adaptiveSupportGray(isDark: isDarkMode))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedOrigin == origin ? Color.primaryPurple : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    // MARK: - Step 3: Release
    private var releaseStep: some View {
        VStack(spacing: 32) {
            // Title and instruction
            VStack(spacing: 12) {
                Text("Release")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                Text(isEmotionReleased ? "Released" : (isHolding ? "Keep holding..." : "Press and hold"))
                    .font(.system(size: 15))
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            // Center circle with emotion - directly pressable
            ZStack {
                // Explosion particles (only show during explosion)
                if isEmotionReleased && !showTransformed {
                    ForEach(explosionParticles) { particle in
                        Text(selectedEmoji)
                            .font(.system(size: 20))
                            .opacity(particle.opacity)
                            .offset(x: particle.offset.width, y: particle.offset.height)
                            .scaleEffect(particle.scale)
                            .rotationEffect(.degrees(particle.rotation))
                    }
                }

                if !isEmotionReleased {
                    // Main pressable circle (before release)
                    Button(action: {}) {
                        ZStack {
                            // Outer progress ring
                            Circle()
                                .stroke(Color.primaryPurple.opacity(0.2), lineWidth: 6)
                                .frame(width: 200, height: 200)

                            Circle()
                                .trim(from: 0, to: holdProgress)
                                .stroke(Color.primaryPurple, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                .frame(width: 200, height: 200)
                                .rotationEffect(.degrees(-90))

                            // Inner circle
                            Circle()
                                .fill(Color.primaryPurple.opacity(0.15 + (Double(holdProgress) * 0.15)))
                                .frame(width: 180, height: 180)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primaryPurple, lineWidth: isHolding ? 3 : 2)
                                )

                            // Crack overlay when holding
                            if isHolding && holdProgress > 0.3 {
                                Circle()
                                    .frame(width: 180, height: 180)
                                    .overlay(
                                        CrackOverlay(progress: holdProgress)
                                    )
                                    .clipShape(Circle())
                            }

                            // Emotion emoji and name
                            VStack(spacing: 12) {
                                Text(selectedEmoji)
                                    .font(.system(size: 72))
                                    .scaleEffect(isHolding ? 0.9 : 1.0)

                                Text(emotionName)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode).opacity(isHolding ? 0.7 : 1.0))
                            }
                            .opacity(isHolding ? Double(1.0 - holdProgress * 0.5) : 1.0)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !isHolding {
                                    startHolding()
                                }
                            }
                            .onEnded { _ in
                                if isHolding && holdProgress < 1.0 {
                                    cancelHolding()
                                }
                            }
                    )
                    .transition(.opacity)
                }

                if showTransformed {
                    // Transformed positive emoji
                    VStack(spacing: 16) {
                        Text(transformedEmoji)
                            .font(.system(size: 80))

                        Text("Released")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color.primaryPurple)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(width: UIScreen.main.bounds.width - 48, height: 300)
            .clipped()
            .padding(.vertical, 60)
        }
        .frame(maxWidth: .infinity)
    }

    private func startHolding() {
        isHolding = true
        holdProgress = 0

        // Cancel any existing task
        holdTask?.cancel()

        // Light haptic at start
        HapticManager.shared.impact(.medium)

        // Manually update progress over 4 seconds using Task
        holdTask = Task { @MainActor in
            let totalDuration: Double = 4.0
            let updateInterval: Double = 0.05 // 50ms updates for smooth animation
            let totalSteps = Int(totalDuration / updateInterval)

            for step in 0...totalSteps {
                guard !Task.isCancelled && isHolding else { return }

                let progress = CGFloat(step) / CGFloat(totalSteps)
                withAnimation(.linear(duration: updateInterval)) {
                    holdProgress = progress
                }

                // Haptic feedback every 0.5 seconds
                if step % 10 == 0 && step > 0 {
                    HapticManager.shared.impact(.light)
                }

                // Check if we need to complete
                if step == totalSteps {
                    completeRelease()
                    return
                }

                try? await Task.sleep(nanoseconds: UInt64(updateInterval * 1_000_000_000))
            }
        }
    }

    private func cancelHolding() {
        isHolding = false
        holdTask?.cancel()
        withAnimation(.easeOut(duration: 0.2)) {
            holdProgress = 0
        }
    }

    private func completeRelease() {
        // Success haptic
        HapticManager.shared.notification(.success)

        // Get transformed emoji
        transformedEmoji = getTransformedEmoji()

        // Sequence the animation perfectly
        Task { @MainActor in
            // Step 1: Hide button/circles, create explosion particles at center
            createExplosionParticles()

            withAnimation(.easeOut(duration: 0.3)) {
                isEmotionReleased = true // This hides the button and shows particles
            }

            // Brief moment for state change to settle
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05s

            // Step 2: Animate explosion outward (0.7 seconds)
            withAnimation(.easeOut(duration: 0.7)) {
                animateExplosionParticles()
            }

            // Wait for explosion to expand
            try? await Task.sleep(nanoseconds: 400_000_000) // 0.4s

            // Step 3: Fade out explosion particles
            withAnimation(.easeOut(duration: 0.4)) {
                fadeExplosionParticles()
            }

            // Wait for particles to start fading
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s

            // Step 4: Show transformed emoji with spring animation
            withAnimation(.spring(response: 0.8, dampingFraction: 0.65)) {
                showTransformed = true // This hides particles and shows new emoji
            }

            // Step 5: Auto-advance after showing result
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2s
            guard !Task.isCancelled else { return }

            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                currentStep += 1
            }
        }
    }

    private func createExplosionParticles() {
        explosionParticles = []

        for i in 0..<12 {
            let angle = (Double(i) / 12.0) * 2 * .pi

            let particle = ExplosionParticle(
                offset: CGSize(width: 0, height: 0), // Start at center
                scale: 1.0,
                opacity: 1.0, // Start fully visible
                rotation: 0,
                finalOffset: CGSize(
                    width: CGFloat(cos(angle)) * 150,
                    height: CGFloat(sin(angle)) * 150
                ),
                finalRotation: Double.random(in: -360...360)
            )
            explosionParticles.append(particle)
        }
    }

    private func animateExplosionParticles() {
        for i in 0..<explosionParticles.count {
            explosionParticles[i].offset = explosionParticles[i].finalOffset
            explosionParticles[i].rotation = explosionParticles[i].finalRotation
            explosionParticles[i].scale = CGFloat.random(in: 0.4...0.8)
        }
    }

    private func fadeExplosionParticles() {
        for i in 0..<explosionParticles.count {
            explosionParticles[i].opacity = 0
        }
    }

    private func getTransformedEmoji() -> String {
        // Map negative emotions to positive transformations
        switch emotionName.lowercased() {
        case "anxious", "worried", "scared":
            return "😌" // Calm
        case "overwhelmed", "stressed":
            return "😮‍💨" // Relieved
        case "sad", "depressed", "hurt":
            return "☺️" // Peaceful
        case "angry", "frustrated":
            return "💪" // Strong/Empowered
        default:
            return "😊" // Happy default
        }
    }

    // MARK: - Step 4: Compassion
    private var compassionStep: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Color.primaryPurple)

                Text("You're doing your best")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 32)

            VStack(alignment: .leading, spacing: 16) {
                Text("Remember:")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))

                ForEach(compassionAffirmations, id: \.self) { affirmation in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color.primaryPurple.opacity(0.3))
                            .frame(width: 6, height: 6)

                        Text(affirmation)
                            .font(.system(size: 16))
                            .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primaryPurple.opacity(0.06))
            )

            // Complete button integrated into step
            Button(action: {
                HapticManager.shared.impact(.medium)
                showingSummary = true
            }) {
                Text("Complete")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.primaryPurple)
                    )
            }
            .padding(.top, 8)

            Spacer()
        }
    }

    // MARK: - Helper Properties
    private var canProceed: Bool {
        switch currentStep {
        case 0:
            return !selectedEmoji.isEmpty && !emotionName.isEmpty
        case 1:
            return selectedOrigin != nil
        case 2:
            return isEmotionReleased
        case 3:
            return true
        default:
            return false
        }
    }

    // MARK: - Actions
    private func nextStep() {
        HapticManager.shared.impact(.medium)

        if currentStep < 3 {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                currentStep += 1
            }
        } else {
            // Complete the exercise
            dismiss()
        }
    }

    private func previousStep() {
        HapticManager.shared.impact(.light)

        if currentStep > 0 {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                currentStep -= 1
            }
            // Reset release state if going back to release step
            if currentStep == 2 {
                holdTask?.cancel()
                isEmotionReleased = false
                isHolding = false
                holdProgress = 0
                explosionParticles = []
                showTransformed = false
            }
        }
    }
}

// MARK: - Supporting Types
enum EmotionOrigin: String, CaseIterable {
    case relationship = "Relationship"
    case family = "Family"
    case work = "Work or Studies"
    case money = "Money"
    case self_ = "Self"
    case other = "Other"

    var icon: String {
        switch self {
        case .relationship: return "heart.fill"
        case .family: return "house.fill"
        case .work: return "briefcase.fill"
        case .money: return "dollarsign.circle.fill"
        case .self_: return "person.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

// MARK: - Constants
struct EmotionOption {
    let emoji: String
    let name: String
}

private let typicalEmotions = [
    EmotionOption(emoji: "😰", name: "Anxious"),
    EmotionOption(emoji: "😢", name: "Sad"),
    EmotionOption(emoji: "😡", name: "Angry"),
    EmotionOption(emoji: "😫", name: "Overwhelmed"),
    EmotionOption(emoji: "😟", name: "Worried"),
    EmotionOption(emoji: "😓", name: "Stressed"),
    EmotionOption(emoji: "😨", name: "Scared"),
    EmotionOption(emoji: "🥺", name: "Hurt"),
    EmotionOption(emoji: "😩", name: "Frustrated"),
    EmotionOption(emoji: "😔", name: "Depressed")
]

private let compassionAffirmations = [
    "It's okay to feel what I'm feeling",
    "My emotions are valid and important",
    "I deserve kindness and understanding",
    "I'm doing the best I can right now"
]

struct ExplosionParticle: Identifiable {
    let id = UUID()
    var offset: CGSize
    var scale: CGFloat
    var opacity: Double
    var rotation: Double
    let finalOffset: CGSize
    let finalRotation: Double
}

struct CrackOverlay: View {
    let progress: CGFloat

    var body: some View {
        Canvas { context, size in
            guard size.width > 0 && size.height > 0 else { return }

            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = size.width / 2

            var path = Path()

            // Create crack lines based on progress
            if progress > 0.3 {
                path.move(to: center)
                path.addLine(to: CGPoint(
                    x: center.x + radius * cos(0.2),
                    y: center.y + radius * sin(0.2)
                ))
            }

            if progress > 0.5 {
                path.move(to: center)
                path.addLine(to: CGPoint(
                    x: center.x + radius * cos(1.8),
                    y: center.y + radius * sin(1.8)
                ))
            }

            if progress > 0.7 {
                path.move(to: center)
                path.addLine(to: CGPoint(
                    x: center.x + radius * cos(3.5),
                    y: center.y + radius * sin(3.5)
                ))
            }

            if progress > 0.85 {
                path.move(to: center)
                path.addLine(to: CGPoint(
                    x: center.x + radius * cos(5.0),
                    y: center.y + radius * sin(5.0)
                ))
            }

            context.stroke(path, with: .color(.white.opacity(0.8)), lineWidth: 2)
        }
    }
}

#Preview {
    EmotionResetView(navigateToDashboard: {})
}
