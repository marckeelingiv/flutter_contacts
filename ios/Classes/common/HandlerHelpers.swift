import Flutter
import Foundation

enum HandlerHelpers {
    static let errorCode = "flutter_contacts_error"

    static func makeError(code: String, message: String, details: Any? = nil) -> FlutterError {
        FlutterError(code: code, message: message, details: details)
    }

    static func makeError(_ message: String) -> FlutterError {
        makeError(code: errorCode, message: message)
    }

    static func nsError(_ message: String, code: Int = 1) -> NSError {
        NSError(domain: errorCode, code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }

    static func handleResult(_ result: @escaping FlutterResult, _ block: () throws -> Any?) {
        do {
            try result(block())
        } catch {
            result(makeError(error.localizedDescription))
        }
    }
}
