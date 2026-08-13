import UIKit

final class StatsViewController: UIViewController {
    private let store = FinanceStore.shared
    private let settings = AppSettings.shared
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let emptyView: UIContentUnavailableView = {
        var configuration = UIContentUnavailableConfiguration.empty()
        configuration.text = "No transactions yet"
        configuration.secondaryText = "Transactions you add from Overview will appear here."
        configuration.image = UIImage(systemName: "list.bullet.rectangle")
        return UIContentUnavailableView(configuration: configuration)
    }()
    private var displayedTransactions: [Transaction] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Activity"
        tabBarItem = UITabBarItem(title: "Activity", image: UIImage(systemName: "list.bullet.rectangle"), selectedImage: UIImage(systemName: "list.bullet.rectangle.fill"))
        view.backgroundColor = .systemGroupedBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(confirmClear)
        )

        configureTable()
        configureNotifications()
        refresh()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func configureTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TransactionCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: FinanceStore.didChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: AppSettings.didChangeNotification, object: nil)
    }

    @objc private func refresh() {
        displayedTransactions = store.transactions.sorted { lhs, rhs in
            if Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date) {
                return lhs.id.uuidString > rhs.id.uuidString
            }
            return lhs.date > rhs.date
        }
        tableView.reloadData()
        tableView.backgroundView = displayedTransactions.isEmpty ? emptyView : nil
        navigationItem.rightBarButtonItem?.isEnabled = !displayedTransactions.isEmpty
    }

    @objc private func confirmClear() {
        let alert = UIAlertController(
            title: "Clear all transactions?",
            message: "This removes the complete transaction history and cannot be undone.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive) { [weak self] _ in
            self?.store.clearTransactions()
        })
        present(alert, animated: true)
    }

    private func edit(_ transaction: Transaction) {
        let editor = TransactionEditorViewController(transaction: transaction)
        present(UINavigationController(rootViewController: editor), animated: true)
    }
}

extension StatsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedTransactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let transaction = displayedTransactions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = transaction.category
        content.secondaryText = transaction.date.formatted(date: .abbreviated, time: .omitted)
        content.image = UIImage(systemName: transaction.kind == .income ? "arrow.down.left.circle.fill" : "arrow.up.right.circle.fill")
        content.imageProperties.tintColor = transaction.kind == .income ? AppTheme.incomeText : .systemOrange
        content.secondaryTextProperties.color = .secondaryLabel

        let amount = settings.formatMoney(transaction.signedAmount, showSign: true)
        let amountLabel = UILabel()
        amountLabel.text = amount
        amountLabel.font = .preferredFont(forTextStyle: .headline)
        amountLabel.textColor = transaction.kind == .income ? AppTheme.incomeText : .label
        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.minimumScaleFactor = 0.8
        amountLabel.sizeToFit()

        cell.contentConfiguration = content
        cell.accessoryView = amountLabel
        cell.accessoryType = .none
        cell.accessibilityLabel = "\(transaction.kind.title), \(transaction.category), \(amount), \(content.secondaryText ?? "")"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        edit(displayedTransactions[indexPath.row])
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let transaction = displayedTransactions[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.store.delete(id: transaction.id)
            completion(true)
        }
        delete.image = UIImage(systemName: "trash")

        let edit = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completion in
            self?.edit(transaction)
            completion(true)
        }
        edit.image = UIImage(systemName: "pencil")
        edit.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
}
