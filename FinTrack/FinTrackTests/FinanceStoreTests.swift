import XCTest
@testable import FinTrack

final class FinanceStoreTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "FinTrackTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testTotalsUpdateWhenTransactionsChange() {
        let store = FinanceStore(defaults: defaults, namespace: "test")
        let salary = Transaction(amount: 1200, kind: .income, category: "Salary")
        let groceries = Transaction(amount: 75.50, kind: .expense, category: "Food")

        store.add(salary)
        store.add(groceries)

        XCTAssertEqual(store.totalIncome, 1200)
        XCTAssertEqual(store.totalExpenses, 75.50)
        XCTAssertEqual(store.balance, 1124.50)

        var corrected = groceries
        corrected.amount = 80
        store.update(corrected)
        XCTAssertEqual(store.balance, 1120)

        store.delete(id: salary.id)
        XCTAssertEqual(store.balance, -80)
    }

    func testTransactionsAndCategoriesPersist() throws {
        let namespace = "persistence"
        let firstStore = FinanceStore(defaults: defaults, namespace: namespace)
        firstStore.add(Transaction(amount: 42, kind: .expense, category: "Travel"))
        try firstStore.addCategory("Education")

        let reloadedStore = FinanceStore(defaults: defaults, namespace: namespace)

        XCTAssertEqual(reloadedStore.transactions.count, 1)
        XCTAssertEqual(reloadedStore.transactions[0].amount, 42)
        XCTAssertEqual(reloadedStore.customCategories, ["Education"])
    }

    func testCategoryValidationAndReset() throws {
        let store = FinanceStore(defaults: defaults, namespace: "categories")

        try store.addCategory("Education")
        XCTAssertThrowsError(try store.addCategory("education"))
        XCTAssertThrowsError(try store.deleteCategory("Food"))

        store.add(Transaction(amount: 10, kind: .income, category: "Education"))
        store.resetAllData()

        XCTAssertTrue(store.transactions.isEmpty)
        XCTAssertTrue(store.customCategories.isEmpty)
        XCTAssertEqual(store.allCategories, FinanceStore.defaultCategories)
    }

    func testMoneyInputAcceptsCommonDecimalFormats() {
        XCTAssertEqual(MoneyInput.decimal(from: "12.50"), Decimal(string: "12.50"))
        XCTAssertEqual(MoneyInput.decimal(from: " 9 "), 9)
        XCTAssertNil(MoneyInput.decimal(from: ""))
        XCTAssertNil(MoneyInput.decimal(from: "not money"))
    }
}
