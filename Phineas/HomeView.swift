//
//  HomeView.swift
//  Phineas
//
//

import SwiftUICore
import SwiftUI
import GoogleAPIClientForREST_Calendar



struct HomeView: View {
    @ObservedObject var authManager: AuthenticationManager
    @StateObject private var calendarManager = CalendarManager()
    @State private var events: [GTLRCalendar_Event] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let backgroundColor = Color(red: 231/255, green: 215/255, blue: 171/255)
    private let darkerColor = Color(red: 221/255, green: 205/255, blue: 161/255)
    
    var body: some View {
        NavigationView {
            VStack {
                if !authManager.hasCalendarAccess {
                    CalendarAccessView(authManager: authManager)
                } else {
                    CalendarEventsView(events: events, isLoading: isLoading, errorMessage: errorMessage)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        authManager.signOut()
                    }
                }) {
                    Text("Sign Out")
                        .padding()
                        .foregroundColor(.red)
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
            .onAppear {
                if authManager.hasCalendarAccess {
                    loadEvents()
                }
            }
        }
    }
    
    private func loadEvents() {
        isLoading = true
        calendarManager.fetchUpcomingEvents { result in
            isLoading = false
            switch result {
            case .success(let fetchedEvents):
                events = fetchedEvents
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct CalendarAccessView: View {
    @ObservedObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Calendar Access Required")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Text("Phineas needs access to your calendar to help manage your schedule and provide timely notifications.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Grant Calendar Access") {
                authManager.requestCalendarAccess()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

struct CalendarEventsView: View {
    let events: [GTLRCalendar_Event]
    let isLoading: Bool
    let errorMessage: String?
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else if events.isEmpty {
                Text("No upcoming events")
                    .foregroundColor(.secondary)
            } else {
                List(events, id: \.identifier) { event in
                    VStack(alignment: .leading) {
                        Text(event.summary ?? "Untitled Event")
                            .font(.headline)
                        if let start = event.start?.dateTime?.date {
                            Text(start, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
}
