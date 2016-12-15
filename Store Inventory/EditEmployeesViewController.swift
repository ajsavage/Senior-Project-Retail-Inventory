//
//  EditEmployeesViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 12/14/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import FirebaseDatabase

class EditEmployeesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // Properties
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var table: UITableView!
    
    // reference to the inventory portion of the database
    let dataRef = FIRDatabase.database().reference().child("users")
    
    // Loading Animation
    var indicator: UIActivityIndicatorView? = nil
    
    // NSUserDefaults
    let prefs = NSUserDefaults.standardUserDefaults()
    
    // if already loading
    var isLoading = false
    
    // Number of employees to load at a time
    let loadNumber = 30
    
    // Array holding all of the users to display
    var users = Array<User>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showLoadingSymbol(table)
        loadMoreEmployees()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        users = Array<User>()
        showLoadingSymbol(table)
        loadMoreEmployees()
    }
    
    private func loadMoreEmployees() {
        if (!isLoading) {
            isLoading = true
            
            dataRef.queryOrderedByKey().queryLimitedToFirst(UInt(loadNumber)).observeEventType(.Value, withBlock: { snapshot in
                
                if !snapshot.exists() { return }
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    let dict = snapshot.value as? NSDictionary
                    
                    if (dict != nil) {
                        for unconvertedKey in dict!.allKeys {
                            let id: String = unconvertedKey as? String != nil ?
                                unconvertedKey as! String : "error"
                            let key: NSDictionary? = dict?.objectForKey(unconvertedKey) as? NSDictionary
                            
                            if key != nil {
                                let newUser: User = User()
                                
                                newUser.id = id
                                newUser.name = key!.valueForKey("DisplayName") as? String
                                newUser.type = key!.valueForKey("UserType") as? String
                                    
                                self.users.append(newUser)
                            }
                        }
                    }
                
                    self.table.reloadData()
                    self.isLoading = false
                    self.indicator?.removeFromSuperview()
                }
            })
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "EmployeeTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EmployeeTableViewCell
        let currentUser = users[indexPath.row]
        
        // Name
        cell.nameLabel.text = currentUser.name
        cell.managerCheckbox.enabled = false
        
        // User Permissions
        if (currentUser.type == "Manager") {
            cell.managerCheckbox.setImage(UIImage(named: "Checked"), forState: .Normal)
            cell.employeeCheckbox.setImage(UIImage(named: "Checked"), forState: .Normal)
            cell.employeeCheckbox.enabled = false
        }
        else {
            cell.employeeCheckbox.addTarget(self, action: #selector(checkboxSelected), forControlEvents: .TouchUpInside)
            cell.employeeCheckbox.userID = currentUser.id
        
            if currentUser.type == "Employee" {
                cell.employeeCheckbox.setImage(UIImage(named: "Checked"), forState: .Normal)
                cell.employeeCheckbox.isChecked = true
            }
            // Customers have no permissions
            else {
                cell.employeeCheckbox.isChecked = false
            }
        }
        
        // Loads more users if needed
        if (!isLoading && indexPath.row == users.count - 1) {
            showLoadingSymbol(cell)
            loadMoreEmployees()
        }
        
        return cell
    }
    
    // Employee checkbox button action
    func checkboxSelected(sender: CheckboxButton!) {
        if (sender.isChecked != nil) {
            // Check if box is already selected
            if (sender.isChecked!) {
                // User becomes a customer
                sender.setImage(UIImage(named: "Unchecked"), forState: .Normal)
                dataRef.child(sender.userID!).child("UserType").setValue("Customer")
            }
            else {
                // User becomes an employee
                sender.setImage(UIImage(named: "Checked"), forState: .Normal)
                dataRef.child(sender.userID!).child("UserType").setValue("Employee")
            }
        }
    }
    
    // Adds a loadiing symbol to the given view
    func showLoadingSymbol(loadingView: UIView) {
        indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        loadingView.addSubview(indicator!)
        indicator!.frame = loadingView.bounds
        indicator!.startAnimating()
    }
}
