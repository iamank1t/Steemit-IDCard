//
//  IDcardVC.swift
//  mySteemitIdCard
//
//  Created by Ankit Singh on 29/03/18.
//  Copyright © 2018 Ankit Singh. All rights reserved.
//

import UIKit
import SDWebImage
class IDcardVC: UIViewController {

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

    
}
