//
//  ContentView.swift
//  anxietyapp
//
//  Created by Nathan Douziech on 27/09/2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.isDarkMode) var isDarkMode
    @State private var hasCompletedOnboarding = false
    @ObservedObject private var subscriptionService = SubscriptionService.shared
    @ObservedObject private var navigationManager = NavigationManager.shared
    @State private var isCheckingSubscription = true

    #if DEBUG
    @State private var debugBypassPaywall = UserDefaults.standard.bool(forKey: "debugBypassPaywall")
    #endif

    private var shouldShowMainApp: Bool {
        #if DEBUG
        return subscriptionService.isSubscribed || debugBypassPaywall
        #else
        return subscriptionService.isSubscribed
        #endif
    }

    var body: some View {
        ZStack {
            Group {
                if isCheckingSubscription {
                    // Loading screen while checking subscription
                    ZStack {
                        Color.adaptiveBackground(isDark: isDarkMode).ignoresSafeArea()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .tint(Color.accentViolet)
                    }
                } else if !hasCompletedOnboarding {
                    #if DEBUG
                    OnboardingCoordinatorView(
                        onComplete: {
                            hasCompletedOnboarding = true
                        },
                        debugBypassPaywall: $debugBypassPaywall
                    )
                    #else
                    OnboardingCoordinatorView(
                        onComplete: {
                            hasCompletedOnboarding = true
                        }
                    )
                    #endif
                } else if shouldShowMainApp {
                    MainTabView()
                } else {
                    // Show offer page → paywall flow if onboarding completed but not subscribed
                    SubscriptionFlowView()
                }
            }
            .onAppear {
                checkOnboardingStatus()
                Task {
                    await subscriptionService.checkSubscriptionStatus()
                    isCheckingSubscription = false
                }
            }

            // DEBUG: Reset button (remove in production)
            // COMMENTED OUT FOR SCREENSHOTS - Uncomment to get debug buttons back
            
            #if DEBUG
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 16) {
                        // TEST FEEDBACK BUTTON
                        Button(action: {
                            print("🧪 DEBUG: Opening feedback form")
                            navigationManager.shouldShowFeedback = true
                        }) {
                            Image(systemName: "envelope.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.purple)
                                .background(Circle().fill(Color.adaptiveBackground(isDark: isDarkMode)))
                        }

                        // Skip onboarding button
                        Button(action: skipOnboarding) {
                            Image(systemName: "forward.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                                .background(Circle().fill(Color.adaptiveBackground(isDark: isDarkMode)))
                        }

                        // Reset onboarding button
                        Button(action: resetOnboarding) {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.red)
                                .background(Circle().fill(Color.adaptiveBackground(isDark: isDarkMode)))
                        }

                        // Toggle paywall bypass button
                        Button(action: {
                            debugBypassPaywall.toggle()
                            UserDefaults.standard.set(debugBypassPaywall, forKey: "debugBypassPaywall")
                        }) {
                            Image(systemName: debugBypassPaywall ? "checkmark.circle.fill" : "dollarsign.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(debugBypassPaywall ? .green : .orange)
                                .background(Circle().fill(Color.adaptiveBackground(isDark: isDarkMode)))
                        }
                    }
                    .padding(20)
                }
            }
            #endif

        }
        .sheet(isPresented: $navigationManager.shouldShowFeedback) {
            FeedbackIncentiveView()
        }
    }

    private func checkOnboardingStatus() {
        // Try Keychain first (secure storage)
        if let profile = KeychainManager.shared.getObject(forKey: "userProfile", as: UserProfile.self) {
            hasCompletedOnboarding = profile.hasCompletedOnboarding
            return
        }

        // Fallback to UserDefaults (legacy, migrate to Keychain)
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            hasCompletedOnboarding = profile.hasCompletedOnboarding

            // Migrate to Keychain
            _ = KeychainManager.shared.save(profile, forKey: "userProfile")
            UserDefaults.standard.removeObject(forKey: "userProfile")

            #if DEBUG
            print("📦 Migrated userProfile to Keychain")
            #endif
        }
    }

    #if DEBUG
    // DEBUG: Skip onboarding and go to app
    private func skipOnboarding() {
        hasCompletedOnboarding = true
        debugBypassPaywall = true
        UserDefaults.standard.set(debugBypassPaywall, forKey: "debugBypassPaywall")

        // Save to Keychain so it persists across rebuilds
        var profile = UserProfile()
        profile.hasCompletedOnboarding = true
        _ = KeychainManager.shared.save(profile, forKey: "userProfile")
    }

    // DEBUG: Reset onboarding
    private func resetOnboarding() {
        KeychainManager.shared.delete(forKey: "userProfile")
        UserDefaults.standard.removeObject(forKey: "userProfile") // Clean legacy too
        UserDefaults.standard.removeObject(forKey: "debugBypassPaywall")
        hasCompletedOnboarding = false
        debugBypassPaywall = false
    }
    #endif
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
}
