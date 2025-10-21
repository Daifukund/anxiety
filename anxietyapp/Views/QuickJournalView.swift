//
//  QuickJournalView.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct QuickJournalView: View {
    let navigateToDashboard: () -> Void
    @State private var journalText = ""
    @State private var timeRemaining = 60
    @State private var isActive = false
    @State private var timer: Timer?
    @State private var showingSummary = false
    @State private var hasStarted = false
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isDarkMode) var isDarkMode

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .padding(.top, DesignSystem.Spacing.small)
                .padding(.bottom, DesignSystem.Spacing.small)

            if !hasStarted {
                Spacer()

                // Pre-exercise instructions
                instructionSection

                Spacer()
            } else {
                // Active journaling or completion
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.large) {
                        journalingSection

                        // Action button - right after text editor
                        actionButton
                            .padding(.top, DesignSystem.Spacing.small)
                    }
                }
                .padding(DesignSystem.Spacing.medium)

                Spacer()
            }
        }
        .gradientBackground(AppGradient.adaptiveBackground(isDark: isDarkMode))
        .navigationBarHidden(true)
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    // Swipe from left edge to go back
                    if gesture.startLocation.x < 50 && gesture.translation.width > 100 {
                        HapticManager.shared.impact(.light)
                        stopTimer()
                        dismiss()
                    }
                }
        )
        .sheet(isPresented: $showingSummary) {
            ReliefSummaryView(
                completedTechnique: "Quick Brain Dump",
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

    private var headerSection: some View {
        HStack {
            Button(action: {
                HapticManager.shared.impact(.light)
                stopTimer()
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
            }

            Spacer()
        }
    }

    private var instructionSection: some View {
        VStack(spacing: 32) {
            Text("Empty your mind\non paper")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text("Private & not saved • 60 seconds")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))

            // Journal illustration
            journalIllustration

            // Explanation text
            Text("Write without thinking. No filter, no judgment.")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                .padding(.top, 8)
                .multilineTextAlignment(.center)

            // Start button
            Button(action: {
                HapticManager.shared.impact(.medium)
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    startJournaling()
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
            .padding(.horizontal, DesignSystem.Spacing.large)
            .padding(.top, 8)
        }
        .padding(.horizontal, DesignSystem.Spacing.large)
    }

    private var journalIllustration: some View {
        ZStack {
            // Paper pages
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primaryPurple.opacity(isDarkMode ? 0.25 - CGFloat(index) * 0.05 : 0.15 - CGFloat(index) * 0.03))
                    .frame(width: 140 - CGFloat(index) * 8, height: 160 - CGFloat(index) * 8)
                    .offset(x: CGFloat(index) * 4, y: CGFloat(index) * 4)
            }

            // Writing lines
            VStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.primaryPurple.opacity(isDarkMode ? 0.6 : 0.4))
                        .frame(width: 100, height: 3)
                }
            }
            .offset(y: -10)

            // Pencil icon
            Image(systemName: "pencil")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(Color.primaryPurple)
                .offset(x: 40, y: 50)
                .rotationEffect(.degrees(-15))
        }
        .frame(height: 200)
    }


    private var journalingSection: some View {
        VStack(spacing: DesignSystem.Spacing.large) {

            // Timer and progress
            if isActive {
                VStack(spacing: DesignSystem.Spacing.medium) {
                    Text("Keep writing...")
                        .font(DesignSystem.Typography.subtitleFallback)
                        .foregroundColor(Color.primaryPurple)
                        .fontWeight(.semibold)

                    HStack {
                        Text("\(timeRemaining)s")
                            .font(DesignSystem.Typography.titleFallback)
                            .foregroundColor(Color.primaryPurple)
                            .fontWeight(.bold)
                            .monospacedDigit()

                        Spacer()

                        ProgressView(value: Double(60 - timeRemaining) / 60.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color.primaryPurple))
                            .frame(width: 200)
                    }
                }
            } else if timeRemaining <= 0 {
                // Time's up message
                VStack(spacing: DesignSystem.Spacing.medium) {
                    Text("Time's up!")
                        .font(DesignSystem.Typography.titleFallback)
                        .foregroundColor(Color.success)
                        .fontWeight(.bold)

                    Text("Take a moment to see what came out. Then let's release it.")
                        .font(DesignSystem.Typography.bodyFallback)
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                        .multilineTextAlignment(.center)
                }
            }

            // Text editor
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                if isActive || timeRemaining <= 0 {
                    Text("Your thoughts:")
                        .font(DesignSystem.Typography.bodyFallback)
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                }

                TextEditor(text: $journalText)
                    .font(DesignSystem.Typography.bodyFallback)
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                    .padding(DesignSystem.Spacing.small)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                            .fill(isDarkMode ? Color.adaptiveSecondaryBackground(isDark: true) : Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                            .stroke(Color.primaryPurple.opacity(0.2), lineWidth: 1)
                    )
                    .frame(minHeight: 200)
                    .disabled(timeRemaining <= 0)  // Disable when time is up
                    .opacity(isActive || timeRemaining <= 0 ? 1.0 : 0.5)
                    .focused($isTextFieldFocused)
                    .autocorrectionDisabled(false)
                    .textInputAutocapitalization(.sentences)
                    .scrollContentBackground(.hidden)

                if !journalText.isEmpty && timeRemaining <= 0 {
                    let wordCount = journalText.split(separator: " ").count
                    Text("\(wordCount) words written")
                        .font(DesignSystem.Typography.captionFallback)
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                }
            }
        }
    }

    private var actionButton: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            if isActive {
                PrimaryButton("Finish & Delete", style: .primary) {
                    finishEarly()
                }
            } else if timeRemaining <= 0 {
                PrimaryButton("Delete & Let Go", style: .primary) {
                    deleteAndComplete()
                }
            }
        }
    }

    private func startJournaling() {
        hasStarted = true
        isActive = true
        timeRemaining = 60
        journalText = ""
        isTextFieldFocused = true

        // Light haptic feedback to confirm start
        #if os(iOS)
        HapticManager.shared.impact(.light)
        #endif

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
                // Haptic feedback when timer ends
                #if os(iOS)
                HapticManager.shared.notification(.success)
                #endif
                // User can now read but not write - summary only shows when they click button
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isActive = false
    }

    private func finishEarly() {
        stopTimer()
        journalText = ""

        // Success haptic feedback
        #if os(iOS)
        HapticManager.shared.notification(.success)
        #endif

        // Show summary immediately
        showingSummary = true
    }

    private func deleteAndComplete() {
        // Success haptic feedback
        #if os(iOS)
        HapticManager.shared.notification(.success)
        #endif

        // Clear the text
        journalText = ""

        // Show relief summary immediately
        showingSummary = true
    }
}

#Preview {
    QuickJournalView(navigateToDashboard: {})
}
