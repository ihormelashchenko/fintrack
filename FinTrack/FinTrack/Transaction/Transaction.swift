import Foundation

final class Transaction {
    static var categories = [
        "Food",
        "Health",
        "Bills",
        "Transport",
        "Pets",
        "Gifts",
        "Delivery",
        "Eating out",
        "Sports",
        "Entertainment",
        "Taxi",
        "Clothes"
    ]
    static var latest: Transaction?

    let category: String
    let amount: String
    let option: TransactionOption
    let date: String

    init(category: String, amount: String, option: TransactionOption, date: String) {
        self.category = category
        self.amount = amount
        self.option = option
        self.date = date
    }

    static func getDate() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        return formatter.string(from: Date())
    }
}

enum TransactionOption {
    case income
    case expense
}
