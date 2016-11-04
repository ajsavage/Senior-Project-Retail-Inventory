//
//  BarcodeScanner.swift
//  Store Inventory
//
//  Created by Andrea Savage on 10/24/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//
//  Created partially from App Coda tutorial: Building a Simple Barcode Reader App in Swift
//  Found at: www.appcoda.com/simple-barcode-reader-app-swift/
//

import UIKit
import AVFoundation

// Protocol to communicate with the modal calling classes
// ScanInViewController and CheckOutViewController
protocol barcodeScannerCommunicator {
    func backFromBarcodeScanner(barcode: String?)
}

class BarcodeScanner: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate {
    // Camera MetaData Properties
    var session: AVCaptureSession!
    var videoPreview: AVCaptureVideoPreviewLayer!
    var code: String?
    var delegate: barcodeScannerCommunicator? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = AVCaptureSession()
        
        // Camera or other capture device
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let videoInput: AVCaptureDeviceInput?
        
        do {
            videoInput = try AVCaptureDeviceInput(device: captureDevice)
        }
        catch {
            // No input
            return
        }
        
        // Add input
        if (session.canAddInput(videoInput)) {
            session.addInput(videoInput)
        }
        else {
            // Device does not have a camera
            scanImpossible()
        }
        
        // Add Output
        let metadataOutput = AVCaptureMetadataOutput()
        if (session.canAddOutput(metadataOutput)) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            
            
            // Set barcode type
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN13Code]
        }
        else {
            // Camera data error
            scanImpossible()
        }
        
        // Show video preview so user can aim at barcode
        videoPreview = AVCaptureVideoPreviewLayer(session: session)
        videoPreview.frame = view.layer.bounds
        videoPreview.videoGravity = AVLayerVideoGravityResizeAspectFill
        view.layer.addSublayer(videoPreview)
        
        // Start running session
        session.startRunning()
    }
    
    // Handle the output
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        // Get the first Object from the metadata
        if let barcodeData = metadataObjects.first {
            let readableBarcode = barcodeData as? AVMetadataMachineReadableCodeObject
            
            if let readableCode = readableBarcode {
                // Handle the found barcode
                barcodeDetected(readableCode.stringValue)
            }
            
            // Vibrate for feedback when found something
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            session.stopRunning()
        }
    }
    
    // Handle a scanned barcode
    func barcodeDetected(code: String) {
        // Notify user
        let alert = UIAlertView(title: "Found a Barcode!", message: "Barcode is: \(code)", delegate: self, cancelButtonTitle: "Add to List")
        alert.tag = 1
        
        self.code = code
        alert.show()
    }
    
    // Dismiss view when 'OK' is clicked in AlertView
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if (alertView.tag == 1) {
            let trimmedCode = code!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            let eanCode = "\(trimmedCode)"
            var upcCode: String
            
            if (eanCode.hasPrefix("0") && eanCode.characters.count > 1) {
                upcCode = String(eanCode.characters.dropFirst())
                self.delegate?.backFromBarcodeScanner(upcCode)
            }
            else {
                self.delegate?.backFromBarcodeScanner(eanCode)
            }
        }
        
        self.delegate?.backFromBarcodeScanner(nil)
    }
    
    // Device was unable to scan/use the camera, show error notification
    func scanImpossible() {
        let errorAlert = UIAlertView(title: "Error: Cannot Scan", message: "This device does not have a camera or this app does not have access to the camera, please enter barcodes manually", delegate: self, cancelButtonTitle: "OK")
        errorAlert.tag = -1
        errorAlert.show()
        session = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
