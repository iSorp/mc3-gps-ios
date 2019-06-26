//
//  GeoFenceManager.swift
//  mc3-gps
//
//  Created by Simon Wälti on 26.06.19.
//  Copyright © 2019 Simon Wälti. All rights reserved.
//

import Foundation
import Reachability
import CoreLocation

class GeoFenceManager : ReachabilityObserverDelegate {
  
    static let instance : GeoFenceManager = GeoFenceManager()
    
    let latitude = 0
    let longitude = 0
    
    /// Singleton instance
    class var Instance : GeoFenceManager {
        return instance
    }
    
    fileprivate init() {
        
        let geoFenceRegion:CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(CLLocationDegrees(latitude), CLLocationDegrees(longitude)), radius: 50, identifier: "home")
        
        NotificationCenter.default.addObserver(self, selector: #selector(enterRegion(_:)), name: Notification.Name.enterRegion, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(exitRegion(_:)), name: Notification.Name.exitRegion, object: nil)
        
        LocationManager.Instance.locationManager.startMonitoring(for: geoFenceRegion)
    }

    @objc func enterRegion(_ notification: Notification) {
        if let userInfo = notification.userInfo, let region = userInfo["region"] as? CLRegion {
            do {
                if region.identifier == "home" {
                    pushNotification(message: "Willkommen zurück! Schalte doch bitte das WIFi ein")
                }
            } catch let error as Error {
                print(error.localizedDescription)
            }
        }
    }
    
    @objc func exitRegion(_ notification: Notification) {
        if let userInfo = notification.userInfo, let region = userInfo["region"] as? CLRegion {
            do {
                if region.identifier == "home" {
                   pushNotification(message: "Du hast das Zuhause verlassen. WIFi wird nicht mehr benötigt")
                }
            } catch let error as Error {
                print(error.localizedDescription)
            }
        }
    }
    
    func reachabilityChanged(_ isReachable: Bool, connection: Reachability.Connection) {
        
    }
    
    func pushNotification(message:String) {
        let notification = UILocalNotification()
        notification.alertAction = ""
        notification.alertBody = message
        notification.fireDate = NSDate(timeIntervalSinceNow: 1) as Date
        UIApplication.shared.scheduleLocalNotification(notification)
    }
}
