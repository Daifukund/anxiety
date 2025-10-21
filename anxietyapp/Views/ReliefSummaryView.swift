//
//  ReliefSummaryView.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import SwiftUI

struct ReliefSummaryView: View {
    @Environment(\.isDarkMode) var isDarkMode
    let completedTechnique: String
    let onTryAnother: () -> Void
    let onFinish: () -> Void
    let navigateToDashboard: () -> Void
    @ObservedObject private var userDataService = UserDataService.shared
    @State private var showCelebration = false
    @State private var particles: [Particle] = []

    struct Particle: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let delay: Double
        let duration: Double
    }

    var body: some View {
        ZStack {
            // Background gradient
            AppGradient.adaptiveBackground(isDark: isDarkMode)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 40) {
                    Spacer()
                        .frame(height: 60)

                    // Success animation and message
                    celebrationSection

                    // Reframe message
                    reframeSection

                    // Action buttons
                    actionSection

                    Spacer()
                        .frame(height: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .onAppear {
            // Record the completed session
            userDataService.recordSession(technique: completedTechnique)

            // Generate particles spreading in all directions
            particles = (0..<20).map { i in
                let angle = (Double(i) / 20.0) * 2 * .pi
                let distance = CGFloat.random(in: 80...150)
                return Particle(
                    x: cos(angle) * distance,
                    y: sin(angle) * distance,
                    delay: Double.random(in: 0...0.3),
                    duration: Double.random(in: 1.5...2.5)
                )
            }

            // Trigger celebration animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                showCelebration = true
            }
        }
    }

    private var celebrationSection: some View {
        VStack(spacing: 24) {
            // Success animation with particles effect
            ZStack {
                // Floating particles
                ForEach(particles) { particle in
                    Circle()
                        .fill(Color.primaryPurple.opacity(0.4))
                        .frame(width: 6, height: 6)
                        .offset(
                            x: showCelebration ? particle.x : 0,
                            y: showCelebration ? particle.y : 0
                        )
                        .opacity(showCelebration ? 0 : 1)
                        .scaleEffect(showCelebration ? 0.5 : 1)
                        .animation(
                            .easeOut(duration: particle.duration)
                            .delay(particle.delay),
                            value: showCelebration
                        )
                }

                // Outer glow rings
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.success.opacity(0.3),
                                    Color.success.opacity(0.0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 120 + CGFloat(index * 20), height: 120 + CGFloat(index * 20))
                        .scaleEffect(showCelebration ? 1.2 : 0.8)
                        .opacity(showCelebration ? 0 : 0.6)
                        .animation(
                            .easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.3),
                            value: showCelebration
                        )
                }

                // Main success icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.success.opacity(0.2),
                                    Color.success.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(Color.success)
                }
                .scaleEffect(showCelebration ? 1.0 : 0.5)
                .opacity(showCelebration ? 1.0 : 0.0)
            }
            .frame(height: 120)

            // Success message
            VStack(spacing: 12) {
                Text("Well Done!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                    .scaleEffect(showCelebration ? 1.0 : 0.8)
                    .opacity(showCelebration ? 1.0 : 0.0)

                Text("You completed \(completedTechnique)")
                    .font(.system(size: 16))
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                    .multilineTextAlignment(.center)
                    .scaleEffect(showCelebration ? 1.0 : 0.8)
                    .opacity(showCelebration ? 1.0 : 0.0)
            }
        }
        .padding(.vertical, 8)
    }

    private var reframeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Icon + Title
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.softViolet.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.softViolet)
                }

                Text("Remember")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                Spacer()
            }

            // Reframe message in beautiful card
            Text("Your body thinks you're in danger, but this is a false alarm. You're safe.")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                .lineSpacing(4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: isDarkMode ? [
                                Color.adaptiveSupportGray(isDark: true).opacity(0.95),
                                Color.adaptiveSupportGray(isDark: true).opacity(0.85)
                            ] : [
                                Color.white.opacity(0.95),
                                Color.white.opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isDarkMode ? Color.white.opacity(0.1) : Color.white.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(isDarkMode ? 0.3 : 0.08), radius: 12, x: 0, y: 6)
        }
    }

    private var actionSection: some View {
        VStack(spacing: 12) {
            // Primary action - Finish and navigate to Dashboard
            Button(action: {
                HapticManager.shared.impact(.medium)

                // Request App Store rating if user is eligible
                // Perfect timing: user just completed exercise and feels better
                RatingService.shared.requestRatingIfEligible()

                onFinish()
                navigateToDashboard()
            }) {
                HStack {
                    Spacer()
                    Text("I'm Feeling Better")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.vertical, 16)
                .background(Color.primaryPurple)
                .cornerRadius(16)
                .shadow(color: Color.primaryPurple.opacity(0.4), radius: 12, x: 0, y: 6)
            }

            // Secondary action - Try another
            Button(action: {
                HapticManager.shared.impact(.light)
                onTryAnother()
            }) {
                HStack {
                    Spacer()
                    Text("Do Another Exercise")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color.primaryPurple)
                    Spacer()
                }
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isDarkMode ? Color.adaptiveSupportGray(isDark: true).opacity(0.7) : Color.white.opacity(0.7))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isDarkMode ? Color.white.opacity(0.1) : Color.white.opacity(0.8), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(isDarkMode ? 0.2 : 0.05), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.top, 8)
    }
}

#Preview {
    ReliefSummaryView(
        completedTechnique: "Breathing Exercise",
        onTryAnother: {},
        onFinish: {},
        navigateToDashboard: {}
    )
}