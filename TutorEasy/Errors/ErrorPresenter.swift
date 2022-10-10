import UIKit

enum ErrorPresenter {
	static func showError(message: String, on viewController: UIViewController?, dismissAction: ((UIAlertAction) -> Void)? = nil) {
		weak var weakViewController = viewController
			let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: dismissAction))
			weakViewController?.present(alertController, animated: true)
	}
}

enum MessagePresenter {
	static func showMessage(title: String, message: String, on viewController: UIViewController?, actions: [UIAlertAction]) {
		weak var weakViewController = viewController
			let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
			
			for action in actions {
				alertController.addAction(action)
			}
			
			if actions.isEmpty {
				alertController.addAction(UIAlertAction(title: "确定", style: .default))
			}
			weakViewController?.present(alertController, animated: true)
	}
}
