//
//  NewAccountViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 11/2/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

class NewAccountViewController: UIViewController {
    @IBOutlet weak var usernameLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var confirmPasswordLabel: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    
    var email = ""
    var password = ""
    
    // Loading Animation
    var indicator: UIActivityIndicatorView? = nil
    
    @IBAction func createAccountClicked(sender: UIButton) {
        indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        createAccountButton.addSubview(indicator!)
        indicator!.frame = createAccountButton.bounds
        indicator!.startAnimating()
        
        if (validLogin()) {
            FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user, error) in
                if error != nil {
                    self.loginError("Could not create this account.")
                }
                else {
                    FIRDatabase.database().reference().child("users/\(user?.uid)/UserType").setValue("Customer")
                    self.indicator?.removeFromSuperview()
                    
                    let errorAlert = UIAlertView(title: "New Account", message: "Successfully created new account!", delegate: self, cancelButtonTitle: "OK")
                    errorAlert.tag = 2
                    errorAlert.show()
                }
            }
        }
    }
    
    private func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        // Exit on OK in successful alert view
        if (alertView.tag == 2 && buttonIndex == 0) {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    private func loginError(message: String) {
        indicator?.removeFromSuperview()
        
        let errorAlert = UIAlertView(title: "Sign Up Error", message: message, delegate: self, cancelButtonTitle: "OK")
        errorAlert.show()
    }
    
    private func validLogin() -> Bool {
        email = usernameLabel.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        password = passwordLabel.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let confirm = confirmPasswordLabel.text!
        var shouldLogin = false
        
        if (email == "") {
            loginError("Please enter an email")
        }
        else if (password == "") {
            loginError("Please enter a password")
        }
        else if (confirm == "") {
            loginError("Please re-enter your password to confirm")
        }
        else if (confirm != password) {
            loginError("Passwords don't match! Excess whitespace at the front and back of passwords is illegal.")
        }
        else {
            shouldLogin = true
        }
        
        return shouldLogin
    }
}