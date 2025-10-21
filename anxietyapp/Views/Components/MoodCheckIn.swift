//
//  MoodCheckIn.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct MoodCheckIn: View {
    @Environment(\.isDarkMode) var isDarkMode
    @ObservedObject private var userDataService = UserDataService.shared
    @State private var selectedMoodValue: Double = 0.5
    @State private var showingMoodSelection = false

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {

            // Header
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Daily Check-in")
                        .font(DesignSystem.Typography.subtitleFallback)
                        .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                        .fontWeight(.semibold)

                    if userDataService.hasCheckedInToday() {
                        Text("Thanks for checking in today!")
                            .font(DesignSystem.Typography.captionFallback)
                            .foregroundColor(Color.success)
                    } else {
                        Text("How are you feeling today?")
                            .font(DesignSystem.Typography.captionFallback)
                            .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                    }
                }

                Spacer()

                // Streak indicator
                streakIndicator
            }

            // Mood selection or current mood
            if userDataService.hasCheckedInToday() {
                currentMoodDisplay
            } else {
                moodSelectionSlider
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(Color.adaptiveSupportGray(isDark: isDarkMode).opacity(isDarkMode ? 0.5 : 1.0))
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .onAppear {
            if let todaysMood = userDataService.getTodaysMoodValue() {
                selectedMoodValue = todaysMood
            }
        }
    }

    private var streakIndicator: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text(userDataService.getStreakEmoji())
                .font(.title2)

            VStack(spacing: 2) {
                Text("\(userDataService.userStats.currentStreak)")
                    .font(DesignSystem.Typography.subtitleFallback)
                    .foregroundColor(Color.lightBlue)
                    .fontWeight(.bold)

                Text("streak")
                    .font(DesignSystem.Typography.captionFallback)
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.small)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(Color.lightBlue.opacity(isDarkMode ? 0.2 : 0.1))
        .cornerRadius(DesignSystem.CornerRadius.small)
    }

    private var currentMoodDisplay: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            if let currentMoodValue = userDataService.getTodaysMoodValue() {
                HStack(spacing: DesignSystem.Spacing.small) {
                    MoodFaceView(moodValue: currentMoodValue, size: 32)

                    let entry = MoodEntry(id: UUID(), date: Date(), moodValue: currentMoodValue, sessionCount: 0)
                    Text("Feeling \(entry.description.lowercased()) today")
                        .font(DesignSystem.Typography.bodyFallback)
                        .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                }
            }

            Spacer()

            Button("Change") {
                showingMoodSelection.toggle()
            }
            .font(DesignSystem.Typography.captionFallback)
            .foregroundColor(Color.lightBlue)
        }
        .sheet(isPresented: $showingMoodSelection) {
            MoodSelectionSheet(initialValue: selectedMoodValue)
        }
    }

    private var moodSelectionSlider: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            // Labels
            HStack {
                Text("Anxious")
                    .font(DesignSystem.Typography.captionFallback)
                    .foregroundColor(Color.moodGradient(for: 1.0))
                    .fontWeight(.semibold)
                Spacer()
                Text("Calm")
                    .font(DesignSystem.Typography.captionFallback)
                    .foregroundColor(Color.moodGradient(for: 0.0))
                    .fontWeight(.semibold)
            }

            // Color gradient bar with slider
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Gradient background (reversed: anxious to calm)
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.moodGradient(for: 1.0),
                            Color.moodGradient(for: 0.75),
                            Color.moodGradient(for: 0.5),
                            Color.moodGradient(for: 0.25),
                            Color.moodGradient(for: 0.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 40)
                    .cornerRadius(20)

                    // Slider thumb
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .overlay(
                            Circle()
                                .fill(Color.moodGradient(for: selectedMoodValue))
                                .frame(width: 40, height: 40)
                        )
                        .offset(x: geometry.size.width * CGFloat(1.0 - selectedMoodValue) - 25)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newValue = min(max(value.location.x / geometry.size.width, 0), 1)
                                    selectedMoodValue = 1.0 - newValue

                                    // Haptic feedback
                                    #if os(iOS)
                                    HapticManager.shared.impact(.light)
                                    #endif
                                }
                                .onEnded { _ in
                                    userDataService.recordMoodValue(selectedMoodValue)
                                }
                        )
                }
            }
            .frame(height: 50)

            // Current mood description
            let entry = MoodEntry(id: UUID(), date: Date(), moodValue: selectedMoodValue, sessionCount: 0)
            Text(entry.description)
                .font(DesignSystem.Typography.bodyFallback)
                .foregroundColor(Color.moodGradient(for: selectedMoodValue))
                .fontWeight(.semibold)

            // Medical disclaimer
            Text("This is for personal tracking only and not medical advice. Consult a healthcare professional for diagnosis or treatment.")
                .font(.system(size: 10))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode).opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
    }
}

struct MoodSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isDarkMode) var isDarkMode
    @ObservedObject private var userDataService = UserDataService.shared
    @State private var selectedMoodValue: Double

    init(initialValue: Double = 0.5) {
        _selectedMoodValue = State(initialValue: initialValue)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: DesignSystem.Spacing.xl) {

                Text("How are you feeling right now?")
                    .font(DesignSystem.Typography.titleFallback)
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                    .multilineTextAlignment(.center)
                    .padding(.top, DesignSystem.Spacing.large)

                VStack(spacing: DesignSystem.Spacing.large) {
                    // Large mood face indicator
                    MoodFaceView(moodValue: selectedMoodValue, size: 120)
                        .shadow(color: Color.moodGradient(for: selectedMoodValue).opacity(0.3), radius: 20, x: 0, y: 10)

                    // Mood description
                    let entry = MoodEntry(id: UUID(), date: Date(), moodValue: selectedMoodValue, sessionCount: 0)
                    Text(entry.description)
                        .font(DesignSystem.Typography.titleFallback)
                        .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                        .fontWeight(.semibold)

                    // Color gradient slider
                    VStack(spacing: DesignSystem.Spacing.small) {
                        HStack {
                            Text("Anxious")
                                .font(DesignSystem.Typography.captionFallback)
                                .foregroundColor(Color.moodGradient(for: 1.0))
                                .fontWeight(.semibold)
                            Spacer()
                            Text("Calm")
                                .font(DesignSystem.Typography.captionFallback)
                                .foregroundColor(Color.moodGradient(for: 0.0))
                                .fontWeight(.semibold)
                        }

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Gradient background (reversed: anxious to calm)
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.moodGradient(for: 1.0),
                                        Color.moodGradient(for: 0.75),
                                        Color.moodGradient(for: 0.5),
                                        Color.moodGradient(for: 0.25),
                                        Color.moodGradient(for: 0.0)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .frame(height: 50)
                                .cornerRadius(25)

                                // Slider thumb
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 60, height: 60)
                                    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                                    .overlay(
                                        Circle()
                                            .fill(Color.moodGradient(for: selectedMoodValue))
                                            .frame(width: 50, height: 50)
                                    )
                                    .offset(x: geometry.size.width * CGFloat(1.0 - selectedMoodValue) - 30)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                let newValue = min(max(value.location.x / geometry.size.width, 0), 1)
                                                selectedMoodValue = 1.0 - newValue

                                                // Haptic feedback
                                                #if os(iOS)
                                                HapticManager.shared.impact(.light)
                                                #endif
                                            }
                                    )
                            }
                        }
                        .frame(height: 60)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.small)

                    // Medical disclaimer
                    Text("This is for personal tracking only and not medical advice. Consult a healthcare professional for diagnosis or treatment.")
                        .font(.system(size: 11))
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode).opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignSystem.Spacing.medium)
                        .padding(.top, 8)

                    // Save button
                    Button(action: {
                        userDataService.recordMoodValue(selectedMoodValue)
                        dismiss()
                    }) {
                        Text("Save")
                            .font(DesignSystem.Typography.bodyFallback)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DesignSystem.Spacing.medium)
                            .background(Color.primaryPurple)
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                }

                Spacer()
            }
            .padding(DesignSystem.Spacing.medium)
            .background(Color.adaptiveBackground(isDark: isDarkMode))
            .navigationTitle("Mood Check-in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(isDarkMode ? .dark : .light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                    }
                }
            }
        }
    }
}

#Preview {
    MoodCheckIn()
}