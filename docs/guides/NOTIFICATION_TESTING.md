# Push Notification Testing Guide

## Setup Complete! ✅

The following has been implemented:

### Files Created
1. **`Services/NotificationService.swift`** - Core notification manager
2. **Enhanced `Views/SettingsView.swift`** - Added quote notification settings

### Files Modified
1. **`anxietyappApp.swift`** - Initialized NotificationService
2. **`Services/UserDataService.swift`** - Cancels mood notification when user checks in

---

## How to Add NotificationService to Xcode Project

**IMPORTANT:** The `NotificationService.swift` file was created but needs to be added to your Xcode project:

1. Open `anxietyapp.xcodeproj` in Xcode
2. Right-click on the `Services` folder in the Project Navigator
3. Select "Add Files to anxietyapp..."
4. Navigate to and select `Services/NotificationService.swift`
5. Make sure "Copy items if needed" is **unchecked** (file is already in correct location)
6. Make sure your target is selected
7. Click "Add"

---

## How to Test Notifications

### 1. **Enable Notifications**
- Run the app in the simulator
- Go to Settings → Set Reminders
- Enable either "Daily Mood Check-in" or "Daily Quotes"
- Grant permission when prompted

### 2. **Test Mood Check-In Notification**
- Enable "Daily Mood Check-in"
- Set the time to **2 minutes from now**
- Wait for the notification to appear
- Tap the notification to open the app

### 3. **Test Quote Notifications**
- Enable "Daily Quotes"
- Select frequency (Once, Twice, or Three times daily)
- Set the first time to **2 minutes from now**
- Wait for the notification with a random quote
- Tap the notification to open the app

### 4. **Test Notification Cancellation**
- Enable "Daily Mood Check-in"
- Schedule it for later today
- Check in your mood manually in the app
- The notification should be cancelled automatically

### 5. **Simulator Testing Tips**
```bash
# In iOS Simulator, notifications will appear as banners
# You can also check scheduled notifications in the Debug console

# To see what notifications are scheduled, add this debug button
# to any view temporarily:
Button("Debug Notifications") {
    NotificationService.shared.listScheduledNotifications()
}
```

---

## Features Implemented

### Mood Check-In Reminder
- ✅ Daily reminder at user-selected time
- ✅ Friendly notification: "How are you feeling? 💙"
- ✅ Auto-cancels if user already checked in that day
- ✅ Configurable time via Settings

### Daily Quote Notifications
- ✅ 1-3 quotes per day (user selects frequency)
- ✅ Random motivational/calming quotes from existing Quote.swift
- ✅ Each time slot shows different quote category
- ✅ Fully configurable times via Settings
- ✅ Beautiful notification with quote + author

### Settings Integration
- ✅ Easy toggle switches for enable/disable
- ✅ Time pickers for each notification
- ✅ Frequency selector for quotes
- ✅ Permission handling with alerts
- ✅ Link to iOS Settings if permissions denied

### Smart Behavior
- ✅ Respects iOS "Do Not Disturb" automatically
- ✅ Shows notifications even when app is in foreground
- ✅ Cancels mood reminder when user checks in
- ✅ Reschedules automatically when settings change
- ✅ Persists preferences across app launches

---

## AppStorage Keys Used

The following keys store notification preferences:
- `moodCheckInEnabled` (Bool) - Default: true
- `moodCheckInTime` (String) - Default: "09:00"
- `quoteNotificationsEnabled` (Bool) - Default: false
- `quoteFrequency` (Int) - Default: 1 (1, 2, or 3)
- `quoteTime1` (String) - Default: "09:00"
- `quoteTime2` (String) - Default: "14:00"
- `quoteTime3` (String) - Default: "19:00"

---

## Troubleshooting

### Notifications not appearing?
1. Check if notifications are enabled in iOS Settings → Notifications → anxietyapp
2. Make sure the app has notification permission granted
3. Check the scheduled time is in the future
4. Run `NotificationService.shared.listScheduledNotifications()` in debug

### Permission denied?
- The app will show an alert with "Open Settings" button
- User can grant permission in iOS Settings

### Notifications appearing at wrong times?
- Check that the time picker values are correct
- Time is in the device's local timezone
- Notifications repeat daily at the specified time

---

## Next Steps (Optional Enhancements)

1. **Deep Linking**: Make notifications open specific screens
   - Mood notification → Mood check-in screen
   - Quote notification → Quotes/Affirmations view

2. **Notification Actions**: Add quick actions to notifications
   - "Check In Now" button on mood notification
   - "Save Quote" button on quote notification

3. **Onboarding Integration**: Request permission during onboarding

4. **Smart Scheduling**:
   - Don't send mood reminder if user already checked in
   - Vary quote categories based on time of day

5. **Badge Count**: Update app icon badge for unread notifications

---

## Code Architecture

```
NotificationService (Singleton)
├── Permission Management
│   ├── requestPermission()
│   ├── checkPermissionStatus()
│   └── openSettings()
├── Mood Check-In
│   ├── scheduleMoodCheckIn()
│   └── cancelMoodCheckIn()
├── Quote Notifications
│   ├── scheduleQuoteNotifications()
│   ├── cancelAllQuoteNotifications()
│   └── getQuoteForTimeSlot()
└── UNUserNotificationCenterDelegate
    ├── willPresent (show in foreground)
    └── didReceive (handle tap)
```

All notification logic is centralized in `NotificationService.swift` for easy maintenance and testing.
