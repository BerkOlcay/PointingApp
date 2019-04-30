//
//  JsonOutput.swift
//  PointingApp
//
//  Created by Berk on 21.12.18.
//  Copyright © 2018 Berk Olcay. All rights reserved.
//

import Foundation
class JSON: OutputsAdapter{
    func generateOutput(test: Test, patient: Patient) -> String{
        //Format date output
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        
        let subjectDict = [
            "firstName": patient.name,
            "lastName": patient.surname,
            "birthDate": df.string(from: patient.birthday),
            "male": patient.gender
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
}
