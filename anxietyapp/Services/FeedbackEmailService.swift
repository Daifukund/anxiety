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

    // MARK: - FormSubmit Configuration
    // FormSubmit.co - Free email service that works from iOS apps
    private let yourEmail = "nathan@nuvin.app"

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
        // FormSubmit endpoint - super simple, no API keys needed!
        let formSubmitURL = "https://formsubmit.co/\(yourEmail)"

        guard let url = URL(string: formSubmitURL) else {
            print("❌ Invalid email: \(yourEmail)")
            completion(.failure(EmailError.invalidEndpoint))
            return
        }

        print("🌐 Sending to FormSubmit: \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        // FormSubmit requires form-encoded data, NOT JSON
        let formData: [String: String] = [
            "_subject": "🚨 Nuvin - User Feedback Before Deletion",
            "User_Email": userEmail,
            "Reasons": reasons,
            "Feedback": additionalFeedback.isEmpty ? "No additional feedback" : additionalFeedback,
            "Submitted": Date().formatted(date: .long, time: .standard),
            "_captcha": "false"
        ]

        // Convert to form-encoded string
        var components = URLComponents()
        components.queryItems = formData.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let formEncodedData = components.percentEncodedQuery?.data(using: .utf8) else {
            print("❌ Failed to encode form data")
            completion(.failure(EmailError.sendFailed))
            return
        }

        request.httpBody = formEncodedData

        print("📧 Sending feedback email...")
        print("To: \(yourEmail)")
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
                    print("📧 FormSubmit response status: \(httpResponse.statusCode)")

                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("📧 Response: \(responseString)")
                    }

                    // FormSubmit returns 200 on success
                    if httpResponse.statusCode == 200 {
                        print("✅ Email sent successfully via FormSubmit!")
                        completion(.success(()))
                    } else {
                        print("❌ FormSubmit error (status \(httpResponse.statusCode))")
                        completion(.failure(EmailError.sendFailed))
                    }
                } else {
                    print("❌ No HTTP response")
                    completion(.failure(EmailError.sendFailed))
                }
            }
        }

        task.resume()
        print("✅ Request sent to FormSubmit")
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
