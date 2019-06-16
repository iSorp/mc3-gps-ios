//
//  ViewController.swift
//  mc3-gps
//
//  Created by Simon Wälti on 13.04.19.
//  Copyright © 2019 Simon Wälti. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
//import GoogleMaps
import MapKit


class ViewController: UIViewController {
    let defaults = UserDefaults.standard
    
    var currentPosition:Position = Position(longitude: 0,latitude: 0,heigt: 0)
    
    @IBOutlet var mapView:MKMapView!
    @IBOutlet var distanceFilterText:UITextField!
    @IBOutlet var bgButton:UIButton!
    
    // set initial location in Honolulu
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    let locationManager = CLLocationManager()
    let mqtt = MqttController()
    let httpClient:HttpClient = HttpClient(host:"localhost")
    
    let topic_dop = "location/dop/";
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToEnterForeground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appTerminate), name: UIApplication.willTerminateNotification, object: nil)
        
        centerMapOnLocation(location: initialLocation)
        enableLocationServices()
        
        mqtt.subscribe(topic: topic_dop, callback: onMessageReceive)
        mqtt.connect()
    }
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue) {}
    
    
    @objc func appTerminate() {
        //startReceivingLocationChanges()
        mqtt.disconnect()
    }
    
    @objc func appMovedToEnterForeground() {
        locationManager.startUpdatingLocation()
    }
    
    
    @objc func appMovedToBackground() {
        locationManager.stopUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func distanceFilterEditingDidEnd(_ sender: UITextField) {
        if let text = sender.text as? String {
            locationManager.distanceFilter = Double(text)!
        }
    }
    
    @IBAction func bgButtonOnClick(sender: UIButton!) {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ViewControllerDop
        {
            let vc = segue.destination as? ViewControllerDop
            vc?.currentPosition = currentPosition
        }
    }
    
}

extension ViewController : CLLocationManagerDelegate {
    
    func enableLocationServices() {
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestWhenInUseAuthorization()
            return
            
        case .restricted, .denied:
            // Disable location features
            return
            
        case .authorizedWhenInUse:
            // Enable basic location features
            break
            
        case .authorizedAlways:
            // Enable any of your app's location features
            break
        }
        
        // Configure and start the service.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = Double(defaults.string(forKey: "distanceFilter") ?? "10")! // In meters.
        locationManager.delegate = self
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        currentPosition = Position(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude, heigt: location.altitude)
        
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        let current = MKPointAnnotation()
        current.title = "pos"
        current.coordinate = CLLocationCoordinate2D(latitude: coordinateRegion.center.latitude, longitude:coordinateRegion.center.longitude)
        mapView.addAnnotation(current)
        
        httpClient.postPosition(position: currentPosition)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    func onMessageReceive(topic:String, data: String?) {
        print("mqtt received")
    }
    
}
