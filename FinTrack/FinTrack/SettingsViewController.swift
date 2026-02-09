//
//  SettingsViewController.swift
//  FinTrack
//
//  Created by Ihor Melashchenko on 9/4/21.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // Outlets
    @IBOutlet var languageSelection: UIPickerView!
    let languages = ["English", "Русский", "Українська"]
    var selectedLanguage: String = ""
    @IBOutlet var currencySelection: UIPickerView!
    let currencies = ["(USD) US dollar", "(EUR) Euro", "(UAH) Ukrainian hryvnia", "(RUB) Russian ruble"]
    var selectedCurrency: String = ""
    @IBOutlet var selLang: UILabel!
    @IBOutlet var selCurr: UILabel!
    @IBOutlet var restoreLogOutlet: UIButton!
    @IBOutlet var restorePurchasesOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        languageSelection.dataSource = self
        languageSelection.delegate = self
        
        currencySelection.dataSource = self
        currencySelection.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        restoreLogOutlet.layer.cornerRadius = 10
        restoreLogOutlet.clipsToBounds = true
        restorePurchasesOutlet.layer.cornerRadius = 10
        restorePurchasesOutlet.clipsToBounds = true
    }
}

extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var countrows : Int = languages.count
        
        if pickerView == currencySelection {
            countrows = self.currencies.count
        }
        
        return countrows
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == languageSelection {
            let titleRow = languages[row]
            return titleRow
        } else if pickerView == currencySelection {
            let titleRow = currencies[row]
            return titleRow
        }
        
        return ""
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == languageSelection {
            self.selectedLanguage = self.languages[row]
            self.selLang.text = self.languages[row]
        } else if pickerView == currencySelection {
            self.selectedCurrency = self.currencies[row]
            self.selCurr.text = self.currencies[row]
        }
    }
}
