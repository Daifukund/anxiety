//
//  PerspectiveReminder.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import Foundation
import SwiftUI

struct PerspectiveReminder: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let visualType: VisualType
    let category: Category

    enum VisualType {
        case stars
        case earth
        case time
        case timeFuture
        case space
    }

    enum Category {
        case existential
        case temporal
        case spatial
        case universal
    }

    static let allReminders: [PerspectiveReminder] = [
        // Existential
        PerspectiveReminder(
            title: "You are one human",
            message: "You are 1 human among 8 billion on a rock spinning through infinite space. This worry is small.",
            visualType: .space,
            category: .existential
        ),
        PerspectiveReminder(
            title: "You only live once",
            message: "You get one life, one chance at this experience. Don't waste it on worry.",
            visualType: .earth,
            category: .existential
        ),

        // Spatial
        PerspectiveReminder(
            title: "Infinite cosmos",
            message: "In the immensity of the universe, this fear is dust. You are safe in the vastness.",
            visualType: .stars,
            category: .universal
        ),
        PerspectiveReminder(
            title: "Zoom out",
            message: "From space, your problems disappear. You can't even see your city, let alone your stress.",
            visualType: .earth,
            category: .spatial
        ),

        // Temporal
        PerspectiveReminder(
            title: "This too shall pass",
            message: "No one will remember this moment, not even you in a year. All storms pass.",
            visualType: .time,
            category: .temporal
        ),
        PerspectiveReminder(
            title: "Future self",
            message: "Your future self is looking back at this moment with compassion. You got through it.",
            visualType: .timeFuture,
            category: .temporal
        )
    ]

    var backgroundColor: Color {
        // Consistent calming gradient across all cards
        return Color.indigo.opacity(0.8)
    }

    var accentColor: Color {
        // Consistent soft white/light text for readability
        return Color.white.opacity(0.95)
    }
}