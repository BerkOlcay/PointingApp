//
//  Settings.swift
//  PointingApp
//
//  Created by Berk on 20.11.18.
//  Copyright © 2018 Berk Olcay. All rights reserved.
//

import Foundation
class Settings: Codable{
    var id: Int
    var volumeLevel: Double
    var language: String //{ get { return self.language} set { self.language = newValue} }
    var cloudId: String
    var cloudPw: String
    
    
    init(id: Int, volumeLevel: Double, language: String, cloudId: String, cloudPw: String) {
        self.id = id
        self.volumeLevel = volumeLevel
        self.language = language
        self.cloudId = cloudId
        self.cloudPw = cloudPw
    }
    
    
    public func getLanguage () -> String{
        return self.language
    }
}
//Mark: -Extension: Equatable
extension Settings: Equatable {
    static func == (lhs: Settings, rhs: Settings) -> Bool{
        return lhs.id == rhs.id
    }
}

//mark: - extension: hashable
extension Settings: Hashable{
    var hashValue: Int{
        return id
    }
}

//to change language on fly
extension String {
    var localized: String {
        let lang = UserDefaults.standard.string(forKey: "i18n_language")
        
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)
        
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}
