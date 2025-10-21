# Email Addresses Configuration Required

## Current Situation

Your Privacy Policy and Terms of Service documents reference these email addresses:
- **privacy@nuvin.app** (in Privacy Policy)
- **support@nuvin.app** (in Terms of Service)

These emails are currently **placeholders** and not functional.

## You Must Choose One Option:

### Option 1: Purchase nuvin.app Domain + Set Up Email

**If you want professional branding:**

1. **Purchase the domain** `nuvin.app` (check availability at Namecheap, Google Domains, etc.)
   - Cost: ~$12-15/year

2. **Set up email forwarding** (choose one):
   - **Cloudflare Email Routing** (FREE) - Forwards emails to your personal email
   - **Google Workspace** ($6/month) - Get actual privacy@nuvin.app and support@nuvin.app inboxes
   - **Namecheap Email Forwarding** - Often free with domain purchase

3. **No changes needed** to your legal documents

**Pros:**
- Professional appearance
- Matches your app branding
- Ready for launch

**Cons:**
- Ongoing cost (minimal if using free email forwarding)

---

### Option 2: Use Your Personal Email

**If you want to launch quickly and avoid costs:**

1. **Edit the HTML files** to replace placeholder emails:

   **File: docs/privacy.html**
   - Find: `privacy@nuvin.app`
   - Replace with: `your-actual-email@gmail.com` (or whatever email you use)

   **File: docs/terms.html**
   - Find: `support@nuvin.app`
   - Replace with: `your-actual-email@gmail.com`

2. **Also update the markdown files** (used in the app):
   - `anxietyapp/Resources/PrivacyPolicy.md`
   - `anxietyapp/Resources/TermsOfService.md`

**Pros:**
- Free
- Works immediately
- No domain purchase needed

**Cons:**
- Less professional appearance
- You can always upgrade to a custom domain later

---

## Recommendation

**For MVP/Initial Launch:**
→ Use your personal email (Option 2) to get launched quickly

**For Professional Launch:**
→ Get the nuvin.app domain + Cloudflare email forwarding (FREE after domain purchase)

---

## How to Update Email in Files

If choosing Option 2 (personal email), update these files:

### HTML files (for web):
```bash
# Edit these files and replace the emails:
docs/privacy.html
docs/terms.html
```

### Markdown files (for in-app display):
```bash
# Also update these:
anxietyapp/Resources/PrivacyPolicy.md
anxietyapp/Resources/TermsOfService.md
```

You can use find-and-replace in any text editor:
- Find: `privacy@nuvin.app`
- Replace: `youremail@example.com`

---

## Questions to Answer:

1. **Do you already own the nuvin.app domain?**
   - If yes → Set up email forwarding
   - If no → Decide if you want to purchase it

2. **What's your preferred contact email for user support?**
   - This will be used for both privacy and support contacts

3. **Timeline:**
   - Launching soon? → Use personal email
   - Have time? → Get professional domain + email

---

## Next Action Required

⚠️ **Before deploying to GitHub Pages or submitting to App Store:**

Choose one of the options above and update the email addresses accordingly.
