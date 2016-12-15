//
//  EditProductColorsViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 12/14/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import FirebaseDatabase

class EditProductColorsViewController: Helper {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var colorScrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var removeCheckbox: CheckboxButton!
    @IBOutlet weak var checkbox: UIButton!
    
    // Database Reference
    let dataRef: FIRDatabaseReference = FIRDatabase.database().reference()
    
    // Product to load inventory for
    var currentProduct: Product? = nil
    
    // Color Swatch View Properties
    let colorSwatchHeight = 37
    let colorSwatchWidth = 45
    var nextXValue = 0
    var nextYValue = 0
    
    // Color and Size temporary storage
    let colorDictionary: NSMutableDictionary = [:]
    var totalSizes: Array<Int> = [0, 0, 0, 0, 0]
    var allColors = Array<ColorInventory>()
    
    // Index for colors
    var colorIndex = 0
    
    // If selecting a color swatch should remove it
    // rather than open a view so the user can edit it
    var shouldRemove: Bool = false
    
    @IBAction func removeCheckboxClicked(sender: CheckboxButton) {
        if (sender.isChecked != nil) {
            // Check if box is already selected
            if (sender.isChecked!) {
                // Becomes unchecked box
                sender.setImage(UIImage(named: "Unchecked"), forState: .Normal)
                shouldRemove = false
            }
            else {
                // Becomes checked box
                sender.setImage(UIImage(named: "Checked"), forState: .Normal)
                shouldRemove = true
            }
        }
    }
    
    @IBAction func addButtonClicked(sender: AnyObject) {
        let editColor = storyboard?.instantiateViewControllerWithIdentifier("addNewColor") as! AddNewColorViewController
        editColor.callback = addNewColor
        editColor.dataRef = dataRef
        
        navigationController?.pushViewController(editColor, animated: true)
    }
    
    @IBAction func searchFieldClicked(sender: AnyObject) {
        if (self.isBeingDismissed()) {
            showSearchAlert("You are being dismissed!")
        }
        else if (sender.text == nil || sender.text == "") {
            showSearchAlert("Please enter a product ID to display.")
        }
        else if (sender.text!.characters.count != Constants.ProductID.Length) {
            showSearchAlert("Not a valid Product ID - Product IDs must be exactly \(Constants.ProductID.Length) characters long.")
        }
        else {
            showLoadingSymbol(searchField)
            
            // Capitalize all letters in the product ID
            let capitalID = sender.text!.uppercaseString
            
            let dataRef = FIRDatabase.database().reference().child("inventory")
            let productRef = dataRef.child(capitalID)
            
            productRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                if !snapshot.exists() {
                    self.showSearchAlert("Product ID# " + capitalID + " does not currently exist in the database.")
                    self.removeLoadingSymbol(self.searchField)
                }
                else {
                    self.currentProduct = Product(data: snapshot, ref: dataRef)
                    self.currentProduct!.loadInformation(true, callback: self.updateWithLoadedData)
                }
            })
        }
    }
    
    @IBAction func saveButtonClicked(sender: AnyObject) {
        let id = (currentProduct?.productID)! as String
        
        dataRef.child("inventory/\(id)/Colors").setValue(colorDictionary)
        dataRef.child("inventory/\(id)/Sizes").setValue(convertSizesToDictionary)
        
        // Upload all barcodes for colors to the database
        for color in allColors {
            color.addBarcodesToDatabase(dataRef, productID: id)
        }
    
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // Called when the product's details are finished loading from the database
    func updateWithLoadedData() {
        // Sets the view to display the current product's details
        titleLabel.text = currentProduct!.title as String
        
        // Update colors view
        for color in currentProduct!.colors {
            color.tag = -1
            addNewColor(color)
        }
        
        // Unhide
        mainView.hidden = false
        titleLabel.hidden = false
        buttonView.hidden = false
        
        view.backgroundColor = UIColor.whiteColor()
        removeLoadingSymbol(searchField)
        searchField.text = nil
    }
    
    // Coverts the total sizes array to a NSDictionary
    private var convertSizesToDictionary: NSDictionary {
        let dict: NSDictionary = ["XSmall" : totalSizes[0],
                                  "Small" : totalSizes[1],
                                  "Medium" : totalSizes[2],
                                  "Large" : totalSizes[3],
                                  "XLarge" : totalSizes[4]]
        
        return dict
    }
    
    // Removes a given color from the product
    func removeColor(tag: Int) {
        let color: ColorInventory = allColors[tag]
        
        // Remove old inventory counts
        totalSizes[0] -= color.sizes[0]
        totalSizes[1] -= color.sizes[1]
        totalSizes[2] -= color.sizes[2]
        totalSizes[3] -= color.sizes[3]
        totalSizes[4] -= color.sizes[4]
        
        // Remove from dictionary
        let subDictionary: NSMutableDictionary =
            NSMutableDictionary(dictionary: colorDictionary[color.colorType] as! NSDictionary)
        subDictionary.removeObjectForKey(color.colorName!)
        
        if (subDictionary.count == 0) {
            colorDictionary.removeObjectForKey(color.colorType)
        }
        else {
            colorDictionary[color.colorType] = subDictionary
        }
        
        // Remove from allColors
        if (allColors.count == 1) {
            allColors = Array<ColorInventory>()
        }
        else {
            allColors[tag] = allColors[allColors.count - 1]
            allColors.removeLast()
        }
    }
    
    // Callback for adding a new color swatch
    func addNewColor(color: ColorInventory) {
        // Add new color size inventory to total size array
        totalSizes[0] += color.sizes[0]
        totalSizes[1] += color.sizes[1]
        totalSizes[2] += color.sizes[2]
        totalSizes[3] += color.sizes[3]
        totalSizes[4] += color.sizes[4]
        
        var subDictionary: NSMutableDictionary = [:]
        
        // Add to colors dictionary
        if (colorDictionary[color.colorType] != nil) {
            subDictionary = NSMutableDictionary(dictionary: colorDictionary[color.colorType] as! NSDictionary)
        }
        
        subDictionary[color.colorName!] = color.sizeDictionary
        
        // color.colorName: color.sizeDictionary]
        colorDictionary.setObject(subDictionary, forKey: color.colorType)
        
        if (color.tag == -1) {
            color.tag = colorIndex
            allColors.append(color)
            
            if (color.color == nil) {
                color.loadUIColor(FIRDatabase.database().reference(), callback: setUpSwatchView)
            }
            else {
                setUpSwatchView(color.color)
            }
        }
        else {
            // Remove old inventory counts
            totalSizes[0] -= allColors[color.tag].sizes[0]
            totalSizes[1] -= allColors[color.tag].sizes[1]
            totalSizes[2] -= allColors[color.tag].sizes[2]
            totalSizes[3] -= allColors[color.tag].sizes[3]
            totalSizes[4] -= allColors[color.tag].sizes[4]
            
            allColors[color.tag] = color
        }
    }
    
    // Sets up color swatch
    private func setUpSwatchView(color: UIColor?) {
        if color == nil {
            return
        }
        
        // Create new color swatch
        let colorSwatch = UIButton()
        var addHeight = 0
        colorSwatch.backgroundColor = color
        colorSwatch.frame = CGRect(x: nextXValue, y: nextYValue, width: colorSwatchWidth - 2, height: colorSwatchHeight - 2)
        colorSwatch.addTarget(self, action: #selector(colorButtonActions), forControlEvents: .TouchUpInside)
        colorSwatch.tag = colorIndex
        colorIndex += 1
        
        // Add rounded border to title textview
        colorSwatch.layer.borderColor = UIColor.lightGrayColor().CGColor
        colorSwatch.layer.cornerRadius = 5
        colorSwatch.layer.borderWidth = 1
        
        // Calculate addHeight, which is the height of a color swatch
        // plus extras pace unless on the first row
        if nextYValue == 0 {
            addHeight = colorSwatchHeight
        }
        else {
            addHeight = colorSwatchHeight + 10
        }
        
        // Extend color view height
        if nextXValue == 0 {
            let currentSize = colorScrollView.contentSize
            colorScrollView.contentSize = CGSize(width: currentSize.width, height: currentSize.height + CGFloat(addHeight))
        }
        
        // Update next x and y values
        nextXValue = nextXValue + colorSwatchWidth + 20
        
        // Move down to the next row if reached the end of the colorView
        if Float(nextXValue + colorSwatchWidth) > Float(colorScrollView.bounds.width) {
            nextXValue = 0
            nextYValue = nextYValue + addHeight
        }
        
        colorScrollView.addSubview(colorSwatch)
    }
    
    // Action for all of the colorButtons
    func colorButtonActions(sender: UIButton!) {
        if (!shouldRemove) {
            let editColor = storyboard?.instantiateViewControllerWithIdentifier("addNewColor") as! AddNewColorViewController
            editColor.callback = addNewColor
            editColor.dataRef = dataRef
            editColor.colorInventory = allColors[sender.tag]
            
            navigationController?.pushViewController(editColor, animated: true)
        }
        // Remove color from the product
        else {
            removeColor(sender.tag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissTextFieldsByTapping()
        
        // Set up remove view data
        removeCheckbox.isChecked = false
        shouldRemove = false
        
        // Setup starting view
        if (currentProduct == nil) {
            mainView.hidden = true
            titleLabel.hidden = true
            buttonView.hidden = true
            view.backgroundColor = UIColor.blackColor()
        }
    }
}
