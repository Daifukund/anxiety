# Config.plist Validation Setup Guide

## Overview

This app uses a secure `Config.plist` file to store API keys and secrets. To prevent build/runtime failures due to missing configuration, we've implemented multiple layers of validation.

---

## ✅ What We Fixed

### 1. **Graceful Error Handling in ConfigurationManager**
- **Debug builds**: Still crash with `fatalError()` to alert developers immediately
- **Production builds**: Return empty string and log error instead of crashing
- Added `isConfigured` property to check if configuration is valid
- Added `configurationError` property to get human-readable error messages

### 2. **Service-Level Protection**
- `SubscriptionService` and `AnalyticsService` now skip initialization if API keys are empty
- Prevents crashes in RevenueCat/Mixpanel SDKs when keys are missing

### 3. **App Launch Validation**
- Debug builds validate configuration on launch and crash if missing
- Production builds log errors to CrashReporter for visibility

### 4. **Build-Time Validation Script**
- Created `scripts/validate-config.sh` to validate Config.plist before building
- Checks if file exists, is valid plist format, and contains real API keys

---

## 🛠️ How to Add Build Script to Xcode

### Step 1: Open Build Phases
1. Open `anxietyapp.xcodeproj` in Xcode
2. Select the **anxietyapp** target
3. Go to **Build Phases** tab

### Step 2: Add Run Script Phase
1. Click the **+** button at the top left
2. Select **New Run Script Phase**
3. Drag it to be the **FIRST** phase (before "Compile Sources")

### Step 3: Configure the Script
1. Rename the phase to: **"Validate Config.plist"**
2. In the script text area, paste:
   ```bash
   # Validate Config.plist before building
   "${SRCROOT}/scripts/validate-config.sh"
   ```

3. Check the box: **"Show environment variables in build log"** (optional, for debugging)
4. Leave "Based on dependency analysis" **unchecked** (we want this to run every time)

### Step 4: Test the Script
1. Clean build folder (Cmd + Shift + K)
2. Try to build (Cmd + B)
3. You should see green checkmarks in the build log:
   ```
   🔍 Validating Config.plist...
   ✅ Config.plist exists
   ✅ Config.plist is valid plist format
   ✅ RevenueCat API Key is configured
   ✅ Mixpanel Token is configured
   ✅ All configuration validations passed!
   ```

---

## 🧪 Testing the Validation

### Test 1: Missing Config.plist
```bash
cd anxietyapp
mv Config.plist Config.plist.backup
# Now try to build in Xcode - should fail with clear error message
mv Config.plist.backup Config.plist
```

### Test 2: Invalid API Keys
Edit `Config.plist` and change a key to `YOUR_REVENUECAT_API_KEY` - build should fail.

### Test 3: Production Build Behavior
1. Create a Production scheme/configuration
2. Set a breakpoint in `anxietyappApp.init()`
3. Temporarily remove Config.plist
4. Run - app should not crash, but should log error

---

## 📋 Pre-Release Checklist

Before submitting to App Store:

- [ ] Verify `Config.plist` has real API keys (not template values)
- [ ] Build validation script is added to Xcode Build Phases
- [ ] Test that app doesn't crash if Config.plist is missing (production build)
- [ ] Verify services (RevenueCat, Mixpanel) work with real API keys
- [ ] Ensure `Config.plist` is in `.gitignore` (never commit real keys!)

---

## 🔒 Security Notes

### Current Setup
- ✅ `Config.plist` should be in `.gitignore`
- ✅ `Config-Template.plist` is safe to commit (contains placeholder values)
- ✅ Real API keys are only in your local `Config.plist`

### Check .gitignore
Ensure these lines are in `.gitignore`:
```gitignore
# API Keys and Secrets
anxietyapp/Config.plist
Config.plist

# Keep template
!Config-Template.plist
```

### For Team Development
If you have other developers:
1. Share `Config-Template.plist` via git
2. Share real API keys securely (1Password, etc.)
3. Each developer copies template to `Config.plist` and adds their keys

---

## 🚨 Troubleshooting

### Build fails with "Config.plist not found"
**Solution:** Copy the template:
```bash
cd anxietyapp
cp Config-Template.plist Config.plist
# Then edit Config.plist with real API keys
```

### Build fails with "not a valid plist file"
**Solution:** The file is corrupted. Re-copy from template:
```bash
cd anxietyapp
rm Config.plist
cp Config-Template.plist Config.plist
```

### App crashes on launch in debug
**Solution:** This is intentional! Add real API keys to `Config.plist`:
1. Open `Config.plist` in Xcode
2. Update `RevenueCatAPIKey` with your key from https://app.revenuecat.com/
3. Update `MixpanelToken` with your token from https://mixpanel.com/

### Services aren't working (no subscriptions/analytics)
**Solution:** Check that API keys are valid:
```bash
plutil -p anxietyapp/Config.plist
```
Verify the keys don't contain "YOUR_" prefix.

---

## 📚 Related Files

- `anxietyapp/Services/ConfigurationManager.swift` - Configuration loading logic
- `anxietyapp/Config.plist` - Your API keys (not in git)
- `anxietyapp/Config-Template.plist` - Template (safe to commit)
- `scripts/validate-config.sh` - Build validation script
- `anxietyapp/anxietyappApp.swift` - App initialization with config validation

---

## ✅ Summary

The configuration validation is now **production-safe**:

1. **Debug builds** crash immediately if config is missing (fast feedback for developers)
2. **Production builds** never crash, but log errors for diagnostics
3. **Build script** catches configuration issues before archiving
4. **Services** handle empty API keys gracefully

**Result:** Zero risk of App Store rejection or user-facing crashes due to configuration issues! 🎉
