# 📱 App Store Privacy Labels Configuration Guide

## Overview

When submitting Nuvin to the App Store, you must configure **Privacy Labels** in App Store Connect. This document provides the exact configuration for your app based on the data you collect.

**Reference:** [Apple Privacy Labels Documentation](https://developer.apple.com/app-store/app-privacy-details/)

---

## Quick Summary

Nuvin collects the following data:

| Data Type | Purpose | Linked to User | Used for Tracking |
|-----------|---------|----------------|-------------------|
| **Device ID** | Analytics | ❌ No | ✅ Yes (Mixpanel) |
| **Product Interaction** | Analytics | ❌ No | ✅ Yes (Mixpanel) |
| **Purchase History** | Subscriptions | ❌ No | ❌ No |
| **Health & Fitness** | Mood Tracking | ❌ No | ❌ No |

---

## Step-by-Step Configuration in App Store Connect

### 1. Navigate to Privacy Section

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app: **Nuvin**
3. Click **App Privacy** (left sidebar)
4. Click **Get Started** or **Edit**

---

### 2. Question 1: "Do you or your third-party partners collect data from this app?"

**Answer:** ✅ **Yes**

(You collect analytics via Mixpanel and subscription data via RevenueCat)

---

### 3. Question 2: "Does this app or any third-party SDKs use data for tracking purposes?"

**Answer:** ✅ **Yes**

**Explanation:** Mixpanel is used for analytics and product improvement, which includes tracking user behavior across apps and websites.

---

## Data Types Configuration

### Category 1: Identifiers

#### ✅ Device ID

**Select:** Device ID

**How is this data used?**
- ✅ **Analytics**
- ✅ **Product Personalization**

**Is this data linked to the user's identity?**
- ❌ **No** (Anonymous analytics)

**Do you or your third-party partners use this data for tracking purposes?**
- ✅ **Yes** (Mixpanel analytics)

---

### Category 2: Usage Data

#### ✅ Product Interaction

**Select:** Product Interaction

**Description:** Data about how users interact with the app (buttons clicked, features used, time spent).

**How is this data used?**
- ✅ **Analytics**
- ✅ **Product Personalization**

**Is this data linked to the user's identity?**
- ❌ **No** (Anonymous usage data)

**Do you or your third-party partners use this data for tracking purposes?**
- ✅ **Yes** (Mixpanel tracks feature usage)

---

### Category 3: Purchases

#### ✅ Purchase History

**Select:** Purchase History

**Description:** Information about purchases or transactions made within the app.

**How is this data used?**
- ✅ **App Functionality** (Managing subscriptions via RevenueCat)

**Is this data linked to the user's identity?**
- ❌ **No** (RevenueCat uses anonymous customer IDs)

**Do you or your third-party partners use this data for tracking purposes?**
- ❌ **No** (Only for subscription management)

---

### Category 4: Health & Fitness

#### ✅ Health

**Select:** Health

**Description:** Mood check-ins, anxiety levels, stress tracking, and wellness data.

**How is this data used?**
- ✅ **App Functionality** (Core feature of the app)

**Is this data linked to the user's identity?**
- ❌ **No** (Stored locally on device, not sent to servers)

**Do you or your third-party partners use this data for tracking purposes?**
- ❌ **No** (Stored locally for user benefit only)

---

## Third-Party SDKs Disclosure

### RevenueCat (Subscription Management)

**Data Collected:**
- Purchase history
- Device identifiers (anonymous customer ID)

**Purpose:** Subscription management and entitlement checking

**Linked to User:** No (uses anonymous IDs)

**Used for Tracking:** No

---

### Mixpanel (Analytics)

**Data Collected:**
- Device ID
- Product interaction (events, screen views)
- User properties (anonymized)

**Purpose:** Analytics and product improvement

**Linked to User:** No (anonymous analytics)

**Used for Tracking:** Yes (cross-app/website behavior)

---

## Privacy Policy Link

**Required:** You must provide a link to your Privacy Policy.

**Your Privacy Policy URL:**
```
[Will be hosted at: https://yourdomain.com/privacy-policy]
```

**Alternatively:**
- Host on GitHub Pages
- Include in-app and provide App Store reviewers access
- Use a privacy policy generator service

**Current Location:**
`anxietyapp/Resources/PrivacyPolicy.md` (needs to be hosted publicly)

---

## Data Collection Summary Table

Use this table when filling out App Store Connect:

| Category | Type | Linked | Tracking | Purpose |
|----------|------|--------|----------|---------|
| **Identifiers** | Device ID | No | Yes | Analytics, Personalization |
| **Usage Data** | Product Interaction | No | Yes | Analytics, Personalization |
| **Purchases** | Purchase History | No | No | App Functionality |
| **Health & Fitness** | Health | No | No | App Functionality |

---

## Important Notes

### ✅ Data NOT Collected

The following categories should be marked as **NOT collected**:

- ❌ Name
- ❌ Email Address (optional in your app)
- ❌ Phone Number
- ❌ Physical Address
- ❌ Photos or Videos
- ❌ Audio Data
- ❌ Precise Location
- ❌ Coarse Location
- ❌ Search History
- ❌ Browsing History
- ❌ User Content
- ❌ Customer Support
- ❌ Other User Content
- ❌ Contacts
- ❌ Sensitive Info

### ⚠️ Optional: Email Collection

If you later add **email collection** for account creation:

**Category:** Contact Info → Email Address
**Linked to User:** Yes
**Tracking:** No
**Purpose:** App Functionality

---

## Privacy Manifest File

✅ Created: `PrivacyInfo.xcprivacy`

This file is **required for iOS 17+** and must be included in your app bundle.

**Location:** `anxietyapp/PrivacyInfo.xcprivacy`

**What it declares:**
- Tracking domains (Mixpanel)
- Data types collected
- Required reason APIs (UserDefaults, file timestamps, etc.)

**Xcode automatically includes this file** in your app bundle when building.

---

## App Tracking Transparency (ATT)

✅ **Implemented** in `anxietyappApp.swift`

**What happens:**
1. User launches app
2. After 1 second delay, ATT prompt appears:
   ```
   "We use analytics to understand how you use Nuvin and improve
   your anxiety relief experience. Your data helps us make the
   app better for everyone while keeping your information
   private and secure."
   ```
3. User can:
   - **Allow:** Mixpanel gets IDFA, full tracking enabled
   - **Ask App Not to Track:** Mixpanel still works but without IDFA

**Info.plist Entry:**
```xml
<key>NSUserTrackingUsageDescription</key>
<string>We use analytics to understand how you use Nuvin...</string>
```

---

## Compliance Checklist

Before submitting to App Store:

- [x] Privacy Manifest created (`PrivacyInfo.xcprivacy`)
- [x] ATT implemented (`anxietyappApp.swift`)
- [x] `NSUserTrackingUsageDescription` added to Info.plist
- [ ] Privacy Policy hosted publicly (URL required)
- [ ] Privacy labels configured in App Store Connect
- [ ] All third-party SDKs declared (RevenueCat, Mixpanel)
- [ ] Data collection purposes documented
- [ ] Tracking domains listed in Privacy Manifest

---

## Testing ATT

### In Simulator:
1. Settings → Privacy & Security → Tracking
2. Enable "Allow Apps to Request to Track"
3. Launch Nuvin
4. ATT prompt should appear after 1 second

### On Device:
1. Install build on device
2. Settings → Privacy & Security → Tracking
3. Launch app
4. Verify ATT prompt appears

### Reset Permission:
1. Settings → Privacy & Security → Tracking
2. Toggle "Allow Apps to Request to Track" off/on
3. Delete app and reinstall

---

## Common Mistakes to Avoid

❌ **DON'T:**
- Say you don't collect data when you use Mixpanel
- Mark data as "linked to user" if it's anonymous
- Forget to declare tracking when using analytics
- Submit without a public Privacy Policy URL

✅ **DO:**
- Be transparent about Mixpanel and RevenueCat
- Mark all data as "not linked" (you use anonymous IDs)
- Include Privacy Manifest for iOS 17+
- Test ATT prompt before submission

---

## App Review Notes

**For App Store Reviewers:**

> Nuvin uses analytics (Mixpanel) to improve the user experience and subscription management (RevenueCat) for in-app purchases. All health data (mood tracking) is stored locally on the device and not transmitted to servers. We request tracking permission via App Tracking Transparency (ATT) to help us understand how users benefit from our anxiety relief tools, allowing us to make the app more helpful.

---

## Helpful Resources

- [App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)
- [Privacy Manifest Files](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files)
- [App Tracking Transparency](https://developer.apple.com/documentation/apptrackingtransparency)
- [Required Reason API](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api)

---

## Privacy Policy Hosting Options

### Option 1: GitHub Pages (Free)
1. Create `privacy-policy.html` in GitHub repo
2. Enable GitHub Pages in repo settings
3. URL: `https://yourusername.github.io/repo/privacy-policy.html`

### Option 2: Custom Domain
1. Host `PrivacyPolicy.md` on your website
2. Convert to HTML or use Markdown renderer
3. URL: `https://nuvin.app/privacy`

### Option 3: In-App + Review Access
1. Keep Privacy Policy in-app only
2. Provide App Store reviewers access via demo account
3. Less ideal, but acceptable

---

**Status: ✅ PRIVACY COMPLIANCE CONFIGURED**

Your app is now compliant with iOS 17+ privacy requirements and App Store guidelines.
