//
//  KeychainManager.swift
//  anxietyapp
//
//  Secure storage for sensitive data using iOS Keychain
//  More secure than UserDefaults (encrypted, survives app deletion if configured)
//

import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    private init() {}

    // MARK: - Service Identifier

    private let service = Bundle.main.bundleIdentifier ?? "eunoia.anxietyapp"

    // MARK: - Save to Keychain

    /// Save a string value to Keychain
    @discardableResult
    func save(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            #if DEBUG
            print("❌ KeychainManager: Failed to encode value for key '\(key)'")
            #endif
            return false
        }

        return save(data, forKey: key)
    }

    /// Save data to Keychain
    @discardableResult
    func save(_ data: Data, forKey key: String) -> Bool {
        // Build query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        // Delete existing item if it exists
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecSuccess {
            #if DEBUG
            print("✅ KeychainManager: Saved '\(key)'")
            #endif
            return true
        } else {
            #if DEBUG
            print("❌ KeychainManager: Failed to save '\(key)' (status: \(status))")
            #endif
            return false
        }
    }

    // MARK: - Retrieve from Keychain

    /// Get a string value from Keychain
    func getString(forKey key: String) -> String? {
        guard let data = getData(forKey: key) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    /// Get data from Keychain
    func getData(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data else {
            #if DEBUG
            if status != errSecItemNotFound {
                print("⚠️ KeychainManager: Failed to retrieve '\(key)' (status: \(status))")
            }
            #endif
            return nil
        }

        #if DEBUG
        print("✅ KeychainManager: Retrieved '\(key)'")
        #endif

        return data
    }

    // MARK: - Delete from Keychain

    /// Delete a value from Keychain
    @discardableResult
    func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status == errSecSuccess || status == errSecItemNotFound {
            #if DEBUG
            print("✅ KeychainManager: Deleted '\(key)'")
            #endif
            return true
        } else {
            #if DEBUG
            print("❌ KeychainManager: Failed to delete '\(key)' (status: \(status))")
            #endif
            return false
        }
    }

    // MARK: - Update in Keychain

    /// Update an existing value in Keychain
    @discardableResult
    func update(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            return false
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if status == errSecSuccess {
            #if DEBUG
            print("✅ KeychainManager: Updated '\(key)'")
            #endif
            return true
        } else if status == errSecItemNotFound {
            // Item doesn't exist, create it
            return save(value, forKey: key)
        } else {
            #if DEBUG
            print("❌ KeychainManager: Failed to update '\(key)' (status: \(status))")
            #endif
            return false
        }
    }

    // MARK: - Clear All

    /// Clear all Keychain items for this app (use with caution!)
    @discardableResult
    func clearAll() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status == errSecSuccess || status == errSecItemNotFound {
            #if DEBUG
            print("🗑️ KeychainManager: Cleared all items")
            #endif
            return true
        } else {
            #if DEBUG
            print("❌ KeychainManager: Failed to clear all items (status: \(status))")
            #endif
            return false
        }
    }

    // MARK: - Convenience Methods for Codable

    /// Save a Codable object to Keychain
    func save<T: Encodable>(_ object: T, forKey key: String) -> Bool {
        do {
            let data = try JSONEncoder().encode(object)
            return save(data, forKey: key)
        } catch {
            #if DEBUG
            print("❌ KeychainManager: Failed to encode object for key '\(key)': \(error)")
            #endif
            return false
        }
    }

    /// Retrieve a Codable object from Keychain
    func getObject<T: Decodable>(forKey key: String, as type: T.Type) -> T? {
        guard let data = getData(forKey: key) else {
            return nil
        }

        do {
            let object = try JSONDecoder().decode(type, from: data)
            return object
        } catch {
            #if DEBUG
            print("❌ KeychainManager: Failed to decode object for key '\(key)': \(error)")
            #endif
            return nil
        }
    }
}

// MARK: - Keychain Keys (Centralized)

extension KeychainManager {
    enum Keys {
        // User data
        static let userProfile = "user_profile"
        static let anonymousUserID = "anonymous_user_id"

        // Subscription data
        static let subscriptionToken = "subscription_token"
        static let subscriptionStatus = "subscription_status"

        // Analytics
        static let analyticsUserID = "analytics_user_id"

        // Other sensitive data
        static let lastSyncTimestamp = "last_sync_timestamp"
    }
}

// MARK: - Migration Helper

extension KeychainManager {
    /// Migrate data from UserDefaults to Keychain
    func migrateFromUserDefaults() {
        let defaults = UserDefaults.standard

        // List of keys to migrate (sensitive data only)
        let keysToMigrate: [String] = [
            // Add any UserDefaults keys that should be in Keychain
            // We'll identify these when updating services
        ]

        var migratedCount = 0

        for key in keysToMigrate {
            if let value = defaults.string(forKey: key) {
                if save(value, forKey: key) {
                    defaults.removeObject(forKey: key)
                    migratedCount += 1
                    #if DEBUG
                    print("📦 Migrated '\(key)' from UserDefaults to Keychain")
                    #endif
                }
            }
        }

        if migratedCount > 0 {
            #if DEBUG
            print("✅ Migration complete: \(migratedCount) items moved to Keychain")
            #endif
        }
    }
}
