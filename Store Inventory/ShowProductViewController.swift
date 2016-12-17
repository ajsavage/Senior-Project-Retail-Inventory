//
//  ShowProductViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 10/24/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit

class ShowProductViewController: Helper, UIActionSheetDelegate, UIAlertViewDelegate {
    // Product to display details about
    var currentProduct: Product! = nil
    
    // Sizes index for calculating the number in stock
    var sizeIndex = -1
    var colorIndex = -1
    var cancelColorIndex = 0
    var cancelSizeIndex = 0
    var typeName = ""
    
    // Creates a color action sheet to display
    func createCustomerColorMenu() -> UIActionSheet {
        let sheet: UIActionSheet = UIActionSheet(title: "Choose Color",
                                                 delegate: self,
                                                 cancelButtonTitle: nil,
                                                 destructiveButtonTitle: nil,
                                                 otherButtonTitles: "All")
        sheet.tag = Constants.Colors.MenuTag
        cancelColorIndex = 1 // All and Cancel buttons
        
        for newColor in currentProduct.colors {
            sheet.addButtonWithTitle(newColor.colorName)
            cancelColorIndex += 1
        }
        
        colorCancelButton(sheet)
        return sheet
    }
    
    // Create and add the Cancel Button
    func colorCancelButton(sheet: UIActionSheet) {
        sheet.addButtonWithTitle("Cancel")
        sheet.cancelButtonIndex = cancelColorIndex
    }
    
    // Creates a size action sheet to display
    var createSizeMenu: UIActionSheet {
        let sheet: UIActionSheet = UIActionSheet(title: "Choose Size",
                                                 delegate: self,
                                                 cancelButtonTitle: nil,
                                                 destructiveButtonTitle: nil,
                                                 otherButtonTitles: "All")
        sheet.tag = Constants.Sizes.MenuTag
        cancelSizeIndex = 1
        
        for newSize in Constants.Sizes.Names {
            addSizeButton(newSize, index: cancelSizeIndex - 1, actionSheet: sheet)
        }
        
        // Cancel button
        sheet.addButtonWithTitle("Cancel")
        sheet.cancelButtonIndex = cancelSizeIndex
        
        return sheet
    }
    
    // Creates a type action sheet to display
    var createTypeMenu: UIActionSheet {
        let sheet: UIActionSheet = UIActionSheet(title: "Choose Type",
                                                 delegate: self,
                                                 cancelButtonTitle: nil,
                                                 destructiveButtonTitle: nil)
        sheet.tag = Constants.Types.MenuTag
        
        for newType in Constants.Types.Names {
            sheet.addButtonWithTitle(newType)
        }
        
        // Cancel button
        sheet.addButtonWithTitle("Cancel")
        sheet.cancelButtonIndex = Constants.Types.Names.count
        
        return sheet
    }
    
    // Adds a new size button to the action sheet if there is atleast one
    // product available in that size
    func addSizeButton(title: String, index: Int, actionSheet: UIActionSheet) {
        actionSheet.addButtonWithTitle(title)
        cancelSizeIndex += 1
    }
    
    // Handles the action sheet interactions
    func actionSheetButtonClicked(actionSheet: UIActionSheet, buttonIndex: Int, view: UILabel) {
        // Size ActionSheet
        if (actionSheet.tag == Constants.Sizes.MenuTag) {
            if (buttonIndex != cancelSizeIndex) {
                sizeIndex = buttonIndex - 1
                view.text = actionSheet.buttonTitleAtIndex(buttonIndex)
            }
        }
        // Color ActionSheet
        else if (actionSheet.tag == Constants.Colors.MenuTag) {
            if (buttonIndex != cancelColorIndex) {
                colorIndex = buttonIndex - 1
                view.text = actionSheet.buttonTitleAtIndex(buttonIndex)
            }
        }
        // Type ActionSheet
        else if (actionSheet.tag == Constants.Types.MenuTag) {
            if (buttonIndex != Constants.Types.Names.count) {
                typeName = actionSheet.buttonTitleAtIndex(buttonIndex)!
                view.text = "Type: \(typeName)"
            }
        }
    }
    
    // Calculates the number of items available of the product in the selected size
    var calculateStock: String {
        var stock = 0
        
        if (colorIndex == -1) {
            // Calculates all sizes
            if (sizeIndex == -1) {
                for index in 0 ..< Constants.Sizes.Names.count {
                    stock += currentProduct.sizes[index].integerValue
                }
            }
            else {
                stock = currentProduct.sizes[sizeIndex].integerValue
            }
        }
        // User selected a color
        else {
            let colorInventory: ColorInventory = currentProduct.colors[colorIndex]
          
            // Calculates all sizes
            if (sizeIndex == -1) {
                for index in 0 ..< Constants.Sizes.Names.count {
                    stock += colorInventory.sizes[index]
                }
            }
            else {
                stock = colorInventory.sizes[sizeIndex]
            }
        }
        
        return "In Stock: " + String(stock)
    }
}
