//
//  ViewController.swift
//  FinTrack
//
//  Created by Ihor Melashchenko on 8/27/21.
//

import UIKit

class MainViewController: UIViewController {
    
    // Outlets
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var currentBalance: UILabel!
    @IBOutlet var lastTransactionDate: UILabel!
    @IBOutlet var categorySelection: UIPickerView!
    // Current selected Categroy in UIPickerView
    var selectedCategory: String = "Food"
    @IBOutlet var selCate: UILabel!
    @IBOutlet var newExpenseButtonOutlet: UIButton!
    @IBOutlet var newIncomeButtonOutlet: UIButton!
    @IBOutlet var customButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dismiss keyboard on tap (tap outside the keyboard)
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        categorySelection.dataSource = self
        categorySelection.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        newExpenseButtonOutlet.layer.cornerRadius = 10
        newExpenseButtonOutlet.clipsToBounds = true
        newIncomeButtonOutlet.layer.cornerRadius = 10
        newIncomeButtonOutlet.clipsToBounds = true
        customButtonOutlet.layer.cornerRadius = 10
        customButtonOutlet.clipsToBounds = true
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // Get current date and time
    func getDate() -> String {
        // get the current date and time
        let currentDate = Date()
        // initialize the date formatter and
        let formatter = DateFormatter()
        // set the style
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        // return the date time String from the date object
        return formatter.string(from: currentDate)
    }
    
    @IBAction func newExpenseButton(_ sender: Any) {
        // Output an alert if Text Field is empty
        if (amountTextField.text?.isEmpty == true || amountTextField.text == "0") {
            let alert = UIAlertController(title: "Amount error!", message: "Amount can't be 0 or empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        let transactionDate = getDate()
        let newTransaction = Transaction(category: selectedCategory, amount: "-" + amountTextField.text!, option: .expense, date: transactionDate)
        
        // Add date to lastTransactionDate
        lastTransactionDate.text = transactionDate
        
        //tabBarController?.selectedIndex = 0 // opens first tab  USE THIS!! ADD THIS TO SETTINGS AS A CHOICE
        newTransactionGlobal = newTransaction
    }
    
    @IBAction func newIncomeButton(_ sender: Any)  {
        // Output an alert if Text Field is empty
        if (amountTextField.text?.isEmpty == true || amountTextField.text == "0") {
            let alert = UIAlertController(title: "Amount error!", message: "Amount can't be 0 or empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        let transactionDate = getDate()
        let newTransaction = Transaction(category: selectedCategory, amount: "+" + amountTextField.text!, option: .expense, date: transactionDate)
        lastTransactionDate.text = transactionDate
        
        newTransactionGlobal = newTransaction
        
        //addTransactionToLog()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO
    }
}

extension MainViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return transactionCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = transactionCategories[row]
        selCate.text = transactionCategories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return transactionCategories[row]
    }
}
