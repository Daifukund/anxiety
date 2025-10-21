# Email Service Setup Guide

This guide will help you set up email delivery for the feedback feature.

## Current Status

✅ **Implemented:**
- Feedback form with email collection
- Email validation
- Email service architecture
- Beautiful HTML email templates

⚠️ **To Do:**
- Configure email service provider (see options below)

---

## Quick Setup Options

### Option 1: EmailJS (Easiest - No Backend Required) ⭐ RECOMMENDED

**Why:** Free tier, no backend needed, works directly from iOS app.

**Setup Steps:**

1. **Sign up at [EmailJS.com](https://www.emailjs.com/)**
   - Free tier: 200 emails/month

2. **Create an Email Service:**
   - Dashboard → Email Services → Add New Service
   - Choose Gmail, Outlook, or your email provider
   - Follow connection instructions

3. **Create an Email Template:**
   - Dashboard → Email Templates → Create New Template
   - Template for feedback (to you):
     ```
     Subject: 🚨 User Feedback Before Deletion

     User Email: {{user_email}}

     Reasons:
     {{reasons}}

     Additional Feedback:
     {{additional_feedback}}
     ```
   - Template for promo code (to user):
     ```
     Subject: 🎁 Your Free Month of Nuvin Premium

     [Use the HTML template from FeedbackEmailService.swift]
     ```

4. **Get Your Credentials:**
   - Service ID: `service_xxxxxxx`
   - Template ID: `template_xxxxxxx`
   - Public Key: `your_public_key`

5. **Update the Code:**

   In `FeedbackEmailService.swift`, replace the `sendEmail` method:

   ```swift
   import EmailJS // Add EmailJS SDK

   private let emailJSServiceID = "service_xxxxxxx"
   private let emailJSTemplateID = "template_xxxxxxx"
   private let emailJSPublicKey = "your_public_key"

   private func sendEmail(
       to: String,
       subject: String,
       body: String,
       completion: @escaping (Result<Void, Error>) -> Void
   ) {
       // EmailJS implementation
       EmailJS.send(
           serviceID: emailJSServiceID,
           templateID: emailJSTemplateID,
           templateParams: [
               "to_email": to,
               "subject": subject,
               "message": body
           ],
           publicKey: emailJSPublicKey
       ) { response in
           if response.status == 200 {
               completion(.success(()))
           } else {
               completion(.failure(EmailError.sendFailed))
           }
       }
   }
   ```

---

### Option 2: SendGrid API (Professional)

**Why:** Professional email service, good deliverability, 100 free emails/day.

**Setup Steps:**

1. **Sign up at [SendGrid.com](https://sendgrid.com/)**

2. **Get API Key:**
   - Settings → API Keys → Create API Key
   - Copy your API key

3. **Update Config.plist:**
   ```xml
   <key>SendGridAPIKey</key>
   <string>YOUR_SENDGRID_API_KEY</string>
   ```

4. **Add to ConfigurationManager.swift:**
   ```swift
   static var sendGridAPIKey: String {
       return configValue(for: "SendGridAPIKey") ?? ""
   }
   ```

5. **Update FeedbackEmailService.swift:**
   ```swift
   private func sendEmail(
       to: String,
       subject: String,
       body: String,
       completion: @escaping (Result<Void, Error>) -> Void
   ) {
       let url = URL(string: "https://api.sendgrid.com/v3/mail/send")!
       var request = URLRequest(url: url)
       request.httpMethod = "POST"
       request.setValue("Bearer \(ConfigurationManager.sendGridAPIKey)", forHTTPHeaderField: "Authorization")
       request.setValue("application/json", forHTTPHeaderField: "Content-Type")

       let emailData: [String: Any] = [
           "personalizations": [[
               "to": [["email": to]]
           ]],
           "from": ["email": "noreply@nuvin.app"],
           "subject": subject,
           "content": [[
               "type": "text/html",
               "value": body
           ]]
       ]

       request.httpBody = try? JSONSerialization.data(withJSONObject: emailData)

       URLSession.shared.dataTask(with: request) { data, response, error in
           DispatchQueue.main.async {
               if let error = error {
                   completion(.failure(error))
                   return
               }
               completion(.success(()))
           }
       }.resume()
   }
   ```

---

### Option 3: Your Own Backend API

**Why:** Full control, can store feedback in database.

**Setup Steps:**

1. **Create an endpoint:** `POST /api/feedback`

2. **Request body:**
   ```json
   {
     "user_email": "user@example.com",
     "reasons": ["Too expensive", "Not enough features"],
     "additional_feedback": "...",
     "timestamp": "2024-01-15T10:30:00Z"
   }
   ```

3. **Update FeedbackEmailService.swift:**
   ```swift
   private let emailEndpoint = "https://yourapi.com/api/feedback"

   private func sendEmail(...) {
       guard let url = URL(string: emailEndpoint) else {
           completion(.failure(EmailError.invalidEndpoint))
           return
       }

       var request = URLRequest(url: url)
       request.httpMethod = "POST"
       request.setValue("application/json", forHTTPHeaderField: "Content-Type")

       let feedbackData: [String: Any] = [
           "user_email": to,
           "subject": subject,
           "body": body
       ]

       request.httpBody = try? JSONSerialization.data(withJSONObject: feedbackData)

       URLSession.shared.dataTask(with: request) { data, response, error in
           // Handle response
       }.resume()
   }
   ```

---

## Testing

Right now, the email service is in **simulation mode**. It will:
- ✅ Print email content to console
- ✅ Track analytics
- ✅ Show success message
- ❌ Not actually send emails

To test:
1. Run the app
2. Long-press app icon → "Leaving? Tell us why..."
3. Fill out form
4. Check Xcode console for email preview

---

## Recommended: Start with EmailJS

EmailJS is the easiest to set up and requires **zero backend code**. Once you validate the feature works well, you can upgrade to SendGrid or build your own backend.

---

## Configuration File Location

Update this file:
```
/Users/nathandouziech/Desktop/anxietyapp/anxietyapp/Services/FeedbackEmailService.swift
```

Replace these lines (14-15):
```swift
private let emailEndpoint = "YOUR_EMAIL_SERVICE_ENDPOINT"
private let recipientEmail = "YOUR_EMAIL@example.com"
```

With your actual values.

---

## Need Help?

Just ask! I can help you:
1. Set up EmailJS integration
2. Implement SendGrid
3. Build a simple backend API
4. Test the email flow
