import UserNotifications
import SwiftUI
import GoogleAPIClientForREST_Calendar

class NotificationManager: ObservableObject {
    @Published var isNotificationsAuthorized = false
    @Published var notificationPreferences = NotificationPreferences()
    @Published var notificationStatus: NotificationStatus = .unknown
    
    static let shared = NotificationManager()
    
    init() {
        checkNotificationStatus()
    }
    
    enum NotificationStatus {
        case unknown
        case notDetermined
        case denied
        case authorized
    }
    
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { [weak self] success, error in
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self?.isNotificationsAuthorized = success
                self?.checkNotificationStatus()
            }
        }
    }
    
    func refreshNotificationStatus() {
        checkNotificationStatus()
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    self?.notificationStatus = .notDetermined
                case .denied:
                    self?.notificationStatus = .denied
                case .authorized:
                    self?.notificationStatus = .authorized
                    self?.isNotificationsAuthorized = true
                default:
                    self?.notificationStatus = .unknown
                }
            }
        }
    }
    
    func openSettingsForNotifications() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    func scheduleEventNotification(for event: GTLRCalendar_Event, urgencyLevel: UrgencyLevel) {
        guard let eventDate = event.start?.dateTime?.date,
              let title = event.summary else {
            print("Invalid event data for notification scheduling")
            return
        }
        
        // First, remove any existing notifications for this event
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(event.identifier ?? "")-notification"])
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = createNotificationBody(for: event, urgencyLevel: urgencyLevel)
        content.sound = .default
        
        // Get notification times based on urgency
        let timeIntervals = getNotificationTimeIntervals(for: urgencyLevel)
        
        for interval in timeIntervals {
            let triggerDate = eventDate.addingTimeInterval(-interval)
            
            // Only schedule if the trigger time is in the future
            if triggerDate > Date() {
                print("Creating notification for \(title)")
                print("Event time: \(eventDate)")
                print("Trigger time: \(triggerDate)")
                
                let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
                print("Notification components: \(components)")
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let identifier = "\(event.identifier ?? UUID().uuidString)-\(interval)"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("❌ Error scheduling notification: \(error.localizedDescription)")
                    } else {
                        print("✅ Successfully scheduled notification for \(title)")
                        print("   Will trigger at: \(triggerDate)")
                        
                        // List all pending notifications for verification
                        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                            print("Current pending notifications: \(requests.count)")
                            for request in requests {
                                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                                    print("- \(request.identifier): scheduled for \(trigger.nextTriggerDate() ?? Date())")
                                }
                            }
                        }
                    }
                }
            } else {
                print("⚠️ Skipping notification for \(title) as trigger time \(triggerDate) is in the past")
            }
        }
    }
    
    private func createNotificationBody(for event: GTLRCalendar_Event, urgencyLevel: UrgencyLevel) -> String {
        switch urgencyLevel {
        case .low:
            return "Upcoming: \(event.summary ?? "Event")"
        case .medium:
            return "Don't forget: \(event.summary ?? "Event") is coming up in 1 hour"
        case .high:
            return "Important: \(event.summary ?? "Event") requires your attention"
        }
    }
    
    private func getNotificationTimeIntervals(for urgencyLevel: UrgencyLevel) -> [TimeInterval] {
        switch urgencyLevel {
        case .low:
            return [3600] // 1 hour before
        case .medium:
            return [3600] // For testing, just 1 hour before
        case .high:
            return [7200, 3600] // 2 hours and 1 hour before
        }
    }
    
    func scheduleAppEngagementReminder() {
        guard notificationPreferences.allowEngagementReminders else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Update Your Plans with Phineas"
        content.body = "Take a moment to review and plan your upcoming tasks"
        content.sound = .default
        
        // Schedule for next day at 9 AM
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "engagement-reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling engagement reminder: \(error.localizedDescription)")
            }
        }
    }
}
