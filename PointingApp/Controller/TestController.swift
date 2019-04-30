//
//  NewTestController.swift
//  PointingApp
//
//  Created by Berk on 27.11.18.
//  Copyright © 2018 Berk Olcay. All rights reserved.
//

import UIKit

enum TestControllerType {
    case edit(test: Test)
    case add
}

class TestController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var controllerMode: TestControllerType = .add
    
    @IBOutlet private weak var titleField: UITextField!
    @IBOutlet private weak var languagePicker: UIPickerView!
    @IBOutlet private weak var objectTextView: UITextView!
    
    var pickerData: [String] = [String]()
    //var pickerDataSelected: String = "English" todo remove
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect data to picker
        self.languagePicker.delegate = self
        self.languagePicker.dataSource = self
        pickerData = ["English", "German"]
        
        switch controllerMode {
        case .edit(_):
            self.title = "Edit Test"
            
        default:
            break
        }
    }

    //Settings for the Picker
    /////
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    /*
    // This method is triggered whenever the user makes a change to the picker selection.
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerDataSelected = pickerData[component]
        print(pickerDataSelected)
    }*/
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    ///////
    
    private func resetViewController(){
        if case let.edit(test) = controllerMode {
            titleField.text = test.testName
            
            
            //remove the language and add it as first so picker automatically selects old one in case english not selected
            pickerData = pickerData.filter{$0 != test.language}
            pickerData.insert(test.language, at: 0)
            
            var objectsString: String = ""
            for t in test.testItems {
                objectsString = objectsString + "/n" + t
            }
            objectTextView.text = objectsString
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let testTitle = titleField.text
        let language = pickerData[languagePicker.selectedRow(inComponent: 0)]
        let objectsString = objectTextView.text
        let objects = objectsString?.lines
        print (testTitle ?? "empty")
        print (language)
        print (objects)
        
        switch controllerMode{
            case .edit(let test):
                test.testName = testTitle!
                test.language = language
                test.testItems = objects!
    
        case .add: break
                //TODO	 remove break
                //TODO get the datahandler.test.count+1 to test id
                //let newTest = Test(testID: 1, testName: testTitle, langauage: language, testItems: objects)
                //something.tests.insert(newTest)
            //to do save to DataHandler.saveTestDataToJSON()
        }
    }
}

//extension to string class to separate string into lines.
extension String {
    var lines: [String] {
        var result: [String] = []
        enumerateLines { line, _ in result.append(line) }
        return result
    }
}
