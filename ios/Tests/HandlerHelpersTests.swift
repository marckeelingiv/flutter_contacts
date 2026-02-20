import Flutter
@testable import flutter_contacts
import XCTest

final class HandlerHelpersTests: XCTestCase {
    func testMakeErrorWithExplicitCodeMessageAndDetails() {
        let details: [String: Any] = ["method": "native.showPicker", "attempt": 1]
        let error = HandlerHelpers.makeError(
            code: "no_view_controller",
            message: "No active view controller available",
            details: details
        )

        XCTAssertEqual(error.code, "no_view_controller")
        XCTAssertEqual(error.message, "No active view controller available")
        XCTAssertNotNil(error.details as? [String: Any])
    }

    func testMakeErrorUsesDefaultPluginCode() {
        let error = HandlerHelpers.makeError("Any error")
        XCTAssertEqual(error.code, "flutter_contacts_error")
        XCTAssertEqual(error.message, "Any error")
        XCTAssertNil(error.details)
    }

    func testHandleResultReturnsValue() {
        let expectation = XCTestExpectation(description: "result returned")
        HandlerHelpers.handleResult({ value in
            if let number = value as? Int {
                XCTAssertEqual(number, 42)
                expectation.fulfill()
            }
        }, {
            42
        })
        wait(for: [expectation], timeout: 1.0)
    }

    func testHandleResultReturnsFlutterErrorOnThrow() {
        let expectation = XCTestExpectation(description: "error returned")
        HandlerHelpers.handleResult({ value in
            if let error = value as? FlutterError {
                XCTAssertEqual(error.code, "flutter_contacts_error")
                expectation.fulfill()
            }
        }, {
            throw NSError(domain: "test", code: 1)
        })
        wait(for: [expectation], timeout: 1.0)
    }
}
