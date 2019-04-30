//
//  Patient.swift
//  PointingApp
//
//  Created by Berk on 04.12.18.
//  Copyright © 2018 Berk Olcay. All rights reserved.
//

import Foundation
class Patient: Codable{
    var name: String
    var surname: String
    var birthday: Date
    var gender: String
    var handedness: String
	var identificationNumber: String
    
    init(name: String, surname: String, birthday: Date, gender: Int, handedness: Int, identificationNumber: String) {
        self.name = name
        self.surname = surname
        self.birthday = birthday
        self.identificationNumber = identificationNumber
        
        if (gender == 0){
            self.gender = "Male".localized
        }
        else{
            self.gender = "Female".localized
        }
		
		if (handedness == 0){
            self.handedness = "Lefthanded".localized
        }
        else{
            self.handedness = "Righthanded".localized
        }
    }
}
