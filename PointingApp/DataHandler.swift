//
//  DataHandler.swift
//  PointingApp
//
//  Created by Berk on 20.11.18.
//  Copyright © 2018 Berk Olcay. All rights reserved.
//

import Foundation
enum DataHandler {
    private enum TestConstants {
        static let fileName = "Tests.json"
        static var localStorageURL: URL{
            guard let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first else {
                fatalError ("Can't access the document directory in the user's home directory.")
            }
            return documentsDirectory.appendingPathComponent(TestConstants.fileName)
        }
    }
    
    // MARK: Stored Type Properties
    static var tests: Set<Test> = []
    
    static var nextTestID: Int {
        return tests.reduce(0, { $0 > $1.testID ? $0 : $1.testID }) + 1
    }
    
    // MARK: Type Methods
    static func test(withId id: Int) -> Test? {
        return tests.first(where: { $0.testID == id })
    }
    
    static func generateNewTestID() -> Int {
        var maxTestID = 0
        for test in tests{
            if (test.testID > maxTestID){
                maxTestID = test.testID
            }
        }
        return maxTestID + 1
    }
    
    static func loadTestDataFromJSON() {
        do {
            let fileWrapper = try FileWrapper(url: TestConstants.localStorageURL, options: .immediate)
            guard let data = fileWrapper.regularFileContents else {
                throw NSError()
            }
            tests = try JSONDecoder().decode(Set<Test>.self, from: data)
            print ("Decoded \(tests.count) tests.")
        } catch _ {
            print("Could not load Tests data, DataHandler uses empty setting")
        }
    }
    
    static func saveTestDataToJSON() {
        do {
            let data = try JSONEncoder().encode(tests)
            let jsonFileWrapper = FileWrapper(regularFileWithContents: data)
            try jsonFileWrapper.write(to: TestConstants.localStorageURL, options: FileWrapper.WritingOptions.atomic, originalContentsURL: nil)
            print("Saved tests.")
        } catch _ {
            print ("Couldn't not save Tests")
        }
    }
}
