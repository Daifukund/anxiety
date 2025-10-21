//
//  OnboardingViewModel.swift
//  anxietyapp
//
//  Created by Claude Code
//

import Foundation
import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var userProfile = UserProfile()
    @Published var isOnboardingComplete = false

    func nextStep() {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep) else { return }

        if currentIndex < OnboardingStep.allCases.count - 1 {
            currentStep = OnboardingStep.allCases[currentIndex + 1]
        } else {
            completeOnboarding()
        }
    }

    func completeOnboarding() {
        userProfile.hasCompletedOnboarding = true
        isOnboardingComplete = true
        saveUserProfile()
    }

    private func saveUserProfile() {
        // Save to Keychain (secure storage)
        if !KeychainManager.shared.save(userProfile, forKey: "userProfile") {
            #if DEBUG
            print("❌ OnboardingViewModel: Failed to save UserProfile to Keychain")
            #endif

            // Fallback to UserDefaults
            if let encoded = try? JSONEncoder().encode(userProfile) {
                UserDefaults.standard.set(encoded, forKey: "userProfile")
            }
        }
    }

    func loadUserProfile() {
        // Load from Keychain (secure)
        if let profile = KeychainManager.shared.getObject(forKey: "userProfile", as: UserProfile.self) {
            userProfile = profile
            isOnboardingComplete = profile.hasCompletedOnboarding
            return
        }

        // Fallback: Load from UserDefaults (legacy)
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = decoded
            isOnboardingComplete = decoded.hasCompletedOnboarding

            // Migrate to Keychain
            _ = KeychainManager.shared.save(decoded, forKey: "userProfile")
            UserDefaults.standard.removeObject(forKey: "userProfile")

            #if DEBUG
            print("📦 OnboardingViewModel: Migrated UserProfile to Keychain")
            #endif
        }
    }
}
