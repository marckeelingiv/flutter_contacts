import UIKit
@testable import flutter_contacts
import XCTest

final class ViewControllerUtilsTests: XCTestCase {
    func testSelectRootViewControllerPrefersForegroundActiveKeyWindow() {
        let backgroundRoot = UIViewController()
        let foregroundRoot = UIViewController()

        let selected = ViewControllerUtils.selectRootViewController(from: [
            .init(
                rootViewController: backgroundRoot,
                isForegroundActive: false,
                isKeyWindow: true,
                isVisible: true,
                isNormalLevel: true
            ),
            .init(
                rootViewController: foregroundRoot,
                isForegroundActive: true,
                isKeyWindow: true,
                isVisible: true,
                isNormalLevel: true
            ),
        ])

        XCTAssertTrue(selected === foregroundRoot)
    }

    func testSelectRootViewControllerFallsBackToVisibleNormalWindowWhenNoKeyWindow() {
        let hiddenRoot = UIViewController()
        let visibleRoot = UIViewController()

        let selected = ViewControllerUtils.selectRootViewController(from: [
            .init(
                rootViewController: hiddenRoot,
                isForegroundActive: true,
                isKeyWindow: false,
                isVisible: false,
                isNormalLevel: true
            ),
            .init(
                rootViewController: visibleRoot,
                isForegroundActive: true,
                isKeyWindow: false,
                isVisible: true,
                isNormalLevel: true
            ),
        ])

        XCTAssertTrue(selected === visibleRoot)
    }

    func testSelectRootViewControllerReturnsNilWithoutCandidates() {
        XCTAssertNil(ViewControllerUtils.selectRootViewController(from: []))
    }

    func testTopPresentedViewControllerReturnsTopMostPresented() {
        let root = StubViewController()
        let mid = StubViewController()
        let top = StubViewController()
        root.stubPresentedViewController = mid
        mid.stubPresentedViewController = top

        let selected = ViewControllerUtils.topPresentedViewController(from: root)
        XCTAssertTrue(selected === top)
    }

    func testTopPresentedViewControllerStopsWhenPresentedIsBeingDismissed() {
        let root = StubViewController()
        let mid = StubViewController()
        let dismissing = StubViewController()
        dismissing.stubIsBeingDismissed = true
        root.stubPresentedViewController = mid
        mid.stubPresentedViewController = dismissing

        let selected = ViewControllerUtils.topPresentedViewController(from: root)
        XCTAssertTrue(selected === mid)
    }
}

private final class StubViewController: UIViewController {
    var stubPresentedViewController: UIViewController?
    var stubIsBeingDismissed = false

    override var presentedViewController: UIViewController? {
        stubPresentedViewController
    }

    override var isBeingDismissed: Bool {
        stubIsBeingDismissed
    }
}
