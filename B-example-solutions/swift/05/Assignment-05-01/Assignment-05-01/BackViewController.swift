//
//  BackViewController.swift
//  Assignment-05-01
//
//  Created by Philip Dow on 9/10/15.
//  Copyright (c) 2015 Phil Dow. All rights reserved.
//

import UIKit

protocol BackViewControllerDelegate {
    func backViewControllerDidFinish(aController: BackViewController)
}

class BackViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    // @IBOutlet marks the property as a storyboard outlet
    // weak marks the property weak for automatic reference counting (ARC)
    
    // var is used because this is not a constant.
    // at init it's value will be nil, but by viewDidLoad it's value will be set
    
    // ! is used with the type to indicate it is implicity unwrapped.
    // This is necessary because the variable has no value at init, which means it can be nil
    // Normally those kinds of variables are marked as optional with a ?
    // But we know the outlet will be set by the time it is used, and the ! makes it so that
    // we don't have to keep unwrapping an optional
    
    var delegate: BackViewControllerDelegate?

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
        
        // I'm shadowing the optional here, which I think is the correct idiom
        
        if let delegate = delegate {
            delegate.backViewControllerDidFinish(self)
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

// MARK: - Text Field Delegae

extension BackViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == nameField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}