    //
//  FeedbackIncentiveView.swift
//  anxietyapp
//
//  Feedback form shown when user long-presses app icon
//  Offers 1 month free subscription as incentive for feedback
//

import SwiftUI

struct FeedbackIncentiveView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedReasons: Set<String> = []
    @State private var additionalFeedback: String = ""
    @State private var userEmail: String = ""
    @State private var isSubmitting = false
    @State private var showThankYou = false
    @State private var emailError: String?

    private let feedbackReasons = [
        "Too expensive",
        "Not enough features",
        "Technical issues",
        "Didn't help with anxiety",
        "Found a better alternative",
        "Privacy concerns",
        "Other"
    ]

    var body: some View {
        NavigationView {
            ZStack {
                if showThankYou {
                    thankYouView
                } else {
                    feedbackFormView
                }
            }
            .navigationTitle("Before you go...")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var feedbackFormView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.primaryPurple)

                    Text("We'd love to hear from you")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)

                    Text("Tell us why you're leaving and we'll send you **1 month free**")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 8)

                Divider()

                // Feedback reasons
                VStack(alignment: .leading, spacing: 16) {
                    Text("What's the main reason? (Select all that apply)")
                        .font(.headline)

                    VStack(spacing: 12) {
                        ForEach(feedbackReasons, id: \.self) { reason in
                            FeedbackReasonButton(
                                reason: reason,
                                isSelected: selectedReasons.contains(reason),
                                action: {
                                    if selectedReasons.contains(reason) {
                                        selectedReasons.remove(reason)
                                    } else {
                                        selectedReasons.insert(reason)
                                    }
                                }
                            )
                        }
                    }
                }

                // Email field
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your email (we'll send you a promo code)")
                        .font(.headline)

                    TextField("", text: $userEmail, prompt: Text("email@example.com").foregroundColor(.gray.opacity(0.5)))
                        .textFieldStyle(.plain)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(emailError != nil ? Color.red : Color(.systemGray4), lineWidth: 1)
                        )

                    if let emailError = emailError {
                        Text(emailError)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

                // Additional feedback
                VStack(alignment: .leading, spacing: 12) {
                    Text("Anything else we should know? (Optional)")
                        .font(.headline)

                    ZStack(alignment: .topLeading) {
                        if additionalFeedback.isEmpty {
                            Text("Your feedback helps us improve...")
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                        }

                        TextEditor(text: $additionalFeedback)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                }

                // Submit button
                Button(action: {
                    print("🔴 BUTTON TAPPED!")
                    submitFeedback()
                }) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Submit & Get 1 Month Free")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background((selectedReasons.isEmpty || userEmail.isEmpty) ? Color.gray : Color.primaryPurple)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .disabled(selectedReasons.isEmpty || userEmail.isEmpty || isSubmitting)

                // Privacy note
                Text("Your feedback is anonymous and helps us improve Nuvin")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
        }
    }

    private var thankYouView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(.green)

            VStack(spacing: 12) {
                Text("Thank you!")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Your feedback has been submitted")
                    .font(.body)
                    .foregroundColor(.secondary)

                Text("We'll review your feedback and email you a promo code within 24 hours")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(.primaryPurple)
                    .padding(.top, 8)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button(action: { dismiss() }) {
                Text("Close")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryPurple)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    private func submitFeedback() {
        print("🔵 submitFeedback called")

        // Validate email
        guard isValidEmail(userEmail) else {
            print("❌ Email validation failed: \(userEmail)")
            emailError = "Please enter a valid email address"
            return
        }

        print("✅ Email validated: \(userEmail)")
        emailError = nil
        isSubmitting = true

        // Track analytics
        let feedbackData: [String: Any] = [
            "reasons": Array(selectedReasons),
            "additional_feedback": additionalFeedback,
            "source": "quick_action",
            "has_email": !userEmail.isEmpty
        ]

        print("📊 Tracking analytics...")
        AnalyticsService.shared.track(.feedbackSubmitted, properties: feedbackData)

        print("📧 Calling FeedbackEmailService.sendFeedback...")
        // Send feedback via email
        FeedbackEmailService.shared.sendFeedback(
            userEmail: userEmail,
            reasons: Array(selectedReasons),
            additionalFeedback: additionalFeedback
        ) { result in
            print("📬 Email service callback received")
            DispatchQueue.main.async {
                isSubmitting = false

                switch result {
                case .success:
                    withAnimation {
                        showThankYou = true
                    }

                    // Auto-dismiss after 4 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        dismiss()
                    }

                case .failure(let error):
                    emailError = "Failed to send: \(error.localizedDescription)"
                }
            }
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

struct FeedbackReasonButton: View {
    let reason: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Color.primaryPurple : .gray)
                    .font(.title3)

                Text(reason)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding()
            .background(isSelected ? Color.primaryPurple.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.primaryPurple : Color(.systemGray4), lineWidth: 1.5)
            )
        }
    }
}

#Preview {
    FeedbackIncentiveView()
}
