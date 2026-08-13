import XCTest

final class FinTrackUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITestReset"]
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testAddPersistEditAndDeleteTransaction() {
        app.buttons["Add Income"].tap()

        let amountField = app.textFields["Amount"]
        XCTAssertTrue(amountField.waitForExistence(timeout: 2))
        capture("transaction-editor")
        amountField.tap()
        amountField.typeText("125.50")
        app.navigationBars.buttons["Save"].tap()

        let balance = app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS %@", "$125.50"))
            .firstMatch
        XCTAssertTrue(balance.waitForExistence(timeout: 5))

        app.terminate()
        app.launchArguments = []
        app.launch()
        XCTAssertTrue(balance.waitForExistence(timeout: 5))
        capture("overview-with-data")

        app.tabBars.buttons["Activity"].tap()
        let foodCell = app.cells.containing(.staticText, identifier: "Food").element
        XCTAssertTrue(foodCell.waitForExistence(timeout: 2))
        foodCell.tap()

        let editAmountField = app.textFields["Amount"]
        XCTAssertTrue(editAmountField.waitForExistence(timeout: 2))
        editAmountField.tap()
        editAmountField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        editAmountField.typeText("100")
        app.navigationBars.buttons["Save"].tap()

        let updatedCell = app.cells.containing(.staticText, identifier: "Food").element
        XCTAssertTrue(updatedCell.waitForExistence(timeout: 5))
        XCTAssertTrue(updatedCell.label.contains("+$100.00"))
        XCTAssertTrue(app.tabBars.buttons["Settings"].waitForExistence(timeout: 5))
        capture("activity-with-data")

        updatedCell.swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssertTrue(app.staticTexts["No transactions yet"].waitForExistence(timeout: 2))
    }

    func testSettingsAndCustomCategoriesAreUsable() {
        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Currency"].exists)
        XCTAssertTrue(app.staticTexts["Appearance"].exists)
        capture("settings")

        let appearanceCell = app.cells.containing(.staticText, identifier: "Appearance").element
        appearanceCell.tap()
        app.sheets["Appearance"].buttons["Dark"].tap()
        XCTAssertTrue(app.staticTexts["Dark"].waitForExistence(timeout: 2))
        capture("settings-dark")

        app.cells.containing(.staticText, identifier: "Appearance").element.tap()
        app.sheets["Appearance"].buttons["System"].tap()

        app.cells.containing(.staticText, identifier: "Categories").element.tap()
        XCTAssertTrue(app.navigationBars["Categories"].waitForExistence(timeout: 2))
        app.navigationBars.buttons["Add"].tap()

        let categoryField = app.alerts.textFields["Category name"]
        XCTAssertTrue(categoryField.waitForExistence(timeout: 2))
        categoryField.typeText("Education")
        app.alerts.buttons["Add"].tap()

        XCTAssertTrue(app.staticTexts["Education"].waitForExistence(timeout: 2))
        capture("custom-categories")
    }
}
