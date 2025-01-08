import SwiftUI

class UserPreferencesManager: ObservableObject {
    @Published var preferences: UserPreferences {
        didSet {
            savePreferences()
        }
    }
    
    private let preferencesKey = "user_preferences"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: preferencesKey),
           let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            self.preferences = preferences
        } else {
            self.preferences = UserPreferences()
        }
    }
    
    private func savePreferences() {
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: preferencesKey)
        }
    }
}
