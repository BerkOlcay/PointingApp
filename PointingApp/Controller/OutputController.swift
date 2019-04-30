//
//  OutputController.swift
//  PointingApp
//
//  Created by Berk on 21.12.18.
//  Copyright © 2018 Berk Olcay. All rights reserved.
//
import GoogleAPIClientForREST
import GoogleSignIn
import UIKit
import MediaPlayer

class OutputController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    @IBOutlet weak var outputTextView: UITextView!
    @IBOutlet weak var saveToGoogleDriveButton: UIButton!
    @IBOutlet weak var textControl: UISegmentedControl!
    @IBOutlet weak var orderControl: UISegmentedControl!
    
    var test: Test!
    var patient: Patient!
    var plaintText = PlainText()
    var json = JSON()
    var cloud = Cloud()
    
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheets, kGTLRAuthScopeDrive]
    private let sheetsService = GTLRSheetsService()
    private let driveService = GTLRDriveService()
    let signInButton = GIDSignInButton()
    
    var sharedResults = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Hide volume HUD
        let systemVolumeView = MPVolumeView(frame: CGRect(origin: .init(x: -1000, y: -1000), size: CGSize(width: 100, height: 100)))
        view.addSubview(systemVolumeView)
        ////
        
        //Change Back button to main menu
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "View Tests".localized, style: .plain, target: self, action: #selector(OutputController.goToTestViews))
        
        //set up share button.
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(OutputController.shareAction))
        navigationItem.rightBarButtonItem = shareButton
        
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        
        // Add the sign-in button.
        view.addSubview(signInButton)
        //view.insertSubview(signInButton, at: 0)
        saveToGoogleDriveButton.isHidden = true
        
        //Initalize text Control
        textControl.removeAllSegments()
        textControl.insertSegment(withTitle: "JSON".localized, at: 0, animated: true)
        textControl.insertSegment(withTitle: "Plain Text".localized, at: 0, animated: true)
        textControl.selectedSegmentIndex = 0
        orderControl.removeAllSegments()
        orderControl.insertSegment(withTitle: "Shuffled".localized, at: 0, animated: true)
        orderControl.insertSegment(withTitle: "Alphabetical".localized, at: 0, animated: true)
        orderControl.selectedSegmentIndex = 0
        outputTextView.text = plaintText.generateOutputAlphabetical(test: test, patient: patient)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GIDSignIn.sharedInstance().signInSilently()
    }
    
    @IBAction func textControlValueChanged(_ sender: Any) {
        if (textControl.selectedSegmentIndex == 0) {
            if (orderControl.selectedSegmentIndex == 0) {
                outputTextView.text = plaintText.generateOutputAlphabetical(test: test, patient: patient)
            }
            else{
                outputTextView.text = plaintText.generateOutputShuffled(test: test, patient: patient)
            }
        }
        else {
            if (orderControl.selectedSegmentIndex == 0) {
                outputTextView.text = json.generateOutputAlphabetical(test: test, patient: patient)
            }
            else{
                outputTextView.text = json.generateOutputShuffled(test: test, patient: patient)
            }
        }
    }
    
    @IBAction func shareAction(_ sender: AnyObject) {
        let vc = UIActivityViewController(activityItems: [outputTextView.text], applicationActivities: nil)
        vc.popoverPresentationController?.sourceView = self.view
        vc.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            self.sharedResults = completed
        }
        present(vc, animated: true, completion: nil)
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.sheetsService.authorizer = nil
            self.driveService.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.saveToGoogleDriveButton.isHidden = false
            self.sheetsService.authorizer = user.authentication.fetcherAuthorizer()
            self.driveService.authorizer = user.authentication.fetcherAuthorizer()
        }
        cloud.setService(sheetsService: self.sheetsService, driveService: self.driveService, outputController: self)
    }
    
    @IBAction func saveToGoogleDriveButtonPressed(_ sender: Any) {
        if (orderControl.selectedSegmentIndex == 0) {
            cloud.generateOutputAlphabetical(test: test, patient: patient)
        }
        else{
            cloud.generateOutputShuffled(test: test, patient: patient)
        }
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
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}

