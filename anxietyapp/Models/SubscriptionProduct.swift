//
//  SubscriptionProduct.swift
//  anxietyapp
//
//  Created by Claude Code
//

import Foundation

enum SubscriptionProduct: String, CaseIterable {
    case monthly = "eunoia.anxietyapp.monthly"
    case annual = "eunoia.anxietyapp.annual"
    case lifetime = "eunoia.anxietyapp.lifetime"

    var displayName: String {
        switch self {
        case .monthly: return "Monthly"
        case .annual: return "Yearly"
        case .lifetime: return "Lifetime"
        }
    }

    var displayPrice: String {
        switch self {
        case .monthly: return "$7.99"
        case .annual: return "$49.99"
        case .lifetime: return "$99.99"
        }
    }

    var period: String {
        switch self {
        case .monthly: return "per month"
        case .annual: return "per year"
        case .lifetime: return "one-time"
        }
    }

    var savings: String? {
        switch self {
        case .monthly: return nil
        case .annual: return "Save 50%"
        case .lifetime: return "Best Value"
        }
    }

    var isRecommended: Bool {
        return false
    }

    var monthlyEquivalent: String? {
        switch self {
        case .annual: return "$3.99/mo"
        default: return nil
        }
    }
}

struct SubscriptionStatus {
    let isActive: Bool
    let productIdentifier: String?
    let expirationDate: Date?
    let willRenew: Bool
}
