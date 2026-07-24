import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet var languageSelection: UIPickerView!
    @IBOutlet var currencySelection: UIPickerView!
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
        super.viewWillAppear(animated)

        [restoreLogOutlet, restorePurchasesOutlet].forEach {
            $0?.layer.cornerRadius = 10
            $0?.clipsToBounds = true
        }
    }

    @IBAction func unwindToSettingsViewController(segue: UIStoryboardSegue) {}
}

extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerView == currencySelection
            ? Settings.currencies.count
            : Settings.languages.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerView == languageSelection
            ? Settings.languages[row]
            : Settings.currencies[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == languageSelection {
            Settings.selectedLanguage = Settings.languages[row]
            selLang.text = Settings.selectedLanguage
        } else {
            Settings.selectedCurrency = Settings.currencies[row]
            selCurr.text = Settings.selectedCurrency
        }
    }
}
