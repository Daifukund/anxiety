//
//  UnifiedSOSFlowView.swift
//  anxietyapp
//
//  Unified SOS flow combining breathing exercise and technique menu
//

import SwiftUI

struct UnifiedSOSFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isDarkMode) var isDarkMode
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let navigateToDashboard: () -> Void

    @State private var currentPhase: SOSPhase = .breathing
    @State private var selectedTechnique: ReliefTechnique?

    // Breathing state
    @State private var breathingPhase: BreathingPhase = .inhale1
    @State private var currentCycle = 0
    @State private var dotPosition: CGFloat = 0
    @State private var phaseText = "Inhale"
    @State private var startTime: Date?
    @State private var isCancelled = false

    private let totalCycles = 2
    private let cycleDuration: TimeInterval = 4.0 // 1s + 1s + 2s
    private let techniques = ReliefTechnique.allTechniques

    enum SOSPhase {
        case breathing
        case menu
    }

    enum BreathingPhase {
        case inhale1, hold1, inhale2, hold2, exhale

        var duration: Double {
            switch self {
            case .inhale1: return 2.5
            case .hold1: return 0.5
            case .inhale2: return 1.5
            case .hold2: return 0.5
            case .exhale: return 5.0
            }
        }

        var text: String {
            switch self {
            case .inhale1: return "Inhale deep"
            case .hold1: return "Inhale deep"
            case .inhale2: return "Inhale again"
            case .hold2: return "Inhale again"
            case .exhale: return "Exhale slow"
            }
        }

        var nextPhase: BreathingPhase {
            switch self {
            case .inhale1: return .hold1
            case .hold1: return .inhale2
            case .inhale2: return .hold2
            case .hold2: return .exhale
            case .exhale: return .inhale1
            }
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let visualizationHeight = min(320, screenHeight * 0.4) // Max 40% of screen height

            ZStack {
                // Shared gradient background matching app design
                AppGradient.adaptiveBackground(isDark: isDarkMode)
                    .ignoresSafeArea()

                // Phase content with smooth transition
                Group {
                    if currentPhase == .breathing {
                        breathingContent(visualizationHeight: visualizationHeight)
                            .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.95)))
                    } else {
                        menuContent
                            .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 1.05)))
                    }
                }
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: currentPhase)
            }
            .sheet(item: $selectedTechnique) { technique in
                techniqueDetailView(for: technique)
            }
            .onAppear {
                isCancelled = false
                startBreathingCycle()
            }
            .onDisappear {
                isCancelled = true
            }
        }
    }

    // MARK: - Breathing Phase Content

    private func breathingContent(visualizationHeight: CGFloat) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button(action: {
                        HapticManager.shared.impact(.soft)
                        dismiss()
                    }) {
                        Text("Skip")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.top, 20)
                .padding(.trailing, 24)

                Spacer()
                    .frame(height: 40)

                // Title and instruction
                VStack(spacing: 12) {
                    Text("Breathe In Twice")
                        .font(.system(size: min(34, visualizationHeight * 0.1), weight: .semibold))
                        .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)

                    Text("Inhale through your nose • Exhale through your mouth")
                        .font(.system(size: 15))
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.8)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, min(100, visualizationHeight * 0.3))

                // Breathing visualization
                curvePathVisualization(height: visualizationHeight)

                // Phase instruction
                VStack(spacing: 12) {
                    Text(phaseText)
                        .font(.system(size: min(40, visualizationHeight * 0.125), weight: .bold))
                        .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: phaseText)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)

                    if currentCycle < totalCycles {
                        Text("Cycle \(currentCycle + 1) of \(totalCycles)")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                    }
                }
                .padding(.top, min(-60, -visualizationHeight * 0.2))

                Spacer()
                    .frame(height: 60)
            }
        }
    }

    // MARK: - Menu Phase Content

    private var menuContent: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 60)

                    // Encouragement message
                    VStack(spacing: 12) {
                        Text("Keep Going")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                        Text("Try another technique or finish when ready")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 40)

                    // Techniques grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(techniques) { technique in
                            TechniqueCard(technique: technique) {
                                selectedTechnique = technique
                            }
                        }
                    }
                    .padding(.bottom, 32)

                    // Action button
                    Button(action: {
                        HapticManager.shared.impact(.medium)
                        dismiss()
                    }) {
                        Text("I'm Done")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.accentViolet)
                            .cornerRadius(16)
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }

            // Close button
            Button(action: {
                HapticManager.shared.impact(.light)
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
            }
            .padding(.top, 16)
            .padding(.trailing, 24)
        }
    }

    // MARK: - Breathing Visualization

    private func curvePathVisualization(height: CGFloat) -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let curveHeight = geometry.size.height

            ZStack {
                // Breathing curve path
                BreathingCurvePath()
                    .stroke(
                        Color.accentViolet.opacity(0.6),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: width * 0.85, height: curveHeight * 0.75)

                // Animated point
                Circle()
                    .fill(Color.accentViolet)
                    .frame(width: min(48, height * 0.15), height: min(48, height * 0.15))
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

        // New pattern: Inhale1 (0-0.25) -> Inhale2 (0.25-0.5) -> Exhale (0.5-1.0)
        if progress < 0.25 {
            // First inhale - smooth rise to 50%
            let localProgress = progress / 0.25
            let eased = 1 - cos(localProgress * .pi / 2)
            y = -eased * amplitude * 0.5
        } else if progress < 0.50 {
            // Second inhale - smooth rise from 50% to 100%
            let localProgress = (progress - 0.25) / 0.25
            let eased = 1 - cos(localProgress * .pi / 2)
            y = -(0.5 + eased * 0.5) * amplitude
        } else {
            // Exhale - smooth descent to baseline
            let localProgress = (progress - 0.50) / 0.50
            let eased = sin((1 - localProgress) * .pi / 2)
            y = -eased * amplitude
        }

        return CGPoint(x: x, y: y)
    }

    // MARK: - Breathing Logic

    private func startBreathingCycle() {
        startTime = Date()
        phaseText = "Inhale deep"

        HapticManager.shared.impact(.light)

        // Update position smoothly using TimelineView approach
        updateBreathingPosition()
    }

    private func updateBreathingPosition() {
        guard !isCancelled, let startTime = startTime else { return }

        let elapsed = Date().timeIntervalSince(startTime)
        let progress = elapsed / cycleDuration

        if progress >= 1.0 {
            // Cycle complete
            currentCycle += 1

            if currentCycle >= totalCycles {
                dotPosition = 1.0
                showCompletionAndTransition()
            } else {
                // Start next cycle
                self.startTime = Date()
                dotPosition = 0
                breathingPhase = .inhale1
                phaseText = "Inhale deep"  // Explicitly set text for cycle 2
                HapticManager.shared.impact(.light)
                updateBreathingPosition()
            }
            return
        }

        // Update dot position smoothly
        dotPosition = CGFloat(progress)

        // Update phase text based on elapsed time
        updatePhaseForTime(elapsed)

        // Schedule next update (60fps)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0/60.0) {
            self.updateBreathingPosition()
        }
    }

    private func updatePhaseForTime(_ elapsed: TimeInterval) {
        if elapsed < 1.0 {
            // First inhale: 0-1s
            if breathingPhase != .inhale1 {
                breathingPhase = .inhale1
                phaseText = breathingPhase.text
                HapticManager.shared.impact(.light)
            }
        } else if elapsed < 2.0 {
            // Second inhale: 1-2s
            if breathingPhase != .inhale2 {
                breathingPhase = .inhale2
                phaseText = breathingPhase.text
                HapticManager.shared.impact(.light)
            }
        } else {
            // Exhale: 2-4s
            if breathingPhase != .exhale {
                breathingPhase = .exhale
                phaseText = breathingPhase.text
                HapticManager.shared.impact(.medium)
            }
        }
    }


    private func showCompletionAndTransition() {
        phaseText = "Better. Keep going..."

        HapticManager.shared.impact(.medium)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            transitionToMenu()
        }
    }

    private func transitionToMenu() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentPhase = .menu
        }
    }

    // MARK: - Technique Detail Views

    @ViewBuilder
    private func techniqueDetailView(for technique: ReliefTechnique) -> some View {
        switch technique.type {
        case .breathing:
            BreathingExerciseView(navigateToDashboard: navigateToDashboard)
        case .grounding:
            GroundingExerciseView(navigateToDashboard: navigateToDashboard)
        case .physical:
            PhysicalResetView(navigateToDashboard: navigateToDashboard)
        case .perspective:
            PerspectiveShiftView(navigateToDashboard: navigateToDashboard)
        case .journal:
            QuickJournalView(navigateToDashboard: navigateToDashboard)
        case .stats:
            StatsView()
        }
    }
}

// MARK: - Technique Card Component

struct TechniqueCard: View {
    @Environment(\.isDarkMode) var isDarkMode
    let technique: ReliefTechnique
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(technique.color.opacity(0.15))
                        .frame(width: 64, height: 64)

                    Image(systemName: technique.icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(technique.color)
                }

                // Text
                VStack(spacing: 4) {
                    Text(technique.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                        .multilineTextAlignment(.center)

                    Text(technique.subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
            .background(Color.adaptiveSupportGray(isDark: isDarkMode))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(isDarkMode ? 0.3 : 0.06), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// Custom Shape to draw the breathing curve path
struct BreathingCurvePath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height
        let centerY = height / 2
        let amplitude = height * 0.55

        // Start point (left side, baseline)
        path.move(to: CGPoint(x: 0, y: centerY))

        // New pattern: Inhale1 (0-25%) -> Inhale2 (25-50%) -> Exhale (50-100%)
        let segments = 200
        for i in 0...segments {
            let progress = CGFloat(i) / CGFloat(segments)
            let x = progress * width

            var y: CGFloat = centerY

            if progress < 0.25 {
                // First inhale - smooth rise to 50%
                let localProgress = progress / 0.25
                let eased = 1 - cos(localProgress * .pi / 2)
                y = centerY - eased * amplitude * 0.5
            } else if progress < 0.50 {
                // Second inhale - smooth rise from 50% to 100%
                let localProgress = (progress - 0.25) / 0.25
                let eased = 1 - cos(localProgress * .pi / 2)
                y = centerY - (0.5 + eased * 0.5) * amplitude
            } else {
                // Exhale - smooth descent to baseline
                let localProgress = (progress - 0.50) / 0.50
                let eased = sin((1 - localProgress) * .pi / 2)
                y = centerY - eased * amplitude
            }

            path.addLine(to: CGPoint(x: x, y: y))
        }

        return path
    }
}

#Preview {
    UnifiedSOSFlowView(navigateToDashboard: {})
}
