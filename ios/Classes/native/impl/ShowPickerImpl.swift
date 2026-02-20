import Contacts
import ContactsUI
import Flutter
import UIKit

enum ShowPickerImpl {
    private static var pendingResult: FlutterResult?
    private static var pickerDelegate: PickerDelegate?

    static func handle(call _: FlutterMethodCall, result: @escaping FlutterResult) {
        pendingResult = result

        DispatchQueue.main.async {
            guard let rootVC = ViewControllerUtils.presentingViewController() else {
                result(
                    HandlerHelpers.makeError(
                        code: "no_view_controller",
                        message: "No active view controller available",
                        details: [
                            "method": "native.showPicker",
                            "sceneSummary": ViewControllerUtils.sceneDebugSummary(),
                        ]
                    )
                )
                pendingResult = nil
                return
            }

            let picker = CNContactPickerViewController()
            let delegate = PickerDelegate()
            picker.delegate = delegate
            picker.predicateForSelectionOfContact = NSPredicate(value: true)
            pickerDelegate = delegate
            rootVC.present(picker, animated: true)
        }
    }

    static func completeWithResult(_ value: Any?) {
        pendingResult?(value)
        pendingResult = nil
        pickerDelegate = nil
    }
}

private class PickerDelegate: NSObject, CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        picker.dismiss(animated: true) {
            ShowPickerImpl.completeWithResult(contact.identifier)
        }
    }

    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        picker.dismiss(animated: true) {
            ShowPickerImpl.completeWithResult(nil)
        }
    }
}
