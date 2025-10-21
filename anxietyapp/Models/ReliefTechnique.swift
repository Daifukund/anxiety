//
//  ReliefTechnique.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import Foundation
import SwiftUI

struct ReliefTechnique: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let type: TechniqueType

    enum TechniqueType {
        case breathing
        case grounding
        case physical
        case perspective
        case journal
        case stats
    }

    static let allTechniques: [ReliefTechnique] = [
        ReliefTechnique(
            title: "Breathing",
            subtitle: "Calm your nervous system",
            icon: "wind",
            color: Color.lightBlue,
            type: .breathing
        ),
        ReliefTechnique(
            title: "Grounding",
            subtitle: "Reconnect to the present",
            icon: "figure.walk",
            color: Color.softViolet,
            type: .grounding
        ),
        ReliefTechnique(
            title: "Physical Reset",
            subtitle: "Release body tension",
            icon: "figure.wave",
            color: Color.success,
            type: .physical
        ),
        ReliefTechnique(
            title: "Perspective",
            subtitle: "See the bigger picture",
            icon: "globe",
            color: Color.orange,
            type: .perspective
        )
    ]
}