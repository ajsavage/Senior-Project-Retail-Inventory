//
//  ProductTableViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 10/10/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

class ProductTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UITextFieldDelegate {
    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!

    // Filter Properties
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var loadingSymbolLabel: UILabel!
    
    // Price Properties
    @IBOutlet weak var maxPriceLabel: UILabel!
    @IBOutlet weak var priceSlider: UISlider!
    
    // Search Options
    @IBOutlet weak var titleSearch: UITextField!
    @IBOutlet weak var idSearch: UITextField!
    @IBOutlet weak var typeSearch: UISegmentedControl!
    @IBOutlet weak var colorView: UIView!
    
    // Color Buttons
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet var coloredButtons: [UIButton]!
    
    // Arrays holding the products currently on the phone
    var products = [Product]()
    var productSearchResults = [Product]()
    
    let detailSegueIdentifier = "ProductDetailsSegue"
    
    // reference to the inventory portion of the database
    let dataRef = FIRDatabase.database().reference()
    
    // Loading Animation
    var indicator: UIActivityIndicatorView? = nil
    
    // NSUserDefaults
    let prefs = NSUserDefaults.standardUserDefaults()
    
    // Button Actions
    @IBAction func cancelButton(sender: UIButton) {
        filterView.hidden = true
    }
    
    @IBAction func openFilterMenu(sender: UIButton) {
        filterView.hidden = false
    }
    
    @IBAction func allColorsButton(sender: UIButton) {
        allButton.selected = true
        
        for button in coloredButtons {
            button.selected = false
        }
    }
    
    @IBAction func searchButton(sender: UIButton) {
        showLoadingSymbol(loadingSymbolLabel)
        
        // Filter for a title search and resets productSearchResults
        filterProductsByTitle(titleSearch.text!)
        
        // Filter by price if the max price is not selected
        if (priceSlider.value != priceSlider.maximumValue) {
            self.productSearchResults = self.productSearchResults.filter() {
                ($0 as Product).price <= priceSlider.value
            }
        }
        
        // Filter by type if 'All' is not selected
        if (typeSearch.selectedSegmentIndex != (Constants.Types.Filters.count - 1)) {
            let typeFilter = Constants.Types.Filters[typeSearch.selectedSegmentIndex]
                
            self.productSearchResults = self.productSearchResults.filter() {
                ($0 as Product).type == typeFilter
            }
        }
        
        // Filter by product ID if the field is not empty
        if (idSearch.text != nil) {
            let idFilter = idSearch.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            if (idFilter != "") {
                self.productSearchResults = self.productSearchResults.filter() {
                    ($0 as Product).productID.lowercaseString.rangeOfString(idFilter.lowercaseString) != nil
                }
            }
        }
        
        // Filter by color if the 'All' option is not selected
        if (!allButton.selected) {
            var searchColors = [NSString]()
            
            for button in coloredButtons {
                if (button.selected) {
                    searchColors.append(Constants.Colors.Names[coloredButtons.indexOf(button)!])
                }
            }
            
            let colorSet = Set(searchColors)
            self.productSearchResults = self.productSearchResults.filter() {
                !colorSet.intersect(($0 as Product).colors).isEmpty
            }
        }
        
        // Notify user if there are no found products
        if productSearchResults.count == 0 {
            let message = "Oh no! There are no products that match your search selections."
            let noResultsAlert = UIAlertView(title: "No Results", message: message, delegate: self, cancelButtonTitle: "OK")
            noResultsAlert.show()
        }
        
        indicator?.removeFromSuperview()
        self.tableView.reloadData()
    }
    
    // Helper for searching
    // Updates productSearchResults to have only the products
    // that have a title beginning with the key
    private func filterProductsByTitle(longSearchText: String) {
        let searchText = longSearchText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        // No products to filter
        if products.count == 0 {
            productSearchResults = []
        }
        // No search values
        else if (searchText == "") {
            productSearchResults = products
        }
        // Filter search results
        else {
            let searchQuery = dataRef.child("inventory").queryOrderedByChild("Title").queryStartingAtValue(searchText).queryEndingAtValue(searchText)
            
            self.productSearchResults = []
            loadProductsFromQuery(searchQuery)
        }
    }
    
    // Loads all of the products returned by the given database query
    private func loadProductsFromQuery(query: FIRDatabaseQuery) {
        query.observeEventType(.Value, withBlock: { snapshot in
            if snapshot.exists() {
                var newProduct: Product
                
                // create and add all of the products in the query
                for child in snapshot.children {
                    newProduct = Product(data: child as! FIRDataSnapshot, ref: self.dataRef.child("inventory"))
                    self.productSearchResults.append(newProduct)
                }
            }
            
            self.tableView.reloadData()
        })
    }
    
    private func setupFiltersMenu() {
        // hide filters menu
        filterView.hidden = true
        
        // price slider with max price
        var maxPrice: Float = 150
        dataRef.child("maxPrice").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.exists() {
                maxPrice = snapshot.value as! Float
            }
            
            self.maxPriceLabel.text = "$\(maxPrice)"
            self.priceSlider.maximumValue = maxPrice
        })
    }
    
    // Grays out all other filter options if there is data in the product ID field
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField == idSearch) {
            // Change filter access
            if idSearch.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
                disableAllOtherFilters(true)
            }
            else {
                disableAllOtherFilters(false)
            }
        }
    }
    
    // Helper method that disables or enables all filter options except the product ID
    // text field if there is non-whitespace text in the field
    private func disableAllOtherFilters(shouldDisable: Bool) {
        priceSlider.enabled = !shouldDisable
        titleSearch.enabled = !shouldDisable
        typeSearch.enabled = !shouldDisable
        allButton.enabled = !shouldDisable
        
        for colorButton in coloredButtons {
            colorButton.enabled = !shouldDisable
        }
    }
    
    // Closes a textField with the return key
    // Called when a textField is highlighted and the Return key is pushed
    // From UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.endEditing(true)
        
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var newProduct: Product!
        
        setupFiltersMenu()
        
        // Greet user in title
        navigationTitle.title = "Hi \(prefs.stringForKey("USERNAME"))!"
        
        // Set back button title
        let backButton = UIBarButtonItem.init(title: "Home", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        dataRef.child("inventory").observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if !snapshot.exists() { return }
            
            for child in snapshot.children {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    let converted = child as! FIRDataSnapshot
                    newProduct = Product(data: converted, ref: self.dataRef.child("inventory"))
                    
                    if (newProduct.price > 0) {
                        self.products.append(newProduct)
                        self.loadProductImageFromStorage(newProduct)
                    }
                }
            }
        })
    }
    
    func loadProductImageFromStorage(product: Product) {
        let storage = FIRStorage.storage().referenceForURL("gs://storeinventoryapp.appspot.com")
        let newImage = storage.child(product.productID as String + ".jpeg")
        
        newImage.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                if (error != nil) {
                    product.setImage(UIImage(named: "DefaultImage")!)
                }
                else {
                    product.setImage(UIImage(data: data!)!)
                }
            
                self.productSearchResults = self.products
                self.tableView.reloadData()
             //   self.tableView.insertRowsAtIndexPaths([NSIndexPath(row: self.products.count - 1, section: 0)], withRowAnimation: true)
            }
        }
    }
    
    // Adds a loadiing symbol to the given view
    func showLoadingSymbol(loadingView: UIView) {
        indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        loadingView.addSubview(indicator!)
        indicator!.frame = loadingView.bounds
        indicator!.startAnimating()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productSearchResults.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ProductTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ProductTableViewCell
        let currentProduct = productSearchResults[indexPath.row]
        
        cell.productTitle.text = currentProduct.title as String
        cell.priceLabel.text = currentProduct.strPrice
        cell.productImage.image = currentProduct.image
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == detailSegueIdentifier,
            let destination = segue.destinationViewController as? DetailsViewController,
            IDIndex = tableView.indexPathForSelectedRow?.row
        {
            destination.currentProduct = productSearchResults[IDIndex]
        }
    }
}
