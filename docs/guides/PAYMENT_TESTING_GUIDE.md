# Payment Testing Guide - Nuvin. App

## ✅ What's Been Implemented

1. **RevenueCat SDK** - Integrated and configured
2. **Subscription Models** - Monthly ($7.99), Annual ($49.99), Lifetime ($99.99)
3. **Paywall UI** - Connected to real purchases
4. **Subscription Gating** - App access blocked without subscription
5. **StoreKit Configuration** - For local testing
6. **Debug Tools** - Bypass paywall during development

---

## 🔧 Setup Steps (DO THESE FIRST)

### 1. Get Your RevenueCat API Key

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Select your project (or create new one)
3. Go to **API keys** section
4. Copy your **iOS API Key**
5. Open `anxietyappApp.swift` in Xcode
6. Replace `YOUR_REVENUECAT_API_KEY` with your actual key:

```swift
let apiKey = "your_actual_key_here"
```

### 2. Set Up Products in App Store Connect

**IMPORTANT:** Product IDs must match exactly:

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to your app → **Features** → **In-App Purchases**
3. Create these 3 products:

#### Product 1: Monthly Subscription
- Type: **Auto-Renewable Subscription**
- Reference Name: **Monthly Subscription**
- Product ID: **`eunoia.anxietyapp.monthly`** (must match exactly!)
- Subscription Group: Create new group "Nuvin. Subscriptions"
- Price: **$7.99 USD**

#### Product 2: Annual Subscription
- Type: **Auto-Renewable Subscription**
- Reference Name: **Annual Subscription**
- Product ID: **`eunoia.anxietyapp.annual`**
- Subscription Group: Same group as Monthly
- Price: **$49.99 USD**

#### Product 3: Lifetime
- Type: **Non-Consumable**
- Reference Name: **Lifetime Access**
- Product ID: **`eunoia.anxietyapp.lifetime`**
- Price: **$99.99 USD**

### 3. Upload In-App Purchase Key to RevenueCat (CRITICAL for StoreKit 2)

**⚠️ Required for RevenueCat SDK 5.x with StoreKit 2**

#### Step 1: Generate In-App Purchase Key in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **Users and Access** (in top navigation)
3. Select **Integrations** tab
4. Scroll to **In-App Purchase** section
5. Click **Generate In-App Purchase Key** (or use existing one)
6. Give it a name (e.g., "RevenueCat IAP Key")
7. Click **Generate**
8. **⚠️ IMPORTANT:** Download the `.p8` key file immediately (you can only download it once!)
9. Copy the **Key ID** (you'll need this)
10. Note your **Issuer ID** (found at top of Integrations page)

#### Step 2: Upload Key to RevenueCat Dashboard

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Select your project
3. Go to **Project Settings** → **Apple App Store**
4. Scroll to **In-App Purchase Key Configuration** section
5. Upload your `.p8` key file
6. Enter the **Key ID** from Step 1
7. Enter the **Issuer ID** from Step 1
8. Click **Save**

✅ **This enables StoreKit 2 features including:**
- Faster receipt validation
- Real-time subscription status updates
- Better handling of refunds and subscription changes

### 4. Enable App Store Server Notifications (Recommended Best Practice)

**Why:** Apple will automatically notify RevenueCat about subscription changes (renewals, cancellations, refunds) in real-time.

#### Step 1: Get Your RevenueCat Notification URL

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Select your project
3. Go to **Project Settings** → **Notifications**
4. Find **Apple App Store Server Notifications**
5. Copy the **Server URL** (looks like: `https://api.revenuecat.com/v1/webhooks/apple/...`)

#### Step 2: Configure in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to **App Information** (under General section)
4. Scroll to **App Store Server Notifications** section
5. Click **+ Add Server URL**
6. Paste the RevenueCat URL from Step 1
7. Select **Version 2** (recommended)
8. Click **Save**

✅ **Benefits:**
- Real-time subscription status updates
- Automatic handling of renewals, cancellations, and refunds
- No polling required - Apple pushes updates directly
- Better customer experience with instant entitlement changes

### 5. Configure RevenueCat Products & Entitlements

1. In RevenueCat Dashboard, go to **Project Settings**
2. Add your **App Store Connect** credentials (if not already done)
3. Go to **Products** section
4. Import the 3 products from App Store Connect
5. Go to **Entitlements** section
6. Create an entitlement called **"premium"**
7. Attach all 3 products to this entitlement

### 6. Enable StoreKit Testing in Xcode

1. Open `anxietyapp.xcodeproj` in Xcode
2. Click on the scheme dropdown → **Edit Scheme**
3. Select **Run** → **Options** tab
4. Under **StoreKit Configuration**, select **Configuration.storekit**
5. Click **Close**

---

## 🧪 How to Test (3 Methods)

### Method 1: Debug Bypass (Fastest - Skip Payment Entirely)

**Best for:** Testing app features without dealing with payments

1. Build and run the app
2. Complete onboarding
3. When paywall appears, tap the **orange dollar button** (bottom right)
4. Button turns green ✅ = paywall bypassed
5. You now have full access to the app!

**Toggle anytime:**
- Orange dollar icon 💰 = Paywall active (must pay)
- Green checkmark ✅ = Paywall bypassed (free access)

---

### Method 2: StoreKit Testing (Recommended - Test Real Flow)

**Best for:** Testing the actual purchase flow without spending money

1. Make sure StoreKit Configuration is enabled (Step 4 above)
2. Build and run app in **Simulator or Real Device**
3. Complete onboarding
4. Select a subscription plan on paywall
5. Tap **"Start Now"**
6. You'll see a **fake purchase dialog** (no real money!)
7. Tap **Subscribe** → purchase completes instantly
8. App unlocks! 🎉

**Testing Restore Purchases:**
1. Reset the app (tap red reset button in bottom right)
2. Complete onboarding again
3. On paywall, tap **"Restore Purchase"**
4. Previous "purchase" is restored

**Testing Different Plans:**
- Select different plans and test each one
- All transactions are simulated (fake)
- No Apple ID required
- No real money charged

---

### Method 3: Sandbox Testing (Most Realistic)

**Best for:** Testing exactly like production before release

1. Create a **Sandbox Tester Account**:
   - Go to [App Store Connect](https://appstoreconnect.apple.com)
   - Users and Access → Sandbox Testers → Create New
   - Use a fake email (doesn't need to exist)

2. **Sign out** of your real Apple ID on device:
   - Settings → App Store → Sign Out

3. Build and run the app

4. When prompted to sign in, use your **Sandbox Tester** credentials

5. Complete purchase - it's free but behaves exactly like production!

**Note:** Only works on **real devices**, not simulator.

---

## 🐛 Debug Tools Available

### Red Reset Button (bottom right)
- Resets onboarding
- Clears all user data
- Returns to welcome screen

### Orange/Green Dollar Button (bottom right)
- **Orange 💰** = Paywall is active (must subscribe)
- **Green ✅** = Paywall bypassed (free access for testing)
- Tap to toggle on/off

**⚠️ These buttons only appear in DEBUG builds (not production)**

---

## 📱 Testing Checklist

Use this to make sure everything works:

### Basic Flow
- [ ] App loads without crashing
- [ ] Complete onboarding successfully
- [ ] Paywall appears after onboarding
- [ ] Can select different plans (Monthly/Annual/Lifetime)
- [ ] Selected plan highlights correctly

### Purchase Testing (Method 2 or 3)
- [ ] Tap "Start Now" → loading spinner appears
- [ ] Purchase dialog appears
- [ ] Complete purchase → app unlocks
- [ ] Can access all app features
- [ ] Close and reopen app → still subscribed

### Restore Testing
- [ ] Reset app with debug button
- [ ] Complete onboarding
- [ ] Tap "Restore Purchase"
- [ ] Previous purchase restored
- [ ] App unlocks without new purchase

### Error Handling
- [ ] Cancel purchase → error message doesn't show (or shows "cancelled")
- [ ] No internet → shows appropriate error
- [ ] Invalid product → shows error

### Debug Tools
- [ ] Red button resets onboarding ✅
- [ ] Orange/Green button bypasses paywall ✅
- [ ] Both buttons only in DEBUG mode ✅

---

## 🚨 Common Issues & Solutions

### "Product not found" error
**Fix:** Make sure:
1. Product IDs in App Store Connect match exactly: `eunoia.anxietyapp.monthly`, `eunoia.anxietyapp.annual`, `eunoia.anxietyapp.lifetime`
2. Products are imported in RevenueCat dashboard
3. Products attached to "premium" entitlement in RevenueCat

### "Unable to load products"
**Fix:**
1. Check RevenueCat API key is correct in `anxietyappApp.swift`
2. Check internet connection
3. Wait 1-2 minutes (first load can be slow)

### Purchases not working in Simulator
**Fix:**
- Make sure StoreKit Configuration is enabled (Scheme → Options)
- If still not working, use Debug Bypass button instead

### Restore not finding purchases
**Fix:**
- This is normal if using StoreKit testing - transactions are session-based
- For real testing, use Sandbox Testing (Method 3)

### App crashes on launch
**Fix:**
1. Check RevenueCat SDK is installed correctly
2. Check API key is not empty string
3. Clean build folder: **Product → Clean Build Folder**

---

## 📦 Before Submitting to App Store

**IMPORTANT:** Complete these steps:

1. [ ] Remove or comment out debug bypass button code
2. [ ] Test with real Sandbox account (Method 3)
3. [ ] Test all 3 subscription options
4. [ ] Test restore purchases
5. [ ] Test app behavior when subscription expires
6. [ ] Add privacy policy and terms of service links
7. [ ] Configure App Store listing with subscription info

---

## 🎯 Quick Start (TL;DR)

**Just want to test the app quickly?**

1. Add RevenueCat API key to `anxietyappApp.swift`
2. Build and run
3. Complete onboarding
4. Tap **orange dollar button** (bottom right) → turns green
5. App unlocks! ✅

**Want to test real purchases?**

1. Complete "Setup Steps" section above
2. Enable StoreKit Configuration in Xcode
3. Build and run
4. Buy subscription (it's fake - no real money)

---

## 📞 Need Help?

- **RevenueCat Docs:** https://www.revenuecat.com/docs
- **StoreKit Testing:** https://developer.apple.com/documentation/storekit/in-app_purchase/testing_in-app_purchases_with_sandbox
- **App Store Connect:** https://developer.apple.com/support/app-store-connect/

---

**Happy Testing! 🎉**
