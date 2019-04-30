//
//  TestItemViewController.swift
//  PointingApp
//
//  Created by Berk on 30.11.18.
//  Copyright © 2018 Berk Olcay. All rights reserved.
//

import UIKit

class TestObjectViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var testModePicker: UIPickerView!
    @IBOutlet weak var repetitionPicker: UIPickerView!
    @IBOutlet private weak var testObjectsTableView: UITableView!
    
    var picker1Options : [String] = [String]()
    var picker2Options : [String] = [String]()
    var test: Test!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = test?.testName
        
        // Connect data to picker
        self.testModePicker.delegate = self
        self.testModePicker.dataSource = self
        self.repetitionPicker.delegate = self
        self.repetitionPicker.dataSource = self
        picker1Options = ["eyes_open".localized, "eyes_on_calibration_1".localized, "eyes_on_calibration_2".localized, "rotation_left".localized, "rotation_right".localized, "eyes_closed".localized, "mental_rotations_90".localized]
		picker2Options = ["1","2","3","4","5", "6", "7", "8", "9", "10"]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        testObjectsTableView.reloadData()
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
        if (pickerView.tag == 1){
            return picker1Options.count
        }else{
            return picker2Options.count
        }
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 1){
            return "\(picker1Options[row])"
        }else{
            return "\(picker2Options[row])"
        }
    }
    ///////
    @IBAction func startTestButtonPressed(_ sender: Any) {
        test?.repetitionLimit = Int(picker2Options[repetitionPicker.selectedRow(inComponent: 0)])!
        test?.mode = picker1Options[testModePicker.selectedRow(inComponent: 0)]
        test?.testObjects.shuffle()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let patientController as PatientController:
            patientController.test = test
        case let editTestController as TestController:
            editTestController.delegate = self          //Don't forget to set the delegate when moving for editing...
            let editTest = self.test
            editTestController.controllerMode = .edit(test: editTest!)
        default:
            print("Unknown Destination ViewController")
        }
    }
}

extension TestObjectViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (test?.testObjects.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "objectCell", for: indexPath)
        let object = test?.testObjects.sorted(by: {$0.name < $1.name}) [indexPath.row]
        
        cell.tag = (object?.ID)!
        cell.textLabel?.text = object?.name ?? "No Object Name"
        
        return cell
    }
}

extension TestObjectViewController: TestControllerDelegate {
    func didSelect(test: Test?) {
        self.test = test
        viewDidLoad()
    }
}

/*
extension UIViewController {
    var test: Test {
        return (UIApplication.shared.delegate as! TestObjectViewController).test
    }
}
*/
