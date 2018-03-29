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
        self.nameLabel.text = self.finalUserData!["name"] as? String
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
}
