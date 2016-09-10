//
//  LoadingViewController.swift
//  crowdLearning
//
//  Created by Kevin Fang on 9/10/16.
//  Copyright © 2016 myh1000. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class LoadingViewController: UIViewController {
    
    var model = NSMutableDictionary()
    var network: FFNN!
    private let networkQueue = dispatch_queue_create("com.SwiftAI.networkQueue", DISPATCH_QUEUE_SERIAL)
    var numPoints = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        let ref = FIRDatabase.database().reference()

        ref.observeEventType(.ChildChanged, withBlock: { (snapshot) -> Void in
            print("sjdaskf")
            print(snapshot.key)
            print(snapshot.value)
            if (snapshot.key == "request_recieved" && snapshot.value as! String == "true") {
                self.network = FFNN(inputs: self.model.objectForKey("num_inputs")!.integerValue, hidden: self.model.objectForKey("hidden_size")!.integerValue, outputs: self.model.objectForKey("num_outputs")!.integerValue,
                    learningRate: 0.7, momentum: 0.4, weights: nil,
                    activationFunction : .Sigmoid, errorFunction: .CrossEntropy(average: false))
                self.startTraining()
                print("SAME")
                self.performSegueWithIdentifier("done", sender: self)
            }
        })
    }
    
    func startTraining() {
        let ref = FIRDatabase.database().reference()

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
            //            print(self.network.hiddenWeights)
            //            print(self.network.outputWeights)
            
            ref.child("weights").setValue(["hiddenWeights":self.network.hiddenWeights.description, "outputWeights":self.network.outputWeights.description])
            self.network.writeToFile("data")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindone(segue: UIStoryboardSegue) {
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
