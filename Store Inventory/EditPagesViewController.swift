//
//  EditPagesViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 10/24/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

class EditPagesViewController: ShowProductViewController, selectImageCommunicator {
    // Product Viewing Elements
    @IBOutlet var titleLabel: UITextView!
    @IBOutlet var priceLabel: UITextField!
    @IBOutlet var descriptionLabel: UITextView!
    @IBOutlet var imageLabel: UIImageView!
    @IBOutlet weak var typeSegControl: UISegmentedControl!
    @IBOutlet var overallScrollView: UIScrollView!
    @IBOutlet var searchField: UITextField!
    @IBOutlet var descriptionScrollView: UIScrollView!
    @IBOutlet var saveButton: UIButton!
    
    @IBOutlet weak var colorScrollView: UIScrollView!
    @IBOutlet var totalSizeLabels: [UILabel]!
    
    // Color Swatch View Properties
    let colorSwatchHeight = 37
    let colorSwatchWidth = 45
    var nextXValue = 0
    var nextYValue = 0
    
    // Temporary colors array
    var newColors = [NSString]()
    
    // If the image was updated
    var imageChanged = false
    
    @IBAction func editImageClicked(sender: AnyObject) {
        showLoadingSymbol(imageLabel)
        let imagePicker = storyboard?.instantiateViewControllerWithIdentifier("ImagePicker") as! SelectImageViewController
        imagePicker.delegate = self
        navigationController?.pushViewController(imagePicker, animated: true)
    }
    
    // Callback for the selectImageView
    func selectedImageCallback(image: UIImage?) {
        indicator?.removeFromSuperview()
        
        if (image != nil) {
            imageLabel.image = image
        }
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
                    self.currentProduct.loadInformation(true, callback: self.updateWithLoadedData)
                }
            })
        }
    }
    
    // Called when a textView is selected for editing
    override func textViewDidBeginEditing(textView: UITextView) {
        if (textView.tag == Constants.Description.FieldTag) {
            animateScrollView(descriptionScrollView, distanceLength: 200, up: true)
        }
    }
    
    // Called when a textView is being edited and the Return key is pushed
    override func textViewDidEndEditing(textView: UITextView) {
        if (textView.tag == Constants.Description.FieldTag) {
            animateScrollView(descriptionScrollView, distanceLength: 200, up: false)
        }
    }
    
    // Called when the product's details are finished loading from the database
    func updateWithLoadedData() {
        // Sets the view to display the current product's details
        titleLabel.text = currentProduct.title as String
        priceLabel.text = String(currentProduct.price)
        imageLabel.image = currentProduct.image
        self.descriptionLabel.text = self.currentProduct.productDescription as String
        typeName = currentProduct.type as String
        typeSegControl.selectedSegmentIndex = Constants.Types.Names.indexOf(typeName)!
        
        // Update sizes
        var index = 0
        
        for label in totalSizeLabels {
            let name = Constants.Sizes.Names[index]
            let count = currentProduct.sizes[index]
           
            label.text = "\(name): \(count)"
            index += 1
        }
        
        // Update colors view
        for color in currentProduct.colors {
            if (color.color == nil) {
                color.loadUIColor(FIRDatabase.database().reference(), callback: setUpSwatchView)
            }
            else {
                setUpSwatchView(color.color)
            }
        }
        
        overallScrollView.hidden = false
        view.backgroundColor = UIColor.whiteColor()
        removeLoadingSymbol(searchField)
        searchField.text = nil
    }
    
    // Sets up color swatch
    private func setUpSwatchView(color: UIColor?) {
        if color == nil {
            return
        }
        
        // Create new color swatch
        let colorSwatch = UIView()
        var addHeight = 0
        colorSwatch.backgroundColor = color
        colorSwatch.frame = CGRect(x: nextXValue, y: nextYValue, width: colorSwatchWidth - 2, height: colorSwatchHeight - 2)

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
 
    @IBAction func saveButtonClicked(sender: AnyObject) {
        showLoadingSymbol(overallScrollView)
        
        currentProduct.selfRef.child("Title").setValue(titleLabel.text)
        currentProduct.selfRef.child("Description").setValue(descriptionLabel.text)

        let price = Float(priceLabel.text!)
        if (price != nil) {
            currentProduct.selfRef.child("Price").setValue(price)
        }
        
        if (typeSegControl.selectedSegmentIndex != UISegmentedControlNoSegment) {
            currentProduct.selfRef.child("Type").setValue(Constants.Types.Names[typeSegControl.selectedSegmentIndex])
        }
        
        // Save Image
        if (imageChanged) {
            currentProduct.saveImage(imageLabel.image!, callback: doneSavingProduct)
        }
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    // Saving Button Callback after Image is uploaded to storage
    func doneSavingProduct() {
        removeLoadingSymbol(overallScrollView)
    }
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissTextFieldsByTapping()
        
        // Setup starting view
        if (currentProduct == nil) {
            overallScrollView.hidden = true
            view.backgroundColor = UIColor.blackColor()
       //     searchField.becomeFirstResponder()
        }
        else {
            showLoadingSymbol(searchField)
            self.currentProduct.loadInformation(true, callback: self.updateWithLoadedData)
        }
        
        // Set description textView tag
        descriptionLabel.tag = Constants.Description.FieldTag
        
        // Add rounded border to title textview
        titleLabel.layer.borderColor = UIColor.lightGrayColor().CGColor
        titleLabel.layer.cornerRadius = 5
        titleLabel.layer.borderWidth = 1
    }
    
    // Helper to move description text field up when clicked and
    // covered by the keyboard
    func animateDescriptionScrollView(view: UIScrollView, distanceLength: Int, up: Bool) {
        let duration = 0.3
        let distance = CGFloat(distanceLength) * (up ? 1 : -1)
        
        UIView.beginAnimations("animateDescriptionScrollView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(duration)
        self.view.frame = CGRectOffset(self.view.frame, 0, distance)
        UIView.commitAnimations()
    }
}
