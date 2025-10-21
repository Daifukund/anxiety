//
//  SOSWidget.swift
//  SOSWidget
//
//  Main widget bundle definition
//

import WidgetKit
import SwiftUI

@main
struct SOSWidgetBundle: WidgetBundle {
    var body: some Widget {
        // Home Screen widgets (small, medium, large)
        SOSHomeScreenWidget()

        // Lock Screen widgets
        SOSLockScreenWidget()
    }
}

// MARK: - Home Screen Widget

struct SOSHomeScreenWidget: Widget {
    let kind: String = "SOSHomeScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SOSWidgetProvider()) { entry in
            SOSHomeScreenWidgetView(entry: entry)
        }
        .configurationDisplayName("SOS Button")
        .description("Quick access to emergency anxiety relief")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Lock Screen Widget

@available(iOS 16.0, *)
struct SOSLockScreenWidget: Widget {
    let kind: String = "SOSLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SOSWidgetProvider()) { entry in
            SOSLockScreenWidgetView(entry: entry)
        }
        .configurationDisplayName("SOS")
        .description("Instant access to anxiety relief")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}
