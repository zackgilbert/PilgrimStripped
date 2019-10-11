//
//  AppDelegate.swift
//  PilgrimStripped
//
//  Created by Zack Gilbert on 3/4/19.
//  Copyright © 2019 Zack Gilbert. All rights reserved.
//

import UIKit
import Pilgrim
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // TODO #1 -- put your Pilgrim keys here:
        // Note: you should store these fields elsewhere and reference them via variable.
        PilgrimManager.shared().configure(withConsumerKey: "MY_CLIENT_ID",
                                          secret: "MY_CLIENT_SECRET",
                                          delegate: self)
        
        PilgrimManager.shared().isDebugLogsEnabled = true
        
        // Request ability to send notifications to this device:
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .badge, .alert]) { _, _ in }
        return true
    }
    
    func eventType(_ visit: GeofenceEvent) -> String {
        switch (visit.eventType) {
        case GeofenceEvent.EventType.entrance:
            return "Entrance"
        case GeofenceEvent.EventType.dwell:
            return "Dwell"
        case GeofenceEvent.EventType.venueConfirmation:
            return "Venue Confirmation"
        case GeofenceEvent.EventType.exit:
            return "Exit"
        case GeofenceEvent.EventType.presence:
            return "Presence"
        }
    }
    
}

// Your AppDelegate should conform to the PilgrimManagerDelegate, allowing you to properly handle visits and geofences that occur in the background:
extension AppDelegate: PilgrimManagerDelegate {
    
    // Handle how your app wants to handle visits:
    func pilgrimManager(_ pilgrimManager: PilgrimManager, handle visit: Visit) {
        // Send a notification of a visit event:
        UIApplication.shared.scheduleLocalNotification(
            title: "\(visit.hasDeparted ? "Departure from" : "Arrival at") \(visit.venue != nil ? visit.venue!.name : "somewhere?")",
            body: "Added a Pilgrim visit at: \(visit.displayName)"
        )
        let segments = visit.segments?.map { "\($0.name) (\($0.segmentId))" }
        print("Segments: \(segments?.joined(separator: ", ") ?? "")")
        let states = visit.userStates?.map { "\($0.name ?? "") (\($0.properties ?? [:]))" }
        print("User states: \(states?.joined(separator: ", ") ?? "")")
    }
    
    // Handle backfill visits (visits that occurred while there was no network connectivity, so get registered at a later time):
    func pilgrimManager(_ pilgrimManager: PilgrimManager, handleBackfill visit: Pilgrim.Visit) {
        // Send a notification of a backfilled visit event:
        UIApplication.shared.scheduleLocalNotification(
            title: "Backfill \(visit.hasDeparted ? "departure from" : "arrival at") \(visit.venue != nil ? visit.venue!.name : "somewhere?")",
            body: "Added a Pilgrim visit at: \(visit.displayName)"
        )
    }
    
    // Handle geofence events. More details: https://developer.foursquare.com/docs/pilgrim-sdk/geofences
    func pilgrimManager(_ pilgrimManager: PilgrimManager, handle geofenceEvents: [GeofenceEvent]) {
        // Send a notification of a geofence event:
        let names = geofenceEvents.map { "\($0.venue?.name ?? "Geofence") (\(eventType($0)))" }
        print("Geofence Venues: \(names.joined(separator: ", "))")
        UIApplication.shared.scheduleLocalNotification(title: "New Pilgrim Geofence Event", body: "Geofence Venues: \(names.joined(separator: ", "))")
    }
    
}

