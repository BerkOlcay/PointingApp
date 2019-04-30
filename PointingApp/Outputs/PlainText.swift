//
//  PlainText.swift
//  PointingApp
//
//  Created by Berk on 21.12.18.
//  Copyright © 2018 Berk Olcay. All rights reserved.
//

import Foundation
class PlainText: OutputsAdapter{
    func generateOutputAlphabetical(test: Test, patient: Patient) -> String{
        //Format date output
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        var output = "Name:\t\t\t\t\t\(patient.name)\nSurname:\t\t\t\t\(patient.surname)\nBirthday:\t\t\t\t\(dateFormatter.string(from: patient.birthday))\nGender:\t\t\t\t\t\(patient.gender)\nHandedness:\t\t\t\(patient.handedness.localized)\nIdentification Number:\t\(patient.identificationNumber)\n"
		
        output = output + "\nTest Name:\t\(test.testName)\nTest Mode:\t\(test.mode)\n"
        
        let testObjectsSorted = test.testObjects.sorted(by: {$0.name < $1.name})
        for i in 0..<test.repetitionLimit {
            output = output + "\nTest \(i+1)\n"
            for j in testObjectsSorted{
                let GPSDataOfTheObject = [j.GPSLocation[i*2], j.GPSLocation[i*2+1]]
                let AccelerometerDataOfTheObject = [j.AccelerometerData[i*3], j.AccelerometerData[i*3+1], j.AccelerometerData[i*3+2]]
                output = output + "\(j.name)\nGPS:\t\(GPSDataOfTheObject)\nPosition:\t\(AccelerometerDataOfTheObject)\n\n"
            }
        }
        
        return output
    }
    func generateOutputShuffled(test: Test, patient: Patient) -> String{
        //Format date output
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateFormat = "dd.MM.yyyy"
		
        var output = "Name:\t\t\t\t\t\(patient.name)\nSurname:\t\t\t\t\(patient.surname)\nBirthday:\t\t\t\t\(dateFormatter.string(from: patient.birthday))\nGender:\t\t\t\t\t\(patient.gender)\nHandedness:\t\t\t\(patient.handedness.localized)\nIdentification Number:\t\(patient.identificationNumber)\n"
        
        output = output + "\nTest Name:\t\(test.testName)\nTest Mode:\t\(test.mode)\n"
        
        var i = 0
        for object in test.prevTestObjectsOrder {
            if (i % test.testObjects.count == 0){
                output = output + "\nTest \(i/test.testObjects.count+1)\n"
            }
            let GPSDataOfTheObject = [object.GPSLocation[(i/test.testObjects.count)*2], object.GPSLocation[(i/test.testObjects.count)*2+1]]
            let AccelerometerDataOfTheObject = [object.AccelerometerData[(i/test.testObjects.count)*3], object.AccelerometerData[(i/test.testObjects.count)*3+1], object.AccelerometerData[(i/test.testObjects.count)*3+2]]
            output = output + "\(object.name)\nGPS:\t\(GPSDataOfTheObject)\nPosition:\t\(AccelerometerDataOfTheObject)\n\n"
            
            i += 1
        }
        
        return output
    }
}
