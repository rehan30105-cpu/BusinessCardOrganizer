import XCTest

final class BusinessCardOrganizerUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify that the launch screen elements appear
        XCTAssertTrue(app.staticTexts["Business"].waitForExistence(timeout: 5.0))
        XCTAssertTrue(app.staticTexts["Organizer"].exists)
    }
}
