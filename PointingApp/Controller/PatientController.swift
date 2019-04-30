//
//  PatientController.swift
//  PointingApp
//
//  Created by Berk on 04.12.18.
//  Copyright © 2018 Berk Olcay. All rights reserved.
//

import UIKit

class PatientController: UIViewController, UITextFieldDelegate {
    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet private weak var surnameField: UITextField!
    @IBOutlet private weak var birthdayPicker: UIDatePicker!
    @IBOutlet private weak var genderControl: UISegmentedControl!
    @IBOutlet weak var handednessControl: UISegmentedControl!
    @IBOutlet weak var identificationNumberField: UITextField!
    
    var test: Test!
    var patient: Patient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.delegate = self
        surnameField.delegate = self
        identificationNumberField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func testButtonPressed(_ sender: Any) {
        patient = Patient(name: nameField.text!, surname: surnameField.text!, birthday: birthdayPicker.date, gender: genderControl.selectedSegmentIndex, handedness: handednessControl.selectedSegmentIndex, identificationNumber: identificationNumberField.text!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let objectController as ObjectController:
            objectController.test = test
            objectController.patient = patient
        default:
            print("Unknown Destination ViewController")
        }
    }
    
    //Called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

/*
extension UIViewController {
    var patient: Patient {
        return (UIApplication.shared.delegate as! PatientController).patient
    }
}
*/
