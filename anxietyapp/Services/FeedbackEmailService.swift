//
//  FeedbackEmailService.swift
//  anxietyapp
//
//  Service for sending feedback emails
//

import Foundation

class FeedbackEmailService {
    static let shared = FeedbackEmailService()

    private init() {}

    // MARK: - Google Apps Script Webhook
    // Webhook that forwards feedback to nathan@nuvin.app
    private let webhookURL = "https://script.google.com/macros/u/1/s/AKfycbzFa8g-33Q6Ct8xabOo0hQOm7UZPNthzhw1CiYWD2NQkTqO3ietf5VazCvXYuut3lNh/exec"

    // MARK: - Send Feedback

    func sendFeedback(
        userEmail: String,
        reasons: [String],
        additionalFeedback: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        print("🟢 FeedbackEmailService.sendFeedback called")
        print("User email: \(userEmail)")
        print("Reasons count: \(reasons.count)")

        // Format reasons as a readable list
        let reasonsList = reasons.joined(separator: ", ")

        sendEmailViaFormSubmit(
            userEmail: userEmail,
            reasons: reasonsList,
            additionalFeedback: additionalFeedback,
            completion: completion
        )
    }

    private func sendEmailViaFormSubmit(
        userEmail: String,
        reasons: String,
        additionalFeedback: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: webhookURL) else {
            print("❌ Invalid webhook URL")
            completion(.failure(EmailError.invalidEndpoint))
            return
        }

        print("🌐 Sending to Google Apps Script webhook")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        // Prepare JSON data for webhook
        let webhookData: [String: String] = [
            "user_email": userEmail,
            "reasons": reasons,
            "feedback": additionalFeedback.isEmpty ? "No additional feedback" : additionalFeedback,
            "timestamp": Date().formatted(date: .long, time: .standard)
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: webhookData)
        } catch {
            print("❌ JSON encoding error: \(error)")
            completion(.failure(error))
            return
        }

        print("📧 Sending feedback to webhook...")
        print("User: \(userEmail)")
        print("Reasons: \(reasons)")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("📧 Webhook response status: \(httpResponse.statusCode)")

                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("📧 Response: \(responseString)")
                    }

                    if httpResponse.statusCode == 200 {
                        print("✅ Email sent successfully via Google Apps Script!")
                        completion(.success(()))
                    } else {
                        print("❌ Webhook error (status \(httpResponse.statusCode))")
                        completion(.failure(EmailError.sendFailed))
                    }
                } else {
                    print("❌ No HTTP response")
                    completion(.failure(EmailError.sendFailed))
                }
            }
        }

        task.resume()
        print("✅ Request sent to webhook")
    }
}

// MARK: - Email Errors

enum EmailError: LocalizedError {
    case invalidEndpoint
    case invalidEmail
    case sendFailed

    var errorDescription: String? {
        switch self {
        case .invalidEndpoint:
            return "Email service endpoint is not configured"
        case .invalidEmail:
            return "Invalid email address"
        case .sendFailed:
            return "Failed to send email"
        }
    }
}
