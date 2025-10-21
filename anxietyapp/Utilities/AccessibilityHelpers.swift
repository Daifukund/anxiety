//
//  AccessibilityHelpers.swift
//  anxietyapp
//
//  Accessibility utilities and extensions for better VoiceOver support
//

import SwiftUI

// MARK: - Dynamic Type Scale Categories

extension Font {
    /// Dynamic font that scales with user's accessibility text size preferences
    static func scaledFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        return .system(size: size, weight: weight, design: design)
    }

    /// Title font that respects Dynamic Type
    static var accessibleTitle: Font {
        return .system(.title, design: .rounded, weight: .bold)
    }

    /// Body font that respects Dynamic Type
    static var accessibleBody: Font {
        return .body
    }

    /// Caption font that respects Dynamic Type
    static var accessibleCaption: Font {
        return .caption
    }

    /// Large title for important content
    static var accessibleLargeTitle: Font {
        return .largeTitle
    }

    /// Headline for section headers
    static var accessibleHeadline: Font {
        return .headline
    }

    /// Subheadline for supporting text
    static var accessibleSubheadline: Font {
        return .subheadline
    }
}

// MARK: - Minimum Touch Target

extension View {
    /// Ensures minimum 44x44 touch target as per Apple HIG
    func minimumTouchTarget(width: CGFloat = 44, height: CGFloat = 44) -> some View {
        self.frame(minWidth: width, minHeight: height)
    }

    /// Standard minimum touch target (44x44)
    func standardTouchTarget() -> some View {
        self.minimumTouchTarget(width: 44, height: 44)
    }
}

// MARK: - Accessibility Traits Helper

extension View {
    /// Makes element a button with proper traits
    func accessibleButton(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isButton)
            .accessibilityHint(hint ?? "")
    }

    /// Makes element a header
    func accessibleHeader(label: String) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isHeader)
    }

    /// Makes element an image with description
    func accessibleImage(label: String) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isImage)
    }

    /// Makes element a selectable item
    func accessibleSelectable(label: String, isSelected: Bool) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - VoiceOver Helper

struct VoiceOverHelper {
    /// Check if VoiceOver is currently running
    static var isVoiceOverRunning: Bool {
        return UIAccessibility.isVoiceOverRunning
    }

    /// Check if user prefers reduced motion
    static var isReduceMotionEnabled: Bool {
        return UIAccessibility.isReduceMotionEnabled
    }

    /// Check if user prefers reduced transparency
    static var isReduceTransparencyEnabled: Bool {
        return UIAccessibility.isReduceTransparencyEnabled
    }

    /// Post accessibility announcement
    static func announce(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    /// Post screen changed notification (when view changes significantly)
    static func screenChanged() {
        UIAccessibility.post(notification: .screenChanged, argument: nil)
    }
}

// MARK: - Accessibility Environment

extension EnvironmentValues {
    var isVoiceOverRunning: Bool {
        UIAccessibility.isVoiceOverRunning
    }

    var isReduceMotionEnabled: Bool {
        UIAccessibility.isReduceMotionEnabled
    }
}

// MARK: - Scale Factor for Dynamic Type

extension View {
    /// Get the current Dynamic Type scale factor
    @ViewBuilder
    func adaptivePadding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        self.padding(edges, length)
    }
}

// MARK: - Common Accessibility Labels

enum AccessibilityLabels {
    // Navigation
    static let settings = "Settings"
    static let back = "Back"
    static let close = "Close"
    static let done = "Done"

    // Actions
    static let play = "Play"
    static let pause = "Pause"
    static let stop = "Stop"
    static let next = "Next"
    static let previous = "Previous"

    // Mood
    static func moodValue(_ value: Int) -> String {
        switch value {
        case 1...2: return "Very anxious, rated \(value) out of 10"
        case 3...4: return "Anxious, rated \(value) out of 10"
        case 5...6: return "Neutral, rated \(value) out of 10"
        case 7...8: return "Calm, rated \(value) out of 10"
        case 9...10: return "Very calm, rated \(value) out of 10"
        default: return "Mood rated \(value) out of 10"
        }
    }

    static func moodEmoji(_ moodValue: Double) -> String {
        switch moodValue {
        case 0..<2: return "Very anxious face"
        case 2..<4: return "Anxious face"
        case 4..<6: return "Neutral face"
        case 6..<8: return "Calm face"
        case 8...10: return "Very calm face"
        default: return "Mood indicator"
        }
    }
}

// MARK: - Accessibility Modifiers

struct AccessibilityModifier: ViewModifier {
    let label: String
    let hint: String?
    let traits: AccessibilityTraits
    let value: String?

    func body(content: Content) -> some View {
        content
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
            .accessibilityValue(value ?? "")
    }
}

extension View {
    func accessibility(
        label: String,
        hint: String? = nil,
        traits: AccessibilityTraits = [],
        value: String? = nil
    ) -> some View {
        self.modifier(AccessibilityModifier(
            label: label,
            hint: hint,
            traits: traits,
            value: value
        ))
    }
}
