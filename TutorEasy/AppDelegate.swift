//
//  AppDelegate.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/6/23.
//

import UIKit

@available(iOS 9.0, *)
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		window = UIWindow(frame: UIScreen.main.bounds)

        // Only if OS is lower than 13.0, run this. In iOS 13.0 and later, code in SceneDelegate will run, so we can avoid calling the same function twice for iOS 13 and later.
        if #unavailable(iOS 13.0) {
            setupDestinationVC(window: self.window!)
        }

        return true
	}
	
	// MARK: UISceneSession Lifecycle
	
	@available(iOS 13.0, *)
	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}
	
	@available(iOS 13.0, *)
	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}
	
	
}

