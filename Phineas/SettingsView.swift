//
//  SettingsView.swift
//  Phineas
//
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var preferencesManager = UserPreferencesManager()
    @ObservedObject var notificationManager = NotificationManager.shared
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                switch notificationManager.notificationStatus {
                case .notDetermined:
                    Button("Enable Notifications") {
                        notificationManager.requestAuthorization()
                    }
                    
                case .denied:
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notifications are disabled")
                            .foregroundColor(.red)
                        Text("To enable notifications, please update your iPhone settings")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Button("Open Settings") {
                            notificationManager.openSettingsForNotifications()
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 4)
                    
                case .authorized:
                    Toggle("Event Notifications", isOn: $preferencesManager.preferences.notificationPreferences.allowEventNotifications)
                    Toggle("Engagement Reminders", isOn: $preferencesManager.preferences.notificationPreferences.allowEngagementReminders)
                    
                    Picker("Minimum Urgency Level", selection: $preferencesManager.preferences.notificationPreferences.minimumUrgencyLevel) {
                        Text("Low").tag(UrgencyLevel.low)
                        Text("Medium").tag(UrgencyLevel.medium)
                        Text("High").tag(UrgencyLevel.high)
                    }
                    
                case .unknown:
                    Text("Unable to determine notification status")
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("About")) {
                Text("Notification preferences help Phineas determine how and when to alert you about upcoming events and tasks.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Settings")
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                notificationManager.refreshNotificationStatus()
            }
        }
    }
}
