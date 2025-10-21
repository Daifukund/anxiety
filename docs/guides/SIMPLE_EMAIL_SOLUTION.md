# Simple Email Solution - Choose One

FormSubmit and EmailJS don't work from iOS apps. Here are 3 **working** solutions:

---

## ✅ **OPTION 1: Make.com Webhook (EASIEST - 5 min setup)**

### Setup:
1. Go to [make.com](https://www.make.com) (free account)
2. Create new scenario
3. Add "Webhooks" → "Custom webhook"
4. Copy the webhook URL (looks like: `https://hook.us1.make.com/abc123`)
5. Add "Gmail" → "Send an Email" module
6. Connect Gmail and configure:
   - To: `nathan@nuvin.app`
   - Subject: `🚨 User Feedback - {{1.Reasons}}`
   - Body: Use the webhook data

### In Code:
Just change one line in `FeedbackEmailService.swift`:
```swift
private let webhookURL = "YOUR_MAKE.COM_WEBHOOK_URL"
```

---

## ✅ **OPTION 2: Zapier Webhook (Also Easy)**

### Setup:
1. Go to [zapier.com](https://zapier.com) (free tier)
2. Create Zap: Webhooks → Gmail
3. Get webhook URL
4. Configure email template

Same code change as Option 1.

---

## ✅ **OPTION 3: Google Apps Script (100% Free Forever)**

### Setup (10 minutes):
1. Go to [script.google.com](https://script.google.com)
2. New Project
3. Paste this code:

```javascript
function doPost(e) {
  try {
    var data = JSON.parse(e.postData.contents);

    var subject = "🚨 Nuvin - User Feedback Before Deletion";
    var body = "User Email: " + data.user_email + "\n\n" +
               "Reasons: " + data.reasons + "\n\n" +
               "Feedback: " + data.feedback + "\n\n" +
               "Submitted: " + data.timestamp;

    MailApp.sendEmail({
      to: "nathan@nuvin.app",
      subject: subject,
      body: body
    });

    return ContentService.createTextOutput(JSON.stringify({success: true}))
      .setMimeType(ContentService.MimeType.JSON);

  } catch(error) {
    return ContentService.createTextOutput(JSON.stringify({success: false, error: error.toString()}))
      .setMimeType(ContentService.MimeType.JSON);
  }
}
```

4. Deploy → New Deployment → Web App
5. Execute as: **Me**
6. Who has access: **Anyone**
7. Copy the deployment URL

### In Code:
```swift
private let webhookURL = "YOUR_GOOGLE_APPS_SCRIPT_URL"
```

---

## Which Should You Choose?

- **Make.com** - Easiest if you want a visual interface
- **Zapier** - If you already use Zapier
- **Google Apps Script** - 100% free forever, no limits, most reliable

---

I recommend **Google Apps Script** - it's free forever and totally reliable.

**Which one do you want to use?** I'll update the code for you.
