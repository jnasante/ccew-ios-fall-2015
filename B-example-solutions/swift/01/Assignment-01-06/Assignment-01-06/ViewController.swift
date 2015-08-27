//
//  ViewController.swift
//  Assignment-01-06
//
//  Created by Philip Dow on 8/27/15.
//  Copyright (c) 2015 Phil Dow. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        let text = textField.text
        let URL = NSURL(string: text)
        
        if let URLNotNil = URL {
            let request = NSURLRequest(URL: URLNotNil)
            webView.loadRequest(request)
        }
        
        return true
    }
}

