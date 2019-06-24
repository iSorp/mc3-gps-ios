//
//  PrefetchController.swift
//  mc3-gps
//
//  https://github.com/ashleymills/Reachability.swift
//

import Foundation
import SQLite3
import Reachability
import CoreLocation

class PersistentManager : ReachabilityObserverDelegate {

    static let instance : PersistentManager = PersistentManager()
    
    let restClient = RestClient()
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("mc3-gps.sqlite")

    let TABLE_LOCATION = """
        CREATE TABLE IF NOT EXISTS location (id INTEGER PRIMARY KEY AUTOINCREMENT, latitude FLOAT(9,6), longitude FLOAT(9,6), altitude FLOAT(9,6), timestamp VARCHAR(255))
        """
    let DELETE = """
        DELETE FROM location;
        """
    let INSERT = """
        INSERT INTO location (latitude, longitude, altitude, timestamp) VALUES (?, ?, ?, ?);
        """
    let COUNT = """
        SELECT COUNT(id) FROM location;
        """
    let ENTRIES = """
        SELECT latitude, longitude, altitude, timestamp FROM location;
        """
    
    /// Singleton instance
    class var Instance : PersistentManager {
        return instance
    }
    
    fileprivate init() {
        
        destroyDatabase(fileURL:fileURL)
        guard let db = openDatabase(fileURL: fileURL) else {
            return
        }
        commandDatabase(db: db, commandStatement: TABLE_LOCATION)
        closeDatabase(db:db)

        addReachabilityObserver()
        allowsCellularConnection(status: false)
        NotificationCenter.default.addObserver(self, selector: #selector(positionChanged(_:)), name: Notification.Name.locationChange, object: nil)
    }
    
    deinit {
        removeReachabilityObserver()
    }
    
    /// If wifi is avaiable post prefetched locations
    func reachabilityChanged(_ isReachable: Bool, connection:Reachability.Connection) {
        switch connection {
            
        case .none: break;
        case .wifi:
            if isReachable {
                exec()
            }
        case .cellular:break;
        @unknown default:break;
        }
    }
    
    /// Prefetch data when position changes
    @objc func positionChanged(_ notification: Notification) {
        
       if let userInfo = notification.userInfo, let locations = userInfo["locations"] as? [CLLocation] {
            do {
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                let dateString:String =  dateFormatter.string(from: date)
                
                let location = locations.last!
                let pos = Position(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    altitude: location.altitude,
                    date: dateString)
                prefetch(position: pos)
            } catch let error as Error {
                print(error.localizedDescription)
            }
        }
    }
    
    /// Post prefetched locations
    func exec() {
        if getConnection() == .wifi  {
            let entries = getPositions()
            for entry in entries {
                restClient.postPosition(position:entry)
            }
            clear()
        }
    }
    
    /// Clear all prefetched locations
    func clear() {
        guard let db = openDatabase(fileURL: fileURL) else {
            return
        }
        commandDatabase(db:db, commandStatement: DELETE)
        closeDatabase(db:db)
    }
    
    /// Count prefetched locations
    func countPositions() -> Int32 {
        
        guard let db = openDatabase(fileURL: fileURL) else {
            return 0
        }
        var queryStatement: OpaquePointer? = nil
        var count:Int32 = 0
        if sqlite3_prepare_v2(db, COUNT, -1, &queryStatement, nil) == SQLITE_OK {
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                count = sqlite3_column_int(queryStatement, 0)
            }
            else{
                print("Query returned no results")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        closeDatabase(db:db)
        return count
    }
    
    /// Get prefetched locations
    func getPositions() -> [Position] {
        
        guard let db = openDatabase(fileURL: fileURL) else {
            return []
        }
        var queryStatement: OpaquePointer? = nil
        var entries:[Position] = []
        if sqlite3_prepare_v2(db, ENTRIES, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let pos = Position(
                    latitude: sqlite3_column_double(queryStatement, 0),
                    longitude: sqlite3_column_double(queryStatement, 1),
                    altitude: sqlite3_column_double(queryStatement, 2),
                    date: String(cString:sqlite3_column_text(queryStatement, 3)))
                entries.append(pos)
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        closeDatabase(db:db)
        return entries
    }
    
    /// Store locations
    func prefetch(position:Position) {
        guard let db = openDatabase(fileURL: fileURL) else {
            return
        }
        
        var insertStatement: OpaquePointer? = nil
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let dateString:String =  dateFormatter.string(from: date)
        
        if sqlite3_prepare_v2(db, INSERT, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_double(insertStatement, 1, position.latitude)
            sqlite3_bind_double(insertStatement, 2, position.longitude)
            sqlite3_bind_double(insertStatement, 3, position.altitude)
            
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            sqlite3_bind_text(insertStatement, 4, dateString, -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
        
        closeDatabase(db:db)
    }

}
