import UIKit

final class TransactionEditorViewController: UIViewController {
    private let store: FinanceStore
    private var transaction: Transaction?
    private let onSave: (() -> Void)?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let amountField = UITextField()
    private let typeControl = UISegmentedControl(items: TransactionKind.allCases.map(\.title))
    private let categoryButton = UIButton(type: .system)
    private let datePicker = UIDatePicker()
    private var selectedCategory: String

    init(
        store: FinanceStore = .shared,
        transaction: Transaction? = nil,
        preselectedKind: TransactionKind = .expense,
        onSave: (() -> Void)? = nil
    ) {
        self.store = store
        self.transaction = transaction
        self.onSave = onSave
        selectedCategory = transaction?.category ?? store.allCategories[0]
        super.init(nibName: nil, bundle: nil)
        typeControl.selectedSegmentIndex = TransactionKind.allCases.firstIndex(of: transaction?.kind ?? preselectedKind) ?? 0
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = transaction == nil ? "New Transaction" : "Edit Transaction"
        view.backgroundColor = .systemGroupedBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .cancel,
            primaryAction: UIAction { [weak self] _ in self?.dismiss(animated: true) }
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .save,
            primaryAction: UIAction { [weak self] _ in self?.save() }
        )

        configureAmountField()
        configureCategoryButton()
        configureDatePicker()
        configureLayout()

        if let transaction {
            amountField.text = NSDecimalNumber(decimal: transaction.amount).stringValue
            datePicker.date = transaction.date
        }
    }

    private func configureAmountField() {
        amountField.placeholder = "0.00"
        amountField.keyboardType = .decimalPad
        amountField.textAlignment = .right
        amountField.font = .preferredFont(forTextStyle: .title1)
        amountField.adjustsFontForContentSizeCategory = true
        amountField.backgroundColor = .secondarySystemGroupedBackground
        amountField.layer.cornerRadius = 14
        amountField.layer.cornerCurve = .continuous
        amountField.leftView = spacer(width: 16)
        amountField.leftViewMode = .always
        amountField.rightView = spacer(width: 16)
        amountField.rightViewMode = .always
        amountField.heightAnchor.constraint(equalToConstant: 64).isActive = true
        amountField.accessibilityLabel = "Amount"
    }

    private func configureCategoryButton() {
        categoryButton.configuration = .tinted()
        categoryButton.configuration?.cornerStyle = .large
        categoryButton.contentHorizontalAlignment = .leading
        categoryButton.showsMenuAsPrimaryAction = true
        categoryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        refreshCategoryMenu()
    }

    private func configureDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.maximumDate = Date()
    }

    private func configureLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 24, leading: 20, bottom: 32, trailing: 20)

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(section(title: "AMOUNT", content: amountField))
        contentStack.addArrangedSubview(section(title: "TYPE", content: typeControl))
        contentStack.addArrangedSubview(section(title: "CATEGORY", content: categoryButton))
        contentStack.addArrangedSubview(section(title: "DATE", content: datePicker))

        typeControl.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func section(title: String, content: UIView) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [label, content])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }

    private func spacer(width: CGFloat) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 1))
        view.widthAnchor.constraint(equalToConstant: width).isActive = true
        return view
    }

    private func refreshCategoryMenu() {
        categoryButton.configuration?.title = selectedCategory
        categoryButton.configuration?.image = UIImage(systemName: "square.grid.2x2")
        categoryButton.configuration?.imagePadding = 10
        categoryButton.menu = UIMenu(children: store.allCategories.map { category in
            UIAction(
                title: category,
                state: category == selectedCategory ? .on : .off
            ) { [weak self] _ in
                self?.selectedCategory = category
                self?.refreshCategoryMenu()
            }
        })
    }

    private func save() {
        guard let amount = MoneyInput.decimal(from: amountField.text), amount > 0 else {
            presentMessage(title: "Invalid amount", message: "Enter an amount greater than zero.")
            return
        }

        let kind = TransactionKind.allCases[typeControl.selectedSegmentIndex]
        if var transaction {
            transaction.amount = amount
            transaction.kind = kind
            transaction.category = selectedCategory
            transaction.date = datePicker.date
            store.update(transaction)
        } else {
            store.add(Transaction(amount: amount, kind: kind, category: selectedCategory, date: datePicker.date))
        }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onSave?()
        dismiss(animated: true)
    }
}

extension UIViewController {
    func presentMessage(title: String, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
