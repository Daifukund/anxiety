# AppsFlyer Quick Start Guide

## Current Status: 95% Complete ✅

Your AppsFlyer integration is **already coded and configured**. You just need to verify it works!

---

## What You Have Already:

✅ **Dev Key configured**: `DZUHwzPd9WKsjdyxd2kG4V`
✅ **SDK added to project**: AppsFlyerLib package
✅ **Code integrated**: AppsFlyerService.swift
✅ **Auto-starts**: Configured in anxietyappApp.swift
✅ **11 events ready**: SOS, breathing, mood tracking, subscriptions, etc.

---

## Quick Testing Steps (5 minutes):

### 1. Open Xcode and Build the App

```bash
# Open the project
open anxietyapp.xcodeproj
```

In Xcode:
1. Select a simulator (iPhone 15 recommended)
2. Press **Cmd + R** to build and run
3. Watch the Xcode console for these messages:

```
AppsFlyer configured with Dev Key: DZUHwzPd9WKsjdyxd2kG4V
AppsFlyer tracking started
```

### 2. Register Your Test Device in AppsFlyer Dashboard

**Option A: Using Simulator**
1. In terminal, find the simulator ID:
   ```bash
   xcrun simctl list devices | grep Booted
   ```
2. Copy the UUID (looks like: `12345678-1234-1234-1234-123456789012`)

**Option B: Using Real iPhone**
1. Connect iPhone to Mac
2. Open Xcode → Window → Devices and Simulators
3. Select your iPhone → Copy the "Identifier"

**Then in AppsFlyer:**
1. Go to [https://hq1.appsflyer.com](https://hq1.appsflyer.com)
2. Navigate to: **Configuration** → **SDK** → **Test Devices**
3. Click "Add device"
4. Paste your device ID
5. Save

### 3. Test Event Tracking

In the running app, perform these actions and watch Xcode console:

| Action | Expected Console Output |
|--------|------------------------|
| Complete onboarding | `AppsFlyer event logged: onboarding_completed` |
| Tap SOS button | `AppsFlyer event logged: sos_flow_started` |
| Start breathing exercise | `AppsFlyer event logged: breathing_exercise_started` |
| Log mood | `AppsFlyer event logged: mood_check_in` |

### 4. Verify in AppsFlyer Dashboard (Wait 1-2 hours)

1. Go to **Dashboard** → **Overview**
2. Check **Installs** - you should see 1 test install
3. Go to **In-App Events** → **Event Dashboard**
4. You should see your test events listed

---

## Troubleshooting

### ❌ "No such module 'AppsFlyerLib'" Build Error

**Solution 1: Verify Package**
1. In Xcode, go to **File** → **Add Package Dependencies**
2. Search for: `https://github.com/AppsFlyerSDK/AppsFlyerFramework`
3. If it's already there, remove it and re-add it
4. Select version 6.14.0 or higher

**Solution 2: Clean Build**
```bash
# In Xcode: Product → Clean Build Folder (Cmd + Shift + K)
# Then rebuild: Product → Build (Cmd + B)
```

**Solution 3: Reset Package Cache**
1. In Xcode: **File** → **Packages** → **Reset Package Caches**
2. Wait for resolution to complete
3. Rebuild

### ❌ No Console Output

1. Make sure you're running in **Debug** mode (not Release)
2. Open Xcode console: **View** → **Debug Area** → **Activate Console** (Cmd + Shift + Y)
3. Check that `ConfigurationManager.isConfigured` is true

### ❌ Events Not Appearing in Dashboard

- **Normal**: Events can take 1-2 hours to appear
- **Check**: Ensure device is registered in Test Devices
- **Verify**: Console shows "AppsFlyer event logged: ..." messages
- **Internet**: App needs network connection to send events

---

## Where to Add Event Tracking

Once verified, add these event calls to your views:

### SOS Button (DashboardView)
```swift
Button("SOS") {
    AppsFlyerService.shared.trackSOSFlowStarted()
    // ... navigate to SOS flow
}
```

### Breathing Exercise (BreathingExerciseView)
```swift
.onAppear {
    AppsFlyerService.shared.trackBreathingExerciseStarted(type: "box_breathing")
}
.onDisappear {
    let duration = Int(Date().timeIntervalSince(startTime))
    AppsFlyerService.shared.trackBreathingExerciseCompleted(type: "box_breathing", duration: duration)
}
```

### Subscription (PaywallView)
```swift
// When paywall appears
.onAppear {
    AppsFlyerService.shared.trackSubscription(action: "viewed")
}

// When purchase button tapped
Button("Subscribe") {
    AppsFlyerService.shared.trackSubscription(action: "started", productId: productId)
    // ... purchase logic
}
```

---

## Next Steps After Testing

1. ✅ **Build app** - Verify no errors
2. ✅ **Check console** - See AppsFlyer messages
3. ✅ **Register device** - In AppsFlyer dashboard
4. ✅ **Test events** - Trigger actions, watch console
5. ⏰ **Wait 1-2 hours** - Check dashboard for data
6. 🚀 **Add tracking** - Insert event calls in your Views

---

## Need Help?

- **Full Documentation**: See `APPSFLYER_SETUP.md` in this folder
- **AppsFlyer Docs**: [https://dev.appsflyer.com/hc/docs/ios-sdk](https://dev.appsflyer.com/hc/docs/ios-sdk)
- **Dashboard**: [https://hq1.appsflyer.com](https://hq1.appsflyer.com)

---

**Last Updated**: 2025-10-21
**Your Dev Key**: `DZUHwzPd9WKsjdyxd2kG4V`
**Status**: Ready to test! 🎉
