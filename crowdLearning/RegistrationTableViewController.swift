//
//  RegistrationTableViewController.swift
//  crowdLearning
//
//  Created by Kevin Fang on 9/10/16.
//  Copyright © 2016 myh1000. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SCLAlertView

class RegistrationTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var name:UITextField!
    @IBOutlet weak var address:UITextField!
    
    @IBOutlet weak var city:UITextField!
    @IBOutlet weak var state:UITextField!
    @IBOutlet weak var zip:UITextField!
    private var customerid = NSString()
    private var money = 5;
    
    @IBAction func done(sender: UIBarButtonItem){
        let request = NSMutableURLRequest(URL: NSURL(string: "http://api.reimaginebanking.com/customers?key=18287c43fec33cb6c333a33deba4b003")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let fullNameArr = name.text!.componentsSeparatedByString(" ")
        let fullAddressArr = address.text!.componentsSeparatedByString(" ")
        
        let requestDictionary = [
            "first_name" : "\(fullNameArr[0])",
            "last_name" : "\(fullNameArr[1])",
            "address"  : [
                "street_number":"\(fullAddressArr[0])",
                "street_name":"\(fullAddressArr[1])",
                "city":"\(city.text!)",
                "state":"\(state.text!)",
                "zip":"\(zip.text!)"
            ]
        ]
        
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(requestDictionary, options:[])
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                print("error=\(error)")
                return
            }
            
            let responseString = String(data: data!, encoding: NSUTF8StringEncoding)
            
            print("responseString = \(responseString!)")
            var dictionary = self.convertStringToDictionary(responseString!)
            
            if let created = dictionary!["objectCreated"] as? [String: AnyObject]{
                if let id = created["_id"] as? String{
                    print("id is \(id)")
                    self.customerid = id
                    let ref = FIRDatabase.database().reference()
                    ref.child("paymentId").setValue(id);
                    
//                    let alert = UIAlertController(title: "Alert", message: "You will be paid shortly", preferredStyle: UIAlertControllerStyle.Alert)
//                    self.presentViewController(alert, animated: true, completion: nil)
                    
//                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
//                    dispatch_after(delayTime, dispatch_get_main_queue()) {
//                        self.performSegueWithIdentifier("reset", sender: self)
//                    }
                }
            }
            if let message = dictionary!["message"] as? String{
                print("message is \(message)")
            }
        }
        task.resume()
        
        
        
        let request2 = NSMutableURLRequest(URL: NSURL(string: "http://api.reimaginebanking.com/customers/\(customerid)/accounts?key=18287c43fec33cb6c333a33deba4b003")!)
        request2.HTTPMethod = "POST"
        request2.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request2.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let requestDictionary2 = [
            "type":"Credit Card",
            "nickname": "string",
            "rewards": 0,
            "balanace" : 0
        ]
        
        request2.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(requestDictionary2, options:[])
        
        let task2 = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                print("error=\(error)")
                return
            }
            
            let responseString = String(data: data!, encoding: NSUTF8StringEncoding)
            
            print("responseString = \(responseString!)")
            var dictionary = self.convertStringToDictionary(responseString!)
            
            if let created = dictionary!["objectCreated"] as? [String: AnyObject]{
                if let id = created["_id"] as? String{
                    print("id is \(id)")
                    
                    let ref = FIRDatabase.database().reference()
                    ref.child("paymentId").setValue(id);
                    
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
//                        self.performSegueWithIdentifier("reset", sender: self)
//                        SCLAlertView().showInfo("Congratulations!", subTitle: "You made $\(money)")
                        
                        let appearance = SCLAlertView.SCLAppearance(
                            showCloseButton: false
                        )
                        let alertView = SCLAlertView(appearance: appearance)
                        let alertViewIcon = UIImage(named: "Icon")
                        alertView.showInfo("Congrats!", subTitle: "You just made $\(self.money)", circleIconImage: alertViewIcon)
                        alertView.addButton("Done") {
                            self.performSegueWithIdentifier("reset",sender:self);
                        }
                        alertView.showSuccess("Congrats!", subTitle: "You just made $\(self.money)", circleIconImage: alertViewIcon)
//                        let alertView = SCLAlertView(appearance: appearance)
//                        alertView.showWarning("No button", subTitle: "Just wait for 3 seconds and I will disappear", duration: 3)
                    }
                }
            }
            if let message = dictionary!["message"] as? String{
                print("message is \(message)")
            }
        }
        task2.resume()
        
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.name.delegate = self;
        self.address.delegate = self;
        self.city.delegate = self;
        self.state.delegate = self;
        self.zip.delegate = self



        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}
