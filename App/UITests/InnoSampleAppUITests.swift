import XCTest

@MainActor
final class InnoSampleAppUITests: XCTestCase {
    func testAppLaunchesAndSupportsCoreFlows() {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()

        XCTAssertEqual(app.state, .runningForeground)
        assertSelectedTab("People", in: app)

        tapTab(named: "Posts", in: app)
        assertSelectedTab("Posts", in: app)
        XCTAssertTrue(element("posts-list", in: app).waitForExistence(timeout: 5))

        tapTab(named: "Settings", in: app)
        assertSelectedTab("Settings", in: app)
        XCTAssertTrue(element("settings-list", in: app).waitForExistence(timeout: 5))

        tapTab(named: "People", in: app)
        XCTAssertTrue(element("people-list", in: app).waitForExistence(timeout: 5))

        element("people-row-1", in: app).tap()
        XCTAssertTrue(element("people-detail", in: app).waitForExistence(timeout: 5))
        scrollToElement("people-open-settings", in: element("people-detail", in: app))
        element("people-open-settings", in: app).tap()
        assertSelectedTab("Settings", in: app)
        XCTAssertTrue(element("settings-detail", in: app).waitForExistence(timeout: 5))
        scrollToElement("settings-open-people", in: element("settings-detail", in: app))
        element("settings-open-people", in: app).tap()
        assertSelectedTab("People", in: app)
        XCTAssertTrue(element("people-detail", in: app).waitForExistence(timeout: 5))

        navigateBack(in: app)
        XCTAssertTrue(element("people-list", in: app).waitForExistence(timeout: 5))

        app.buttons["Overview"].tap()
        XCTAssertTrue(element("people-overview-title", in: app).waitForExistence(timeout: 5))
        app.buttons["Close"].tap()
        XCTAssertFalse(element("people-overview-title", in: app).waitForExistence(timeout: 1))
    }

    func testPostsSplitSelectionAndHighlights() {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        tapTab(named: "Posts", in: app)
        XCTAssertTrue(element("posts-list", in: app).waitForExistence(timeout: 5))

        app.buttons["Highlights"].tap()
        XCTAssertTrue(element("posts-highlights-title", in: app).waitForExistence(timeout: 5))
        app.buttons["Close"].tap()
        XCTAssertTrue(element("posts-list", in: app).waitForExistence(timeout: 5))
        element("posts-row-1", in: app).tap()
        XCTAssertTrue(element("posts-detail", in: app).waitForExistence(timeout: 5))
    }

    func testSettingsFilterAndTypedDigestCompletion() {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        tapTab(named: "Settings", in: app)
        XCTAssertTrue(element("settings-row-1", in: app).waitForExistence(timeout: 5))
        // iOS 27 exposes an outer labelled Toggle plus its inner native switch.
        let filter = app.switches.element(boundBy: 1)
        XCTAssertTrue(filter.waitForExistence(timeout: 5))
        filter.tap()
        XCTAssertTrue(element("settings-row-2", in: app).waitForExistence(timeout: 5))
        let pendingRow = element("settings-row-1", in: app)
        expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: pendingRow)
        waitForExpectations(timeout: 5)

        app.buttons["Digest"].tap()
        XCTAssertTrue(element("settings-digest-title", in: app).waitForExistence(timeout: 5))
        app.buttons["Close"].tap()
        expectation(
            for: NSPredicate(format: "exists == false"),
            evaluatedWith: element("settings-digest-title", in: app)
        )
        waitForExpectations(timeout: 5)
    }

    private func assertSelectedTab(_ title: String, in app: XCUIApplication) {
        let tab = app.buttons[title]
        XCTAssertTrue(tab.waitForExistence(timeout: 5))
        let selected = NSPredicate(format: "isSelected == true")
        expectation(for: selected, evaluatedWith: tab)
        waitForExpectations(timeout: 5)
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
        let nativeBack = app.buttons.matching(identifier: "BackButton").firstMatch
        if nativeBack.exists {
            nativeBack.tap()
            return
        }

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

        for _ in 0..<maxSwipes where !target.isHittable {
            container.swipeUp()
        }

        XCTAssertTrue(target.waitForExistence(timeout: 5))
    }
}
