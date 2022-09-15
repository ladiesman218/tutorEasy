//
//  AppDelegate.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/6/23.
//

import UIKit

@available(iOS 13.0, *)
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		//window = UIWindow(frame: UIScreen.main.bounds)
		
		let navVC = UINavigationController()
		navVC.navigationBar.isHidden = true
		
		lazy var accountsVC = AccountsVC(nibName: nil, bundle: nil)
		lazy var startVC = LanguagesVC(nibName: nil, bundle: nil)
		
//		Auth.tokenValue = nil
		var destinationVC: UIViewController = (Auth.tokenValue == nil) ? accountsVC : startVC
		
		if Keychain.load(key: Auth.keychainTokenKey) != nil {
			Auth.getPublicUserFromToken { result in
				
				switch result {
				case .success:
					destinationVC = startVC
				case .failure:
					destinationVC = accountsVC
				}
				if navVC.topViewController != destinationVC {
					DispatchQueue.main.async {
						navVC.pushViewController(destinationVC, animated: true)
					}
				}
			}
			
		}
		
		window!.rootViewController = navVC
		window!.makeKeyAndVisible()
		navVC.pushViewController(destinationVC, animated: false)
		
		return true
	}
	
	// MARK: UISceneSession Lifecycle
	
	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}
	
	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}
	
	
}

