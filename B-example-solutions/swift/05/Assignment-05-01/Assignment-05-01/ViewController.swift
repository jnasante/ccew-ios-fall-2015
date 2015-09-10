//
//  ViewController.swift
//  Assignment-05-01
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
        
        if ( segue.identifier == "ShowBackside" ) {
            let backsideController = segue.destinationViewController as! BackViewController
            backsideController.delegate = self
        }
    }
}

// MARK: - Back View Controller Delegate

extension ViewController: BackViewControllerDelegate {
    
    func backViewControllerDidFinish(aController: BackViewController) {
        
        let name = aController.nameField.text
        let password = aController.passwordField.text
        
        NSLog("The name is %@ and the password is %@", name, password)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
