//
//  IDcardVC.swift
//  mySteemitIdCard
//
//  Created by Ankit Singh on 29/03/18.
//  Copyright © 2018 Ankit Singh. All rights reserved.
//

import UIKit
import SDWebImage
import Photos

class IDcardVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var mainView: UIView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var joinedLabel: UILabel!
    @IBOutlet var barcodeImage: UIImageView!
    @IBOutlet var idLabel: UILabel!
    var userName: String?
    var finalUserData: [String:AnyObject]?
    var joinDate: String?
    var id : Int?
    var imagePickerController = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userNameLabel.text = self.userName
        self.idLabel.text = "\(self.id!)"
        if let name = self.finalUserData!["name"] as? String {
            self.nameLabel.text = name
        }
        else {
            self.nameLabel.text = "My username is enough"
        }
        if let userImageUrl = self.finalUserData!["profile_image"] as? String {
            self.profileImage.sd_setImage(with: URL(string: userImageUrl), completed: nil)
            self.profileImage.sd_setImage(with: URL(string: userImageUrl), placeholderImage: UIImage(named: "defaultImage.png"))
        }
        else {
            self.profileImage.image = #imageLiteral(resourceName: "defaultImage")
        }
        let formattedDate = self.joinDate!.dropLast(9)
        self.joinedLabel.text = String(formattedDate)
//        let url = URL(string: "https://steemit.com/@" + userName! + ".json")!
         self.barcodeImage.image = generateQRCode(from: "https://steemit.com/@" + userName!)
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    @IBAction func saveToDeviceButtonClicked(_ sender: Any) {
        // get an UIImage object from this
        let image = imageWithView(view: self.mainView)
        
        //Then save your ID Card image
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    //function to convert the ID Card UIView into an UIImage
    func imageWithView(view:UIView)->UIImage{
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    // function to show users alert, if image saved or not
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Yureka!", message: "Your Steem Id Card has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Great", style: .default))
            present(ac, animated: true)
        }
    }

    @IBAction func addCustomImageButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction) -> Void in
        })
        
        let takePhotoButton = UIAlertAction(title: "Take Photo", style: .default, handler: {(action: UIAlertAction) -> Void in
            let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch authorizationStatus {
            case .notDetermined:
                // permission dialog not yet presented, request authorization
                AVCaptureDevice.requestAccess(for: AVMediaType.video,
                                              completionHandler: { (granted:Bool) -> Void in
                                                if granted {
                                                    DispatchQueue.main.async(execute: {
                                                        if UIImagePickerController.isSourceTypeAvailable(.camera)
                                                        {
                                                            print("access granted", terminator: "")
                                                            self.imagePickerController.sourceType = .camera
                                                            self.imagePickerController.delegate = self
                                                            self.present(self.imagePickerController, animated: true, completion: {() -> Void in })
                                                        }
                                                        else
                                                        {
                                                            print("Camera not available")
                                                        }
                                                    })
                                                }
                                                else {
                                                    print("access denied", terminator: "")
                                                }
                })
            case .authorized:
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    self.imagePickerController.sourceType = .camera
                    self.imagePickerController.delegate = self
                    self.present(self.imagePickerController, animated: true, completion: {() -> Void in })
                } else {
                    print("Camera not available")
                }
                break
            case .denied, .restricted:
                self.alertToEncourageCameraAccessWhenApplicationStarts()
            }
            
            
        })
        
        let chooseExistingButton = UIAlertAction(title: "Choose Existing", style: .default, handler: { (action: UIAlertAction) -> Void in
            if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized
            {
                UINavigationBar.appearance().titleTextAttributes = [
                    NSAttributedStringKey.font : UIFont(name: "Ubuntu", size: 16)!,
                    NSAttributedStringKey.foregroundColor : UIColor.black
                ]
                self.imagePickerController.sourceType = .photoLibrary
                self.imagePickerController.delegate = self
                self.present(self.imagePickerController, animated: true, completion: {() -> Void in
                })
                
            }
            else if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.notDetermined {
                PHPhotoLibrary.requestAuthorization({(_ status: PHAuthorizationStatus) -> Void in
                    if status == .authorized {
                        DispatchQueue.main.async(execute: {
                            
                            // Access has been granted.
                            self.imagePickerController.sourceType = .photoLibrary
                            self.imagePickerController.delegate = self
                            UINavigationBar.appearance().titleTextAttributes = [
                                NSAttributedStringKey.font : UIFont(name: "Ubuntu", size: 16)!,
                                NSAttributedStringKey.foregroundColor : UIColor.black
                            ]
                            self.present(self.imagePickerController, animated: true, completion: {() -> Void in
                            })
                        })
                    }
                    else {
                        // Access has been denied.
                    }
                })
            } else {
                self.alertToEncouragePhotoLibraryAccessWhenApplicationStarts()
            }
            
        })
        
        let removeButton = UIAlertAction(title: "Remove", style: .destructive, handler: { (action: UIAlertAction) -> Void in
            self.removeProfileImage()
            //backend request to remove image
        })
        
        alert.addAction(cancelButton)
        alert.addAction(takePhotoButton)
        alert.addAction(chooseExistingButton)
        if self.profileImage.image != #imageLiteral(resourceName: "defaultImage")
        {
            alert.addAction(removeButton)
        }
        self.present(alert, animated: true, completion: {})
    }
    
    //removing image from id card
    func removeProfileImage(){
        self.profileImage.image = #imageLiteral(resourceName: "defaultImage")
    }
    
    func alertToEncouragePhotoLibraryAccessWhenApplicationStarts()
    {
        //Photo Library not available - Alert
        let cameraUnavailableAlertController = UIAlertController (title: "Photo Library Unavailable", message: "Please check to see if device settings doesn't allow photo library access", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .destructive) { (_) -> Void in
            let settingsUrl = URL(string:UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        cameraUnavailableAlertController .addAction(settingsAction)
        cameraUnavailableAlertController .addAction(cancelAction)
        self.present(cameraUnavailableAlertController , animated: true, completion: nil)
    }
    
    func alertToEncourageCameraAccessWhenApplicationStarts()
    {
        //Camera not available - Alert
        let internetUnavailableAlertController = UIAlertController (title: "Camera Unavailable", message: "Please check to see if it is disconnected or in use by another application", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .destructive) { (_) -> Void in
            let settingsUrl = URL(string:UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        internetUnavailableAlertController .addAction(settingsAction)
        internetUnavailableAlertController .addAction(cancelAction)
        self.present(internetUnavailableAlertController , animated: true, completion: nil)
    }
}
