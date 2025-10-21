//
//  Logger.swift
//  anxietyapp
//
//  Centralized logging utility with DEBUG-only output
//

import Foundation

/// Centralized logging utility that only logs in DEBUG builds
enum Logger {

    /// Log a general message (only in DEBUG builds)
    static func log(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let filename = (file as NSString).lastPathComponent
        print("[\(filename):\(line)] \(function) - \(message)")
        #endif
    }

    /// Log an error message (only in DEBUG builds)
    static func error(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let filename = (file as NSString).lastPathComponent
        var output = "❌ [\(filename):\(line)] \(function) - \(message)"
        if let error = error {
            output += "\n   Error: \(error.localizedDescription)"
        }
        print(output)
        #endif
    }

    /// Log a warning message (only in DEBUG builds)
    static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let filename = (file as NSString).lastPathComponent
        print("⚠️ [\(filename):\(line)] \(function) - \(message)")
        #endif
    }

    /// Log a success message (only in DEBUG builds)
    static func success(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let filename = (file as NSString).lastPathComponent
        print("✅ [\(filename):\(line)] \(function) - \(message)")
        #endif
    }

    /// Log analytics/tracking events (only in DEBUG builds)
    static func analytics(_ event: String, properties: [String: Any]? = nil, file: String = #file, line: Int = #line) {
        #if DEBUG
        let filename = (file as NSString).lastPathComponent
        var output = "📊 [\(filename):\(line)] Analytics: \(event)"
        if let properties = properties {
            output += "\n   Properties: \(properties)"
        }
        print(output)
        #endif
    }

    /// Log configuration/setup information (only in DEBUG builds)
    static func config(_ message: String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let filename = (file as NSString).lastPathComponent
        print("🔑 [\(filename):\(line)] Config: \(message)")
        #endif
    }
}
