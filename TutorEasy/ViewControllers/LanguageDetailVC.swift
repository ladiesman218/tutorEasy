//
//  LangaugeDetailVCViewController.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/9/29.
//

import UIKit

class LanguageDetailVC: UIViewController {
	var language: Language.PublicInfo!

    private var topView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        topView = configTopView()
        setUpGoBackButton(in: topView, animated: false)

    }
}
