//
//  ThirdViewController.swift
//  Assignment-05-02
//
//  Created by Philip Dow on 9/10/15.
//  Copyright (c) 2015 Phil Dow. All rights reserved.
//

import UIKit

protocol ThirdViewControllerDelegate {
    func thirdViewControllerDidFinish(aController: ThirdViewController)
}

class ThirdViewController: UIViewController {

    var delegate: ThirdViewControllerDelegate?

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func done(sender: AnyObject) {
        if let del = delegate {
            del.thirdViewControllerDidFinish(self)
        }
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
