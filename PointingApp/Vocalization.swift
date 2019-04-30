//
//  Vocalization.swift
//  PointingApp
//
//  Created by Berk on 04.12.18.
//  Copyright © 2018 Berk Olcay. All rights reserved.
//
import UIKit
import Foundation
import AVFoundation

class Vocalization: UIViewController{
    let synth = AVSpeechSynthesizer()
    
    func speak(text: String){
        let utterance = AVSpeechUtterance(string: text)
        
        if (settings.language == "English"){
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        else if (settings.language == "German"){
            utterance.voice = AVSpeechSynthesisVoice(language: "de-DE")
        }
        
        //Stop if speaking and say the new text
        if(synth.isSpeaking){
            
            synth.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        synth.speak(utterance)
    }
}



