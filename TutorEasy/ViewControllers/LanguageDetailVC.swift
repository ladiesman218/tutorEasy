//
//  LangaugeDetailVCViewController.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/9/29.
//

import UIKit

class LanguageDetailVC: UIViewController {
	var language: Language.PublicInfo!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        if #available(iOS 14.0, *) {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward.circle.fill")!, style: .plain, target: self, action: #selector(goBack))
        } else {
            // SF symbols are available in iOS 13 and later, the symbol used here is available in iOS 14, this is a hack from https://stackoverflow.com/questions/43073738/change-size-of-uibarbuttonitem-image-in-swift-3
            setUpGoBackButton()
        }
        
        let backTitle = UIBarButtonItem(title: language.name, style: .done, target: nil, action: nil)
        backTitle.isEnabled = false
        backTitle.tintColor = .black
        
        self.navigationItem.leftBarButtonItems?.append(backTitle)

    }
    
    func setUpGoBackButton() {
        let backButton = UIButton(type: .custom)
        backButton.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        backButton.setImage(UIImage(named:"arrow back"), for: .normal)
        backButton.addTarget(self, action: #selector(goBack), for: UIControl.Event.touchUpInside)

        let menuBarItem = UIBarButtonItem(customView: backButton)
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
    }
    
	@objc func goBack() {
		self.dismiss(animated: true)
	}
	
}
