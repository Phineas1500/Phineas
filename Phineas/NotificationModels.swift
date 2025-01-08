//
//  NotificationModels.swift
//  Phineas
//
//

import Foundation

enum UrgencyLevel: String, Codable {
    case low
    case medium
    case high
}

struct NotificationPreferences: Codable {
    var allowEventNotifications: Bool
    var allowEngagementReminders: Bool
    var minimumUrgencyLevel: UrgencyLevel
    
    init() {
        self.allowEventNotifications = true
        self.allowEngagementReminders = true
        self.minimumUrgencyLevel = .low
    }
}

struct UserPreferences: Codable {
    var notificationPreferences: NotificationPreferences
    var lastEngagementDate: Date?
    
    init() {
        self.notificationPreferences = NotificationPreferences()
        self.lastEngagementDate = nil
    }
}
