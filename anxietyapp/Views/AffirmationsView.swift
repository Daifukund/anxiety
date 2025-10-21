//
//  AffirmationsView.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import SwiftUI

struct AffirmationsView: View {
    @Environment(\.isDarkMode) var isDarkMode
    @State private var currentAffirmationIndex = 0
    @State private var swipeOffset: CGSize = .zero
    @State private var likedAffirmations: Set<Int> = []
    @State private var seenIndices: Set<Int> = []
    @State private var shuffledIndices: [Int] = []
    @State private var showSwipeHint = false

    // All 50 affirmations organized by category
    private let affirmations = [
        // Calm & Presence 🌱 (10)
        Affirmation(id: 0, text: "I am safe in this moment.", category: .calmPresence),
        Affirmation(id: 1, text: "My breath anchors me to peace.", category: .calmPresence),
        Affirmation(id: 2, text: "I release what I cannot control.", category: .calmPresence),
        Affirmation(id: 3, text: "I choose calm over chaos.", category: .calmPresence),
        Affirmation(id: 4, text: "Each breath softens my body and mind.", category: .calmPresence),
        Affirmation(id: 5, text: "I am grounded and centered.", category: .calmPresence),
        Affirmation(id: 6, text: "Peace flows through me now.", category: .calmPresence),
        Affirmation(id: 7, text: "I slow down and trust the present.", category: .calmPresence),
        Affirmation(id: 8, text: "Stillness is my strength.", category: .calmPresence),
        Affirmation(id: 9, text: "I welcome serenity into my life.", category: .calmPresence),

        // Confidence & Courage 💪 (10)
        Affirmation(id: 10, text: "I believe in my abilities.", category: .confidenceCourage),
        Affirmation(id: 11, text: "I face challenges with strength.", category: .confidenceCourage),
        Affirmation(id: 12, text: "I am worthy of success and joy.", category: .confidenceCourage),
        Affirmation(id: 13, text: "My voice matters and deserves to be heard.", category: .confidenceCourage),
        Affirmation(id: 14, text: "I step forward with courage.", category: .confidenceCourage),
        Affirmation(id: 15, text: "I trust my decisions.", category: .confidenceCourage),
        Affirmation(id: 16, text: "I have everything I need within me.", category: .confidenceCourage),
        Affirmation(id: 17, text: "I radiate confidence and self-respect.", category: .confidenceCourage),
        Affirmation(id: 18, text: "I can handle whatever comes my way.", category: .confidenceCourage),
        Affirmation(id: 19, text: "I choose boldness over fear.", category: .confidenceCourage),

        // Growth & Resilience 🌿 (10)
        Affirmation(id: 20, text: "Every setback is a setup for growth.", category: .growthResilience),
        Affirmation(id: 21, text: "I learn and improve every day.", category: .growthResilience),
        Affirmation(id: 22, text: "I adapt and thrive in all situations.", category: .growthResilience),
        Affirmation(id: 23, text: "My challenges help me become stronger.", category: .growthResilience),
        Affirmation(id: 24, text: "I rise after every fall.", category: .growthResilience),
        Affirmation(id: 25, text: "I embrace change with openness.", category: .growthResilience),
        Affirmation(id: 26, text: "I grow through what I go through.", category: .growthResilience),
        Affirmation(id: 27, text: "My resilience is limitless.", category: .growthResilience),
        Affirmation(id: 28, text: "I welcome progress, not perfection.", category: .growthResilience),
        Affirmation(id: 29, text: "I trust the process of becoming.", category: .growthResilience),

        // Self-Love & Compassion ❤️ (10)
        Affirmation(id: 30, text: "I am enough just as I am.", category: .selfLoveCompassion),
        Affirmation(id: 31, text: "I treat myself with kindness today.", category: .selfLoveCompassion),
        Affirmation(id: 32, text: "I forgive myself and release guilt.", category: .selfLoveCompassion),
        Affirmation(id: 33, text: "I listen to my needs with love.", category: .selfLoveCompassion),
        Affirmation(id: 34, text: "I deserve rest and care.", category: .selfLoveCompassion),
        Affirmation(id: 35, text: "My flaws make me human and whole.", category: .selfLoveCompassion),
        Affirmation(id: 36, text: "I honor my journey at my own pace.", category: .selfLoveCompassion),
        Affirmation(id: 37, text: "I love myself unconditionally.", category: .selfLoveCompassion),
        Affirmation(id: 38, text: "I offer myself patience and understanding.", category: .selfLoveCompassion),
        Affirmation(id: 39, text: "I celebrate who I am becoming.", category: .selfLoveCompassion),

        // Gratitude & Positivity 🌞 (10)
        Affirmation(id: 40, text: "I am grateful for this moment.", category: .gratitudePositivity),
        Affirmation(id: 41, text: "Abundance flows into my life.", category: .gratitudePositivity),
        Affirmation(id: 42, text: "I notice beauty in the small things.", category: .gratitudePositivity),
        Affirmation(id: 43, text: "I attract joy and light.", category: .gratitudePositivity),
        Affirmation(id: 44, text: "I am thankful for the lessons of today.", category: .gratitudePositivity),
        Affirmation(id: 45, text: "Positivity guides my thoughts and actions.", category: .gratitudePositivity),
        Affirmation(id: 46, text: "I focus on what I can appreciate.", category: .gratitudePositivity),
        Affirmation(id: 47, text: "I choose joy in this moment.", category: .gratitudePositivity),
        Affirmation(id: 48, text: "Gratitude fills my heart with peace.", category: .gratitudePositivity),
        Affirmation(id: 49, text: "I welcome happiness into my life.", category: .gratitudePositivity)
    ]

    init() {
        loadLikedAffirmations()
    }

    var body: some View {
        ZStack {
            // Background gradient that fills entire screen
            AppGradient.adaptiveBackground(isDark: isDarkMode)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                    .padding(.top, 16)
                    .padding(.horizontal, 24)

                Spacer()
                    .frame(height: 40)

                // Main affirmation card
                affirmationCard
                    .padding(.horizontal, 24)

                // Swipe hint for first-time users
                if showSwipeHint {
                    swipeHintView
                        .padding(.top, 24)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }

                Spacer()
                    .frame(height: 56)
            }
        }
        .onAppear {
            if shuffledIndices.isEmpty {
                // First time initialization
                initializeShuffledIndices()
            } else {
                // Show a fresh affirmation each time user navigates here
                shuffleToNext()
            }
            checkAndShowSwipeHint()
        }
    }

    private var headerSection: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Affirmations")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

            Text("Gentle reminders to bring you back to calm")
                .font(.system(size: 15))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var affirmationCard: some View {
        let currentAffirmation = affirmations[currentAffirmationIndex]
        let isLiked = likedAffirmations.contains(currentAffirmation.id)

        return ZStack {
            // Card background with gradient
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: isDarkMode ? [
                            Color.adaptiveSecondaryBackground(isDark: isDarkMode).opacity(0.95),
                            Color.adaptiveSecondaryBackground(isDark: isDarkMode).opacity(0.85)
                        ] : [
                            Color.white.opacity(0.95),
                            Color.white.opacity(0.85)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(isDarkMode ? 0.4 : 0.08), radius: 20, x: 0, y: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.adaptiveSecondaryBackground(isDark: isDarkMode).opacity(isDarkMode ? 0.3 : 0.5), lineWidth: 1)
                )

            VStack(spacing: 24) {
                // Category icon with animated glow
                ZStack {
                    Circle()
                        .fill(currentAffirmation.category.color.opacity(isDarkMode ? 0.25 : 0.15))
                        .frame(width: 80, height: 80)

                    Image(systemName: currentAffirmation.category.icon)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(currentAffirmation.category.color)
                }

                // Affirmation text - larger and more prominent
                Text(currentAffirmation.text)
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 28)
                    .minimumScaleFactor(0.8)

                // Category label - subtle badge
                Text(currentAffirmation.category.displayName.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(currentAffirmation.category.color)
                    .tracking(1.2)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(currentAffirmation.category.color.opacity(isDarkMode ? 0.22 : 0.12))
                    )
            }
            .padding(32)

            // Action buttons overlay - top corners
            VStack {
                HStack {
                    // Share button (top-left)
                    Button(action: {
                        shareAffirmation(currentAffirmation)
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(Color.adaptiveBackground(isDark: isDarkMode).opacity(0.9))
                                    .shadow(color: Color.black.opacity(isDarkMode ? 0.5 : 0.1), radius: 8, x: 0, y: 4)
                            )
                    }

                    Spacer()

                    // Like button (top-right)
                    Button(action: {
                        toggleLike(for: currentAffirmation.id)
                    }) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(isLiked ? .red : Color.adaptiveSecondaryText(isDark: isDarkMode))
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(Color.adaptiveBackground(isDark: isDarkMode).opacity(0.9))
                                    .shadow(color: Color.black.opacity(isDarkMode ? 0.5 : 0.1), radius: 8, x: 0, y: 4)
                            )
                            .scaleEffect(isLiked ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isLiked)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Spacer()
            }
        }
        .frame(height: 360)
        .offset(swipeOffset)
        .rotation3DEffect(
            .degrees(swipeOffset.width / 25.0),
            axis: (x: 0, y: 1, z: 0)
        )
        .scaleEffect(1 - abs(swipeOffset.width) / 2000.0)
        .opacity(1 - abs(swipeOffset.width) / 500.0)
        .gesture(
            DragGesture()
                .onChanged { value in
                    swipeOffset = value.translation
                }
                .onEnded { value in
                    // Hide hint on first swipe
                    if showSwipeHint {
                        withAnimation {
                            showSwipeHint = false
                        }
                        UserDefaults.standard.set(true, forKey: "hasSeenAffirmationSwipeHint")
                    }

                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        if abs(value.translation.width) > 100 {
                            // Swipe detected - show next affirmation
                            HapticManager.shared.impact(.medium)
                            nextAffirmation()
                        }
                        swipeOffset = .zero
                    }
                }
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: swipeOffset)
        .transition(.scale.combined(with: .opacity))
        .id(currentAffirmation.id)
    }

    private var swipeHintView: some View {
        HStack(spacing: 8) {
            Image(systemName: "chevron.left")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode).opacity(0.6))

            Text("Swipe to explore")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode).opacity(0.7))

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode).opacity(0.6))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.adaptiveBackground(isDark: isDarkMode).opacity(0.6))
                .shadow(color: Color.black.opacity(isDarkMode ? 0.5 : 0.05), radius: 8, x: 0, y: 4)
        )
    }

    // MARK: - Navigation Functions
    private func nextAffirmation() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            shuffleToNext()
        }
    }

    // MARK: - Smart Randomization
    private func initializeShuffledIndices() {
        guard !affirmations.isEmpty else { return }
        shuffledIndices = Array(0..<affirmations.count).shuffled()
        currentAffirmationIndex = shuffledIndices[0]
        seenIndices.removeAll()
        markAsSeen(affirmations[currentAffirmationIndex].id)
    }

    private func shuffleToNext() {
        guard !affirmations.isEmpty else { return }

        // If we've seen all affirmations, reset and reshuffle
        if seenIndices.count >= affirmations.count {
            seenIndices.removeAll()
            shuffledIndices = Array(0..<affirmations.count).shuffled()
        }

        // Find next unseen affirmation
        let unseenIndices = shuffledIndices.filter { !seenIndices.contains(affirmations[$0].id) }

        if let nextShuffledIndex = unseenIndices.first {
            currentAffirmationIndex = nextShuffledIndex
            markAsSeen(affirmations[nextShuffledIndex].id)
        } else {
            // Fallback to random
            currentAffirmationIndex = Int.random(in: 0..<affirmations.count)
            markAsSeen(affirmations[currentAffirmationIndex].id)
        }
    }

    private func markAsSeen(_ id: Int) {
        seenIndices.insert(id)
    }

    // MARK: - Like/Favorite Functions
    private func toggleLike(for id: Int) {
        HapticManager.shared.impact(.medium)

        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            if likedAffirmations.contains(id) {
                likedAffirmations.remove(id)
            } else {
                likedAffirmations.insert(id)
            }
            saveLikedAffirmations()
        }
    }

    private func loadLikedAffirmations() {
        if let data = UserDefaults.standard.array(forKey: "likedAffirmations") as? [Int] {
            likedAffirmations = Set(data)
        }
    }

    private func saveLikedAffirmations() {
        UserDefaults.standard.set(Array(likedAffirmations), forKey: "likedAffirmations")
    }

    // MARK: - Share Function
    private func shareAffirmation(_ affirmation: Affirmation) {
        HapticManager.shared.impact(.light)

        let shareText = "\"\(affirmation.text)\"\n\n✨ From Nuvin - Your anxiety relief companion"

        let activityViewController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            activityViewController.popoverPresentationController?.sourceView = rootViewController.view
            rootViewController.present(activityViewController, animated: true)
        }
    }

    // MARK: - Swipe Hint
    private func checkAndShowSwipeHint() {
        let hasSeenHint = UserDefaults.standard.bool(forKey: "hasSeenAffirmationSwipeHint")

        if !hasSeenHint {
            // Show hint with a slight delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showSwipeHint = true
                }

                // Auto-hide after 4 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showSwipeHint = false
                    }
                }
            }
        }
    }
}

struct Affirmation: Identifiable {
    let id: Int
    let text: String
    let category: AffirmationCategory
}

enum AffirmationCategory {
    case calmPresence
    case confidenceCourage
    case growthResilience
    case selfLoveCompassion
    case gratitudePositivity

    var displayName: String {
        switch self {
        case .calmPresence:
            return "Calm & Presence"
        case .confidenceCourage:
            return "Confidence & Courage"
        case .growthResilience:
            return "Growth & Resilience"
        case .selfLoveCompassion:
            return "Self-Love & Compassion"
        case .gratitudePositivity:
            return "Gratitude & Positivity"
        }
    }

    var color: Color {
        switch self {
        case .calmPresence:
            return Color(red: 0.45, green: 0.80, blue: 0.55) // 🌱 Green
        case .confidenceCourage:
            return Color(red: 0.95, green: 0.55, blue: 0.35) // 💪 Orange
        case .growthResilience:
            return Color(red: 0.40, green: 0.70, blue: 0.40) // 🌿 Forest green
        case .selfLoveCompassion:
            return Color(red: 0.95, green: 0.45, blue: 0.55) // ❤️ Pink/Red
        case .gratitudePositivity:
            return Color(red: 1.0, green: 0.75, blue: 0.30) // 🌞 Yellow/Gold
        }
    }

    var icon: String {
        switch self {
        case .calmPresence:
            return "leaf.fill"
        case .confidenceCourage:
            return "bolt.fill"
        case .growthResilience:
            return "arrow.up.right.circle.fill"
        case .selfLoveCompassion:
            return "heart.fill"
        case .gratitudePositivity:
            return "sun.max.fill"
        }
    }
}

#Preview {
    AffirmationsView()
}