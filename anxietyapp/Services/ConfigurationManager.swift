//
//  ConfigurationManager.swift
//  anxietyapp
//
//  Secure configuration manager for API keys and secrets
//

import Foundation

enum ConfigurationManager {

    // MARK: - Configuration Keys

    private enum Keys {
        static let revenueCatAPIKey = "RevenueCatAPIKey"
        static let mixpanelToken = "MixpanelToken"
        static let appsFlyerDevKey = "AppsFlyerDevKey"
    }

    // MARK: - Configuration Status

    /// Returns true if all required configuration keys are present and valid
    static var isConfigured: Bool {
        return getValue(forKey: Keys.revenueCatAPIKey) != nil &&
               getValue(forKey: Keys.mixpanelToken) != nil &&
               getValue(forKey: Keys.appsFlyerDevKey) != nil
    }

    /// Returns error message if configuration is invalid
    static var configurationError: String? {
        if getValue(forKey: Keys.revenueCatAPIKey) == nil {
            return "RevenueCat API Key not found in Config.plist"
        }
        if getValue(forKey: Keys.mixpanelToken) == nil {
            return "Mixpanel Token not found in Config.plist"
        }
        if getValue(forKey: Keys.appsFlyerDevKey) == nil {
            return "AppsFlyer Dev Key not found in Config.plist"
        }
        return nil
    }

    // MARK: - Configuration Access

    static var revenueCatAPIKey: String {
        guard let key = getValue(forKey: Keys.revenueCatAPIKey) else {
            #if DEBUG
            // In debug builds, crash immediately to alert developer
            fatalError("❌ RevenueCat API Key not found in Config.plist. Please copy Config-Template.plist to Config.plist and add your keys.")
            #else
            // In production, return empty string to prevent crash
            // Services should handle this gracefully
            print("❌ CRITICAL: RevenueCat API Key missing from Config.plist")
            return ""
            #endif
        }
        return key
    }

    static var mixpanelToken: String {
        guard let token = getValue(forKey: Keys.mixpanelToken) else {
            #if DEBUG
            // In debug builds, crash immediately to alert developer
            fatalError("❌ Mixpanel Token not found in Config.plist. Please copy Config-Template.plist to Config.plist and add your keys.")
            #else
            // In production, return empty string to prevent crash
            // Services should handle this gracefully
            print("❌ CRITICAL: Mixpanel Token missing from Config.plist")
            return ""
            #endif
        }
        return token
    }

    static var appsFlyerDevKey: String {
        guard let key = getValue(forKey: Keys.appsFlyerDevKey) else {
            #if DEBUG
            // In debug builds, crash immediately to alert developer
            fatalError("❌ AppsFlyer Dev Key not found in Config.plist. Please copy Config-Template.plist to Config.plist and add your keys.")
            #else
            // In production, return empty string to prevent crash
            // Services should handle this gracefully
            print("❌ CRITICAL: AppsFlyer Dev Key missing from Config.plist")
            return ""
            #endif
        }
        return key
    }

    // MARK: - Private Helper

    private static func getValue(forKey key: String) -> String? {
        // Try to load from Config.plist
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path),
              let value = config[key] as? String,
              !value.isEmpty,
              !value.contains("YOUR_") else {
            return nil
        }

        return value
    }

    // MARK: - Debug Helper

    #if DEBUG
    static func printConfiguration() {
        print("🔑 Configuration Status:")
        print("  - RevenueCat API Key: \(revenueCatAPIKey.prefix(15))...")
        print("  - Mixpanel Token: \(mixpanelToken.prefix(15))...")
        print("  - AppsFlyer Dev Key: \(appsFlyerDevKey.prefix(15))...")
    }
    #endif
}
