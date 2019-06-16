import Foundation
import UIKit
import CoreLocation
//import GoogleMaps
import MapKit


class ViewControllerSettings: UIViewController {
    let defaults = UserDefaults.standard
    
    @IBOutlet var serverText:UITextField!
    @IBOutlet var userText:UITextField!
    @IBOutlet var password:UITextField!
    @IBOutlet var distanceFilterText:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serverText.text = defaults.string(forKey: "server")
        userText.text = defaults.string(forKey: "user")
        password.text = defaults.string(forKey: "password")
        distanceFilterText.text = defaults.string(forKey: "distanceFilter")
        
    }
    
    @IBAction func setSettings(sender: UIButton!) {
        defaults.set(serverText.text, forKey: "server")
        defaults.set(userText.text, forKey: "user")
        defaults.set(password.text, forKey: "password")
        defaults.set(distanceFilterText.text, forKey: "distanceFilter")
        
        self.performSegue(withIdentifier: "unwindToView", sender: self)
    }
    
}

