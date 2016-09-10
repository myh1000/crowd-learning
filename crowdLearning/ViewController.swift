//
//  ViewController.swift
//  crowdLearning
//
//  Created by family on 9/9/16.
//  Copyright © 2016 myh1000. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    /// The number of points to plot on screen
    var numPoints = 0
    /// Serial queue for synchronizing access to neural network from multiple threads
    private let networkQueue = dispatch_queue_create("com.SwiftAI.networkQueue", DISPATCH_QUEUE_SERIAL)
    private var network: FFNN!
    private let filePath = NSHomeDirectory() + "/Library/Caches/test.txt"
    @IBOutlet weak var joinButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        joinButton.layer.cornerRadius = 5;
        // Do any additional setup after loading the view, typically from a nib.
        let ref = FIRDatabase.database().reference()
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
            print(snapshot)
        })
        network = FFNN(inputs: 100, hidden: 64, outputs: 10,
                   learningRate: 0.7, momentum: 0.4, weights: nil,
                   activationFunction : .Sigmoid, errorFunction: .CrossEntropy(average: false))
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

