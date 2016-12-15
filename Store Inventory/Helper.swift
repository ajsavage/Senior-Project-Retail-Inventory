//
//  Helper.swift
//  Store Inventory
//
//  Created by Andrea Savage on 11/26/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit

class Helper: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    // Loading Animation
    var indicator: UIActivityIndicatorView? = nil
    
    // Keyboard height size
    var keyboardSize: CGFloat = 200
    
    // Moved difference
    var difference: CGFloat? = nil
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Removes a loadiing symbol in the given view
    func removeLoadingSymbol(loadingView: UIView) {
        indicator?.removeFromSuperview()
        loadingView.resignFirstResponder()
    }
    
    // Adds a loadiing symbol to the given view
    func showLoadingSymbol(loadingView: UIView) {
        indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        loadingView.addSubview(indicator!)
        indicator!.frame = loadingView.bounds
        indicator!.startAnimating()
    }
    
    // Closes a textView with the return key
    // Called when a textView is highlighted and the Return key is pushed
    // From UITextViewDelegate
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (textView.tag != Constants.Description.FieldTag) {
            // Return key was pressed
            if text == "\n" {
                textView.resignFirstResponder()
                textView.endEditing(true)
                
                return false
            }
        }
        return true
    }
    
    // Closes a textField with the return key
    // Called when a textField is highlighted and the Return key is pushed
    // From UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.endEditing(true)
        
        return true
    }
    
    // Shows an alertView with only an OK button
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okButton)
        self.presentViewController(alert, animated: true, completion: nil)
        indicator?.removeFromSuperview()
    }
    
    // Shows an alertview with only an OK button and a title of 'Invalid Search'
    func showSearchAlert(message: String) {
        showErrorAlert("Invalid Search", message: message)
    }
    
    // MUST BE CALLED FOR TEXTVIEW SHIFTING TO WORK
    // Subscribes view controller to the keyboardWillShow notification
    func subscribeToKeyboard() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Helper.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    // called when the keyboard is going to be shown
    func keyboardWillShow(notification: NSNotification) {
        let temp = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        
        if temp != nil {
            keyboardSize = temp!.height
        }
    }
    
    // Called when a textField is selected for editing
    func textFieldDidBeginEditing(textField: UITextField) {
        if (difference == nil) {
            difference = textField.frame.maxY - (view.frame.maxY - CGFloat(keyboardSize))
            
            // If field is hidden by the keyboard
            if (difference > 0) {
                animateScrollView(textField, distanceLength: difference!, up: true)
            }
            else {
                difference = nil
            }
        }
    }
    
    // Called when a textField is being edited and the Return key is pushed
    func textFieldDidEndEditing(textField: UITextField) {
        if (difference != nil) {
            animateScrollView(textField, distanceLength: difference!, up: false)
            difference = nil
        }
    }
    
    // Called when a textView is selected for editing
    func textViewDidBeginEditing(textView: UITextView) {
        if (difference == nil) {
            difference = textView.frame.maxY - (view.frame.maxY - CGFloat(keyboardSize))
            
            // If field is hidden by the keyboard
            if (difference > 0) {
                animateScrollView(textView, distanceLength: difference!, up: true)
            }
            else {
                difference = nil
            }
        }
    }
    
    // Called when a textView is being edited and the Return key is pushed
    func textViewDidEndEditing(textView: UITextView) {
        if (difference != nil) {
            animateScrollView(textView, distanceLength: difference!, up: false)
            difference = nil
        }
    }
    
    // Helper to move description text field up when clicked and
    // covered by the keyboard
    func animateScrollView(view: UIView, distanceLength: CGFloat, up: Bool) {
        let duration = 0.3
        let distance = distanceLength * (up ? -1 : 1)
        
        UIView.beginAnimations("animateScrollView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(duration)
        self.view.frame = CGRectOffset(self.view.frame, 0, distance)
        UIView.commitAnimations()
    }
    
    // For Keyboard dismissal
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Add dismissing keyboard by tapping
    func dismissTextFieldsByTapping() {
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(AddNewColorViewController.dismissKeyboard))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)
    }
}
