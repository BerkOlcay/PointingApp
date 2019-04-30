//
//  TestViewController.swift
//  PointingApp
//
//  Created by Berk on 20.11.18.
//  Copyright © 2018 Berk Olcay. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    @IBOutlet private weak var testsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        testsTableView.reloadData()
    }
    
    //this is necessary for the data of the pressed cell.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
            case let testObjectViewController as TestObjectViewController:
                guard let senderCell = sender as? UITableViewCell,
                    let test = DataHandler.test(withId: senderCell.tag) else {
                        print("Unknown Sender in segue to TestItemViewController")
                        return
                }
                testObjectViewController.test = test
        default:
            print("Unknown Destination ViewController")
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        testsTableView.setEditing(!testsTableView.isEditing, animated: true)
        if (testsTableView.isEditing){
            sender.style = .done
            sender.title = "Done".localized
        } else {
            sender.style = .plain
            sender.title = "Delete".localized
        }
    }
    
}

extension TestViewController: UITableViewDataSource{
    //return the number of the tests in app's language
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataHandler.tests.filter{ $0.language == settings.language }.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testCell", for: indexPath)
        let test = DataHandler.tests.filter{ $0.language == settings.language }.sorted(by: {$0.testID < $1.testID}) [indexPath.row]
        let TestTitle = test.testName ?? "No Test Name"
        
        cell.tag = test.testID
        cell.textLabel?.text = test.testName ?? "No Test Name"
        
        return cell
    }
}

extension TestViewController: UITableViewDelegate{
    // for deleting of the tests in the table. Swipe left to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            guard let cell = tableView.cellForRow(at: indexPath),
                let test = DataHandler.test(withId: cell.tag) else {
                    return
            }
            
            DataHandler.tests.remove(test)
            DataHandler.saveTestDataToJSON()
            tableView.deleteRows(at: [indexPath], with: .left)
        default:
            break
        }
    }
}
