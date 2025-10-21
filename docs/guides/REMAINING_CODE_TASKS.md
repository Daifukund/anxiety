# 🔧 Remaining Code Tasks - Updated Status

## ✅ COMPLETED (Already Done)

### Critical Items ✅
1. ✅ **Fix StoreKit Configuration** - DONE
   - Changed NonConsumable → RecurringSubscription
   - Added subscription groups and renewal periods
   - File: `Configuration.storekit`

2. ✅ **Create Info.plist with Privacy Strings** - DONE
   - All privacy descriptions added
   - ITSAppUsesNonExemptEncryption configured
   - File: `Info.plist`

3. ✅ **Remove Hardcoded API Keys** - DONE
   - Config.plist created (gitignored)
   - ConfigurationManager.swift implemented
   - Files: `Config.plist`, `ConfigurationManager.swift`, `.gitignore`

4. ✅ **Remove Debug Code** - DONE
   - All debug UI wrapped in #if DEBUG
   - Paywall bypass gated properly
   - Files: `ContentView.swift`, `OnboardingPaywallView.swift`, etc.

5. ✅ **Create Entitlements File** - DONE
   - All capabilities configured
   - File: `anxietyapp.entitlements`

### Important Items ✅
7. ✅ **Implement ATT (App Tracking Transparency)** - DONE
   - ATTrackingManager implemented
   - Permission request on app launch
   - File: `anxietyappApp.swift`

8. ✅ **Privacy Manifest** - DONE (bonus)
   - iOS 17+ compliance
   - File: `PrivacyInfo.xcprivacy`

---

## ❌ STILL NEEDED (Code Changes Required)

### 🔴 HIGH PRIORITY

#### 1. Add Crash Reporting ⏱️ 2 hours
**Status:** ❌ Not implemented
**Required for:** Production monitoring, debugging issues in TestFlight/App Store

**Option A: Firebase Crashlytics (Recommended)**
```swift
// 1. Add Firebase SDK via SPM or CocoaPods
// 2. Configure in anxietyappApp.swift

import FirebaseCrashlytics

init() {
    FirebaseApp.configure()
    Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)

    // Existing config...
}

// 3. Add to critical paths
func criticalOperation() {
    do {
        try riskyCode()
    } catch {
        Crashlytics.crashlytics().record(error: error)
        // Handle error
    }
}
```

**Option B: Sentry (Alternative)**
```swift
import Sentry

SentrySDK.start { options in
    options.dsn = "YOUR_SENTRY_DSN"
    options.debug = true // Enabled in debug mode only
}
```

**Files to modify:**
- `anxietyappApp.swift` - Initialize crash reporting
- `SubscriptionService.swift` - Add error tracking to purchase flows
- `UnifiedSOSFlowView.swift` - Track SOS flow errors
- `Package.swift` or `Podfile` - Add dependency

**Why critical:**
- Can't debug production crashes without it
- Required for identifying subscription issues
- Essential for TestFlight feedback

---

#### 2. Move Sensitive Data to Keychain ⏱️ 3 hours
**Status:** ⚠️ Currently using UserDefaults (less secure)
**Security Risk:** Sensitive data accessible in backups, jailbroken devices

**What to migrate:**
```swift
// Current (UserDefaults - less secure):
UserDefaults.standard.set(apiKey, forKey: "apiKey")
UserDefaults.standard.set(token, forKey: "subscriptionToken")

// Should be (Keychain - secure):
KeychainManager.shared.save(apiKey, forKey: "apiKey")
KeychainManager.shared.save(token, forKey: "subscriptionToken")
```

**Implementation:**

**Step 1: Create KeychainManager.swift**
```swift
import Security

class KeychainManager {
    static let shared = KeychainManager()
    private init() {}

    func save(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary) // Delete if exists
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    func get(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    func delete(_ key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }
}
```

**Step 2: Migrate existing UserDefaults usage**

**Files to update:**
- `UserDataService.swift` - User profile data
- `SubscriptionService.swift` - Subscription tokens
- `AnalyticsService.swift` - User identifiers
- Any file using UserDefaults for sensitive data

**Data to migrate:**
- ✅ User profile data
- ✅ Subscription status/tokens
- ✅ Anonymous user IDs
- ❌ Keep UI preferences in UserDefaults (theme, etc.)

---

### 🟠 MEDIUM PRIORITY

#### 3. Complete Accessibility Implementation ⏱️ 3 hours
**Status:** ⚠️ Partial - Some labels exist, not comprehensive

**Required changes:**

**A. Add VoiceOver Labels**
```swift
// Current (missing accessibility):
Button(action: { showingSOS = true }) {
    Text("SOS")
}

// Fixed:
Button(action: { showingSOS = true }) {
    Text("SOS")
}
.accessibilityLabel("Emergency SOS button")
.accessibilityHint("Double tap for immediate anxiety relief options")
.accessibilityAddTraits(.isButton)
```

**Files needing accessibility audit:**
- `DashboardView.swift` - SOS button, mood circles
- `BreathingExerciseView.swift` - Breathing controls
- `GroundingExerciseView.swift` - Grounding technique steps
- `SettingsView.swift` - All settings toggles
- `OnboardingPaywallView.swift` - Subscription options

**B. Dynamic Type Support**
```swift
// Current (fixed font sizes):
.font(.system(size: 24, weight: .bold))

// Fixed (scales with accessibility settings):
.font(.title2)
// or
.font(.system(.title2, design: .rounded, weight: .bold))
```

**C. Minimum Touch Targets**
```swift
// Ensure all interactive elements are at least 44x44 points
Button(action: {}) {
    Image(systemName: "gear")
}
.frame(minWidth: 44, minHeight: 44) // ✅ Meets accessibility guidelines
```

**Testing:**
1. Enable VoiceOver: Settings → Accessibility → VoiceOver
2. Navigate entire app with VoiceOver
3. Test with larger text sizes: Settings → Accessibility → Display & Text Size
4. Verify color contrast (use Xcode Accessibility Inspector)

---

#### 4. Implement Certificate Pinning (Optional) ⏱️ 2 hours
**Status:** ❌ Not implemented
**Security Level:** Medium priority (HTTPS already used)

**Why implement:**
- Prevents man-in-the-middle attacks
- Extra security for API calls (RevenueCat, Mixpanel)
- Best practice for healthcare/mental health apps

**Implementation:**

**Create NetworkSecurityManager.swift**
```swift
import Foundation

class NetworkSecurityManager: NSObject, URLSessionDelegate {

    // SHA256 hashes of your API certificates
    private let pinnedCertificates = [
        "api.revenuecat.com": "CERTIFICATE_HASH_HERE",
        "api.mixpanel.com": "CERTIFICATE_HASH_HERE"
    ]

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let serverCertificateData = SecCertificateCopyData(certificate) as Data
        let serverCertificateHash = serverCertificateData.sha256()

        let host = challenge.protectionSpace.host

        if let pinnedHash = pinnedCertificates[host],
           pinnedHash == serverCertificateHash {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
```

**Note:** This is optional for MVP. Consider for v1.1 or if handling very sensitive data.

---

#### 5. Add Jailbreak Detection (Optional) ⏱️ 1 hour
**Status:** ❌ Not implemented
**Priority:** Low (optional security measure)

**Why implement:**
- Prevent tampering with subscription checks
- Protect against piracy
- Common in paid apps

**Implementation:**

**Create SecurityChecker.swift**
```swift
class SecurityChecker {

    static func isJailbroken() -> Bool {
        #if targetEnvironment(simulator)
        return false // Don't check in simulator
        #else

        // Check for common jailbreak files
        let jailbreakPaths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/"
        ]

        for path in jailbreakPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }

        // Check if we can write outside sandbox
        let testPath = "/private/jailbreak_test.txt"
        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            return true // Should not be able to write here
        } catch {
            return false
        }

        #endif
    }

    static func handleJailbrokenDevice() {
        // Option 1: Show warning
        print("⚠️ Warning: Jailbroken device detected")

        // Option 2: Disable certain features
        // SubscriptionService.shared.disablePremiumFeatures()

        // Option 3: Exit app (extreme)
        // exit(0)
    }
}
```

**Usage in anxietyappApp.swift:**
```swift
init() {
    #if !DEBUG
    if SecurityChecker.isJailbroken() {
        SecurityChecker.handleJailbrokenDevice()
    }
    #endif

    // Existing configuration...
}
```

**Note:** This is very optional. Many successful apps don't implement this.

---

## 📊 Priority Summary

### Must Do (Before TestFlight):
1. ❌ **Add Crash Reporting** (2 hours) - CRITICAL
   - Can't debug production issues without it
   - Essential for TestFlight

2. ❌ **Move Sensitive Data to Keychain** (3 hours) - HIGH
   - Better security than UserDefaults
   - Protects user data in backups

3. ⚠️ **Complete Accessibility** (3 hours) - IMPORTANT
   - VoiceOver labels
   - Dynamic Type support
   - Required for App Store approval (accessibility checklist)

### Nice to Have (Can Do Later):
4. ❌ Certificate Pinning (2 hours) - OPTIONAL
   - Extra security layer
   - Can add in v1.1

5. ❌ Jailbreak Detection (1 hour) - OPTIONAL
   - Anti-piracy measure
   - Not critical for MVP

---

## 🎯 Recommended Implementation Order

### Week 1 (Before TestFlight):
1. **Day 1-2:** Crash Reporting (Firebase Crashlytics)
2. **Day 3-4:** Keychain Migration
3. **Day 5:** Accessibility Audit & Fixes

### Week 2+ (Post-TestFlight, if needed):
4. Certificate Pinning (if security audit requires)
5. Jailbreak Detection (if piracy becomes concern)

---

## ✅ What's Already Production-Ready

These are DONE and don't need changes:
- ✅ StoreKit configuration (subscriptions work)
- ✅ Info.plist (all privacy strings)
- ✅ API key security (Config.plist, gitignored)
- ✅ Debug code removed (all gated)
- ✅ Entitlements (all capabilities)
- ✅ ATT implementation (tracking permission)
- ✅ Privacy Manifest (iOS 17+ compliance)

---

## 📋 Final Code Checklist

**Before TestFlight:**
- [ ] Add crash reporting (Firebase/Sentry)
- [ ] Migrate sensitive data to Keychain
- [ ] Complete accessibility implementation
- [ ] Test VoiceOver throughout app
- [ ] Test Dynamic Type support

**Optional (Post-MVP):**
- [ ] Certificate pinning
- [ ] Jailbreak detection
- [ ] Advanced security hardening

---

**Current Status:** 70% code-complete for production
**Remaining Time:** ~8 hours of coding (crash reporting + keychain + accessibility)
**Timeline:** 1-2 days of focused work

---

## 🚀 Next Steps

1. **Choose crash reporting solution:**
   - Firebase Crashlytics (recommended, free)
   - Sentry (alternative, paid tiers)

2. **Implement KeychainManager** (3 hours)
   - Create utility class
   - Migrate UserDefaults → Keychain
   - Test data persistence

3. **Accessibility audit** (3 hours)
   - Add VoiceView labels
   - Implement Dynamic Type
   - Test with accessibility features

4. **Test everything** (1-2 hours)
   - Run app with VoiceOver
   - Test crash reporting
   - Verify keychain storage

**Total remaining:** ~8-10 hours of code work before TestFlight-ready
