//
//  SOSWidgetProvider.swift
//  SOSWidget
//
//  Timeline provider for SOS widgets
//

import WidgetKit
import SwiftUI

// MARK: - Widget Entry

struct SOSWidgetEntry: TimelineEntry {
    let date: Date
}

// MARK: - Timeline Provider

struct SOSWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SOSWidgetEntry {
        SOSWidgetEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SOSWidgetEntry) -> Void) {
        let entry = SOSWidgetEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SOSWidgetEntry>) -> Void) {
        // SOS widget is static - no need for frequent updates
        // Refresh once per day to keep widget alive
        let currentDate = Date()
        let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!

        let entry = SOSWidgetEntry(date: currentDate)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }
}
