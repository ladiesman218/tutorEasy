//
//  Global.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/6/24.
//

import UIKit

//let serverURL = URL(string: "http://localhost:8080")!     //localhost
let serverURL = URL(string: "https://98ab-1-28-218-30.jp.ngrok.io")!     //ngrok
//let serverURL = URL(string: "http://20.243.114.35:8080")!     //azure
//let serverURL = URL(string: "http://0.0.0.0:8080")!     // docker production environment
let baseURL = serverURL.appendingPathComponent("api")

enum ImageName: String, CaseIterable {
    case image
    case banner
}

enum ImageExtension: String, CaseIterable {
    case png
    case jpg
    case jpeg
}

//let courseRoot = URL(string: "../Courses")!
let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
let phoneNumberRegex = "^([+](\\d{1,3}|\\d{1,2}[- ]{1,}\\d{3,4})[- ]{1,}){0,1}\\d{5,20}$"
let userNameLength = Range(4...35)
let nameLength = Range(3...40)
let passwordLength = Range(6...40)
let adminEmail = "chn_dunce@126.com"
let loginChanged: Notification.Name = .init(rawValue: "login-status-changed")


let borderColor: CGColor = UIColor.systemGray.cgColor
let textColor = UIColor.systemBlue
let backgroundColor = UIColor.systemBackground




func setupDestinationVC(window: UIWindow) {
    let languageVC = LanguageListVC(nibName: nil, bundle: nil)
    languageVC.loadLanguages()
    
    let navVC = UINavigationController(rootViewController: languageVC)
    navVC.isNavigationBarHidden = true
    
    window.rootViewController = navVC
    window.makeKeyAndVisible()
    
    AuthAPI.getPublicUserFromToken { userInfo, response, error in
        if let userInfo = userInfo {
            AuthAPI.userInfo = userInfo
        } else {
            AuthAPI.userInfo = nil
            let authenticationVC = AuthenticationVC(nibName: nil, bundle: nil)
            
            if !navVC.topViewController!.isKind(of: AuthenticationVC.self) {
                navVC.pushViewController(authenticationVC, animated: true)
            }
        }
    }
}
