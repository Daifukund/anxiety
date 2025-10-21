//
//  DashboardView.swift
//  anxietyapp
//
//  Minimal home screen design
//  Layout: App name → Weekly mood tracker → Jellyfish mascot → SOS button
//

import SwiftUI

struct DashboardView: View {
    // MARK: - Properties
    @Environment(\.isDarkMode) var isDarkMode
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @EnvironmentObject var themeManager: ThemeManager
    var onNavigateToStats: (() -> Void)? = nil
    @Binding var showMoodCheckIn: Bool
    @Binding var showDailyQuote: Bool

    // MARK: - State
    @State private var showingUnifiedSOS = false
    @State private var showingSettings = false
    @State private var showingMoodSelection = false
    @State private var sosButtonPressed = false
    @State private var jellyfishOffset: CGFloat = 0
    @ObservedObject private var userDataService = UserDataService.shared

    // Quick access exercises
    @State private var showingExercise: FavoriteExercise? = nil
    @State private var showingExercisePicker = false
    @State private var selectedSlotIndex: Int = 0
    @State private var selectedQuote: Quote?

    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let _ = min(1.0, screenHeight / 800) // Scale down spacing on smaller screens

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Top navigation bar
                    HStack {
                        // App Name (top left)
                        Text("Nuvin")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                            .tracking(1.5)

                        Spacer()

                        // Settings icon (top right)
                        Button(action: {
                            showingSettings = true
                            HapticManager.shared.impact(.light)
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                                .frame(width: 48, height: 48)
                                .contentShape(Rectangle())
                        }
                        .accessibilityLabel("Settings")
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 24)

                    // Weekly Mood Tracker (7 circles)
                    weeklyMoodTracker
                        .padding(.bottom, 24)

                    // Mood wave visualization
                    jellyfishMascot
                        .padding(.bottom, 32)

                    // Quick access favorite exercises
                    quickAccessCircles
                        .padding(.bottom, 32)

                    // Reassuring message
                    Text("Take a breath. You're not alone")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 24)

                    // 4. SOS Panic Button (bigger and more prominent)
                    sosButton
                        .padding(.horizontal, 24)

                    Spacer()
                        .frame(height: 32)
                }
            }
            .gradientBackground(AppGradient.adaptiveBackground(isDark: isDarkMode))
        }
        .fullScreenCover(isPresented: $showingUnifiedSOS) {
            UnifiedSOSFlowView(navigateToDashboard: {
                showingUnifiedSOS = false
            })
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingMoodSelection) {
            MoodSelectionSheet()
        }
        .onChange(of: showMoodCheckIn) { shouldShow in
            if shouldShow {
                showingMoodSelection = true
                showMoodCheckIn = false // Reset the trigger
            }
        }
        .onChange(of: showDailyQuote) { shouldShow in
            if shouldShow {
                selectedQuote = Quote.getDailyQuote()
                showDailyQuote = false // Reset the trigger
            }
        }
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePickerSheet(selectedIndex: selectedSlotIndex)
        }
        .sheet(item: $selectedQuote) { quote in
            QuotePopupView(quote: quote)
        }
        .fullScreenCover(item: $showingExercise) { exercise in
            exerciseView(for: exercise)
        }
    }

    @ViewBuilder
    private func exerciseView(for exercise: FavoriteExercise) -> some View {
        switch exercise {
        case .breathing:
            BreathingExerciseView(navigateToDashboard: { showingExercise = nil })
        case .grounding:
            GroundingExerciseView(navigateToDashboard: { showingExercise = nil })
        case .physicalReset:
            PhysicalResetView(navigateToDashboard: { showingExercise = nil })
        case .perspective:
            PerspectiveShiftView(navigateToDashboard: { showingExercise = nil })
        case .journal:
            QuickJournalView(navigateToDashboard: { showingExercise = nil })
        case .reframe:
            ReframeStressView(navigateToDashboard: { showingExercise = nil })
        case .emotionReset:
            EmotionResetView(navigateToDashboard: { showingExercise = nil })
        }
    }

    // MARK: - Weekly Mood Tracker (7 circles)
    private var weeklyMoodTracker: some View {
        Button(action: {
            showingMoodSelection = true
            HapticManager.shared.impact(.light)
        }) {
            VStack(spacing: 8) {
                Text("This Week")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))

                HStack(spacing: 16) {
                    ForEach(0..<7) { index in
                        let (date, dayLabel) = getWeekDay(index: index)
                        let moodEntry = getMoodEntryForDate(date)
                        let isToday = Calendar.current.isDateInToday(date)

                        VStack(spacing: 8) {
                            ZStack {
                                // Mood color circle or empty indicator
                                if let entry = moodEntry {
                                    MoodFaceView(moodValue: entry.moodValue, size: 36)
                                        .shadow(color: Color.moodGradient(for: entry.moodValue).opacity(0.3), radius: 2, x: 0, y: 1)
                                        .accessibilityLabel(AccessibilityLabels.moodEmoji(entry.moodValue))
                                        .accessibilityValue("Mood level \(Int(entry.moodValue)) out of 10")
                                } else {
                                    Circle()
                                        .fill(Color.adaptiveDivider(isDark: isDarkMode).opacity(0.5))
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Circle()
                                                .fill(Color.adaptiveDivider(isDark: isDarkMode))
                                                .frame(width: 5, height: 5)
                                        )
                                        .accessibilityLabel("No mood entry")
                                }

                                // Highlight for today
                                if isToday {
                                    Circle()
                                        .stroke(Color.accentViolet, lineWidth: 2.5)
                                        .frame(width: 40, height: 40)
                                        .accessibilityHidden(true)
                                }
                            }
                            .scaleEffect(isToday ? 1.0 : 0.95)
                            .shadow(
                                color: isToday ? Color.accentViolet.opacity(0.2) : .clear,
                                radius: 6,
                                x: 0,
                                y: 2
                            )

                            Text(dayLabel)
                                .font(.caption)
                                .foregroundColor(
                                    isToday ? Color.accentViolet : Color.adaptiveSecondaryText(isDark: isDarkMode)
                                )
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(dayLabel)\(isToday ? ", Today" : ""), \(moodEntry.map { AccessibilityLabels.moodEmoji($0.moodValue) } ?? "No mood entry")")
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Your mood this week. Tap to check in with your mood")
    }

    // MARK: - Mood Gradient Wave
    private var jellyfishMascot: some View {
        Button(action: {
            selectedQuote = Quote.getDailyQuote()
            HapticManager.shared.impact(.light)
        }) {
            VStack(spacing: 8) {
                // Wave visualization
                ZStack {
                    // Flowing wave with uniform color
                    MoodWaveShape(offset: jellyfishOffset)
                        .fill(Color.accentViolet.opacity(0.4))
                        .frame(height: 120)
                        .shadow(color: Color.accentViolet.opacity(0.15), radius: 15, x: 0, y: 8)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 32)
                .onAppear {
                    // Wave flowing animation (only if reduce motion is disabled)
                    if !reduceMotion {
                        withAnimation(
                            .easeInOut(duration: 4.0)
                            .repeatForever(autoreverses: true)
                        ) {
                            jellyfishOffset = 20
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Daily inspiration. Tap for your quote of the day")
    }

    // MARK: - Quick Access Circles
    private var quickAccessCircles: some View {
        HStack(spacing: 24) {
            ForEach(0..<3, id: \.self) { index in
                if let exercise = userDataService.getFavoriteExercise(at: index) {
                    // Filled circle with exercise
                    favoriteExerciseCircle(exercise: exercise, index: index)
                } else {
                    // Empty circle - tap to add favorite
                    emptyFavoriteCircle(index: index)
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private func favoriteExerciseCircle(exercise: FavoriteExercise, index: Int) -> some View {
        Button(action: {
            showingExercise = exercise
            HapticManager.shared.impact(.medium)
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: exercise.color.0),
                                    Color(hex: exercise.color.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .shadow(color: Color(hex: exercise.color.0).opacity(0.3), radius: 6, x: 0, y: 3)

                    Image(systemName: exercise.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .accessibilityHidden(true) // Icon is decorative
                }
                .contextMenu {
                    Button {
                        selectedSlotIndex = index
                        showingExercisePicker = true
                    } label: {
                        Label("Change", systemImage: "arrow.triangle.2.circlepath")
                    }
                    .accessibilityLabel("Change favorite exercise")

                    Button(role: .destructive) {
                        userDataService.removeFavoriteExercise(at: index)
                    } label: {
                        Label("Remove", systemImage: "trash")
                    }
                    .accessibilityLabel("Remove \(exercise.rawValue) from favorites")
                }

                Text(exercise.rawValue)
                    .font(.caption)
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .accessibilityHidden(true) // Label included in button accessibility
            }
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(exercise.rawValue) exercise")
        .accessibilityHint("Double tap to start this exercise. Long press to change or remove.")
        .standardTouchTarget()
    }

    private func emptyFavoriteCircle(index: Int) -> some View {
        Button(action: {
            selectedSlotIndex = index
            showingExercisePicker = true
            HapticManager.shared.impact(.light)
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .strokeBorder(
                            Color.adaptiveSecondaryText(isDark: isDarkMode).opacity(isDarkMode ? 0.5 : 0.3),
                            style: StrokeStyle(lineWidth: 2, dash: [6, 3])
                        )
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(Color.adaptiveSupportGray(isDark: isDarkMode).opacity(isDarkMode ? 0.8 : 0.5))
                        )

                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode).opacity(isDarkMode ? 0.8 : 0.5))
                        .accessibilityHidden(true) // Icon is decorative
                }

                Text("Add")
                    .font(.caption)
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode).opacity(isDarkMode ? 0.9 : 0.6))
                    .accessibilityHidden(true) // Label included in button accessibility
            }
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Add favorite exercise")
        .accessibilityHint("Double tap to choose an exercise to add to your favorites")
        .standardTouchTarget()
    }

    // MARK: - SOS Panic Button
    private var sosButton: some View {
        Button(action: {
            sosButtonPressed = true
            HapticManager.shared.impact(.heavy)

            if reduceMotion {
                showingUnifiedSOS = true
            } else {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    showingUnifiedSOS = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                sosButtonPressed = false
            }
        }) {
            Text("SOS")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .tracking(4)
                .frame(maxWidth: .infinity)
                .frame(height: 96)
                .background(
                    ZStack {
                        // Main button
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.98, green: 0.35, blue: 0.32),
                                        Color(red: 0.92, green: 0.25, blue: 0.25)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color(red: 0.92, green: 0.45, blue: 0.45).opacity(0.4), radius: 20, x: 0, y: 8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                            )
                    }
                )
        }
        .scaleEffect(sosButtonPressed ? 0.96 : 1.0)
        .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.6), value: sosButtonPressed)
        .accessibilityLabel("SOS button. I need help now")
        .accessibilityHint("Double tap for immediate anxiety relief options")
    }

    // MARK: - Helper Functions

    /// Returns the date and day label for a specific index in the Monday-Sunday week
    private func getWeekDay(index: Int) -> (Date, String) {
        let calendar = Calendar.current
        let today = Date()

        // Get the Monday of the current week
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return (today, "?")
        }

        // Calculate the date for this index (0 = Monday, 6 = Sunday)
        guard let targetDate = calendar.date(byAdding: .day, value: index, to: startOfWeek) else {
            return (today, "?")
        }

        // Format the day label (M, T, W, T, F, S, S)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEE"
        let dayLabel = String(formatter.string(from: targetDate).prefix(1))

        return (targetDate, dayLabel)
    }

    private func getMoodEntryForDate(_ date: Date) -> MoodEntry? {
        return userDataService.userStats.getMoodForDate(date)
    }

    /// Get gradient colors based on weekly mood data
    private func getWeeklyMoodGradient() -> [Color] {
        var colors: [Color] = []

        for index in 0..<7 {
            let (date, _) = getWeekDay(index: index)
            if let moodEntry = getMoodEntryForDate(date) {
                colors.append(Color.moodGradient(for: moodEntry.moodValue))
            } else {
                // Default to calm violet for days without data
                colors.append(Color.accentViolet.opacity(0.3))
            }
        }

        // If no mood data exists, return default calming gradient
        if colors.isEmpty {
            return [
                Color.accentViolet.opacity(0.4),
                Color.lightBlue.opacity(0.4),
                Color.accentViolet.opacity(0.4)
            ]
        }

        return colors
    }
}

// MARK: - Mood Wave Shape
struct MoodWaveShape: Shape {
    var offset: CGFloat

    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height
        let midHeight = height / 2

        // Create flowing wave pattern
        path.move(to: CGPoint(x: 0, y: midHeight))

        // Multiple waves for organic feel
        for x in stride(from: 0, through: width, by: 2) {
            let relativeX = x / width
            let wave1 = sin((relativeX * .pi * 3) + (offset / 10)) * (height * 0.15)
            let wave2 = sin((relativeX * .pi * 2) - (offset / 15)) * (height * 0.12)
            let wave3 = cos((relativeX * .pi * 4) + (offset / 8)) * (height * 0.08)

            let y = midHeight + wave1 + wave2 + wave3

            path.addLine(to: CGPoint(x: x, y: y))
        }

        // Close the path at bottom
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()

        return path
    }
}

// MARK: - Quote Popup View
struct QuotePopupView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.isDarkMode) var isDarkMode
    let quote: Quote

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                AppGradient.adaptiveBackground(isDark: isDarkMode)
                    .ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    // Quote content
                    VStack(spacing: 24) {
                        // Quote of the day label
                        Text("Quote of the Day")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.accentViolet)
                            .textCase(.uppercase)
                            .tracking(1.5)

                        // Opening quote mark
                        Image(systemName: "quote.opening")
                            .font(.system(size: 40))
                            .foregroundColor(quote.category.color.opacity(0.5))

                        // Quote text
                        Text(quote.text)
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .padding(.horizontal, 32)

                        // Author if exists
                        if let author = quote.author {
                            Text("— \(author)")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                                .padding(.top, 8)
                        }

                        // Category badge
                        Text(quote.category.displayName)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(quote.category.color)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(quote.category.color.opacity(0.15))
                            )
                            .padding(.top, 16)
                    }

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.accentViolet)
                    }
                }
            }
        }
    }
}

// MARK: - Exercise Picker Sheet
struct ExercisePickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.isDarkMode) var isDarkMode
    @ObservedObject private var userDataService = UserDataService.shared
    let selectedIndex: Int

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Choose your favorite exercise")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                        .padding(.top, 16)

                    ForEach(FavoriteExercise.allCases, id: \.self) { exercise in
                        Button(action: {
                            userDataService.setFavoriteExercise(exercise, at: selectedIndex)
                            HapticManager.shared.impact(.medium)
                            dismiss()
                        }) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(hex: exercise.color.0),
                                                    Color(hex: exercise.color.1)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 60, height: 60)
                                        .shadow(color: Color(hex: exercise.color.0).opacity(0.3), radius: 6, x: 0, y: 3)

                                    Image(systemName: exercise.icon)
                                        .font(.system(size: 26, weight: .semibold))
                                        .foregroundColor(.white)
                                }

                                Text(exercise.rawValue)
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode).opacity(0.4))
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.adaptiveSecondaryBackground(isDark: isDarkMode))
                                    .shadow(color: Color.black.opacity(isDarkMode ? 0.3 : 0.06), radius: 8, x: 0, y: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .background(Color.adaptiveSecondaryBackground(isDark: isDarkMode))
            .navigationTitle("Add Favorite")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    DashboardView(
        showMoodCheckIn: .constant(false),
        showDailyQuote: .constant(false)
    )
    .environmentObject(ThemeManager())
}
