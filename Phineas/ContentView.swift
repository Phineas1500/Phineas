//
//  ContentView.swift
//  Phineas
//
//

import SwiftUI
import GoogleSignInSwift

struct ContentView: View {
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                HomeView(authManager: authManager)  // Changed this line to pass authManager directly
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
