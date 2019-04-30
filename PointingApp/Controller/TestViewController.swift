//
//  ViewController.swift
//  PointingApp
//
//  Created by Berk on 20.11.18.
//  Copyright © 2018 Berk Olcay. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    @IBOutlet weak var testsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        testsTableView.reloadData()
    }


}

extension TestViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataHandler.testsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testCell", for: indexPath)
        let test = DataHandler.testsData.sorted(by: {$0.testID < $1.testID}) [indexPath.row]
        //let TestTitle = test.testName ?? "No Test Name"
        
        cell.tag = test.testID
        cell.textLabel?.text = test.testName ?? "No Test Name"
        
        return cell
    }
}
