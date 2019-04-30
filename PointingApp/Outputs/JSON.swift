//
//  JsonOutput.swift
//  PointingApp
//
//  Created by Berk on 21.12.18.
//  Copyright © 2018 Berk Olcay. All rights reserved.
//

import Foundation
class JSON: OutputsAdapter{
    func generateOutputAlphabetical(test: Test, patient: Patient) -> String{
        //Format date output
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let subjectDict = [
            "firstName": patient.name,
            "lastName": patient.surname,
            "birthDate": dateFormatter.string(from: patient.birthday),
            "male": patient.gender,
			"handedness": patient.handedness.localized,
			"identificationNumber": patient.identificationNumber
            ] as [String : Any]
        
        let testDict = [
            "testName": test.testName,
            "testMode": test.mode
            ] as [String : Any]
        
        let testObjectsSorted = test.testObjects.sorted(by: {$0.name < $1.name})
        var answerDict = [NSDictionary]();
        for i in 0..<test.repetitionLimit {
            answerDict.append(["repetition": i+1])
            for j in testObjectsSorted {
                answerDict.append(
                    [
                        "question": j.name,
                        "gps": [j.GPSLocation[i*2], j.GPSLocation[i*2+1]],
                        "accelerometer": [j.AccelerometerData[i*3], j.AccelerometerData[i*3+1], j.AccelerometerData[i*3+2]]
                    ])
            }
        }
        
        let ret = [
            "subject": subjectDict,
            "test": testDict,
            "directions": answerDict
            ] as [String : Any]
        
        return NSString(data: try! JSONSerialization.data(withJSONObject: ret, options: .prettyPrinted), encoding: String.Encoding.utf8.rawValue) as! String
    }
    func generateOutputShuffled(test: Test, patient: Patient) -> String{
        //Format date output
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        

        let subjectDict = [
            "firstName": patient.name,
            "lastName": patient.surname,
            "birthDate": dateFormatter.string(from: patient.birthday),
            "male": patient.gender,
			"handedness": patient.handedness.localized,
			"identificationNumber": patient.identificationNumber
            ] as [String : Any]
        
        let testDict = [
            "testName": test.testName,
            "testMode": test.mode
            ] as [String : Any]
        
        var answerDict = [NSDictionary]();
        var i=0
        for object in test.testObjects {
            if (i % test.testObjects.count == 0){
                answerDict.append(["repetition": i/test.testObjects.count+1])
            }
            let GPSDataOfTheObject = [object.GPSLocation[(i/test.testObjects.count)*2], object.GPSLocation[(i/test.testObjects.count)*2+1]]
            let AccelerometerDataOfTheObject = [object.AccelerometerData[(i/test.testObjects.count)*3], object.AccelerometerData[(i/test.testObjects.count)*3+1], object.AccelerometerData[(i/test.testObjects.count)*3+2]]
            answerDict.append(
                    [
                        "question": object.name,
                        "gps": GPSDataOfTheObject,
                        "accelerometer": AccelerometerDataOfTheObject
                    ])
            i += 1
        }
        
        let ret = [
            "subject": subjectDict,
            "test": testDict,
            "directions": answerDict
            ] as [String : Any]
        
        return NSString(data: try! JSONSerialization.data(withJSONObject: ret, options: .prettyPrinted), encoding: String.Encoding.utf8.rawValue) as! String
    }
}
