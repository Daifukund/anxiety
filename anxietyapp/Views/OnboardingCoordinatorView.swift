//
//  OnboardingCoordinatorView.swift
//  anxietyapp
//
//  Created by Claude Code
//

import SwiftUI
import Combine

struct OnboardingCoordinatorView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @ObservedObject private var subscriptionService = SubscriptionService.shared
    let onComplete: () -> Void

    @State private var onboardingStartTime = Date()

    #if DEBUG
    @Binding var debugBypassPaywall: Bool
    #endif

    @State private var isCheckingSubscription = false

    var body: some View {
        ZStack {
            switch viewModel.currentStep {
            case .welcome:
                OnboardingWelcomeView(onContinue: {
                    AnalyticsService.shared.trackOnboardingStep("Welcome", stepNumber: 1)
                    viewModel.currentStep = .quizName
                })
                .transition(.opacity)

            case .quizName, .quizAge, .quizGoals, .quizStressBaseline, .quizStressCauses,
                    .quizLifeSatisfaction, .quizExerciseExperience, .quizTherapist:
                OnboardingQuizView(
                    userProfile: $viewModel.userProfile,
                    onComplete: {
                        AnalyticsService.shared.trackQuizCompleted(
                            userName: viewModel.userProfile.name,
                            age: viewModel.userProfile.ageRange?.rawValue,
                            reason: viewModel.userProfile.goals.first?.rawValue
                        )
                        viewModel.currentStep = .personalization
                    }
                )
                .transition(.opacity)

            case .personalization:
                OnboardingPersonalizationView(
                    userProfile: viewModel.userProfile,
                    onContinue: {
                        AnalyticsService.shared.trackPersonalizationViewed(score: viewModel.userProfile.stressBaseline)
                        viewModel.currentStep = .reliefExperience
                    }
                )
                .transition(.opacity)

            case .reliefExperience:
                OnboardingReliefExperienceView(
                    userProfile: $viewModel.userProfile,
                    onContinue: {
                        // Track relief experience completion with metrics
                        AnalyticsService.shared.trackReliefExperienceCompleted(
                            before: viewModel.userProfile.anxietyBefore ?? 0,
                            after: viewModel.userProfile.anxietyAfter ?? 0,
                            technique: viewModel.userProfile.chosenTechnique?.rawValue ?? "none",
                            experiencedRelief: viewModel.userProfile.experiencedRelief,
                            improvement: viewModel.userProfile.anxietyImprovement,
                            improvementPercentage: viewModel.userProfile.anxietyImprovementPercentage
                        )
                        viewModel.currentStep = .symptoms
                    }
                )
                .transition(.opacity)

            case .symptoms:
                OnboardingSymptomsView(
                    userProfile: $viewModel.userProfile,
                    onContinue: {
                        AnalyticsService.shared.trackSymptomsSelected(
                            symptoms: viewModel.userProfile.symptoms.map { $0.rawValue }
                        )
                        viewModel.currentStep = .informativeCards
                    }
                )
                .transition(.opacity)

            case .informativeCards:
                OnboardingInformativeCardsView(onContinue: {
                    viewModel.currentStep = .rewiringBenefits
                })
                .transition(.opacity)

            case .rewiringBenefits:
                OnboardingRewiringBenefitsView(onContinue: {
                    viewModel.currentStep = .setGoals
                })
                .transition(.opacity)

            case .setGoals:
                OnboardingSetGoalsView(
                    userProfile: $viewModel.userProfile,
                    onContinue: {
                        AnalyticsService.shared.trackGoalsSet(
                            goals: viewModel.userProfile.selectedGoals.map { $0.rawValue }
                        )
                        viewModel.currentStep = .rating
                    }
                )
                .transition(.opacity)

            case .rating:
                OnboardingRatingView(onContinue: {
                    viewModel.currentStep = .commitment
                })
                .transition(.opacity)

            case .commitment:
                OnboardingCommitmentView(
                    userName: viewModel.userProfile.name,
                    onContinue: {
                        AnalyticsService.shared.trackCommitmentSigned()
                        viewModel.currentStep = .reminderSetup
                    }
                )
                .transition(.opacity)

            case .reminderSetup:
                OnboardingReminderSetupView(
                    userProfile: $viewModel.userProfile,
                    onContinue: {
                        handleReminderSetup()
                        viewModel.currentStep = .offerPage
                    }
                )
                .transition(.opacity)

            case .offerPage:
                OnboardingOfferPageView(
                    userName: viewModel.userProfile.name,
                    userProfile: viewModel.userProfile,
                    onContinue: {
                        // Check subscription before showing paywall
                        Task {
                            isCheckingSubscription = true
                            await subscriptionService.checkSubscriptionStatus()
                            isCheckingSubscription = false

                            if subscriptionService.isSubscribed {
                                // User already has subscription (e.g., from promo code)
                                // Skip paywall and complete onboarding
                                let timeSpent = Date().timeIntervalSince(onboardingStartTime)
                                AnalyticsService.shared.trackOnboardingCompleted(timeSpent: timeSpent)
                                viewModel.completeOnboarding()
                                onComplete()
                            } else {
                                // No subscription, show paywall
                                viewModel.currentStep = .paywall
                            }
                        }
                    }
                )
                .transition(.opacity)
                .onAppear {
                    // Mark onboarding as completed when reaching offer page
                    // This ensures user goes directly to paywall on app restart
                    viewModel.completeOnboarding()
                }

            case .paywall:
                RevenueCatPaywallView(
                    onSubscribe: {
                        let timeSpent = Date().timeIntervalSince(onboardingStartTime)
                        AnalyticsService.shared.trackOnboardingCompleted(timeSpent: timeSpent)
                        viewModel.completeOnboarding()
                        onComplete()
                    },
                    onDismiss: {
                        viewModel.currentStep = .offerPage
                    }
                )
                .transition(.opacity)
                .onAppear {
                    #if DEBUG
                    // Auto-skip paywall if debug bypass is enabled
                    if debugBypassPaywall {
                        let timeSpent = Date().timeIntervalSince(onboardingStartTime)
                        AnalyticsService.shared.trackOnboardingCompleted(timeSpent: timeSpent)
                        viewModel.completeOnboarding()
                        onComplete()
                    }
                    #endif
                }

            case .complete:
                EmptyView()
            }

            // Loading overlay when checking subscription
            if isCheckingSubscription {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .tint(.white)
                            .scaleEffect(1.2)

                        Text("Checking subscription...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(24)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(16)
                }
            }
        }
        .preferredColorScheme(.light)  // Force light mode for all onboarding screens
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
        .onAppear {
            AnalyticsService.shared.trackOnboardingStarted()
            onboardingStartTime = Date()
        }
    }

    // MARK: - Helper Methods

    private func handleReminderSetup() {
        // Track analytics
        let reminderEnabled = viewModel.userProfile.notificationTime != nil
        AnalyticsService.shared.track(.reminderSetup, properties: [
            "enabled": reminderEnabled,
            "time": viewModel.userProfile.notificationTime?.description ?? "none"
        ])

        // Request notification permission if user enabled reminders
        if let notificationTime = viewModel.userProfile.notificationTime {
            NotificationService.shared.requestPermission { granted in
                // Track permission result
                AnalyticsService.shared.track(.notificationPermissionResult, properties: [
                    "granted": granted,
                    "context": "onboarding"
                ])

                if granted {
                    // Save to AppStorage so Settings view knows about it
                    UserDefaults.standard.set(true, forKey: "moodCheckInEnabled")

                    // Convert time to HH:mm format for AppStorage
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    let timeString = formatter.string(from: notificationTime)
                    UserDefaults.standard.set(timeString, forKey: "moodCheckInTime")

                    // Schedule the notification
                    NotificationService.shared.scheduleMoodCheckIn(enabled: true, time: notificationTime)

                    print("✅ Reminder scheduled for \(timeString)")
                } else {
                    print("⚠️ User denied notification permission")
                }
            }
        } else {
            AnalyticsService.shared.track(.reminderSkipped)
            print("ℹ️ User skipped reminder setup")
        }
    }
}

#if DEBUG
#Preview {
    OnboardingCoordinatorView(
        onComplete: {},
        debugBypassPaywall: .constant(false)
    )
}
#endif
