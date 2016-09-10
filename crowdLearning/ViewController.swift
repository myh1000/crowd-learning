//
//  ViewController.swift
//  crowdLearning
//
//  Created by family on 9/9/16.
//  Copyright © 2016 myh1000. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController {

    /// The number of points to plot on screen
    var numPoints = 0
    /// Serial queue for synchronizing access to neural network from multiple threads
    private let networkQueue = dispatch_queue_create("com.SwiftAI.networkQueue", DISPATCH_QUEUE_SERIAL)
    var network: FFNN!
    private let filePath = NSHomeDirectory() + "/Documents/test"
    @IBOutlet weak var joinButton: UIButton!
//    @IBOutlet weak var same: UIButton!
    var model : NSMutableDictionary = [:]
    var ref = FIRDatabaseReference()
    var postDict: AnyObject?
    var eyedee = Int()
    
    @IBAction func join(sender: AnyObject) {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://47ebd870.ngrok.io/servant_connect")!)
        
        request.HTTPMethod = "POST"
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200
            {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            self.eyedee = Int(responseString!)!
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        joinButton.layer.cornerRadius = 5;
        // Do any additional setup after loading the view, typically from a nib.
        
        ref.child("model_structure").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            self.model.setObject(snapshot.value!["hidden_size"] as! String, forKey: "hidden_size")
            self.model.setObject(snapshot.value!["num_inputs"] as! String, forKey: "num_inputs")
            self.model.setObject(snapshot.value!["learning_rate"] as! String, forKey: "learning_rate")
            self.model.setObject(snapshot.value!["num_outputs"] as! String, forKey: "num_outputs")
        }) { (error) in
            print(error.localizedDescription)
        }
        ref.child("model_structure").observeEventType(.ChildChanged, withBlock: { (snapshot) -> Void in
            let keyname = snapshot.key
            self.model.setObject((snapshot.value as! NSString).doubleValue, forKey: keyname)
        })
        

        //        ref.observeEventType(.ChildChanged, withBlock: { (snapshot) -> Void in
//            let index = self.snapshots.indexOf(snapshot)
//            self.snapshots.append(snapshot)
//        })
//        self.startTraining()
    }
    

        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            if segue.identifier == "same" {
                if let destinationVC = segue.destinationViewController as? LoadingViewController {
                    destinationVC.model = self.model
                    destinationVC.network = self.network
                    destinationVC.eyedee = self.eyedee
                }
            }
        }
    }
    
    @IBAction func unwindtwo(segue: UIStoryboardSegue) {
    }

}

