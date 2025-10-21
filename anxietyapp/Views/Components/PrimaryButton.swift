//
//  PrimaryButton.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    let style: ButtonStyle

    enum ButtonStyle {
        case primary
        case secondary
        case emergency
    }

    var backgroundColor: Color {
        switch style {
        case .primary:
            return Color.softViolet
        case .secondary:
            return Color.lightBlue
        case .emergency:
            return Color.sosRed
        }
    }

    var textColor: Color {
        return .white
    }

    init(_ title: String, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignSystem.Typography.buttonFallback)
                .foregroundColor(textColor)
                .padding(.horizontal, DesignSystem.Spacing.large)
                .padding(.vertical, DesignSystem.Spacing.small)
                .background(backgroundColor)
                .cornerRadius(DesignSystem.CornerRadius.pill)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SOSButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("🚨")
                    .font(.system(size: 40))
                Text("I NEED RELIEF NOW")
                    .font(DesignSystem.Typography.buttonFallback)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.vertical, DesignSystem.Spacing.large)
            .background(Color.sosRed)
            .cornerRadius(DesignSystem.CornerRadius.large)
            .shadow(color: DesignSystem.Shadow.medium, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(DesignSystem.Animation.quick, value: 1.0)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton("Primary Button", style: .primary) {}
        PrimaryButton("Secondary Button", style: .secondary) {}
        PrimaryButton("Emergency Button", style: .emergency) {}
        SOSButton {}
    }
    .padding()
}