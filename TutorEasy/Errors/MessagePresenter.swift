import UIKit

@MainActor enum MessagePresenter {
    static func showMessage(title: String, message: String, on viewController: UIViewController?, actions: [UIAlertAction]) {
        weak var weakViewController = viewController
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for action in actions {
            alertController.addAction(action)
        }
        
        if actions.isEmpty {
            alertController.addAction(UIAlertAction(title: "确定", style: .default))
        }
		alertController.preferredAction = alertController.actions.last
        weakViewController?.present(alertController, animated: true)
    }
}
