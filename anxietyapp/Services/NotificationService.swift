//
//  NotificationService.swift
//  anxietyapp
//
//  Manages local push notifications for mood tracking and daily quotes
//

import Foundation
import UserNotifications
import SwiftUI
import Combine

class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()

    @Published var notificationPermissionGranted = false
    @Published var selectedNotificationAction: NotificationAction?

    let notificationCenter = UNUserNotificationCenter.current()

    // Notification identifiers
    private enum NotificationID {
        static let moodCheckIn = "mood-check-in"
        static let dailyQuote = "daily-quote"
        static let dailyQuotePrefix = "daily-quote-" // For multiple quotes per day
    }

    override private init() {
        super.init()
        notificationCenter.delegate = self
        setupNotificationCategories()
        checkPermissionStatus()
    }

    // MARK: - Notification Categories Setup

    private func setupNotificationCategories() {
        // Skip in preview mode
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            return
        }

        // Define categories for different notification types
        let moodCategory = UNNotificationCategory(
            identifier: "MOOD_CHECK_IN",
            actions: [],
            intentIdentifiers: [],
            options: []
        )

        let quoteCategory = UNNotificationCategory(
            identifier: "DAILY_QUOTE",
            actions: [],
            intentIdentifiers: [],
            options: []
        )

        // Register categories with notification center
        notificationCenter.setNotificationCategories([moodCategory, quoteCategory])
    }

    // MARK: - Permission Management

    func requestPermission(completion: ((Bool) -> Void)? = nil) {
        // Skip in preview mode
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            completion?(false)
            return
        }

        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.notificationPermissionGranted = granted
                completion?(granted)

                if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                }
            }
        }
    }

    func checkPermissionStatus() {
        // Skip in preview mode
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            return
        }

        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.notificationPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }

    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Mood Check-In Notifications

    func scheduleMoodCheckIn(enabled: Bool, time: Date) {
        // Skip in preview mode
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            return
        }

        // Cancel existing mood check-in notification
        cancelMoodCheckIn()

        guard enabled, notificationPermissionGranted else { return }

        // Check if user has already checked in today
        if UserDataService.shared.hasCheckedInToday() {
            return // Don't schedule if already checked in
        }

        let content = UNMutableNotificationContent()
        content.title = "How are you feeling? 💙"
        content.body = "Take a moment to check in with yourself"
        content.sound = .default
        content.categoryIdentifier = "MOOD_CHECK_IN"

        // Extract hour and minute from the time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)

        // Create daily trigger
        var dateComponents = DateComponents()
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: NotificationID.moodCheckIn,
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling mood check-in: \(error.localizedDescription)")
            } else {
                print("✅ Mood check-in notification scheduled for \(components.hour ?? 0):\(components.minute ?? 0)")
            }
        }
    }

    func cancelMoodCheckIn() {
        // Skip in preview mode to avoid crashes
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            return
        }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [NotificationID.moodCheckIn])
    }

    // MARK: - Daily Quote Notifications

    func scheduleDailyQuote(enabled: Bool, time: Date) {
        // Skip in preview mode
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            return
        }

        // Cancel existing quote notifications
        cancelDailyQuote()

        guard enabled, notificationPermissionGranted else { return }

        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)

        // Schedule quotes for the next 30 days
        // This ensures the quote updates daily with the correct content
        for dayOffset in 0..<30 {
            guard let futureDate = calendar.date(byAdding: .day, value: dayOffset, to: Date()) else { continue }

            // Get the quote for this specific day
            let quote = getQuoteForDate(futureDate)

            // Create notification content with the actual quote
            let content = UNMutableNotificationContent()
            content.title = "Daily Inspiration 💜"
            content.body = quote.text
            content.sound = .default
            content.categoryIdentifier = "DAILY_QUOTE"

            // Set the exact date and time for this notification
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: futureDate)
            dateComponents.hour = timeComponents.hour
            dateComponents.minute = timeComponents.minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            // Create unique identifier for each day's notification
            let identifier = "\(NotificationID.dailyQuotePrefix)\(dayOffset)"

            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )

            notificationCenter.add(request) { error in
                if let error = error {
                    print("Error scheduling daily quote for day \(dayOffset): \(error.localizedDescription)")
                }
            }
        }

        print("✅ Daily quote notifications scheduled for next 30 days at \(timeComponents.hour ?? 0):\(timeComponents.minute ?? 0)")
    }

    /// Get the quote that should be shown for a specific date
    /// Uses the same algorithm as Quote.getDailyQuote() but for any date
    private func getQuoteForDate(_ date: Date) -> Quote {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let daysSince1970 = Int(startOfDay.timeIntervalSince1970 / 86400)
        let index = daysSince1970 % Quote.allQuotes.count
        return Quote.allQuotes[index]
    }

    func cancelDailyQuote() {
        // Skip in preview mode
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            return
        }

        // Cancel all daily quote notifications (30 days worth)
        var identifiers: [String] = []
        for dayOffset in 0..<30 {
            identifiers.append("\(NotificationID.dailyQuotePrefix)\(dayOffset)")
        }

        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // MARK: - Cancel All Notifications

    func cancelAllNotifications() {
        // Skip in preview mode
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            return
        }
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }

    // MARK: - Debug Helper

    func listScheduledNotifications() {
        // Skip in preview mode
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
            return
        }
        notificationCenter.getPendingNotificationRequests { requests in
            print("📅 Scheduled notifications (\(requests.count)):")
            for request in requests {
                print("  - \(request.identifier): \(request.content.title)")
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let nextTriggerDate = trigger.nextTriggerDate() {
                    print("    Next trigger: \(nextTriggerDate)")
                }
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.notification.request.identifier

        // Trigger navigation based on notification type
        DispatchQueue.main.async { [weak self] in
            if identifier == NotificationID.moodCheckIn {
                print("📱 User tapped mood check-in notification → Opening mood selection")
                self?.selectedNotificationAction = .openMoodCheckIn
            } else if identifier == NotificationID.dailyQuote {
                print("📱 User tapped daily quote notification → Opening daily quote")
                self?.selectedNotificationAction = .openDailyQuote
            }
        }

        completionHandler()
    }
}

// MARK: - Notification Actions
enum NotificationAction {
    case openMoodCheckIn
    case openDailyQuote
}
