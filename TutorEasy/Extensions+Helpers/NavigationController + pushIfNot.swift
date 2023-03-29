//
//  NavigationController + pushIfNot.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/1/29.
//

import UIKit

// Only if topViewController is not type of the given VC, push a new one
extension UINavigationController {
	func pushIfNot(destinationVCType: AnyClass, newVC: UIViewController, animated: Bool = true) {
		guard let topViewController = self.topViewController else { return }
		
		if !topViewController.isKind(of: destinationVCType) {
			self.pushViewController(newVC, animated: animated)
		}
	}
}
