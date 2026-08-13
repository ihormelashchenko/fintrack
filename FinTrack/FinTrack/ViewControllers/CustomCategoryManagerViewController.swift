import UIKit

final class CustomCategoryManagerViewController: UITableViewController {
    private let store = FinanceStore.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Categories"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction { [weak self] _ in self?.promptForCategory() }
        )
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadCategories),
            name: FinanceStore.didChangeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Built-in" : "Custom"
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Built-in categories are always available."
        }
        return store.customCategories.isEmpty ? "Tap + to create your own category." : "Swipe a custom category to remove it. Existing transactions keep their original category name."
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? FinanceStore.defaultCategories.count : store.customCategories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = category(at: indexPath)
        content.image = UIImage(systemName: indexPath.section == 0 ? "square.grid.2x2" : "tag.fill")
        content.imageProperties.tintColor = indexPath.section == 0 ? .secondaryLabel : .systemBlue
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard indexPath.section == 1 else { return nil }
        let name = store.customCategories[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            do {
                try self?.store.deleteCategory(name)
                completion(true)
            } catch {
                self?.presentMessage(title: "Couldn’t delete category", message: error.localizedDescription)
                completion(false)
            }
        }
        delete.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [delete])
    }

    private func category(at indexPath: IndexPath) -> String {
        indexPath.section == 0
            ? FinanceStore.defaultCategories[indexPath.row]
            : store.customCategories[indexPath.row]
    }

    @objc private func reloadCategories() {
        tableView.reloadData()
    }

    private func promptForCategory() {
        let alert = UIAlertController(title: "New Category", message: "Give the category a short, clear name.", preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Category name"
            field.autocapitalizationType = .words
            field.returnKeyType = .done
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self, weak alert] _ in
            do {
                try self?.store.addCategory(alert?.textFields?.first?.text ?? "")
            } catch {
                self?.presentMessage(title: "Couldn’t add category", message: error.localizedDescription)
            }
        })
        present(alert, animated: true)
    }
}
