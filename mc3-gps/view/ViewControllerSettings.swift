import Foundation
import UIKit
import CoreLocation
//import GoogleMaps
import MapKit


class ViewControllerSettings: UIViewController {
    let defaults = UserDefaults.standard
    
    @IBOutlet var mqttServerText:UITextField!
    @IBOutlet var mqttUserText:UITextField!
    @IBOutlet var mqttPassword:UITextField!
    @IBOutlet var distanceFilterText:UITextField!
    @IBOutlet var apiServerText:UITextField!
    @IBOutlet var apiPortText:UITextField!
    @IBOutlet var apiUserIDText:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mqttServerText.text = defaults.string(forKey: "mqttServer")
        mqttUserText.text = defaults.string(forKey: "mqttUser")
        mqttPassword.text = defaults.string(forKey: "mqttPassword")
        
        apiServerText.text = defaults.string(forKey: "apiServer")
        apiPortText.text = defaults.string(forKey: "apiPort")
        apiUserIDText.text = defaults.string(forKey: "apiUserID")
        
        distanceFilterText.text = defaults.string(forKey: "distanceFilter")
    }
    
    @IBAction func setSettings(sender: UIButton!) {
        defaults.set(mqttServerText.text, forKey: "mqttServer")
        defaults.set(mqttUserText.text, forKey: "mqttUser")
        defaults.set(mqttPassword.text, forKey: "mqttPassword")
        
        defaults.set(apiServerText.text, forKey: "apiServer")
        defaults.set(apiPortText.text, forKey: "apiPort")
        defaults.set(apiUserIDText.text, forKey: "apiUserID")
        
        defaults.set(distanceFilterText.text, forKey: "distanceFilter")
        
 
        
        self.performSegue(withIdentifier: "unwindToView", sender: self)
    }
    
}

