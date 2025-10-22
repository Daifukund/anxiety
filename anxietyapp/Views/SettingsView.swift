//
//  SettingsView.swift
//  anxietyapp
//
//  Settings screen with user preferences and app information
//  Based on PRD lines 272-277
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.isDarkMode) var isDarkMode
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @ObservedObject private var subscriptionService = SubscriptionService.shared

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - App Preferences
                    settingsSection(title: "Preferences") {
                        GlassToggleRow(
                            icon: "iphone.radiowaves.left.and.right",
                            title: "Haptic Vibration",
                            subtitle: "Feel vibrations with each tap",
                            isOn: $hapticsEnabled
                        )
                        .onChange(of: hapticsEnabled) { newValue in
                            // Provide immediate feedback when ENABLING haptics
                            if newValue {
                                HapticManager.shared.impact(.light)
                            }
                        }

                        Divider()
                            .padding(.leading, 60)

                        GlassToggleRow(
                            icon: "moon.fill",
                            title: "Dark Mode",
                            subtitle: "Switch to dark theme",
                            isOn: $themeManager.isDarkMode
                        )
                    }

                    // MARK: - Subscription
                    settingsSection(title: "Subscription") {
                        NavigationLink(destination: SubscriptionManagementView()) {
                            HStack(spacing: 16) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color.accentViolet)
                                    .frame(width: 28)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Manage Subscription")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                                    if subscriptionService.isSubscribed, let subscription = subscriptionService.currentSubscription {
                                        let planName = getPlanDisplayName(from: subscription.productIdentifier)
                                        Text("\(planName) • Active")
                                            .font(.system(size: 13))
                                            .foregroundColor(Color.success)
                                    } else {
                                        Text("No active subscription")
                                            .font(.system(size: 13))
                                            .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                                    }
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                    }

                    // MARK: - Notifications
                    settingsSection(title: "Notifications") {
                        NavigationLink(destination: NotificationSettingsView()) {
                            SettingsRow(icon: "bell", title: "Set Reminders")
                        }
                    }

                    // MARK: - Data Management
                    settingsSection(title: "Data & Privacy") {
                        NavigationLink(destination: DataManagementView()) {
                            SettingsRow(icon: "folder", title: "Manage Your Data")
                        }
                    }

                    // MARK: - Share & Community
                    settingsSection(title: "Share & Connect") {
                        Button(action: shareApp) {
                            SettingsRow(icon: "square.and.arrow.up", title: "Share App")
                        }

                        Button(action: rateApp) {
                            SettingsRow(icon: "star", title: "Rate Nuvin")
                        }
                    }

                    // MARK: - Support & Legal
                    settingsSection(title: "Support & Legal") {
                        NavigationLink(destination: DisclaimerView()) {
                            SettingsRow(icon: "info.circle", title: "Disclaimer")
                        }

                        NavigationLink(destination: SupportView()) {
                            SettingsRow(icon: "questionmark.circle", title: "Support")
                        }

                        Button(action: reportIssue) {
                            SettingsRow(icon: "exclamationmark.triangle", title: "Report an Issue")
                        }
                    }

                    // MARK: - Account & Privacy
                    settingsSection(title: "Account & Privacy") {
                        Button(action: openTerms) {
                            HStack(spacing: 16) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color.accentViolet)
                                    .frame(width: 28)

                                Text("Terms & Conditions")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.adaptiveSupportGray(isDark: isDarkMode))
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        Button(action: openPrivacy) {
                            HStack(spacing: 16) {
                                Image(systemName: "lock.shield")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color.accentViolet)
                                    .frame(width: 28)

                                Text("Privacy Policy")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.adaptiveSupportGray(isDark: isDarkMode))
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }

                    // Version info
                    Text("Version 1.2.0")
                        .font(.system(size: 13))
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color.adaptiveBackground(isDark: isDarkMode))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                    }
                }
            }
            .task {
                await subscriptionService.checkSubscriptionStatus()
            }
        }
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
    }

    // MARK: - Helper Functions

    private func getPlanDisplayName(from productIdentifier: String?) -> String {
        guard let identifier = productIdentifier else { return "Premium" }

        if identifier.contains("Monthly") {
            return "Premium Monthly"
        } else if identifier.contains("Annual") {
            return "Premium Annual"
        } else if identifier.contains("Lifetime") {
            return "Premium Lifetime"
        }
        return "Premium"
    }

    // MARK: - Helper Views
    @ViewBuilder
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.adaptiveSupportGray(isDark: isDarkMode))
            .cornerRadius(12)
        }
    }

    // MARK: - Actions
    private func shareApp() {
        HapticManager.shared.impact(.light)

        let shareText = "Check out Nuvin - instant anxiety relief in under 2 minutes! https://apps.apple.com/app/nuvin/id6753338724"
        let activityController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            // For iPad - prevent crash
            if let popover = activityController.popoverPresentationController {
                popover.sourceView = rootViewController.view
                popover.sourceRect = CGRect(x: rootViewController.view.bounds.midX,
                                           y: rootViewController.view.bounds.midY,
                                           width: 0, height: 0)
                popover.permittedArrowDirections = []
            }

            rootViewController.present(activityController, animated: true)
        }
    }

    private func rateApp() {
        HapticManager.shared.impact(.light)

        if let url = URL(string: "https://apps.apple.com/app/nuvin/id6753338724?action=write-review") {
            UIApplication.shared.open(url)
        }
    }

    private func reportIssue() {
        HapticManager.shared.impact(.light)

        if let url = URL(string: "mailto:nathan@nuvin.app?subject=Issue%20Report") {
            UIApplication.shared.open(url)
        }
    }

    private func openTerms() {
        HapticManager.shared.impact(.light)

        if let url = URL(string: "https://nuvin.app/terms") {
            UIApplication.shared.open(url)
        }
    }

    private func openPrivacy() {
        HapticManager.shared.impact(.light)

        if let url = URL(string: "https://nuvin.app/privacy") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Settings Row Component
struct SettingsRow<Trailing: View>: View {
    @Environment(\.isDarkMode) var isDarkMode
    let icon: String
    let title: String
    let isDestructive: Bool
    let trailing: () -> Trailing

    init(icon: String, title: String, isDestructive: Bool = false, @ViewBuilder trailing: @escaping () -> Trailing) {
        self.icon = icon
        self.title = title
        self.isDestructive = isDestructive
        self.trailing = trailing
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(isDestructive ? Color.emergencyRed : Color.accentViolet)
                .frame(width: 28)

            Text(title)
                .font(.system(size: 16))
                .foregroundColor(isDestructive ? Color.emergencyRed : Color.adaptiveText(isDark: isDarkMode))

            Spacer()

            trailing()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.adaptiveSupportGray(isDark: isDarkMode))
    }
}

extension SettingsRow where Trailing == EmptyView {
    init(icon: String, title: String, isDestructive: Bool = false) {
        self.icon = icon
        self.title = title
        self.isDestructive = isDestructive
        self.trailing = { EmptyView() }
    }
}

// MARK: - Placeholder Detail Views
// These will be implemented with full functionality later

struct NotificationSettingsView: View {
    @Environment(\.isDarkMode) var isDarkMode
    @AppStorage("moodCheckInEnabled") private var moodCheckInEnabled = true
    @AppStorage("moodCheckInTime") private var moodCheckInTimeString = "09:00"
    @AppStorage("quoteNotificationsEnabled") private var quoteNotificationsEnabled = false
    @AppStorage("quoteTime") private var quoteTimeString = "09:00"

    @State private var moodCheckInTime = Date()
    @State private var quoteTime = Date()
    @State private var showingPermissionAlert = false
    @ObservedObject private var notificationService = NotificationService.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Set reminders to help you maintain your mental wellness routine.")
                    .font(.system(size: 15))
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                    .padding(.bottom, 8)

                // Mood Check-in Reminder
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Daily Mood Check-in")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                            Text("Reminder to log your mood")
                                .font(.system(size: 13))
                                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                        }

                        Spacer()

                        Toggle("", isOn: $moodCheckInEnabled)
                            .tint(Color.accentViolet)
                            .onChange(of: moodCheckInEnabled) { newValue in
                                requestNotificationPermission()
                                scheduleMoodCheckIn()
                            }
                    }
                    .padding(16)

                    if moodCheckInEnabled {
                        Divider()
                            .padding(.leading, 16)

                        DatePicker("Time", selection: $moodCheckInTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                            .padding(16)
                            .onChange(of: moodCheckInTime) { newValue in
                                saveTime(newValue, to: $moodCheckInTimeString)
                                scheduleMoodCheckIn()
                            }
                    }
                }
                .background(Color.adaptiveSupportGray(isDark: isDarkMode))
                .cornerRadius(12)

                // Daily Quote Notification
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Daily Quote")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                            Text("One uplifting message each day")
                                .font(.system(size: 13))
                                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                        }

                        Spacer()

                        Toggle("", isOn: $quoteNotificationsEnabled)
                            .tint(Color.accentViolet)
                            .onChange(of: quoteNotificationsEnabled) { newValue in
                                requestNotificationPermission()
                                scheduleDailyQuote()
                            }
                    }
                    .padding(16)

                    if quoteNotificationsEnabled {
                        Divider()
                            .padding(.leading, 16)

                        DatePicker("Time", selection: $quoteTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                            .padding(16)
                            .onChange(of: quoteTime) { newValue in
                                saveTime(newValue, to: $quoteTimeString)
                                scheduleDailyQuote()
                            }
                    }
                }
                .background(Color.adaptiveSupportGray(isDark: isDarkMode))
                .cornerRadius(12)

                Text("You can manage notification permissions in your device Settings.")
                    .font(.system(size: 13))
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                    .padding(.top, 8)
            }
            .padding(20)
        }
        .background(Color.adaptiveBackground(isDark: isDarkMode))
        .navigationTitle("Reminders")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadTimes()
            scheduleMoodCheckIn()
            scheduleDailyQuote()
        }
        .alert("Enable Notifications", isPresented: $showingPermissionAlert) {
            Button("Open Settings") {
                notificationService.openSettings()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable notifications in Settings to receive reminders.")
        }
    }

    private func loadTimes() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let calendar = Calendar.current

        // Load mood check-in time
        if let date = formatter.date(from: moodCheckInTimeString) {
            let components = calendar.dateComponents([.hour, .minute], from: date)
            moodCheckInTime = calendar.date(from: components) ?? Date()
        }

        // Load quote time
        if let date = formatter.date(from: quoteTimeString) {
            let components = calendar.dateComponents([.hour, .minute], from: date)
            quoteTime = calendar.date(from: components) ?? Date()
        }
    }

    private func saveTime(_ time: Date, to binding: Binding<String>) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        binding.wrappedValue = formatter.string(from: time)
    }

    private func scheduleMoodCheckIn() {
        notificationService.scheduleMoodCheckIn(enabled: moodCheckInEnabled, time: moodCheckInTime)
    }

    private func scheduleDailyQuote() {
        notificationService.scheduleDailyQuote(enabled: quoteNotificationsEnabled, time: quoteTime)
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .notDetermined {
                    notificationService.requestPermission { granted in
                        if !granted {
                            showingPermissionAlert = true
                        }
                    }
                } else if settings.authorizationStatus == .denied {
                    showingPermissionAlert = true
                }
            }
        }
    }
}

struct DisclaimerView: View {
    @Environment(\.isDarkMode) var isDarkMode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Important Information")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                disclaimerSection(
                    title: "Not a Substitute for Professional Care",
                    content: "Nuvin is a wellness tool designed to help manage everyday stress and anxiety. It is not a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician, therapist, or other qualified health provider with any questions you may have regarding a medical or mental health condition."
                )

                disclaimerSection(
                    title: "In Case of Emergency",
                    content: "If you are experiencing a mental health emergency, having thoughts of harming yourself or others, or are in crisis, please contact emergency services immediately:\n\n• Call 911 (US)\n• National Suicide Prevention Lifeline: 988\n• Crisis Text Line: Text HOME to 741741\n• International Association for Suicide Prevention: https://www.iasp.info/resources/Crisis_Centres/"
                )

                disclaimerSection(
                    title: "Limitations of the App",
                    content: "Nuvin provides general wellness techniques and is not tailored to your specific medical or psychological needs. The breathing exercises, grounding techniques, and other tools are meant to complement professional treatment, not replace it."
                )

                disclaimerSection(
                    title: "User Responsibility",
                    content: "By using this app, you acknowledge that you are responsible for your own health decisions and that Nuvin and its creators assume no liability for any outcomes resulting from the use of this app."
                )

                disclaimerSection(
                    title: "Consult Your Healthcare Provider",
                    content: "Before starting any new wellness routine, especially if you have pre-existing health conditions, consult with your healthcare provider to ensure it's appropriate for you."
                )
            }
            .padding(20)
        }
        .background(Color.adaptiveBackground(isDark: isDarkMode))
        .navigationTitle("Disclaimer")
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private func disclaimerSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

            Text(content)
                .font(.system(size: 15))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct SupportView: View {
    @Environment(\.isDarkMode) var isDarkMode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("We're here to help")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                // Contact Support
                VStack(spacing: 0) {
                    supportRow(
                        icon: "envelope.fill",
                        title: "Email Support",
                        subtitle: "nathan@nuvin.app",
                        action: {
                            if let url = URL(string: "mailto:nathan@nuvin.app") {
                                UIApplication.shared.open(url)
                            }
                        }
                    )
                }
                .background(Color.adaptiveSupportGray(isDark: isDarkMode))
                .cornerRadius(12)

                // Crisis Resources
                Text("Crisis Resources")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                    .padding(.top, 8)

                VStack(spacing: 0) {
                    crisisResourceRow(
                        title: "National Suicide Prevention Lifeline",
                        contact: "988",
                        description: "24/7 confidential support",
                        action: {
                            if let url = URL(string: "tel://988") {
                                UIApplication.shared.open(url)
                            }
                        }
                    )

                    Divider().padding(.leading, 16)

                    crisisResourceRow(
                        title: "Crisis Text Line",
                        contact: "Text HOME to 741741",
                        description: "24/7 text support",
                        action: {
                            if let url = URL(string: "sms://741741&body=HOME") {
                                UIApplication.shared.open(url)
                            }
                        }
                    )

                    Divider().padding(.leading, 16)

                    crisisResourceRow(
                        title: "SAMHSA National Helpline",
                        contact: "1-800-662-4357",
                        description: "Treatment referral service",
                        action: {
                            if let url = URL(string: "tel://1-800-662-4357") {
                                UIApplication.shared.open(url)
                            }
                        }
                    )
                }
                .background(Color.adaptiveSupportGray(isDark: isDarkMode))
                .cornerRadius(12)

                // Additional Resources
                Text("Additional Resources")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                    .padding(.top, 8)

                VStack(spacing: 0) {
                    resourceRow(title: "Anxiety and Depression Association of America", url: "https://adaa.org")
                    Divider().padding(.leading, 16)
                    resourceRow(title: "National Alliance on Mental Illness", url: "https://nami.org")
                    Divider().padding(.leading, 16)
                    resourceRow(title: "Mental Health America", url: "https://mhanational.org")
                }
                .background(Color.adaptiveSupportGray(isDark: isDarkMode))
                .cornerRadius(12)

                Text("If you're experiencing a medical emergency, call 911 immediately.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.emergencyRed)
                    .padding(.top, 8)
            }
            .padding(20)
        }
        .background(Color.adaptiveBackground(isDark: isDarkMode))
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private func supportRow(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(Color.accentViolet)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private func crisisResourceRow(title: String, contact: String, description: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                    Text(contact)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.accentViolet)

                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                }

                Spacer()

                Image(systemName: "phone.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color.accentViolet)
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private func resourceRow(title: String, url: String) -> some View {
        Button(action: {
            if let webUrl = URL(string: url) {
                UIApplication.shared.open(webUrl)
            }
        }) {
            HStack {
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                    .multilineTextAlignment(.leading)

                Spacer()

                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 16))
                    .foregroundColor(Color.accentViolet)
            }
            .padding(16)
        }
    }
}

struct TermsView: View {
    @Environment(\.isDarkMode) var isDarkMode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Last Updated: January 2025")
                    .font(.system(size: 13))
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))

                termsSection(
                    title: "1. Acceptance of Terms",
                    content: "By downloading, installing, or using Nuvin (\"the App\"), you agree to be bound by these Terms & Conditions. If you do not agree to these terms, please do not use the App."
                )

                termsSection(
                    title: "2. Description of Service",
                    content: "Nuvin is a wellness application that provides stress and anxiety relief tools including breathing exercises, grounding techniques, mood tracking, and journaling features. The App is designed to support mental wellness and is not a substitute for professional medical care."
                )

                termsSection(
                    title: "3. Eligibility",
                    content: "You must be at least 13 years of age to use this App. If you are under 18, you must have parental or guardian consent to use the App. By using the App, you represent that you meet these eligibility requirements."
                )

                termsSection(
                    title: "4. User Responsibilities",
                    content: "You agree to:\n• Use the App only for lawful purposes and in accordance with these Terms\n• Not attempt to interfere with or disrupt the App's functionality\n• Not use the App in any way that could harm, disable, or impair the App\n• Take responsibility for maintaining the confidentiality of your device and any data stored on it\n• Seek professional help if you are in crisis or experiencing a mental health emergency"
                )

                termsSection(
                    title: "5. Subscription and Payments",
                    content: "Nuvin operates on a premium subscription model. Subscription details:\n• Payments are processed through Apple's App Store\n• Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period\n• You can manage or cancel subscriptions in your App Store account settings\n• Refunds are subject to Apple's refund policies\n• We reserve the right to modify subscription pricing with notice to users"
                )

                termsSection(
                    title: "6. Intellectual Property",
                    content: "All content, features, and functionality of the App, including but not limited to text, graphics, logos, designs, and software, are owned by Nuvin or its licensors and are protected by copyright, trademark, and other intellectual property laws. You may not reproduce, distribute, modify, or create derivative works without express written permission."
                )

                termsSection(
                    title: "7. Medical Disclaimer",
                    content: "THE APP IS NOT A MEDICAL DEVICE AND DOES NOT PROVIDE MEDICAL ADVICE. The information and tools provided are for general wellness purposes only. Always consult with qualified healthcare professionals regarding any medical or mental health concerns. In case of emergency, call 911 or your local emergency services immediately."
                )

                termsSection(
                    title: "8. Limitation of Liability",
                    content: "TO THE MAXIMUM EXTENT PERMITTED BY LAW, NUVIN AND ITS CREATORS SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, OR ANY LOSS OF PROFITS OR REVENUES, WHETHER INCURRED DIRECTLY OR INDIRECTLY, OR ANY LOSS OF DATA, USE, OR OTHER INTANGIBLE LOSSES RESULTING FROM YOUR USE OF THE APP."
                )

                termsSection(
                    title: "9. Indemnification",
                    content: "You agree to indemnify, defend, and hold harmless Nuvin and its officers, directors, employees, and agents from any claims, liabilities, damages, losses, costs, or expenses arising from your use of the App or violation of these Terms."
                )

                termsSection(
                    title: "10. Data and Privacy",
                    content: "Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and protect your information. By using the App, you consent to our data practices as described in the Privacy Policy."
                )

                termsSection(
                    title: "11. Termination",
                    content: "We reserve the right to suspend or terminate your access to the App at any time, with or without notice, for conduct that we believe violates these Terms or is harmful to other users, us, or third parties, or for any other reason."
                )

                termsSection(
                    title: "12. Changes to Terms",
                    content: "We may modify these Terms at any time. We will notify users of material changes through the App or via email. Your continued use of the App after changes are made constitutes acceptance of the modified Terms."
                )

                termsSection(
                    title: "13. Governing Law",
                    content: "These Terms shall be governed by and construed in accordance with the laws of the United States, without regard to its conflict of law provisions."
                )

                termsSection(
                    title: "14. Contact Information",
                    content: "If you have questions about these Terms, please contact us at:\nnathan@nuvin.app"
                )

                Text("By using Nuvin, you acknowledge that you have read, understood, and agree to be bound by these Terms & Conditions.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                    .padding(.top, 8)
            }
            .padding(20)
        }
        .background(Color.adaptiveBackground(isDark: isDarkMode))
        .navigationTitle("Terms & Conditions")
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private func termsSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

            Text(content)
                .font(.system(size: 15))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct PrivacyView: View {
    @Environment(\.isDarkMode) var isDarkMode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Last Updated: January 2025")
                    .font(.system(size: 13))
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))

                Text("Your privacy is critically important to us. This Privacy Policy explains how Nuvin (\"we\", \"us\", or \"our\") collects, uses, and protects your information.")
                    .font(.system(size: 15))
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))

                privacySection(
                    title: "1. Information We Collect",
                    content: "We collect and store the following types of information:\n\n• Usage Data: Information about how you use the App, including which features you access, session duration, and interaction patterns\n• Mood & Journal Data: Your mood logs, journal entries, and wellness tracking data stored locally on your device\n• Device Information: Device type, operating system version, and unique device identifiers for analytics purposes\n• Emergency Contact: If you choose to add an emergency contact, this information is stored locally on your device only\n\nIMPORTANT: Your journal entries and mood data are stored locally on your device by default and are not transmitted to our servers unless you explicitly choose to enable cloud backup features."
                )

                privacySection(
                    title: "2. How We Use Your Information",
                    content: "We use collected information for:\n• Providing and improving the App's functionality\n• Personalizing your experience and recommendations\n• Analyzing usage patterns to enhance features\n• Communicating with you about updates and support\n• Processing subscription payments through Apple\n• Complying with legal obligations\n\nWe do NOT:\n• Sell your personal information to third parties\n• Share your journal entries or mood data with anyone\n• Use your data for advertising purposes"
                )

                privacySection(
                    title: "3. Data Storage and Security",
                    content: "Your sensitive data (journal entries, mood logs, emergency contacts) is stored locally on your device using encrypted storage when possible. We implement industry-standard security measures to protect any data transmitted to our servers.\n\nHowever, no method of electronic storage or transmission is 100% secure. While we strive to protect your information, we cannot guarantee absolute security."
                )

                privacySection(
                    title: "4. Third-Party Services",
                    content: "We use the following third-party services:\n\n• Apple App Store: For payment processing and subscription management. Subject to Apple's Privacy Policy\n• Analytics Services: To understand app usage and improve performance. These services receive anonymized usage data only\n\nThese services have their own privacy policies, and we encourage you to review them."
                )

                privacySection(
                    title: "5. Data Retention and Deletion",
                    content: "• Local Data: You can delete your journal entries and mood logs at any time through the App\n• Account Data: If you delete the App, all locally stored data is removed from your device\n• Server Data: If we store any data on our servers (with your permission), you can request deletion at any time by contacting nathan@nuvin.app\n\nWe retain minimal data only for as long as necessary to provide our services and comply with legal obligations."
                )

                privacySection(
                    title: "6. Your Privacy Rights",
                    content: "Depending on your location, you may have the following rights:\n• Access: Request a copy of the data we hold about you\n• Correction: Request correction of inaccurate data\n• Deletion: Request deletion of your data\n• Objection: Object to certain types of data processing\n• Data Portability: Receive your data in a portable format\n\nTo exercise these rights, contact us at nathan@nuvin.app"
                )

                privacySection(
                    title: "7. Children's Privacy",
                    content: "Our App is not intended for children under 13. We do not knowingly collect personal information from children under 13. If you believe we have collected information from a child under 13, please contact us immediately so we can delete it."
                )

                privacySection(
                    title: "8. International Data Transfers",
                    content: "Your information may be transferred to and processed in countries other than your country of residence. These countries may have different data protection laws. By using the App, you consent to such transfers."
                )

                privacySection(
                    title: "9. GDPR Compliance (EU Users)",
                    content: "If you are in the European Union, we process your data based on:\n• Your consent (which you can withdraw at any time)\n• Performance of our contract with you\n• Legitimate interests in improving our services\n• Compliance with legal obligations\n\nYou have the right to lodge a complaint with your local data protection authority."
                )

                privacySection(
                    title: "10. California Privacy Rights (CCPA)",
                    content: "California residents have additional rights including:\n• Right to know what personal information we collect\n• Right to delete personal information\n• Right to opt-out of sale of personal information (note: we do not sell personal information)\n• Right to non-discrimination for exercising privacy rights"
                )

                privacySection(
                    title: "11. Changes to This Policy",
                    content: "We may update this Privacy Policy from time to time. We will notify you of significant changes through the App or via email. Your continued use of the App after changes are posted constitutes acceptance of the updated policy."
                )

                privacySection(
                    title: "12. Contact Us",
                    content: "If you have questions about this Privacy Policy or how we handle your data, please contact us at:\n\nEmail: nathan@nuvin.app\n\nWe will respond to your inquiry within 30 days."
                )

                Text("By using Nuvin, you acknowledge that you have read and understood this Privacy Policy.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                    .padding(.top, 8)
            }
            .padding(20)
        }
        .background(Color.adaptiveBackground(isDark: isDarkMode))
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private func privacySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

            Text(content)
                .font(.system(size: 15))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Subscription Management View

struct SubscriptionManagementView: View {
    @Environment(\.isDarkMode) var isDarkMode
    @ObservedObject private var subscriptionService = SubscriptionService.shared
    @State private var isRestoring = false
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Current Status Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color.accentViolet)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Plan")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))

                            if subscriptionService.isSubscribed {
                                Text(getPlanDisplayName(from: subscriptionService.currentSubscription?.productIdentifier))
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                            } else {
                                Text("No Active Plan")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                            }
                        }

                        Spacer()

                        if subscriptionService.isSubscribed {
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(Color.success)
                                    .frame(width: 8, height: 8)
                                Text("Active")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.success)
                            }
                        }
                    }

                    Divider()

                    // Subscription Details
                    if subscriptionService.isSubscribed, let subscription = subscriptionService.currentSubscription {
                        VStack(spacing: 12) {
                            // Renewal Date
                            if let expirationDate = subscription.expirationDate {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                                        .frame(width: 24)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(subscription.willRenew ? "Next Renewal" : "Expires")
                                            .font(.system(size: 13))
                                            .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))

                                        Text(formatDate(expirationDate))
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                                    }

                                    Spacer()
                                }
                            }

                            // Auto-Renew Status
                            HStack {
                                Image(systemName: subscription.willRenew ? "arrow.clockwise.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(subscription.willRenew ? Color.success : Color.warning)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Auto-Renewal")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))

                                    Text(subscription.willRenew ? "Enabled" : "Disabled")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                                }

                                Spacer()
                            }

                            // Plan Type (if not lifetime)
                            if let productId = subscription.productIdentifier, !productId.contains("Lifetime") {
                                HStack {
                                    Image(systemName: "creditcard")
                                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                                        .frame(width: 24)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Billing Cycle")
                                            .font(.system(size: 13))
                                            .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))

                                        Text(getBillingCycle(from: productId))
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
                                    }

                                    Spacer()
                                }
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("You don't have an active subscription")
                                .font(.system(size: 15))
                                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))

                            Text("Subscribe to unlock all premium features and support the app.")
                                .font(.system(size: 14))
                                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                        }
                    }
                }
                .padding(20)
                .background(Color.adaptiveSupportGray(isDark: isDarkMode))
                .cornerRadius(16)

                // Action Buttons
                VStack(spacing: 12) {
                    if subscriptionService.isSubscribed {
                        Button(action: openManageSubscription) {
                            HStack {
                                Image(systemName: "gear")
                                Text("Manage in App Store")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.accentViolet)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }

                    Button(action: restorePurchases) {
                        HStack {
                            if isRestoring {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "arrow.clockwise")
                                Text("Restore Purchases")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.lightBlue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isRestoring)
                }

                // Info Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("About Subscriptions")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(
                            icon: "checkmark.circle.fill",
                            text: "Subscriptions are managed through your Apple ID",
                            isDarkMode: isDarkMode
                        )

                        InfoRow(
                            icon: "checkmark.circle.fill",
                            text: "Cancel anytime in App Store settings",
                            isDarkMode: isDarkMode
                        )

                        InfoRow(
                            icon: "checkmark.circle.fill",
                            text: "Subscriptions automatically renew unless cancelled 24 hours before period ends",
                            isDarkMode: isDarkMode
                        )

                        InfoRow(
                            icon: "checkmark.circle.fill",
                            text: "Refunds are handled by Apple according to their policies",
                            isDarkMode: isDarkMode
                        )
                    }
                }
                .padding(.top, 8)

                // Links
                VStack(spacing: 0) {
                    Button(action: openTerms) {
                        HStack {
                            Text("Terms & Conditions")
                                .font(.system(size: 15))
                                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                            Spacer()

                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(Color.accentViolet)
                        }
                        .padding(16)
                    }

                    Divider().padding(.leading, 16)

                    Button(action: openPrivacy) {
                        HStack {
                            Text("Privacy Policy")
                                .font(.system(size: 15))
                                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                            Spacer()

                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(Color.accentViolet)
                        }
                        .padding(16)
                    }
                }
                .background(Color.adaptiveSupportGray(isDark: isDarkMode))
                .cornerRadius(12)
            }
            .padding(20)
        }
        .background(Color.adaptiveBackground(isDark: isDarkMode))
        .navigationTitle("Subscription")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await subscriptionService.checkSubscriptionStatus()
        }
        .alert("Restore Purchases", isPresented: $showRestoreAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(restoreMessage)
        }
    }

    // MARK: - Helper Functions

    private func getPlanDisplayName(from productIdentifier: String?) -> String {
        guard let identifier = productIdentifier else { return "Premium" }

        if identifier.contains("Monthly") {
            return "Premium Monthly"
        } else if identifier.contains("Annual") {
            return "Premium Annual"
        } else if identifier.contains("Lifetime") {
            return "Premium Lifetime"
        }
        return "Premium"
    }

    private func getBillingCycle(from productIdentifier: String) -> String {
        if productIdentifier.contains("Monthly") {
            return "Monthly"
        } else if productIdentifier.contains("Annual") {
            return "Yearly"
        }
        return "One-time"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func openManageSubscription() {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }

    private func restorePurchases() {
        isRestoring = true

        Task {
            do {
                let restored = try await subscriptionService.restorePurchases()

                await MainActor.run {
                    isRestoring = false
                    if restored {
                        restoreMessage = "Your purchases have been restored successfully!"
                    } else {
                        restoreMessage = "No previous purchases found. If you believe this is an error, please contact support."
                    }
                    showRestoreAlert = true
                }
            } catch {
                await MainActor.run {
                    isRestoring = false
                    restoreMessage = "Failed to restore purchases. Please try again or contact support."
                    showRestoreAlert = true
                }
            }
        }
    }

    private func openTerms() {
        if let url = URL(string: "https://nuvin.app/terms") {
            UIApplication.shared.open(url)
        }
    }

    private func openPrivacy() {
        if let url = URL(string: "https://nuvin.app/privacy") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Info Row Component

struct InfoRow: View {
    let icon: String
    let text: String
    let isDarkMode: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color.success)
                .frame(width: 20)

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Data Management View

struct DataManagementView: View {
    @Environment(\.isDarkMode) var isDarkMode
    @ObservedObject private var userDataService = UserDataService.shared
    @State private var showingDeleteConfirmation = false
    @State private var showingExportSuccess = false
    @State private var showingExportError = false
    @State private var isExporting = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your data is stored locally on this device and never sent to external servers without your permission.")
                        .font(.system(size: 15))
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Data Overview Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color.accentViolet)

                        Text("Your Data")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                        Spacer()
                    }

                    Divider()

                    // Data stats
                    VStack(spacing: 12) {
                        DataStatRow(
                            icon: "face.smiling",
                            label: "Mood Entries",
                            value: "\(userDataService.userStats.moodEntries.count)",
                            isDarkMode: isDarkMode
                        )

                        DataStatRow(
                            icon: "bolt.fill",
                            label: "Relief Sessions",
                            value: "\(userDataService.userStats.totalSessions)",
                            isDarkMode: isDarkMode
                        )

                        DataStatRow(
                            icon: "flame.fill",
                            label: "Current Streak",
                            value: "\(userDataService.userStats.currentStreak) days",
                            isDarkMode: isDarkMode
                        )

                        DataStatRow(
                            icon: "star.fill",
                            label: "Longest Streak",
                            value: "\(userDataService.userStats.longestStreak) days",
                            isDarkMode: isDarkMode
                        )

                        let favoriteCount = userDataService.userStats.favoriteExercises.compactMap { $0 }.count
                        DataStatRow(
                            icon: "heart.fill",
                            label: "Favorite Exercises",
                            value: "\(favoriteCount)",
                            isDarkMode: isDarkMode
                        )
                    }
                }
                .padding(20)
                .background(Color.adaptiveSupportGray(isDark: isDarkMode))
                .cornerRadius(16)

                // Export Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Export Your Data")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                    Text("Download all your mood logs, session history, and preferences as a JSON file. You can use this for backup or transfer to another device.")
                        .font(.system(size: 14))
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                        .fixedSize(horizontal: false, vertical: true)

                    Button(action: exportData) {
                        HStack {
                            if isExporting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export All Data")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.accentViolet)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isExporting)
                }

                // Delete Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Delete Your Data")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.emergencyRed)

                    Text("Permanently delete all your mood logs, journal entries, and session history from this device. This action cannot be undone.")
                        .font(.system(size: 14))
                        .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                        .fixedSize(horizontal: false, vertical: true)

                    Button(action: { showingDeleteConfirmation = true }) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Delete All Data")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.emergencyRed.opacity(0.1))
                        .foregroundColor(Color.emergencyRed)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.emergencyRed, lineWidth: 1.5)
                        )
                    }
                }

                // What's Stored Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("What Data We Store")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                    VStack(alignment: .leading, spacing: 10) {
                        StoredDataRow(
                            icon: "circle.fill",
                            title: "Mood Check-ins",
                            description: "Date, mood value, and session count",
                            isDarkMode: isDarkMode
                        )

                        StoredDataRow(
                            icon: "circle.fill",
                            title: "Relief Sessions",
                            description: "Technique used and timestamp",
                            isDarkMode: isDarkMode
                        )

                        StoredDataRow(
                            icon: "circle.fill",
                            title: "Preferences",
                            description: "App settings, favorite exercises, notification preferences",
                            isDarkMode: isDarkMode
                        )
                    }
                }
                .padding(.top, 8)
            }
            .padding(20)
        }
        .background(Color.adaptiveBackground(isDark: isDarkMode))
        .navigationTitle("Data Management")
        .navigationBarTitleDisplayMode(.large)
        .alert("Delete All Data?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("This will permanently delete all your mood logs, session history, and preferences. This action cannot be undone.\n\nAre you sure you want to continue?")
        }
        .alert("Export Successful", isPresented: $showingExportSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your data has been exported successfully. You can now save or share the file.")
        }
        .alert("Export Failed", isPresented: $showingExportError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Failed to export your data. Please try again or contact support if the problem persists.")
        }
    }

    // MARK: - Data Operations

    private func exportData() {
        isExporting = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                // Create exportable data structure
                let exportData: [String: Any] = [
                    "exportDate": ISO8601DateFormatter().string(from: Date()),
                    "appVersion": "1.2.0",
                    "userStats": [
                        "totalSessions": userDataService.userStats.totalSessions,
                        "currentStreak": userDataService.userStats.currentStreak,
                        "longestStreak": userDataService.userStats.longestStreak,
                        "lastSessionDate": userDataService.userStats.lastSessionDate?.ISO8601Format() ?? ""
                    ],
                    "moodEntries": userDataService.userStats.moodEntries.map { entry in
                        [
                            "id": entry.id.uuidString,
                            "date": ISO8601DateFormatter().string(from: entry.date),
                            "moodValue": entry.moodValue,
                            "description": entry.description,
                            "sessionCount": entry.sessionCount
                        ]
                    },
                    "favoriteExercises": userDataService.userStats.favoriteExercises.compactMap { $0?.rawValue }
                ]

                // Convert to JSON
                let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)

                // Create temporary file
                let tempDir = FileManager.default.temporaryDirectory
                let fileName = "Nuvin_Data_Export_\(Date().timeIntervalSince1970).json"
                let fileURL = tempDir.appendingPathComponent(fileName)

                try jsonData.write(to: fileURL)

                // Share the file
                DispatchQueue.main.async {
                    isExporting = false
                    shareFile(url: fileURL)
                }
            } catch {
                isExporting = false
                showingExportError = true
                print("Export error: \(error)")
            }
        }
    }

    private func shareFile(url: URL) {
        let activityController = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            // For iPad - prevent crash
            if let popover = activityController.popoverPresentationController {
                popover.sourceView = rootViewController.view
                popover.sourceRect = CGRect(x: rootViewController.view.bounds.midX,
                                           y: rootViewController.view.bounds.midY,
                                           width: 0, height: 0)
                popover.permittedArrowDirections = []
            }

            rootViewController.present(activityController, animated: true) {
                self.showingExportSuccess = true
            }
        }
    }

    private func deleteAllData() {
        // Reset user stats
        userDataService.userStats = UserStats()

        // Persist the empty stats to UserDefaults (UserDataService.saveUserStats is private)
        if let emptyData = try? JSONEncoder().encode(UserStats()) {
            UserDefaults.standard.set(emptyData, forKey: "UserStats")
        }

        // Clear old AppStorage values (backwards compatibility)
        UserDefaults.standard.removeObject(forKey: "emergencyContactName")
        UserDefaults.standard.removeObject(forKey: "emergencyContactPhone")
        UserDefaults.standard.removeObject(forKey: "emergencyContactRelationship")

        // Provide haptic feedback
        HapticManager.shared.notification(.success)
    }
}

// MARK: - Supporting Components

struct DataStatRow: View {
    let icon: String
    let label: String
    let value: String
    let isDarkMode: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color.accentViolet)
                .frame(width: 24)

            Text(label)
                .font(.system(size: 15))
                .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color.adaptiveText(isDark: isDarkMode))
        }
    }
}

struct StoredDataRow: View {
    let icon: String
    let title: String
    let description: String
    let isDarkMode: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 8))
                .foregroundColor(Color.accentViolet)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Toggle Row Component

struct GlassToggleRow: View {
    @Environment(\.isDarkMode) var isDarkMode
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color.accentViolet)
                .frame(width: 28)

            // Title and subtitle
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(Color.adaptiveText(isDark: isDarkMode))

                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(Color.adaptiveSecondaryText(isDark: isDarkMode))
            }

            Spacer()

            // Standard iOS Toggle
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.accentViolet)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.adaptiveSupportGray(isDark: isDarkMode))
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
}