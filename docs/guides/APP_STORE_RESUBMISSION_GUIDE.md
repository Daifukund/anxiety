# App Store Resubmission Guide

This guide addresses the rejection issues from the October 8, 2025 review and provides step-by-step instructions for resubmission.

## Issues Fixed in Code

### ✅ 1. Medical Information Citations (Guideline 1.4.1)

**Problem**: The anxiety level analysis lacked medical citations.

**Fixed**:
- Added clickable links to NIMH (National Institute of Mental Health) and ADAA (Anxiety and Depression Association of America)
- Citations appear in `OnboardingPersonalizationView.swift`
- Users can tap "Learn more about anxiety" to access NIMH resources
- Sources are clearly labeled at the bottom of the anxiety analysis card

**Files Changed**:
- `anxietyapp/Views/OnboardingPersonalizationView.swift`

---

### ✅ 2. In-App Purchase Bug on iPad (Guideline 2.1)

**Problem**: Error when tapping to purchase on iPad Air (5th generation).

**Fixed**:
- Added product loading validation before purchase attempts
- Improved error handling with device-specific logging
- Added RevenueCat configuration check
- Enhanced error messages for better debugging
- Added guards to prevent purchases when products aren't loaded

**Files Changed**:
- `anxietyapp/ViewModels/PaywallViewModel.swift`
- `anxietyapp/Services/SubscriptionService.swift`

**Testing**:
Before resubmission, test on iPad simulator:
```bash
# Run on iPad Air (5th generation) simulator
xcodebuild -project anxietyapp.xcodeproj -scheme anxietyapp -destination 'platform=iOS Simulator,name=iPad Air (5th generation)' test
```

---

### ✅ 3. Terms of Use (EULA) Link (Guideline 3.1.2)

**Problem**: Missing EULA link in app metadata and paywall view.

**Fixed in Code**:
- Added Terms and Privacy Policy links to main paywall view
- Added Terms and Privacy Policy links to "All Plans" sheet
- Links point to: https://daifukund.github.io/nuvin/terms.html

**Files Changed**:
- `anxietyapp/Views/OnboardingPaywallView.swift`

---

## Required App Store Connect Changes

### 📋 IMPORTANT: Add EULA Link to App Description

You MUST add the following text to your App Store Connect app description:

#### Option 1: Add to App Description (RECOMMENDED)

1. Log into App Store Connect
2. Go to your app → App Store tab
3. Scroll to "Description" field
4. Add this text at the bottom of your description:

```
---
LEGAL

Terms of Use: https://daifukund.github.io/nuvin/terms.html
Privacy Policy: https://daifukund.github.io/nuvin/privacy.html
```

#### Option 2: Add Custom EULA (Alternative)

1. Log into App Store Connect
2. Go to your app → App Store tab
3. Scroll to "End User License Agreement" section
4. Select "Custom EULA"
5. Paste the content from `anxietyapp/Resources/TermsOfService.md`
6. Include the link: https://daifukund.github.io/nuvin/terms.html

---

## Testing Checklist Before Resubmission

### Medical Citations
- [ ] Open app and complete onboarding
- [ ] Verify anxiety analysis shows clickable citation links
- [ ] Tap "Learn more about anxiety" - should open NIMH website
- [ ] Verify "Sources: NIMH • ADAA" appears with clickable links

### In-App Purchases
- [ ] Test on iPhone simulator - purchase flow should work
- [ ] Test on iPad Air (5th generation) simulator - purchase flow should work
- [ ] Verify error message appears if products don't load
- [ ] Test with StoreKit Configuration file
- [ ] Verify RevenueCat is properly configured with valid API key

### Terms of Use Links
- [ ] Verify Terms and Privacy links appear at bottom of main paywall
- [ ] Verify Terms and Privacy links appear in "All Plans" sheet
- [ ] Tap each link - should open correct webpage
- [ ] Verify links are added to App Store Connect description

---

## Resubmission Notes

### What to Include in "Notes to Reviewer"

```
Thank you for your review. We have addressed all three issues:

1. MEDICAL CITATIONS (Guideline 1.4.1):
   - Added medical citations with links to NIMH and ADAA
   - Citations appear in the anxiety analysis screen
   - Users can tap links to access credible medical sources

2. IAP BUG FIX (Guideline 2.1):
   - Enhanced error handling for iPad devices
   - Added product loading validation
   - Improved RevenueCat configuration checks
   - Purchase flow now validates products are loaded before purchase attempts

3. EULA LINK (Guideline 3.1.2):
   - Added Terms and Privacy links to all paywall views
   - Added EULA link to App Store Connect description
   - Links are functional and point to: https://daifukund.github.io/nuvin/terms.html

All changes have been tested on both iPhone and iPad devices.

Test Account (if needed):
Email: [provide if you have test account]
Password: [provide if you have test account]
```

---

## Configuration Verification

Before building for submission, verify:

### 1. RevenueCat Configuration
- [ ] `Config.plist` has valid RevenueCat API key
- [ ] API key is not empty
- [ ] Entitlements are properly set up in RevenueCat dashboard

### 2. StoreKit Configuration
- [ ] `Configuration.storekit` has all 3 product IDs:
  - `com.yourapp.premium.monthly`
  - `com.yourapp.premium.annual`
  - `com.yourapp.premium.lifetime`
- [ ] Products match RevenueCat product IDs exactly

### 3. Legal Documents
- [ ] https://daifukund.github.io/nuvin/terms.html is live and accessible
- [ ] https://daifukund.github.io/nuvin/privacy.html is live and accessible
- [ ] Both URLs open in browser without errors

---

## Build and Submit

```bash
# 1. Clean build folder
rm -rf ~/Library/Developer/Xcode/DerivedData

# 2. Archive for App Store
# Use Xcode: Product → Archive

# 3. Upload to App Store Connect
# Use Xcode Organizer: Distribute App → App Store Connect

# 4. Submit for Review
# Go to App Store Connect → TestFlight → Submit to App Review
```

---

## Expected Review Timeline

- TestFlight processing: 15-30 minutes
- Review queue: 24-48 hours
- Review duration: 24-48 hours

**Total estimated time**: 2-4 business days

---

## Contact Support (If Needed)

If the app is rejected again:

1. **Request Phone Call**: In App Store Connect, you can request a phone call from App Review
2. **App Review Appeal**: If you believe the rejection is incorrect, you can appeal
3. **Developer Forums**: Post on Apple Developer Forums for community help

---

## Summary of Changes

| Issue | Guideline | Status | Files Changed |
|-------|-----------|--------|---------------|
| Medical Citations | 1.4.1 | ✅ Fixed | OnboardingPersonalizationView.swift |
| IAP Bug (iPad) | 2.1 | ✅ Fixed | PaywallViewModel.swift, SubscriptionService.swift |
| EULA Link | 3.1.2 | ✅ Fixed (Code) + ⚠️ Need ASC update | OnboardingPaywallView.swift + App Store Connect |

**Action Required**: Update App Store Connect description with Terms of Use link before resubmission.
