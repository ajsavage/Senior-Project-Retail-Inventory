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
    
    // Reference to the inventory portion of the database
    let dataRef = FIRDatabase.database().reference().child("users")
    
    // Loading Animation
    var indicator: UIActivityIndicatorView? = nil
    
    // NSUserDefaults
    let prefs = NSUserDefaults.standardUserDefaults()
    
    // if already loading
    var isLoading = false
    
    // Number of employees to load at a time
    let loadNumber = 3
    
    // Array holding all of the users to display
    var users = Array<User>()
    
    // Overrides the viewDidLoad function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showLoadingSymbol(table)
        loadMoreEmployees()
    }
    
    // If using too much memory
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        users = Array<User>()
        showLoadingSymbol(table)
        loadMoreEmployees()
    }
    
    // Loads more employees to the table
    private func loadMoreEmployees() {
        // Checks if more employees are already being loaded
        if (!isLoading) {
            isLoading = true
            
            // Loads employees from database
            dataRef.queryOrderedByKey().queryLimitedToFirst(UInt(loadNumber)).observeEventType(.Value, withBlock: { snapshot in
                
                if !snapshot.exists() { return }
                
                // Loads products from snapchat in async thread
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    let dict = snapshot.value as? NSDictionary
                    
                    // Checks if the dictionary exists
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
                
                    // Reloads table on main thread
                    dispatch_async(dispatch_get_main_queue()) {
                        self.table.reloadData()
                        self.isLoading = false
                        self.indicator?.removeFromSuperview()
                    }
                }
            })
        }
    }
    
    // Table view delegate methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    // Loads a new employee cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "EmployeeTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EmployeeTableViewCell
        let currentUser = users[indexPath.row]
        
        // Name
        cell.nameLabel.text = currentUser.name
        cell.managerCheckbox.enabled = false
        cell.employeeCheckbox.tag = indexPath.row
        
        // User Permissions
        if (currentUser.type == "Manager") {
            cell.managerCheckbox.setImage(UIImage(named: "Checked"), forState: .Normal)
            cell.employeeCheckbox.setImage(UIImage(named: "Checked"), forState: .Normal)
            cell.employeeCheckbox.enabled = false
        }
        else {
            cell.employeeCheckbox.addTarget(self, action: #selector(checkboxSelected), forControlEvents: .TouchUpInside)
        
            if currentUser.type == "Employee" {
                cell.employeeCheckbox.setImage(UIImage(named: "Checked"), forState: .Normal)
                currentUser.isChecked = true
            }
            // Customers have no permissions
            else {
                currentUser.isChecked = false
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
    func checkboxSelected(sender: UIButton!) {
        let user: User = users[sender.tag]
        
        if (user.isChecked != nil) {
            // Check if box is already selected
            if (user.isChecked!) {
                // User becomes a customer
                sender.setImage(UIImage(named: "Unchecked"), forState: .Normal)
                dataRef.child(user.id!).child("UserType").setValue("Customer")
            }
            else {
                // User becomes an employee
                sender.setImage(UIImage(named: "Checked"), forState: .Normal)
                dataRef.child(user.id!).child("UserType").setValue("Employee")
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
