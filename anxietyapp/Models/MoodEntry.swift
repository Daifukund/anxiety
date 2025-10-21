//
//  MoodEntry.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import Foundation
import SwiftUI

struct MoodEntry: Identifiable, Codable {
    var id: UUID
    let date: Date
    let moodValue: Double // 0.0 (calm/green) to 1.0 (anxious/red)
    let sessionCount: Int // Number of relief sessions that day

    init(id: UUID = UUID(), date: Date, moodValue: Double, sessionCount: Int) {
        self.id = id
        self.date = date
        self.moodValue = moodValue
        self.sessionCount = sessionCount
    }

    // Color for this mood value on the gradient
    var color: Color {
        Color.moodGradient(for: moodValue)
    }

    // Description based on mood value
    var description: String {
        switch moodValue {
        case 0.0..<0.2:
            return "Very calm"
        case 0.2..<0.4:
            return "Calm"
        case 0.4..<0.6:
            return "Neutral"
        case 0.6..<0.8:
            return "A bit anxious"
        case 0.8...1.0:
            return "Very anxious"
        default:
            return "Neutral"
        }
    }
}

enum FavoriteExercise: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }
    case breathing = "Breathing"
    case grounding = "Grounding"
    case physicalReset = "Physical reset"
    case perspective = "Zoom out"
    case journal = "Quick dump"
    case reframe = "Reframe stress"
    case emotionReset = "Emotion Reset"

    var icon: String {
        switch self {
        case .breathing: return "wind"
        case .grounding: return "leaf.fill"
        case .physicalReset: return "bolt.fill"
        case .perspective: return "sparkles"
        case .journal: return "pencil.line"
        case .reframe: return "brain.head.profile"
        case .emotionReset: return "heart.text.square.fill"
        }
    }

    var color: (String, String) { // (light, dark) for gradient
        switch self {
        case .breathing: return ("#66B2F2", "#5199D9")        // Blue (0.40, 0.70, 0.95)
        case .grounding: return ("#73BF8C", "#5FA873")        // Green (0.45, 0.75, 0.55)
        case .physicalReset: return ("#F2A659", "#D98F47")    // Orange (0.95, 0.65, 0.35)
        case .perspective: return ("#BF99E6", "#A67FCC")      // Purple (0.75, 0.60, 0.90)
        case .journal: return ("#F28CA6", "#D9738C")          // Pink (0.95, 0.55, 0.65)
        case .reframe: return ("#8CB2F2", "#7399D9")          // Blue (0.55, 0.70, 0.95)
        case .emotionReset: return ("#D973BF", "#BF5FA6")     // Pink-purple (0.85, 0.45, 0.75)
        }
    }
}

struct UserStats: Codable {
    var totalSessions: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastSessionDate: Date?
    var moodEntries: [MoodEntry] = []
    var favoriteQuoteCategory: String = "calming"
    var favoriteExercises: [FavoriteExercise?] = [nil, nil, nil] // 3 slots for favorites

    // Performance optimization: Cache mood entries by date for O(1) lookup
    private var moodEntriesByDate: [String: MoodEntry] {
        let calendar = Calendar.current
        return Dictionary(uniqueKeysWithValues:
            moodEntries.map { entry in
                let dateKey = calendar.startOfDay(for: entry.date).timeIntervalSince1970
                return (String(dateKey), entry)
            }
        )
    }

    // Helper methods
    var sessionsThisWeek: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return moodEntries.filter { $0.date >= weekAgo }.reduce(0) { $0 + $1.sessionCount }
    }

    var averageMoodThisWeek: Double {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentEntries = moodEntries.filter { $0.date >= weekAgo }

        guard !recentEntries.isEmpty else { return 0 }

        let moodValues = recentEntries.map { $0.moodValue }
        return moodValues.reduce(0, +) / Double(moodValues.count)
    }

    func getMoodForDate(_ date: Date) -> MoodEntry? {
        let calendar = Calendar.current
        let dateKey = String(calendar.startOfDay(for: date).timeIntervalSince1970)
        return moodEntriesByDate[dateKey]
    }

    func getRecentMoods(days: Int = 7) -> [MoodEntry] {
        let calendar = Calendar.current
        let daysAgo = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return moodEntries
            .filter { $0.date >= daysAgo }
            .sorted { $0.date > $1.date }
    }
}