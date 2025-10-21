//
//  DesignSystem.swift
//  anxietyapp
//
//  Created by Claude Code on 29/09/2025.
//

import SwiftUI

struct DesignSystem {

    // MARK: - Spacing (8px grid system)
    enum Spacing {
        static let xs: CGFloat = 8
        static let small: CGFloat = 16
        static let medium: CGFloat = 24
        static let large: CGFloat = 32
        static let xl: CGFloat = 48
        static let xxl: CGFloat = 64
    }

    // MARK: - Typography (SF Pro - native iOS)
    enum Typography {
        // Question titles / Headings
        static let questionTitle = Font.system(size: 22, weight: .bold) // 20-22pt Bold (700)

        // Answer text / Body
        static let answerText = Font.system(size: 18, weight: .regular) // 17-18pt Regular (400)

        // Button text
        static let button = Font.system(size: 18, weight: .semibold) // 18pt Semi-bold (600)

        // Small helper text
        static let helperText = Font.system(size: 14, weight: .regular) // 14pt Regular

        // Legacy aliases (for backward compatibility)
        static let titleFont = questionTitle
        static let subtitleFont = Font.system(size: 20, weight: .medium)
        static let bodyFont = answerText
        static let captionFont = helperText
        static let buttonFont = button

        static let titleFallback = questionTitle
        static let subtitleFallback = Font.system(size: 20, weight: .medium)
        static let bodyFallback = answerText
        static let captionFallback = helperText
        static let buttonFallback = button
    }

    // MARK: - Corner Radius
    enum CornerRadius {
        static let small: CGFloat = 8
        static let button: CGFloat = 12  // 12-14pt radius for buttons
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let pill: CGFloat = 50
    }

    // MARK: - Shadows
    enum Shadow {
        static let soft = Color.textDark.opacity(0.1)
        static let medium = Color.textDark.opacity(0.15)
        static let strong = Color.textDark.opacity(0.2)
    }

    // MARK: - Button Heights
    enum ButtonHeight {
        static let primary: CGFloat = 56  // Full-width primary buttons
        static let standard: CGFloat = 48 // Standard buttons
    }

    // MARK: - Animation
    enum Animation {
        static let quick = SwiftUI.Animation.easeOut(duration: 0.2)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let breathing = SwiftUI.Animation.easeInOut(duration: 4.0)
    }
}