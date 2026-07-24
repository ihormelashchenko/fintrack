import UIKit

class CustomCategoryManagerViewController: UIViewController {

    @IBOutlet var categoryNameTextField: UITextField!
    @IBOutlet var createButton: UIButton!
    @IBOutlet var categorySelector: UIPickerView!
    @IBOutlet var deleteButton: UIButton!

    var selectedCategory = Transaction.categories[0]

    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categorySelector.dataSource = self
        categorySelector.delegate = self
        categorySelector.reloadAllComponents()
    }

    @IBAction func createButtonAction(_ sender: Any) {
        let category = categoryNameTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !category.isEmpty else {
            presentAlert(title: "Category name required")
            return
        }

        guard !Transaction.categories.contains(category) else {
            presentAlert(title: "Category already exists")
            return
        }

        Transaction.categories.append(category)
        selectedCategory = category
        categoryNameTextField.text = ""
        categorySelector.reloadAllComponents()
        categorySelector.selectRow(Transaction.categories.count - 1, inComponent: 0, animated: true)
        presentAlert(title: "Category \"\(category)\" created")
    }

    @IBAction func deleteButtonAction(_ sender: Any) {
        guard Transaction.categories.count > 1 else {
            presentAlert(title: "At least one category is required")
            return
        }

        guard let selectedIndex = Transaction.categories.firstIndex(of: selectedCategory) else {
            return
        }

        let removedCategory = Transaction.categories.remove(at: selectedIndex)
        selectedCategory = Transaction.categories[0]
        categorySelector.reloadAllComponents()
        categorySelector.selectRow(0, inComponent: 0, animated: true)
        presentAlert(title: "Category \"\(removedCategory)\" removed")
    }

    private func presentAlert(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension CustomCategoryManagerViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        Transaction.categories.count
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = Transaction.categories[row]
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        Transaction.categories[row]
    }
}
