//
//  Quote.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import Foundation
import SwiftUI

struct Quote: Identifiable, Codable {
    let id: UUID
    let text: String
    let author: String?
    let category: Category

    init(text: String, author: String?, category: Category) {
        self.id = UUID()
        self.text = text
        self.author = author
        self.category = category
    }

    enum Category: String, CaseIterable, Codable {
        case calming = "calming"
        case existential = "existential"
        case motivational = "motivational"

        var displayName: String {
            switch self {
            case .calming:
                return "Calming"
            case .existential:
                return "Perspective"
            case .motivational:
                return "Motivational"
            }
        }

        var color: Color {
            switch self {
            case .calming:
                return Color.lightBlue
            case .existential:
                return Color.softViolet
            case .motivational:
                return Color.success
            }
        }
    }

    // MARK: - Default Fallback Quote

    private static let defaultQuote = Quote(
        text: "Breathe. This moment will pass.",
        author: nil,
        category: .calming
    )

    static let allQuotes: [Quote] = [
        // Calming/Compassionate quotes
        Quote(text: "This is just a feeling. Feelings are not forever.", author: nil, category: .calming),
        Quote(text: "Your body is reacting, but you are safe right now.", author: nil, category: .calming),
        Quote(text: "Breathe. You've been here before, and you got through it.", author: nil, category: .calming),
        Quote(text: "Every storm passes. This one will too.", author: nil, category: .calming),
        Quote(text: "You are stronger than this moment.", author: nil, category: .calming),
        Quote(text: "The present moment is the only time we have.", author: "Thich Nhat Hanh", category: .calming),
        Quote(text: "You can't stop the waves, but you can learn to surf.", author: "Jon Kabat-Zinn", category: .calming),
        Quote(text: "Peace comes from within. Do not seek it without.", author: "Buddha", category: .calming),

        // Existential/Stoic quotes
        Quote(text: "No one will remember this moment, not even you in a year.", author: nil, category: .existential),
        Quote(text: "All this worry... for nothing. It will pass.", author: nil, category: .existential),
        Quote(text: "You are a speck on a rock spinning through infinite space. Breathe.", author: nil, category: .existential),
        Quote(text: "In the immensity of the universe, this fear is dust.", author: nil, category: .existential),
        Quote(text: "What we fear doing most is usually what we most need to do.", author: "Tim Ferriss", category: .existential),
        Quote(text: "The obstacle is the way.", author: "Marcus Aurelius", category: .existential),

        // Motivational/Grounding quotes
        Quote(text: "Focus on what you can control: inhale, exhale, repeat.", author: nil, category: .motivational),
        Quote(text: "Your anxiety is lying to you. Reality is calmer than your thoughts.", author: nil, category: .motivational),
        Quote(text: "Action dissolves fear. One breath, one step, one choice.", author: nil, category: .motivational),
        Quote(text: "You've already survived 100% of your bad days.", author: nil, category: .motivational),
        Quote(text: "This is not the end, it's just another wave.", author: nil, category: .motivational),
        Quote(text: "Small daily habits can reshape your brain and your life.", author: "Andrew Huberman", category: .motivational),
        Quote(text: "Every thought you repeat is a seed: plant fear and you grow anxiety; plant calm and you grow peace.", author: nil, category: .motivational),
        Quote(text: "Courage is not the absence of fear, but action in spite of it.", author: "Mark Twain", category: .motivational)
    ]

    static func getRandomQuote(from category: Category? = nil) -> Quote {
        if let category = category {
            let filtered = allQuotes.filter { $0.category == category }
            return filtered.randomElement() ?? allQuotes.randomElement() ?? defaultQuote
        }
        return allQuotes.randomElement() ?? defaultQuote
    }

    static func getDailyQuote() -> Quote {
        // Use today's date as seed for consistency
        let today = Calendar.current.startOfDay(for: Date())
        let daysSince1970 = Int(today.timeIntervalSince1970 / 86400)

        // Create a consistent but pseudo-random selection based on the day
        let index = daysSince1970 % allQuotes.count
        return allQuotes[index]
    }

    static func getQuotesForMoodValue(_ moodValue: Double) -> [Quote] {
        // 0.0 = very calm/green, 1.0 = very anxious/red
        switch moodValue {
        case 0.0..<0.4:
            // Calm to somewhat calm - motivational quotes
            return allQuotes.filter { $0.category == .motivational }
        case 0.4..<0.6:
            // Neutral - calming quotes
            return allQuotes.filter { $0.category == .calming }
        case 0.6...1.0:
            // Anxious to very anxious - calming or existential
            return allQuotes.filter { $0.category == .calming || $0.category == .existential }
        default:
            return allQuotes.filter { $0.category == .calming }
        }
    }
}