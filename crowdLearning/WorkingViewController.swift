//
//  WorkingViewController.swift
//  crowdLearning
//
//  Created by Kevin Fang on 9/10/16.
//  Copyright © 2016 myh1000. All rights reserved.
//

import UIKit
import BAFluidView
import Foundation
import Firebase
import FirebaseDatabase

class WorkingViewController: UIViewController {

    @IBOutlet weak var workingLabel: UILabel!
    var counter = 0
    var eyedee = Int()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let ref = FIRDatabase.database().reference()

        // Do any additional setup after loading the view, typically from a nib.
        
        setUpBackground()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            let myView:BAFluidView = BAFluidView(frame: self.view.frame, startElevation: 0.5)
            
            myView.strokeColor = UIColor.whiteColor()
            myView.fillColor = UIColor(netHex: 0x23B9FF)
            myView.keepStationary()
            myView.startAnimation()
            
            self.containerView.hidden = false
            myView.startAnimation()
            self.view.insertSubview(myView, aboveSubview: self.view)
//            self.view.sendSubviewToBack(myView)
            self.view.bringSubviewToFront(self.workingLabel)
            
            UIView.animateWithDuration(0.5, animations: {
                myView.alpha=1.0
                }, completion: { _ in
                    self.containerView.removeFromSuperview()
                    self.containerView = myView
            })
        }
        print("numberid\(self.eyedee-1)")
        ref.child("working_text\(Int(self.eyedee-1))").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            self.workingLabel.text = snapshot.value as? String
        })
        ref.observeEventType(.ChildChanged, withBlock: { (snapshot) -> Void in
            if (snapshot.key == "request_recieved" && snapshot.value as! String == "false") {
//                self.performSegueWithIdentifier("unwindsmae", sender: self)
                
                let request = NSMutableURLRequest(URL: NSURL(string: "http://47ebd870.ngrok.io/servant_disconnect")!)
                
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
            else if (snapshot.key == "working_tex\(Int(self.eyedee-1))t") {
                self.workingLabel.text = snapshot.value as? String
            }
            else if(snapshot.key == "iters")
            {
                if(snapshot.value as! Int > 15)
                {
                    print("got into this derp thing");
                    ref.child("request_recieved").setValue("false")
                    self.performSegueWithIdentifier("doneSegue", sender: self)
                }
            }
        })
    }


    
    @IBOutlet weak var containerView: UIView!
    var gradient = CAGradientLayer()
    
    func setUpBackground() {
        
        let tempLayer: CAGradientLayer = CAGradientLayer()
        tempLayer.frame = self.view.bounds
        tempLayer.colors = [UIColor(netHex: 0xFAFF14).CGColor, UIColor(netHex: 0xFAFF14).CGColor, UIColor(netHex: 0xFAFF14).CGColor, UIColor(netHex: 0xFAFF14).CGColor]
        tempLayer.locations = [NSNumber(float: 0.0), NSNumber(float: 0.5), NSNumber(float: 0.8), NSNumber(float: 1.0)]
        tempLayer.startPoint = CGPointMake(0, 0)
        tempLayer.endPoint = CGPointMake(1, 1)
        
        self.gradient = tempLayer
        self.view.layer.insertSublayer(self.gradient, atIndex: 1)
        self.containerView.hidden = true
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}