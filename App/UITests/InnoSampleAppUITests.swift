import XCTest
import UIKit

@MainActor
final class InnoSampleAppUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    override func tearDownWithError() throws {
        XCUIDevice.shared.orientation = .portrait
    }

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
        tap(element("posts-row-1", in: app), in: app)
        XCTAssertTrue(element("posts-detail", in: app).waitForExistence(timeout: 5))
    }

    func testPostsDetailSurvivesCompactSplitWidthChanges() throws {
        let app = launchPosts()
        try requireCompactTablet(app)
        tap(element("posts-row-1", in: app), in: app)
        XCTAssertTrue(element("posts-detail", in: app).waitForExistence(timeout: 5), app.debugDescription)

        tapTab(named: "Settings", in: app)
        assertSelectedTab("Settings", in: app)
        tapTab(named: "Posts", in: app)
        assertSelectedTab("Posts", in: app)
        XCTAssertTrue(element("posts-detail", in: app).waitForExistence(timeout: 5), app.debugDescription)

        rotate(.landscapeLeft, app: app, wide: true)
        assertPostsListVisible(in: app)
        assertPostDetailVisible(in: app)
        let row = element("posts-row-1", in: app)
        let body = element("posts-detail", in: app).staticTexts["Deterministic routing fixture"]
        XCTAssertLessThan(row.frame.maxX, body.frame.minX, "The list and selected detail must occupy separate columns")

        rotate(.portrait, app: app, wide: false)
        assertPostDetailVisible(in: app)
        navigateBack(in: app)
        assertPostsListVisible(in: app)
    }

    func testPostsHighlightsSurvivesWidthChangesAndRetainsDetail() throws {
        let app = launchPosts()
        try requireCompactTablet(app)
        tap(app.buttons["Highlights"], in: app)
        assertHittable(element("posts-highlights-title", in: app))

        rotate(.landscapeLeft, app: app, wide: true)
        assertHittable(element("posts-highlights-title", in: app))
        dismissHighlights(in: app)
        assertPostsListVisible(in: app)
        tap(element("posts-row-1", in: app), in: app)
        assertPostDetailVisible(in: app)

        tap(app.buttons["Highlights"], in: app)
        assertHittable(element("posts-highlights-title", in: app))
        rotate(.portrait, app: app, wide: false)
        assertHittable(element("posts-highlights-title", in: app))
        dismissHighlights(in: app)
        assertPostDetailVisible(in: app)
        navigateBack(in: app)
        assertPostsListVisible(in: app)
    }

    func testSettingsFilterAndTypedDigestCompletion() {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        tapTab(named: "Settings", in: app)
        XCTAssertTrue(element("settings-row-1", in: app).waitForExistence(timeout: 5))
        // Target the labelled control's native switch, independent of other toggles.
        let labelledFilter = app.switches["settings-shows-completed-only"]
        let filter = labelledFilter.switches.firstMatch.exists ? labelledFilter.switches.firstMatch : labelledFilter
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
        scrollToElement("digest acknowledged", in: element("settings-list", in: app))
        XCTAssertEqual(app.staticTexts.matching(identifier: "digest acknowledged").count, 1)
    }

    func testSettingsInteractiveDismissalDoesNotAcknowledgeDigest() {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        tapTab(named: "Settings", in: app)
        XCTAssertTrue(element("settings-list", in: app).waitForExistence(timeout: 5))
        app.buttons["Digest"].tap()
        let title = element("settings-digest-title", in: app)
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        title.coordinate(withNormalizedOffset: .init(dx: 0.5, dy: 0.5))
            .press(forDuration: 0.1, thenDragTo: app.coordinate(withNormalizedOffset: .init(dx: 0.5, dy: 0.95)))
        expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: title)
        waitForExpectations(timeout: 5)
        scrollToElement("digest modal requested", in: element("settings-list", in: app))
        XCTAssertFalse(app.staticTexts["digest acknowledged"].exists)
    }

    private func launchPosts() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        tapTab(named: "Posts", in: app)
        XCTAssertTrue(element("posts-list", in: app).waitForExistence(timeout: 5))
        return app
    }

    private func requireCompactTablet(_ app: XCUIApplication) throws {
        try XCTSkipUnless(app.frame.width >= 700 && app.frame.width < 800,
                          "Adaptive regressions run on an iPad mini; other devices run the core flows")
    }

    private func rotate(_ orientation: UIDeviceOrientation, app: XCUIApplication, wide: Bool) {
        XCUIDevice.shared.orientation = orientation
        let predicate = NSPredicate { _, _ in wide ? app.frame.width >= 800 : app.frame.width < 800 }
        expectation(for: predicate, evaluatedWith: app)
        waitForExpectations(timeout: 10)
    }

    private func assertHittable(_ element: XCUIElement) {
        let visible = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == true AND isHittable == true"), object: element
        )
        if XCTWaiter.wait(for: [visible], timeout: 10) != .completed {
            let app = XCUIApplication()
            let screenshot = XCTAttachment(screenshot: app.screenshot())
            screenshot.lifetime = .keepAlways
            add(screenshot)
            XCTFail("Expected visible content: \(element.identifier)\n\(app.debugDescription)")
        }
    }

    private func assertPostsListVisible(in app: XCUIApplication) {
        XCTAssertTrue(element("posts-list", in: app).waitForExistence(timeout: 5))
        let row = element("posts-row-1", in: app)
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        XCTAssertFalse(row.frame.isEmpty)
        XCTAssertTrue(app.frame.contains(row.frame), app.debugDescription)
    }

    private func assertPostDetailVisible(in app: XCUIApplication) {
        let detail = element("posts-detail", in: app)
        XCTAssertTrue(detail.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertTrue(detail.staticTexts["post identifier 1"].waitForExistence(timeout: 5))
        let body = detail.staticTexts["Deterministic routing fixture"]
        XCTAssertTrue(body.waitForExistence(timeout: 5))
        XCTAssertFalse(body.frame.isEmpty)
        XCTAssertTrue(app.frame.contains(body.frame), app.debugDescription)
    }

    private func dismissHighlights(in app: XCUIApplication) {
        app.buttons["Close"].tap()
        let closed = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: element("posts-highlights-title", in: app)
        )
        XCTAssertEqual(XCTWaiter.wait(for: [closed], timeout: 5), .completed)
    }

    private func assertSelectedTab(_ title: String, in app: XCUIApplication) {
        let tab = tabButton(named: title, in: app)
        expectation(for: NSPredicate(format: "isSelected == true"), evaluatedWith: tab)
        waitForExpectations(timeout: 5)
    }

    private func tapTab(named title: String, in app: XCUIApplication) {
        tap(tabButton(named: title, in: app), in: app)
    }

    private func tabButton(named title: String, in app: XCUIApplication) -> XCUIElement {
        let phoneTab = app.tabBars.buttons[title]
        if phoneTab.exists { return phoneTab }
        // iPad uses the TabItem image as its native identifier. Matching both
        // fields excludes a detail's Back button, which can also be named Posts.
        let images = ["People": "person.2", "Posts": "doc.text", "Settings": "gearshape"]
        let predicate = NSPredicate(format: "identifier == %@ AND label == %@", images[title] ?? "", title)
        return app.buttons.matching(predicate).firstMatch
    }

    private func tap(_ target: XCUIElement, in app: XCUIApplication) {
        XCTAssertTrue(target.waitForExistence(timeout: 5))
        if target.isHittable {
            target.tap()
        } else {
            // Adaptive iPad chrome can expose a visible cell with no AX hit point.
            // Use that cell's observed center, then assert the resulting route.
            XCTAssertFalse(target.frame.isEmpty)
            XCTAssertTrue(app.frame.contains(target.frame), app.debugDescription)
            target.coordinate(withNormalizedOffset: .init(dx: 0.5, dy: 0.5)).tap()
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
