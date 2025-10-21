//
//  WeeklyMoodChart.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import SwiftUI

struct WeeklyMoodChart: View {
    @Environment(\.isDarkMode) var isDarkMode
    @ObservedObject private var userDataService = UserDataService.shared
    @State private var selectedDate: IdentifiableDate?
    @State private var displayedMonth: Date = Date()

    private var displayedMonthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    private var isCurrentMonth: Bool {
        let calendar = Calendar.current
        return calendar.isDate(displayedMonth, equalTo: Date(), toGranularity: .month)
    }

    private var monthDays: [Date] {
        let calendar = Calendar.current

        // Get the start of the displayed month
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return []
        }

        // Get the range of days in the displayed month
        guard let monthRange = calendar.range(of: .day, in: .month, for: displayedMonth) else {
            return []
        }

        // Generate all days in the displayed month
        return monthRange.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: monthStart)
        }
    }

    private var sessionsThisMonth: Int {
        let calendar = Calendar.current

        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return 0
        }

        return userDataService.userStats.moodEntries
            .filter { $0.date >= monthStart && calendar.isDate($0.date, equalTo: displayedMonth, toGranularity: .month) }
            .reduce(0) { $0 + $1.sessionCount }
    }

    private func previousMonth() {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    private func nextMonth() {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
            // Don't go beyond current month
            if !calendar.isDate(newMonth, equalTo: Date(), toGranularity: .month) && newMonth > Date() {
                return
            }
            displayedMonth = newMonth
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                // Month navigation
                HStack(spacing: 12) {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.67, green: 0.58, blue: 0.85))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(displayedMonthName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                        Text("\(sessionsThisMonth) relief sessions")
                            .font(.system(size: 13))
                            .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                    }

                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(isCurrentMonth ? Color.gray.opacity(0.3) : Color(red: 0.67, green: 0.58, blue: 0.85))
                    }
                    .disabled(isCurrentMonth)
                }

                Spacer()

                // Monthly summary
                monthlyProgress
            }

            // Calendar month grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                ForEach(monthDays, id: \.self) { date in
                    DayMoodIndicator(
                        date: date,
                        moodEntry: userDataService.userStats.getMoodForDate(date),
                        isToday: Calendar.current.isDateInToday(date),
                        compact: true
                    )
                    .onTapGesture {
                        selectedDate = IdentifiableDate(date: date)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: isDarkMode ? [
                            Color.adaptiveSecondaryBackground(isDark: true).opacity(0.6),
                            Color.adaptiveSecondaryBackground(isDark: true).opacity(0.4)
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
                .stroke(isDarkMode ? Color.adaptiveDivider(isDark: true).opacity(0.3) : Color.white.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(isDarkMode ? 0.3 : 0.08), radius: 12, x: 0, y: 6)
        .sheet(item: $selectedDate) { identifiableDate in
            DayDetailView(date: identifiableDate.date, moodEntry: userDataService.userStats.getMoodForDate(identifiableDate.date))
        }
    }

    private var monthlyProgress: some View {
        let daysInMonth = monthDays.count

        return VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 5)
                    .frame(width: 52, height: 52)

                Circle()
                    .trim(from: 0, to: CGFloat(min(userDataService.userStats.currentStreak, daysInMonth)) / CGFloat(daysInMonth))
                    .stroke(
                        Color(red: 0.67, green: 0.58, blue: 0.85),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: 52, height: 52)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: userDataService.userStats.currentStreak)

                VStack(spacing: 0) {
                    Text("\(userDataService.userStats.currentStreak)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                    Text("days")
                        .font(.system(size: 9))
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                }
            }
        }
    }
}

struct DayMoodIndicator: View {
    @Environment(\.isDarkMode) var isDarkMode
    let date: Date
    let moodEntry: MoodEntry?
    let isToday: Bool
    var compact: Bool = false

    private var dayAbbreviation: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: compact ? 3 : 6) {
            // Day abbreviation (only show in non-compact mode)
            if !compact {
                Text(dayAbbreviation)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(isToday ? Color(red: 0.67, green: 0.58, blue: 0.85) : Color.adaptiveSecondaryText(isDark: isDarkMode))
            }

            // Mood indicator
            ZStack {
                if let moodEntry = moodEntry {
                    MoodFaceView(moodValue: moodEntry.moodValue, size: compact ? 32 : 40)
                        .shadow(color: Color.moodGradient(for: moodEntry.moodValue).opacity(0.3), radius: compact ? 2 : 3, x: 0, y: 2)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: compact ? 32 : 40, height: compact ? 32 : 40)
                        .overlay(
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: compact ? 6 : 8, height: compact ? 6 : 8)
                        )
                }

                if isToday {
                    Circle()
                        .stroke(Color(red: 0.67, green: 0.58, blue: 0.85), lineWidth: 2.5)
                        .frame(width: compact ? 36 : 44, height: compact ? 36 : 44)
                }
            }

            // Day number
            Text(dayNumber)
                .font(.system(size: compact ? 9 : 11, weight: .semibold))
                .foregroundColor(isToday ? Color(red: 0.67, green: 0.58, blue: 0.85) : Color.adaptiveSecondaryText(isDark: isDarkMode))
        }
        .frame(maxWidth: .infinity)
    }
}

struct DayDetailView: View {
    @Environment(\.isDarkMode) var isDarkMode
    let date: Date
    let moodEntry: MoodEntry?
    @Environment(\.dismiss) var dismiss

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateStyle = .long
        return formatter
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppGradient.adaptiveBackground(isDark: isDarkMode)
                    .ignoresSafeArea()

                VStack(spacing: 32) {
                    if let entry = moodEntry {
                        // Mood indicator
                        ZStack {
                            MoodFaceView(moodValue: entry.moodValue, size: 120)
                                .shadow(color: Color.moodGradient(for: entry.moodValue).opacity(0.4), radius: 20, x: 0, y: 10)
                        }
                        .padding(.top, 32)

                        // Mood description
                        VStack(spacing: 8) {
                            Text(entry.description)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                            Text(dateFormatter.string(from: date))
                                .font(.system(size: 16))
                                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                        }

                        // Session info
                        if entry.sessionCount > 0 {
                            VStack(spacing: 12) {
                                HStack(spacing: 8) {
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color.sosRed)

                                    Text("\(entry.sessionCount) relief session\(entry.sessionCount == 1 ? "" : "s")")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(isDarkMode ? Color.adaptiveSecondaryBackground(isDark: true).opacity(0.6) : Color.white.opacity(0.9))
                                )
                            }
                        }

                    } else {
                        // No mood entry for this day
                        VStack(spacing: 24) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 60))
                                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode).opacity(0.4))
                                .padding(.top, 32)

                            VStack(spacing: 8) {
                                Text("No entry for this day")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                                Text(dateFormatter.string(from: date))
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                    }
                }
            }
        }
    }
}

// Helper struct to make Date identifiable for sheet presentation
struct IdentifiableDate: Identifiable {
    let id = UUID()
    let date: Date
}

#Preview {
    VStack {
        WeeklyMoodChart()
        Spacer()
    }
    .padding()
}