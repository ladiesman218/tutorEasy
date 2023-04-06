//
//  NavigationController + pushIfNot.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/1/29.
//

import UIKit

// Only if topViewController is not type of the given VC, push a new one
extension UINavigationController {
	func pushIfNot(newVC: UIViewController, animated: Bool = true) {
		guard let topViewController = self.topViewController else { return }
		let newType = type(of: newVC)
		guard !topViewController.isKind(of: newType) else { return }
		self.pushViewController(newVC, animated: animated)
	}
}
