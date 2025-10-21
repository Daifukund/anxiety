# Mixpanel Dependency Fix Required

## Issue
The Mixpanel Swift package is currently pinned to the `master` branch instead of a stable version tag. This can cause unexpected breaking changes.

## Current Configuration
```json
{
  "identity": "mixpanel-swift",
  "kind": "remoteSourceControl",
  "location": "https://github.com/mixpanel/mixpanel-swift.git",
  "state": {
    "branch": "master",
    "revision": "4088e46b2d76a70e227f790f5b683f8ff52951d0"
  }
}
```

## Required Fix (Must be done in Xcode)

### Option 1: Use Specific Version (Recommended)
1. Open `anxietyapp.xcodeproj` in Xcode
2. Go to **File → Packages → Resolve Package Versions**
3. Click on **Mixpanel** in the package list
4. Change from "Branch: master" to "Up to Next Major Version"
5. Set minimum version: `4.0.0`
6. Click **Done**

### Option 2: Keep Current Commit (Temporary)
If you need to ship quickly and don't want to risk breaking changes:
1. The current commit `4088e46b` appears stable
2. Leave as-is for this release
3. **BUT** plan to fix in version 1.2.1

### Why This Matters
- Using `master` branch means automatic updates
- Automatic updates can introduce breaking changes
- Could cause build failures in CI/CD
- Best practice is to use semantic versioning

## Recommended Version
Latest stable: **v4.2.8** (as of October 2025)

Pin to: `4.0.0` with "Up to Next Major Version" for stability while getting patch updates.

---

**Status:** ⚠️ Deferred to Xcode - Cannot be fixed via command line
**Priority:** Medium - Fix in next build session
