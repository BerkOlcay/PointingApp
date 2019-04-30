//
//  NewTestController.swift
//  PointingApp
//
//  Created by Berk on 27.11.18.
//  Copyright © 2018 Berk Olcay. All rights reserved.
//

import UIKit

//Required for passsing back the edited test to testobjectview
protocol TestControllerDelegate: class {
    func didSelect(test: Test?)
}

enum TestControllerType {
    case edit(test: Test)
    case add
}

class TestController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {
    var controllerMode: TestControllerType = .add
    weak var delegate: TestControllerDelegate?
    
    @IBOutlet private weak var titleField: UITextField!
    @IBOutlet private weak var languagePicker: UIPickerView!
    @IBOutlet private weak var objectTextView: UITextView!
    
    var keyboardHeight : CGFloat = 0.0
    var pickerData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.objectTextView.delegate = self
        objectTextView.text = "TestControllertitleField".localized
        
        // Connect data to picker
        self.languagePicker.delegate = self
        self.languagePicker.dataSource = self
        pickerData = ["English".localized, "German".localized]
        
        switch controllerMode {
        case .edit(_):
            self.title = "Edit Test".localized
            resetViewController()
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
    
    ///Settings for text view a)size change when typing b) clearing of the input when editing started
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification , object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification , object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            objectTextView.contentInset = UIEdgeInsets.zero
        } else {
            objectTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        objectTextView.scrollIndicatorInsets = objectTextView.contentInset
        
        let selectedRange = objectTextView.selectedRange
        objectTextView.scrollRangeToVisible(selectedRange)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if case .add = controllerMode {
            objectTextView.text = ""
        }
    }
    ///////
    
    private func resetViewController(){
        if case let.edit(test) = controllerMode {
            titleField.text = test.testName
            
            //remove the language and add it as first so picker automatically selects old one in case english not selected
            pickerData = pickerData.filter{$0 != test.language.localized}
            pickerData.insert(test.language.localized, at: 0)
            
            var objectsString: String = ""
            for t in test.testObjects {
                objectsString = objectsString + t.name + "\n"
            }
            objectTextView.text = objectsString
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let testTitle = titleField.text
        var language = pickerData[languagePicker.selectedRow(inComponent: 0)]
        //Because code is in English and when you save as language = Deustch test view filter will search for German
        if (language == "Deutsch"){
            language = "German"
        }
        let objectsString = objectTextView.text
        let objects = objectsString?.lines
        
        switch controllerMode{
            case .edit(let test):
                var id = test.testID
                let oldTest = DataHandler.test(withId: id)
                DataHandler.tests.remove(oldTest!)
                let newTest = Test(testID: id, testName: testTitle!, langauage: language, testItems: objects!)
                DataHandler.tests.insert(newTest)
            
                //passing back the new test to the previous view
                delegate?.didSelect(test: newTest)
         
            case .add:
                
                let newTest = Test(testID: DataHandler.generateNewTestID(), testName: testTitle!, langauage: language, testItems: objects!)
                DataHandler.tests.insert(newTest)
        }
        DataHandler.saveTestDataToJSON()
        _ = navigationController?.popViewController(animated: true)         //Goes back to old view
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
