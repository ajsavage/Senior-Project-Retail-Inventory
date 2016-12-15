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
    func backFromBarcodeScanner(barcode: String?, index: Int)
    func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}

class BarcodeScanner: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate {
    // Camera MetaData Properties
    var session: AVCaptureSession!
    var videoPreview: AVCaptureVideoPreviewLayer!
    var delegate: barcodeScannerCommunicator? = nil
    var index: Int = -1
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
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
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeQRCode]
        }
        else {
            // Camera data error
            scanImpossible()
        }
        
        // Show video preview so user can aim at barcode
        videoPreview = AVCaptureVideoPreviewLayer(session: session)
        videoPreview.frame = view.layer.bounds
        videoPreview.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreview.bounds = self.view.bounds
        videoPreview.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))
        self.view.layer.addSublayer(videoPreview)
        
        // Start running session
        session.startRunning()
    }
    
    // Draws a rectangle around a detected barcode
    func translatePoints(points: [AnyObject], fromView: UIView, toView: UIView)
        
        -> [CGPoint] {
        var translated : [CGPoint] = []
        
        for point in points {
            let dict = point as! NSDictionary
            let x = CGFloat((dict.objectForKey("X") as! NSNumber).floatValue)
            let y = CGFloat((dict.objectForKey("Y") as! NSNumber).floatValue)
            let curr = CGPointMake(x, y)
            
            let currFinal = fromView.convertPoint(curr, toView: toView)
            translated.append(currFinal)
        }
        
        return translated
    }
    
    // Handle the output
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        // Get the first Object from the metadata
        if let barcodeData = metadataObjects.first {
            // Close this Scanner
            dismissViewControllerAnimated(true, completion: nil)
            
            let readableBarcode = barcodeData as? AVMetadataMachineReadableCodeObject
            
            if let readableCode = readableBarcode {
                // Handle the found barcode
                barcodeDetected(readableCode.stringValue)
            }
            
            // Vibrate for feedback when found something
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.session.stopRunning()
        }
    }
    
    // Handle a scanned barcode
    func barcodeDetected(code: String) {
        // Notify user
        let alert = UIAlertController(title: "Found a Barcode!", message: "Barcode is: \(code)", preferredStyle: .Alert)
        
        let okButton = UIAlertAction(title: "Ignore", style: .Default, handler: nil)        
        let cancelButton = UIAlertAction(title: "Use Barcode", style: .Cancel) { action in
            self.sendBarcode(code)
        }
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        delegate!.presentViewController(alert, animated: true, completion: nil)
    }
    
    // Send delegate found barcode when 'Use Barcode' is clicked in AlertView
    func sendBarcode(code: String) {
        let trimmedCode = code.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let eanCode = "\(trimmedCode)"
        var upcCode: String
        
        if (eanCode.hasPrefix("0") && eanCode.characters.count > 1) {
            upcCode = String(eanCode.characters.dropFirst())
            self.delegate?.backFromBarcodeScanner(upcCode, index: self.index)
        }
        else {
            self.delegate?.backFromBarcodeScanner(eanCode, index: self.index)
        }
    }
    
    // Device was unable to scan/use the camera, show error notification
    func scanImpossible() {
        let alert = UIAlertController(title: "Error: Cannot Scan", message: "This device does not have a camera or this app does not have access to the camera, please enter barcodes manually", preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "OK", style: .Default) { action in
            self.delegate?.backFromBarcodeScanner(nil, index: 0)
        }
        
        alert.addAction(okButton)
        self.presentViewController(alert, animated: true, completion: nil)
        session = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
