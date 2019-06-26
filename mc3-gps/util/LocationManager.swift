//
//  LocationManager.swift
//  mc3-gps
//
//  Created by Simon Wälti on 23.06.19.
//  Copyright © 2019 Simon Wälti. All rights reserved.
//
import Foundation
import CoreLocation
import CoreTelephony


enum LocationServiceMode {
    case update
    case significant
    case none
}

class LocationManager : NSObject, CLLocationManagerDelegate {

    static let instance : LocationManager = LocationManager()

    let defaults = UserDefaults.standard
    let locationManager = CLLocationManager()

    var mode = LocationServiceMode.none
    var verboseMessage = ""
    var isRunning = false
    
    class var Instance : LocationManager {
        return instance
    }
    
    fileprivate override init() {
        super.init()
    }
    
    /// Start updating Location
    func enableLocationServices(mode:LocationServiceMode = LocationServiceMode.update) {
        
        locationManager.delegate = self
        self.mode = mode
        // Configure and start the service.
        switch mode {
        case .update:
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = Double(defaults.string(forKey: "distanceFilter") ?? "100")! // In meters.
            locationManager.startUpdatingLocation()
            isRunning = true
            break
        case .significant:
            // locationManager.startMonitoringSignificantLocationChanges()
            break
        @unknown default:
            break
        }
    }
    
    func disableLocationServices() {
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()
        isRunning = false
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name.locationChange.rawValue), object: self, userInfo: ["locations" : locations])
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name.enterRegion.rawValue), object: self, userInfo: ["region" : region])
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name.exitRegion.rawValue), object: self, userInfo: ["region" : region])
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    internal func locationManager(_ manager: CLLocationManager,
                                  didChangeAuthorization status: CLAuthorizationStatus) {
        var hasAuthorised = false
        switch status {
        case .restricted:
            break
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        default:
            hasAuthorised = true
        }
        
        if (hasAuthorised == true) {
            enableLocationServices(mode:mode)
        }
    }
}
