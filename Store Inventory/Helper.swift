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
        if (textView.tag != Constants.Description.fieldTag) {
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
        let errorAlert = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "OK")
        errorAlert.tag = -1
        errorAlert.show()
    }
    
    // Shows an alertview with only an OK button and a title of 'Invalid Search'
    func showSearchAlert(message: String) {
        showErrorAlert("Invalid Search", message: message)
    }
}
