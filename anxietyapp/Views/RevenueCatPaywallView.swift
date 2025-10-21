//
//  RevenueCatPaywallView.swift
//  anxietyapp
//
//  Created by Claude Code
//  RevenueCat native paywall implementation
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct RevenueCatPaywallView: View {
    let onSubscribe: () -> Void
    let onDismiss: () -> Void

    @ObservedObject private var subscriptionService = SubscriptionService.shared
    @State private var showError = false
    @State private var errorMessage: String?
    @State private var isCompletingPurchase = false // Prevents error flash during successful transition

    var body: some View {
        ZStack {
            // RevenueCat's native paywall UI
            PaywallView(displayCloseButton: true)
            .onPurchaseCompleted { customerInfo in
                // Set flag to prevent error flashing during transition
                isCompletingPurchase = true

                // Track purchase completion
                AnalyticsService.shared.trackPurchaseCompleted(
                    plan: "revenuecat_managed",
                    price: "varies",
                    revenue: 0.0 // RevenueCat tracks this server-side
                )

                print("✅ Purchase completed via RevenueCat paywall")

                // Clear any error state
                showError = false
                errorMessage = nil

                onSubscribe()

                // Reset flag after transition
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
                    isCompletingPurchase = false
                }
            }
            .onPurchaseFailure { error in
                // Track purchase failure
                AnalyticsService.shared.trackPurchaseFailed(
                    plan: "revenuecat_managed",
                    error: error.localizedDescription
                )

                print("❌ Purchase failed: \(error.localizedDescription)")

                // Don't show error for user cancellation
                let nsError = error as NSError
                if nsError.code != 1 { // Not a cancellation
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
            .onRestoreCompleted { customerInfo in
                // Check if user has active subscription after restore
                let hasActiveAccess = !customerInfo.entitlements.active.isEmpty ||
                                     !customerInfo.activeSubscriptions.isEmpty ||
                                     !customerInfo.nonSubscriptions.isEmpty

                if hasActiveAccess {
                    // Set flag to prevent error flashing during transition
                    isCompletingPurchase = true

                    AnalyticsService.shared.trackRestorePurchaseSuccess(plan: "revenuecat_managed")
                    print("✅ Restore successful")

                    // Clear any error state
                    showError = false
                    errorMessage = nil

                    onSubscribe()

                    // Reset flag after transition
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
                        isCompletingPurchase = false
                    }
                } else {
                    errorMessage = "No previous purchases found."
                    showError = true
                    AnalyticsService.shared.trackRestorePurchaseFailed(error: "No active entitlements")
                }
            }
            .onRestoreFailure { error in
                errorMessage = "Unable to restore purchases. Please try again."
                showError = true
                AnalyticsService.shared.trackRestorePurchaseFailed(error: error.localizedDescription)
                print("❌ Restore failed: \(error.localizedDescription)")
            }

            // Close button overlay (RevenueCat's built-in close button can be customized)
            VStack {
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.textMedium)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .padding(.top, 16)
                    .padding(.trailing, 16)
                }
                Spacer()
            }
        }
        .onAppear {
            AnalyticsService.shared.trackPaywallViewed(source: "onboarding")

            Task {
                // Check if user already has subscription
                await subscriptionService.checkSubscriptionStatus()

                if subscriptionService.isSubscribed {
                    print("✅ Subscription detected automatically, skipping paywall")
                    onSubscribe()
                }
            }
        }
        .onChange(of: subscriptionService.isSubscribed) { isSubscribed in
            if isSubscribed {
                // Set flag to prevent error flashing during transition
                isCompletingPurchase = true

                print("✅ Subscription detected via real-time monitoring, dismissing paywall")

                // Clear any error state
                showError = false
                errorMessage = nil

                onSubscribe()

                // Reset flag after transition
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
                    isCompletingPurchase = false
                }
            }
        }
        .overlay(
            Group {
                // Don't show errors during successful purchase/restore transitions
                if showError, let errorMessage = errorMessage, !isCompletingPurchase {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                showError = false
                            }

                        VStack(spacing: DesignSystem.Spacing.medium) {
                            Text("Error")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.textDark)

                            Text(errorMessage)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.textMedium)
                                .multilineTextAlignment(.center)

                            Button(action: {
                                showError = false
                            }) {
                                Text("OK")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.primaryPurple)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(DesignSystem.Spacing.large)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                        .padding(.horizontal, 40)
                    }
                }
            }
        )
    }
}

#Preview {
    RevenueCatPaywallView(onSubscribe: {}, onDismiss: {})
}
