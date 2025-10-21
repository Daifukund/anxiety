//
//  LegalDocumentView.swift
//  anxietyapp
//
//  Created by Claude Code
//

import SwiftUI

enum LegalDocument {
    case terms
    case privacy

    var title: String {
        switch self {
        case .terms: return "Terms of Service"
        case .privacy: return "Privacy Policy"
        }
    }

    var fileName: String {
        switch self {
        case .terms: return "TermsOfService"
        case .privacy: return "PrivacyPolicy"
        }
    }
}

struct LegalDocumentView: View {
    let document: LegalDocument
    @Environment(\.dismiss) var dismiss

    @State private var content: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                    if content.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        MarkdownText(content)
                            .padding(DesignSystem.Spacing.large)
                    }
                }
            }
            .navigationTitle(document.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryPurple)
                }
            }
        }
        .onAppear {
            loadDocument()
        }
    }

    private func loadDocument() {
        guard let url = Bundle.main.url(forResource: document.fileName, withExtension: "md"),
              let text = try? String(contentsOf: url) else {
            content = "Unable to load \(document.title). Please try again later."
            return
        }
        content = text
    }
}

// MARK: - Markdown Text Renderer
struct MarkdownText: View {
    let markdown: String

    init(_ markdown: String) {
        self.markdown = markdown
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            ForEach(parseMarkdown(), id: \.id) { element in
                element.view
            }
        }
    }

    private func parseMarkdown() -> [MarkdownElement] {
        var elements: [MarkdownElement] = []
        let lines = markdown.components(separatedBy: .newlines)

        for line in lines {
            if line.hasPrefix("# ") {
                elements.append(.heading1(String(line.dropFirst(2))))
            } else if line.hasPrefix("## ") {
                elements.append(.heading2(String(line.dropFirst(3))))
            } else if line.hasPrefix("### ") {
                elements.append(.heading3(String(line.dropFirst(4))))
            } else if line.hasPrefix("**") && line.hasSuffix("**") {
                let text = String(line.dropFirst(2).dropLast(2))
                elements.append(.bold(text))
            } else if line.hasPrefix("- ") || line.hasPrefix("* ") {
                elements.append(.bullet(String(line.dropFirst(2))))
            } else if line.trimmingCharacters(in: .whitespaces).isEmpty {
                elements.append(.spacing)
            } else {
                elements.append(.paragraph(line))
            }
        }

        return elements
    }
}

// MARK: - Markdown Elements
enum MarkdownElement {
    case heading1(String)
    case heading2(String)
    case heading3(String)
    case paragraph(String)
    case bold(String)
    case bullet(String)
    case spacing

    var id: String {
        UUID().uuidString
    }

    @ViewBuilder
    var view: some View {
        switch self {
        case .heading1(let text):
            Text(text)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.textDark)
                .padding(.top, DesignSystem.Spacing.small)

        case .heading2(let text):
            Text(text)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.textDark)
                .padding(.top, DesignSystem.Spacing.medium)

        case .heading3(let text):
            Text(text)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.textDark)
                .padding(.top, DesignSystem.Spacing.small)

        case .paragraph(let text):
            Text(parseInlineMarkdown(text))
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.textMedium)
                .lineSpacing(4)

        case .bold(let text):
            Text(text)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.textDark)

        case .bullet(let text):
            HStack(alignment: .top, spacing: DesignSystem.Spacing.xs) {
                Text("•")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.textMedium)
                Text(parseInlineMarkdown(text))
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.textMedium)
                    .lineSpacing(4)
            }
            .padding(.leading, DesignSystem.Spacing.medium)

        case .spacing:
            Spacer()
                .frame(height: 4)
        }
    }

    private func parseInlineMarkdown(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)

        // Handle bold **text** - simple string search
        var searchText = text
        while let startRange = searchText.range(of: "**") {
            let afterStart = searchText[startRange.upperBound...]
            if let endRange = afterStart.range(of: "**") {
                let boldText = String(afterStart[..<endRange.lowerBound])
                let fullPattern = "**\(boldText)**"

                if let attrRange = attributed.range(of: fullPattern) {
                    var boldAttributed = AttributedString(boldText)
                    boldAttributed.font = .system(size: 15, weight: .bold)
                    attributed.replaceSubrange(attrRange, with: boldAttributed)
                }

                // Move search position forward
                searchText = String(afterStart[endRange.upperBound...])
            } else {
                break
            }
        }

        return attributed
    }
}

#Preview {
    LegalDocumentView(document: .terms)
}
