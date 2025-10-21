//
//  anxietyappApp.swift
//  anxietyapp
//
//  Created by Nathan Douziech on 27/09/2025.
//

import SwiftUI
import RevenueCat

// AppDelegate to handle orientation locking, AppsFlyer lifecycle, and Quick Actions
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }

    // Start AppsFlyer when app becomes active
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppsFlyerService.shared.start()
    }

    // Handle Quick Actions from home screen long-press (when app is not running)
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            NavigationManager.shared.handleQuickAction(shortcutItem.type)
        }

        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

// SceneDelegate to handle Quick Actions when app is already running
class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        NavigationManager.shared.handleQuickAction(shortcutItem.type)
        completionHandler(true)
    }
}

@main
struct anxietyappApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var themeManager = ThemeManager()
    @ObservedObject private var navigationManager = NavigationManager.shared

    init() {
        // Configure crash reporting (native, no third-party services)
        CrashReporter.shared.configure()

        // Check for crash reports from previous sessions
        CrashReporter.shared.checkForPendingCrashReports()

        #if DEBUG
        // In debug builds, validate configuration and crash if missing
        // This alerts developers immediately during development
        if !ConfigurationManager.isConfigured {
            if let error = ConfigurationManager.configurationError {
                fatalError("❌ Configuration Error: \(error)\n\nPlease copy Config-Template.plist to Config.plist and add your API keys.")
            }
        }
        // Print configuration status in debug builds
        ConfigurationManager.printConfiguration()
        #else
        // In production builds, log error to crash reporter but don't crash or print
        if !ConfigurationManager.isConfigured {
            if let error = ConfigurationManager.configurationError {
                // Log to crash reporter for visibility (no console output in production)
                CrashReporter.shared.logError(
                    NSError(domain: "ConfigurationManager", code: -1, userInfo: [NSLocalizedDescriptionKey: error]),
                    context: "App Launch - Missing Configuration"
                )
            }
        }
        #endif

        // Configure RevenueCat with API key from secure config
        // NOTE: For local simulator testing, products must exist in App Store Connect
        // or you can use StoreKit configuration file (Product → Scheme → Edit Scheme → Options → StoreKit Configuration)
        #if DEBUG
        // Force StoreKit Testing mode for local development
        Purchases.simulatesAskToBuyInSandbox = true
        #endif
        SubscriptionService.shared.configure(apiKey: ConfigurationManager.revenueCatAPIKey)

        // Configure Mixpanel for in-app analytics (not cross-app tracking)
        // Used only for understanding user behavior within this app
        AnalyticsService.shared.configure(token: ConfigurationManager.mixpanelToken)

        // Configure AppsFlyer for attribution and marketing analytics
        AppsFlyerService.shared.configure()

        // Initialize NotificationService
        _ = NotificationService.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .environmentObject(navigationManager)
                .darkMode(themeManager.isDarkMode)
                .onOpenURL { url in
                    navigationManager.handleDeepLink(url)
                }
                .onAppear {
                    // Setup Quick Actions for home screen long-press
                    setupQuickActions()

                    // Refresh quote notifications when app opens
                    refreshQuoteNotificationsIfNeeded()
                }
        }
    }

    /// Setup Quick Actions that appear when user long-presses app icon
    private func setupQuickActions() {
        UIApplication.shared.shortcutItems = [
            UIApplicationShortcutItem(
                type: "com.nuvin.feedback",
                localizedTitle: "Leaving? Tell us why (get 1 month free)",
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(systemImageName: "heart.text.square.fill"),
                userInfo: nil
            ),
            UIApplicationShortcutItem(
                type: "com.nuvin.emergency",
                localizedTitle: "Emergency SOS",
                localizedSubtitle: "Quick relief - works offline",
                icon: UIApplicationShortcutIcon(systemImageName: "cross.circle.fill"),
                userInfo: nil
            )
        ]
    }

    /// Refresh quote notifications if we're running low (less than 7 days remaining)
    /// Rate limited to once per 24 hours to avoid battery drain
    private func refreshQuoteNotificationsIfNeeded() {
        // Rate limiting: Only check once per 24 hours
        let lastRefreshKey = "lastQuoteNotificationRefresh"
        let now = Date()

        if let lastRefresh = UserDefaults.standard.object(forKey: lastRefreshKey) as? Date {
            let hoursSinceLastRefresh = now.timeIntervalSince(lastRefresh) / 3600
            if hoursSinceLastRefresh < 24 {
                #if DEBUG
                print("📅 Skipping quote notification refresh - last checked \(Int(hoursSinceLastRefresh)) hours ago")
                #endif
                return
            }
        }

        // Update last refresh timestamp
        UserDefaults.standard.set(now, forKey: lastRefreshKey)

        // Run on background queue to avoid blocking UI
        DispatchQueue.global(qos: .utility).async {
            NotificationService.shared.notificationCenter.getPendingNotificationRequests { requests in
                // Count how many daily quote notifications are scheduled
                let quoteNotifications = requests.filter { $0.identifier.hasPrefix("daily-quote-") }

                // If less than 7 days of quotes scheduled, refresh the full 30 days
                if quoteNotifications.count < 7 {
                    #if DEBUG
                    DispatchQueue.main.async {
                        print("📅 Only \(quoteNotifications.count) quote notifications remaining, refreshing...")
                    }
                    #endif

                    // Get user's quote notification settings
                    let quoteEnabled = UserDefaults.standard.bool(forKey: "quoteNotificationsEnabled")

                    if quoteEnabled {
                        let quoteTimeString = UserDefaults.standard.string(forKey: "quoteTime") ?? "09:00"
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm"

                        if let date = formatter.date(from: quoteTimeString) {
                            let calendar = Calendar.current
                            let components = calendar.dateComponents([.hour, .minute], from: date)
                            let quoteTime = calendar.date(from: components) ?? Date()

                            // Reschedule the next 30 days
                            NotificationService.shared.scheduleDailyQuote(enabled: true, time: quoteTime)
                        }
                    }
                }
            }
        }
    }
}
