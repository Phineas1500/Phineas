//
//  AuthenticationManager.swift
//  Phineas
//
//

import SwiftUI
import GoogleSignIn

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    
    init() {
        if let user = GIDSignIn.sharedInstance.currentUser {
            print("User already signed in: \(user)")
            isAuthenticated = true
        }
    }
    
    func signIn() {
        // Get the client ID from the bundle
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String else {
            print("Error: No client ID found in bundle")
            return
        }
        
        // Get the URL scheme from the bundle
        guard let bundleId = Bundle.main.bundleIdentifier else {
            print("Error: No bundle identifier found")
            return
        }
        
        print("Bundle ID: \(bundleId)")
        print("Client ID: \(clientID)")
        
        // Configure GIDSignIn
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        // Get the root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Failed to get root view controller")
            return
        }
        
        print("Starting sign in process...")
        GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController
        ) { [weak self] signInResult, error in
            if let error = error {
                print("Sign in error: \(error.localizedDescription)")
                return
            }
            
            guard let result = signInResult else {
                print("No result from sign in")
                return
            }
            
            print("Sign in successful: \(result)")
            DispatchQueue.main.async {
                self?.isAuthenticated = true
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        isAuthenticated = false
    }
}
