//
//  OnboardingOfferPageView.swift
//  anxietyapp
//
//  Created by Claude Code
//

import SwiftUI

struct OnboardingOfferPageView: View {
    let userName: String
    let userProfile: UserProfile
    let onContinue: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                // Personalized Hero
            VStack(spacing: DesignSystem.Spacing.medium) {
                Text("\(userName), we've made custom exercises for you.")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.textDark)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text("No BS. No long meditations or lessons. Just quick, science-backed relief when you need it most.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.textMedium)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, DesignSystem.Spacing.xl)
            .padding(.horizontal, DesignSystem.Spacing.large)

            // Core Benefits Section
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                // Section Header
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.primaryPurple)

                    Text("What you get")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.textDark)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, DesignSystem.Spacing.xs)

                benefitRow(
                    icon: "bolt.fill",
                    title: "Instant relief",
                    description: "Quick tools for panic & stress, anytime.",
                    color: .primaryPurple
                )

                benefitRow(
                    icon: "person.fill.checkmark",
                    title: "Personalized to you",
                    description: "Exercises matched to your goals & symptoms.",
                    color: .primaryPurple
                )

                benefitRow(
                    icon: "lock.shield.fill",
                    title: "100% Private",
                    description: "No account needed. Your data stays on your device.",
                    color: .primaryPurple
                )

                benefitRow(
                    icon: "wifi.slash",
                    title: "Works offline",
                    description: "SOS tools always available, even without internet.",
                    color: .primaryPurple
                )

                benefitRow(
                    icon: "apps.iphone",
                    title: "Lock screen widget",
                    description: "1-tap SOS access - no unlock needed.",
                    color: .primaryPurple
                )

                benefitRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Track your progress",
                    description: "See improvements in mood & stress levels.",
                    color: .primaryPurple
                )
            }
            .padding(.horizontal, DesignSystem.Spacing.large)
            .padding(.top, DesignSystem.Spacing.large)

            // Personalized Insight (if they experienced relief)
            if let before = userProfile.anxietyBefore,
               let after = userProfile.anxietyAfter,
               before > after {
                VStack(spacing: DesignSystem.Spacing.small) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.success)

                        Text("You just reduced anxiety by \(userProfile.anxietyImprovementPercentage)%")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.textDark)
                    }

                    Text("Imagine having this relief available 24/7, whenever you need it.")
                        .font(.system(size: 14))
                        .foregroundColor(.textMedium)
                        .multilineTextAlignment(.center)
                }
                .padding(DesignSystem.Spacing.small)
                .background(Color.success.opacity(0.1))
                .cornerRadius(DesignSystem.CornerRadius.medium)
                .padding(.horizontal, DesignSystem.Spacing.large)
                .padding(.top, DesignSystem.Spacing.medium)
            }

            // Anxiety Toolkit Preview
            VStack(spacing: DesignSystem.Spacing.medium) {
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text("Your Anxiety Toolkit")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.textDark)

                    if let technique = userProfile.chosenTechnique {
                        Text("You tried: \(technique.rawValue)")
                            .font(.system(size: 14))
                            .foregroundColor(.textMedium)
                    }

                    Text("Unlock 10+ more techniques")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primaryPurple)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignSystem.Spacing.small) {
                        toolkitCard(title: "SOS Button", icon: "bolt.circle.fill", isLocked: false)
                        toolkitCard(title: "Box Breathing", icon: "wind", isLocked: userProfile.chosenTechnique != .breathing)
                        toolkitCard(title: "5-4-3-2-1\nGrounding", icon: "hand.tap.fill", isLocked: userProfile.chosenTechnique != .grounding)
                        toolkitCard(title: "Zoom Out", icon: "arrow.up.left.and.arrow.down.right", isLocked: true)
                        toolkitCard(title: "Quick Dump", icon: "brain.head.profile", isLocked: true)
                        toolkitCard(title: "Reframe\nStress", icon: "rectangle.2.swap", isLocked: true)
                        toolkitCard(title: "Emotion\nReset", icon: "heart.circle.fill", isLocked: true)
                        toolkitCard(title: "Affirmations", icon: "sparkles", isLocked: true)
                        toolkitCard(title: "Mood Check-In", icon: "face.smiling", isLocked: true)
                        toolkitCard(title: "Quote of Day", icon: "quote.bubble.fill", isLocked: true)
                        toolkitCard(title: "Stats", icon: "chart.bar.fill", isLocked: true)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                }
            }
            .padding(.top, DesignSystem.Spacing.large)

            // Value Message
            Text("More affordable than a single therapy session")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textMedium)
                .multilineTextAlignment(.center)
                .padding(.top, DesignSystem.Spacing.large)
                .padding(.horizontal, DesignSystem.Spacing.large)

            // Guarantee Badges
            VStack(spacing: DesignSystem.Spacing.xs) {
                HStack(spacing: DesignSystem.Spacing.medium) {
                    guaranteeBadge(icon: "checkmark.shield.fill", text: "Money-back\nguarantee")
                    guaranteeBadge(icon: "arrow.uturn.left.circle.fill", text: "Cancel\nanytime")
                }

                HStack(spacing: DesignSystem.Spacing.medium) {
                    guaranteeBadge(icon: "wifi.slash", text: "Works\noffline")
                    guaranteeBadge(icon: "lock.shield.fill", text: "100%\nprivate")
                }
            }
            .padding(.top, DesignSystem.Spacing.large)
            .padding(.horizontal, DesignSystem.Spacing.large)

            // Urgency Message
            VStack(spacing: DesignSystem.Spacing.small) {
                Text("Your anxiety doesn't wait.")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.textDark)

                Text("Get relief in the next 2 minutes")
                    .font(.system(size: 14))
                    .foregroundColor(.textMedium)

                // Wave animation
                WaveAnimationView()
                    .frame(height: 40)
                    .padding(.top, DesignSystem.Spacing.xs)
            }
            .padding(.top, DesignSystem.Spacing.large)
            .padding(.bottom, 140) // Add padding to prevent content from being hidden behind sticky CTA
                }
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0xE8/255, green: 0xDB/255, blue: 0xFF/255), // Deeper purple
                        Color(red: 0xF5/255, green: 0xF0/255, blue: 0xFF/255)  // Light purple
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )

            // Sticky CTA at bottom
            VStack(spacing: 0) {
                // Wave gradient fade to distinguish from content
                ZStack(alignment: .bottom) {
                    // Multi-step gradient for smoother wave effect
                    LinearGradient(
                        colors: [
                            Color(red: 0xF5/255, green: 0xF0/255, blue: 0xFF/255).opacity(0),
                            Color(red: 0xF5/255, green: 0xF0/255, blue: 0xFF/255).opacity(0.3),
                            Color(red: 0xF5/255, green: 0xF0/255, blue: 0xFF/255).opacity(0.7),
                            Color(red: 0xF5/255, green: 0xF0/255, blue: 0xFF/255)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .frame(height: 50)

                // CTA Section
                VStack(spacing: DesignSystem.Spacing.small) {
                    OnboardingButton(title: "Get unlimited access now", action: onContinue)
                        .padding(.horizontal, DesignSystem.Spacing.medium)

                    LegalLinksText()
                        .padding(.horizontal, DesignSystem.Spacing.large)
                }
                .padding(.top, DesignSystem.Spacing.xs)
                .padding(.bottom, DesignSystem.Spacing.small)
                .background(
                    Color(red: 0xF5/255, green: 0xF0/255, blue: 0xFF/255)
                )
            }
        }
    }

    // MARK: - Toolkit Card
    private func toolkitCard(title: String, icon: String, isLocked: Bool) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .frame(width: 100, height: 120)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)

                VStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 32))
                        .foregroundColor(isLocked ? .textLight : .primaryPurple)

                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.textLight)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.success)
                    }
                }
            }

            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.textDark)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 100, height: 32)
        }
    }

    // MARK: - Guarantee Badge
    private func guaranteeBadge(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.primaryPurple)

            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.textDark)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.small)
        .background(Color.white)
        .cornerRadius(DesignSystem.CornerRadius.small)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .stroke(Color.borderGray, lineWidth: 1)
        )
    }

    // MARK: - Benefit Row
    private func benefitRow(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.small) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textDark)
                    .fixedSize(horizontal: false, vertical: true)

                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.textMedium)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Wave Animation View
struct WaveAnimationView: View {
    @State private var waveOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Multiple wave layers for depth
            OnboardingWaveShape(offset: waveOffset, amplitude: 8)
                .stroke(
                    LinearGradient(
                        colors: [Color.primaryPurple.opacity(0.4), Color.primaryPurple.opacity(0.2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )

            OnboardingWaveShape(offset: waveOffset + 50, amplitude: 6)
                .stroke(
                    LinearGradient(
                        colors: [Color.primaryPurple.opacity(0.3), Color.primaryPurple.opacity(0.15)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                waveOffset = 400
            }
        }
    }
}

struct OnboardingWaveShape: Shape {
    var offset: CGFloat
    var amplitude: CGFloat

    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height / 2

        path.move(to: CGPoint(x: 0, y: midHeight))

        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let sine = sin((relativeX + offset / width) * 4 * .pi)
            let y = midHeight + sine * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }

        return path
    }
}

// MARK: - Legal Links Text
struct LegalLinksText: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("By continuing, you agree to our")
                .font(DesignSystem.Typography.helperText)
                .foregroundColor(.textLight)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 4) {
                Button(action: {
                    if let url = URL(string: "https://nuvin.app/terms") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Terms")
                        .font(DesignSystem.Typography.helperText)
                        .foregroundColor(.primaryPurple)
                        .underline()
                }
                .buttonStyle(.plain)

                Text("and")
                    .font(DesignSystem.Typography.helperText)
                    .foregroundColor(.textLight)

                Button(action: {
                    if let url = URL(string: "https://nuvin.app/privacy") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Privacy Policy")
                        .font(DesignSystem.Typography.helperText)
                        .foregroundColor(.primaryPurple)
                        .underline()
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    let profile: UserProfile = {
        var p = UserProfile()
        p.name = "Sarah"
        p.anxietyBefore = 8
        p.anxietyAfter = 4
        p.chosenTechnique = .breathing
        return p
    }()

    return OnboardingOfferPageView(
        userName: "Sarah",
        userProfile: profile,
        onContinue: {}
    )
}
