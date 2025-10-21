//
//  RatingService.swift
//  anxietyapp
//
//  Manages App Store rating requests with smart timing
//  Only asks when user is in positive emotional state after relief
//

import Foundation
import StoreKit
import UIKit

class RatingService {
    static let shared = RatingService()

    // MARK: - UserDefaults Keys
    private let ratingRequestCountKey = "ratingRequestCount"
    private let lastRatingRequestDateKey = "lastRatingRequestDate"

    // MARK: - Constants
    private let minimumSessions = 5
    private let minimumStreak = 0  // No streak requirement - can show on first day after 5 exercises
    private let maximumRequests = 3
    private let daysBetweenRequests = 7  // 7 days between requests instead of 30

    private init() {}

    // MARK: - Public Methods

    /// Request rating if user is eligible (call when user taps "I'm Feeling Better")
    func requestRatingIfEligible() {
        guard shouldRequestRating() else { return }

        // Request rating from StoreKit
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)

            // Record that we made a request
            recordRatingRequest()

            #if DEBUG
            print("📊 Rating requested - Total requests: \(ratingRequestCount)")
            #endif
        }
    }

    // MARK: - Private Methods

    /// Check if all conditions are met to show rating prompt
    private func shouldRequestRating() -> Bool {
        let userDataService = UserDataService.shared

        // Condition 1: User has completed at least 5 sessions
        guard userDataService.userStats.totalSessions >= minimumSessions else {
            #if DEBUG
            print("❌ Rating: Not enough sessions (\(userDataService.userStats.totalSessions)/\(minimumSessions))")
            #endif
            return false
        }

        // Condition 2: User has at least 1 day streak
        guard userDataService.userStats.currentStreak >= minimumStreak else {
            #if DEBUG
            print("❌ Rating: Streak too low (\(userDataService.userStats.currentStreak)/\(minimumStreak))")
            #endif
            return false
        }

        // Condition 3: Haven't reached maximum request limit
        guard ratingRequestCount < maximumRequests else {
            #if DEBUG
            print("❌ Rating: Max requests reached (\(ratingRequestCount)/\(maximumRequests))")
            #endif
            return false
        }

        // Condition 4: Either never asked, or asked more than 30 days ago
        if let lastRequestDate = lastRatingRequestDate {
            let daysSinceLastRequest = Calendar.current.dateComponents(
                [.day],
                from: lastRequestDate,
                to: Date()
            ).day ?? 0

            guard daysSinceLastRequest >= daysBetweenRequests else {
                #if DEBUG
                print("❌ Rating: Too soon since last request (\(daysSinceLastRequest)/\(daysBetweenRequests) days)")
                #endif
                return false
            }
        }

        // All conditions met!
        #if DEBUG
        print("✅ Rating: Eligible! Sessions: \(userDataService.userStats.totalSessions), Streak: \(userDataService.userStats.currentStreak)")
        #endif
        return true
    }

    /// Record that we showed a rating request
    private func recordRatingRequest() {
        UserDefaults.standard.set(ratingRequestCount + 1, forKey: ratingRequestCountKey)
        UserDefaults.standard.set(Date(), forKey: lastRatingRequestDateKey)
    }

    // MARK: - UserDefaults Getters

    private var ratingRequestCount: Int {
        return UserDefaults.standard.integer(forKey: ratingRequestCountKey)
    }

    private var lastRatingRequestDate: Date? {
        return UserDefaults.standard.object(forKey: lastRatingRequestDateKey) as? Date
    }

    // MARK: - Debug Helper (for testing)

    #if DEBUG
    /// Reset rating request data (for testing only)
    func resetForTesting() {
        UserDefaults.standard.removeObject(forKey: ratingRequestCountKey)
        UserDefaults.standard.removeObject(forKey: lastRatingRequestDateKey)
        print("🔄 Rating data reset for testing")
    }

    /// Get current status (for debugging)
    func debugStatus() -> String {
        let userDataService = UserDataService.shared
        return """
        📊 Rating Service Status:
        - Sessions: \(userDataService.userStats.totalSessions) (need \(minimumSessions))
        - Streak: \(userDataService.userStats.currentStreak) (need \(minimumStreak))
        - Requests made: \(ratingRequestCount)/\(maximumRequests)
        - Last request: \(lastRatingRequestDate?.formatted() ?? "Never")
        - Eligible: \(shouldRequestRating() ? "YES ✅" : "NO ❌")
        """
    }
    #endif
}
