//
//  Colors.swift
//  anxietyapp
//
//  Design System Colors
//  Based on UX/UI guidelines for anxiety relief app
//

import SwiftUI

// MARK: - Dark Mode Environment Key
private struct DarkModeKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isDarkMode: Bool {
        get { self[DarkModeKey.self] }
        set { self[DarkModeKey.self] = newValue }
    }
}

extension View {
    func darkMode(_ enabled: Bool) -> some View {
        environment(\.isDarkMode, enabled)
    }
}

// MARK: - Design System Colors
extension Color {

    // MARK: - Hex Color Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // MARK: - Primary Accent (Purple)
    /// Primary purple for buttons, highlights, progress bars, selection borders
    static let primaryPurple = Color(red: 0x7B/255, green: 0x61/255, blue: 0xFF/255) // #7B61FF

    /// Pressed state for primary purple buttons
    static let primaryPurplePressed = Color(red: 0x6A/255, green: 0x52/255, blue: 0xE8/255) // #6A52E8

    // MARK: - Secondary Accent (Light Violet)
    /// Light violet for hover states, backgrounds, soft highlights
    static let secondaryViolet = Color(red: 0xED/255, green: 0xEB/255, blue: 0xFF/255) // #EDEBFF

    // MARK: - Emergency Color (Red)
    /// Red for SOS button and error states
    static let emergencyRed = Color(red: 0xFF/255, green: 0x3B/255, blue: 0x30/255) // #FF3B30

    /// Pressed state for emergency red button
    static let emergencyRedPressed = Color(red: 0xE6/255, green: 0x32/255, blue: 0x28/255) // #E63228

    // MARK: - Neutral Palette (Text & Borders)
    /// Dark text color
    static let textDark = Color(red: 0x1C/255, green: 0x1C/255, blue: 0x1E/255) // #1C1C1E

    /// Medium text color
    static let textMedium = Color(red: 0x3C/255, green: 0x3C/255, blue: 0x43/255) // #3C3C43

    /// Light text color (for secondary/helper text)
    static let textLight = Color(red: 0x8E/255, green: 0x8E/255, blue: 0x93/255) // #8E8E93

    /// Border and divider color
    static let borderGray = Color(red: 0xE5/255, green: 0xE5/255, blue: 0xEA/255) // #E5E5EA

    /// Pure white
    static let pureWhite = Color.white // #FFFFFF

    // MARK: - Disabled States
    /// Disabled background color
    static let disabledBackground = Color(red: 0xE5/255, green: 0xE5/255, blue: 0xEA/255) // #E5E5EA

    /// Disabled text color
    static let disabledText = Color(red: 0x8E/255, green: 0x8E/255, blue: 0x93/255) // #8E8E93

    // MARK: - Legacy Aliases (for backward compatibility)
    static let primaryBackground = Color.white
    static let secondaryBackground = Color(red: 0.98, green: 0.98, blue: 0.98)
    static let supportGray = Color(red: 0.95, green: 0.95, blue: 0.95)
    static let dividerGray = borderGray

    static let accentViolet = primaryPurple
    static let accentVioletPressed = primaryPurplePressed

    static let primaryText = textDark
    static let secondaryText = textMedium
    static let tertiaryText = textLight

    static let sosRed = emergencyRed
    static let sosRedPressed = emergencyRedPressed

    // MARK: - Supporting Colors (for mood tracking, etc.)
    static let lightBlue = Color(red: 0.60, green: 0.80, blue: 1.0)
    static let success = Color(red: 0.40, green: 0.80, blue: 0.60)
    static let warning = Color(red: 1.0, green: 0.75, blue: 0.40)

    static let softViolet = primaryPurple
    static let breathingGradient = LinearGradient(
        colors: [primaryPurple.opacity(0.3), lightBlue.opacity(0.3)],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Dark Mode Colors
    // Background Colors
    static let darkPrimaryBackground = Color(red: 0x1A/255, green: 0x1A/255, blue: 0x1E/255) // #1A1A1E - Deep charcoal
    static let darkSecondaryBackground = Color(red: 0x25/255, green: 0x25/255, blue: 0x2A/255) // #25252A - Elevated surface
    static let darkSupportGray = Color(red: 0x2F/255, green: 0x2F/255, blue: 0x35/255) // #2F2F35 - Card backgrounds

    // Text Colors (inverted for dark mode)
    static let darkTextPrimary = Color(red: 0xF5/255, green: 0xF5/255, blue: 0xF7/255) // #F5F5F7 - Almost white
    static let darkTextSecondary = Color(red: 0xC7/255, green: 0xC7/255, blue: 0xCC/255) // #C7C7CC - Medium gray
    static let darkTextTertiary = Color(red: 0x8E/255, green: 0x8E/255, blue: 0x93/255) // #8E8E93 - Dim gray

    // Borders and Dividers
    static let darkBorderGray = Color(red: 0x38/255, green: 0x38/255, blue: 0x3C/255) // #38383C - Subtle borders
    static let darkDividerGray = Color(red: 0x48/255, green: 0x48/255, blue: 0x4C/255) // #48484C - Visible dividers

    // Secondary Violet (adjusted for dark mode)
    static let darkSecondaryViolet = Color(red: 0x2A/255, green: 0x25/255, blue: 0x3F/255) // #2A253F - Deep violet tint

    // Disabled States (dark mode)
    static let darkDisabledBackground = Color(red: 0x2A/255, green: 0x2A/255, blue: 0x2E/255) // #2A2A2E
    static let darkDisabledText = Color(red: 0x6E/255, green: 0x6E/255, blue: 0x73/255) // #6E6E73

    // MARK: - Adaptive Colors (automatically switch based on dark mode)
    static func adaptiveBackground(isDark: Bool) -> Color {
        isDark ? darkPrimaryBackground : Color.white
    }

    static func adaptiveSecondaryBackground(isDark: Bool) -> Color {
        isDark ? darkSecondaryBackground : secondaryBackground
    }

    static func adaptiveSupportGray(isDark: Bool) -> Color {
        isDark ? darkSupportGray : supportGray
    }

    static func adaptiveText(isDark: Bool) -> Color {
        isDark ? darkTextPrimary : textDark
    }

    static func adaptiveSecondaryText(isDark: Bool) -> Color {
        isDark ? darkTextSecondary : textMedium
    }

    static func adaptiveTertiaryText(isDark: Bool) -> Color {
        isDark ? darkTextTertiary : textLight
    }

    static func adaptiveBorder(isDark: Bool) -> Color {
        isDark ? darkBorderGray : borderGray
    }

    static func adaptiveDivider(isDark: Bool) -> Color {
        isDark ? darkDividerGray : borderGray
    }

    static func adaptiveSecondaryViolet(isDark: Bool) -> Color {
        isDark ? darkSecondaryViolet : secondaryViolet
    }

    static func adaptiveDisabledBackground(isDark: Bool) -> Color {
        isDark ? darkDisabledBackground : disabledBackground
    }

    static func adaptiveDisabledText(isDark: Bool) -> Color {
        isDark ? darkDisabledText : disabledText
    }

    // MARK: - Mood Gradient
    /// Returns a color on the mood gradient from blue (calm) to purple to pink (anxious)
    /// - Parameter value: 0.0 (blue/calm) to 1.0 (pink/anxious)
    static func moodGradient(for value: Double) -> Color {
        let clampedValue = min(max(value, 0.0), 1.0)

        // Blue (calm) → Purple (neutral) → Pink (anxious)
        // Blue (calm): #6BB8FF - (0.42, 0.72, 1.0)
        // Purple (neutral): #7B61FF - (0.48, 0.38, 1.0)
        // Pink (anxious): #FF6B9C - (1.0, 0.42, 0.61)

        if clampedValue < 0.5 {
            // Blue to Purple (0.0 to 0.5)
            let t = clampedValue / 0.5
            return Color(
                red: 0.42 + (t * 0.06),      // 0.42 → 0.48
                green: 0.72 - (t * 0.34),    // 0.72 → 0.38
                blue: 1.0                     // 1.0 → 1.0
            )
        } else {
            // Purple to Pink (0.5 to 1.0)
            let t = (clampedValue - 0.5) / 0.5
            return Color(
                red: 0.48 + (t * 0.52),      // 0.48 → 1.0
                green: 0.38 + (t * 0.04),    // 0.38 → 0.42
                blue: 1.0 - (t * 0.39)       // 1.0 → 0.61
            )
        }
    }
}

// MARK: - App Gradients
struct AppGradient {
    /// Official design system background gradient (Light Mode)
    /// Top: #F8F6FF → Bottom: #FFFFFF
    static let background = LinearGradient(
        colors: [
            Color(red: 0xF8/255, green: 0xF6/255, blue: 0xFF/255), // #F8F6FF
            Color.white                                             // #FFFFFF
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Dark mode background gradient
    /// Top: Deep purple-tinted dark → Bottom: Pure dark
    static let darkBackground = LinearGradient(
        colors: [
            Color(red: 0x1F/255, green: 0x1A/255, blue: 0x2E/255), // #1F1A2E - Deep purple-dark
            Color(red: 0x1A/255, green: 0x1A/255, blue: 0x1E/255)  // #1A1A1E - Deep charcoal
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Adaptive background gradient (switches based on dark mode)
    static func adaptiveBackground(isDark: Bool) -> LinearGradient {
        isDark ? darkBackground : background
    }

    // ============================================
    // 📱 ALTERNATIVE BACKGROUND OPTIONS
    // ============================================

    // Option 1: Enhanced visibility version (more pronounced purple)
    static let option1 = LinearGradient(
        colors: [
            Color(red: 0xF2/255, green: 0xED/255, blue: 0xF9/255), // #F2EDF9 (more visible purple)
            Color(red: 0xFA/255, green: 0xF8/255, blue: 0xFE/255)  // #FAF8FE (very light purple)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    // Option 2: Soft Lavender Dream (Gentle calming purple)
    static let option2 = LinearGradient(
        colors: [
            Color(red: 0.95, green: 0.93, blue: 0.98),  // #F2EDF9
            Color(red: 0.88, green: 0.85, blue: 0.95)   // #E0D8F2
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    // Option 3: Morning Mist (Cool peaceful gray-blue)
    static let option3 = LinearGradient(
        colors: [
            Color(red: 0.93, green: 0.95, blue: 0.97),  // #EDF2F7
            Color(red: 0.85, green: 0.89, blue: 0.93)   // #D9E3ED
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Option 4: Peach Serenity (Warm gentle peach)
    static let option4 = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.95, blue: 0.93),   // #FFF2ED
            Color(red: 0.98, green: 0.88, blue: 0.83)   // #FAE0D4
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    // Option 5: Mint Breeze (Soft refreshing mint)
    static let option5 = LinearGradient(
        colors: [
            Color(red: 0.93, green: 0.98, blue: 0.96),  // #EDF9F5
            Color(red: 0.84, green: 0.94, blue: 0.90)   // #D6F0E6
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Option 6: Rose Quartz (Delicate pink warmth)
    static let option6 = LinearGradient(
        colors: [
            Color(red: 0.99, green: 0.94, blue: 0.95),  // #FCF0F2
            Color(red: 0.96, green: 0.87, blue: 0.90)   // #F5DDE6
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    // Option 7: Ocean Depth (Calm deep blue)
    static let option7 = LinearGradient(
        colors: [
            Color(red: 0.91, green: 0.95, blue: 0.98),  // #E8F2FA
            Color(red: 0.78, green: 0.87, blue: 0.95)   // #C7DEF2
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Option 8: Golden Hour (Warm sunset glow)
    static let option8 = LinearGradient(
        colors: [
            Color(red: 0.99, green: 0.96, blue: 0.91),  // #FCF5E8
            Color(red: 0.96, green: 0.90, blue: 0.80)   // #F5E5CC
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    // Option 9: Moonlight Whisper (Ethereal blue-purple)
    static let option9 = LinearGradient(
        colors: [
            Color(red: 0.94, green: 0.95, blue: 0.99),  // #F0F2FC
            Color(red: 0.87, green: 0.89, blue: 0.96)   // #DDE3F5
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Option 10: Sakura Sunset (Soft pink-orange)
    static let option10 = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.94, blue: 0.93),   // #FFF0ED
            Color(red: 0.98, green: 0.86, blue: 0.87)   // #FADBDD
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - View Modifier for Gradient Background
struct GradientBackgroundModifier: ViewModifier {
    @Environment(\.isDarkMode) var isDarkMode
    var gradient: LinearGradient?

    init(gradient: LinearGradient? = nil) {
        self.gradient = gradient
    }

    func body(content: Content) -> some View {
        content
            .background(
                (gradient ?? AppGradient.adaptiveBackground(isDark: isDarkMode))
                    .ignoresSafeArea()
            )
    }
}

// MARK: - Animated Gradient Background
struct AnimatedGradientBackground: View {
    @Environment(\.isDarkMode) var isDarkMode
    @State private var shift: CGFloat = 0

    var body: some View {
        ZStack {
            if isDarkMode {
                // Dark mode animated gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.12, green: 0.10, blue: 0.18),  // Deep purple-dark
                        Color(red: 0.10, green: 0.12, blue: 0.16),  // Deep blue-dark
                        Color.darkPrimaryBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .hueRotation(.degrees(shift * 5))

                // Moving orb for dark mode
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.accentViolet.opacity(0.2),
                                Color.lightBlue.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .offset(x: shift * 50, y: shift * 30)
                    .blur(radius: 40)
            } else {
                // Light mode animated gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.97, green: 0.96, blue: 1.0),   // Very light violet
                        Color(red: 0.95, green: 0.97, blue: 1.0),   // Very light blue
                        Color.white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .hueRotation(.degrees(shift))

                // Moving orb for light mode
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.accentViolet.opacity(0.15),
                                Color.lightBlue.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .offset(x: shift * 50, y: shift * 30)
                    .blur(radius: 40)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(
                .easeInOut(duration: 12.0)
                .repeatForever(autoreverses: true)
            ) {
                shift = 1.0
            }
        }
    }
}

extension View {
    /// Applies the app's standard gradient background (adaptive to dark mode)
    func gradientBackground(_ gradient: LinearGradient? = nil) -> some View {
        modifier(GradientBackgroundModifier(gradient: gradient))
    }

    /// Applies an animated gradient background with slow color shifting (adaptive to dark mode)
    func animatedGradientBackground() -> some View {
        ZStack {
            AnimatedGradientBackground()
            self
        }
    }
}