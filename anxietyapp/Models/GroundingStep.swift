//
//  GroundingStep.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import Foundation
import SwiftUI

struct GroundingStep: Identifiable {
    let id = UUID()
    let number: Int
    let sense: String
    let emoji: String
    let icon: String
    let instruction: String
    let example: String
    let action: String
    let color: Color

    static let allSteps: [GroundingStep] = [
        GroundingStep(
            number: 5,
            sense: "things you see",
            emoji: "👀",
            icon: "eye.fill",
            instruction: "Look around and notice five things in your environment.",
            example: "the chair, a window, a book, my shoes, the clock",
            action: "saw",
            color: Color(red: 0.4, green: 0.7, blue: 1.0) // Soft blue
        ),
        GroundingStep(
            number: 4,
            sense: "things you feel",
            emoji: "✋",
            icon: "hand.raised.fill",
            instruction: "Notice four things you can physically feel.",
            example: "my feet on the ground, my shirt against my skin, the air on my face, the pen in my hand",
            action: "felt",
            color: Color(red: 0.67, green: 0.58, blue: 0.85) // Soft violet
        ),
        GroundingStep(
            number: 3,
            sense: "things you hear",
            emoji: "👂",
            icon: "ear.fill",
            instruction: "Pay attention to three sounds.",
            example: "traffic outside, my breathing, a bird chirping",
            action: "heard",
            color: Color(red: 0.5, green: 0.85, blue: 0.65) // Soft green
        ),
        GroundingStep(
            number: 2,
            sense: "things you smell",
            emoji: "👃",
            icon: "nose.fill",
            instruction: "Focus on two scents or think of your two favorite smells.",
            example: "coffee, fresh air, or imagine lavender and vanilla",
            action: "smelled",
            color: Color(red: 1.0, green: 0.75, blue: 0.4) // Soft orange
        ),
        GroundingStep(
            number: 1,
            sense: "thing you taste",
            emoji: "👅",
            icon: "mouth.fill",
            instruction: "Notice one taste in your mouth or imagine one you love.",
            example: "toothpaste, coffee, or imagine chocolate",
            action: "tasted",
            color: Color(red: 0.95, green: 0.60, blue: 0.65) // Soft pink/red
        )
    ]
}
