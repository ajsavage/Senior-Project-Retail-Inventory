//
//  NewAccountViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 11/2/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

class NewAccountViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var displayNameLabel: UITextField!
    @IBOutlet weak var confirmPasswordLabel: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    
    // User account traits
    var email = ""
    var password = ""
    var name = ""
    
    // Loading Animation
    var indicator: UIActivityIndicatorView? = nil
    
    // Opens creating a new account view
    @IBAction func createAccountClicked(sender: UIButton) {
        indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        createAccountButton.addSubview(indicator!)
        indicator!.frame = createAccountButton.bounds
        indicator!.startAnimating()
        
        // Checks if the user login was valid
        if (validLogin()) {
            FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user, error) in
                if error != nil {
                    self.loginError("Could not create this account.")
                }
                else if let user = user {
                    
                    // Add display name
                    FIRDatabase.database().reference().child("users/\(user.uid)/DisplayName").setValue(self.name)
                    FIRDatabase.database().reference().child("users/\(user.uid)/UserType").setValue("Customer")
                    self.indicator?.removeFromSuperview()
                }
            }
        }
    }
    
    // Handles alert view interactions
    private func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        // Exit on OK in successful alert view
        if (alertView.tag == 2 && buttonIndex == 0) {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // Shows login error alert view
    private func loginError(message: String) {
        indicator?.removeFromSuperview()
        
        let errorAlert = UIAlertView(title: "Sign Up Error", message: message, delegate: self, cancelButtonTitle: "OK")
        errorAlert.show()
    }
    
    // Checks if the entered user data is valid
    private func validLogin() -> Bool {
        email = usernameLabel.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        password = passwordLabel.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        name = displayNameLabel.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let confirm = confirmPasswordLabel.text!
        var shouldLogin = false
        
        if (name == "") {
            loginError("Please enter a display name")
        }
        else if (email == "") {
            loginError("Please enter an email")
        }
        else if (password == "") {
            loginError("Please enter a password")
        }
        // Firebase requirement
        else if (password.characters.count < 6) {
            loginError("Password must be longer than 6 characters.")
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
    
    // Overrides the viewDidLoad function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add dismissing keyboard by tapping
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(EditPagesViewController.dismissKeyboard))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)
    }
    
    // For Keyboard dismissal
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Called when a textField is highlighted and the Return key is pushed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.endEditing(true)
        
        return true
    }
}