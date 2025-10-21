    //
//  ReframeStressView.swift
//  anxietyapp
//
//  Created by Claude Code on 30/09/2025.
//

import SwiftUI

struct ReframeStressView: View {
    @Environment(\.isDarkMode) var isDarkMode
    let navigateToDashboard: () -> Void
    @State private var hasStarted = false
    @State private var currentCardIndex = 0
    @State private var showingReframe = false
    @State private var showingSummary = false
    @State private var offset: CGSize = .zero
    @State private var dragAmount: CGFloat = 0
    @Environment(\.dismiss) private var dismiss

    private let reframeCards = ReframeCard.allCards

    var body: some View {
        VStack(spacing: 0) {
            // Header with close button
            headerSection
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .padding(.top, DesignSystem.Spacing.small)
                .padding(.bottom, DesignSystem.Spacing.small)

            // Main content area
            if !hasStarted && !showingSummary {
                Spacer()
                beginSection
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                Spacer()
            } else if hasStarted && !showingSummary {
                Spacer()
                cardSection
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    .padding(.bottom, DesignSystem.Spacing.medium)
                navigationSection
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .gradientBackground(AppGradient.adaptiveBackground(isDark: isDarkMode))
        .navigationBarHidden(true)
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    // Swipe from left edge to go back
                    if gesture.startLocation.x < 50 && gesture.translation.width > 100 {
                        HapticManager.shared.impact(.light)
                        dismiss()
                    }
                }
        )
        .sheet(isPresented: $showingSummary) {
            ReliefSummaryView(
                completedTechnique: "Reframe Stress",
                onTryAnother: {
                    dismiss()
                },
                onFinish: {
                    showingSummary = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismiss()
                    }
                },
                navigateToDashboard: navigateToDashboard
            )
            .interactiveDismissDisabled()
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Button(action: {
                HapticManager.shared.impact(.light)
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
            }

            Spacer()
        }
    }

    private var beginSection: some View {
        VStack(spacing: 32) {
            Text("Reframe anxious\nthoughts")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text("10 common anxious thoughts • 1-2 minutes")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                .multilineTextAlignment(.center)

            // Illustration
            reframeIllustration

            // Explanation text
            Text("Learn to catch and reframe unhelpful thinking patterns.")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            // Begin button
            Button(action: {
                HapticManager.shared.impact(.medium)
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    hasStarted = true
                }
            }) {
                HStack(spacing: 12) {
                    Text("Begin")
                        .font(.system(size: 17, weight: .bold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.primaryPurple)
                )
            }
            .padding(.top, 8)
        }
    }

    private var reframeIllustration: some View {
        ZStack {
            // Two overlapping cards showing before/after
            HStack(spacing: -60) {
                // Anxious thought card (left, tilted)
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color.red.opacity(isDarkMode ? 0.9 : 0.7))

                    Text("Anxious\nThought")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                        .multilineTextAlignment(.center)
                }
                .frame(width: 120, height: 140)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.red.opacity(isDarkMode ? 0.2 : 0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red.opacity(isDarkMode ? 0.4 : 0.3), lineWidth: 2)
                        )
                )
                .rotationEffect(.degrees(-8))
                .shadow(color: Color.black.opacity(isDarkMode ? 0.3 : 0.1), radius: 8, x: -4, y: 4)

                // Arrow
                Image(systemName: "arrow.right")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.softViolet)
                    .zIndex(1)

                // Reframed thought card (right, tilted)
                VStack(spacing: 12) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 28))
                        .foregroundColor(Color(red: 0.55, green: 0.70, blue: 0.95))

                    Text("Healthier\nPerspective")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                        .multilineTextAlignment(.center)
                }
                .frame(width: 120, height: 140)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.55, green: 0.70, blue: 0.95).opacity(isDarkMode ? 0.25 : 0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 0.55, green: 0.70, blue: 0.95).opacity(isDarkMode ? 0.5 : 1.0), lineWidth: 2)
                        )
                )
                .rotationEffect(.degrees(8))
                .shadow(color: Color.black.opacity(isDarkMode ? 0.3 : 0.1), radius: 8, x: 4, y: 4)
            }
        }
        .frame(height: 180)
    }

    private var cardSection: some View {
        VStack(spacing: 0) {
            // Instructions
            Text(showingReframe ? "Swipe to continue" : "Tap the card to see a healthier perspective")
                .font(DesignSystem.Typography.bodyFallback)
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                .multilineTextAlignment(.center)
                .padding(.bottom, DesignSystem.Spacing.large)

            // Card with swipe indicators
            if currentCardIndex < reframeCards.count {
                ZStack {
                    ReframeCardView(
                        card: reframeCards[currentCardIndex],
                        isFlipped: showingReframe,
                        isDarkMode: isDarkMode
                    )
                    .onTapGesture {
                        HapticManager.shared.impact(.medium)
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showingReframe.toggle()
                        }
                    }
                    .rotation3DEffect(
                        .degrees(showingReframe ? 180 : 0),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .transition(.scale)
                    .offset(x: dragAmount)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragAmount = value.translation.width
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 50

                                if value.translation.width < -threshold {
                                    // Swipe left - go to next
                                    if currentCardIndex < reframeCards.count - 1 {
                                        HapticManager.shared.impact(.medium)
                                        withAnimation(.easeInOut) {
                                            showingReframe = false
                                            currentCardIndex += 1
                                            dragAmount = 0
                                        }
                                    } else {
                                        // Last card - show completion
                                        HapticManager.shared.impact(.medium)
                                        showingSummary = true
                                    }
                                } else if value.translation.width > threshold {
                                    // Swipe right - go to previous
                                    if currentCardIndex > 0 {
                                        HapticManager.shared.impact(.medium)
                                        withAnimation(.easeInOut) {
                                            showingReframe = false
                                            currentCardIndex -= 1
                                            dragAmount = 0
                                        }
                                    } else {
                                        withAnimation(.spring()) {
                                            dragAmount = 0
                                        }
                                    }
                                } else {
                                    // Not enough swipe, bounce back
                                    withAnimation(.spring()) {
                                        dragAmount = 0
                                    }
                                }
                            }
                    )

                    // Swipe indicators (only show when card is flipped)
                    if showingReframe {
                        HStack {
                            // Left chevron (previous)
                            if currentCardIndex > 0 {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Color.white.opacity(0.4))
                                    .padding(.leading, 20)
                            }

                            Spacer()

                            // Right chevron (next)
                            if currentCardIndex < reframeCards.count - 1 {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Color.white.opacity(0.4))
                                    .padding(.trailing, 20)
                            } else {
                                // Show checkmark on last card
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Color.white.opacity(0.4))
                                    .padding(.trailing, 20)
                            }
                        }
                        .transition(.opacity)
                    }
                }
            }

        }
    }

    private var navigationSection: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            // Progress indicator with navigation buttons
            HStack(spacing: 16) {
                // Previous button
                Button(action: {
                    if currentCardIndex > 0 {
                        HapticManager.shared.impact(.medium)
                        withAnimation(.easeInOut) {
                            showingReframe = false
                            currentCardIndex -= 1
                        }
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(currentCardIndex > 0 ? Color.adaptiveText(isDark: isDarkMode) : Color.adaptiveSecondaryText(isDark: isDarkMode).opacity(0.3))
                        .frame(width: 32, height: 32)
                }
                .disabled(currentCardIndex == 0)

                // Progress indicator
                Text("\(currentCardIndex + 1) of \(reframeCards.count)")
                    .font(DesignSystem.Typography.captionFallback)
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                    .frame(minWidth: 60)

                // Next button
                Button(action: {
                    if currentCardIndex < reframeCards.count - 1 {
                        HapticManager.shared.impact(.medium)
                        withAnimation(.easeInOut) {
                            showingReframe = false
                            currentCardIndex += 1
                        }
                    } else {
                        // Last card - show completion
                        HapticManager.shared.impact(.medium)
                        showingSummary = true
                    }
                }) {
                    Image(systemName: currentCardIndex < reframeCards.count - 1 ? "chevron.right" : "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                        .frame(width: 32, height: 32)
                }
            }

            // Progress dots
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(0..<reframeCards.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentCardIndex ? Color.primaryPurple : Color.primaryPurple.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: currentCardIndex)
                }
            }
            .padding(.top, 6)

            // Skip button
            Button(action: {
                HapticManager.shared.impact(.soft)
                showingSummary = true
            }) {
                Text("Skip")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
            }
            .padding(.top, DesignSystem.Spacing.medium)
        }
        .padding(.bottom, 80)
    }
}

// MARK: - Reframe Card Model

struct ReframeCard: Identifiable {
    let id = UUID()
    let anxiousThought: String
    let reframedThought: String

    static let allCards = [
        ReframeCard(
            anxiousThought: "I can't handle this.",
            reframedThought: "I've handled hard things before — I can handle this step by step."
        ),
        ReframeCard(
            anxiousThought: "Something bad is going to happen.",
            reframedThought: "I don't know the future — it could also turn out fine, or even better than I expect."
        ),
        ReframeCard(
            anxiousThought: "Everyone is judging me.",
            reframedThought: "Most people are focused on themselves — I'm not under a spotlight."
        ),
        ReframeCard(
            anxiousThought: "I'm not good enough.",
            reframedThought: "I don't need to be perfect — I'm learning and growing every day."
        ),
        ReframeCard(
            anxiousThought: "If I make a mistake, it's over.",
            reframedThought: "Mistakes are part of progress — they help me improve."
        ),
        ReframeCard(
            anxiousThought: "I don't have time.",
            reframedThought: "I can prioritize what matters most right now and take one thing at a time."
        ),
        ReframeCard(
            anxiousThought: "I'll embarrass myself.",
            reframedThought: "Even if it's not perfect, people respect effort and courage."
        ),
        ReframeCard(
            anxiousThought: "It's always going to be this way.",
            reframedThought: "This feeling will pass — nothing stays forever."
        ),
        ReframeCard(
            anxiousThought: "I have no control.",
            reframedThought: "I can't control everything, but I can control my response."
        ),
        ReframeCard(
            anxiousThought: "I'm failing compared to others.",
            reframedThought: "Everyone has their own timeline — I'm exactly where I need to be."
        )
    ]
}

// MARK: - Reframe Card View

struct ReframeCardView: View {
    let card: ReframeCard
    let isFlipped: Bool
    let isDarkMode: Bool

    var body: some View {
        ZStack {
            // Back side (reframed thought)
            cardSide(
                icon: "arrow.triangle.2.circlepath",
                title: "Reframed",
                content: card.reframedThought,
                backgroundColor: Color(red: 0.55, green: 0.70, blue: 0.95).opacity(isDarkMode ? 0.25 : 0.15),
                accentColor: Color(red: 0.55, green: 0.70, blue: 0.95)
            )
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            .opacity(isFlipped ? 1 : 0)

            // Front side (anxious thought)
            cardSide(
                icon: "exclamationmark.triangle.fill",
                title: "Anxious Thought",
                content: card.anxiousThought,
                backgroundColor: Color.red.opacity(isDarkMode ? 0.2 : 0.1),
                accentColor: Color.red.opacity(isDarkMode ? 0.9 : 0.7)
            )
            .opacity(isFlipped ? 0 : 1)
        }
    }

    private func cardSide(icon: String, title: String, content: String, backgroundColor: Color, accentColor: Color) -> some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(accentColor)

            // Title
            Text(title)
                .font(DesignSystem.Typography.captionFallback)
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                .fontWeight(.semibold)
                .textCase(.uppercase)
                .tracking(1)

            // Content
            Text(content)
                .font(DesignSystem.Typography.titleFallback)
                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, DesignSystem.Spacing.medium)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 280, maxHeight: 320)
        .padding(DesignSystem.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(accentColor.opacity(isDarkMode ? 0.4 : 0.3), lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(isDarkMode ? 0.3 : 0.1), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    ReframeStressView(navigateToDashboard: {})
}
