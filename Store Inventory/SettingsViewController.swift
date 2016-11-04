//
//  SettingsViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 10/12/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    @IBOutlet weak var displayNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var favoritesScrollView: UIScrollView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet var favoritesLabel: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var logoutButtonGuest: UIButton!
    
    var userRef: FIRDatabaseReference? = nil
    var changingPassword = false
    
    // NSUserDefaults
    let prefs = NSUserDefaults.standardUserDefaults()
    
    // Loading Animation
    var indicator: UIActivityIndicatorView? = nil
    
    private func showNoFavorites() {
        let newView = UILabel()
        newView.text = "Currently you have no favorites saved."
        favoritesScrollView.addSubview(newView)
    }
    
    private func showFavorites() {
        let ref: FIRDatabaseReference? = userRef!.child("Favorites")
        
        // User has no favorites saved
        if (ref == nil) {
            showNoFavorites()
        }
        // User does have favorites saved
        else {
            ref!.observeSingleEventOfType(.Value, withBlock: { snapshot in
                if !snapshot.exists() {
                    let errorAlert = UIAlertView(title: "Favorites Error", message: "Sorry, could not load your favorites.", delegate: self, cancelButtonTitle: "OK")
                    errorAlert.show()
                    self.showNoFavorites()
                }
                else {
   //                 for newFavorite in snapshot.children {
     //                   favoritesScrollView.addSubview(newFavorite)
       //             }
                }
            })
        }
    }
    
    func exitSettings() {
        indicator?.removeFromSuperview()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func LogoutButtonClicked(sender: UIButton) {
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
        prefs.setObject(0, forKey: "ISLOGGEDIN")
        
        do {
            try FIRAuth.auth()!.signOut()
        } catch {
            let errorAlert = UIAlertView(title: "Logout Error", message: "Sorry, we were unable to log you out at this time.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
        
        // Clear navigation controller trail
        navigationController?.popToRootViewControllerAnimated(false)
        self.performSegueWithIdentifier("toLogin", sender: self)
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
            // Set up change request
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
        }
        
        // If user changed their email
        if newEmail != "" && newEmail != prefs.stringForKey("USEREMAIL") {
            let user = FIRAuth.auth()?.currentUser
            
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
        favoritesScrollView.hidden = true
        emailLabel.hidden = true
        passwordLabel.hidden = true
        logoutButton.hidden = true
        
        logoutButtonGuest.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if prefs.boolForKey("ISGUESTUSER") {
            setupGuestView()
        }
        else {
            emailField.text = prefs.stringForKey("USEREMAIL")
            userRef = FIRDatabase.database().reference().child("users").child(prefs.stringForKey("USERID")! as String)
            
            showFavorites()
        }
            
        displayNameField.text = prefs.stringForKey("USERNAME")
    }
}
