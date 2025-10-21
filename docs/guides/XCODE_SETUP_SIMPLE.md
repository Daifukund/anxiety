# 🎯 Super Simple: Add Build Script to Xcode

## Current Situation

✅ **The script works!** I tested it and it's perfect.
❌ **But it's not in Xcode yet**, so it won't run automatically when you build.

**This is a 2-minute manual task you need to do once.**

---

## 📋 Exact Steps (Copy & Paste Friendly)

### Step 1: Open Xcode
```bash
open anxietyapp.xcodeproj
```
Wait for Xcode to fully load.

---

### Step 2: Click These Things in Order

**Click #1:** In the left sidebar, click **anxietyapp** (the blue project icon at the very top)

**Click #2:** In the main area, under "TARGETS", click **anxietyapp** (with your app icon)

**Click #3:** At the top, click the **Build Phases** tab

You should now see a list like:
- Dependencies
- Compile Sources (XX items)
- Link Binary With Libraries
- etc.

---

### Step 3: Add the Script Phase

**Click #4:** Click the **+** button at the top-left corner

**Click #5:** In the dropdown, click **"New Run Script Phase"**

You'll see a new section appear at the bottom called **"Run Script"**

---

### Step 4: Move It to the Top

**Click and hold** on the "Run Script" title bar, then **drag it ALL the way to the TOP** (above "Dependencies", above everything).

---

### Step 5: Name It

**Double-click** on the text "Run Script" and change it to:
```
Validate Config.plist
```
Press Enter.

---

### Step 6: Add the Script Code

**Click** the small triangle (▶) next to "Validate Config.plist" to expand it.

You'll see a big text box. It probably says:
```
# Type a script or drag a script file from your workspace to insert its path.
```

**Select ALL that text** (Cmd + A) and **delete it**.

Then **paste this EXACTLY:**
```bash
"${SRCROOT}/scripts/validate-config.sh"
```

---

### Step 7: Make Sure These Boxes Are UNCHECKED

Below the script box, look for checkboxes:

- ☐ "Based on dependency analysis" → **MUST BE UNCHECKED** ❌
- ☐ "For install builds only" → **MUST BE UNCHECKED** ❌

---

### Step 8: Test It!

**Press Cmd + B** (or click Product → Build)

---

### Step 9: Check the Build Log

**Press Cmd + 9** (or click View → Navigators → Reports)

**Click** on the latest build (top of the list)

**Look for** a section called "Validate Config.plist"

**Click** the triangle to expand it

You should see:
```
🔍 Validating Config.plist...
✅ Config.plist exists
✅ Config.plist is valid plist format
✅ RevenueCat API Key is configured
✅ Mixpanel Token is configured

✅ All configuration validations passed!
```

---

## ✅ Success Criteria

**You know it's working when:**
1. Build succeeds (no errors)
2. Build log shows green checkmarks ✅
3. "Validate Config.plist" appears in build phases (at the top)

---

## ❌ If You Don't See the Checkmarks

### Problem 1: Don't see "Validate Config.plist" in build log
**Solution:** You haven't added it to Xcode yet. Go back to Step 2.

### Problem 2: See the phase but no output
**Solution:**
- Make sure the script box contains: `"${SRCROOT}/scripts/validate-config.sh"`
- Make sure "Based on dependency analysis" is **UNCHECKED**
- Clean build (Cmd + Shift + K) and build again

### Problem 3: Build fails with "Permission denied"
**Solution:** Run this in Terminal:
```bash
chmod +x scripts/validate-config.sh
```

---

## 🎬 What Exactly Should You See?

### In Build Phases tab:
```
Your build phases list should look like this:

1. Validate Config.plist     ← This is YOUR NEW ONE (at the top!)
2. Dependencies
3. Compile Sources
4. Link Binary With Libraries
... etc
```

### When you expand "Validate Config.plist":
```
▼ Validate Config.plist
  Shell: /bin/sh

  [Text box containing:]
  "${SRCROOT}/scripts/validate-config.sh"

  ☐ Based on dependency analysis
  ☐ For install builds only

  Input Files:
  [empty]

  Output Files:
  [empty]
```

---

## 🆘 Still Stuck?

If you're not sure if you did it right, check your Xcode project file:

```bash
grep -A 3 "shellScript" anxietyapp.xcodeproj/project.pbxproj
```

**You should see:**
```
shellScript = "\"${SRCROOT}/scripts/validate-config.sh\"\n";
```

**If you see:**
```
shellScript = "# Type a script or drag a script file...
```
Then you haven't pasted the script into Xcode yet. Go back to Step 6.

---

## ✅ Quick Test

After you've added it to Xcode, test that it works:

```bash
# This test should PASS
SRCROOT="$(pwd)" ./scripts/validate-config.sh
```

**You should see green checkmarks.** If this works manually but not in Xcode, then the Xcode setup isn't complete yet.

---

## 🎯 Bottom Line

**The script is ready and works perfectly.**
**You just need to add it to Xcode so it runs automatically.**
**Follow Steps 1-9 above.**
**Takes 2 minutes.**
**You only do this once.**

---

**Need help?** Check `DIAGNOSTIC_CHECKLIST.md` for detailed troubleshooting.
