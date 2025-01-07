//
//  AuthenticationManager.swift
//  Phineas
//
//

import SwiftUI
import GoogleSignIn
import GoogleAPIClientForREST_Calendar

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var hasCalendarAccess = false
    
    private let calendarScopes = [
        "https://www.googleapis.com/auth/calendar",
        "https://www.googleapis.com/auth/calendar.events"
    ]
    
    init() {
        if let user = GIDSignIn.sharedInstance.currentUser {
            print("User already signed in: \(user)")
            isAuthenticated = true
            checkCalendarAccess()
        }
    }
    
    func signIn() {
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String else {
            print("Error: No client ID found in bundle")
            return
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Failed to get root view controller")
            return
        }
        
        // changed config to _
        _ = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController,
            hint: nil,
            additionalScopes: calendarScopes
        ) { [weak self] signInResult, error in
            if let error = error {
                print("Sign in error: \(error.localizedDescription)")
                return
            }
            
            // changed let result = signInResult to signInResult != nil
            guard signInResult != nil else {
                print("No result from sign in")
                return
            }
            
            DispatchQueue.main.async {
                self?.isAuthenticated = true
                self?.checkCalendarAccess()
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        isAuthenticated = false
        hasCalendarAccess = false
    }
    
    private func checkCalendarAccess() {
        if let user = GIDSignIn.sharedInstance.currentUser,
           let hasCalendarScope = user.grantedScopes?.contains("https://www.googleapis.com/auth/calendar") {
            DispatchQueue.main.async {
                self.hasCalendarAccess = hasCalendarScope
            }
        }
    }
    
    func requestCalendarAccess() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController,
            hint: nil,
            additionalScopes: calendarScopes
        ) { [weak self] signInResult, error in
            if let error = error {
                print("Error requesting calendar access: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self?.checkCalendarAccess()
            }
        }
    }
}
