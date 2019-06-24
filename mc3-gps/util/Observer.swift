//
//  Observer.swift
//  mc3-gps
//
//  Created by Simon Wälti on 23.06.19.
//  Copyright © 2019 Simon Wälti. All rights reserved.
//

import Foundation

// Make notification names consistent and avoid stringly-typing.
// Try to use constants instead of strings or numbers.
extension Notification.Name {

    static let reachabilityChange = Notification.Name("reachabilityChange")
}

// The key to the notification's "userInfo" dictionary.
enum StatusKey: String {
    case locationKey
    case reachabilityKey
}

// This protocol forms the basic design for OBSERVERS,
// entities whose operation CRTICIALLY depends
// on the status of some other, usually single, entity.
// Adopters of this protocol SUBSCRIBE to and RECEIVE
// notifications about that critical entity/resource.
protocol ObserverProtocol {
    associatedtype T

    var value: T { get set }
    var notificationOfInterest: Notification.Name { get }
    func subscribe()
    func unsubscribe()
    func handleNotification()
    
}

// This template class abstracts out all the details
// necessary for an entity to SUBSCRIBE to and RECEIVE
// notifications about a critical entity/resource.
// It provides a "hook" (handleNotification()) in which
// subclasses of this base class can pretty much do whatever
// they need to do when specific notifications are received.
// This is basically an "abstract" class, not detectable
// at compile time, but I felt this was an exceptional case.
class Observer<T>: ObserverProtocol {

    var value:T
    
    let statusKey: String
    
    // The name of the notification this class has registered
    // to receive whenever messages are broadcast.
    let notificationOfInterest: Notification.Name
    
    // Initializer which registers/subscribes/listens for a specific
    // notification and then watches for a specific state as reported
    // by notifications when received.
    init() {

    }
    
    // Initializer which registers/subscribes/listens for a specific
    // notification and then watches for a specific state as reported
    // by notifications when received.
    func subscribe(statusKey: StatusKey, notification: Notification.Name, value:T) {
        self.statusKey = statusKey.rawValue
        self.notificationOfInterest = notification
        self.value = value
        subscribe()
    }
    
    // We're registering self (this) with NotificationCenter to receive
    // all notifications with the name stored in "notificationOfInterest."
    // Whenever one of those notifications is received, the
    // "receiveNotification(_:)" method is called.
    internal func subscribe() {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotification(_:)), name: notificationOfInterest, object: nil)
    }
    
    // It's a good idea to un-register from notifications when we no
    // longer need to listen, but this is more of a historic curiosity
    // as, since iOS 9.0, the OS does some type of cleanup.
    internal func unsubscribe() {
        NotificationCenter.default.removeObserver(self, name: notificationOfInterest, object: nil)
    }
    
    // Called whenever a message labelled "notificationOfInterest"
    // is received. This is our chance to do something when the
    // state of that critical resource we're observing changes.
    // This method "must have one and only one argument (an instance
    // of NSNotification)."
    @objc func receiveNotification(_ notification: Notification) {
        
        if let userInfo = notification.userInfo, let status = userInfo[statusKey] as? T {
            
            self.value = status
            handleNotification()
            
            print("Notification \(notification.name) received; status: \(status)")
            
        }
        
    } // end func receiveNotification
    
    // YOU MUST OVERRIDE THIS METHOD; YOU MUST SUBCLASS THIS CLASS.
    // I've MacGyvered this class into being "abstract" so you
    // can subclass and specialize as much as you want and not
    // have to worry about NotificationCenter details.
    func handleNotification() {
        fatalError("ERROR: You must override the [handleNotification] method.")
    }
    
    // Be kind and stop tapping a resource (NotificationCenter)
    // when we don't need to anymore.
    deinit {
        print("Observer unsubscribing from notifications.")
        unsubscribe()
    }
    
} // end class Observer


// An template for a subject, usually a single
// critical resource, that broadcasts notifications
// about a change in its state to many
// subscribers that depend on that resource.
protocol ObservedProtocol {
    associatedtype T
    var statusKey: StatusKey { get }
    var notification: Notification.Name { get }
    func notifyObservers(about changeTo: T) -> Void
}

// When an adopter of this ObservedProtocol
// changes status, it notifies ALL subsribed
// observers. It BROADCASTS to ALL SUBSCRIBERS.
extension ObservedProtocol {
    
    func notifyObservers(about changeTo: T) -> Void {
        NotificationCenter.default.post(name: notification, object: self, userInfo: [statusKey.rawValue : changeTo])
    }
    
} // end extension ObservedProtocol
