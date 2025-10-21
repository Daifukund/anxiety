# 🔐 Configuration Setup Guide

## Overview

This app uses a secure configuration file to store API keys and secrets. This prevents sensitive data from being committed to version control.

## Quick Setup

### 1. Create Your Config File

Copy the template file:
```bash
cp anxietyapp/Config-Template.plist anxietyapp/Config.plist
```

### 2. Add Your API Keys

Open `anxietyapp/Config.plist` and replace the placeholder values:

```xml
<key>RevenueCatAPIKey</key>
<string>YOUR_ACTUAL_REVENUECAT_KEY</string>

<key>MixpanelToken</key>
<string>YOUR_ACTUAL_MIXPANEL_TOKEN</string>
```

### 3. Where to Find Your Keys

#### RevenueCat API Key
1. Go to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Navigate to: **Settings → API Keys**
3. Copy your **Public App-Specific API Key** (starts with `appl_`)

#### Mixpanel Token
1. Go to [Mixpanel Dashboard](https://mixpanel.com)
2. Navigate to: **Settings → Project Settings**
3. Copy your **Project Token**

## Important Security Notes

⚠️ **DO NOT commit `Config.plist` to git**
- This file is already in `.gitignore`
- Only commit `Config-Template.plist` (without real keys)

✅ **Safe to commit:**
- `Config-Template.plist` ✅
- `ConfigurationManager.swift` ✅
- `.gitignore` ✅

❌ **NEVER commit:**
- `Config.plist` ❌ (contains real API keys)

## For Team Members

When cloning this project:

1. Copy the template:
   ```bash
   cp anxietyapp/Config-Template.plist anxietyapp/Config.plist
   ```

2. Ask your team lead for the API keys

3. Update `Config.plist` with the real keys

4. Build and run the app

## Verification

The app will print configuration status in debug builds:
```
🔑 Configuration Status:
  - RevenueCat API Key: appl_FchwLGrn...
  - Mixpanel Token: 78a41fbf890a...
```

If you see an error about missing keys, make sure you've created `Config.plist` with valid values.

## Troubleshooting

### Error: "RevenueCat API Key not found in Config.plist"
- Make sure `Config.plist` exists in `anxietyapp/` folder
- Check that you've replaced `YOUR_REVENUECAT_API_KEY_HERE` with a real key
- Rebuild the project (Cmd+B)

### Error: "Config.plist not found"
- Run: `cp anxietyapp/Config-Template.plist anxietyapp/Config.plist`
- Add your API keys to the new file

## Production Deployment

For production builds, consider:
1. Using Xcode Build Configurations (Debug vs Release)
2. Environment-specific configuration files
3. CI/CD secrets management (GitHub Secrets, etc.)
