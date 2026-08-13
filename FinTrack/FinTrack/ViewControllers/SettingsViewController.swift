import UIKit

final class SettingsViewController: UITableViewController {
    private enum Section: Int, CaseIterable {
        case preferences
        case data
        case about
    }

    private enum Row: Int {
        case currency
        case appearance
        case categories
        case eraseData
        case about
    }

    private let settings = AppSettings.shared
    private let store = FinanceStore.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"
        tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), selectedImage: UIImage(systemName: "gearshape.fill"))
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 52
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = 44
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DestructiveCell")
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSettings), name: AppSettings.didChangeNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .preferences: "Preferences"
        case .data: "Data"
        case .about: "About"
        case nil: nil
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard Section(rawValue: section) == .data else { return nil }
        return "FinTrack stores your transactions locally on this device."
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .preferences: 2
        case .data: 2
        case .about: 1
        case nil: 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        cell.accessoryType = .none
        cell.accessoryView = nil
        cell.selectionStyle = .default

        switch (Section(rawValue: indexPath.section), indexPath.row) {
        case (.preferences, Row.currency.rawValue):
            content.text = "Currency"
            content.secondaryText = settings.currency.title
            content.image = UIImage(systemName: "dollarsign.circle")
            cell.accessoryType = .disclosureIndicator

        case (.preferences, Row.appearance.rawValue):
            content.text = "Appearance"
            content.secondaryText = settings.appearance.title
            content.image = UIImage(systemName: "circle.lefthalf.filled")
            cell.accessoryType = .disclosureIndicator

        case (.data, Row.categories.rawValue - 2):
            content.text = "Categories"
            content.secondaryText = "\(store.customCategories.count) custom"
            content.image = UIImage(systemName: "square.grid.2x2")
            cell.accessoryType = .disclosureIndicator

        case (.data, Row.eraseData.rawValue - 2):
            content.text = "Erase All Data"
            content.textProperties.color = .systemRed
            content.image = UIImage(systemName: "trash")
            content.imageProperties.tintColor = .systemRed

        case (.about, 0):
            content.text = "About FinTrack"
            content.secondaryText = "Version 1.0"
            content.image = UIImage(systemName: "info.circle")
            cell.accessoryType = .disclosureIndicator

        default:
            break
        }

        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch (Section(rawValue: indexPath.section), indexPath.row) {
        case (.preferences, 0):
            presentCurrencyOptions(sourceView: tableView.cellForRow(at: indexPath))
        case (.preferences, 1):
            presentAppearanceOptions(sourceView: tableView.cellForRow(at: indexPath))
        case (.data, 0):
            let controller = CustomCategoryManagerViewController(style: .insetGrouped)
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
        case (.data, 1):
            confirmEraseData()
        case (.about, 0):
            let controller = AboutViewController()
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
        default:
            break
        }
    }

    private func presentCurrencyOptions(sourceView: UIView?) {
        let alert = UIAlertController(title: "Currency", message: nil, preferredStyle: .actionSheet)
        CurrencyOption.allCases.forEach { option in
            let title = option == settings.currency ? "✓ \(option.title)" : option.title
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.settings.currency = option
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        configurePopover(alert, sourceView: sourceView)
        present(alert, animated: true)
    }

    private func presentAppearanceOptions(sourceView: UIView?) {
        let alert = UIAlertController(title: "Appearance", message: nil, preferredStyle: .actionSheet)
        AppearanceOption.allCases.forEach { option in
            let title = option == settings.appearance ? "✓ \(option.title)" : option.title
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.settings.appearance = option
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        configurePopover(alert, sourceView: sourceView)
        present(alert, animated: true)
    }

    private func configurePopover(_ alert: UIAlertController, sourceView: UIView?) {
        alert.popoverPresentationController?.sourceView = sourceView ?? view
        alert.popoverPresentationController?.sourceRect = sourceView?.bounds ?? view.bounds
    }

    private func confirmEraseData() {
        let alert = UIAlertController(
            title: "Erase all FinTrack data?",
            message: "This removes every transaction and custom category. Your currency and appearance preferences stay unchanged.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Erase All Data", style: .destructive) { [weak self] _ in
            self?.store.resetAllData()
            self?.tableView.reloadData()
        })
        present(alert, animated: true)
    }

    @objc private func reloadSettings() {
        tableView.reloadData()
    }
}

final class AboutViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "About"
        view.backgroundColor = .systemGroupedBackground

        let imageView = UIImageView(image: UIImage(named: "BrandMark"))
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 24
        imageView.layer.cornerCurve = .continuous
        imageView.clipsToBounds = true
        imageView.widthAnchor.constraint(equalToConstant: 112).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true

        let titleLabel = UILabel()
        titleLabel.text = "FinTrack"
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.textAlignment = .center

        let bodyLabel = UILabel()
        bodyLabel.text = "A simple, private way to keep track of everyday income and expenses. Your data stays on this device."
        bodyLabel.font = .preferredFont(forTextStyle: .body)
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.numberOfLines = 0
        bodyLabel.textAlignment = .center

        let creatorLabel = UILabel()
        creatorLabel.text = "Created by Ihor Melashchenko"
        creatorLabel.font = .preferredFont(forTextStyle: .footnote)
        creatorLabel.textColor = .tertiaryLabel
        creatorLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, bodyLabel, creatorLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.setCustomSpacing(24, after: imageView)

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -12)
        ])
    }
}
