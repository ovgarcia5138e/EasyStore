//
//  Space.swift
//  EasyStore
//
//  Created by Oscar Garcia Vazquez on 9/26/20.
//  Copyright © 2020 Oscar Garcia Vazquez. All rights reserved.
//

import Foundation


struct storageSpace {
    let address : String
    let maxRenters : Int
    let LocationType : Int
    let width : Int
    let height : Int
    let length : Int
    let dailyRate :Int
    
    init(address : String, maxRenters : Int, location : Int, width : Int, height : Int, length : Int, dailyRate : Int) {
        self.address = address
        self.maxRenters = maxRenters
        self.LocationType = location
        self.width = width
        self.height = height
        self.dailyRate = dailyRate
        self.length = length
    }
}

struct storageResponse : Codable {
    let id : String
    let latitude : Double
    let longitude : Double
    let rentalWidth : Int
    let rentalHeight : Int
    let rentalLength : Int
    let address : String
    let maxRenters : Int
}

struct location : Codable {
    let id : String
    let owner : String
    let latitude : Double
    let longitude : Double
    let rentalWidth : Int
    let rentalHeight : Int
    let rentalLength : Int
    let address : String
    let maxRenters : Int
    let currentRenters : Int
}

struct locations : Codable {
    let locations : [location]
}
