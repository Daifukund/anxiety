//
//  OnboardingRewiringBenefitsView.swift
//  anxietyapp
//
//  Created by Claude Code
//

import SwiftUI

struct OnboardingRewiringBenefitsView: View {
    let onContinue: () -> Void

    @State private var animateGraph = false

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.large) {
                // Header
                VStack(spacing: DesignSystem.Spacing.small) {
                    Text("Rewiring Benefits")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.textDark)
                }
                .padding(.top, DesignSystem.Spacing.large)

                // Progress graph
                progressGraph
                    .padding(.top, DesignSystem.Spacing.medium)

                // Text below graph
                Text("Small daily practices with Nuvin change your brain over time, and you'll feel the difference. 📈")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.textDark)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, DesignSystem.Spacing.large)
                    .padding(.top, DesignSystem.Spacing.medium)

                // Continue button
                OnboardingButton(title: "Continue", action: onContinue)
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .padding(.top, DesignSystem.Spacing.small)
                .padding(.bottom, DesignSystem.Spacing.large)
            }
        }
        .gradientBackground()
    }

    // MARK: - Progress Graph
    private var progressGraph: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text("Anxiety level over time")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.textDark)

            VStack(spacing: DesignSystem.Spacing.small) {
                // Graph area
                GeometryReader { geometry in
                    ZStack(alignment: .bottomLeading) {
                        // Background grid
                        VStack(spacing: 0) {
                            ForEach(0..<4) { _ in
                                Divider()
                                    .background(Color.borderGray.opacity(0.3))
                                Spacer()
                            }
                            Divider()
                                .background(Color.borderGray.opacity(0.3))
                        }
                        .padding(.vertical, 8)

                        // Gradient fill under "with app" line
                        if animateGraph {
                            Path { path in
                                let points = [0.7, 0.55, 0.4, 0.3, 0.22]
                                let width = geometry.size.width
                                let height = geometry.size.height - 16
                                let step = width / CGFloat(points.count - 1)

                                path.move(to: CGPoint(x: 0, y: height * (1 - points[0]) + 8))
                                for (index, point) in points.enumerated() {
                                    path.addLine(to: CGPoint(x: CGFloat(index) * step, y: height * (1 - point) + 8))
                                }
                                path.addLine(to: CGPoint(x: CGFloat(points.count - 1) * step, y: height + 8))
                                path.addLine(to: CGPoint(x: 0, y: height + 8))
                                path.closeSubpath()
                            }
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.primaryPurple.opacity(0.18),
                                        Color.primaryPurple.opacity(0.03)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .transition(.opacity)
                        }

                        // Without app line (erratic/uncontrolled) with dashed style
                        Path { path in
                            let points = [0.7, 0.85, 0.6, 0.95, 0.7]
                            let width = geometry.size.width
                            let height = geometry.size.height - 16
                            let step = width / CGFloat(points.count - 1)

                            path.move(to: CGPoint(x: 0, y: height * (1 - points[0]) + 8))
                            for (index, point) in points.enumerated() {
                                path.addLine(to: CGPoint(x: CGFloat(index) * step, y: height * (1 - point) + 8))
                            }
                        }
                        .trim(from: 0, to: animateGraph ? 1 : 0)
                        .stroke(Color.emergencyRed.opacity(0.6), style: StrokeStyle(lineWidth: 2.5, dash: [6, 4]))
                        .animation(.easeInOut(duration: 1.5), value: animateGraph)

                        // Without app data points
                        if animateGraph {
                            let points = [0.7, 0.85, 0.6, 0.95, 0.7]
                            ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                                Circle()
                                    .fill(Color.emergencyRed.opacity(0.6))
                                    .frame(width: 5, height: 5)
                                    .position(
                                        x: CGFloat(index) * (geometry.size.width / CGFloat(points.count - 1)),
                                        y: (geometry.size.height - 16) * (1 - point) + 8
                                    )
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }

                        // With app line (declining)
                        Path { path in
                            let points = [0.7, 0.55, 0.4, 0.3, 0.22]
                            let width = geometry.size.width
                            let height = geometry.size.height - 16
                            let step = width / CGFloat(points.count - 1)

                            path.move(to: CGPoint(x: 0, y: height * (1 - points[0]) + 8))
                            for (index, point) in points.enumerated() {
                                path.addLine(to: CGPoint(x: CGFloat(index) * step, y: height * (1 - point) + 8))
                            }
                        }
                        .trim(from: 0, to: animateGraph ? 1 : 0)
                        .stroke(Color.primaryPurple, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        .animation(.easeInOut(duration: 1.5).delay(0.3), value: animateGraph)

                        // With app data points
                        if animateGraph {
                            let points = [0.7, 0.55, 0.4, 0.3, 0.22]
                            ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 7, height: 7)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primaryPurple, lineWidth: 2.5)
                                    )
                                    .position(
                                        x: CGFloat(index) * (geometry.size.width / CGFloat(points.count - 1)),
                                        y: (geometry.size.height - 16) * (1 - point) + 8
                                    )
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                }
                .frame(height: 180)

                // X-axis label
                HStack {
                Text("Week 1")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textLight)

                Spacer()

                Text("Week 2")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textLight)

                Spacer()

                Text("Week 3")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textLight)
                }
                .padding(.horizontal, 8)

                // Legend
                HStack(spacing: DesignSystem.Spacing.medium) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.emergencyRed.opacity(0.6))
                        .frame(width: 20, height: 3)
                    Text("Without Nuvin")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.textMedium)
                }

                HStack(spacing: DesignSystem.Spacing.xs) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.primaryPurple)
                        .frame(width: 20, height: 3)
                    Text("With Nuvin")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.textMedium)
                }
                }
                .padding(.top, DesignSystem.Spacing.xs)
                .frame(maxWidth: .infinity)
            }
            .padding(DesignSystem.Spacing.medium)
            .background(Color.secondaryViolet)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .stroke(Color.primaryPurple.opacity(0.2), lineWidth: 1.5)
            )
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).delay(0.3)) {
                animateGraph = true
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.medium)
    }
}

#Preview {
    OnboardingRewiringBenefitsView(onContinue: {})
}
