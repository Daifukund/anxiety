//
//  BreathingViewModel.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import Foundation
import Combine
#if os(iOS)
import UIKit
#endif

class BreathingViewModel: ObservableObject {
    @Published var currentPhase: BreathingPhase = .inhale
    @Published var progress: Double = 0.0
    @Published var cycleCount: Int = 0
    @Published var isActive: Bool = false
    @Published var showingQuickMenu: Bool = false

    private var timer: Timer?
    private let totalCycles = 4
    private let phaseDuration: TimeInterval = 4.0 // 4 seconds for box breathing (4-4-4-4)

    // MARK: - Lifecycle

    deinit {
        // Clean up timer to prevent memory leaks
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Breathing Phase

    enum BreathingPhase: String, CaseIterable {
        case inhale = "Breathe In"
        case holdIn = "Hold"
        case exhale = "Breathe Out"
        case holdOut = "Hold Out"

        var displayText: String {
            switch self {
            case .inhale:
                return "Inhale"
            case .holdIn, .holdOut:
                return "Hold"
            case .exhale:
                return "Exhale"
            }
        }

        var instruction: String {
            switch self {
            case .inhale:
                return "Breathe in slowly through your nose"
            case .holdIn:
                return "Hold your breath gently"
            case .exhale:
                return "Breathe out slowly through your mouth"
            case .holdOut:
                return "Hold your breath gently"
            }
        }
    }

    func startBreathing() {
        guard !isActive else { return }

        isActive = true
        cycleCount = 0
        currentPhase = .inhale
        progress = 0.0

        startPhaseTimer()
    }

    func stopBreathing() {
        timer?.invalidate()
        timer = nil
        isActive = false
        progress = 0.0
        cycleCount = 0
        currentPhase = .inhale
    }

    func skipToQuickMenu() {
        stopBreathing()
        showingQuickMenu = true
    }

    private func startPhaseTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.progress += 0.1 / self.phaseDuration

            if self.progress >= 1.0 {
                self.progress = 0.0
                self.moveToNextPhase()
            }
        }
    }

    private func moveToNextPhase() {
        let phases = BreathingPhase.allCases
        let currentIndex = phases.firstIndex(of: currentPhase) ?? 0
        let nextIndex = (currentIndex + 1) % phases.count

        currentPhase = phases[nextIndex]

        // If we completed a full cycle (back to inhale), increment cycle count
        if currentPhase == .inhale {
            cycleCount += 1

            if cycleCount >= totalCycles {
                completeBreathingExercise()
                return
            }
        }

        // Trigger haptic feedback at phase transitions
        triggerHapticFeedback()
    }

    private func completeBreathingExercise() {
        stopBreathing()
        showingQuickMenu = true
    }

    private func triggerHapticFeedback() {
        HapticManager.shared.impact(.light)
    }
}