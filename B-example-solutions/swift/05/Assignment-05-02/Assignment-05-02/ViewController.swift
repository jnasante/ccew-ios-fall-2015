//
//  ViewController.swift
//  Assignment-05-02
//
//  Created by Philip Dow on 9/10/15.
//  Copyright (c) 2015 Phil Dow. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        // Try switching on a string (more generally pattern matching with guards)
        // https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Statements.html
        
        // Notice that we need to unwrap the identifier first with the let statement
        
        if let identifier = segue.identifier {
            switch identifier {
            case "ShowBackside":
                let backsideController = segue.destinationViewController as! BackViewController
                backsideController.delegate = self
            case "ShowThird":
                let thirdController = segue.destinationViewController as! ThirdViewController
                thirdController.delegate = self
            default:
                break
            }
        }
    }
}

// MARK: - Back View Controller Delegate

extension ViewController: BackViewControllerDelegate {
    
    func backViewControllerDidFinish(aController: BackViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - Third View Controller Delegate

extension ViewController: ThirdViewControllerDelegate {
    
    func thirdViewControllerDidFinish(aController: ThirdViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

