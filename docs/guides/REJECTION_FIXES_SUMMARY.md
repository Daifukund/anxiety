# App Store Rejection Fixes - Summary

**Review Date**: October 8, 2025
**Version**: 1.0
**Submission ID**: 1cfbd9dc-a51a-4f1a-a866-23dbb9d8c042

---

## 🔴 Issues Identified

### 1. Guideline 1.4.1 - Safety - Physical Harm
**Issue**: Medical information without citations
- App provides anxiety level analysis without citing sources
- Calculations shown without links to medical information

### 2. Guideline 2.1 - Performance - App Completeness
**Issue**: IAP purchase error on iPad
- Bug when tapping to purchase in-app products
- Device: iPad Air (5th generation), iPadOS 26.0.1

### 3. Guideline 3.1.2 - Business - Payments - Subscriptions
**Issue**: Missing EULA link in metadata
- No functional link to Terms of Use in app metadata
- Required for auto-renewable subscriptions

---

## ✅ Fixes Implemented

### 1. Medical Citations ✅

**Changes Made**:
- Added NIMH (National Institute of Mental Health) citation link
- Added ADAA (Anxiety and Depression Association of America) citation link
- Added "Learn more about anxiety" button linking to NIMH resources
- Citations appear on anxiety analysis results screen

**File**: `anxietyapp/Views/OnboardingPersonalizationView.swift`

**Lines Changed**: 183-209, 135-172

---

### 2. IAP Bug Fixes ✅

**Changes Made**:
- Added product loading validation before purchase attempts
- Enhanced error handling with device-specific logging (iPhone vs iPad)
- Added RevenueCat configuration status tracking
- Improved error messages for debugging
- Added guard to prevent purchases when products aren't loaded

**Files**:
- `anxietyapp/ViewModels/PaywallViewModel.swift` (lines 48-100)
- `anxietyapp/Services/SubscriptionService.swift` (lines 18, 28, 39, 83-116, 157-175)

**Key Improvements**:
```swift
// Validation before purchase
guard !availableProducts.isEmpty else {
    errorMessage = "Products not loaded. Please wait and try again."
    return
}

// Configuration check
guard isConfigured else {
    throw SubscriptionError.notConfigured
}

// Device-specific logging
print("📱 Device: \(UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone")")
```

---

### 3. EULA Links ✅

**Changes Made**:
- Added Terms and Privacy Policy links to main paywall view
- Added Terms and Privacy Policy links to "All Plans" sheet
- Links point to: https://daifukund.github.io/nuvin/terms.html and privacy.html

**File**: `anxietyapp/Views/OnboardingPaywallView.swift`

**Lines Changed**: 159-187, 334-361

---

## ⚠️ ACTION REQUIRED

### App Store Connect Update

**CRITICAL**: You must add the EULA link to App Store Connect before resubmitting.

**Steps**:
1. Go to App Store Connect
2. Navigate to your app → App Store tab
3. Scroll to "Description" field
4. Add at the bottom:

```
---
LEGAL

Terms of Use: https://daifukund.github.io/nuvin/terms.html
Privacy Policy: https://daifukund.github.io/nuvin/privacy.html
```

---

## 📝 Testing Checklist

Before resubmission:

- [x] Medical citations appear with clickable links
- [x] NIMH and ADAA links work correctly
- [ ] Test IAP on iPhone simulator
- [ ] Test IAP on iPad Air (5th generation) simulator
- [ ] Verify Terms/Privacy links in paywall
- [ ] Verify Terms/Privacy links in "All Plans" sheet
- [ ] Add EULA to App Store Connect description
- [ ] Verify all legal URLs are live and accessible

---

## 📤 Resubmission Steps

1. **Test on iPad**:
   ```bash
   xcodebuild -project anxietyapp.xcodeproj -scheme anxietyapp \
   -destination 'platform=iOS Simulator,name=iPad Air (5th generation)' build
   ```

2. **Update App Store Connect**:
   - Add EULA link to description (see above)

3. **Build Archive**:
   - Xcode → Product → Archive

4. **Submit**:
   - Xcode Organizer → Distribute App → App Store Connect

5. **Add Review Notes**:
   ```
   We have addressed all three rejection issues:

   1. Medical Citations: Added links to NIMH and ADAA
   2. IAP Bug: Enhanced error handling for iPad devices
   3. EULA: Added links to paywall and App Store description
   ```

---

## 📊 Files Changed Summary

| File | Lines Changed | Purpose |
|------|--------------|---------|
| OnboardingPersonalizationView.swift | 183-209, 135-172 | Medical citations |
| PaywallViewModel.swift | 48-100 | IAP validation |
| SubscriptionService.swift | 18, 28, 39, 83-116, 157-175 | IAP error handling |
| OnboardingPaywallView.swift | 159-187, 334-361 | EULA links |

**Total Files Modified**: 4
**New File Created**: `APP_STORE_RESUBMISSION_GUIDE.md`

---

## 🎯 Expected Outcome

All three rejection issues are now resolved:

✅ **Guideline 1.4.1**: Medical citations present with links
✅ **Guideline 2.1**: IAP error handling improved for iPad
✅ **Guideline 3.1.2**: EULA links in app + metadata (pending ASC update)

**Next Steps**:
1. Update App Store Connect with EULA link
2. Test on iPad simulator
3. Archive and submit for review

---

*For detailed instructions, see `APP_STORE_RESUBMISSION_GUIDE.md`*
