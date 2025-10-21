//
//  DailyQuote.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct DailyQuote: View {
    @ObservedObject private var userDataService = UserDataService.shared
    @State private var currentQuote: Quote
    @State private var showingQuoteCategories = false

    init() {
        _currentQuote = State(initialValue: Quote.getDailyQuote())
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.small) {

            // Category and refresh button
            HStack {
                Button(action: {
                    showingQuoteCategories = true
                }) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Circle()
                            .fill(currentQuote.category.color)
                            .frame(width: 8, height: 8)

                        Text(currentQuote.category.displayName)
                            .font(DesignSystem.Typography.captionFallback)
                            .foregroundColor(currentQuote.category.color)
                    }
                }

                Spacer()

                Button(action: refreshQuote) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                }
            }

            // Quote content
            QuoteCard(currentQuote.text, author: currentQuote.author)
                .onTapGesture {
                    refreshQuote()
                }
        }
        .sheet(isPresented: $showingQuoteCategories) {
            QuoteCategorySheet(selectedQuote: $currentQuote)
        }
        .onAppear {
            updateQuoteForMood()
        }
    }

    private func refreshQuote() {
        // Get quote appropriate for current mood if available
        if let todaysMoodValue = userDataService.getTodaysMoodValue() {
            let moodQuotes = Quote.getQuotesForMoodValue(todaysMoodValue)
            currentQuote = moodQuotes.randomElement() ?? Quote.getRandomQuote()
        } else {
            currentQuote = Quote.getRandomQuote()
        }

        // Light haptic feedback
        #if os(iOS)
        HapticManager.shared.impact(.light)
        #endif
    }

    private func updateQuoteForMood() {
        if let todaysMoodValue = userDataService.getTodaysMoodValue() {
            let moodQuotes = Quote.getQuotesForMoodValue(todaysMoodValue)
            if !moodQuotes.contains(where: { $0.id == currentQuote.id }) {
                currentQuote = moodQuotes.randomElement() ?? currentQuote
            }
        }
    }
}

struct QuoteCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedQuote: Quote

    var body: some View {
        NavigationView {
            VStack(spacing: DesignSystem.Spacing.large) {

                Text("Choose Your Inspiration")
                    .font(DesignSystem.Typography.titleFallback)
                    .foregroundColor(Color.primaryText)
                    .padding(.top, DesignSystem.Spacing.medium)

                VStack(spacing: DesignSystem.Spacing.medium) {
                    ForEach(Quote.Category.allCases, id: \.rawValue) { category in
                        QuoteCategoryCard(category: category) {
                            selectedQuote = Quote.getRandomQuote(from: category)
                            dismiss()
                        }
                    }
                }

                Spacer()
            }
            .padding(DesignSystem.Spacing.medium)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct QuoteCategoryCard: View {
    let category: Quote.Category
    let action: () -> Void

    private var categoryDescription: String {
        switch category {
        case .calming:
            return "Gentle reminders that this moment will pass"
        case .existential:
            return "Big picture perspective to shrink your worries"
        case .motivational:
            return "Empowering words to take action"
        }
    }

    private var categoryExample: String {
        switch category {
        case .calming:
            return "\"This is just a feeling. Feelings are not forever.\""
        case .existential:
            return "\"You are a speck on a rock spinning through space.\""
        case .motivational:
            return "\"You've already survived 100% of your bad days.\""
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {

                HStack {
                    Circle()
                        .fill(category.color)
                        .frame(width: 12, height: 12)

                    Text(category.displayName)
                        .font(DesignSystem.Typography.subtitleFallback)
                        .foregroundColor(Color.primaryText)
                        .fontWeight(.semibold)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(Color.secondaryText)
                }

                Text(categoryDescription)
                    .font(DesignSystem.Typography.bodyFallback)
                    .foregroundColor(Color.secondaryText)
                    .multilineTextAlignment(.leading)

                Text(categoryExample)
                    .font(DesignSystem.Typography.captionFallback)
                    .foregroundColor(category.color)
                    .italic()
                    .multilineTextAlignment(.leading)
            }
            .padding(DesignSystem.Spacing.medium)
            .background(category.color.opacity(0.05))
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(category.color.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DailyQuote()
        .padding()
}