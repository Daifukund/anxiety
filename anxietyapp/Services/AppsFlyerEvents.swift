//
//  AppsFlyerEvents.swift
//  anxietyapp
//
//  Example event tracking integrations for AppsFlyer
//  This file demonstrates how to integrate AppsFlyer tracking throughout the app
//

import Foundation

/// Example integrations for AppsFlyer event tracking
/// Use these patterns in your ViewModels and Views to track user actions
enum AppsFlyerEventExamples {

    // MARK: - Onboarding Events

    /// Call this when user completes onboarding
    /// Example location: OnboardingView or OnboardingViewModel
    static func trackOnboardingComplete() {
        AppsFlyerService.shared.trackOnboardingCompleted()
    }

    // MARK: - SOS Flow Events

    /// Call this when user taps the SOS button
    /// Example location: DashboardView SOS button action
    static func trackSOSStart() {
        AppsFlyerService.shared.trackSOSFlowStarted()
    }

    /// Call this when user completes an SOS technique
    /// Example location: SOSFlowView completion handler
    /// - Parameter technique: The technique used (e.g., "breathing", "grounding", "physical_reset")
    static func trackSOSComplete(technique: String) {
        AppsFlyerService.shared.trackSOSFlowCompleted(technique: technique)
    }

    // MARK: - Breathing Exercise Events

    /// Call this when user starts a breathing exercise
    /// Example location: BreathingExerciseView onAppear
    /// - Parameter type: The type of exercise (e.g., "box_breathing", "4-7-8", "calm_breathing")
    static func trackBreathingStart(type: String) {
        AppsFlyerService.shared.trackBreathingExerciseStarted(type: type)
    }

    /// Call this when user completes a breathing exercise
    /// Example location: BreathingExerciseView completion handler
    /// - Parameters:
    ///   - type: The type of exercise
    ///   - duration: How long they did the exercise (in seconds)
    static func trackBreathingComplete(type: String, duration: Int) {
        AppsFlyerService.shared.trackBreathingExerciseCompleted(type: type, duration: duration)
    }

    // MARK: - Grounding Technique Events

    /// Call this when user uses a grounding technique
    /// Example location: GroundingView completion
    /// - Parameter type: The technique type (e.g., "5-4-3-2-1", "body_scan", "sensory")
    static func trackGroundingUsed(type: String) {
        AppsFlyerService.shared.trackGroundingTechniqueUsed(type: type)
    }

    // MARK: - Mood Tracking Events

    /// Call this when user logs their mood
    /// Example location: MoodCheckInView submit button
    /// - Parameters:
    ///   - mood: The mood emoji or value selected
    ///   - notes: Optional notes the user added
    static func trackMoodLog(mood: String, notes: String? = nil) {
        AppsFlyerService.shared.trackMoodCheckIn(mood: mood, notes: notes)
    }

    // MARK: - Subscription Events

    /// Call this when user views the paywall/subscription screen
    /// Example location: PaywallView onAppear
    static func trackSubscriptionViewed() {
        AppsFlyerService.shared.trackSubscription(action: "viewed")
    }

    /// Call this when user starts the subscription purchase flow
    /// Example location: SubscriptionViewModel purchase method
    /// - Parameter productId: The product identifier being purchased
    static func trackSubscriptionStarted(productId: String) {
        AppsFlyerService.shared.trackSubscription(action: "started", productId: productId)
    }

    /// Call this when subscription purchase completes successfully
    /// Example location: SubscriptionViewModel purchase completion
    /// - Parameter productId: The product identifier that was purchased
    static func trackSubscriptionCompleted(productId: String) {
        AppsFlyerService.shared.trackSubscription(action: "completed", productId: productId)
    }

    /// Call this when user cancels subscription
    /// Example location: SubscriptionViewModel cancellation handler
    static func trackSubscriptionCancelled() {
        AppsFlyerService.shared.trackSubscription(action: "cancelled")
    }

    // MARK: - Custom Event Tracking

    /// Example of tracking a custom event
    /// Use this pattern for any app-specific events
    /// - Parameters:
    ///   - eventName: Name of the event (use snake_case)
    ///   - parameters: Optional parameters dictionary
    static func trackCustomEvent(eventName: String, parameters: [String: Any]? = nil) {
        AppsFlyerService.shared.logEvent(eventName, parameters: parameters)
    }
}

// MARK: - Usage Examples in SwiftUI Views

/*
 EXAMPLE 1: Track SOS Button Tap in DashboardView

 Button("SOS") {
     AppsFlyerService.shared.trackSOSFlowStarted()
     // Navigate to SOS flow
 }

 EXAMPLE 2: Track Breathing Exercise Completion

 struct BreathingExerciseView: View {
     @State private var startTime = Date()

     var body: some View {
         // ... breathing UI ...
         .onDisappear {
             let duration = Int(Date().timeIntervalSince(startTime))
             AppsFlyerService.shared.trackBreathingExerciseCompleted(
                 type: "box_breathing",
                 duration: duration
             )
         }
     }
 }

 EXAMPLE 3: Track Subscription Purchase in ViewModel

 class SubscriptionViewModel: ObservableObject {
     func purchaseSubscription(productId: String) {
         AppsFlyerService.shared.trackSubscription(action: "started", productId: productId)

         // RevenueCat purchase logic...

         // On success:
         AppsFlyerService.shared.trackSubscription(action: "completed", productId: productId)
     }
 }

 EXAMPLE 4: Track Mood Check-In

 Button("Submit") {
     AppsFlyerService.shared.trackMoodCheckIn(
         mood: selectedMood,
         notes: moodNotes
     )
     // Save mood to database
 }
 */
