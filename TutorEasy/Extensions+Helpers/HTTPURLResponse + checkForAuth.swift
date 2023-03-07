//
//  HTTPURLResponse + checkForAuth.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/1/27.
//

import UIKit

extension HTTPURLResponse {
	@MainActor
	func checkForAuth(from viewController: UIViewController) {
		if self.statusCode == 401 {
			AuthAPI.tokenValue = nil
			
			if let navVC = viewController.navigationController,
			   let topVC = navVC.topViewController,
			   !topVC.isKind(of: AuthenticationVC.self) {
				let authVC = AuthenticationVC(nibName: nil, bundle: nil)
				navVC.pushViewController(authVC, animated: true)
				MessagePresenter.showMessage(title: "登录信息失效", message: "请重新登录", on: authVC, actions: [])
			}
		}
	}
}
