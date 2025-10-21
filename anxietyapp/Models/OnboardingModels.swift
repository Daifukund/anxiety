//
//  OnboardingModels.swift
//  anxietyapp
//
//  Created by Claude Code
//

import Foundation
import SwiftUI

// MARK: - User Profile
struct UserProfile: Codable {
    var name: String = ""
    var ageRange: AgeRange?
    var goals: [OnboardingGoal] = []
    var stressBaseline: Int = 5
    var stressCauses: [StressCause] = []
    var lifeSatisfaction: LifeSatisfaction?
    var exerciseExperience: ExerciseExperience?
    var heardFromTherapist: Bool?
    var symptoms: [Symptom] = []
    var selectedGoals: [UserGoal] = []
    var notificationTime: Date?
    var hasCompletedOnboarding: Bool = false

    // Relief Experience fields
    var anxietyBefore: Int?
    var anxietyAfter: Int?
    var chosenTechnique: TechniqueType?

    var experiencedRelief: Bool {
        guard let before = anxietyBefore,
              let after = anxietyAfter else { return false }
        return after < before
    }

    var anxietyImprovement: Int {
        guard let before = anxietyBefore,
              let after = anxietyAfter else { return 0 }
        return max(0, before - after)
    }

    var anxietyImprovementPercentage: Int {
        guard let before = anxietyBefore,
              let after = anxietyAfter,
              before > 0 else { return 0 }
        let improvement = Double(before - after) / Double(before) * 100.0
        return max(0, Int(improvement))
    }
}

// MARK: - Enums
enum AgeRange: String, Codable, CaseIterable {
    case teen = "13-17"
    case youngAdult = "18-24"
    case adult = "25-34"
    case middleAge = "35-44"
    case mature = "45-54"
    case senior = "55+"
}

enum OnboardingGoal: String, Codable, CaseIterable {
    case stopPanicAttacks = "Stop panic attacks"
    case manageAnxiety = "Manage daily anxiety"
    case sleepBetter = "Sleep better"
    case learnToRelax = "Learn to relax"
    case moodTracking = "Mood tracking"
    case somethingElse = "Something else"
}

enum StressCause: String, Codable, CaseIterable {
    case familyRelationships = "Family & Relationships"
    case jobStress = "Job-related stress"
    case financialStruggles = "Financial struggles"
    case healthIssues = "Health issues"
    case personalLoss = "Personal loss"
    case others = "Others"
}

enum LifeSatisfaction: String, Codable, CaseIterable {
    case verySatisfied = "I feel satisfied with my life"
    case satisfied = "I'm okay but I want to improve"
    case neutral = "I feel neutral, not good or bad"
    case dissatisfied = "I often feel sad and unhappy"
    case veryDissatisfied = "I feel very low and need help"
}

enum ExerciseExperience: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case someExperience = "Some experience"
    case regularly = "Regularly"
}

enum Symptom: String, Codable, CaseIterable {
    case overthinking = "Overthinking"
    case irritability = "Irritability"
    case troubleSleeping = "Trouble sleeping"
    case muscleTension = "Muscle tensions"
    case fastHeartbeat = "Fast heartbeat"
    case stomachDiscomfort = "Stomach discomfort"
    case other = "Other"
}

enum UserGoal: String, Codable, CaseIterable {
    case reducePanic = "Reduce panic & anxiety quickly"
    case sleepBetter = "Sleep better and wake up refreshed"
    case buildCalm = "Build long-term calm habits"
    case emotionalControl = "Gain emotional control & balance"

    var icon: String {
        switch self {
        case .reducePanic:
            return "bolt.heart.fill"
        case .sleepBetter:
            return "moon.stars.fill"
        case .buildCalm:
            return "leaf.fill"
        case .emotionalControl:
            return "brain.head.profile"
        }
    }

    var color: Color {
        switch self {
        case .reducePanic:
            return Color(red: 1.0, green: 0.4, blue: 0.4) // Coral red
        case .sleepBetter:
            return Color(red: 0.4, green: 0.6, blue: 1.0) // Soft blue
        case .buildCalm:
            return Color(red: 0.4, green: 0.8, blue: 0.5) // Green
        case .emotionalControl:
            return Color(red: 0.7, green: 0.5, blue: 0.9) // Purple
        }
    }
}

enum TechniqueType: String, Codable, CaseIterable {
    case breathing = "Breathing Exercises"
    case grounding = "Grounding (5-4-3-2-1)"

    var icon: String {
        switch self {
        case .breathing:
            return "wind"
        case .grounding:
            return "hand.tap.fill"
        }
    }

    var description: String {
        switch self {
        case .breathing:
            return "Multiple breathing techniques for different moods"
        case .grounding:
            return "5-4-3-2-1 method for instant calm"
        }
    }
}

// MARK: - Quiz Progress
enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case quizName
    case quizAge
    case quizGoals
    case quizStressBaseline
    case quizStressCauses
    case quizLifeSatisfaction
    case quizExerciseExperience
    case quizTherapist
    case personalization
    case reliefExperience
    case symptoms
    case informativeCards
    case rewiringBenefits
    case setGoals
    case rating
    case commitment
    case reminderSetup
    case offerPage
    case paywall
    case complete
}
