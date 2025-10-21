//
//  HapticManager.swift
//  anxietyapp
//
//  Centralized haptic feedback management with settings integration
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

class HapticManager {
    static let shared = HapticManager()

    private init() {}

    /// Check if haptics are enabled in user settings
    private var hapticsEnabled: Bool {
        // Default to true if not set
        if UserDefaults.standard.object(forKey: "hapticsEnabled") == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: "hapticsEnabled")
    }

    /// Trigger impact haptic feedback if enabled
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        #if os(iOS)
        guard hapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
        #endif
    }

    /// Trigger notification haptic feedback if enabled
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        #if os(iOS)
        guard hapticsEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
        #endif
    }

    /// Trigger selection haptic feedback if enabled
    func selection() {
        #if os(iOS)
        guard hapticsEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        #endif
    }
}
