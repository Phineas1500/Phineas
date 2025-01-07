//
//  CalendarManager.swift
//  Phineas
//
//

import GoogleAPIClientForREST_Calendar
import GoogleSignIn

class CalendarManager: ObservableObject {
    private var service: GTLRCalendarService?
    @Published var events: [GTLRCalendar_Event] = []
    
    init() {
        setupService()
    }
    
    private func setupService() {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            print("No user found when setting up calendar service")
            return
        }
        
        let service = GTLRCalendarService()
        service.authorizer = user.fetcherAuthorizer
        self.service = service
        print("Calendar service setup completed")
    }
    
    func reinitializeService() {
        setupService()
    }
    
    func fetchUpcomingEvents(completion: @escaping (Result<[GTLRCalendar_Event], Error>) -> Void) {
        guard let service = service else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Calendar service not initialized"])))
            return
        }
        
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")
        query.timeMin = GTLRDateTime(date: Date())
        query.maxResults = 10
        query.singleEvents = true
        query.orderBy = kGTLRCalendarOrderByStartTime
        
        service.executeQuery(query) { [weak self] (ticket, result, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let eventsList = result as? GTLRCalendar_Events else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                return
            }
            
            DispatchQueue.main.async {
                self?.events = eventsList.items ?? []
                completion(.success(eventsList.items ?? []))
            }
        }
    }
    
    func createEvent(title: String, startDate: Date, endDate: Date, completion: @escaping (Result<GTLRCalendar_Event, Error>) -> Void) {
        guard let service = service else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Calendar service not initialized"])))
            return
        }
        
        let event = GTLRCalendar_Event()
        event.summary = title
        
        let startDateTime = GTLRDateTime(date: startDate)
        let endDateTime = GTLRDateTime(date: endDate)
        
        event.start = GTLRCalendar_EventDateTime()
        event.start?.dateTime = startDateTime
        
        event.end = GTLRCalendar_EventDateTime()
        event.end?.dateTime = endDateTime
        
        let query = GTLRCalendarQuery_EventsInsert.query(withObject: event, calendarId: "primary")
        
        service.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let createdEvent = result as? GTLRCalendar_Event else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                return
            }
            
            completion(.success(createdEvent))
        }
    }
}
