//
//  HomeView.swift
//  Phineas
//
//

import SwiftUI
import GoogleSignInSwift

struct HomeView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    private let backgroundColor = Color(red: 231/255, green: 215/255, blue: 171/255)
    private let darkerColor = Color(red: 221/255, green: 205/255, blue: 161/255)
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome back!")
                    .font(.title)
                    .padding()
                
                Spacer()
                
                Button("Sign Out") {
                    authManager.signOut()
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [backgroundColor, darkerColor],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
