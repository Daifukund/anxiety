//
//  UserDataService.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import Foundation
import Combine

class UserDataService: ObservableObject {
    static let shared = UserDataService()

    @Published var userStats = UserStats()

    private let keychain = KeychainManager.shared
    private let userStatsKey = "UserStats"

    private init() {
        migrateFromUserDefaultsIfNeeded()
        loadUserStats()
        calculateStreak()
    }

    // MARK: - Data Persistence

    /// Migrate data from UserDefaults to Keychain (one-time migration)
    private func migrateFromUserDefaultsIfNeeded() {
        let userDefaults = UserDefaults.standard
        let migrationKey = "UserStats_Migrated_To_Keychain"

        // Check if already migrated
        guard !userDefaults.bool(forKey: migrationKey) else {
            return
        }

        // Migrate UserStats from UserDefaults to Keychain
        if let data = userDefaults.data(forKey: userStatsKey) {
            if keychain.save(data, forKey: userStatsKey) {
                // Migration successful, remove from UserDefaults
                userDefaults.removeObject(forKey: userStatsKey)
                userDefaults.set(true, forKey: migrationKey)

                #if DEBUG
                print("✅ UserDataService: Migrated UserStats to Keychain")
                #endif
            }
        } else {
            // No data to migrate, mark as migrated
            userDefaults.set(true, forKey: migrationKey)
        }
    }

    private func loadUserStats() {
        // Try loading from Keychain (secure)
        if let stats = keychain.getObject(forKey: userStatsKey, as: UserStats.self) {
            userStats = stats
            return
        }

        // Fallback: Try loading from UserDefaults (legacy, should not happen after migration)
        let userDefaults = UserDefaults.standard
        if let data = userDefaults.data(forKey: userStatsKey),
           let stats = try? JSONDecoder().decode(UserStats.self, from: data) {
            userStats = stats

            // Save to Keychain for next time
            _ = keychain.save(stats, forKey: userStatsKey)
            userDefaults.removeObject(forKey: userStatsKey)

            #if DEBUG
            print("⚠️ UserDataService: Loaded from UserDefaults (legacy), migrated to Keychain")
            #endif
        }
    }

    private func saveUserStats() {
        // Save to Keychain (secure)
        if !keychain.save(userStats, forKey: userStatsKey) {
            #if DEBUG
            print("❌ UserDataService: Failed to save UserStats to Keychain")
            #endif

            // Fallback to UserDefaults (should rarely happen)
            if let data = try? JSONEncoder().encode(userStats) {
                UserDefaults.standard.set(data, forKey: userStatsKey)
            }
        }
    }

    // MARK: - Mood Tracking
    func recordMoodValue(_ moodValue: Double) {
        objectWillChange.send()

        let today = Date()
        let calendar = Calendar.current

        // Get today's session count BEFORE removing the entry
        let todaysSessionCount = getTodaysSessionCount()

        // Remove existing entry for today if any
        userStats.moodEntries.removeAll { calendar.isDate($0.date, inSameDayAs: today) }

        // Add new entry with preserved session count
        let entry = MoodEntry(date: today, moodValue: moodValue, sessionCount: todaysSessionCount)
        userStats.moodEntries.append(entry)

        calculateStreak()
        saveUserStats()

        // Cancel today's mood check-in notification since user has checked in
        NotificationService.shared.cancelMoodCheckIn()
    }

    func getTodaysMoodValue() -> Double? {
        return userStats.getMoodForDate(Date())?.moodValue
    }

    // MARK: - Session Tracking
    func recordSession(technique: String) {
        objectWillChange.send()

        userStats.totalSessions += 1
        userStats.lastSessionDate = Date()

        // Update today's session count in mood entry if exists, or create one
        let calendar = Calendar.current
        let today = Date()

        if let index = userStats.moodEntries.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            // Update existing mood entry
            let entry = userStats.moodEntries[index]
            userStats.moodEntries[index] = MoodEntry(
                date: entry.date,
                moodValue: entry.moodValue,
                sessionCount: entry.sessionCount + 1
            )
        } else {
            // Create a mood entry for today with neutral value if user hasn't checked in
            // This ensures sessions contribute to streak building
            let neutralMoodValue = 0.5 // Neutral mood value
            let entry = MoodEntry(date: today, moodValue: neutralMoodValue, sessionCount: 1)
            userStats.moodEntries.append(entry)
        }

        calculateStreak()
        saveUserStats()
    }

    private func getTodaysSessionCount() -> Int {
        let calendar = Calendar.current
        let today = Date()
        return userStats.moodEntries
            .first { calendar.isDate($0.date, inSameDayAs: today) }?.sessionCount ?? 0
    }

    // MARK: - Streak Calculation
    private func calculateStreak() {
        let calendar = Calendar.current
        let sortedEntries = userStats.moodEntries.sorted { $0.date > $1.date }

        guard !sortedEntries.isEmpty else {
            userStats.currentStreak = 0
            return
        }

        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())

        for entry in sortedEntries {
            let entryDate = calendar.startOfDay(for: entry.date)

            if calendar.isDate(entryDate, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if entryDate < currentDate {
                // Gap in streak
                break
            }
        }

        userStats.currentStreak = streak
        userStats.longestStreak = max(userStats.longestStreak, streak)
    }

    // MARK: - Helper Methods
    func hasCheckedInToday() -> Bool {
        return getTodaysMoodValue() != nil
    }

    func getStreakEmoji() -> String {
        switch userStats.currentStreak {
        case 0:
            return "🌱"
        case 1...2:
            return "🌿"
        case 3...6:
            return "🌳"
        case 7...13:
            return "🔥"
        default:
            return "⭐️"
        }
    }

    func getStreakMessage() -> String {
        switch userStats.currentStreak {
        case 0:
            return "Start your journey"
        case 1:
            return "Great start!"
        case 2...6:
            return "Building momentum"
        case 7...13:
            return "On fire!"
        default:
            return "Superstar streak!"
        }
    }

    // MARK: - Favorite Exercises
    func setFavoriteExercise(_ exercise: FavoriteExercise, at index: Int) {
        guard index >= 0 && index < 3 else { return }
        objectWillChange.send()
        userStats.favoriteExercises[index] = exercise
        saveUserStats()
    }

    func removeFavoriteExercise(at index: Int) {
        guard index >= 0 && index < 3 else { return }
        objectWillChange.send()
        userStats.favoriteExercises[index] = nil
        saveUserStats()
    }

    func getFavoriteExercise(at index: Int) -> FavoriteExercise? {
        guard index >= 0 && index < userStats.favoriteExercises.count else { return nil }
        return userStats.favoriteExercises[index]
    }
}