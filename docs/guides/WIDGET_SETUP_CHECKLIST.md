# SOS Widget Setup - Quick Checklist

Quick reference for setting up the SOS widgets in Xcode.

## ☑️ Pre-Setup Checklist

- [ ] All widget files exist in `SOSWidget/` directory
- [ ] `AppGroup.swift` exists in `anxietyapp/Shared/`
- [ ] `NavigationManager.swift` exists in `anxietyapp/Services/`
- [ ] `Info.plist` has URL scheme `nuvin`
- [ ] Xcode project is open

---

## 🎯 Setup Steps (15-20 minutes)

### 1. Create Widget Extension Target
- [ ] File → New → Target
- [ ] Select "Widget Extension"
- [ ] Name: `SOSWidget`
- [ ] Uncheck "Include Configuration Intent"
- [ ] Click Finish
- [ ] Click "Activate" when prompted
- [ ] Delete template files Xcode created

### 2. Add Files to Widget Target
- [ ] Drag `SOSWidget.swift` to SOSWidget group → Check SOSWidget target only
- [ ] Drag `SOSWidgetProvider.swift` to SOSWidget group → Check SOSWidget target only
- [ ] Drag `SOSWidgetViews.swift` to SOSWidget group → Check SOSWidget target only
- [ ] Select `AppGroup.swift` → Check BOTH anxietyapp AND SOSWidget targets
- [ ] Verify `NavigationManager.swift` is ONLY in anxietyapp target

### 3. Configure App Groups
**For anxietyapp target:**
- [ ] Select anxietyapp target
- [ ] Signing & Capabilities tab
- [ ] Click "+ Capability"
- [ ] Add "App Groups"
- [ ] Add new group: `group.com.nuvin.anxietyapp`

**For SOSWidget target:**
- [ ] Select SOSWidget target
- [ ] Signing & Capabilities tab
- [ ] Click "+ Capability"
- [ ] Add "App Groups"
- [ ] Check existing: `group.com.nuvin.anxietyapp`

### 4. Set Deployment Target
- [ ] Select SOSWidget target
- [ ] Build Settings
- [ ] Set "iOS Deployment Target" to 16.6

### 5. Build & Test
- [ ] Select SOSWidget scheme
- [ ] Select iPhone 15 simulator
- [ ] Run (Cmd+R)
- [ ] Add widget to home screen
- [ ] Tap widget
- [ ] Verify SOS flow launches

---

## ✅ Verification Tests

- [ ] Build succeeds for anxietyapp scheme
- [ ] Build succeeds for SOSWidget scheme
- [ ] Widget appears in widget gallery
- [ ] Small home screen widget displays correctly
- [ ] Medium home screen widget displays correctly
- [ ] Large home screen widget displays correctly
- [ ] Circular lock screen widget displays correctly (iOS 16+)
- [ ] Rectangular lock screen widget displays correctly (iOS 16+)
- [ ] Inline lock screen widget displays correctly (iOS 16+)
- [ ] Tapping any widget opens app
- [ ] App navigates to home tab
- [ ] SOS flow launches automatically
- [ ] No console errors
- [ ] Works from cold app start
- [ ] Works when app is backgrounded

---

## 🐛 Common Issues & Fixes

| Issue | Fix |
|-------|-----|
| Widget not in gallery | Clean build (Shift+Cmd+K), delete app, rebuild |
| "Unable to Load" | Check App Groups match in both targets |
| Tap does nothing | Verify URL scheme in Info.plist |
| Build errors | Check file target membership |
| Old content shows | Remove and re-add widget |

---

## 📁 File Target Membership Reference

| File | anxietyapp | SOSWidget |
|------|-----------|-----------|
| `SOSWidget.swift` | ❌ | ✅ |
| `SOSWidgetProvider.swift` | ❌ | ✅ |
| `SOSWidgetViews.swift` | ❌ | ✅ |
| `AppGroup.swift` | ✅ | ✅ |
| `NavigationManager.swift` | ✅ | ❌ |
| All other app files | ✅ | ❌ |

---

## 🚀 Ready to Ship?

**Final checklist before App Store:**

- [ ] All widgets tested on physical device
- [ ] Screenshots taken for all widget sizes
- [ ] Privacy manifest updated (if needed)
- [ ] Archive builds successfully
- [ ] Widget description added to App Store listing
- [ ] Keywords include "widget", "emergency", "panic"

---

**Setup time: ~15 minutes**
**Testing time: ~5 minutes**
**Total: ~20 minutes**

See `SOS_WIDGET_SETUP_GUIDE.md` for detailed instructions.
