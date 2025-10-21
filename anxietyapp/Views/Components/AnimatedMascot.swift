//
//  AnimatedMascot.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct AnimatedMascot: View {
    @ObservedObject private var userDataService = UserDataService.shared
    @State private var isFloating = false
    @State private var showingMascotInteraction = false
    @State private var mascotMessage = ""

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.small) {

            // Animated mascot
            Button(action: {
                showMascotInteraction()
            }) {
                ZStack {
                    // Glow effect based on mood
                    Circle()
                        .fill(mascotGlowColor.opacity(0.2))
                        .frame(width: 140, height: 140)
                        .scaleEffect(isFloating ? 1.1 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                            value: isFloating
                        )

                    // Main mascot circle
                    Circle()
                        .fill(mascotPrimaryColor.opacity(0.3))
                        .frame(width: 120, height: 120)

                    // Jellyfish emoji with floating animation
                    Text("🪼")
                        .font(.system(size: 60))
                        .offset(y: isFloating ? -8 : -2)
                        .animation(
                            Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: true),
                            value: isFloating
                        )

                    // Mood indicator particles
                    if let todaysMoodValue = userDataService.getTodaysMoodValue() {
                        let moodColor = Color.moodGradient(for: todaysMoodValue)
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(moodColor.opacity(0.6))
                                .frame(width: 4, height: 4)
                                .offset(
                                    x: CGFloat(cos(Double(index) * 2.0 * .pi / 3.0)) * 70,
                                    y: CGFloat(sin(Double(index) * 2.0 * .pi / 3.0)) * 70
                                )
                                .scaleEffect(isFloating ? 0.8 : 1.2)
                                .animation(
                                    Animation.easeInOut(duration: 2.0)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.3),
                                    value: isFloating
                                )
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())

            // Mascot message
            if !mascotMessage.isEmpty {
                Text(mascotMessage)
                    .font(DesignSystem.Typography.bodyFallback)
                    .foregroundColor(Color.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    .opacity(mascotMessage.isEmpty ? 0 : 1)
                    .animation(.easeInOut, value: mascotMessage.isEmpty)
            } else {
                mascotDefaultMessage
            }
        }
        .onAppear {
            isFloating = true
            updateMascotMessage()
        }
        .onReceive(userDataService.$userStats) { _ in
            updateMascotMessage()
        }
        .alert("Nuvin the Jellyfish", isPresented: $showingMascotInteraction) {
            Button("Thanks!") {}
        } message: {
            Text(getMascotInteractionMessage())
        }
    }

    private var mascotPrimaryColor: Color {
        if let todaysMoodValue = userDataService.getTodaysMoodValue() {
            return Color.moodGradient(for: todaysMoodValue)
        }
        return Color.lightBlue
    }

    private var mascotGlowColor: Color {
        switch userDataService.userStats.currentStreak {
        case 0...2:
            return Color.lightBlue
        case 3...6:
            return Color.softViolet
        case 7...13:
            return Color.success
        default:
            return Color.warning
        }
    }

    private var mascotDefaultMessage: some View {
        Text(getMascotMessage())
            .font(DesignSystem.Typography.bodyFallback)
            .foregroundColor(Color.secondaryText)
            .multilineTextAlignment(.center)
            .padding(.horizontal, DesignSystem.Spacing.medium)
    }

    private func getMascotMessage() -> String {
        if !userDataService.hasCheckedInToday() {
            return "How are you feeling today?"
        }

        guard let todaysMoodValue = userDataService.getTodaysMoodValue() else {
            return "I'm here to support you."
        }

        // 0.0 = very calm, 1.0 = very stressed
        switch todaysMoodValue {
        case 0.0..<0.2:
            return "Your calm energy is beautiful! ✨"
        case 0.2..<0.4:
            return "Peaceful vibes flowing your way."
        case 0.4..<0.6:
            return "Every day is a fresh start."
        case 0.6..<0.8:
            return "Take a deep breath with me."
        case 0.8...1.0:
            return "I'm here with you. You're not alone."
        default:
            return "I'm here to support you."
        }
    }

    private func getMascotInteractionMessage() -> String {
        let streak = userDataService.userStats.currentStreak
        let totalSessions = userDataService.userStats.totalSessions

        if streak == 0 && totalSessions == 0 {
            return "Welcome! I'm Nuvin, your calm companion. I'll float here and change colors based on your mood and progress. Tap that red SOS button whenever you need quick relief!"
        } else if streak == 1 {
            return "Great job starting your journey! I can see your mood today, and I'm here to celebrate every small step with you."
        } else if streak >= 7 {
            return "Wow! Look at that streak! I'm glowing with pride. You've been taking such good care of yourself. Keep it up!"
        } else {
            return "I love seeing your daily check-ins! Each mood you share helps me understand your journey better. Together we're building something beautiful."
        }
    }

    private func showMascotInteraction() {
        showingMascotInteraction = true

        // Celebration haptic for high streaks
        #if os(iOS)
        if userDataService.userStats.currentStreak >= 7 {
            HapticManager.shared.notification(.success)
        } else {
            HapticManager.shared.impact(.light)
        }
        #endif
    }

    private func updateMascotMessage() {
        // Update message based on recent activity or milestones
        let streak = userDataService.userStats.currentStreak

        if streak == 3 {
            mascotMessage = "3 days in a row! I'm starting to glow brighter! 🌟"
        } else if streak == 7 {
            mascotMessage = "One week streak! I'm so proud of you! 🔥"
        } else if streak >= 14 {
            mascotMessage = "You're absolutely crushing it! ⭐️"
        } else {
            mascotMessage = ""
        }

        // Clear message after delay
        if !mascotMessage.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                mascotMessage = ""
            }
        }
    }
}

#Preview {
    AnimatedMascot()
        .padding()
}