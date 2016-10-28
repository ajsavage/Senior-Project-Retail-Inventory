//
//  ShowProductViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 10/24/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit

class ShowProductViewController: UIViewController, UIActionSheetDelegate {
    // Product to display details about
    var currentProduct: Product!
    
    // Sizes index for calculating the number in stock
    var sizeIndex = -1
    var cancelColorIndex = 0
    var cancelSizeIndex = 0
    
    // Loading Animation
    var indicator: UIActivityIndicatorView? = nil
    
    var createColorMenu: UIActionSheet {
        let sheet: UIActionSheet = UIActionSheet(title: "Choose Color",
                                                 delegate: self,
                                                 cancelButtonTitle: nil,
                                                 destructiveButtonTitle: nil,
                                                 otherButtonTitles: "All")
        sheet.tag = Constants.Colors.menuTag
        cancelColorIndex = 1 // All and Cancel buttons
        
        for newColor in currentProduct.colors {
            sheet.addButtonWithTitle(newColor as String)
            cancelColorIndex += 1
        }
        
        colorCancelButton(sheet)
        return sheet
    }
    
    // Create and add the Cancel Button
    func colorCancelButton(sheet: UIActionSheet) {
        sheet.addButtonWithTitle("Cancel")
        sheet.dismissWithClickedButtonIndex(cancelColorIndex, animated: true)
    }
    
    var createSizeMenu: UIActionSheet {
        let sheet: UIActionSheet = UIActionSheet(title: "Choose Size",
                                                 delegate: self,
                                                 cancelButtonTitle: nil,
                                                 destructiveButtonTitle: nil,
                                                 otherButtonTitles: "All")
        sheet.tag = Constants.Sizes.menuTag
        cancelSizeIndex = 1
        
        for newSize in Constants.Sizes.Names {
            addSizeButton(newSize, index: cancelSizeIndex - 1, actionSheet: sheet)
        }
        
        // Cancel button
        sheet.addButtonWithTitle("Cancel")
        sheet.dismissWithClickedButtonIndex(cancelSizeIndex, animated: true)
        
        return sheet
    }
    
    var createTypeMenu: UIActionSheet {
        let sheet: UIActionSheet = UIActionSheet(title: "Choose Type",
                                                 delegate: self,
                                                 cancelButtonTitle: nil,
                                                 destructiveButtonTitle: nil)
        sheet.tag = Constants.Types.menuTag
        
        for newType in Constants.Types.Names {
            sheet.addButtonWithTitle(newType)
        }
        
        // Cancel button
        sheet.addButtonWithTitle("Cancel")
        sheet.dismissWithClickedButtonIndex(Constants.Types.Names.count, animated: true)
    
        return sheet
    }
    
    // Adds a new size button to the action sheet if there is atleast one
    // product available in that size
    func addSizeButton(title: String, index: Int, actionSheet: UIActionSheet) {
      /*  if (self.currentProduct.sizes[index].integerValue > 0) {
            let newButton = UIButton()
            newButton.titleLabel?.text = title
            newButton.titleLabel?.tag = index
            actionSheet.addSubview(newButton)
            cancelSizeIndex += 1
        }
        */
        
        actionSheet.addButtonWithTitle(title)
        cancelSizeIndex += 1
    }
    
    func actionSheetButtonClicked(actionSheet: UIActionSheet, buttonIndex: Int, view: UIView) {
        // Size ActionSheet
        if (actionSheet.tag == Constants.Sizes.menuTag) {
            if (buttonIndex != cancelSizeIndex) {
                (view as! UILabel).text = actionSheet.buttonTitleAtIndex(buttonIndex)
                
                sizeIndex = buttonIndex - 1
            }
        }
        // Color ActionSheet
        else if (actionSheet.tag == Constants.Colors.menuTag) {
            if (buttonIndex != cancelColorIndex) {
                (view as! UILabel).text = actionSheet.buttonTitleAtIndex(buttonIndex)
            }
        }
        // Type ActionSheet
        else if (actionSheet.tag == Constants.Types.menuTag) {
            if (buttonIndex != Constants.Types.Names.count) {
                (view as! UIButton).titleLabel!.text = actionSheet.buttonTitleAtIndex(buttonIndex)
            }
        }
    }
    
    // Calculates the number of items available of the product in the selected size
    var calculateStock: String {
        var stock = 0
        
        // Calculates all sizes
        if (sizeIndex == -1) {
            for index in 0 ..< Constants.Sizes.Names.count {
                stock += currentProduct.sizes[index].integerValue
            }
        }
        else {
            stock = currentProduct.sizes[sizeIndex].integerValue
        }
        
        return "In Stock: " + String(stock)
    }
    
    func removeLoadingSymbol(loadingView: UIView) {
        indicator?.removeFromSuperview()
        loadingView.resignFirstResponder()
    }
    
    func showLoadingSymbol(loadingView: UIView) {
        indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        loadingView.addSubview(indicator!)
        indicator!.frame = loadingView.bounds
        indicator!.startAnimating()
    }
}
