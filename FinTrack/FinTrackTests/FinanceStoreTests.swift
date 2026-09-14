import XCTest
import UIKit
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

@MainActor
final class OverviewLayoutTests: XCTestCase {
    func testActionButtonsReflowWhenTextSizeChanges() throws {
        let controller = MainViewController()
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let window = UIWindow(windowScene: scene)
        window.frame = CGRect(x: 0, y: 0, width: 402, height: 874)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        defer { window.isHidden = true }

        func descendants(of view: UIView) -> [UIView] {
            view.subviews.flatMap { [$0] + descendants(of: $0) }
        }
        let buttons = descendants(of: controller.view).compactMap { $0 as? UIButton }
        let expense = try XCTUnwrap(buttons.first { $0.configuration?.title == "Add Expense" })
        let income = try XCTUnwrap(buttons.first { $0.configuration?.title == "Add Income" })

        controller.traitOverrides.preferredContentSizeCategory = .large
        controller.view.layoutIfNeeded()
        let normalExpense = expense.convert(expense.bounds, to: controller.view)
        let normalIncome = income.convert(income.bounds, to: controller.view)
        XCTAssertEqual(normalExpense.minY, normalIncome.minY, accuracy: 1)
        XCTAssertGreaterThan(normalIncome.minX, normalExpense.minX)

        controller.traitOverrides.preferredContentSizeCategory = .accessibilityExtraExtraExtraLarge
        controller.view.layoutIfNeeded()
        let largeExpense = expense.convert(expense.bounds, to: controller.view)
        let largeIncome = income.convert(income.bounds, to: controller.view)
        XCTAssertGreaterThanOrEqual(largeIncome.minY, largeExpense.maxY)
        XCTAssertEqual(largeExpense.minX, largeIncome.minX, accuracy: 1)
        XCTAssertGreaterThan(largeExpense.width, normalExpense.width)

        controller.traitOverrides.preferredContentSizeCategory = .large
        controller.view.layoutIfNeeded()
        XCTAssertEqual(expense.convert(expense.bounds, to: controller.view).minY,
                       income.convert(income.bounds, to: controller.view).minY, accuracy: 1)
    }
}
