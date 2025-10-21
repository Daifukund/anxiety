# Privacy Policy & Terms of Service Deployment Guide

This guide will help you publish your Privacy Policy and Terms of Service to publicly accessible URLs required for App Store submission.

## Quick Overview

Your legal documents are located in `/docs`:
- `docs` - Landing page
- `docs/privacy` - Privacy Policy
- `docs/terms` - Terms of Service
- `docs/style.css` - Shared styles

## Option 1: GitHub Pages (Recommended - FREE)

### Step 1: Create a GitHub Repository

1. Go to [GitHub](https://github.com) and sign in (or create an account)
2. Click the **"+"** icon in the top right → **"New repository"**
    3. Name it: `nuvin-app` (or any name you prefer)
4. Set to **Public**
5. Click **"Create repository"**

### Step 2: Push Your Code to GitHub

```bash
# Navigate to your project
cd /Users/nathandouziech/Desktop/anxietyapp

# If not already initialized (check with git status)
git init

# Add your files
git add docs/

# Commit
git commit -m "Add legal documents for GitHub Pages"

# Add your GitHub repository as remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/nuvin-app.git

# Push to GitHub
git push -u origin main
```

### Step 3: Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **Settings** (top menu)
3. Scroll down to **Pages** (left sidebar)
4. Under **Source**, select:
   - **Branch:** `main`
   - **Folder:** `/docs`
5. Click **Save**

### Step 4: Get Your URLs

After 1-2 minutes, your site will be live at:

```
https://YOUR_USERNAME.github.io/nuvin-app/
https://YOUR_USERNAME.github.io/nuvin-app/privacy
https://YOUR_USERNAME.github.io/nuvin-app/terms
```

**These are the URLs you'll use in App Store Connect!**

---

## Option 2: Custom Domain (nuvin.app)

If you want professional URLs like `nuvin.app/privacy`:

### Step 1: Purchase Domain

1. Go to a domain registrar (Namecheap, Google Domains, Cloudflare, etc.)
2. Search for `nuvin.app` (or another name)
3. Purchase domain (~$12/year)

### Step 2: Set Up GitHub Pages with Custom Domain

1. Follow **Option 1** steps first
2. In your repository **Settings → Pages**:
   - Enter your custom domain: `nuvin.app`
   - Enable **"Enforce HTTPS"**
3. In your domain registrar's DNS settings, add:
   - **A Record** pointing to GitHub Pages IPs:
     ```
     185.199.108.153
     185.199.109.153
     185.199.110.153
     185.199.111.153
     ```
   - **CNAME Record** for `www` pointing to: `YOUR_USERNAME.github.io`

### Step 3: Wait for DNS Propagation

DNS changes can take 24-48 hours. Your site will then be live at:
```
https://nuvin.app/
https://nuvin.app/privacy
https://nuvin.app/terms
```

---

## Option 3: Netlify (Alternative FREE hosting)

### Step 1: Sign Up for Netlify

1. Go to [netlify.com](https://netlify.com)
2. Sign up with GitHub

### Step 2: Deploy

1. Click **"Add new site"** → **"Import an existing project"**
2. Connect to your GitHub repository
3. Configure:
   - **Base directory:** `docs`
   - **Build command:** (leave empty)
   - **Publish directory:** `./`
4. Click **"Deploy site"**

### Step 3: Get URLs

Netlify will give you a URL like:
```
https://random-name-12345.netlify.app/privacy
https://random-name-12345.netlify.app/terms
```

You can customize the subdomain or add a custom domain in Netlify settings.

---

## Important: Update Email Addresses

Your legal documents reference these email addresses:
- `privacy@nuvin.app`
- `support@nuvin.app`

**You have two options:**

### Option A: Get the nuvin.app domain and set up email

If you purchase `nuvin.app`, you can set up email forwarding through:
- **Google Workspace** ($6/month per user)
- **Cloudflare Email Routing** (FREE)
- **Namecheap Email Forwarding** (often free with domain)

### Option B: Use an email you already own

Edit the HTML files and replace:
- `privacy@nuvin.app` → `your-email@gmail.com`
- `support@nuvin.app` → `your-email@gmail.com`

Update both:
- `docs/privacy` (line containing "privacy@nuvin.app")
- `docs/terms` (line containing "support@nuvin.app")

---

## Next Steps: App Store Connect

Once your URLs are live:

1. **Test the URLs** in a web browser to make sure they work
2. **Copy the URLs** (e.g., `https://yourusername.github.io/nuvin-app/privacy`)
3. Go to **App Store Connect**
4. In your app's **App Information** section:
   - **Privacy Policy URL:** Paste your privacy.html URL
   - **Terms of Service URL:** Paste your terms.html URL (if requested)
5. Save changes

---

## Updating Documents in the Future

If you need to update your legal documents:

1. Edit the HTML files in `/docs`
2. Commit and push to GitHub:
   ```bash
   git add docs/
   git commit -m "Update legal documents"
   git push
   ```
3. Changes will be live within 1-2 minutes on GitHub Pages

---

## Need Help?

- **GitHub Pages Documentation:** https://docs.github.com/en/pages
- **Netlify Documentation:** https://docs.netlify.com
- **Custom Domain Setup:** https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site

---

## Checklist

- [ ] Choose hosting option (GitHub Pages recommended)
- [ ] Create repository and push code
- [ ] Enable GitHub Pages
- [ ] Verify URLs work in browser
- [ ] Update email addresses (if needed)
- [ ] Add URLs to App Store Connect
- [ ] Test that URLs are accessible
- [ ] (Optional) Set up custom domain
