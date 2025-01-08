//
//  LoginView.swift
//  Phineas
//
//

import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var animateGradient = false
    @State private var showingNotificationAlert = false
    
    private let backgroundColor = Color(red: 231/255, green: 215/255, blue: 171/255)
    private let darkerColor = Color(red: 221/255, green: 205/255, blue: 161/255)
    
    @Environment(\.scenePhase) private var scenePhase
    
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
            
            // Notification Banner (when needed)
            if notificationManager.notificationStatus == .notDetermined {
                Button(action: {
                    notificationManager.requestAuthorization()
                }) {
                    HStack {
                        Image(systemName: "bell.badge")
                            .foregroundColor(.blue)
                        Text("Enable notifications to get the most out of Phineas")
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            } else if notificationManager.notificationStatus == .denied {
                Button(action: {
                    notificationManager.openSettingsForNotifications()
                }) {
                    HStack {
                        Image(systemName: "bell.slash")
                            .foregroundColor(.red)
                        Text("Enable notifications in Settings")
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
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
        .onAppear {
            // Check notification status when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if notificationManager.notificationStatus == .notDetermined {
                    showingNotificationAlert = true
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                notificationManager.refreshNotificationStatus()
            }
        }
        .alert("Enable Notifications", isPresented: $showingNotificationAlert) {
            Button("Not Now", role: .cancel) { }
            Button("Enable") {
                notificationManager.requestAuthorization()
            }
        } message: {
            Text("Get timely reminders about your tasks and events with Phineas")
        }
    }
}
