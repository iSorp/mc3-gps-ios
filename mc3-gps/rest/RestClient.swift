//
//  RestClient
//  mc3-gps
//
//  Created by Simon Wälti on 16.06.19.
//  Copyright © 2019 Simon Wälti. All rights reserved.
//
import Foundation

class RestClient {
    
    let defaults = UserDefaults.standard
    
    var host:String
    var port:Int
    var userID:Int
    
    public init() {
        self.host = defaults.string(forKey: "apiServer") ?? ""
        self.port = Int(defaults.string(forKey: "apiPort") ?? "") ?? 8080
        self.userID = Int(defaults.string(forKey: "apiUserID") ?? "") ?? 1
    }
    
    enum Result<Value> {
        case success(Value)
        case failure(Error)
    }
    
    struct Post: Codable {
        let longitude: Double
        let latitude: Double
        let altitude: Double
        let timestamp: String
        let user: String
    }
    
    //************************* POST requests *************************
    func postPosition(position:Position, completion: (() -> Void)? = nil) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = "/locations/"
        
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        // Now let's encode out Post struct into JSON data...
        let encoder = JSONEncoder()
        do {
            let user = "http://" + host + ":" + String(port) + "/users/" + String(userID)
            let post = Post(
                longitude: position.longitude,
                latitude: position.latitude,
                altitude: position.altitude,
                timestamp: position.date!,
                user: user)
            
            let jsonData = try encoder.encode(post)
            request.httpBody = jsonData
            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
        } catch {
            return
        }
        
        // Create and run a URLSession data task with our JSON encoded POST request
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else {
                return
            }
            
            // APIs usually respond with the data you just sent in your POST request
            if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                print("response: ", utf8Representation)
            } else {
                print("no readable data received in response")
            }
            completion?()
        }
        task.resume()
    }
    
    //************************* GET requests *************************
    func getUsers(completion: ((Result<UserStructs.Users>) -> Void)?) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = "/users"
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        decodeStructAsync(request:request, session:session, completion:completion)
    }
    
    func getLocations(completion: ((Result<LocationStructs.Locations>) -> Void)?) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = "/locations"
        urlComponents.queryItems = [
            URLQueryItem(name: "size", value: "10000000"),
        ]
        
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        decodeStructAsync(request:request, session:session, completion:completion)
    }
    
    func getDop(date:String, phi:String, lambda:String, height:String, angle:String, completion: ((Result<String>) -> Void)?) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = "/satellites/visibles/dop"

        urlComponents.queryItems = [
            URLQueryItem(name: "date", value: date),
            URLQueryItem(name: "phi", value: phi),
            URLQueryItem(name: "lambda", value: lambda),
            URLQueryItem(name: "height", value: height),
            URLQueryItem(name: "angle", value: angle)
        ]
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        decodeValueAsync(request:request, session:session, completion:completion)
    }
    
    func getBestDop(date:String, phi:String, lambda:String, height:String, angle:String, minutes: String, completion: ((Result<DopStructs.Dops>) -> Void)?) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = "/satellites/visibles/dop/best"
        
        urlComponents.queryItems = [
            URLQueryItem(name: "date", value: date),
            URLQueryItem(name: "phi", value: phi),
            URLQueryItem(name: "lambda", value: lambda),
            URLQueryItem(name: "height", value: height),
            URLQueryItem(name: "angle", value: angle),
            URLQueryItem(name: "minutes", value: minutes)
        ]
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        decodeStructAsync(request:request, session:session, completion:completion)
    }
    
    //************************* AsyncTasks *************************
    func decodeStructAsync<T: Decodable>(request:URLRequest, session:URLSession, completion: ((Result<T>) -> Void)?) {
        
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            DispatchQueue.main.async {
                if let error = responseError {
                    completion?(.failure(error))
                } else if let jsonData = responseData {
                    
                    var jsonString:String = ""
                    jsonString = String(NSString(data: responseData!, encoding: String.Encoding.utf8.rawValue)!)
                    print (jsonString)
                    
                    let decoder = JSONDecoder()
                    
                    do {
                        let dec = try decoder.decode(T.self, from: jsonData)
                        completion?(.success(dec))
                    } catch {
                        completion?(.failure(error))
                    }
                    
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                    completion?(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    func decodeValueAsync<T>(request:URLRequest, session:URLSession, completion: ((Result<T>) -> Void)?) {
        
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            DispatchQueue.main.async {
                if let error = responseError {
                    completion?(.failure(error))
                } else if let data = responseData {
                    
                    var value:String = ""
                    value = String(NSString(data: responseData!, encoding: String.Encoding.utf8.rawValue)!)
                    print (value)
                    
                    do {
                        let v:T = value as! T
                        completion?(.success(v))
                    } catch {
                        completion?(.failure(error))
                    }
                    
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                    completion?(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}
