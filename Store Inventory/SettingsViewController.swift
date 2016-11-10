//
//  SettingsViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 10/12/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var displayNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var favoritesTableView: UITableView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var favoritesLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var logoutButtonGuest: UIButton!
    @IBOutlet weak var otherLogout: UIButton!
 
    var userRef: FIRDatabaseReference? = nil
    var changingPassword = false
    
    // NSUserDefaults
    let prefs = NSUserDefaults.standardUserDefaults()
    
    // Loading Animation
    var indicator: UIActivityIndicatorView? = nil
    
    // Favorites Table View Property and Functions
    var favorites = [String]()
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("gotoDetails", sender: self)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.favoritesTableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.textLabel?.text = self.favorites[indexPath.row]
        return cell
    }
    
    // Called when a textField is highlighted and the Return key is pushed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.endEditing(true)
        
        return true
    }
    
    private func loadFavorites() {
        let ref: FIRDatabaseReference? = userRef!.child("Favorites")
        
        ref!.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if !snapshot.exists() {
                self.favoritesTableView.hidden = true
                self.logoutButton.hidden = true
            }
            else {
                self.otherLogout.hidden = true
                
                for newFavorite in snapshot.children {
                    // Add all favorite titles
                    self.favorites.append(newFavorite.value)
                }
            }
            
            self.favoritesTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
            self.favoritesTableView.reloadData()
        })
    }

    func exitSettings() {
        indicator?.removeFromSuperview()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func LogoutButtonClicked(sender: UIButton) {
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
        prefs.setObject(false, forKey: "ISLOGGEDIN")
        
        do {
            try FIRAuth.auth()!.signOut()
        } catch {
            let errorAlert = UIAlertView(title: "Logout Error", message: "Sorry, we were unable to log you out at this time.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
        
        // Back to Login
   //     navigationController?.popToRootViewControllerAnimated(false)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.switchRootToLogin()
    }
    
    @IBAction func CancelButtonAction(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func SaveButtonAction(sender: UIBarButtonItem) {
        let newPassword = passwordField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let newName = displayNameField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let newEmail = emailField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        // Add loading symbol
        indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        self.view.addSubview(indicator!)
        indicator!.frame = self.view.bounds
        indicator!.startAnimating()
        
        // If user changed their display name
        if newName != "" && newName != prefs.stringForKey("USERNAME") {
            prefs.setObject(newName, forKey: "USERNAME")
            
            // Set up change request
            if (!prefs.boolForKey("ISGUESTUSER")) {
                let user = FIRAuth.auth()?.currentUser
                if let user = user {
                    let changeRequest = user.profileChangeRequest()
                    changeRequest.displayName = newName
                    changeRequest.commitChangesWithCompletion { error in
                        if error != nil {
                            self.showUpdateError("display name")
                        }
                    }
                }
                
                userRef!.child("DisplayName").setValue(newName)
            }
        }
        
        // If user changed their email
        if newEmail != "" && newEmail != prefs.stringForKey("USEREMAIL") {
            let user = FIRAuth.auth()?.currentUser
            prefs.setObject(newEmail, forKey: "USEREMAIL")
            
            user?.updateEmail(newEmail) { error in
                if error != nil {
                    self.showUpdateError("email")
                }
            }
        }
        
        // User has entered a new password
        if newPassword != "" {
            changingPassword = true
            let errorAlert = UIAlertView(title: "Changing Password", message: "Do you really want to change your password?", delegate: self, cancelButtonTitle: "Yes")
            errorAlert.addButtonWithTitle("No")
            errorAlert.dismissWithClickedButtonIndex(1, animated: true)
            errorAlert.show()
        }
        
        if !changingPassword {
            exitSettings()
        }
    }
    
    func showUpdateError(errorType: String) {
        let errorAlert = UIAlertView(title: "Profile Update Error", message: "Sorry, we were unable to update your \(errorType) at this time.", delegate: self, cancelButtonTitle: "OK")
        errorAlert.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        // If user clicked "YES"
        if (buttonIndex == 0) {
            let user = FIRAuth.auth()?.currentUser
            let newPassword = passwordField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            user?.updatePassword(newPassword) { error in
                if error != nil {
                    self.showUpdateError("password")
                }
            }
        }
        
        exitSettings()
    }
    
    private func setupGuestView() {
        emailField.hidden = true
        passwordField.hidden = true
        favoritesLabel.hidden = true
        favoritesTableView.hidden = true
        emailLabel.hidden = true
        passwordLabel.hidden = true
        logoutButton.hidden = true
        
        logoutButtonGuest.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayNameField.text = prefs.stringForKey("USERNAME")
        
        if prefs.boolForKey("ISGUESTUSER") {
            setupGuestView()
        }
        else {
            emailField.text = prefs.stringForKey("USEREMAIL")
            userRef = FIRDatabase.database().reference().child("users").child(prefs.stringForKey("USERID")! as String)
            
            loadFavorites()
        }
        
        // Add dismissing keyboard by tapping
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(EditPagesViewController.dismissKeyboard))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)
    }
    
    // For Keyboard dismissal
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gotoDetails",
            let destination = segue.destinationViewController as? DetailsViewController,
            IDIndex = favoritesTableView.indexPathForSelectedRow?.row
        {
            // Load requested product
            let product = Product(prodID: favorites[IDIndex])
            
            destination.currentProduct = product
        }
    }
}
