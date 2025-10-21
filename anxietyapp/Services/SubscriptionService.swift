//
//  SubscriptionService.swift
//  anxietyapp
//
//  Created by Claude Code
//

import Foundation
import Combine
import RevenueCat
import UIKit

@MainActor
class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()

    @Published var isSubscribed: Bool = false
    @Published var currentSubscription: SubscriptionStatus?
    private var isConfigured: Bool = false

    private init() {}

    // MARK: - Configuration

    func configure(apiKey: String) {
        // Don't configure if API key is empty (missing from Config.plist)
        guard !apiKey.isEmpty else {
            #if DEBUG
            print("⚠️ SubscriptionService: API key is empty, skipping RevenueCat configuration")
            #endif
            isConfigured = false
            return
        }

        #if DEBUG
        Purchases.logLevel = .debug
        #else
        Purchases.logLevel = .error // Only log errors in production
        #endif

        Purchases.configure(withAPIKey: apiKey)
        isConfigured = true

        // Listen for subscription changes
        Task {
            await checkSubscriptionStatus()
        }
    }

    // MARK: - Subscription Status

    func checkSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()

            // Check multiple sources for active access:
            // 1. Active entitlements (requires RevenueCat dashboard configuration)
            let hasActiveEntitlement = !customerInfo.entitlements.active.isEmpty

            // 2. Active subscriptions (monthly/annual)
            let hasActiveSubscription = !customerInfo.activeSubscriptions.isEmpty

            // 3. Non-consumable purchases (lifetime)
            let hasNonConsumablePurchase = !customerInfo.nonSubscriptions.isEmpty

            // User has access if ANY of the above are true
            let hasActiveAccess = hasActiveEntitlement || hasActiveSubscription || hasNonConsumablePurchase

            #if DEBUG
            print("🔍 Subscription Status Check:")
            print("  - Active Entitlements: \(customerInfo.entitlements.active.keys)")
            print("  - Active Subscriptions: \(customerInfo.activeSubscriptions)")
            print("  - Non-consumable Purchases: \(customerInfo.nonSubscriptions.map { $0.productIdentifier })")
            print("  - Final Decision: hasAccess = \(hasActiveAccess)")
            #endif

            self.isSubscribed = hasActiveAccess

            if hasActiveEntitlement,
               let entitlement = customerInfo.entitlements.active.first?.value {
                self.currentSubscription = SubscriptionStatus(
                    isActive: true,
                    productIdentifier: entitlement.productIdentifier,
                    expirationDate: entitlement.expirationDate,
                    willRenew: entitlement.willRenew
                )
            } else if hasActiveSubscription || hasNonConsumablePurchase {
                // Fallback: User has valid purchase but no entitlement configured
                let productId = customerInfo.activeSubscriptions.first ??
                               customerInfo.nonSubscriptions.first?.productIdentifier ??
                               "unknown"
                self.currentSubscription = SubscriptionStatus(
                    isActive: true,
                    productIdentifier: productId,
                    expirationDate: nil,
                    willRenew: false
                )
            } else {
                self.currentSubscription = SubscriptionStatus(
                    isActive: false,
                    productIdentifier: nil,
                    expirationDate: nil,
                    willRenew: false
                )
            }
        } catch {
            print("Error checking subscription status: \(error)")
            CrashReporter.shared.logError(error, context: "SubscriptionService.checkSubscriptionStatus")
            self.isSubscribed = false
        }
    }

    // MARK: - Purchase

    func purchase(_ product: SubscriptionProduct) async throws -> Bool {
        // Validate configuration
        guard isConfigured else {
            let error = SubscriptionError.notConfigured
            CrashReporter.shared.logError(error, context: "SubscriptionService.purchase - Not configured")
            throw error
        }

        do {
            let storeProduct = try await fetchStoreProduct(for: product)

            #if DEBUG
            print("📱 Device: \(UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone")")
            print("🛒 Purchasing product: \(storeProduct.productIdentifier)")
            print("🛒 Product price: \(storeProduct.localizedPriceString)")
            #endif

            // Ensure purchase happens on main actor (required for payment sheet presentation)
            let result = try await Purchases.shared.purchase(product: storeProduct)

            #if DEBUG
            print("✅ Purchase completed successfully")
            print("📋 Entitlements: \(result.customerInfo.entitlements.active.keys)")
            print("📋 Active Subscriptions: \(result.customerInfo.activeSubscriptions)")
            print("📋 Non-consumable Purchases: \(result.customerInfo.nonSubscriptions.map { $0.productIdentifier })")
            #endif

            await checkSubscriptionStatus()

            // Check multiple sources for purchase success
            let hasEntitlement = !result.customerInfo.entitlements.active.isEmpty
            let hasSubscription = !result.customerInfo.activeSubscriptions.isEmpty
            let hasNonConsumable = !result.customerInfo.nonSubscriptions.isEmpty

            let purchaseSuccessful = hasEntitlement || hasSubscription || hasNonConsumable

            #if DEBUG
            print("✅ Purchase success determination: \(purchaseSuccessful)")
            #endif

            return purchaseSuccessful
        } catch let error as ErrorCode {
            // Handle RevenueCat specific errors
            print("❌ RevenueCat error: \(error)")

            #if DEBUG
            print("Error details: \(error.errorUserInfo)")
            #endif

            CrashReporter.shared.logError(error, context: "SubscriptionService.purchase(\(product.rawValue)) - Device: \(UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone")")
            throw error
        } catch let error as NSError {
            print("❌ Purchase error: \(error)")
            print("Error domain: \(error.domain), code: \(error.code)")

            // Log more details for debugging iPad issues
            #if DEBUG
            print("Error userInfo: \(error.userInfo)")
            #endif

            CrashReporter.shared.logError(error, context: "SubscriptionService.purchase(\(product.rawValue)) - Device: \(UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone")")
            throw error
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async throws -> Bool {
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            await checkSubscriptionStatus()

            // Check multiple sources for restored purchases
            let hasEntitlement = !customerInfo.entitlements.active.isEmpty
            let hasSubscription = !customerInfo.activeSubscriptions.isEmpty
            let hasNonConsumable = !customerInfo.nonSubscriptions.isEmpty

            return hasEntitlement || hasSubscription || hasNonConsumable
        } catch {
            print("Restore error: \(error)")
            CrashReporter.shared.logError(error, context: "SubscriptionService.restorePurchases")
            throw error
        }
    }

    // MARK: - Fetch Products

    func fetchStoreProduct(for product: SubscriptionProduct) async throws -> StoreProduct {
        let products = await Purchases.shared.products([product.rawValue])
        guard let storeProduct = products.first else {
            throw SubscriptionError.productNotFound
        }
        return storeProduct
    }

    func fetchAllProducts() async throws -> [StoreProduct] {
        let productIds = SubscriptionProduct.allCases.map { $0.rawValue }

        #if DEBUG
        print("📦 Fetching products: \(productIds)")
        print("📦 Device: \(UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone")")
        print("📦 iOS version: \(UIDevice.current.systemVersion)")
        #endif

        // Fetch with timeout protection
        let products = await Purchases.shared.products(productIds)

        #if DEBUG
        print("📦 RevenueCat returned \(products.count) products")
        if products.isEmpty {
            print("⚠️ WARNING: No products returned from RevenueCat!")
            print("⚠️ This may indicate sandbox/configuration issues")
        }
        for product in products {
            print("  ✓ \(product.productIdentifier): \(product.localizedPriceString)")
        }
        #endif

        return products
    }
}

// MARK: - Errors

enum SubscriptionError: LocalizedError {
    case productNotFound
    case purchaseFailed
    case restoreFailed
    case notConfigured

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not found. Please try again."
        case .purchaseFailed:
            return "Purchase failed. Please try again."
        case .restoreFailed:
            return "Unable to restore purchases. Please try again."
        case .notConfigured:
            return "Subscription service is not configured. Please restart the app."
        }
    }
}
