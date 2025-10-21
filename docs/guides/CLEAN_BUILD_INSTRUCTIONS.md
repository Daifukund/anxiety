# 🧹 Clean Build Instructions

## You're seeing stale warnings - here's how to fix:

### Option 1: Clean Build Folder (Recommended)
1. In Xcode, press **Cmd + Shift + K** (or Product → Clean Build Folder)
2. Wait for it to finish cleaning
3. Press **Cmd + B** to build fresh

### Option 2: Quit and Reopen Xcode
1. Quit Xcode completely (Cmd + Q)
2. Reopen: `open anxietyapp.xcodeproj`
3. Build (Cmd + B)

### Option 3: Clean from Terminal
```bash
cd /Users/nathandouziech/Desktop/anxietyapp
rm -rf ~/Library/Developer/Xcode/DerivedData/anxietyapp-*
```
Then build in Xcode.

---

## What You Should See After Clean Build:

### ✅ In Build Log (Cmd + 9):
```
Build target anxietyapp
  PhaseScriptExecution Validate\ Config.plist
    🔍 Validating Config.plist...
    ✅ Config.plist exists
    ✅ Config.plist is valid plist format
    ✅ RevenueCat API Key is configured
    ✅ Mixpanel Token is configured
    ✅ All configuration validations passed!
  CompileSwiftSources
  ... (rest of build)

** BUILD SUCCEEDED **
```

### ❌ These warnings should be GONE:
- ~~"Run script build phase 'Validate Config.plist' will be run during every build"~~
- ~~"User supplied UIDeviceFamily key in the Info.plist will be overwritten"~~

---

## 🎯 If Warnings Persist After Clean Build:

The script phase warning is actually **informational** in newer Xcode versions. If it still shows up but build succeeds, you can safely ignore it. The important part is:

✅ Build succeeds
✅ Script runs (you see the green checkmarks)
✅ Your code compiles

---

## Quick Test:

After clean build, verify the script actually ran:
```bash
# Look for the validation output in your most recent build
# You should see the green checkmarks ✅
```
