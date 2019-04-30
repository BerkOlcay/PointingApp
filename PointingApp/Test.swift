//
//  Tests.swift
//  PointingApp
//
//  Created by Berk on 20.11.18.
//  Copyright © 2018 Berk Olcay. All rights reserved.
//

import Foundation
class Test: Codable{
    var testID: Int
    var testName: String
    var language: String
    var testItems: [String]
    
    init(testID: Int, testName: String, langauage: String, testItems: [String]) {
        self.testID = testID
        self.testName = testName
        self.language = langauage
        self.testItems = testItems
    }
}
//Mark: -Extension: Equatable
extension Test: Equatable {
    static func == (lhs: Test, rhs: Test) -> Bool{
        return lhs.testID == rhs.testID
    }
}

//mark: - extension: hashable
extension Test: Hashable{
    var hashValue: Int{
        return testID
    }
}
