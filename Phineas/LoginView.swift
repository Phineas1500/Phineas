//
//  LoginView.swift
//  Phineas
//
//

import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var animateGradient = false
    
    private let backgroundColor = Color(red: 231/255, green: 215/255, blue: 171/255)
    private let darkerColor = Color(red: 221/255, green: 205/255, blue: 161/255)
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Logo
            Image("PhineasAppIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
            
            // Welcome Text
            VStack(spacing: 10) {
                Text("Welcome to Phineas")
                    .font(.title)
                    .bold()
                Text("Your personal planning assistant")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Sign In Button
            Button(action: {
                authManager.signIn()
            }) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("Sign in with Google")
                        .font(.headline)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 2)
            }
            .padding(.horizontal, 40)
            
            Spacer()
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
    }
}
