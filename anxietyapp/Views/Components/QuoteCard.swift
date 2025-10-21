//
//  QuoteCard.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import SwiftUI

struct QuoteCard: View {
    let quote: String
    let author: String?

    init(_ quote: String, author: String? = nil) {
        self.quote = quote
        self.author = author
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text("\"" + quote + "\"")
                .font(DesignSystem.Typography.bodyFallback)
                .foregroundColor(Color.secondaryText)
                .multilineTextAlignment(.leading)
                .lineLimit(3)

            if let author = author {
                HStack {
                    Spacer()
                    Text("— " + author)
                        .font(DesignSystem.Typography.captionFallback)
                        .foregroundColor(Color.secondaryText.opacity(0.8))
                }
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(Color.primaryBackground)
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .shadow(color: DesignSystem.Shadow.soft, radius: 4, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 20) {
        QuoteCard("This feeling will pass.", author: "Nuvin")
        QuoteCard("You are stronger than this moment.")
    }
    .padding()
}