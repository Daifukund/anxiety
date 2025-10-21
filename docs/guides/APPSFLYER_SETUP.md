# AppsFlyer Integration Guide

This guide explains the AppsFlyer attribution and analytics implementation for the Nuvin anxiety relief app.

## Overview

AppsFlyer is integrated to provide:
- **Attribution tracking**: Understand which marketing campaigns drive installs
- **In-app event tracking**: Monitor user engagement with key features
- **Deep linking**: Support campaign-specific user journeys
- **ROI measurement**: Track conversion from ad spend to subscriptions

## Installation

### Step 1: Add AppsFlyer SDK via Swift Package Manager

1. Open `anxietyapp.xcodeproj` in Xcode
2. Go to **File → Add Package Dependencies**
3. Enter the AppsFlyer SDK repository URL:
   ```
   https://github.com/AppsFlyerSDK/AppsFlyerFramework
   ```
4. Select version **6.14.0** or later (use "Up to Next Major Version")
5. Click **Add Package**
6. When prompted, select **AppsFlyerLib** to add to your target
7. Click **Add Package** to confirm

### Step 2: Verify Configuration Files

The following files have already been configured:

- ✅ **AppsFlyerService.swift** - Main service class
- ✅ **AppsFlyerEvents.swift** - Event tracking examples
- ✅ **ConfigurationManager.swift** - Updated with AppsFlyer key support
- ✅ **Config.plist** - Contains your AppsFlyer Dev Key
- ✅ **Info.plist** - AppsFlyer configuration added
- ✅ **anxietyappApp.swift** - Initialization code added

## Configuration

### Your AppsFlyer Credentials

- **Dev Key**: `DZUHwzPd9WKsjdyxd2kG4V` (stored in Config.plist)
- **App ID**: `eunoia.anxietyapp` (your bundle identifier)

### How It Works

1. **App Launch**: AppsFlyer is configured in `anxietyappApp.swift` init()
2. **App Becomes Active**: Tracking starts in `AppDelegate.applicationDidBecomeActive()`
3. **Event Tracking**: Events are logged via `AppsFlyerService.shared`

## Event Tracking

### Pre-configured Events

The following events are ready to use throughout your app:

#### 1. Onboarding Events
```swift
// When user completes onboarding
AppsFlyerService.shared.trackOnboardingCompleted()
```

#### 2. SOS Flow Events
```swift
// When SOS button is tapped
AppsFlyerService.shared.trackSOSFlowStarted()

// When SOS technique is completed
AppsFlyerService.shared.trackSOSFlowCompleted(technique: "breathing")
```

#### 3. Breathing Exercise Events
```swift
// When exercise starts
AppsFlyerService.shared.trackBreathingExerciseStarted(type: "box_breathing")

// When exercise completes
AppsFlyerService.shared.trackBreathingExerciseCompleted(
    type: "box_breathing",
    duration: 240  // seconds
)
```

#### 4. Grounding Technique Events
```swift
// When grounding technique is used
AppsFlyerService.shared.trackGroundingTechniqueUsed(type: "5-4-3-2-1")
```

#### 5. Mood Tracking Events
```swift
// When user logs mood
AppsFlyerService.shared.trackMoodCheckIn(
    mood: "😊",
    notes: "Feeling better after breathing exercise"
)
```

#### 6. Subscription Events
```swift
// Paywall viewed
AppsFlyerService.shared.trackSubscription(action: "viewed")

// Purchase started
AppsFlyerService.shared.trackSubscription(action: "started", productId: "premium_monthly")

// Purchase completed
AppsFlyerService.shared.trackSubscription(action: "completed", productId: "premium_monthly")

// Subscription cancelled
AppsFlyerService.shared.trackSubscription(action: "cancelled")
```

### Custom Events
```swift
// Track any custom event
AppsFlyerService.shared.logEvent("custom_event_name", parameters: [
    "parameter1": "value1",
    "parameter2": 123,
    "timestamp": ISO8601DateFormatter().string(from: Date())
])
```

## Integration Examples

### Example 1: Track SOS Button in Dashboard
```swift
struct DashboardView: View {
    var body: some View {
        Button("SOS - Get Relief Now") {
            // Track the event
            AppsFlyerService.shared.trackSOSFlowStarted()

            // Navigate to SOS flow
            showSOSFlow = true
        }
    }
}
```

### Example 2: Track Breathing Exercise
```swift
struct BreathingExerciseView: View {
    @State private var startTime = Date()
    let exerciseType = "box_breathing"

    var body: some View {
        VStack {
            // Breathing exercise UI
        }
        .onAppear {
            startTime = Date()
            AppsFlyerService.shared.trackBreathingExerciseStarted(type: exerciseType)
        }
        .onDisappear {
            let duration = Int(Date().timeIntervalSince(startTime))
            if duration > 10 { // Only track if they did it for >10 seconds
                AppsFlyerService.shared.trackBreathingExerciseCompleted(
                    type: exerciseType,
                    duration: duration
                )
            }
        }
    }
}
```

### Example 3: Track Subscription Purchase
```swift
class SubscriptionViewModel: ObservableObject {
    func purchaseSubscription(productId: String) async {
        // Track purchase start
        AppsFlyerService.shared.trackSubscription(action: "started", productId: productId)

        do {
            // RevenueCat purchase logic
            let result = try await Purchases.shared.purchase(package: package)

            // Track successful purchase
            AppsFlyerService.shared.trackSubscription(action: "completed", productId: productId)
        } catch {
            // Handle error - don't track completion
            print("Purchase failed: \(error)")
        }
    }
}
```

## Testing

### Enable Debug Mode

Debug mode is automatically enabled in DEBUG builds. Check Xcode console for AppsFlyer logs:

```
AppsFlyer configured with Dev Key: DZUHwzPd9WKsjdyxd2kG4V
AppsFlyer tracking started
AppsFlyer event logged: sos_flow_started
```

### Testing in Simulator

1. Run the app in iOS Simulator
2. Perform actions that trigger events (tap SOS, complete breathing exercise, etc.)
3. Check Xcode console for "AppsFlyer event logged:" messages
4. Events will appear in AppsFlyer dashboard within 1-2 hours

### Testing on Device

1. Build and run on a physical device
2. Enable debug mode in Settings → Developer (if needed)
3. Perform actions and verify events in console
4. Check AppsFlyer dashboard for real attribution data

## AppsFlyer Dashboard

### Accessing Your Dashboard

1. Go to [https://hq1.appsflyer.com](https://hq1.appsflyer.com)
2. Log in with your AppsFlyer account
3. Select your app (Nuvin / eunoia.anxietyapp)

### Key Sections

- **Dashboard Overview**: High-level metrics (installs, events, revenue)
- **Installs**: Attribution data by campaign/channel
- **In-App Events**: Custom events you've implemented
- **Cohort Analysis**: User retention and LTV
- **Raw Data**: Detailed event-level data

## Privacy & Compliance

### GDPR/Privacy Considerations

AppsFlyer is configured with privacy in mind:

- **No IDFA Collection by Default**: The code doesn't request IDFA (can be added if needed)
- **Respects App Tracking Transparency**: Works without ATT permission
- **No PII Collection**: Events don't contain personal information
- **GDPR Compliant**: AppsFlyer is GDPR compliant when configured correctly

### Privacy Policy Update

Ensure your privacy policy mentions:
- Attribution tracking via AppsFlyer
- Analytics for app improvement
- No sale of personal data
- User rights under GDPR/CCPA

## Advanced Features

### Deep Linking (Future Enhancement)

To support deep links from campaigns:

1. Add URL scheme to Info.plist
2. Implement deep link handling in AppDelegate
3. Parse attribution data in `onAppOpenAttribution` callback

See `AppsFlyerService.swift` lines 165-176 for the delegate methods.

### Conversion Tracking

The `onConversionDataSuccess` delegate method (lines 154-164) receives:
- Install attribution data
- Campaign information
- Media source
- Organic vs. Non-organic status

### Revenue Tracking

To track subscription revenue in AppsFlyer:

```swift
AppsFlyerService.shared.logEvent(
    AFEventPurchase,
    parameters: [
        AFEventParamRevenue: 9.99,
        AFEventParamCurrency: "USD",
        AFEventParamContentId: productId
    ]
)
```

## Troubleshooting

### Events Not Appearing in Dashboard

1. **Wait 1-2 hours**: Events can take time to appear
2. **Check debug logs**: Ensure events are being logged in console
3. **Verify Dev Key**: Check that Config.plist has correct key
4. **Check internet connection**: AppsFlyer needs network access

### Build Errors

If you see "No such module 'AppsFlyerLib'":
1. Clean build folder (Cmd + Shift + K)
2. Verify package is added in Project → Package Dependencies
3. Rebuild the project

### Configuration Errors

If you see "AppsFlyer Dev Key not found in Config.plist":
1. Verify Config.plist exists in project
2. Check that Config.plist contains `AppsFlyerDevKey` key
3. Ensure the key value is not "YOUR_APPSFLYER_DEV_KEY_HERE"

## File Reference

| File | Location | Purpose |
|------|----------|---------|
| AppsFlyerService.swift | anxietyapp/Services/ | Main AppsFlyer service |
| AppsFlyerEvents.swift | anxietyapp/Services/ | Event tracking examples |
| ConfigurationManager.swift | anxietyapp/Services/ | Configuration management |
| Config.plist | anxietyapp/ | API keys (gitignored) |
| Config-Template.plist | anxietyapp/ | Template for Config.plist |
| Info.plist | anxietyapp/ | App configuration |
| anxietyappApp.swift | anxietyapp/ | App initialization |

## Next Steps

1. **Add SDK via Xcode** (see Step 1 above)
2. **Build and test** the app
3. **Integrate events** in your Views and ViewModels using examples from `AppsFlyerEvents.swift`
4. **Monitor dashboard** for attribution and event data
5. **Set up campaigns** in AppsFlyer for marketing tracking

## Support

- **AppsFlyer Documentation**: [https://dev.appsflyer.com/hc/docs/ios-sdk](https://dev.appsflyer.com/hc/docs/ios-sdk)
- **AppsFlyer Support**: [https://support.appsflyer.com](https://support.appsflyer.com)
- **Code Reference**: See inline comments in `AppsFlyerService.swift` and `AppsFlyerEvents.swift`

---

**Last Updated**: 2025-10-20
**AppsFlyer SDK Version**: 6.14.0+
**iOS Deployment Target**: 16.6+
