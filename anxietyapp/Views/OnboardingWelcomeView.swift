//
//  OnboardingWelcomeView.swift
//  anxietyapp
//
//  Created by Claude Code
//

import SwiftUI

struct OnboardingWelcomeView: View {
    let onContinue: () -> Void

    @State private var animationOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                // Mountain sunrise background image
                Image("welcome")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .edgesIgnoringSafeArea(.all)

                // Dark gradient at bottom for better text visibility
                VStack {
                    Spacer()
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.black.opacity(0.5),
                            Color.black.opacity(0.75)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 350)
                }
                .edgesIgnoringSafeArea(.all)

                VStack(alignment: .center, spacing: 0) {
                    // App name at top (centered) - just below Dynamic Island
                    Text("Nuvin")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: geometry.size.width)
                        .multilineTextAlignment(.center)
                        .padding(.top, 60)

                    Spacer()
                        .frame(height: 175)

                    // Welcome message (moved up, centered)
                    VStack(alignment: .center, spacing: DesignSystem.Spacing.small) {
                        Text("Welcome")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: geometry.size.width)
                            .multilineTextAlignment(.center)

//                        Text("You're in a safe place.")
//                            .font(.system(size: 22, weight: .medium))
//                            .foregroundColor(.black)
//                            .frame(width: geometry.size.width)
//                            .multilineTextAlignment(.center)
                    }

                    Spacer()

                    // Bottom section - white text on dark gradient
                    VStack(alignment: .center, spacing: DesignSystem.Spacing.small) {
                        // 5 star rating with label
                        VStack(alignment: .center, spacing: DesignSystem.Spacing.xs) {
                            StarRating(count: 5)
                                .frame(width: geometry.size.width)
                            Text("Trusted by thousands")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .frame(width: geometry.size.width)
                                .multilineTextAlignment(.center)
                        }

                        // Science backing message
                        Text("Our methods are backed by science.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                            .frame(width: geometry.size.width)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DesignSystem.Spacing.large)
                            .padding(.top, 4)

                        // Start Quiz button (compact)
                        Button(action: onContinue) {
                            Text("Start Quiz")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 48)
                                .padding(.vertical, 14)
                                .background(Color.primaryPurple)
                                .cornerRadius(12)
                        }
                        .frame(width: geometry.size.width)
                        .padding(.top, DesignSystem.Spacing.medium)
                    }
                    .padding(.bottom, 50)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// Animated sunset/sunrise gradient background
struct AnimatedSunsetGradient: View {
    @State private var animationPhase: CGFloat = 0

    var body: some View {
        ZStack {
            // Base gradient (sunset colors)
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.85, blue: 0.70).opacity(0.3 + animationPhase * 0.2),
                    Color(red: 0.95, green: 0.75, blue: 0.85).opacity(0.3 + animationPhase * 0.2),
                    Color(red: 0.90, green: 0.85, blue: 0.95),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Subtle mountain silhouette
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height

                    // Mountain peaks
                    path.move(to: CGPoint(x: 0, y: height * 0.7))
                    path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.5))
                    path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.6))
                    path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.45))
                    path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.65))
                    path.addLine(to: CGPoint(x: width, y: height * 0.55))
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.addLine(to: CGPoint(x: 0, y: height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [
                            Color.primaryPurple.opacity(0.1),
                            Color.white.opacity(0.3)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(
                .easeInOut(duration: 8.0)
                .repeatForever(autoreverses: true)
            ) {
                animationPhase = 1.0
            }
        }
    }
}

#Preview {
    OnboardingWelcomeView(onContinue: {})
}
