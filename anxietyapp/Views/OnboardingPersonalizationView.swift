//
//  OnboardingPersonalizationView.swift
//  anxietyapp
//
//  Created by Claude Code
//

import SwiftUI

struct OnboardingPersonalizationView: View {
    let userProfile: UserProfile
    let onContinue: () -> Void

    @State private var loadingProgress: Double = 0
    @State private var showResults = false

    // Calculate anxiety percentage based on user responses
    private var anxietyPercentage: Int {
        // Base score from anxiety level (0-10 scale * 10 = 0-100%)
        var score = userProfile.stressBaseline * 10

        // Add 6% for each stress cause
        score += userProfile.stressCauses.count * 6

        // Add bonus based on life satisfaction
        if let lifeSatisfaction = userProfile.lifeSatisfaction {
            switch lifeSatisfaction {
            case .verySatisfied:
                score += 0
            case .satisfied:
                score += 3
            case .neutral:
                score += 8
            case .dissatisfied:
                score += 13
            case .veryDissatisfied:
                score += 18
            }
        }

        // Cap at 97% max
        return min(score, 97)
    }

    var body: some View {
        ZStack {
            if !showResults {
                // Dark purple gradient background for loading only
                LinearGradient(
                    colors: [
                        Color(red: 0.25, green: 0.15, blue: 0.35),
                        Color(red: 0.18, green: 0.10, blue: 0.28)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                loadingView
            } else {
                resultsView
                    .gradientBackground()
            }
        }
        .onAppear {
            startLoadingAnimation()
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            Spacer()

            // Animated circle loader
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 8)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: loadingProgress)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                Text("\(Int(loadingProgress * 100))%")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }

            Text("Analyzing your answers...")
                .font(DesignSystem.Typography.questionTitle)
                .foregroundColor(.white)

            Spacer()
        }
        .padding(DesignSystem.Spacing.medium)
    }

    // MARK: - Results View
    private var resultsView: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.medium) {
                    // Header
                    VStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: min(40, geometry.size.width * 0.1)))
                            .foregroundColor(.success)

                        Text("Analysis Complete")
                            .font(.system(size: min(24, geometry.size.width * 0.06), weight: .bold))
                            .foregroundColor(.textDark)
                            .minimumScaleFactor(0.8)
                            .lineLimit(1)
                    }
                    .padding(.top, DesignSystem.Spacing.medium)

                    // Graph visualization
                    anxietyComparisonGraph(maxHeight: min(180, geometry.size.height * 0.25))

                    // Reassurance message
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.primaryPurple)
                            Text("\(userProfile.name.isEmpty ? "You're" : userProfile.name + ", you're") not alone")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.textDark)
                                .minimumScaleFactor(0.8)
                                .lineLimit(1)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Many people your age experience similar anxiety levels. Small daily practices can help you feel calmer and more in control.")
                                .font(.system(size: 14))
                                .foregroundColor(.textLight)
                                .fixedSize(horizontal: false, vertical: true)

                            HStack(spacing: 4) {
                                Text("Sources:")
                                    .font(.system(size: 10))
                                    .foregroundColor(.textLight.opacity(0.8))

                                Button(action: {
                                    if let url = URL(string: "https://www.nimh.nih.gov/health/statistics/any-anxiety-disorder") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    Text("NIMH")
                                        .font(.system(size: 10))
                                        .foregroundColor(.primaryPurple)
                                        .underline()
                                }

                                Text("•")
                                    .font(.system(size: 10))
                                    .foregroundColor(.textLight.opacity(0.8))

                                Button(action: {
                                    if let url = URL(string: "https://adaa.org/understanding-anxiety") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    Text("ADAA")
                                        .font(.system(size: 10))
                                        .foregroundColor(.primaryPurple)
                                        .underline()
                                }
                            }
                        }
                    }
                    .padding(DesignSystem.Spacing.small)
                    .background(Color.secondaryViolet)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                    .padding(.horizontal, DesignSystem.Spacing.medium)

                    // Continue button
                    OnboardingButton(title: "Let's lower this anxiety", action: onContinue)
                        .padding(.horizontal, DesignSystem.Spacing.medium)
                        .padding(.bottom, DesignSystem.Spacing.medium)
                }
            }
        }
    }

    // MARK: - Anxiety Comparison Graph
    private func anxietyComparisonGraph(maxHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text("Your Anxiety Level vs Average")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .minimumScaleFactor(0.8)
                .lineLimit(1)

            HStack(alignment: .bottom, spacing: 32) {
                // Your score
                barView(
                    percentage: anxietyPercentage,
                    label: "You",
                    color: .emergencyRed,
                    maxHeight: maxHeight
                )

                // Average population
                barView(
                    percentage: 30,
                    label: "Average",
                    color: .success,
                    maxHeight: maxHeight
                )
            }
            .frame(maxWidth: .infinity)
            .frame(height: maxHeight + 40)

            // Anxiety level display with disclaimer and citations
            VStack(spacing: 6) {
                Text("\(anxietyPercentage)% anxiety level")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)

                Text("This result is an indication only, not a medical diagnosis.")
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: {
                    if let url = URL(string: "https://www.nimh.nih.gov/health/topics/anxiety-disorders") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Learn more about anxiety")
                        .font(.system(size: 9))
                        .foregroundColor(.white)
                        .underline()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, DesignSystem.Spacing.xs)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.25, green: 0.15, blue: 0.35),
                    Color(red: 0.18, green: 0.10, blue: 0.28)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .padding(.horizontal, DesignSystem.Spacing.medium)
    }

    private func barView(percentage: Int, label: String, color: Color, maxHeight: CGFloat) -> some View {
        VStack(spacing: 8) {
            VStack {
                Spacer(minLength: 0)

                VStack(spacing: 4) {
                    Text("\(percentage)%")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)

                    Spacer(minLength: 0)
                }
                .frame(width: 70)
                .frame(height: max(maxHeight * CGFloat(percentage) / 100.0, 40))
                .background(color)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 12,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 12
                    )
                )
            }
            .frame(height: maxHeight)

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Animation Logic
    private func startLoadingAnimation() {
        let totalDuration: Double = 3.5
        let totalSteps: Int = 100
        let intervalDuration = totalDuration / Double(totalSteps)

        var currentStep = 0

        Timer.scheduledTimer(withTimeInterval: intervalDuration, repeats: true) { timer in
            currentStep += 1

            withAnimation(.linear(duration: intervalDuration * 0.8)) {
                loadingProgress = Double(currentStep) / Double(totalSteps)
            }

            if currentStep >= totalSteps {
                timer.invalidate()

                // Show results after reaching 100%
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation {
                        showResults = true
                    }
                }
            }
        }
    }
}

#Preview {
    let profile: UserProfile = {
        var p = UserProfile()
        p.name = "Sarah"
        p.stressBaseline = 7
        return p
    }()

    return OnboardingPersonalizationView(
        userProfile: profile,
        onContinue: {}
    )
}
