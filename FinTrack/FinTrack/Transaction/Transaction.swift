import Foundation

enum TransactionKind: String, Codable, CaseIterable {
    case income
    case expense

    var title: String {
        switch self {
        case .income: "Income"
        case .expense: "Expense"
        }
    }

    var signedMultiplier: Decimal {
        self == .income ? 1 : -1
    }
}

struct Transaction: Codable, Equatable, Identifiable {
    let id: UUID
    var amount: Decimal
    var kind: TransactionKind
    var category: String
    var date: Date

    init(
        id: UUID = UUID(),
        amount: Decimal,
        kind: TransactionKind,
        category: String,
        date: Date = Date()
    ) {
        self.id = id
        self.amount = amount
        self.kind = kind
        self.category = category
        self.date = date
    }

    var signedAmount: Decimal {
        amount * kind.signedMultiplier
    }
}

enum MoneyInput {
    static func decimal(from text: String?) -> Decimal? {
        guard let text else { return nil }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        formatter.generatesDecimalNumbers = true

        if let number = formatter.number(from: trimmed) as? NSDecimalNumber {
            return number.decimalValue
        }

        let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
        return Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX"))
    }
}

enum CategoryError: LocalizedError {
    case empty
    case duplicate
    case builtIn
    case missing

    var errorDescription: String? {
        switch self {
        case .empty:
            "Enter a category name."
        case .duplicate:
            "That category already exists."
        case .builtIn:
            "Built-in categories cannot be removed."
        case .missing:
            "That category is no longer available."
        }
    }
}

final class FinanceStore {
    static let shared = FinanceStore()
    static let didChangeNotification = Notification.Name("FinanceStoreDidChange")

    static let defaultCategories = [
        "Food",
        "Bills",
        "Transport",
        "Health",
        "Shopping",
        "Dining",
        "Entertainment",
        "Travel",
        "Salary",
        "Other"
    ]

    private let defaults: UserDefaults
    private let transactionsKey: String
    private let categoriesKey: String

    private(set) var transactions: [Transaction]
    private(set) var customCategories: [String]

    init(defaults: UserDefaults = .standard, namespace: String = "fintrack") {
        self.defaults = defaults
        transactionsKey = "\(namespace).transactions.v1"
        categoriesKey = "\(namespace).customCategories.v1"

        if
            let data = defaults.data(forKey: transactionsKey),
            let decoded = try? JSONDecoder().decode([Transaction].self, from: data)
        {
            transactions = decoded
        } else {
            transactions = []
        }

        customCategories = defaults.stringArray(forKey: categoriesKey) ?? []
    }

    var allCategories: [String] {
        Self.defaultCategories + customCategories
    }

    var balance: Decimal {
        transactions.reduce(0) { $0 + $1.signedAmount }
    }

    var totalIncome: Decimal {
        transactions
            .filter { $0.kind == .income }
            .reduce(0) { $0 + $1.amount }
    }

    var totalExpenses: Decimal {
        transactions
            .filter { $0.kind == .expense }
            .reduce(0) { $0 + $1.amount }
    }

    var latestTransaction: Transaction? {
        transactions.max { $0.date < $1.date }
    }

    func add(_ transaction: Transaction) {
        transactions.append(transaction)
        persistAndNotify()
    }

    func update(_ transaction: Transaction) {
        guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else {
            return
        }

        transactions[index] = transaction
        persistAndNotify()
    }

    func delete(id: UUID) {
        transactions.removeAll { $0.id == id }
        persistAndNotify()
    }

    func clearTransactions() {
        transactions.removeAll()
        persistAndNotify()
    }

    func resetAllData() {
        transactions.removeAll()
        customCategories.removeAll()
        persistAndNotify()
    }

    func addCategory(_ name: String) throws {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw CategoryError.empty }
        guard !allCategories.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) else {
            throw CategoryError.duplicate
        }

        customCategories.append(trimmed)
        customCategories.sort { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        persistAndNotify()
    }

    func deleteCategory(_ name: String) throws {
        guard !Self.defaultCategories.contains(name) else { throw CategoryError.builtIn }
        guard let index = customCategories.firstIndex(of: name) else { throw CategoryError.missing }

        customCategories.remove(at: index)
        persistAndNotify()
    }

    private func persistAndNotify() {
        if let data = try? JSONEncoder().encode(transactions) {
            defaults.set(data, forKey: transactionsKey)
        }
        defaults.set(customCategories, forKey: categoriesKey)
        NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
    }
}
