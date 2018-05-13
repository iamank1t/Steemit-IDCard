//
//  ViewController.swift
//  mySteemitIdCard
//
//  Created by Ankit Singh on 29/03/18.
//  Copyright © 2018 Ankit Singh. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView

class ViewController: UIViewController {
     private var loaderView: NVActivityIndicatorView!
    @IBOutlet var usernameTextfield: UITextField!
    var finalUserData: [String:AnyObject]?
    var userName: String?
    var joinDate: String?
    var id : Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func getUserData(userName: String) {
        showLoadingIndicator()
        var statusCode: String?
        let url = URL(string: "https://steemit.com/@" + userName + ".json")!
        URLSession.shared.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            }else{
                do{
                    var json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                    if let status = json["status"] as? String {
                        statusCode = status
                        if statusCode != "404" {
                             statusCode = ""
                        }
                    }
                    if (statusCode?.isEmpty)! {
                    if let userDetailData = json["user"]!["json_metadata"] as? [String: AnyObject] {
                        DispatchQueue.main.async {
                            self.finalUserData = userDetailData["profile"] as? [String: AnyObject]
                        }
                    }
                    DispatchQueue.main.async {
                       self.userName = json["user"]!["name"] as? String
                        self.joinDate = json["user"]!["created"] as? String
                        self.id = json["user"]!["id"] as? Int
                        self.sendToDetailVC()
                    }
                    }
                    else {
                        let alert = UIAlertController(
                            title: "Error",
                            message: "Please enter a valid username",
                            preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(
                            title: NSLocalizedString("Ok", comment: "Ok"),
                            style: UIAlertActionStyle.default,
                            handler: nil))
                        DispatchQueue.main.async(execute: {
                            self.stopLoadingIndicator()
                            statusCode = ""
                            self.present(alert, animated: true, completion: nil)
                        })
                    }
                }catch let error as NSError{
                    print(error)
                }
            }
        }).resume()
    }

    
    @IBAction func goButtonClicked(_ sender: Any) {
        if (self.usernameTextfield.text?.isEmpty)! {
            let alert = UIAlertController(
                title: "Error",
                message: "User name can't be blank!",
                preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Ok", comment: "Ok"),
                style: UIAlertActionStyle.default,
                handler: nil))
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true, completion: nil)
            })
        }
        else {
            self.getUserData(userName: self.usernameTextfield.text!)
        }
    }
    
    func showLoadingIndicator(){
        if loaderView == nil{
            loaderView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50.0, height: 50.0), type: NVActivityIndicatorType.lineScalePulseOutRapid, color: UIColor.white, padding: 0.0)
            // add subview
            view.addSubview(loaderView)
            // autoresizing mask
            loaderView.translatesAutoresizingMaskIntoConstraints = false
            // constraints
            view.addConstraint(NSLayoutConstraint(item: loaderView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: loaderView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        }
        
        loaderView.startAnimating()
    }
    
    func stopLoadingIndicator(){
        loaderView.stopAnimating()
    }
    
    func sendToDetailVC() {
        stopLoadingIndicator()
        performSegue(withIdentifier: "userIdCardSegue", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userIdCardSegue"{
            let vc = segue.destination as! IDcardVC
            vc.userName = nil
            vc.finalUserData = nil
            vc.joinDate = nil
            vc.barcodeImage = nil
            vc.id = nil
            vc.profileImage = nil
            vc.userName = self.userName
            vc.finalUserData = self.finalUserData
            vc.joinDate = self.joinDate
            vc.id = self.id
        }
    }

    
}

