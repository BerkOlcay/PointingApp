//
//  SettingsViewController.swift
//  PointingApp
//
//  Created by Berk on 23.11.18.
//  Copyright © 2018 Berk Olcay. All rights reserved.
//
import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet private weak var volumeSlider: UISlider!
    @IBOutlet private weak var englishButton: UIButton!
    @IBOutlet private weak var germanButton: UIButton!
    
    let userDefaults = UserDefaults.standard
    //var languageButtons = [englishButton, germanButton]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialization of volume stepper
        volumeSlider.maximumValue = 0.9
        volumeSlider.minimumValue = 0.1
        volumeSlider.value = Float(settings.volumeLevel)
        //Disable the button of the current language
        userDefaults.string(forKey: "i18n_language")
        if (Locale.current.languageCode == "en"){
            disableEnableButton(button: englishButton)
        } else if(Locale.current.languageCode == "de"){
            disableEnableButton(button: germanButton)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction private func changeLanguageToEnglish(_ sender: Any) {
        settings.language = "English"
        userDefaults.set(settings.language, forKey: "language")
        userDefaults.set("en", forKey: "i18n_language")
        userDefaults.set(["en"], forKey: "AppleLanguages")
        
        //for button in languageButtons { disableEnableButton(button: button) }
        disableEnableButton(button: englishButton)
        disableEnableButton(button: germanButton)
        
        closeApp()
    }
    @IBAction private func changeLanguageToGerman(_ sender: Any) {
        settings.language = "German"
        userDefaults.set(settings.language, forKey: "language")
        userDefaults.set("de", forKey: "i18n_language")
        userDefaults.set(["de"], forKey: "AppleLanguages")
        
        //for buttons in languageButtons { disableEnableButton(button: buttons) }
        disableEnableButton(button: englishButton)
        disableEnableButton(button: germanButton)
        
        closeApp()
    }
    @IBAction private func sliderValueChanged(_ sender: Any) {
        settings.volumeLevel = Double(volumeSlider.value)
        userDefaults.set(settings.volumeLevel, forKey: "volumeLevel")
    }
    
    func closeApp(){
        let alert = UIAlertController(title: "Alert", message: "exit_string".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in exit(0)}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func disableEnableButton(button: UIButton){
        if (button.isUserInteractionEnabled == true){
            button.isUserInteractionEnabled = false
            button.setTitleColor(.gray, for: .normal)
        } else {
            button.isUserInteractionEnabled = true
            button.setTitleColor(UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1), for: .normal)
        }
    }
    
}
