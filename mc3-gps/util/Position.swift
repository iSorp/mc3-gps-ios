//
//  Position.swift
//  mc3-gps
//
//  Created by Simon Wälti on 16.06.19.
//  Copyright © 2019 Simon Wälti. All rights reserved.
//

import Foundation

struct Position {
    
    var longitude, latitude, altitude: Double
    var date:String? = nil
    
    init(latitude:Double, longitude:Double, altitude:Double, date:String? = nil){
        self.longitude = longitude
        self.latitude = latitude
        self.altitude = altitude
        self.date = date
    }
}
