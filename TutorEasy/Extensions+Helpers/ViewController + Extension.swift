//
//  ViewController + Extension.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/15.
//

import UIKit

extension UIViewController {
    
    func dismissKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(UIViewController.dismissKeyboardTouchOutside))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboardTouchOutside() {
        view.endEditing(true)
    }
    
    func configProfileIcon(for vc: UIViewController) -> UIButton {
        let button = UIButton()
        let font = UIFont.systemFont(ofSize: 50) // <- make it larger, smaller, whatever you want.
        let config = UIImage.SymbolConfiguration(font: font)
        let image = UIImage(systemName: "person.crop.circle", withConfiguration: config)
        
        if isLoggedIn {
            button.setImage(image, for: .normal)
        } else {
            button.setImage(image, for: .normal)
        }
        
        button.addTarget(self, action: #selector(self.profileIconClicked), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }
    
    @objc func profileIconClicked() {
        let destinationVC: UIViewController = (isLoggedIn) ? AccountVC(nibName: nil, bundle: nil) : AuthenticationVC(nibName: nil, bundle: nil)
        
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
}
