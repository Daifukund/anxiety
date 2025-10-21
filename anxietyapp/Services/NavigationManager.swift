//
//  NavigationManager.swift
//  anxietyapp
//
//  Manages deep linking and navigation from widgets
//

import SwiftUI
import Combine

class NavigationManager: ObservableObject {
    static let shared = NavigationManager()

    /// Trigger SOS flow from widget or deep link
    @Published var shouldShowSOS: Bool = false

    /// Trigger feedback form from Quick Action
    @Published var shouldShowFeedback: Bool = false

    private init() {}

    /// Handle deep link URL from widget
    func handleDeepLink(_ url: URL) {
        #if DEBUG
        print("🔗 Deep link received: \(url)")
        #endif

        // Parse the URL
        guard url.scheme == AppGroup.urlScheme else {
            #if DEBUG
            print("❌ Invalid URL scheme: \(url.scheme ?? "none")")
            #endif
            return
        }

        // Route based on host
        switch url.host {
        case "sos":
            #if DEBUG
            print("✅ Triggering SOS flow from widget")
            #endif
            // Small delay to ensure app is fully loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.shouldShowSOS = true
            }

        default:
            #if DEBUG
            print("⚠️ Unknown deep link host: \(url.host ?? "none")")
            #endif
        }
    }

    /// Reset SOS trigger
    func dismissSOS() {
        shouldShowSOS = false
    }

    /// Handle Quick Action from home screen long-press
    func handleQuickAction(_ type: String) {
        #if DEBUG
        print("🚀 Quick Action received: \(type)")
        #endif

        switch type {
        case "com.nuvin.feedback":
            #if DEBUG
            print("✅ Triggering feedback form")
            #endif
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.shouldShowFeedback = true
            }

        case "com.nuvin.emergency":
            #if DEBUG
            print("✅ Triggering emergency SOS")
            #endif
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.shouldShowSOS = true
            }

        default:
            #if DEBUG
            print("⚠️ Unknown Quick Action type: \(type)")
            #endif
        }
    }

    /// Reset feedback trigger
    func dismissFeedback() {
        shouldShowFeedback = false
    }
}
