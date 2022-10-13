//
//  Global.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/6/24.
//

import UIKit

let serverURL = URL(string: "http://localhost:8080")!
let baseURL = serverURL.appendingPathComponent("api")
let mediaURL = baseURL.appendingPathComponent("media")

//let serverURL = URL(string: "http://20.243.114.35:8080")!



//let courseRoot = URL(string: "../Courses")!
let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
let phoneNumberRegex = "^([+](\\d{1,3}|\\d{1,2}[- ]{1,}\\d{3,4})[- ]{1,}){0,1}\\d{5,20}$"
let userNameLength = Range(4...35)
let nameLength = Range(3...40)
let passwordLength = Range(6...40)
let adminEmail = "chn_dunce@126.com"



let borderColor: CGColor = UIColor.systemGray.cgColor
let textColor = UIColor.systemBlue
let backgroundColor: UIColor = {
    if #available(iOS 13, *) {
        return .systemGray
    } else {
        return .white
    }
}()




func setupDestinationVC(window: UIWindow) {
    let languageVC = LanguageListVC(nibName: nil, bundle: nil)
    
    let navVC = UINavigationController(rootViewController: languageVC)
    navVC.isNavigationBarHidden = true
    
    window.rootViewController = navVC
    window.makeKeyAndVisible()
    
    AuthAPI.getPublicUserFromToken { userInfo, response, error in
        if let userInfo = userInfo {
            print("userInfo: \(userInfo)")
            
        } else {
            let accountsVC = AccountsVC(nibName: nil, bundle: nil)
            print(error!.reason)
            navVC.pushViewController(accountsVC, animated: true)
        }
    }
}
