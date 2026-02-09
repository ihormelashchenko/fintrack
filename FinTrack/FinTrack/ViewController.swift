//
//  ViewController.swift
//  FinTrack
//
//  Created by Ihor Melashchenko on 8/27/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var amountTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
              
        //Looks for single or multiple taps.
         let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
    }

    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func newExpenseButton(_ sender: Any) {
    }
    
    @IBAction func newIncomeButton(_ sender: Any) {
    }
}

