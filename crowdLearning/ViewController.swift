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
    private var network: FFNN!
    private let filePath = NSHomeDirectory() + "/Library/Caches/test.txt"
    @IBOutlet weak var joinButton: UIButton!
//    @IBOutlet weak var same: UIButton!
    private var model : NSMutableDictionary = [:]
    var postDict: AnyObject?

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
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        joinButton.layer.cornerRadius = 5;
        // Do any additional setup after loading the view, typically from a nib.

        
        let ref = FIRDatabase.database().reference()
        
        ref.child("model_structure").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            self.model.setObject(snapshot.value!["hidden_size"] as! String, forKey: "hidden_size")
            self.model.setObject(snapshot.value!["num_inputs"] as! String, forKey: "num_inputs")
            self.model.setObject(snapshot.value!["num_layers"] as! String, forKey: "num_layers")
            self.model.setObject(snapshot.value!["num_outputs"] as! String, forKey: "num_outputs")
        }) { (error) in
            print(error.localizedDescription)
        }
        ref.child("model_structure").observeEventType(.ChildChanged, withBlock: { (snapshot) -> Void in
            let keyname = snapshot.key
            self.model.setObject(snapshot.value as! Int, forKey: keyname)
        })
        ref.child("request_recieved").observeEventType(.ChildChanged, withBlock: { (snapshot) -> Void in
            print(snapshot);
            if (snapshot.value as! String == "true") {
                self.network = FFNN(inputs: self.model.objectForKey("num_inputs") as! Int, hidden: 64, outputs: 10,
                    learningRate: 0.7, momentum: 0.4, weights: nil,
                    activationFunction : .Sigmoid, errorFunction: .CrossEntropy(average: false))
                self.startTraining()
            }
        })
//        ref.observeEventType(.ChildChanged, withBlock: { (snapshot) -> Void in
//            let index = self.snapshots.indexOf(snapshot)
//            self.snapshots.append(snapshot)
//        })
//        self.startTraining()
        print("SAME")
    }
    

    func startTraining() {
        // Dispatches training process to background thread
        dispatch_async(self.networkQueue) {
            var epoch = 0
            while epoch < 1000 {
                for index in 0..<self.numPoints {
                    let x = (-500 + (Float(index) * 1000) / Float(self.numPoints)) / 100
                    try! self.network.update(inputs: [x])
                    let answer : Float = 3*x
                    try! self.network.backpropagate(answer: [answer])
                }
                epoch += 1
                if (epoch % 5 == 0) {
//                    print(epoch)
                }
            }
            print(self.network.hiddenWeights)
            print(self.network.outputWeights)
            self.network.writeToFile("test")
            var readString: String
            do {
                readString = try NSString(contentsOfFile: self.filePath, encoding: NSUTF8StringEncoding) as String
                print(readString)
            } catch let error as NSError {
                print(error.description)
            }
        }
    }

        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

