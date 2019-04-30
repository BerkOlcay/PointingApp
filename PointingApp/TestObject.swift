//
//  TestObject.swift
//  PointingApp
//
//  Created by Berk on 30.11.18.
//  Copyright © 2018 Berk Olcay. All rights reserved.
//

import Foundation
class TestObject: Codable{
    var ID: Int
    var name: String
    var GPSLocation: [Double]
    //var PhonePosition: [Double]
    var AccelerometerData: [Double]
    
    init(ID: Int, name: String) {
        self.ID = ID
        self.name = name
        self.GPSLocation = []
        //self.PhonePosition = []
        self.AccelerometerData = []
    }
}
//Mark: -Extension: Equatable
extension TestObject: Equatable {
    static func == (lhs: TestObject, rhs: TestObject) -> Bool{
        return lhs.ID == rhs.ID
    }
}

//mark: - extension: hashable
extension TestObject: Hashable{
    var hashValue: Int{
        return ID
    }
}
