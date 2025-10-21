//
//  ThemeManager.swift
//  anxietyapp
//
//  Manages app-wide theme (light/dark mode)
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "darkModeEnabled")
        }
    }

    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "darkModeEnabled")
    }
}

