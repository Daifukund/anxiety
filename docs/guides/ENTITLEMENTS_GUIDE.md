# 🔐 Entitlements Configuration Guide

## Overview

The `anxietyapp.entitlements` file defines the app's capabilities and permissions required for iOS features like in-app purchases, push notifications, and HealthKit integration.

## Configured Capabilities

### 1. ✅ In-App Purchases
```xml
<key>com.apple.developer.in-app-payments</key>
<array>
    <string>com.apple.developer.in-app-payments</string>
</array>
```

**Purpose:** Required for RevenueCat and StoreKit subscriptions
**Status:** ✅ Required for your subscription model
**App Store Connect:** Must enable "In-App Purchase" capability

---

### 2. ✅ Push Notifications
```xml
<key>aps-environment</key>
<string>development</string>
```

**Purpose:** Local and remote push notifications for:
- Mood check-in reminders
- Daily quote notifications
- Future: Subscription renewal reminders

**Important:**
- **Development builds:** Uses `development` APS environment
- **Production/TestFlight:** Xcode automatically changes to `production` when archiving
- **App Store Connect:** Must enable "Push Notifications" capability

**Current Status:** Local notifications only (no server required)

---

### 3. ✅ App Groups
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.eunoia.anxietyapp</string>
</array>
```

**Purpose:** Share data between:
- Main app
- Widget extensions (future)
- Today extensions (future)
- Watch app (future)

**Status:** ✅ Configured for future features
**App Store Connect:** Must create matching App Group ID: `group.eunoia.anxietyapp`

---

### 4. ✅ HealthKit
```xml
<key>com.apple.developer.healthkit</key>
<true/>
<key>com.apple.developer.healthkit.access</key>
<array/>
```

**Purpose:** Future integration to:
- Export mindfulness minutes to Apple Health
- Track breathing exercise sessions
- Read heart rate data (optional)

**Status:** ⚠️ Optional - Not currently used
**Implementation:** Requires:
- HealthKit framework import
- Privacy usage descriptions (already in Info.plist)
- User consent flow

**To Enable Later:**
1. Import HealthKit framework
2. Request authorization
3. Add specific data types to `healthkit.access` array

---

### 5. ✅ Keychain Sharing
```xml
<key>keychain-access-groups</key>
<array>
    <string>$(AppIdentifierPrefix)eunoia.anxietyapp</string>
</array>
```

**Purpose:** Secure storage for:
- User credentials
- Subscription tokens
- Sensitive user data
- Shared keychain access (future multi-app support)

**Status:** ✅ Best practice for security
**Benefit:** More secure than UserDefaults for sensitive data

---

## App Store Connect Setup

### Required Steps Before Submission:

#### 1. Enable Capabilities in App Store Connect
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app → **Certificates, Identifiers & Profiles**
3. Select **Identifiers** → Your App ID (`eunoia.anxietyapp`)
4. Enable:
   - ✅ **In-App Purchase**
   - ✅ **Push Notifications**
   - ✅ **App Groups** (create: `group.eunoia.anxietyapp`)
   - ⚠️ **HealthKit** (optional, enable if you add integration)

#### 2. Create App Group
1. In Identifiers, select **App Groups**
2. Click **+** to create new
3. Description: "Nuvin App Data Sharing"
4. Identifier: `group.eunoia.anxietyapp`
5. Click **Continue** → **Register**

#### 3. Regenerate Provisioning Profiles
After enabling capabilities:
1. Go to **Profiles**
2. Delete existing development/distribution profiles
3. Xcode will auto-generate new profiles with correct entitlements

---

## Development vs Production

### Development Entitlements (Current)
```xml
<key>aps-environment</key>
<string>development</string>
```

### Production Entitlements (Automatic)
When you **Archive** for App Store/TestFlight, Xcode automatically:
- Changes `development` → `production`
- Signs with Distribution certificate
- Uses Production provisioning profile

**You don't need separate entitlements files** ✅

---

## Testing Push Notifications

### Local Notifications (Currently Used)
- ✅ Works in simulator
- ✅ Works on device
- ✅ No server required
- ✅ No APNS certificate needed

### Remote Notifications (Future)
If you add server-side push notifications:
1. Get APNS certificate from Apple Developer
2. Configure server with certificate
3. Test with development certificate first
4. Switch to production certificate for App Store

---

## Troubleshooting

### ❌ Error: "No provisioning profiles match entitlements"
**Solution:**
1. Xcode → Preferences → Accounts → Download Manual Profiles
2. Or: Delete derived data and clean build folder
3. Rebuild project

### ❌ Error: "App Group not found"
**Solution:**
1. Create App Group in App Store Connect (see above)
2. Wait 5-10 minutes for propagation
3. Download new provisioning profiles

### ❌ Error: "HealthKit capability not enabled"
**Solution:**
1. Enable HealthKit in App Store Connect
2. If not using HealthKit yet, remove from entitlements:
   ```xml
   <!-- Comment out or remove HealthKit -->
   <!--
   <key>com.apple.developer.healthkit</key>
   <true/>
   -->
   ```

### ❌ Error: "Push notification entitlement not recognized"
**Solution:**
1. Ensure bundle ID matches: `eunoia.anxietyapp`
2. Enable Push Notifications in App Store Connect
3. Clean build folder (Cmd+Shift+K)

---

## Security Best Practices

### ✅ DO:
- Use Keychain for sensitive data (tokens, credentials)
- Keep entitlements minimal (only what you need)
- Test on real device before submission
- Verify all capabilities in App Store Connect

### ❌ DON'T:
- Add unnecessary entitlements (increases review scrutiny)
- Store sensitive data in UserDefaults
- Forget to test push notifications on device
- Skip App Store Connect capability setup

---

## Migration from UserDefaults to Keychain (Recommended)

For better security, migrate sensitive data:

```swift
// BEFORE (less secure)
UserDefaults.standard.set(apiKey, forKey: "apiKey")

// AFTER (more secure)
import Security

func saveToKeychain(key: String, data: Data) {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecValueData as String: data
    ]
    SecItemAdd(query as CFDictionary, nil)
}
```

---

## Verification Checklist

- [x] Entitlements file created (`anxietyapp.entitlements`)
- [x] Added to Xcode project (`CODE_SIGN_ENTITLEMENTS`)
- [x] Valid plist syntax (verified with plutil)
- [x] In-App Purchase capability included
- [x] Push Notifications capability included
- [x] App Groups configured
- [x] Keychain sharing enabled
- [ ] **TODO:** Enable capabilities in App Store Connect
- [ ] **TODO:** Create App Group in Developer Portal
- [ ] **TODO:** Test on real device

---

## Next Steps

### Before TestFlight:
1. ✅ Entitlements file created
2. ⚠️ Enable capabilities in App Store Connect
3. ⚠️ Create App Group ID
4. ⚠️ Test push notifications on device
5. ⚠️ Verify in-app purchases work

### Before Production:
1. Archive build (Xcode handles production entitlements)
2. Upload to App Store Connect
3. Verify capabilities in App Review
4. Submit for review

---

**Status: ✅ ENTITLEMENTS CONFIGURED**

All required capabilities are properly configured in the entitlements file.
