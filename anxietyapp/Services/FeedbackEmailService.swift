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
    private let webhookURL = "https://script.google.com/macros/s/AKfycbzFa8g-33Q6Ct8xabOo0hQOm7UZPNthzhw1CiYWD2NQkTqO3ietf5VazCvXYuut3lNh/exec"

    // MARK: - Send Feedback

    func sendFeedback(
        userEmail: String,
        reasons: [String],
        additionalFeedback: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        #if DEBUG
        print("🟢 FeedbackEmailService.sendFeedback called")
        print("User email: \(userEmail)")
        print("Reasons count: \(reasons.count)")
        #endif

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
            #if DEBUG
            print("❌ Invalid webhook URL")
            #endif
            completion(.failure(EmailError.invalidEndpoint))
            return
        }

        #if DEBUG
        print("🌐 Sending to Google Apps Script webhook")
        #endif

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
            #if DEBUG
            print("❌ JSON encoding error: \(error)")
            #endif
            completion(.failure(error))
            return
        }

        #if DEBUG
        print("📧 Sending feedback to webhook...")
        print("Webhook URL: \(webhookURL)")
        print("User: \(userEmail)")
        print("Reasons: \(reasons)")
        print("JSON Data: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "none")")
        #endif

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    #if DEBUG
                    print("❌ Network error: \(error.localizedDescription)")
                    #endif
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    #if DEBUG
                    print("📧 Webhook response status: \(httpResponse.statusCode)")

                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("📧 Response: \(responseString)")
                    }
                    #endif

                    if httpResponse.statusCode == 200 {
                        #if DEBUG
                        print("✅ Email sent successfully via Google Apps Script!")
                        #endif
                        completion(.success(()))
                    } else {
                        #if DEBUG
                        print("❌ Webhook error (status \(httpResponse.statusCode))")
                        #endif
                        completion(.failure(EmailError.sendFailed))
                    }
                } else {
                    #if DEBUG
                    print("❌ No HTTP response")
                    #endif
                    completion(.failure(EmailError.sendFailed))
                }
            }
        }

        task.resume()
        #if DEBUG
        print("✅ Request sent to webhook")
        #endif
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
