//
//  PhysicalExercise.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import Foundation
import SwiftUI

struct PhysicalResetStep: Identifiable {
    let id = UUID()
    let title: String
    let duration: Int // in seconds
    let instruction: String
    let icon: String
    let color: Color
}

struct PhysicalExercise {
    let steps: [PhysicalResetStep]

    static let unifiedReset = PhysicalExercise(
        steps: [
            PhysicalResetStep(
                title: "Stand Up",
                duration: 5,
                instruction: "Stand up and plant your feet firmly on the ground, arms relaxed at your sides.",
                icon: "figure.stand",
                color: Color.lightBlue
            ),
            PhysicalResetStep(
                title: "Tense Everything",
                duration: 10,
                instruction: "Squeeze every muscle as tight as you can: make fists, tighten your jaw, shoulders, core, and legs.",
                icon: "figure.strengthtraining.traditional",
                color: Color.warning
            ),
            PhysicalResetStep(
                title: "Release & Loosen",
                duration: 15,
                instruction: "Let all the tension go at once. Shake your hands, roll your shoulders, and breathe deeply.",
                icon: "figure.wave",
                color: Color.success
            )
        ]
    )
}
