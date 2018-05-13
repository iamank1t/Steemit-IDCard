//
//  PrintRequestVC.swift
//  mySteemitIdCard
//
//  Created by Ankit Singh on 13/05/18.
//  Copyright © 2018 Ankit Singh. All rights reserved.
//

import UIKit
import SwiftyJSON

class PrintRequestVC: UIViewController {
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var postalAddressTextField: UITextView!
    @IBOutlet var zipCodeTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func printButtonClicked(_ sender: Any) {
        if (self.nameTextField.text?.isEmpty)! || (self.emailTextField.text?.isEmpty)! || (self.postalAddressTextField.text.isEmpty) || (self.zipCodeTextField.text?.isEmpty)! {
            let ac = UIAlertController(title: "Error", message: "Please fill all fields!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        else {
            self.submitUserAddressDetails()
        }
    }
    
    func createRequestObject(_ urlString: String, requestType: String) -> URLRequest {
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = requestType
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    func submitUserAddressDetails() {
        let NameText = self.nameTextField.text
        let emailText = self.emailTextField.text
        let postalAddressText = self.postalAddressTextField.text
        let zipcodeText = self.zipCodeTextField.text
        var dataDictionary = [String: AnyObject]()
        if let NameText = NameText {
            dataDictionary["userName"] = NameText as AnyObject?
        }
        if let emailText = emailText {
            dataDictionary["userEmail"] = emailText as AnyObject?
        }
        if let postalAddressText = postalAddressText  {
            dataDictionary["userAddress"] = postalAddressText as AnyObject?
        }
        if let zipcodeText = zipcodeText  {
            dataDictionary["zipcode"] = zipcodeText as AnyObject?
        }
        
        var userDetails = ["user": dataDictionary as AnyObject]
        var request = self.createRequestObject("http://192.168.1.203:3000/userDetails", requestType: "POST")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: userDetails, options:[])
        } catch _{}
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {data, response, error in
            guard let _ = data else {
                
                let networkAlert = self.showNetworkAlert()
                
                DispatchQueue.main.async(execute: {
                    self.present(networkAlert, animated: true, completion: nil)
                })
                return
            }
            let res = response as? HTTPURLResponse            
            if(res?.statusCode == 201) {
                let alert = UIAlertController(
                    title: "Congrats",
                    message: "You will get your ID Card Soon",
                    preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(
                    title: NSLocalizedString("Ok-Title", comment: "Ok-Title"),
                    style: UIAlertActionStyle.default,
                    handler: nil))
                DispatchQueue.main.async(execute: {
                    self.present(alert, animated: true, completion: nil)
                })
                
            } else if(res?.statusCode == 422) {
                let alert = UIAlertController(
                    title: "",
                    message: "",
                    preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(
                    title: NSLocalizedString("Ok-Title", comment: "Ok-Title"),
                    style: UIAlertActionStyle.default,
                    handler: nil))
                DispatchQueue.main.async(execute: {
                    self.present(alert, animated: true, completion: nil)
                })
            }
        })
        task.resume()
    }
    
    //MARK: Alerts
    func showNetworkAlert() -> UIAlertController {
        let networkAlert = UIAlertController(
            title: NSLocalizedString("Network-Error-Title", comment: "Network-Error-Title"),
            message: NSLocalizedString("Network-Error-Message", comment: "Network-Error-Message"),
            preferredStyle: UIAlertControllerStyle.alert)
        networkAlert.addAction(UIAlertAction(
            title: NSLocalizedString("Ok-Title", comment: "Ok-Title"),
            style: UIAlertActionStyle.default,
            handler: nil)
        )
        return networkAlert
    }
}
