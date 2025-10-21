//
//  CrashReporter.swift
//  anxietyapp
//
//  Native crash reporting using NSSetUncaughtExceptionHandler
//  No third-party dependencies required
//

import Foundation
import UIKit

class CrashReporter {
    static let shared = CrashReporter()
    private init() {}

    // MARK: - Configuration

    func configure() {
        // Set up exception handler to catch crashes
        NSSetUncaughtExceptionHandler { exception in
            CrashReporter.shared.handleCrash(exception: exception)
        }

        // Set up signal handler for low-level crashes
        setupSignalHandlers()

        #if DEBUG
        print("🛡️ CrashReporter configured")
        #endif
    }

    // MARK: - Crash Handling

    private func handleCrash(exception: NSException) {
        let crashReport = generateCrashReport(exception: exception)
        saveCrashReport(crashReport)

        #if DEBUG
        print("💥 CRASH DETECTED:")
        print(crashReport)
        #endif
    }

    private func generateCrashReport(exception: NSException) -> String {
        var report = """
        =====================================
        CRASH REPORT
        =====================================
        Date: \(Date())
        App Version: \(Bundle.main.appVersion)
        Build: \(Bundle.main.buildNumber)
        iOS Version: \(UIDevice.current.systemVersion)
        Device: \(UIDevice.current.model)

        Exception Name: \(exception.name.rawValue)
        Reason: \(exception.reason ?? "Unknown")

        Call Stack:
        """

        // Add stack trace
        for (index, symbol) in exception.callStackSymbols.enumerated() {
            report += "\n\(index): \(symbol)"
        }

        report += "\n====================================="

        return report
    }

    private func saveCrashReport(_ report: String) {
        let fileName = "crash_\(Date().timeIntervalSince1970).txt"

        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(fileName)

            do {
                try report.write(to: fileURL, atomically: true, encoding: .utf8)
                print("✅ Crash report saved: \(fileName)")
            } catch {
                print("❌ Failed to save crash report: \(error)")
            }
        }
    }

    // MARK: - Signal Handlers (for low-level crashes)

    private func setupSignalHandlers() {
        signal(SIGABRT) { signal in
            CrashReporter.shared.handleSignal(signal: signal, name: "SIGABRT")
        }
        signal(SIGILL) { signal in
            CrashReporter.shared.handleSignal(signal: signal, name: "SIGILL")
        }
        signal(SIGSEGV) { signal in
            CrashReporter.shared.handleSignal(signal: signal, name: "SIGSEGV")
        }
        signal(SIGFPE) { signal in
            CrashReporter.shared.handleSignal(signal: signal, name: "SIGFPE")
        }
        signal(SIGBUS) { signal in
            CrashReporter.shared.handleSignal(signal: signal, name: "SIGBUS")
        }
        signal(SIGPIPE) { signal in
            CrashReporter.shared.handleSignal(signal: signal, name: "SIGPIPE")
        }
    }

    private func handleSignal(signal: Int32, name: String) {
        let report = """
        =====================================
        SIGNAL CRASH REPORT
        =====================================
        Date: \(Date())
        Signal: \(name) (\(signal))
        App Version: \(Bundle.main.appVersion)
        Build: \(Bundle.main.buildNumber)
        iOS Version: \(UIDevice.current.systemVersion)
        =====================================
        """

        saveCrashReport(report)
    }

    // MARK: - Manual Error Logging

    /// Log non-fatal errors (useful for tracking issues without crashes)
    func logError(_ error: Error, context: String? = nil) {
        let errorReport = """
        =====================================
        ERROR LOG
        =====================================
        Date: \(Date())
        Context: \(context ?? "Unknown")
        Error: \(error.localizedDescription)

        Details:
        \(String(describing: error))
        =====================================
        """

        #if DEBUG
        print("⚠️ Error logged: \(errorReport)")
        #endif

        saveErrorLog(errorReport)
    }

    private func saveErrorLog(_ log: String) {
        let fileName = "error_\(Date().timeIntervalSince1970).txt"

        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(fileName)

            do {
                try log.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                print("❌ Failed to save error log: \(error)")
            }
        }
    }

    // MARK: - Retrieve Crash Reports

    /// Get all saved crash reports (for sending to developer or viewing in debug)
    func getAllCrashReports() -> [URL] {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return []
        }

        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: documentsDirectory,
                includingPropertiesForKeys: nil
            )

            return files.filter { $0.lastPathComponent.hasPrefix("crash_") || $0.lastPathComponent.hasPrefix("error_") }
        } catch {
            print("❌ Failed to retrieve crash reports: \(error)")
            return []
        }
    }

    /// Check if there are pending crash reports from previous sessions
    func checkForPendingCrashReports() {
        let reports = getAllCrashReports()

        if !reports.isEmpty {
            print("⚠️ Found \(reports.count) crash/error reports from previous sessions")

            #if DEBUG
            // In debug, print them
            for reportURL in reports {
                if let content = try? String(contentsOf: reportURL) {
                    print("\n📄 Report: \(reportURL.lastPathComponent)")
                    print(content)
                }
            }
            #else
            // In production, you could:
            // 1. Send to your email/server
            // 2. Show alert to user asking to send report
            // 3. Upload to your backend

            // Log to console for now (custom analytics events not yet implemented)
            print("📊 Found \(reports.count) crash reports from previous sessions")
            #endif
        }
    }

    /// Delete all crash reports (call after sending to developer)
    func clearCrashReports() {
        let reports = getAllCrashReports()

        for reportURL in reports {
            try? FileManager.default.removeItem(at: reportURL)
        }

        print("🗑️ Cleared \(reports.count) crash reports")
    }
}

// MARK: - Bundle Extensions

extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}

// MARK: - Analytics Extension
// Note: Custom event tracking is handled through AnalyticsService.track() method
// The AnalyticsEvent enum contains predefined events only
