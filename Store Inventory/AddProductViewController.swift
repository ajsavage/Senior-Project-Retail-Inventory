//
//  AddProductViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 11/27/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

class AddProductViewController: Helper {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleField: UITextView!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var productIDField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var typeField: UISegmentedControl!
    @IBOutlet weak var loadingSymbolLabel: UILabel!
    @IBOutlet weak var colorView: UIView!

    // Created Product
    var product: Product? = nil
    
    // Colors dictionary
    let colorDictionary: NSMutableDictionary = [:]
    let sizeDictionary: NSMutableDictionary = [:]
    
    // Color Swatch View Properties
    let colorSwatchHeight = 40
    let colorSwatchWidth = 30
    var nextXValue = 0
    var nextYValue = 0
    
    // Button actions
    @IBAction func editImageButtonPushed(sender: AnyObject) {
        
    }
    
    @IBAction func cancelButtonPushed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func saveButtonPushed(sender: AnyObject) {
        showLoadingSymbol(loadingSymbolLabel)
        var temp: String
        let dictionary = Dictionary<String, AnyObject>()
        
        // Product ID
        if (productIDField.text == nil) {
            showSaveErrorAlert("product ID")
            return
        }
        temp = productIDField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if (temp == "") {
            showSaveErrorAlert("product ID")
            return
        }
        if (temp.characters.count != Constants.ProductID.Length) {
            showProductIDErrorAlert()
            return
        }
        
        FIRDatabase.database().reference().child("inventory/\(temp)").observeEventType(.Value,
                     withBlock: { snapshot in
                if snapshot.exists() {
                    self.showErrorAlert("New Product Error", message: "This product ID, \(temp), already exists.")
                    return
                }
                else {
                    self.continueSavingProduct(dictionary)
                }
        })
    }
    
    // Callback for adding a new color swatch
    func addNewColor(color: UIColor, colorName: String, colorType: String, sizes: NSDictionary) {
        // Add new color and sizes to dictionaries
        sizeDictionary["XSmall"] = sizeDictionary["XSmall"] as! Int + (sizes["XSmall"] as! Int)
        sizeDictionary["Small"] = sizeDictionary["Small"] as! Int + (sizes["Small"] as! Int)
        sizeDictionary["Medium"] = sizeDictionary["Medium"] as! Int + (sizes["Medium"] as! Int)
        sizeDictionary["Large"] = sizeDictionary["Large"] as! Int + (sizes["Large"] as! Int)
        sizeDictionary["XLarge"] = sizeDictionary["XLarge"] as! Int + (sizes["XLarge"] as! Int)
            
        // Add to colors dictionary
        colorDictionary[colorType]?.setObject(sizes, forKey: colorName)
        
        setUpSwatchView(color)
    }
    
    // Helper for addNewColor method
    // Sets up color swatch
    private func setUpSwatchView(color: UIColor) {
        // Create new color swatch
        let colorSwatch = UIView()
        var addHeight = 0
        colorSwatch.backgroundColor = color
        colorSwatch.frame = CGRect(x: nextXValue, y: nextYValue, width: colorSwatchWidth, height: colorSwatchHeight)
        
        // Calculate addHeight, which is the height of a color swatch
        // plus extras pace unless on the first row
        if nextYValue == 0 {
            addHeight = colorSwatchHeight
        }
        else {
            addHeight = colorSwatchHeight + 10
        }
        
        // Update next x and y values
        nextXValue = nextXValue + colorSwatchWidth + 10
        
        // Move down to the next row if reached the end of the colorView
        if Float(nextXValue + colorSwatchWidth) > Float(colorView.bounds.width) {
            nextXValue = 0
            nextYValue = nextYValue + addHeight
        }
        
        // Extend color view height
        if nextXValue == 0 {
            let newFrame = CGRect(x: colorView.bounds.minX, y: colorView.bounds.minY, width: colorView.bounds.width, height: CGFloat(nextYValue + colorSwatchHeight))
            
            colorView.frame = newFrame
        }
        
        colorView.addSubview(colorSwatch)
    }
    
    // Helper method for the saveButtonPushed method
    // Checks each of the fields to ensure they all have data
    private func continueSavingProduct(dict: Dictionary<String, AnyObject>) {
        var temp: String
        var dictionary = dict
        
        // Title
        if (titleField.text == nil) {
            showSaveErrorAlert("product title")
            return
        }
        
        temp = titleField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if (temp == "") {
            showSaveErrorAlert("product title")
            return
        }
        dictionary["Title"] = temp
        
        // Type
        if (typeField.selectedSegmentIndex < 0 ||
            typeField.selectedSegmentIndex >= Constants.Types.Names.count) {
            showSaveErrorAlert("product type")
            return
        }
        temp = Constants.Types.Names[typeField.selectedSegmentIndex]
        dictionary["Type"] = temp
        
        // Price
        if (priceField.text == nil) {
            showSaveErrorAlert("product price")
            return
        }
        temp = priceField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if (temp == "") {
            showSaveErrorAlert("product price")
            return
        }
        
        let tempPrice: Float? = Float(temp)
        if (tempPrice == nil) {
            showSaveErrorAlert("product price")
            return
        }
        
        dictionary["Price"] = tempPrice
        
        // Description
        if (descriptionField.text == nil) {
            showSaveErrorAlert("product description")
            return
        }
        temp = descriptionField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if (temp == "") {
            showSaveErrorAlert("product description")
            return
        }
        dictionary["Description"] = temp
        
        // Image
        if (imageView.image != nil) {
            dictionary["Image"] = dictionary["ID"]
            UPLOAD
        }
        else {
            dictionary["Image"] = nil
        }
        
        if (colorView.subviews.count == 0) {
            showErrorAlert("New Product Error", message: "Please add at least one color.")
            return
        }
        else {
            dictionary["Colors"] = colorDictionary
            dictionary["Sizes"] = sizeDictionary
        }
        
        product = Product(dict: dictionary)
        
        indicator?.removeFromSuperview()
        navigationController?.popViewControllerAnimated(true)
        self.presentViewController(EditPagesViewController(), animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the size dictionary with all zeroes
        sizeDictionary["XSmall"] = 0
        sizeDictionary["Small"] = 0
        sizeDictionary["Medium"] = 0
        sizeDictionary["Large"] = 0
        sizeDictionary["XLarge"] = 0
    }
    
    func showSaveErrorAlert(message: String) {
        let errorAlert = UIAlertView(title: "New Product Error", message: "Please fill out the \(message) field.", delegate: self, cancelButtonTitle: "OK")
        indicator?.removeFromSuperview()
        errorAlert.tag = -1
        errorAlert.show()
    }
    
    func showProductIDErrorAlert() {
        let errorAlert = UIAlertView(title: "New Product Error", message: "Product IDs must be exactly \(Constants.ProductID.Length) characters long.", delegate: self, cancelButtonTitle: "OK")
        indicator?.removeFromSuperview()
        errorAlert.tag = -1
        errorAlert.show()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addNewColorSegue",
            let destination = segue.destinationViewController as? AddNewColorViewController
        {
            destination.addProductCallback = addNewColor
        }
        else {
            let destination = segue.destinationViewController as? EditPagesViewController
            
            if destination != nil {
                destination!.currentProduct = self.product
            }
        }
    }
}
