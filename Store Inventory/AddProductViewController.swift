//
//  AddProductViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 11/27/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

class AddProductViewController: Helper, selectImageCommunicator {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleField: UITextView!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var productIDField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var typeField: UISegmentedControl!
    @IBOutlet weak var loadingSymbolLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Database Reference
    let dataRef: FIRDatabaseReference = FIRDatabase.database().reference()
    
    // Created Product
    var product: Product? = nil
    
    // Color and Size temporary storage
    let colorDictionary: NSMutableDictionary = [:]
    var totalSizes: Array<Int> = [0, 0, 0, 0, 0]
    var allColors = Array<ColorInventory>()
    
    // Index for colors
    var colorIndex = 0
    
    // Color Swatch View Properties
    let colorSwatchHeight = 37
    let colorSwatchWidth = 49
    var nextXValue = 0
    var nextYValue = 0
    
    // Button actions
    @IBAction func editImageButtonPushed(sender: AnyObject) {
        showLoadingSymbol(imageView)
        let imagePicker = storyboard?.instantiateViewControllerWithIdentifier("ImagePicker") as! SelectImageViewController
        imagePicker.delegate = self
        navigationController?.pushViewController(imagePicker, animated: true)
    }
    
    // Callback for the selectImageView
    func selectedImageCallback(image: UIImage?) {
        indicator?.removeFromSuperview()
        
        if (image != nil) {
            imageView.image = image
        }
    }
    
    // Cancels the view
    @IBAction func cancelButtonPushed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // Saves the new product
    @IBAction func saveButtonPushed(sender: AnyObject) {
        showLoadingSymbol(loadingSymbolLabel)
        var temp: String
        var dictionary = Dictionary<String, AnyObject>()
        
        // Product ID
        if (productIDField.text == nil) {
            showSaveErrorAlert("product ID")
            return
        }
        
        // Checks if the id exists
        temp = productIDField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if (temp == "") {
            showSaveErrorAlert("product ID")
            return
        }
        if (temp.characters.count != Constants.ProductID.Length) {
            showProductIDErrorAlert()
            return
        }
        
        dictionary["ID"] = temp.uppercaseString
        
        // Checks if the product already exists
        dataRef.child("inventory/\(temp)").observeEventType(.Value,
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
            setUpSwatchView(color.color!)
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
    
    // Helper for addNewColor method
    // Sets up color swatch
    private func setUpSwatchView(color: UIColor) {
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
            // Extend scrollview
            let currentSize = scrollView.contentSize
            scrollView.contentSize = CGSize(width: currentSize.width, height: currentSize.height + CGFloat(addHeight))
        }
        
        // Update next x and y values
        nextXValue = nextXValue + colorSwatchWidth + 20
        
        // Move down to the next row if reached the end of the colorView
        if Float(nextXValue + colorSwatchWidth) > Float(colorView.bounds.width) {
            nextXValue = 0
            nextYValue = nextYValue + addHeight
        }
        
        colorView.addSubview(colorSwatch)
        colorSwatch.enabled = true
    }
    
    // Action for all of the colorButtons
    func colorButtonActions(sender: UIButton!) {
        let editColor = storyboard?.instantiateViewControllerWithIdentifier("addNewColor") as! AddNewColorViewController
        editColor.callback = addNewColor
        editColor.dataRef = dataRef
        editColor.colorInventory = allColors[sender.tag]
        
        navigationController?.pushViewController(editColor, animated: true)
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
        
        // Type
        if (typeField.selectedSegmentIndex < 0 ||
            typeField.selectedSegmentIndex >= Constants.Types.Names.count) {
            showSaveErrorAlert("product type")
            return
        }
        temp = Constants.Types.Names[typeField.selectedSegmentIndex]
        dictionary["Type"] = temp
        
        // TypePrice - special key for filtering
        dictionary["TypePrice"] = temp + " " + String(tempPrice!)
        
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
        var myImage: UIImage?
        
        if (imageView.image != nil) {
            myImage = imageView.image
        }
        else {
            myImage = nil
        }
        
        // Colors
        if (colorView.subviews.count == 0) {
            showErrorAlert("New Product Error", message: "Please add at least one color.")
            return
        }
        else {
            dictionary["Colors"] = colorDictionary
            dictionary["Sizes"] = convertSizesToDictionary
        }
        
        // Upload all barcodes for colors to the database
        for color in allColors {
            color.addBarcodesToDatabase(dataRef, productID: dictionary["ID"] as! String)
        }
        
        product = Product(dict: dictionary, newImage: myImage)
        
        indicator?.removeFromSuperview()
        navigationController?.popViewControllerAnimated(true)
        
        // Display product in the edit product pages view
        let editView = storyboard?.instantiateViewControllerWithIdentifier("EditProductPages") as! EditPagesViewController
        editView.currentProduct = product
        navigationController?.pushViewController(editView, animated: true)
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
    
    // Overrides the viewDidLoad function
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissTextFieldsByTapping()
    }
    
    // Show save error alert view
    func showSaveErrorAlert(message: String) {
        let errorAlert = UIAlertView(title: "New Product Error", message: "Please fill out the \(message) field.", delegate: self, cancelButtonTitle: "OK")
        indicator?.removeFromSuperview()
        errorAlert.tag = -1
        errorAlert.show()
    }
    
    // Show product id alert view
    func showProductIDErrorAlert() {
        let errorAlert = UIAlertView(title: "New Product Error", message: "Product IDs must be exactly \(Constants.ProductID.Length) characters long.", delegate: self, cancelButtonTitle: "OK")
        indicator?.removeFromSuperview()
        errorAlert.tag = -1
        errorAlert.show()
    }
    
    // Called when a textView is selected for editing
    override func textViewDidBeginEditing(textView: UITextView) {
        if (textView.tag == Constants.Description.FieldTag) {
            animateScrollView(descriptionField, distanceLength: 150, up: true)
        }
        
        // Simulates 'placeholder' text
        if (textView.text == "Enter Product Title" || textView.text == "Enter Product Description") {
            textView.text = ""
        }
    }
    
    // Called when a textView is being edited and the Return key is pushed
    override func textViewDidEndEditing(textView: UITextView) {
        if (textView.tag == Constants.Description.FieldTag) {
            animateScrollView(descriptionField, distanceLength: 150, up: false)
        }
    }
    
    // Prepares for this view to segue to a new view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addNewColorSegue",
            let destination = segue.destinationViewController as? AddNewColorViewController
        {
            destination.callback = addNewColor
            destination.dataRef = dataRef
        }
    }
}
