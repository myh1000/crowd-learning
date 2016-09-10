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
    var eyedee = Int()
    var waiting = false
    var weights = NSMutableDictionary()
    var newhidden = false
    var newoutput = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let ref = FIRDatabase.database().reference()
        ref.observeEventType(.ChildChanged, withBlock: { (snapshot) -> Void in
            print("Child has changed")
//            print(snapshot.key)
//            print(snapshot.value)
            if (snapshot.key == "request_recieved" && snapshot.value as! String == "true") {
                self.network = FFNN(inputs: self.model.objectForKey("num_inputs")!.integerValue, hidden: self.model.objectForKey("hidden_size")!.integerValue, outputs: self.model.objectForKey("num_outputs")!.integerValue,
                    learningRate: 0.7, momentum: 0.4, weights: nil,
                    activationFunction : .Sigmoid, errorFunction: .CrossEntropy(average: false))
                self.startTraining()
                print("SAME")
                self.performSegueWithIdentifier("done", sender: self)
            }
        })
        ref.child("newWeights").observeEventType(.ChildChanged, withBlock: { (snapshot) -> Void in
            if (snapshot.key == "newHiddenWeights") {
                self.newhidden = true
            }
            else if (snapshot.key == "newOutputWeights") {
                self.newoutput = true
            }
            self.weights.setValue(snapshot.value, forKey: snapshot.key)
            if (self.newhidden && self.newoutput) {
                self.newhidden = false
                self.newoutput = false
                
                print("Starting Learning")
                var newHiddenWeights : String = self.weights.valueForKey("newHiddenWeights") as! String
                var newOutputWeights : String = self.weights.valueForKey("newOutputWeights") as! String
                print(newHiddenWeights)
                let splitHidden = newHiddenWeights.characters.split{$0 == ","}.map(String.init)
                let splitOutput = newOutputWeights.characters.split{$0 == ","}.map(String.init)
                
                var floatHidden = [Float]()
                for item in splitHidden {
                    floatHidden.append((item as NSString).floatValue)
                }
                var floatOutput = [Float]()
                for item in splitOutput {
                    floatOutput.append((item as NSString).floatValue)
                }
                
                self.weights.setValue(floatHidden, forKey: "newHiddenWeightsArray")
                self.weights.setValue(floatOutput, forKey: "newOutputWeightsArray")

//                = [newString componentsSeparatedByString:@","];
//                NSMutableArray* arrayOfNumbers = [NSMutableArray arrayWithCapacity:arrayOfStrings.count];
//                for (NSString* string in arrayOfStrings) {
//                    [arrayOfNumbers addObject:[NSDecimalNumber decimalNumberWithString:string]];
//                }
                self.startTraining()
            }
        })
    }
    
    func startTraining() {
        let ref = FIRDatabase.database().reference()

        // Dispatches training process to background thread
        dispatch_async(self.networkQueue) {
            var epoch = 0
            if (self.weights.valueForKey("newHiddenWeightsArray") != nil) {
                try! self.network.resetWithWeights(self.weights.valueForKey("newHiddenWeightsArray") as! [Float] + (self.weights.valueForKey("newOutputWeightsArray") as! [Float]))
            }
//            print((self.weights.valueForKey("newHiddenWeights") as! [Float])[0])
            while epoch < 100 {
                for index in 0 ..< 1000 {
                    let x = Float(index)
                    try! self.network.update(inputs: [x])
                    let answer : Float = 3*x
                    try! self.network.backpropagate(answer: [answer])
                }
                epoch += 1
            }
            
            ref.child("status\(Int(self.eyedee-1))").setValue("recieveFromClient");
            
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
