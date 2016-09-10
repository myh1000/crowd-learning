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

class RegistrationTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var firstName:UITextField!
    @IBOutlet weak var lastName:UITextField!
    @IBOutlet weak var streetNumber:UITextField!
    @IBOutlet weak var streetName:UITextField!
    
    @IBOutlet weak var city:UITextField!
    @IBOutlet weak var state:UITextField!
    @IBOutlet weak var zip:UITextField!
    
    @IBAction func done(sender: UIBarButtonItem){
        let request = NSMutableURLRequest(URL: NSURL(string: "http://api.reimaginebanking.com/customers?key=18287c43fec33cb6c333a33deba4b003")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let requestDictionary = [
            "first_name" : "\(firstName.text)",
            "last_name" : "\(lastName.text)",
            "address"  : [
                "street_number":"\(streetNumber.text!)",
                "street_name":"\(streetName.text!)",
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

                    let ref = FIRDatabase.database().reference()
                    ref.child("paymentId").setValue(id);
                    
                    
                    let alert = UIAlertController(title: "Alert", message: "You will be paid shortly", preferredStyle: UIAlertControllerStyle.Alert)
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("reset", sender: self)
                    }
                }
            }
            if let message = dictionary!["message"] as? String{
                print("message is \(message)")
            }
        }
        task.resume()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.firstName.delegate = self;
        self.lastName.delegate = self;
        self.streetNumber.delegate = self;
        self.streetName.delegate = self;
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
