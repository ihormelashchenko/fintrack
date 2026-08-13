import UIKit

final class MainViewController: UIViewController {
    private let store = FinanceStore.shared
    private let settings = AppSettings.shared

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let balanceLabel = UILabel()
    private let lastUpdatedLabel = UILabel()
    private let incomeValueLabel = UILabel()
    private let expenseValueLabel = UILabel()
    private let totalsStack = UIStackView()
    private let actionsStack = UIStackView()
    private let recentStack = UIStackView()
    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Overview"
        tabBarItem = UITabBarItem(title: "Overview", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        view.backgroundColor = .systemGroupedBackground

        configureLayout()
        configureNotifications()
        updateAdaptiveLayout()
        refresh()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func configureLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 22
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 18, leading: 20, bottom: 32, trailing: 20)

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(makeBalanceCard())
        contentStack.addArrangedSubview(makeTotalsRow())
        contentStack.addArrangedSubview(makeActionsRow())
        contentStack.addArrangedSubview(makeRecentSection())

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

    private func makeBalanceCard() -> UIView {
        let eyebrow = UILabel()
        eyebrow.text = "CURRENT BALANCE"
        eyebrow.textColor = .secondaryLabel
        eyebrow.font = .preferredFont(forTextStyle: .caption1)

        balanceLabel.font = UIFontMetrics(forTextStyle: .largeTitle)
            .scaledFont(for: .systemFont(ofSize: 44, weight: .bold))
        balanceLabel.adjustsFontForContentSizeCategory = true
        balanceLabel.adjustsFontSizeToFitWidth = true
        balanceLabel.minimumScaleFactor = 0.65
        balanceLabel.accessibilityTraits = .updatesFrequently

        lastUpdatedLabel.font = .preferredFont(forTextStyle: .subheadline)
        lastUpdatedLabel.textColor = .secondaryLabel
        lastUpdatedLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [eyebrow, balanceLabel, lastUpdatedLabel])
        stack.axis = .vertical
        stack.spacing = 6

        return card(containing: stack, backgroundColor: .secondarySystemGroupedBackground)
    }

    private func makeTotalsRow() -> UIView {
        let incomeCard = metricCard(title: "Income", value: incomeValueLabel, symbol: "arrow.down.left", color: AppTheme.incomeText)
        let expenseCard = metricCard(title: "Expenses", value: expenseValueLabel, symbol: "arrow.up.right", color: .systemOrange)
        totalsStack.addArrangedSubview(incomeCard)
        totalsStack.addArrangedSubview(expenseCard)
        totalsStack.distribution = .fillEqually
        totalsStack.spacing = 12
        return totalsStack
    }

    private func metricCard(title: String, value: UILabel, symbol: String, color: UIColor) -> UIView {
        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.tintColor = color
        icon.setContentHuggingPriority(.required, for: .horizontal)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .subheadline)
        titleLabel.textColor = .secondaryLabel
        titleLabel.numberOfLines = 0

        let titleStack = UIStackView(arrangedSubviews: [icon, titleLabel])
        titleStack.spacing = 6

        value.font = .preferredFont(forTextStyle: .headline)
        value.adjustsFontSizeToFitWidth = true

        let stack = UIStackView(arrangedSubviews: [titleStack, value])
        stack.axis = .vertical
        stack.spacing = 10
        return card(containing: stack, backgroundColor: .secondarySystemGroupedBackground)
    }

    private func makeActionsRow() -> UIView {
        let expense = actionButton(title: "Add Expense", symbol: "minus", color: .systemOrange, kind: .expense)
        let income = actionButton(title: "Add Income", symbol: "plus", color: AppTheme.incomeAccent, kind: .income)
        actionsStack.addArrangedSubview(expense)
        actionsStack.addArrangedSubview(income)
        actionsStack.distribution = .fillEqually
        actionsStack.spacing = 12
        return actionsStack
    }

    private func actionButton(title: String, symbol: String, color: UIColor, kind: TransactionKind) -> UIButton {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.prominentGlass()
        configuration.title = title
        configuration.image = UIImage(systemName: symbol)
        configuration.imagePadding = 8
        configuration.cornerStyle = .large
        configuration.baseForegroundColor = .black
        button.configuration = configuration
        button.tintColor = color
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 54).isActive = true
        button.addAction(UIAction { [weak self] _ in self?.presentEditor(kind: kind) }, for: .touchUpInside)
        return button
    }

    private func makeRecentSection() -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = "Recent activity"
        titleLabel.font = .preferredFont(forTextStyle: .title3)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)

        emptyLabel.text = "Your latest transactions will appear here."
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center

        recentStack.axis = .vertical
        recentStack.spacing = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, recentStack, emptyLabel])
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }

    private func card(containing content: UIView, backgroundColor: UIColor) -> UIView {
        let card = UIView()
        card.backgroundColor = backgroundColor
        card.layer.cornerRadius = 24
        card.layer.cornerCurve = .continuous
        card.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            content.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])
        return card
    }

    private func configureNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: FinanceStore.didChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: AppSettings.didChangeNotification, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAdaptiveLayout),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
    }

    @objc private func updateAdaptiveLayout() {
        let usesAccessibleText = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        totalsStack.axis = usesAccessibleText ? .vertical : .horizontal
        actionsStack.axis = usesAccessibleText ? .vertical : .horizontal
    }

    @objc private func refresh() {
        balanceLabel.text = settings.formatMoney(store.balance)
        incomeValueLabel.text = settings.formatMoney(store.totalIncome)
        expenseValueLabel.text = settings.formatMoney(store.totalExpenses)
        balanceLabel.accessibilityLabel = "Current balance, \(balanceLabel.text ?? "")"
        incomeValueLabel.accessibilityLabel = "Total income, \(incomeValueLabel.text ?? "")"
        expenseValueLabel.accessibilityLabel = "Total expenses, \(expenseValueLabel.text ?? "")"

        if let latest = store.latestTransaction {
            let date = latest.date.formatted(date: .abbreviated, time: .omitted)
            lastUpdatedLabel.text = "Latest transaction · \(date)"
        } else {
            lastUpdatedLabel.text = "Add your first transaction to get started."
        }

        recentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let recent = store.transactions.sorted { $0.date > $1.date }.prefix(3)
        emptyLabel.isHidden = !recent.isEmpty

        for (index, transaction) in recent.enumerated() {
            if index > 0 {
                let divider = UIView()
                divider.backgroundColor = .separator
                divider.heightAnchor.constraint(equalToConstant: 1 / traitCollection.displayScale).isActive = true
                recentStack.addArrangedSubview(divider)
            }
            recentStack.addArrangedSubview(makeRecentRow(transaction))
        }
    }

    private func makeRecentRow(_ transaction: Transaction) -> UIView {
        let symbol = UIImageView(image: UIImage(systemName: transaction.kind == .income ? "arrow.down.left.circle.fill" : "arrow.up.right.circle.fill"))
        symbol.tintColor = transaction.kind == .income ? AppTheme.incomeText : .systemOrange
        symbol.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 27)
        symbol.setContentHuggingPriority(.required, for: .horizontal)

        let titleLabel = UILabel()
        titleLabel.text = transaction.category
        titleLabel.font = .preferredFont(forTextStyle: .body)

        let dateLabel = UILabel()
        dateLabel.text = transaction.date.formatted(date: .abbreviated, time: .omitted)
        dateLabel.font = .preferredFont(forTextStyle: .caption1)
        dateLabel.textColor = .secondaryLabel

        let labels = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        labels.axis = .vertical

        let amountLabel = UILabel()
        amountLabel.text = settings.formatMoney(transaction.signedAmount, showSign: true)
        amountLabel.font = .preferredFont(forTextStyle: .headline)
        amountLabel.textColor = transaction.kind == .income ? AppTheme.incomeText : .label
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [symbol, labels, amountLabel])
        row.alignment = .center
        row.spacing = 10
        row.isLayoutMarginsRelativeArrangement = true
        row.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)
        row.isAccessibilityElement = true
        row.accessibilityLabel = "\(transaction.kind.title), \(transaction.category), \(amountLabel.text ?? ""), \(dateLabel.text ?? "")"
        return row
    }

    private func presentEditor(kind: TransactionKind) {
        let editor = TransactionEditorViewController(preselectedKind: kind)
        present(UINavigationController(rootViewController: editor), animated: true)
    }
}
