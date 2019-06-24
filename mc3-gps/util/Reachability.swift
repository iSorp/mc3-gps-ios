//
//  Reachability.swift
//  mc3-gps
//
//  Created by Simon Wälti on 22.06.19.
//  Copyright © 2019 Simon Wälti. All rights reserved.
// 

import Foundation
import Reachability

fileprivate var reachability: Reachability!

protocol ReachabilityActionDelegate {
    func reachabilityChanged(_ isReachable: Bool, connection:Reachability.Connection)
}

protocol ReachabilityObserverDelegate: class, ReachabilityActionDelegate {
    func addReachabilityObserver()
    func removeReachabilityObserver()
}

/// Reachability cellular, wifi check
extension ReachabilityObserverDelegate {
    
    public func getConnection() -> Reachability.Connection {
        return reachability?.connection ?? Reachability.Connection.none
    }
    
    func allowsCellularConnection(status:Bool) {
        reachability?.allowsCellularConnection = status
    }
    
    func addReachabilityObserver() {
        reachability = Reachability()
        
        reachability.whenReachable = { [weak self] reachability in
            self?.reachabilityChanged(true, connection: reachability.connection)
        }
        
        reachability.whenUnreachable = { [weak self] reachability in
            self?.reachabilityChanged(false, connection: reachability.connection)
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func removeReachabilityObserver() {
        reachability.stopNotifier()
        reachability = nil
        //EventsManager.shared.removeListener(self)
    }
}
