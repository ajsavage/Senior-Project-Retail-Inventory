//
//  LoginViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 11/2/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    @IBOutlet weak var usernameLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var googleButton: GIDSignInButton!
   
    // NSUserDefaults
    let prefs = NSUserDefaults.standardUserDefaults()
    
    // Global email and password
    var email = ""
    var password = ""
    
    // Loading Animation
    var indicator: UIActivityIndicatorView? = nil
   
    private func validLogin() -> Bool {
        email = usernameLabel.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        password = passwordLabel.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        var shouldLogin = false
        
        if (email == "") {
            loginError("Please enter an email")
        }
        else if (password == "") {
            loginError("Please enter a password")
        }
        else {
            shouldLogin = true
        }
        
        return shouldLogin
    }
    
    func showLoadingSymbol(loadingView: UIView) {
        indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        loadingView.addSubview(indicator!)
        indicator!.frame = loadingView.bounds
        indicator!.startAnimating()
    }
    
    @IBAction func loginWithUsernameAndPassword(sender: UIButton) {
        showLoadingSymbol(view)
        
        if validLogin() {
            FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
                if (error != nil) {
                    self.loginError("Not a valid email or password")
                }
            }
        }
    }
  
    @IBAction func loginAsGuest(sender: UIButton) {
        showLoadingSymbol(view)
        
        FIRAuth.auth()?.signInAnonymouslyWithCompletion() { (user, error) in
            if (error != nil) {
                self.loginError("Cannot login as guest right now")
            }
        }
    }

    @IBAction func handleForgottenPassword(sender: UIButton) {
        let errorAlert = UIAlertView(title: "Forgotten Password", message: "Enter your sign in email address and a password reset email will be sent to you shortly.", delegate: self, cancelButtonTitle: nil)
        errorAlert.addButtonWithTitle("OK")
        errorAlert.addButtonWithTitle("Cancel")
        errorAlert.dismissWithClickedButtonIndex(1, animated: true)
        
        errorAlert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        errorAlert.tag = 2
        errorAlert.textFieldAtIndex(0)?.placeholder = "Enter Email"
        
        errorAlert.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        // Forgot password alert view
        if (alertView.tag == 2 && buttonIndex == 0) {
            let email = alertView.textFieldAtIndex(0)!.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            // If no email entered
            if (email == "") {
                alertView.message = "Enter your sign in email address and a password reset email will be sent to you shortly.\n\nPlease enter an email address"
            }
            else {
                FIRAuth.auth()?.sendPasswordResetWithEmail(email) { error in
                    if error != nil {
                        alertView.message = "Could not send reset email to that address, make sure you are entering your sign in email."
                    }
                    else {
                        alertView.message = "Email sent!"
                    }
                    
                    alertView.removeFromSuperview()
                }
            }
        }
    }
    
    private func loggedInUser(user: FIRUser) {
        // User account type
        var type: String? = "Customer"
        
        // Guest user
        if (user.anonymous) {
            // Set NSUserDefaults
            prefs.setObject(1, forKey: "ISLOGGEDIN")
            prefs.setObject(type, forKey: "USERTYPE")
            prefs.setObject("Guest", forKey: "USERNAME")
            prefs.setObject(true, forKey: "ISGUESTUSER")
        }
        // Other user
        else {
            // Get user type from database
            let userID = user.uid
            type = FIRDatabase.database().reference().child("users/\(userID)").valueForKey("UserType") as? String
            
            // Set up database user data
            if type == nil {
                type = "Customer"
                FIRDatabase.database().reference().child("users/\(userID)/UserType").setValue(type)
            }
            
            // Set NSUserDefaults
            prefs.setObject(1, forKey: "ISLOGGEDIN")
            prefs.setObject(type, forKey: "USERTYPE")
            prefs.setObject(user.displayName, forKey: "USERNAME")
            prefs.setObject(user.email, forKey: "USEREMAIL")
            prefs.setObject(String(userID), forKey: "USERID")
            prefs.setObject(false, forKey: "ISGUESTUSER")
        }
        
        indicator?.removeFromSuperview()
        goToHome(type!)
    }
    
    private func goToHome(userType: String) {
        // Dismiss the login view
        navigationController?.popViewControllerAnimated(true)
        
        // Go to home screen
        switch userType {
        case "Employee":
            self.performSegueWithIdentifier("goToEmployeeHome", sender: self)
        case "Manager":
            self.performSegueWithIdentifier("goToManagerHome", sender: self)
        default: // Default is a customer
            self.presentViewController(ProductTableViewController(), animated: true, completion: nil)
        }
    }

    private func loginError(message: String) {
        let errorAlert = UIAlertView(title: "Sign in Error", message: message, delegate: self, cancelButtonTitle: "OK")
        errorAlert.show()
        indicator?.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up NSUserDefaults
        let loggedIn: Int = prefs.integerForKey("ISLOGGEDIN")
        
        // If user is already logged in
        if (loggedIn == 1) {
            goToHome(prefs.stringForKey("USERTYPE")!)
        }
        else {
            GIDSignIn.sharedInstance().uiDelegate = self
            
            FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
                if let user = user {
                    self.loggedInUser(user)
                }
                else {
                    self.loginError("No user signed in??")
                }
            }
        }
    }
    
    // Temporary easy login buttons for testing
    @IBAction func tempLoginAsManager(sender: UIButton) {
   //     FIRAuth.auth()?.signInWithEmail(email, password: password)
    }
    @IBAction func tempLoginAsEmployee(sender: UIButton) {
    }
    @IBAction func tempLoginAsCustomer(sender: UIButton) {
    }
}
