# 🔍 Build Script Diagnostic Checklist

## Current Status

### ✅ What's Working:
- Script file exists: `scripts/validate-config.sh` ✅
- Script is executable (correct permissions) ✅
- Script works when run manually ✅
- Config.plist exists with valid API keys ✅

### ❌ What's NOT Working:
- **Build script is NOT in Xcode project yet** ❌
- This means it won't run automatically when you build

---

## 🎯 The Issue

When I checked your Xcode project file, the build script phase contains only the default placeholder:
```
# Type a script or drag a script file from your workspace to insert its path.
```

This means **you haven't completed the manual Xcode setup step yet**.

---

## ✅ How to Fix (Simple Steps)

### Open Xcode and Follow These Steps:

**1. Open the project:**
```bash
open anxietyapp.xcodeproj
```

**2. Navigate to Build Phases:**
- Click **anxietyapp** (blue icon) in left sidebar
- Click **anxietyapp** under TARGETS
- Click **Build Phases** tab at the top

**3. Add the script:**
- Click **+** button at top-left
- Select **"New Run Script Phase"**
- A new "Run Script" phase appears at the bottom

**4. Configure it:**
- **Drag it to the TOP** (above everything)
- Double-click "Run Script" and rename to **"Validate Config.plist"**
- Click the ▶ triangle to expand it
- In the big text box, **DELETE** the default text
- **PASTE** this exactly:
  ```bash
  "${SRCROOT}/scripts/validate-config.sh"
  ```

**5. Save and test:**
- Press **Cmd + B** to build
- Check the build log (Cmd + 9 → latest build)
- Look for green checkmarks ✅

---

## 🧪 How to Verify It's Working

### After adding to Xcode, run this test:

1. **Build the app** (Cmd + B)

2. **Open Report Navigator:**
   - Press **Cmd + 9**
   - Click on the latest build (top of the list)

3. **Look for "Validate Config.plist":**
   - You should see it in the build phases list
   - Click the disclosure triangle to expand it

4. **Check for this output:**
   ```
   🔍 Validating Config.plist...
   ✅ Config.plist exists
   ✅ Config.plist is valid plist format
   ✅ RevenueCat API Key is configured
   ✅ Mixpanel Token is configured
   ✅ All configuration validations passed!
   ```

**If you see the green checkmarks, IT'S WORKING!** ✅

---

## 📸 What You Should See (Text Description)

### In Build Phases Tab:
```
▼ Validate Config.plist          ← Should be at the TOP
  Shell: /bin/sh
  [Script text box should contain: "${SRCROOT}/scripts/validate-config.sh"]
  ☐ Based on dependency analysis   ← Should be UNCHECKED
  ☐ For install builds only        ← Should be UNCHECKED

▼ Dependencies

▼ Compile Sources (XX items)

... (rest of phases)
```

### In Build Log (Cmd + 9):
```
Build target anxietyapp
  ▸ Running script 'Validate Config.plist'
    🔍 Validating Config.plist...
    ✅ Config.plist exists
    ✅ Config.plist is valid plist format
    ✅ RevenueCat API Key is configured
    ✅ Mixpanel Token is configured
    ✅ All configuration validations passed!
  ▸ Compile Swift source files
  ... (rest of build)
```

---

## 🧪 Test It Catches Errors (Optional)

Want to verify the script actually prevents bad builds?

### Test 1: Rename Config.plist
```bash
cd anxietyapp
mv Config.plist Config.plist.backup
```

Now build in Xcode (Cmd + B). **It should FAIL** with:
```
❌ ERROR: Config.plist not found
```

Restore it:
```bash
mv Config.plist.backup Config.plist
```

Build again - should succeed! ✅

---

## ❓ Still Not Working? Common Issues:

### Issue 1: "Permission denied"
**Fix:**
```bash
chmod +x scripts/validate-config.sh
```

### Issue 2: Don't see the output in build log
**Fix:**
1. Press Cmd + 9 (Report Navigator)
2. Click latest build
3. Expand "Validate Config.plist" section
4. Output should be there

### Issue 3: Script phase exists but doesn't run
**Fix:**
- Make sure "Based on dependency analysis" is **UNCHECKED**
- Make sure the phase is at the **TOP** of the list
- Clean build folder (Cmd + Shift + K) and rebuild

### Issue 4: "No such file or directory"
**Verify script location:**
```bash
ls -la scripts/validate-config.sh
```
Should show: `-rwxr-xr-x ... validate-config.sh`

---

## 🎬 Video-Style Step by Step

Can't find the right buttons? Follow this:

1. **Click** the blue "anxietyapp" icon in the left sidebar
2. **See** two sections: PROJECT and TARGETS
3. **Click** "anxietyapp" under TARGETS (the one with your app icon)
4. **See** tabs at the top: General, Signing & Capabilities, ... Build Phases
5. **Click** "Build Phases" tab
6. **See** a list of build phases with disclosure triangles
7. **Click** the small **+** button at the very top-left of that list area
8. **Click** "New Run Script Phase" from the dropdown
9. **See** a new "Run Script" phase appear at the bottom of the list
10. **Click and drag** the "Run Script" bar up to the very top
11. **Double-click** the text "Run Script" to rename it
12. **Type** "Validate Config.plist" and press Enter
13. **Click** the ▶ triangle next to "Validate Config.plist"
14. **See** a large text box (might have placeholder text)
15. **Select all** text in that box (Cmd + A)
16. **Paste** this: `"${SRCROOT}/scripts/validate-config.sh"`
17. **Click** somewhere else to save
18. **Press** Cmd + B to build
19. **Press** Cmd + 9 to see build log
20. **See** green checkmarks ✅

---

## ✅ Final Verification Command

Run this to confirm everything is ready:

```bash
# Test the script works
SRCROOT="$(pwd)" ./scripts/validate-config.sh

# You should see:
# ✅ Config.plist exists
# ✅ Config.plist is valid plist format
# ✅ RevenueCat API Key is configured
# ✅ Mixpanel Token is configured
# ✅ All configuration validations passed!
```

**If the manual test works**, then you just need to add it to Xcode following the steps above.

---

## 🆘 Need More Help?

If you're still stuck, take a screenshot of:
1. Your Build Phases tab in Xcode
2. Your build log after pressing Cmd + B

And let me know what you see!
