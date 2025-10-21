# 🚨 SECURITY ALERT - API KEY ROTATION REQUIRED

## CRITICAL: Your API Keys Were Exposed in Git

Your `Config.plist` file containing production API keys was committed to the git repository.

### Exposed Keys (NOW REMOVED FROM GIT):
- ✅ RevenueCat API Key: `appl_FchwLGrnKCIZVVJiNfPBOtizTMb`
- ✅ Mixpanel Token: `78a41fbf890ab6cbe392c22081e80e15`
- ✅ AppsFlyer Dev Key: `DZUHwzPd9WKsjdyxd2kG4V`

### ✅ FIXED: Config.plist Removed from Git
The file has been removed from git tracking and will no longer be committed.

---

## ⚠️ ACTION REQUIRED: Rotate All API Keys

If this repository was ever:
- Pushed to GitHub/GitLab (public or private)
- Shared with anyone
- Cloned to multiple machines

You MUST rotate these keys immediately:

### 1. RevenueCat API Key
1. Go to https://app.revenuecat.com/settings/api-keys
2. Delete the exposed key: `appl_FchwLGrnKCIZVVJiNfPBOtizTMb`
3. Generate a new API key
4. Update `anxietyapp/Config.plist` with the new key

### 2. Mixpanel Project Token
1. Go to https://mixpanel.com/settings/project
2. Contact Mixpanel support to rotate token (tokens cannot be self-rotated)
3. Or create a new Mixpanel project and update the token
4. Update `anxietyapp/Config.plist` with the new token

### 3. AppsFlyer Dev Key
1. Go to https://hq1.appsflyer.com/settings/dev-key
2. Contact AppsFlyer support to rotate the dev key
3. Or create a new app in AppsFlyer dashboard
4. Update `anxietyapp/Config.plist` with the new key

---

## 🔒 Security Best Practices Going Forward

1. ✅ `Config.plist` is now in `.gitignore` and removed from tracking
2. ✅ `Config-Template.plist` remains as a template (no real keys)
3. ✅ Never commit real API keys to version control
4. ✅ Always use environment variables or secure vaults in production

---

## Verification

Check that Config.plist is properly ignored:
```bash
git status
# Should NOT show Config.plist as tracked or modified
```

If you see Config.plist in `git status`, run:
```bash
git rm --cached anxietyapp/Config.plist
git commit -m "Remove Config.plist from version control"
```
