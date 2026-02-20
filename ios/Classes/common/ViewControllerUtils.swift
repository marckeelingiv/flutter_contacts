import UIKit

enum ViewControllerUtils {
    struct WindowCandidate {
        let rootViewController: UIViewController?
        let isForegroundActive: Bool
        let isKeyWindow: Bool
        let isVisible: Bool
        let isNormalLevel: Bool
    }

    static func presentingViewController() -> UIViewController? {
        let root = rootViewController()
        return topPresentedViewController(from: root)
    }

    static func rootViewController() -> UIViewController? {
        let candidates = sceneWindowCandidates()
        return selectRootViewController(from: candidates)
    }

    static func sceneDebugSummary() -> String {
        let candidates = sceneWindowCandidates()
        let sceneCount: Int
        let foregroundSceneCount: Int
        if #available(iOS 13.0, *) {
            let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            sceneCount = scenes.count
            foregroundSceneCount = scenes.filter { $0.activationState == .foregroundActive }.count
        } else {
            sceneCount = 1
            foregroundSceneCount = 1
        }
        let foregroundCount = candidates.filter { $0.isForegroundActive }.count
        let keyCount = candidates.filter { $0.isKeyWindow }.count
        let visibleCount = candidates.filter { $0.isVisible }.count
        let normalLevelCount = candidates.filter { $0.isNormalLevel }.count
        return "scenes=\(sceneCount) foregroundScenes=\(foregroundSceneCount) windows=\(candidates.count) foregroundWindows=\(foregroundCount) key=\(keyCount) visible=\(visibleCount) normal=\(normalLevelCount)"
    }

    static func selectRootViewController(from candidates: [WindowCandidate]) -> UIViewController? {
        if let root = firstRoot(from: candidates, where: { $0.isForegroundActive && $0.isKeyWindow }) {
            return root
        }

        if let root = firstRoot(from: candidates, where: {
            $0.isForegroundActive && $0.isVisible && $0.isNormalLevel
        }) {
            return root
        }

        if let root = firstRoot(from: candidates, where: { $0.isKeyWindow }) {
            return root
        }

        if let root = firstRoot(from: candidates, where: { $0.isVisible && $0.isNormalLevel }) {
            return root
        }

        return firstRoot(from: candidates, where: { _ in true })
    }

    static func topPresentedViewController(from rootViewController: UIViewController?) -> UIViewController? {
        guard var current = rootViewController else {
            return nil
        }

        while let presented = current.presentedViewController, !presented.isBeingDismissed {
            current = presented
        }

        return current
    }

    private static func firstRoot(
        from candidates: [WindowCandidate],
        where predicate: (WindowCandidate) -> Bool
    ) -> UIViewController? {
        for candidate in candidates where predicate(candidate) {
            if let root = candidate.rootViewController {
                return root
            }
        }
        return nil
    }

    private static func sceneWindowCandidates() -> [WindowCandidate] {
        var candidates: [WindowCandidate] = []

        if #available(iOS 13.0, *) {
            for scene in UIApplication.shared.connectedScenes {
                guard let windowScene = scene as? UIWindowScene else {
                    continue
                }
                let isForegroundActive = windowScene.activationState == .foregroundActive
                candidates.append(
                    contentsOf: windowScene.windows.map { window in
                        WindowCandidate(
                            rootViewController: window.rootViewController,
                            isForegroundActive: isForegroundActive,
                            isKeyWindow: window.isKeyWindow,
                            isVisible: !window.isHidden && window.alpha > 0,
                            isNormalLevel: window.windowLevel == .normal
                        )
                    }
                )
            }
        }

        if candidates.isEmpty {
            candidates.append(
                contentsOf: UIApplication.shared.windows.map { window in
                    WindowCandidate(
                        rootViewController: window.rootViewController,
                        isForegroundActive: true,
                        isKeyWindow: window.isKeyWindow,
                        isVisible: !window.isHidden && window.alpha > 0,
                        isNormalLevel: window.windowLevel == .normal
                    )
                }
            )
        }

        return candidates
    }
}
