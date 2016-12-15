//
//  EmployeeTableViewCell.swift
//  Store Inventory
//
//  Created by Andrea Savage on 12/14/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit

class EmployeeTableViewCell: UITableViewCell {
 
    //Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var employeeCheckbox: CheckboxButton!
    @IBOutlet weak var managerCheckbox: UIButton!
}

class CheckboxButton: UIButton {
    var isChecked: Bool?
    var userID: String?
}

class User: NSObject {
    var name: String?
    var type: String?
    var id: String?
}