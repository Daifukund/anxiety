//
//  PerspectiveShiftView.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import SwiftUI

struct PerspectiveShiftView: View {
    @Environment(\.isDarkMode) var isDarkMode
    let navigateToDashboard: () -> Void
    @State private var currentReminderIndex = 0
    @State private var showingSummary = false
    @State private var hasViewedReminders = false
    @State private var isActive = false
    @State private var dragOffset: CGFloat = 0
    @Environment(\.dismiss) private var dismiss

    private let reminders = PerspectiveReminder.allReminders
    private var currentReminder: PerspectiveReminder {
        reminders[currentReminderIndex]
    }

    var body: some View {
        ZStack {
            // Background layer
            if isActive {
                currentReminder.backgroundColor
                    .ignoresSafeArea()
            } else {
                AppGradient.adaptiveBackground(isDark: isDarkMode)
                    .ignoresSafeArea()
            }

            // Content layer
            VStack(spacing: 0) {
                if !isActive {
                    // Start screen
                    startSection
                } else {
                    VStack(spacing: 0) {
                        // Header
                        headerSection

                        Spacer()

                        // Main content
                        if !showingSummary {
                            perspectiveContent
                        }

                        Spacer()

                        // Navigation
                        if !showingSummary {
                            navigationSection
                                .padding(.bottom, 24)
                        }

                        // Skip button
                        if !showingSummary {
                            skipButton
                                .padding(.bottom, 72)
                        }
                    }
                    .padding(DesignSystem.Spacing.medium)
                }
            }
        }
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
                completedTechnique: "Perspective Shift",
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

    // MARK: - Start Section
    private var startSection: some View {
        VStack(spacing: 0) {
            // Header with close button
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
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.top, DesignSystem.Spacing.small)
            .padding(.bottom, DesignSystem.Spacing.small)

            Spacer()

            VStack(spacing: 32) {
                Text("Zoom out\nand find peace")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text("\(reminders.count) perspective reminders • 1-2 minutes")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))

                // Perspective illustration
                perspectiveIllustration

                // Explanation text
                Text("See your worries from a cosmic perspective.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                    .padding(.top, 8)
                    .multilineTextAlignment(.center)

                // Start button
                Button(action: {
                    HapticManager.shared.impact(.medium)
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isActive = true
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

            Spacer()
        }
    }

    private var perspectiveIllustration: some View {
        ZStack {
            // Outer space rings
            ForEach(0..<4, id: \.self) { ring in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.purple.opacity(0.3),
                                Color.blue.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: CGFloat(60 + ring * 30), height: CGFloat(60 + ring * 30))
            }

            // Center earth/globe
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.blue, Color.green.opacity(0.7)],
                            center: .center,
                            startRadius: 10,
                            endRadius: 30
                        )
                    )
                    .frame(width: 60, height: 60)

                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white.opacity(0.8))
            }

            // You indicator
            VStack(spacing: 4) {
                Image(systemName: "person.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color.purple)
                Text("You")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.purple)
            }
            .offset(x: 75, y: -75)
        }
        .frame(height: 200)
    }

    private var headerSection: some View {
        HStack {
            Button(action: {
                HapticManager.shared.impact(.light)
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }

            Spacer()

            Text("Zoom Out")
                .font(DesignSystem.Typography.subtitleFallback)
                .foregroundColor(currentReminder.accentColor)
                .fontWeight(.semibold)

            Spacer()

            // Empty space for balance
            Color.clear
                .frame(width: 32, height: 32)
        }
        .padding(.top, 8)
    }

    private var perspectiveContent: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {

            // Visual element
            visualElement

            // Title and message
            VStack(spacing: DesignSystem.Spacing.large) {
                Text(currentReminder.title)
                    .font(DesignSystem.Typography.titleFallback)
                    .foregroundColor(currentReminder.accentColor)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(currentReminder.message)
                    .font(DesignSystem.Typography.bodyFallback)
                    .foregroundColor(currentReminder.accentColor.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, DesignSystem.Spacing.medium)
            }
        }
        .offset(x: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    let threshold: CGFloat = 50

                    if value.translation.width < -threshold {
                        // Swipe left - go to next
                        if currentReminderIndex < reminders.count - 1 {
                            HapticManager.shared.impact(.light)
                            withAnimation(.easeInOut) {
                                currentReminderIndex += 1
                                dragOffset = 0
                            }
                        } else {
                            withAnimation(.spring()) {
                                dragOffset = 0
                            }
                        }
                    } else if value.translation.width > threshold {
                        // Swipe right - go to previous
                        if currentReminderIndex > 0 {
                            HapticManager.shared.impact(.light)
                            withAnimation(.easeInOut) {
                                currentReminderIndex -= 1
                                dragOffset = 0
                            }
                        } else {
                            withAnimation(.spring()) {
                                dragOffset = 0
                            }
                        }
                    } else {
                        // Not enough swipe, bounce back
                        withAnimation(.spring()) {
                            dragOffset = 0
                        }
                    }
                }
        )
    }

    @ViewBuilder
    private var visualElement: some View {
        switch currentReminder.visualType {
        case .stars:
            StarsView()
        case .earth:
            EarthView()
        case .time:
            TimeView()
        case .timeFuture:
            TimeFutureView()
        case .space:
            SpaceView()
        }
    }

    private var navigationSection: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {

            // Progress dots
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(0..<reminders.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentReminderIndex ? currentReminder.accentColor : currentReminder.accentColor.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: currentReminderIndex)
                }
            }

            // Navigation buttons
            HStack(spacing: DesignSystem.Spacing.large) {
                if currentReminderIndex > 0 {
                    Button("Previous") {
                        HapticManager.shared.impact(.light)
                        withAnimation(.easeInOut) {
                            currentReminderIndex -= 1
                        }
                    }
                    .font(DesignSystem.Typography.bodyFallback)
                    .foregroundColor(currentReminder.accentColor.opacity(0.8))
                } else {
                    Text("")
                }

                Spacer()

                Button(currentReminderIndex == reminders.count - 1 ? "Finish" : "Next") {
                    HapticManager.shared.impact(.light)

                    withAnimation(.easeInOut) {
                        if currentReminderIndex < reminders.count - 1 {
                            currentReminderIndex += 1
                        } else {
                            hasViewedReminders = true
                            // Show a moment of reflection
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                showingSummary = true
                            }
                        }
                    }
                }
                .font(DesignSystem.Typography.bodyFallback)
                .foregroundColor(currentReminder.accentColor)
                .fontWeight(.semibold)
            }
        }
    }

    private var skipButton: some View {
        Button(action: {
            HapticManager.shared.impact(.soft)
            showingSummary = true
        }) {
            Text("Skip")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(currentReminder.accentColor.opacity(0.7))
                .frame(height: 48)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Visual Components

struct StarsView: View {
    @State private var twinkle = false

    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.4...1.0)))
                    .frame(width: CGFloat.random(in: 3...8), height: CGFloat.random(in: 3...8))
                    .position(
                        x: CGFloat.random(in: 0...300),
                        y: CGFloat.random(in: 0...200)
                    )
                    .opacity(twinkle ? 0.4 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 1...3)).repeatForever(autoreverses: true),
                        value: twinkle
                    )
            }
        }
        .frame(width: 300, height: 200)
        .onAppear {
            twinkle = true
        }
    }
}

struct EarthView: View {
    @State private var rotate = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.blue, Color.blue.opacity(0.7), Color.green.opacity(0.5)],
                        center: .center,
                        startRadius: 30,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .rotationEffect(.degrees(rotate ? 360 : 0))
                .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: rotate)

            // Continents (simplified)
            ForEach(0..<5, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.green.opacity(0.8))
                    .frame(
                        width: CGFloat.random(in: 20...40),
                        height: CGFloat.random(in: 15...25)
                    )
                    .offset(
                        x: CGFloat.random(in: -50...50),
                        y: CGFloat.random(in: -50...50)
                    )
            }
        }
        .onAppear {
            rotate = true
        }
    }
}

struct TimeView: View {
    @State private var waveOffset: CGFloat = 0
    @State private var hourglassRotation: Double = 0

    var body: some View {
        ZStack {
            // Flowing time waves
            ForEach(0..<3, id: \.self) { index in
                WaveShape(offset: waveOffset + CGFloat(index) * 0.3)
                    .stroke(
                        Color.white.opacity(0.6 - CGFloat(index) * 0.15),
                        lineWidth: 3
                    )
                    .frame(width: 200, height: 80)
                    .offset(y: CGFloat(index) * 20 - 20)
            }

            // Hourglass icon
            VStack(spacing: 8) {
                Image(systemName: "hourglass")
                    .font(.system(size: 40))
                    .foregroundColor(Color.white.opacity(0.9))
                    .rotationEffect(.degrees(hourglassRotation))

                Text("Passing")
                    .font(DesignSystem.Typography.captionFallback)
                    .foregroundColor(Color.white.opacity(0.85))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                waveOffset = 1.0
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                hourglassRotation = 180
            }
        }
    }
}

struct WaveShape: Shape {
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

        path.move(to: CGPoint(x: 0, y: midHeight))

        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let sine = sin((relativeX + offset) * .pi * 4)
            let y = midHeight + sine * 15
            path.addLine(to: CGPoint(x: x, y: y))
        }

        return path
    }
}

struct TimeFutureView: View {
    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.25), lineWidth: 4)
                .frame(width: 120, height: 120)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.white.opacity(0.8), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))

            VStack {
                Image(systemName: "clock")
                    .font(.system(size: 30))
                    .foregroundColor(Color.white.opacity(0.9))

                Text("Now")
                    .font(DesignSystem.Typography.captionFallback)
                    .foregroundColor(Color.white.opacity(0.85))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                progress = 1.0
            }
        }
    }
}

struct SpaceView: View {
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Galaxy spiral (these will animate)
            ForEach(0..<3, id: \.self) { ring in
                Circle()
                    .stroke(Color.white.opacity(0.4), lineWidth: 2)
                    .frame(width: CGFloat(80 + ring * 40), height: CGFloat(80 + ring * 40))
                    .scaleEffect(scale)
            }

            // Center (will animate)
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: 8, height: 8)
                .scaleEffect(scale)

            // You are here indicator - stays fixed, doesn't scale
            VStack(spacing: 2) {
                Text("⭐️")
                    .font(.system(size: 14))
                Text("You")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.95))
            }
            .offset(x: 85, y: -85)
        }
        .frame(width: 260, height: 260)
        .onAppear {
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                scale = 1.2
            }
        }
    }
}

#Preview {
    PerspectiveShiftView(navigateToDashboard: {})
}
