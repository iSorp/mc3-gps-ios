import Foundation
import UIKit
import CoreLocation
//import GoogleMaps
import MapKit

class ViewControllerDop: UIViewController, UITextFieldDelegate {
    let defaults = UserDefaults.standard
    
    @IBOutlet var timeIntervalText:UITextField!
    @IBOutlet var viewAngleText:UITextField!
    @IBOutlet var datePicker:UIDatePicker!
    
    public var currentPosition:Position = Position(latitude: 0,longitude: 0,altitude: 0)
    
    private let httpClient:RestClient = RestClient()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeIntervalText.text = "100"
        viewAngleText.text = "15"
        
        self.timeIntervalText.delegate = self
        self.viewAngleText.delegate = self
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    /// Dilution of Precision calculation
    @IBAction func calcDop() {
        var message:String = ""
        
        datePicker.timeZone = NSTimeZone.local
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let dateString:String =  dateFormatter.string(from: datePicker.date)
        let angle = viewAngleText.text ?? "15"
        
        httpClient.getDop(date: dateString,
            phi: String(currentPosition.longitude),
            lambda: String(currentPosition.latitude),
            height: String(currentPosition.altitude),
            angle: angle) { (result) in

                switch result {
                case .success(let response):
                    
                    print(response)
                    message = String(format: "%.3f", Double(response) ?? 0)
                case .failure(let error):
                    //fatalError("error: \(error.localizedDescription)")
                    message = "error: \(error.localizedDescription)"
                }

                let alert = UIAlertController(title: "Current DOP", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style {
                    case .default:
                        print("default")
                    case .cancel:
                        print("cancel")
                    case .destructive:
                        print("destructive")
                    }
                }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /// Calculation of the best Dilution of Precision
    @IBAction func calcBestDops() {
        var message:String = ""
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let dateString:String =  dateFormatter.string(from: datePicker.date)
        let angle = viewAngleText.text ?? "15"
        let minutes = timeIntervalText.text ?? "100"
        
        httpClient.getBestDop(date: dateString,
            phi: String(currentPosition.longitude),
            lambda: String(currentPosition.latitude),
            height: String(currentPosition.altitude),
            angle: angle,
            minutes: minutes) { (result) in
                
                switch result {
                case .success(let response):
                    for e in response {
                        print(e.date + " " + String(format: "%.3f", e.dop))
                        message += e.date + ": " + String(format: "%.3f", e.dop)+"\n"
                    }
                case .failure(let error):
                    //fatalError("error: \(error.localizedDescription)")
                    message = "error: \(error.localizedDescription)"
                }
            
                let alert = UIAlertController(title: "Best DOP", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style {
                    case .default:
                        print("default")
                    case .cancel:
                        print("cancel")
                    case .destructive:
                        print("destructive")
                    }
                }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
