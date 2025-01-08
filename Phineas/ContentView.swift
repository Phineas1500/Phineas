//
//  ContentView.swift
//  Phineas
//
//

import SwiftUI
import GoogleSignInSwift

struct ContentView: View {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                HomeView(authManager: authManager)
                    .environmentObject(notificationManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
