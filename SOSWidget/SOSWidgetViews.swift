//
//  SOSWidgetViews.swift
//  SOSWidget
//
//  All widget UI variants for SOS button
//

import WidgetKit
import SwiftUI

// MARK: - Home Screen Widget Views

struct SOSHomeScreenWidgetView: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: SOSWidgetEntry

    var body: some View {
        if #available(iOS 17.0, *) {
            Group {
                switch widgetFamily {
                case .systemSmall:
                    SmallHomeScreenWidget()
                case .systemMedium:
                    MediumHomeScreenWidget()
                case .systemLarge:
                    LargeHomeScreenWidget()
                default:
                    SmallHomeScreenWidget()
                }
            }
            .widgetURL(AppGroup.DeepLink.sosFlow)
            .containerBackground(for: .widget) {
                // Emergency red matching app's SOS button (#FF3B30)
                Color(red: 0xFF/255, green: 0x3B/255, blue: 0x30/255)
            }
        } else {
            // iOS 16 fallback - add background to each widget directly
            ZStack {
                Color(red: 0xFF/255, green: 0x3B/255, blue: 0x30/255)
                    .ignoresSafeArea()

                Group {
                    switch widgetFamily {
                    case .systemSmall:
                        SmallHomeScreenWidget()
                    case .systemMedium:
                        MediumHomeScreenWidget()
                    case .systemLarge:
                        LargeHomeScreenWidget()
                    default:
                        SmallHomeScreenWidget()
                    }
                }
            }
            .widgetURL(AppGroup.DeepLink.sosFlow)
        }
    }
}

// MARK: - Small Widget (2x2)

struct SmallHomeScreenWidget: View {
    var body: some View {
        VStack(spacing: 8) {
            // Heart icon
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 40, weight: .semibold))
                .symbolRenderingMode(.monochrome)
                .foregroundColor(.white)

            // SOS text
            Text("SOS")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)

            // Subtitle
            Text("Tap for help")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

// MARK: - Medium Widget (4x2)

struct MediumHomeScreenWidget: View {
    var body: some View {
        HStack(spacing: 20) {
            // Icon on left
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 56, weight: .semibold))
                .symbolRenderingMode(.monochrome)
                .foregroundColor(.white)

            // Text content
            VStack(alignment: .leading, spacing: 6) {
                Text("SOS")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Text("Immediate relief")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.95))

                Text("Tap to start")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Large Widget (4x4)

struct LargeHomeScreenWidget: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Large icon
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 80, weight: .semibold))
                .symbolRenderingMode(.monochrome)
                .foregroundColor(.white)

            // Main text
            VStack(spacing: 8) {
                Text("SOS")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)

                Text("Emergency Relief")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.95))

                Text("Tap anywhere for immediate help")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Spacer()

            // Bottom hint
            Text("< 2 minutes to relief")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.75))
                .padding(.bottom, 16)
        }
    }
}

// MARK: - Lock Screen Widget Views

@available(iOS 16.0, *)
struct SOSLockScreenWidgetView: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: SOSWidgetEntry

    var body: some View {
        Group {
            switch widgetFamily {
            case .accessoryCircular:
                CircularLockScreenWidget()
            case .accessoryRectangular:
                RectangularLockScreenWidget()
            case .accessoryInline:
                InlineLockScreenWidget()
            default:
                CircularLockScreenWidget()
            }
        }
        .widgetURL(AppGroup.DeepLink.sosFlow)
    }
}

// MARK: - Circular Lock Screen Widget

@available(iOS 16.0, *)
struct CircularLockScreenWidget: View {
    var body: some View {
        ZStack {
            // Circular progress ring (decorative)
            Circle()
                .stroke(lineWidth: 3)
                .opacity(0.3)

            // Icon
            VStack(spacing: 2) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .symbolRenderingMode(.monochrome)

                Text("SOS")
                    .font(.system(size: 10, weight: .bold))
            }
        }
        .widgetAccentable()
    }
}

// MARK: - Rectangular Lock Screen Widget

@available(iOS 16.0, *)
struct RectangularLockScreenWidget: View {
    var body: some View {
        HStack(spacing: 8) {
            // Icon
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 24, weight: .semibold))
                .symbolRenderingMode(.monochrome)

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text("SOS Relief")
                    .font(.system(size: 14, weight: .bold))

                Text("Tap for help")
                    .font(.system(size: 12, weight: .regular))
                    .opacity(0.8)
            }

            Spacer()
        }
        .widgetAccentable()
    }
}

// MARK: - Inline Lock Screen Widget

@available(iOS 16.0, *)
struct InlineLockScreenWidget: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "heart.fill")
                .font(.system(size: 12, weight: .semibold))
                .symbolRenderingMode(.monochrome)

            Text("SOS Relief")
                .font(.system(size: 12, weight: .semibold))
        }
    }
}

// MARK: - Previews

@available(iOS 17.0, *)
#Preview("Small", as: .systemSmall) {
    SOSHomeScreenWidget()
} timeline: {
    SOSWidgetEntry(date: .now)
}

@available(iOS 17.0, *)
#Preview("Medium", as: .systemMedium) {
    SOSHomeScreenWidget()
} timeline: {
    SOSWidgetEntry(date: .now)
}

@available(iOS 17.0, *)
#Preview("Large", as: .systemLarge) {
    SOSHomeScreenWidget()
} timeline: {
    SOSWidgetEntry(date: .now)
}

@available(iOS 17.0, *)
#Preview("Circular Lock", as: .accessoryCircular) {
    SOSLockScreenWidget()
} timeline: {
    SOSWidgetEntry(date: .now)
}

@available(iOS 17.0, *)
#Preview("Rectangular Lock", as: .accessoryRectangular) {
    SOSLockScreenWidget()
} timeline: {
    SOSWidgetEntry(date: .now)
}

@available(iOS 17.0, *)
#Preview("Inline Lock", as: .accessoryInline) {
    SOSLockScreenWidget()
} timeline: {
    SOSWidgetEntry(date: .now)
}
