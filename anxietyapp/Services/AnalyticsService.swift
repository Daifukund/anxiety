//
//  AnalyticsService.swift
//  anxietyapp
//
//  Created by Claude Code
//

import Foundation
import Mixpanel

class AnalyticsService {
    static let shared = AnalyticsService()

    private init() {}

    // MARK: - Configuration

    func configure(token: String) {
        // Don't configure if token is empty (missing from Config.plist)
        guard !token.isEmpty else {
            #if DEBUG
            print("⚠️ AnalyticsService: Token is empty, skipping Mixpanel configuration")
            #endif
            return
        }

        Mixpanel.initialize(token: token, trackAutomaticEvents: true)
    }

    // MARK: - User Properties

    func identifyUser(userId: String? = nil) {
        if let userId = userId {
            Mixpanel.mainInstance().identify(distinctId: userId)
        }
    }

    func setUserProperties(_ properties: [String: Any]) {
        for (key, value) in properties {
            if let mixpanelValue = value as? MixpanelType {
                Mixpanel.mainInstance().people.set(property: key, to: mixpanelValue)
            }
        }
    }

    // MARK: - Event Tracking

    func track(_ event: AnalyticsEvent, properties: [String: Any]? = nil) {
        var allProperties: [String: MixpanelType] = [:]

        // Add timestamp
        allProperties["timestamp"] = Date().timeIntervalSince1970

        // Convert properties to MixpanelType
        if let properties = properties {
            for (key, value) in properties {
                if let mixpanelValue = value as? MixpanelType {
                    allProperties[key] = mixpanelValue
                }
            }
        }

        Mixpanel.mainInstance().track(event: event.rawValue, properties: allProperties)

        #if DEBUG
        print("📊 Analytics: \(event.rawValue) \(properties ?? [:])")
        #endif
    }

    // MARK: - Onboarding Events

    func trackOnboardingStarted() {
        track(.onboardingStarted)
    }

    func trackOnboardingStep(_ step: String, stepNumber: Int) {
        track(.onboardingStepViewed, properties: [
            "step_name": step,
            "step_number": stepNumber
        ])
    }

    func trackQuizAnswered(question: String, answer: Any) {
        track(.quizAnswered, properties: [
            "question": question,
            "answer": "\(answer)"
        ])
    }

    func trackQuizCompleted(userName: String?, age: String?, reason: String?) {
        var properties: [String: Any] = [:]
        if let userName = userName { properties["user_name"] = userName }
        if let age = age { properties["age_group"] = age }
        if let reason = reason { properties["primary_reason"] = reason }

        track(.quizCompleted, properties: properties)

        // Set user properties
        var userProps: [String: Any] = [:]
        if let age = age { userProps["age_group"] = age }
        if let reason = reason { userProps["primary_reason"] = reason }
        setUserProperties(userProps)
    }

    func trackPersonalizationViewed(score: Int?) {
        if let score = score {
            track(.personalizationViewed, properties: ["stress_score": score])
        } else {
            track(.personalizationViewed)
        }
    }

    // MARK: - Relief Experience Events

    func trackReliefExperienceStarted() {
        track(.reliefExperienceStarted)
    }

    func trackReliefExperienceMoodCheckIn(before: Int) {
        track(.reliefExperienceMoodCheckIn, properties: [
            "anxiety_before": before
        ])
    }

    func trackReliefExperienceSosBreathingCompleted() {
        track(.reliefExperienceSosBreathingCompleted)
    }

    func trackReliefExperienceTechniqueChosen(technique: String) {
        track(.reliefExperienceTechniqueChosen, properties: [
            "technique": technique
        ])
    }

    func trackReliefExperienceTechniqueCompleted(technique: String) {
        track(.reliefExperienceTechniqueCompleted, properties: [
            "technique": technique
        ])
    }

    func trackReliefExperienceMoodCheckOut(after: Int, improvement: Int) {
        track(.reliefExperienceMoodCheckOut, properties: [
            "anxiety_after": after,
            "improvement_points": improvement
        ])
    }

    func trackReliefExperienceCompleted(
        before: Int,
        after: Int,
        technique: String,
        experiencedRelief: Bool,
        improvement: Int,
        improvementPercentage: Int
    ) {
        track(.reliefExperienceCompleted, properties: [
            "anxiety_before": before,
            "anxiety_after": after,
            "technique_chosen": technique,
            "experienced_relief": experiencedRelief,
            "improvement_points": improvement,
            "improvement_percentage": improvementPercentage
        ])

        // Set user properties for better segmentation
        setUserProperties([
            "experienced_relief_in_onboarding": experiencedRelief,
            "onboarding_anxiety_improvement": improvement
        ])
    }

    func trackSymptomsSelected(symptoms: [String]) {
        track(.symptomsSelected, properties: [
            "symptoms": symptoms,
            "symptom_count": symptoms.count
        ])
        setUserProperties(["symptoms": symptoms])
    }

    func trackInformativeCardsCompleted(timeSpent: TimeInterval) {
        track(.informativeCardsCompleted, properties: [
            "time_spent_seconds": Int(timeSpent)
        ])
    }

    func trackGoalsSet(goals: [String]) {
        track(.goalsSet, properties: [
            "goals": goals,
            "goal_count": goals.count
        ])
        setUserProperties(["goals": goals])
    }

    func trackReminderSetup(enabled: Bool, time: String? = nil) {
        var properties: [String: Any] = ["enabled": enabled]
        if let time = time { properties["reminder_time"] = time }

        track(.reminderSetup, properties: properties)
        setUserProperties(["notifications_enabled": enabled])
    }

    func trackCommitmentSigned() {
        track(.commitmentSigned)
    }

    func trackOnboardingCompleted(timeSpent: TimeInterval) {
        track(.onboardingCompleted, properties: [
            "time_spent_seconds": Int(timeSpent),
            "time_spent_minutes": Int(timeSpent / 60)
        ])
    }

    // MARK: - Paywall Events

    func trackPaywallViewed(source: String = "onboarding") {
        track(.paywallViewed, properties: ["source": source])
    }

    func trackPlanSelected(plan: String, price: String) {
        track(.planSelected, properties: [
            "plan_type": plan,
            "price": price
        ])
    }

    func trackPurchaseInitiated(plan: String, price: String) {
        track(.purchaseInitiated, properties: [
            "plan_type": plan,
            "price": price
        ])
    }

    func trackPurchaseCompleted(plan: String, price: String, revenue: Double) {
        track(.purchaseCompleted, properties: [
            "plan_type": plan,
            "price": price,
            "revenue": revenue
        ])

        // Track revenue
        Mixpanel.mainInstance().people.trackCharge(amount: revenue, properties: [
            "plan_type": plan
        ])

        setUserProperties([
            "is_subscriber": true,
            "subscription_type": plan
        ])
    }

    func trackPurchaseFailed(plan: String, error: String) {
        track(.purchaseFailed, properties: [
            "plan_type": plan,
            "error_message": error
        ])
    }

    func trackPurchaseCancelled(plan: String) {
        track(.purchaseCancelled, properties: [
            "plan_type": plan
        ])
    }

    func trackRestorePurchaseAttempted() {
        track(.restorePurchaseAttempted)
    }

    func trackRestorePurchaseSuccess(plan: String) {
        track(.restorePurchaseSuccess, properties: [
            "plan_type": plan
        ])
    }

    func trackRestorePurchaseFailed(error: String) {
        track(.restorePurchaseFailed, properties: [
            "error_message": error
        ])
    }

    // MARK: - App Usage Events

    func trackSOSButtonTapped() {
        track(.sosButtonTapped)
    }

    func trackTechniqueStarted(technique: String) {
        track(.techniqueStarted, properties: [
            "technique_name": technique
        ])
    }

    func trackTechniqueCompleted(technique: String, duration: TimeInterval) {
        track(.techniqueCompleted, properties: [
            "technique_name": technique,
            "duration_seconds": Int(duration)
        ])
    }

    func trackMoodCheckin(mood: String) {
        track(.moodCheckin, properties: [
            "mood": mood
        ])
    }
}

// MARK: - Analytics Events Enum

enum AnalyticsEvent: String {
    // Onboarding
    case onboardingStarted = "Onboarding Started"
    case onboardingStepViewed = "Onboarding Step Viewed"
    case quizAnswered = "Quiz Question Answered"
    case quizCompleted = "Quiz Completed"
    case personalizationViewed = "Personalization Viewed"
    case reliefExperienceStarted = "Relief Experience Started"
    case reliefExperienceMoodCheckIn = "Relief Experience Mood Check In"
    case reliefExperienceSosBreathingCompleted = "Relief Experience SOS Breathing Completed"
    case reliefExperienceTechniqueChosen = "Relief Experience Technique Chosen"
    case reliefExperienceTechniqueCompleted = "Relief Experience Technique Completed"
    case reliefExperienceMoodCheckOut = "Relief Experience Mood Check Out"
    case reliefExperienceCompleted = "Relief Experience Completed"
    case symptomsSelected = "Symptoms Selected"
    case informativeCardsCompleted = "Informative Cards Completed"
    case goalsSet = "Goals Set"
    case reminderSetup = "Reminder Setup"
    case reminderSkipped = "Reminder Skipped"
    case notificationPermissionResult = "Notification Permission Result"
    case commitmentSigned = "Commitment Signed"
    case onboardingCompleted = "Onboarding Completed"

    // Paywall
    case paywallViewed = "Paywall Viewed"
    case planSelected = "Plan Selected"
    case purchaseInitiated = "Purchase Initiated"
    case purchaseCompleted = "Purchase Completed"
    case purchaseFailed = "Purchase Failed"
    case purchaseCancelled = "Purchase Cancelled"
    case restorePurchaseAttempted = "Restore Purchase Attempted"
    case restorePurchaseSuccess = "Restore Purchase Success"
    case restorePurchaseFailed = "Restore Purchase Failed"

    // App Usage
    case sosButtonTapped = "SOS Button Tapped"
    case techniqueStarted = "Technique Started"
    case techniqueCompleted = "Technique Completed"
    case moodCheckin = "Mood Checkin"

    // Widget
    case widgetPromotionViewed = "Widget Promotion Viewed"
    case widgetPromotionAccepted = "Widget Promotion Accepted"
    case widgetPromotionDismissed = "Widget Promotion Dismissed"

    // Feedback & Retention
    case feedbackSubmitted = "Feedback Submitted Before Deletion"
    case quickActionTapped = "Quick Action Tapped"
}
