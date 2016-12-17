//
//  EmployeeTableViewCell.swift
//  Store Inventory
//
//  Created by Andrea Savage on 12/14/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit

// Cell for the employee table view
class EmployeeTableViewCell: UITableViewCell {
 
    //Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var employeeCheckbox: UIButton!
    @IBOutlet weak var managerCheckbox: UIButton!
    var tracker: CheckboxButton = CheckboxButton()
}

// Object to add to views with checkboxes
class CheckboxButton: NSObject {
    var isChecked: Bool?
    var userID: String?
}

// Object to hold a user loaded into an employee table view cell
class User: NSObject {
    var name: String?
    var type: String?
    var id: String?
    var isChecked: Bool?
}