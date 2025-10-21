//
//  AppsFlyerService.swift
//  anxietyapp
//
//  AppsFlyer attribution and analytics service
//

import Foundation
import AppsFlyerLib

/// Service for managing AppsFlyer attribution and analytics
final class AppsFlyerService: NSObject {

    // MARK: - Singleton
    static let shared = AppsFlyerService()

    // MARK: - Properties
    private var devKey: String {
        return ConfigurationManager.appsFlyerDevKey
    }
    private let appID = "eunoia.anxietyapp" // Your bundle identifier

    // MARK: - Initialization
    private override init() {
        super.init()
    }

    // MARK: - Configuration

    /// Configure and start AppsFlyer SDK
    func configure() {
        // Set AppsFlyer Dev Key
        AppsFlyerLib.shared().appsFlyerDevKey = devKey
        AppsFlyerLib.shared().appleAppID = appID

        // Set delegate for attribution callbacks
        AppsFlyerLib.shared().delegate = self

        // Enable debug mode for development (disable in production)
        #if DEBUG
        AppsFlyerLib.shared().isDebug = true
        #endif

        // Disable IDFA collection to respect privacy (optional)
        // AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)

        // Log configuration
        print("AppsFlyer configured with Dev Key: \(devKey)")
    }

    /// Start tracking - call this when app becomes active
    func start() {
        AppsFlyerLib.shared().start()
        print("AppsFlyer tracking started")
    }

    // MARK: - Event Tracking

    /// Track a custom event
    /// - Parameters:
    ///   - eventName: Name of the event
    ///   - parameters: Optional parameters dictionary
    func logEvent(_ eventName: String, parameters: [String: Any]? = nil) {
        AppsFlyerLib.shared().logEvent(eventName, withValues: parameters)
        print("AppsFlyer event logged: \(eventName)")
    }

    // MARK: - Convenience Methods for App-Specific Events

    /// Track when user completes onboarding
    func trackOnboardingCompleted() {
        logEvent("onboarding_completed", parameters: [
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ])
    }

    /// Track SOS flow initiated
    func trackSOSFlowStarted() {
        logEvent("sos_flow_started", parameters: [
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ])
    }

    /// Track SOS flow completed
    /// - Parameter technique: The technique used (breathing, grounding, etc.)
    func trackSOSFlowCompleted(technique: String) {
        logEvent("sos_flow_completed", parameters: [
            "technique": technique,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ])
    }

    /// Track breathing exercise started
    /// - Parameter type: Type of breathing exercise (box, 4-7-8, etc.)
    func trackBreathingExerciseStarted(type: String) {
        logEvent("breathing_exercise_started", parameters: [
            "exercise_type": type,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ])
    }

    /// Track breathing exercise completed
    /// - Parameters:
    ///   - type: Type of breathing exercise
    ///   - duration: Duration in seconds
    func trackBreathingExerciseCompleted(type: String, duration: Int) {
        logEvent("breathing_exercise_completed", parameters: [
            "exercise_type": type,
            "duration_seconds": duration,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ])
    }

    /// Track grounding technique used
    /// - Parameter type: Type of grounding technique (5-4-3-2-1, etc.)
    func trackGroundingTechniqueUsed(type: String) {
        logEvent("grounding_technique_used", parameters: [
            "technique_type": type,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ])
    }

    /// Track mood check-in
    /// - Parameters:
    ///   - mood: Mood level or emoji
    ///   - notes: Optional notes
    func trackMoodCheckIn(mood: String, notes: String? = nil) {
        var params: [String: Any] = [
            "mood": mood,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        if let notes = notes {
            params["notes"] = notes
        }
        logEvent("mood_check_in", parameters: params)
    }

    /// Track subscription event
    /// - Parameters:
    ///   - action: Action type (viewed, started, completed, cancelled)
    ///   - productId: Product identifier
    func trackSubscription(action: String, productId: String? = nil) {
        var params: [String: Any] = [
            "action": action,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        if let productId = productId {
            params["product_id"] = productId
        }
        logEvent("subscription_\(action)", parameters: params)
    }
}

// MARK: - AppsFlyerLibDelegate

extension AppsFlyerService: AppsFlyerLibDelegate {

    /// Called when conversion data is received
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        print("AppsFlyer conversion data received:")
        for (key, value) in conversionInfo {
            print("  \(key): \(value)")
        }

        // Handle deep linking and attribution data
        if let status = conversionInfo["af_status"] as? String {
            if status == "Non-organic" {
                // User came from a campaign
                if let mediaSource = conversionInfo["media_source"] as? String {
                    print("Media source: \(mediaSource)")
                }
                if let campaign = conversionInfo["campaign"] as? String {
                    print("Campaign: \(campaign)")
                }
            } else {
                // Organic install
                print("Organic install")
            }
        }
    }

    /// Called when conversion data fetch fails
    func onConversionDataFail(_ error: Error) {
        print("AppsFlyer conversion data error: \(error.localizedDescription)")
    }

    /// Called when app open attribution data is received
    func onAppOpenAttribution(_ attributionData: [AnyHashable: Any]) {
        print("AppsFlyer app open attribution:")
        for (key, value) in attributionData {
            print("  \(key): \(value)")
        }

        // Handle deep linking from campaigns
        // You can parse attributionData to handle deep links
    }

    /// Called when app open attribution fails
    func onAppOpenAttributionFailure(_ error: Error) {
        print("AppsFlyer app open attribution error: \(error.localizedDescription)")
    }
}
