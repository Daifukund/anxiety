//
//  GroundingViewModel.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import Foundation
import Combine
#if os(iOS)
import UIKit
#endif

class GroundingViewModel: ObservableObject {
    @Published var isActive: Bool = false
    @Published var currentStepIndex: Int = 0
    @Published var completedSteps: Set<Int> = []
    @Published var isCompleted: Bool = false
    @Published var showingSummary: Bool = false
    @Published var itemsChecked: [Bool] = [false, false, false, false, false] // Max 5 items

    private let steps = GroundingStep.allSteps

    var currentStep: GroundingStep {
        return steps[currentStepIndex]
    }

    var progress: Double {
        return Double(completedSteps.count) / Double(steps.count)
    }

    var allItemsChecked: Bool {
        let requiredCount = currentStep.number
        return itemsChecked.prefix(requiredCount).allSatisfy { $0 }
    }

    func toggleItem(at index: Int) {
        guard index < currentStep.number else { return }
        itemsChecked[index].toggle()

        // Mark step as complete if all items are checked
        if allItemsChecked {
            completedSteps.insert(currentStepIndex)

            // Auto-advance to next step after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.moveToNextStep()
            }
        } else {
            completedSteps.remove(currentStepIndex)
        }
    }

    func moveToNextStep() {
        guard allItemsChecked else { return }

        if currentStepIndex < steps.count - 1 {
            currentStepIndex += 1
            resetCheckboxes()
        } else {
            completeExercise()
        }
    }

    func moveToPreviousStep() {
        if currentStepIndex > 0 {
            currentStepIndex -= 1
            resetCheckboxes()
        }
    }

    func start() {
        isActive = true
    }

    func reset() {
        isActive = false
        currentStepIndex = 0
        completedSteps.removeAll()
        isCompleted = false
        showingSummary = false
        resetCheckboxes()
    }

    private func resetCheckboxes() {
        itemsChecked = [false, false, false, false, false]
    }

    private func completeExercise() {
        isCompleted = true
        showingSummary = true

        // Trigger haptic feedback for completion
        HapticManager.shared.notification(.success)
    }
}