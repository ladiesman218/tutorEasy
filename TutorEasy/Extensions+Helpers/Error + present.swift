//
//  Error + present.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/1/27.
//

import UIKit

// Present errorMessage
extension Error {
	@MainActor
	func present(on viewController: UIViewController, title: String, actions: [UIAlertAction]) {
		if let error = self as? ResponseError {
			MessagePresenter.showMessage(title: title, message: error.reason, on: viewController, actions: actions)
		} else {
			MessagePresenter.showMessage(title: title, message: self.localizedDescription, on: viewController, actions: actions)
		}
	}
}
