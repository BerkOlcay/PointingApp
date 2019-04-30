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
    var testObjects: [TestObject]
    var prevTestObjectsOrder: [TestObject] = []     //Stores the old shuffled order and values of it
    var mode: String = ""
    
    var currentIndex = 0
    var currentRepetition = 1
    var repetitionLimit = 0
    
    init(testID: Int, testName: String, langauage: String, testItems: [String]) {
        self.testID = testID
        self.testName = testName
        self.language = langauage
        
        //Need to create everyobject and store in the array
        testObjects = [TestObject]()
        for i in 0...testItems.count-1 {
            let newTestObject = TestObject(ID: i, name: testItems[i])
            self.testObjects.append(newTestObject)
        }
    }
    
    var currentObject: TestObject {
        return testObjects[currentIndex]
    }
    
    var numberOfRemainingItems: Int {
        return testObjects.count - 1 - currentIndex
    }
    
    var numberOfRemainingRepetition: Int{
        return repetitionLimit - currentRepetition
    }
    
    var isTestOver: Bool{
        if (numberOfRemainingItems > 0 || numberOfRemainingRepetition > 0){
            return false
        }
        else {
            return true
        }
        
    }
    
    func gotoNextItem() {
        if (numberOfRemainingItems > 0){
            currentIndex += 1
        }
        else { //This means one repetition is complete. Clear the counter, increment repetetion and save the shuffled order.
            currentIndex = 0
            currentRepetition += 1
            prevTestObjectsOrder += testObjects
            testObjects.shuffle()
        }
    }
    
    func gotoPreviousItem() {
        if (currentIndex > 0) {
            currentIndex -= 1
        }
        else {  //This means we need to decrement repetition and get the objects in previously shuffled order
            if (currentRepetition > 1) {
                currentRepetition -= 1
                currentIndex = testObjects.count - 1
                
                var j = 0
                if (!prevTestObjectsOrder.isEmpty){
                    for i in ((currentRepetition-1) * testObjects.count)...(((currentRepetition-1) * testObjects.count) + testObjects.count - 1){
                        
                        testObjects[j] = prevTestObjectsOrder[i]
                        
                        j += 1
                    }
                    
                    //after getting the old test objects, we need to delete them from prev test object because they are current.
                    prevTestObjectsOrder = Array(prevTestObjectsOrder.dropLast(testObjects.count))
                }
            }
        }
    }
    
    func gotoItem(_ item: TestObject) {  // not used in case we need it
        currentIndex = testObjects.index(of: item)!
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
