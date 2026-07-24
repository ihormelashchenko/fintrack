import UIKit

class MainViewController: UIViewController {

    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var currentBalance: UILabel!
    @IBOutlet var lastTransactionDate: UILabel!
    @IBOutlet var categorySelection: UIPickerView!
    @IBOutlet var selCate: UILabel!
    @IBOutlet var newExpenseButtonOutlet: UIButton!
    @IBOutlet var newIncomeButtonOutlet: UIButton!
    @IBOutlet var customButtonOutlet: UIButton!

    var selectedCategory = Transaction.categories[0]

    override func viewDidLoad() {
        super.viewDidLoad()

        [newExpenseButtonOutlet, newIncomeButtonOutlet, customButtonOutlet].forEach {
            $0?.layer.cornerRadius = 10
            $0?.clipsToBounds = true
        }

        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        categorySelection.dataSource = self
        categorySelection.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !Transaction.categories.contains(selectedCategory) {
            selectedCategory = Transaction.categories[0]
            selCate.text = selectedCategory
        }
        categorySelection.reloadAllComponents()
    }

    @IBAction func newExpenseButton(_ sender: Any) {
        recordTransaction(option: .expense)
    }

    @IBAction func newIncomeButton(_ sender: Any) {
        recordTransaction(option: .income)
    }

    @IBAction func unwindToMainViewController(segue: UIStoryboardSegue) {
        categorySelection.reloadAllComponents()
    }

    private func recordTransaction(option: TransactionOption) {
        guard
            let amountText = amountTextField.text,
            let amount = Double(amountText),
            amount > 0
        else {
            let alert = UIAlertController(
                title: "Invalid amount",
                message: "Enter a number greater than zero.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let currentAmount = Double(currentBalance.text ?? "") ?? 0
        let signedAmount: Double

        switch option {
        case .income:
            signedAmount = amount
        case .expense:
            signedAmount = -amount
        }

        let transactionDate = Transaction.getDate()
        Transaction.latest = Transaction(
            category: selectedCategory,
            amount: String(signedAmount),
            option: option,
            date: transactionDate
        )

        currentBalance.text = String(currentAmount + signedAmount)
        lastTransactionDate.text = transactionDate
        amountTextField.text = ""
    }
}

extension MainViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        Transaction.categories.count
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = Transaction.categories[row]
        selCate.text = selectedCategory
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        Transaction.categories[row]
    }
}
