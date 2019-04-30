//
//  TestItemViewController.swift
//  PointingApp
//
//  Created by Berk on 30.11.18.
//  Copyright © 2018 Berk Olcay. All rights reserved.
//

import UIKit

class TestObjectViewController: UIViewController {
    @IBOutlet private weak var testsItemsTableView: UITableView!
    
    var test: Test? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        testsItemsTableView.reloadData()
    }
}

extension TestObjectViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (test?.testItems.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        let item = test?.testItems.sorted() [indexPath.row]
        let TestTitle = test.testName ?? "No Test Name"
        
        cell.tag = test.testID
        cell.textLabel?.text = test.testName ?? "No Test Name"
        
        return cell
    }
    
    
}
