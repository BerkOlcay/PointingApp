//
//  ObjectController.swift
//  PointingApp
//
//  Created by Berk on 04.12.18.
//  Copyright © 2018 Berk Olcay. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation
import MapKit
import AVFoundation
import MediaPlayer


class ObjectController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var objectNameLabel: UILabel!
    @IBOutlet weak var compass: UIImageView!
    @IBOutlet weak var compassAngleLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var gpsLabel: UILabel!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var viewTestsButton: UIBarButtonItem!
    
    var locationManager = CLLocationManager()
    var motionManager = CMMotionManager()
    let vocalization = Vocalization()
    
    var accelerometerMeasurements = [Double]()
    var prevAccelerometerMeasurements = [0.0, 0.0, 0.0]
    var gpsMeasurements = [Double]()
    
    var test: Test!
    var patient: Patient!
    var testObject: TestObject!
    var volumeButtonLatency = 0.0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //to make done button invisible
        doneButton.tintColor = .clear
        doneButton.isEnabled = false
		//attach the button to the function
		viewTestsButton.title = "View Tests".localized
        
        
        // Setup for back button if first item go back to previous controller, else go to prev test object
        if !(test.currentRepetition == 1 && test.currentIndex == 0){
            self.navigationItem.hidesBackButton = true
            var back = UIBarButtonItem(
                title: "Back".localized,
                style: .plain,
                target: self,
                action: #selector(backAction(sender:))
            )
            self.navigationItem.leftBarButtonItem = back
        } else {
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.hidesBackButton = false
        }
        
        //Deactivate buttons to activate with observer latency
        if !(test.currentRepetition == 1 && test.currentIndex == 0){
            self.navigationItem.leftBarButtonItem?.isEnabled = false
        } else {
            self.navigationItem.hidesBackButton = true
        }
        self.viewTestsButton.isEnabled = false
        
        //Hide volume HUD
        let systemVolumeView = MPVolumeView(frame: CGRect(origin: .init(x: -1000, y: -1000), size: CGSize(width: 100, height: 100)))
        //systemVolumeView.alpha = 0.0 make vie invisible
        //systemVolumeView.isUserInteractionEnabled = false
        view.addSubview(systemVolumeView)
        
        
        MPVolumeView.setVolume(Float(settings.volumeLevel))

        testObject = test.currentObject
        self.title = ("Repet. \(test.currentRepetition)/\(test.repetitionLimit) Object \(test.currentIndex+1)/\(test.testObjects.count)")
        objectNameLabel.text = testObject.name
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.headingFilter = kCLHeadingFilterNone;
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            
            motionManager.startAccelerometerUpdates()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //latency of 5 sec to voice command for the first object
        if (self.test.currentIndex == 0 && self.test.currentRepetition == 1){
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                self.vocalization.speak(text: "Point to the following target:".localized + self.testObject.name)
            })
            volumeButtonLatency = 5
        }
        else{
            vocalization.speak(text: "Point to the following target:".localized + testObject.name)
            volumeButtonLatency = 2
        }
        
        //latency of 2 sec to volume buttons
        DispatchQueue.main.asyncAfter(deadline: .now() + volumeButtonLatency, execute: {
            self.listenVolumeButton()
            
            if !(self.test.currentRepetition == 1 && self.test.currentIndex == 0){
                self.navigationItem.leftBarButtonItem?.isEnabled = true
            } else {
                self.navigationItem.hidesBackButton = false
            }
            self.viewTestsButton.isEnabled = true
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("view did Disappeared")
        
        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: false)
        gpsLabel.text = ("(\(location.coordinate.latitude) / \(location.coordinate.longitude))")
        gpsMeasurements = [location.coordinate.latitude, location.coordinate.longitude]
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //  Created by Stefan Kohlbecher on 23.04.15.
        //  Copyright (c) 2015 DSGZ. All rights reserved.
        let accel = motionManager.accelerometerData?.acceleration
        
        let ax = accel!.x
        let ay = accel!.y
        let az = accel!.z
        let hx = newHeading.x
        let hy = newHeading.y
        let hz = newHeading.z
        
        let a = [ax, ay, az]
        let m = [hx, hy, hz]
        
        let s1 = normalize(cross(a, m))
        let s3 = normalize([-a[0], -a[1], -a[2]])
        let s2 = cross(s3,s1)
        
        //If the accelerometer measueremnts' difference is smaller than %5 from previous aceelerometer measurement, change the accelerometer Measurements
        //Otherwise we assume the position changed when pressing, or it's shaking and don't update the latest measurement.
        if (abs(prevAccelerometerMeasurements[0] * 1.05) > abs(invert([s1,s2,s3])[1][0]) && abs(prevAccelerometerMeasurements[0] * 0.95) <  abs(invert([s1,s2,s3])[1][0])
            && abs(prevAccelerometerMeasurements[1] * 1.05) > abs(invert([s1,s2,s3])[1][1]) && abs(prevAccelerometerMeasurements[1] * 0.95) <  abs(invert([s1,s2,s3])[1][1])
            && abs(prevAccelerometerMeasurements[2] * 1.05) > abs(invert([s1,s2,s3])[1][2]) && abs(prevAccelerometerMeasurements[2] * 0.95
            ) < abs(invert([s1,s2,s3])[1][2])){
            
            accelerometerMeasurements = invert([s1,s2,s3])[1]
            
            let angle = newHeading.magneticHeading*M_PI/180
            compassAngleLabel.text = NSString(format:"%3.0f°", angle*180/M_PI) as String
            compass.layer.transform = CATransform3DMakeRotation(CGFloat(-angle), 0, 0, 1);
        }
        prevAccelerometerMeasurements = invert([s1,s2,s3])[1]
        for i in 0...2{
            prevAccelerometerMeasurements[i] = Double(round(1000*prevAccelerometerMeasurements[i])/1000)
        }
        
    }
    
    func cross(_ a: [Double], _ b: [Double]) -> [Double] {
        return [
            a[1]*b[2]-a[2]*b[1],
            a[2]*b[0]-a[0]*b[2],
            a[0]*b[1]-a[1]*b[0]
        ]
    }
    
    func invert(_ A: [[Double]]) -> [[Double]] {
        return [
            [A[1][1]*A[2][2]-A[1][2]*A[2][1], A[2][1]*A[0][2]-A[2][2]*A[0][1], A[0][1]*A[1][2]-A[0][2]*A[1][1]],
            [A[2][0]*A[1][2]-A[2][2]*A[1][0], A[0][0]*A[2][2]-A[0][2]*A[2][0], A[1][0]*A[0][2]-A[1][2]*A[0][0]],
            [A[1][0]*A[2][1]-A[1][1]*A[2][0], A[2][0]*A[0][1]-A[2][1]*A[0][0], A[0][0]*A[1][1]-A[0][1]*A[1][0]]
        ]
    }
    
    func normalize(_ v: [Double]) -> [Double] {
        var sumOfSquares = 0.0
        for i in 0..<v.count {
            sumOfSquares += v[i]*v[i]
        }
        let len = sqrt(sumOfSquares)
        let ret = [v[0]/len, v[1]/len, v[2]/len]
        return ret
    }
    ///
    
    //Adds observer to volume so that we can track the changement
    func listenVolumeButton() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true, options: [])
            audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
        } catch {
            print ("listen volume button error.")
        }
    }
    
    //Function is used when volume changed
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume"{
            if (AVAudioSession.sharedInstance().outputVolume != Float(settings.volumeLevel)){
                // audio level should be same. Because we press it for next object
                MPVolumeView.setVolume(Float(settings.volumeLevel))

                //Save the mesaurements
                testObject.GPSLocation += gpsMeasurements
                testObject.AccelerometerData += accelerometerMeasurements
				
				AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                
                if (!test.isTestOver){
                    try AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")

                    //Test is not Over
                    test.gotoNextItem()
                    //UIApplication.shared.sendAction(nextButton.action!, to: nextButton.target, from: self, for: nil)
                    viewDidLoad()
                    viewWillAppear(true)
                } else {
                    test.gotoNextItem()
                    vocalization.speak(text: "Test finished.".localized)
                    UIApplication.shared.sendAction(doneButton.action!, to: doneButton.target, from: self, for: nil)
                }
            }
            
        }
    }
    
    //When arbitary back button pressed, revert the gps and accelerometer and call viewdidload again
    @objc func backAction(sender: UIBarButtonItem) {
        test.gotoPreviousItem()
        //Before going back get the previous object and drop the added points because we are concatanating not overwriting. We have to remove.
        let prevTestObject = test.currentObject
        prevTestObject.GPSLocation = Array(prevTestObject.GPSLocation.dropLast(2))
        prevTestObject.AccelerometerData = Array(prevTestObject.AccelerometerData.dropLast(3))
        
        try AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
        
        viewDidLoad()
        viewWillAppear(true)
    }
	
    @IBAction func viewTestsButtonPressed(_ sender: Any) {
        self.goToTestViews()
    }
    
    @objc func goToTestViews(){
        //let testViewController = TestViewController()
        //self.navigationController?.pushViewController(testViewController, animated: true)
        
        //Reset the test class before going back to test view
        DataHandler.test(withId: test.testID)?.currentIndex = 0
        DataHandler.test(withId: test.testID)?.currentRepetition = 1
        DataHandler.test(withId: test.testID)?.repetitionLimit = 0
        for object in (DataHandler.test(withId: test.testID)?.testObjects)!{
            object.GPSLocation = []
            //object.PhonePosition = []
            object.AccelerometerData = []
            self.test.prevTestObjectsOrder = []
        }
        
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as! [UIViewController];
        
        for aViewController in viewControllers {
            if(aViewController is TestViewController){
                self.navigationController!.popToViewController(aViewController, animated: true);
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let outputController as OutputController:
            outputController.test = self.test
            outputController.patient = self.patient
        default:
            print("Unknown Destination ViewController")
        }
    }
}

extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            slider?.value = volume
        }
    }
}
