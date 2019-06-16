//
//  MqttController.swift
//  mc3-gps
//
//  Created by Simon Wälti on 14.04.19.
//  Copyright © 2019 Simon Wälti. All rights reserved.
//

import Foundation
import CocoaMQTT
import UIKit


class MqttController {
    public var client:CocoaMQTT!
    
    let defaults = UserDefaults.standard
    let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
    
    var responseMessages: [String: ((_ topic:String,_ data: String?) -> Void)?] = [:]
    
    
    func connect() {
        
        client = CocoaMQTT(clientID: clientID, host: defaults.string(forKey: "server")!, port: 8883)
        client.allowUntrustCACertificate = true
        client.secureMQTT = true
        client.enableSSL = true
        client.autoReconnect = true;
        client.cleanSession = true
        client.username = defaults.string(forKey: "user")!
        client.password = defaults.string(forKey: "password")!
        client.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        client.keepAlive = 60
        client.delegate = self
        
        client.didReceiveMessage = { mqtt, message, id in
            print("Message received in topic \(message.topic) with payload \(message.string!)")
        }
        
        client.connect()
    }
    
    func disconnect() {
        // disconnect
        client.disconnect()
    }
    
    func subscribe(topic:String, callback: ((_ topic:String,_ data: String?) -> Void)?) {
        responseMessages[topic] = callback
    }
}


extension MqttController: CocoaMQTTDelegate {
    // Optional ssl CocoaMQTTDelegate
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        print("trust: \(trust)")
        /// Validate the server certificate
        ///
        /// Some custom validation...
        ///
        /// if validatePassed {
        ///     completionHandler(true)
        /// } else {
        ///     completionHandler(false)
        /// }
        completionHandler(true)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("ack: \(ack)")
        
        if ack == .accept {
            for topic in responseMessages {
                mqtt.subscribe(topic.key, qos: CocoaMQTTQOS.qos1)
            }
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        print("new state: \(state)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("message: \(message.string.debugDescription), id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        print("message: \(message.topic), id: \(id)")
        
        if let delegate = responseMessages[message.topic] {
            delegate?(message.topic, message.string)
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("topic: \(topic)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("topic: \(topic)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("\(err.debugDescription)")
    }
}






