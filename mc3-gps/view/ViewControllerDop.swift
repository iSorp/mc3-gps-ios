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
    
    public var currentPosition:Position = Position(longitude: 0,latitude: 0,heigt: 0)
    
    private let httpClient:HttpClient = HttpClient(host:"localhost")
    
    
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
    
    
    @IBAction func calcDop() {
        var message:String = ""
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy-HH-mm"
        let dateString:String =  dateFormatter.string(from: datePicker.date)
        let angle = viewAngleText.text ?? "15"
        
        httpClient.getDop(date: dateString,
                          phi: String(currentPosition.longitude),
                          lambda: String(currentPosition.latitude),
                          height: String(currentPosition.heigt),
                          angle: angle) { (result) in
                            
                            switch result {
                            case .success(let response):
                                
                                print(response)
                                message = response;
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
    
    @IBAction func calcBestDops() {
        var message:String = ""
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy-HH-mm"
        let dateString:String =  dateFormatter.string(from: datePicker.date)
        let angle = viewAngleText.text ?? "15"
        let minutes = timeIntervalText.text ?? "100"
        
        httpClient.getBestDop(date: dateString,
                              phi: String(currentPosition.longitude),
                              lambda: String(currentPosition.latitude),
                              height: String(currentPosition.heigt),
                              angle: angle,
                              minutes: minutes)
        { (result) in
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
