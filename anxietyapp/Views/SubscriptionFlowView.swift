//
//  SubscriptionFlowView.swift
//  anxietyapp
//
//  Created by Claude Code
//

import SwiftUI

struct SubscriptionFlowView: View {
    @State private var showPaywall = false
    @ObservedObject private var subscriptionService = SubscriptionService.shared

    private var userProfile: UserProfile {
        // Try loading from Keychain (secure storage)
        if let profile = KeychainManager.shared.getObject(forKey: "userProfile", as: UserProfile.self) {
            return profile
        }

        // Fallback to UserDefaults (legacy, for migration)
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return profile
        }

        // Return default empty profile if nothing found
        return UserProfile()
    }

    private var userName: String {
        userProfile.name
    }

    var body: some View {
        ZStack {
            if !showPaywall {
                // Show offer page first
                OnboardingOfferPageView(
                    userName: userName,
                    userProfile: userProfile,
                    onContinue: {
                        withAnimation {
                            showPaywall = true
                        }
                    }
                )
                .transition(.opacity)
            } else {
                // Then show paywall
                RevenueCatPaywallView(
                    onSubscribe: {
                        Task {
                            await subscriptionService.checkSubscriptionStatus()
                        }
                    },
                    onDismiss: {
                        // Allow going back to offer page
                        withAnimation {
                            showPaywall = false
                        }
                    }
                )
                .transition(.opacity)
            }
        }
        .preferredColorScheme(.light)  // Force light mode for subscription flow
        .animation(.easeInOut(duration: 0.3), value: showPaywall)
    }
}

#Preview {
    SubscriptionFlowView()
}
