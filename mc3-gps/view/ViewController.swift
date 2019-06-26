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
import CoreTelephony
//import GoogleMaps
import MapKit

///
/// ViewController for map.
///
class ViewController: UIViewController, MKMapViewDelegate {
    
    /// global position Variable
    public var currentPosition:Position = Position(latitude: 0,longitude: 0,altitude: 0)
    
    @IBOutlet var mapView:MKMapView!
    @IBOutlet var distanceFilterText:UITextField!
    @IBOutlet var bgButton:UIButton!
    
    var annotationView = MKMarkerAnnotationView()
    
    let defaults = UserDefaults.standard
    let regionRadius: CLLocationDistance = 1000
    let initialLocation = CLLocation(latitude: 0, longitude: 0)
    let mqtt = MqttController()
    let restClient = RestClient()
    
    let topic_dop = "location/dop/";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
       NotificationCenter.default.addObserver(self, selector: #selector(appTerminate), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(positionChanged(_:)), name: Notification.Name.locationChange, object: nil)
        
        centerMapOnLocation(location: initialLocation)
        mqtt.subscribe(topic: topic_dop, callback: onMessageReceive)
        mqtt.connect()
    }
    
    //************************* APP Handling *************************
    @objc func appTerminate() {
        mqtt.disconnect()
    }
    
    @objc func positionChanged(_ notification: Notification) {
        
       if let userInfo = notification.userInfo, let locations = userInfo["locations"] as? [CLLocation] {
            do {
                let location = locations.last!
                currentPosition = Position(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, altitude: location.altitude)
                
                let coordinateRegion = MKCoordinateRegion(center: location.coordinate,latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
                mapView.setRegion(coordinateRegion, animated: true)
                let current = MKPointAnnotation()
                current.title = String(format:"b:%.3f, l:%.3f, a:%.3f", currentPosition.latitude, currentPosition.longitude, currentPosition.altitude)
                current.coordinate = CLLocationCoordinate2D(latitude: coordinateRegion.center.latitude, longitude:coordinateRegion.center.longitude)
                
                // Post current position to the map
                mapView.addAnnotation(current)
            } catch let error as Error {
                print(error.localizedDescription)
            }
        }
    }
    
    //************************* Actions *************************
    @IBAction func distanceFilterEditingDidEnd(_ sender: UITextField) {
        if let text = sender.text as? String {
            // reload
            LocationManager.Instance.enableLocationServices()
        }
    }
    
    @IBAction func bgButtonOnClick(sender: UIButton!) {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
    }
    
    @IBAction func locButtonOnClick(sender: UIButton!) {
        PersistenceManager.Instance.exec(force:true)
        restClient.getLocations(completion:printLocations)
    }
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue) {
        
    }

    //************************* Callbacks *************************
    func onMessageReceive(topic:String, data: String?) {
        print("mqtt received")
    }
    
    //************************* Map control *************************
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ViewControllerDop
        {
            let vc = segue.destination as? ViewControllerDop
            vc?.currentPosition = currentPosition
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func printLocations(result:RestClient.Result<LocationStructs.Locations>) {
        
        var message:String = ""
        switch result {
        case .success(let response):
            for loc in response.embedded.locations {
                let point = LoadedAnnotation(loc.latitude, loc.longitude, title: String(format:"b:%.3f, l:%.3f, a:%.3f", loc.latitude, loc.longitude, loc.altitude))
                mapView.addAnnotation(point)
            }
        case .failure(let error):
            //fatalError("error: \(error.localizedDescription)")
            message = "error: \(error.localizedDescription)"
        }
    }
    
    /// Prints different colored Markers (green:new position, red:from database)
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        var color:UIColor = .green
        var identifier = "default"
        
        if annotation is LoadedAnnotation {
            color = .red
            identifier = "loaded"
        }
        
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            annotationView = dequedView
        } else{
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        annotationView.markerTintColor = .green
        
        return annotationView
    }
    
    /// Marker class for location originated in database
    class LoadedAnnotation:NSObject, MKAnnotation {
        var coordinate: CLLocationCoordinate2D
        var title: String?
        init(_ latitude:CLLocationDegrees,_ longitude:CLLocationDegrees,title:String){
            self.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            self.title = title
        }
    }
}
