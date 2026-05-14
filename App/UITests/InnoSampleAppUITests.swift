import XCTest

@MainActor
final class InnoSampleAppUITests: XCTestCase {
    func testAppLaunchesAndSupportsCoreFlows() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertEqual(app.state, .runningForeground)
        XCTAssertTrue(element("tab-people", in: app).waitForExistence(timeout: 5))

        tapTab(named: "Posts", in: app)
        XCTAssertTrue(element("tab-posts", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(element("posts-list", in: app).waitForExistence(timeout: 5))

        tapTab(named: "Settings", in: app)
        XCTAssertTrue(element("tab-settings", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(element("settings-list", in: app).waitForExistence(timeout: 5))

        tapTab(named: "People", in: app)
        XCTAssertTrue(element("people-list", in: app).waitForExistence(timeout: 5))

        element("people-row-1", in: app).tap()
        XCTAssertTrue(element("people-detail", in: app).waitForExistence(timeout: 5))
        scrollToElement("people-open-settings", in: element("people-detail", in: app))
        element("people-open-settings", in: app).tap()
        XCTAssertTrue(element("tab-settings", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(element("settings-detail", in: app).waitForExistence(timeout: 5))
        scrollToElement("settings-open-people", in: element("settings-detail", in: app))
        element("settings-open-people", in: app).tap()
        XCTAssertTrue(element("tab-people", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(element("people-detail", in: app).waitForExistence(timeout: 5))

        navigateBack(in: app)
        XCTAssertTrue(element("people-list", in: app).waitForExistence(timeout: 5))

        app.buttons["Overview"].tap()
        XCTAssertTrue(element("people-overview-title", in: app).waitForExistence(timeout: 5))
        app.buttons["Close"].tap()
        XCTAssertFalse(element("people-overview-title", in: app).waitForExistence(timeout: 1))
    }

    private func tapTab(named title: String, in app: XCUIApplication) {
        if app.tabBars.buttons[title].exists {
            app.tabBars.buttons[title].tap()
            return
        }

        if app.buttons[title].exists {
            app.buttons[title].tap()
        }
    }

    private func navigateBack(in app: XCUIApplication) {
        if app.navigationBars.buttons.firstMatch.exists {
            app.navigationBars.buttons.firstMatch.tap()
            return
        }

        if app.buttons.matching(identifier: "Back").firstMatch.exists {
            app.buttons.matching(identifier: "Back").firstMatch.tap()
        }
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    private func scrollToElement(_ identifier: String, in container: XCUIElement, maxSwipes: Int = 6) {
        let target = container.descendants(matching: .any)[identifier]

        for _ in 0..<maxSwipes where !target.exists {
            container.swipeUp()
        }

        XCTAssertTrue(target.waitForExistence(timeout: 5))
    }
}
