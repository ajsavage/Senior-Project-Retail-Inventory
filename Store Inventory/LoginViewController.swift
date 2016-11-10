//
//  LoginViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 11/2/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, GIDSignInUIDelegate, UITextFieldDelegate, UIAlertViewDelegate {
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
        showForgotPasswordMessage("Enter your sign in email address and a password reset email will be sent to you shortly.")
    }
    
    func showForgotPasswordMessage(message: String) {
        let errorAlert = UIAlertView(title: "Forgotten Password", message: message, delegate: self, cancelButtonTitle: "OK")
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
                showForgotPasswordMessage("Enter your sign in email address and a password reset email will be sent to you shortly.\n\nPlease enter an email address")
            }
            else {
                FIRAuth.auth()?.sendPasswordResetWithEmail(email) { error in
                    if error != nil {
                        self.showForgotPasswordMessage("Could not send reset email to that address, make sure you are entering your sign in email.")
                    }
                    else {
                        self.showForgotPasswordMessage("Email sent!")
                    }
                }
            }
        }
    }
    
    private func loggingInUser(user: FIRUser) {
        // User account type
        var type: String? = "Customer"
        var displayName: String? = user.displayName
        
        // Guest user
        if (user.anonymous) {
            // Set NSUserDefaults
            prefs.setObject(1, forKey: "ISLOGGEDIN")
            prefs.setObject(type, forKey: "USERTYPE")
            prefs.setObject("Guest", forKey: "USERNAME")
            prefs.setObject(true, forKey: "ISGUESTUSER")
        
            indicator?.removeFromSuperview()
            goToHome(type!)
        }
        // Other user
        else {
            // Get user type from database
            let userID = user.uid
            FIRDatabase.database().reference().child("users/\(userID)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                type = snapshot.childSnapshotForPath("UserType").value as? String
                
                if displayName == nil {
                    displayName = snapshot.childSnapshotForPath("DisplayName").value as? String
                }
                
                // Set up database user data
                if type == nil {
                    type = "Customer"
                    FIRDatabase.database().reference().child("users/\(userID)/UserType").setValue(type)
                }
                
                // Set NSUserDefaults
                self.prefs.setObject(true, forKey: "ISLOGGEDIN")
                self.prefs.setObject(type, forKey: "USERTYPE")
                self.prefs.setObject(displayName, forKey: "USERNAME")
                self.prefs.setObject(user.email, forKey: "USEREMAIL")
                self.prefs.setObject(String(userID), forKey: "USERID")
                self.prefs.setObject(false, forKey: "ISGUESTUSER")
                
                self.indicator?.removeFromSuperview()
                self.goToHome(type!)
            })
        }
    }
    
    private func goToHome(userType: String) {
        // Go to home screen
        switch userType {
        case "Employee":
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.switchRootToEmployeeHome()
        case "Manager":
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.switchRootToManagerHome()
        default: // Default is a customer
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.switchRootToCustomerHome()
        }
    }

    private func loginError(message: String) {
        let errorAlert = UIAlertView(title: "Sign in Error", message: message, delegate: self, cancelButtonTitle: "OK")
        errorAlert.show()
        indicator?.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        prefs.setBool(false, forKey: "ISLOGGEDIN")
        try! FIRAuth.auth()!.signOut()
        
        // Set up NSUserDefaults
        let loggedIn = prefs.boolForKey("ISLOGGEDIN")
        
        // If user is already logged in
        if (loggedIn) {
            goToHome(prefs.stringForKey("USERTYPE")!)
        }
        else {
            GIDSignIn.sharedInstance().uiDelegate = self
            
            FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
                if let user = user {
                    self.loggingInUser(user)
                }
            }
            
            // Add dismissing keyboard by tapping
            let dismissTap = UITapGestureRecognizer(target: self, action: #selector(EditPagesViewController.dismissKeyboard))
            dismissTap.cancelsTouchesInView = false
            view.addGestureRecognizer(dismissTap)
        }
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
    
    // Temporary easy login buttons for testing
    @IBAction func tempLoginAsManager(sender: UIButton) {
        FIRAuth.auth()?.signInWithEmail("andrea@davidsavage.org", password: "aaaaaa", completion: nil)
    }
    @IBAction func tempLoginAsEmployee(sender: UIButton) {
        FIRAuth.auth()?.signInWithEmail("q@w.org", password: "qwerty", completion: nil)
    }
    @IBAction func tempLoginAsCustomer(sender: UIButton) {
        FIRAuth.auth()?.signInWithEmail("a@a.org", password: "customer", completion: nil)
    }
}
