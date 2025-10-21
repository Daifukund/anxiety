//
//  OnboardingRatingView.swift
//  anxietyapp
//
//  Created by Claude Code
//

import SwiftUI

struct OnboardingRatingView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Header
                    VStack(spacing: DesignSystem.Spacing.small) {
                        StarRating(count: 5)

                        Text("You're not alone on this journey.")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.textDark)
                            .multilineTextAlignment(.center)

                        Text("This app was designed for people like you.")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.textMedium)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, DesignSystem.Spacing.xl)
                    .padding(.horizontal, DesignSystem.Spacing.large)

                    // Testimonials
                    VStack(spacing: DesignSystem.Spacing.medium) {
                        TestimonialCard(
                            rating: 5,
                            text: "I've tried tons of apps for anxiety, but nothing compares to how fast this works. Within minutes, I felt calmer.",
                            author: "Leo G."
                        )

                        TestimonialCard(
                            rating: 5,
                            text: "This app helped me through my worst panic attack. The breathing exercises actually work.",
                            author: "Giulia P."
                        )

                        TestimonialCard(
                            rating: 5,
                            text: "In one week, my sleep improved a lot.",
                            author: "Anonymous user"
                        )

                        TestimonialCard(
                            rating: 5,
                            text: "Finally, relief that actually works when I need it. The SOS button is a lifesaver.",
                            author: "Camille D."
                        )

                        TestimonialCard(
                            rating: 5,
                            text: "Finally, an app that actually works for stress relief.",
                            author: "Anonymous user"
                        )
                    }
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    .padding(.bottom, DesignSystem.Spacing.medium)
                }
            }

            // Continue button - always visible
            OnboardingButton(title: "Continue", action: onContinue)
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .padding(.bottom, DesignSystem.Spacing.medium)
                .background(Color.white)
        }
        .gradientBackground()
    }
}

// MARK: - Testimonial Card Component
struct TestimonialCard: View {
    let rating: Int
    let text: String
    let author: String

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            // Author and Star rating on top
            HStack(alignment: .center, spacing: DesignSystem.Spacing.xs) {
                // Author name
                Text(author)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textDark)

                Spacer()

                // Star rating
                HStack(spacing: 3) {
                    ForEach(0..<rating, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.yellow)
                    }
                }
            }

            // Review text with quote styling
            Text("\"\(text)\"")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.textMedium)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
                .italic()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.medium)
        .background(
            LinearGradient(
                colors: [
                    Color.white,
                    Color.secondaryViolet.opacity(0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .stroke(Color.primaryPurple.opacity(0.1), lineWidth: 1)
        )
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .shadow(color: Color.primaryPurple.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

#Preview {
    OnboardingRatingView(onContinue: {})
}
