//
//  ViewController.swift
//  PilgrimStripped
//
//  Created by Zack Gilbert on 3/4/19.
//  Copyright © 2019 Zack Gilbert. All rights reserved.
//

import UIKit
import Pilgrim

class ViewController: UIViewController {
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var lastKnownField: UILabel!
    
    override func viewDidLoad() {
        locationManager.delegate = self
        
        super.viewDidLoad()
        
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        // For this example, we don't have a separate onboarding flow, so we can request Always On permissions right away to get Pilgrim started. But this could be done anywhere else in your app:
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
            print("Pilgrim: Requested Always On location permissions!")
        }
    }
    
    @IBAction func debugButton(_ sender: UIButton) {
        PilgrimManager.shared().presentDebugViewController(parentViewController: self)
    }
    
    @IBAction func testVisit(_ sender: UIButton) {
        // Only fires a local visit to visit handler.
        //PilgrimManager.shared().visitTester?.fireTestVisit(confidence: .medium, type: .venue, departure: false)
        // Fires a test visit that also hits our server and goes through to the server.
        // Use foreground to get current location...
        PilgrimManager.shared().getCurrentLocation { (currentLocation, error) in
            print(currentLocation!.currentPlace.otherPossibleVenues)
            // Example: currentLocation.currentPlace.venue.name
            var last = "Unknown"
            if (currentLocation?.currentPlace.arrivalLocation) != nil {
                PilgrimManager.shared().visitTester?.fireTestVisit(location: (currentLocation?.currentPlace.arrivalLocation)!)
                last = "Type: \(self.locationType(currentLocation?.currentPlace.locationType ?? Visit.LocationType.unknown))\nLocation: \(String(describing: currentLocation?.currentPlace.arrivalLocation))\nVenue: \(String(describing: currentLocation?.currentPlace.venue))"
            } else {
                last = "Could not fetch location...\n\(String(describing: error))"
            }
            self.lastKnownField.text = last
        }
    }
    
    func locationType(_ type: Visit.LocationType) -> String {
        switch (type) {
        case Visit.LocationType.home:
            return "Home"
        case Visit.LocationType.work:
            return "Work"
        case Visit.LocationType.venue:
            return "Venue"
        case Visit.LocationType.unknown:
            return "Unknown"
        default:
            return "Unknown"
        }
    }
    
    func startPilgrim() -> Void {
        // Start Pilgrim:
        PilgrimManager.shared().start()
        // You might also want to set a user's custom info here:
        let userInfo = UserInfo()
        // We know that once Pilgrim has started, we will have a unique installId, we have chosen in this app to use this as our user identifier:
        let userId = PilgrimManager.shared().installId
        // If you want to use your own ID, but it's not available until later (like when a user logs in), you could persist the variable when it is available...
        if let userId = userId {
            print("Userid: \(userId)")
            // and then set the userinfo's userid here if the variable is persisted:
            userInfo.setUserId(userId)
        }
        
        // You can also set custom userinfo fields using:
        userInfo.setUserInfo("My custom value", forKey: "myCustomKey")
        // Starting in Pilgrim v2.1.2, you have the ability to persist userinfo across sessions:
        PilgrimManager.shared().setUserInfo(userInfo, persisted: true)
    }
}

// Use the CLLocationManager's didChangeAuthorization to handle managing your location features upon user changed permission status:
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        print("Pilgrim: user's location permissions has changed (didChangeAuthorization was called)")
        switch status {
        case .restricted, .denied:
            // Location permissions not given, so Pilgrim will not properly run.
            print("Pilgrim Warning: Always On permission was denied by user.")
            break
            
        case .authorizedWhenInUse:
            // Pilgrim requires always on, but will still work with Foreground location. You could choose to enable When In Use only features here:
            print("Pilgrim Warning: Pilgrim stop detection requires Always On authorization. Only Foreground location feature is available with When In Use.")
            break
            
        case .authorizedAlways:
            // Enable Pilgrim and any other location features:
            print("Pilgrim: Always On permission successfully given. Pilgrim can successfully start!")
            // Note: You should call this in didChangeAuthorization so that if the user changes their location settings, you app will know to start Pilgrim. But you should still start Pilgrim from didFinishLaunchingWithOptions to ensure Pilgrim starts even if location permissions haven't changed.
            startPilgrim()
            break
            
        case .notDetermined:
            // Access not given. Do we want to re-request?
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        UIApplication.shared.scheduleLocalNotification(title: "SLC?", body: "SLC?")
    }
}
