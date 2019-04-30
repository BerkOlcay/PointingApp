//
//  Cloud.swift
//  PointingApp
//
//  Created by Berk on 28.12.18.
//  Copyright © 2018 Berk Olcay. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST
import GoogleSignIn

class Cloud: UIViewController{
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheets, kGTLRAuthScopeDrive]
    private var sheetsService = GTLRSheetsService()
    private var driveService = GTLRDriveService()
    
    var test: Test!
    var patient: Patient!
    var outputController: OutputController!
    var isAlphabetical = true
    
    func generateOutputAlphabetical(test: Test, patient: Patient) -> String{
        self.test = test
        self.patient = patient
        self.isAlphabetical = true
        
        //Format date output
        findPointingAppFolder()
        
        return ""
    }
    
    func generateOutputShuffled(test: Test, patient: Patient) -> String{
        self.test = test
        self.patient = patient
        self.isAlphabetical = false
        
        //Format date output
        findPointingAppFolder()
        
        return ""
    }
    
    func setService(sheetsService: GTLRSheetsService, driveService: GTLRDriveService, outputController: OutputController) {
        self.sheetsService = sheetsService
        self.driveService = driveService
        self.outputController = outputController
    }
    
    func findPointingAppFolder(){ //root
        var folderId = ""
        /*
         When using the Drive v2 API, the name of the file is found under 'title', so a valid query is:
         title = 'TestDoc'
         
         Whereas in Drive v3 API, the name of the file is found under 'name':
         name = 'TestDoc'
         */
        let query = GTLRDriveQuery_FilesList.query()
        //query.q = "mimeType = 'application/vnd.google-apps.folder'"
        query.q = "mimeType='application/vnd.google-apps.folder' and name = 'PointingApp'"
        query.pageSize = 10
        
        
        driveService.executeQuery(query, completionHandler: {(ticket, files, error) in
            if (error == nil) {
                if let filesList : GTLRDrive_FileList = files as? GTLRDrive_FileList {
                    if let filesShow : [GTLRDrive_File] = filesList.files {
                        for file in filesShow {
                            folderId = file.identifier!
                        }
                        if (folderId == ""){
                            print ("Folder not found. Creating PointingApp folder.")
                            self.createFolder()
                        }
                        else{
                            print("Folder found. folderId = \(folderId)")
                            self.createSheets(folderId: folderId)
                        }
                    }
                }
            } else {
                print (error)
            }
        })
    }
    
    func createFolder(){ //root
        var folderId = ""
        let newFolder = GTLRDrive_File.init()
        newFolder.name = "PointingApp";
        newFolder.mimeType = "application/vnd.google-apps.folder";
        
        let query = GTLRDriveQuery_FilesCreate.query(withObject: newFolder, uploadParameters:nil)
        query.fields = "id";
        
        
        driveService.executeQuery(query, completionHandler :{(ticket, files, error) in
            if (error == nil) {
                if let file : GTLRDrive_File = files as! GTLRDrive_File {
                    print ("File created: \(file.identifier)")
                    folderId = file.identifier!
                    
                    self.createSheets(folderId: folderId)
                }
            } else {
                print ("An error occurred: \(error)")
            }
        })
    }
    
    func createSheets(folderId : String){
        let newSheet = GTLRSheets_Spreadsheet.init()
        let properties = GTLRSheets_SpreadsheetProperties.init()
        
        //Get today's date for Google Sheet's name
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        let today = dateFormatter.string(from: date)
        
        if (isAlphabetical){
            properties.title = "\(today) \(patient.name) \(patient.surname) Alphabetical"
        }
        else {
            properties.title = "\(today) \(patient.name) \(patient.surname) Shuffled"
        }
        newSheet.properties = properties
        
        let query = GTLRSheetsQuery_SpreadsheetsCreate.query(withObject:newSheet)
        query.fields = "spreadsheetId"
        
        query.completionBlock = { (ticket, result, NSError) in
            
            if let error = NSError {
                
            }
            else {
                let response = result as! GTLRSheets_Spreadsheet
                print ("Spreadsheet crated with the id = \(response.spreadsheetId)")
                self.updateSheets(spreadsheetID: response.spreadsheetId!)
                
                self.moveSpreadsheetToFolder(spreadsheetID: response.spreadsheetId!, folderID: folderId)
            }
        }
        sheetsService.executeQuery(query, completionHandler: nil)
        
        
    }
    
    func updateSheets(spreadsheetID: String){
        let range = "A1:D1" // range A to D
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        //todo
        var updateValues = [["Patient's name".localized, patient.name], ["Patient's surname".localized, patient.surname], ["Patient's birthday".localized,dateFormatter.string(from: patient.birthday)], ["Patient's gender".localized, patient.gender], ["Patient's handedness".localized, patient.handedness], ["Patient's identification number".localized, patient.identificationNumber], [], ["Name of the test".localized, test.testName], ["Mode of the test".localized, test.mode], []]
        
        if (isAlphabetical){
            let testObjectsSorted = test.testObjects.sorted(by: {$0.name < $1.name})
            for i in 0..<test.repetitionLimit {
                updateValues += [["\nTest \(i+1)\n"]]
                for j in testObjectsSorted{
                    let GPSDataOfTheObject =  [j.GPSLocation[i*2], j.GPSLocation[i*2+1]]
                    let stringGPSDataOfTheObject = GPSDataOfTheObject.map { String($0) }
                    let AccelerometerDataOfTheObject = [j.AccelerometerData[i*3], j.AccelerometerData[i*3+1], j.AccelerometerData[i*3+2]]
                    let stringAccelerometerDataOfTheObject = AccelerometerDataOfTheObject.map{ String($0) }
                    updateValues += [[j.name], ["GPS", ""] + stringGPSDataOfTheObject, ["Position"] + stringAccelerometerDataOfTheObject]
                }
            }
        }
        else {
            var i = 0
            for object in test.prevTestObjectsOrder {
                if (i % 5 == 0){
                    updateValues += [["\nTest \(i/test.testObjects.count+1)\n"]]
                }
                let GPSDataOfTheObject = [object.GPSLocation[(i/test.testObjects.count)*2], object.GPSLocation[(i/test.testObjects.count)*2+1]]
                let stringGPSDataOfTheObject = GPSDataOfTheObject.map { String($0) }
                let AccelerometerDataOfTheObject = [object.AccelerometerData[(i/test.testObjects.count)*3], object.AccelerometerData[(i/test.testObjects.count)*3+1], object.AccelerometerData[(i/test.testObjects.count)*3+2]]
                let stringAccelerometerDataOfTheObject = AccelerometerDataOfTheObject.map{ String($0) }
                updateValues += [[object.name], ["GPS", ""] + stringGPSDataOfTheObject, ["Position"] + stringAccelerometerDataOfTheObject]
                
                i += 1
            }
        }
        
        
        let valueRange = GTLRSheets_ValueRange() // GTLRSheets_ValueRange holds the updated values and other params
        valueRange.majorDimension = "ROWS" // Indicates horizontal row insert
        valueRange.range = range
        valueRange.values = updateValues
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: valueRange, spreadsheetId: spreadsheetID, range: range) // Use an append query to append at the first blank row
        query.valueInputOption = "USER_ENTERED"
        sheetsService.executeQuery(query) { ticket, object, error in
            print("Data entered into spreadsheet.")
        } // `GTLRServiceCompletionHandler` closure containing the service ticket, `GTLRSheets_AppendValuesResponse`, and any error
    }
    
    func moveSpreadsheetToFolder(spreadsheetID: String, folderID: String){
        
        let metadata = GTLRDrive_File()
        let query = GTLRDriveQuery_FilesGet.query(withFileId: spreadsheetID)
        query.fields = "parents";
        driveService.executeQuery(query, completionHandler :{(ticket, files, error) in
            let query = GTLRDriveQuery_FilesUpdate.query(withObject:metadata, fileId: spreadsheetID, uploadParameters:nil)
            query.fields = "parents";
            
            if (error == nil) {
                if let file : GTLRDrive_File = files as! GTLRDrive_File {
                    query.removeParents = file.parents?.first
                    query.addParents = folderID;
                    //query.removeParents = [file.parents]
                    
                    query.fields = "id, parents";
                    self.driveService.executeQuery(query, completionHandler :{(ticket, files, error) in
                        if (error == nil) {
                            print("Spreadsheet moved to the PointingApp folder.")
                            self.outputController.showAlert(title: "Success".localized, message: "Saved to drive".localized)
                        } else {
                            print("An error occurred in the process of moving the spreadsheet to the Pointing App folder.: \(error)")
                            self.outputController.showAlert(title: "Error".localized, message: "Problem on saving to drive".localized)
                        }
                    })
                }
            } else {
                print ("An error occurred: \(error)")
            }
        })
    }
    
    
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.default,
            handler: nil
        )
        alert.addAction(ok)
    }
}
