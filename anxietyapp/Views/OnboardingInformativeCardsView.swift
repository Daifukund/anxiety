//
//  OnboardingInformativeCardsView.swift
//  anxietyapp
//
//  Created by Claude Code
//

import SwiftUI

struct OnboardingInformativeCardsView: View {
    let onContinue: () -> Void

    @State private var currentPage = 0
    private let totalPages = 8

    // Calculate position within current section (red or blue cards)
    private var currentPageInSection: Int {
        currentPage % 4
    }

    var body: some View {
        ZStack {
            // Dynamic background color based on current page
            (currentPage < 4 ? Color.emergencyRed : Color.primaryPurple)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // App name at top
                Text("Nuvin")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, DesignSystem.Spacing.medium)

                // Card content
                TabView(selection: $currentPage) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        cardView(for: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Page indicator with color coding - separate dots for red and blue cards
                HStack(spacing: 6) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(currentPageInSection == index ? Color.white : Color.white.opacity(0.4))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, DesignSystem.Spacing.small)

                // Navigation buttons - Next only
                Button(action: {
                    if currentPage < totalPages - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        onContinue()
                    }
                }) {
                    Text(currentPage == totalPages - 1 ? "Continue" : "Next")
                        .font(DesignSystem.Typography.button)
                        .foregroundColor(currentPage < 4 ? Color.emergencyRed : Color.primaryPurple)
                        .frame(height: 48)
                        .padding(.horizontal, 48)
                        .background(Color.white)
                        .cornerRadius(DesignSystem.CornerRadius.pill)
                }
                .padding(DesignSystem.Spacing.medium)
            }
        }
    }

    @ViewBuilder
    private func cardView(for index: Int) -> some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()

            if index < 4 {
                // Red cards (challenges)
                redCard(for: index)
            } else {
                // Blue cards (solutions)
                blueCard(for: index - 4)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Red Cards (Challenges)
    @ViewBuilder
    private func redCard(for index: Int) -> some View {
        let content: (title: String, icon: String, text: () -> Text) = {
            switch index {
            case 0:
                return (
                    "You're not alone",
                    "person.2.fill",
                    {
                        Text("Anxiety is the ")
                        + Text("most common mental health challenge").bold()
                        + Text(" worldwide, leading to sadness and low motivation.")
                    }
                )
            case 1:
                return (
                    "Modern stress overload",
                    "bolt.fill",
                    {
                        Text("Stress was meant to protect us, but in ")
                        + Text("modern life").bold()
                        + Text(" it's triggered by work, money, and relationships, ")
                        + Text("all the time").bold()
                        + Text(".")
                    }
                )
            case 2:
                return (
                    "Trapped in past or future",
                    "clock.arrow.circlepath",
                    {
                        Text("Suffering often comes from being stuck in the ")
                        + Text("past with regret").bold()
                        + Text(" or lost in the ")
                        + Text("future with worry").bold()
                        + Text(".")
                    }
                )
            case 3:
                return (
                    "When anxiety shows up",
                    "exclamationmark.triangle.fill",
                    {
                        Text("Anxiety often shows up as ")
                        + Text("overthinking, perfectionism, trouble sleeping, or toxic relationships").bold()
                        + Text(".")
                    }
                )
            default:
                return ("", "", { Text("") })
            }
        }()

        VStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: content.icon)
                .font(.system(size: 60))
                .foregroundColor(.white)

            Text(content.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            content.text()
                .font(DesignSystem.Typography.bodyFont)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
        }
        .padding(DesignSystem.Spacing.large)
    }

    // MARK: - Blue Cards (Solutions)
    @ViewBuilder
    private func blueCard(for index: Int) -> some View {
        let content: (title: String, icon: String, text: () -> Text) = {
            switch index {
            case 0:
                return (
                    "Return to now",
                    "arrow.uturn.backward.circle.fill",
                    {
                        Text("True calm is found in the ")
                        + Text("present moment").bold()
                        + Text("; this app helps you return there.")
                    }
                )
            case 1:
                return (
                    "Science on your side",
                    "brain.head.profile",
                    {
                        Text("Science-backed exercises ")
                        + Text("rewire your brain").bold()
                        + Text(" and release stress in ")
                        + Text("minutes").bold()
                        + Text(".")
                    }
                )
            case 2:
                return (
                    "Your journey forward",
                    "chart.line.uptrend.xyaxis",
                    {
                        Text("Daily check-ins keep you ")
                        + Text("motivated").bold()
                        + Text(" and help you ")
                        + Text("track your progress").bold()
                        + Text(".")
                    }
                )
            case 3:
                return (
                    "Conquer yourself",
                    "mountain.2.fill",
                    {
                        Text("With practice, you can ")
                        + Text("conquer anxiety").bold()
                        + Text(" and build ")
                        + Text("lasting progress").bold()
                        + Text(".")
                    }
                )
            default:
                return ("", "", { Text("") })
            }
        }()

        VStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: content.icon)
                .font(.system(size: 60))
                .foregroundColor(.white)

            Text(content.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            content.text()
                .font(DesignSystem.Typography.bodyFont)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
        }
        .padding(DesignSystem.Spacing.large)
    }
}

#Preview {
    OnboardingInformativeCardsView(onContinue: {})
}
