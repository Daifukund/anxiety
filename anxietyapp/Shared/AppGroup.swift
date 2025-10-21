//
//  AppGroup.swift
//  anxietyapp
//
//  Shared constants for app and widget communication
//

import Foundation

enum AppGroup {
    /// App Group identifier for sharing data between app and widget
    /// IMPORTANT: Must match the App Group configured in Signing & Capabilities
    static let identifier = "group.eunoia.anxietyapp"

    /// URL scheme for deep linking from widget to app
    static let urlScheme = "nuvin"

    /// Deep link URLs
    enum DeepLink {
        static var sosFlow: URL {
            guard let url = URL(string: "\(AppGroup.urlScheme)://sos") else {
                // This should never fail with a hardcoded scheme, but provide fallback
                fatalError("Invalid deep link URL configuration for SOS flow")
            }
            return url
        }
    }

    /// Shared UserDefaults for data between app and widget
    static var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: identifier)
    }
}
