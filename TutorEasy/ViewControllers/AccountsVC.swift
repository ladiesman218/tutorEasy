//
//  AccountsVC.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/8/25.
//

import UIKit

class AccountsVC: UIViewController {
	
	private var containerView: UIView!
	private let loginVC = LoginViewController()
	private lazy var registerVC = RegisterViewController()
    
    static private let activeBgColor = UIColor.blue
    static private let deactiveBgColor = UIColor.gray
    
    private var loginViewButton: UIButton!
    private var registerViewButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView = UIView()
        self.dismissKeyboard()
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "LoginBg")!)

        setupButtons()
        setupContainerView()
        
        // Default to login view
        // Using the following code to add loginVC avoids instantiating a registerVC, which in some case won't be necessary hence waste resources.
		self.addChild(loginVC)
		containerView.addSubview(loginVC.view)
		
		loginVC.view.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			loginVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
			loginVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			loginVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			loginVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
		])

	}
	
	
	@objc private func switchVCs(sender: UIButton) {
		if sender.tag == 0 {
			registerViewButton.backgroundColor = Self.deactiveBgColor
			registerVC.view.removeFromSuperview()
			registerVC.removeFromParent()
			
			loginViewButton.backgroundColor = Self.activeBgColor
			self.addChild(loginVC)
			containerView.addSubview(loginVC.view)
			
			loginVC.view.translatesAutoresizingMaskIntoConstraints = false
			
			NSLayoutConstraint.activate([
				loginVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
				loginVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
				loginVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
				loginVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
			])

		} else {
			loginViewButton.backgroundColor = Self.deactiveBgColor
			loginVC.view.removeFromSuperview()
			loginVC.removeFromParent()
			
			registerViewButton.backgroundColor = Self.activeBgColor
			self.addChild(registerVC)
			containerView.addSubview(registerVC.view)

			registerVC.view.translatesAutoresizingMaskIntoConstraints = false
			
			NSLayoutConstraint.activate([
				registerVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
				registerVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
				registerVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
				registerVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
			])
		}
	}
	
	private func setupContainerView() {
		
		containerView.layer.cornerRadius = 10
		containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
		containerView.translatesAutoresizingMaskIntoConstraints = false
		containerView.backgroundColor = .white
		view.addSubview(containerView)
		
		// Two switch view buttons are constrained above container view rather than in the container view itself.
		NSLayoutConstraint.activate([
			containerView.leadingAnchor.constraint(equalTo: loginViewButton.leadingAnchor),
			containerView.topAnchor.constraint(equalTo: loginViewButton.bottomAnchor),
			containerView.widthAnchor.constraint(equalTo: loginViewButton.widthAnchor, multiplier: 2),
			containerView.heightAnchor.constraint(equalToConstant: 250)
		])
	}
	
	private func setupButtons() {
		loginViewButton = UIButton()
		loginViewButton.tag = 0
		loginViewButton.addTarget(self, action: #selector(switchVCs), for: .touchUpInside)
		loginViewButton.setTitle("登录", for: .init())
		loginViewButton.backgroundColor = Self.activeBgColor
		loginViewButton.layer.cornerRadius = 10
		loginViewButton.layer.maskedCorners = [.layerMinXMinYCorner]
		view.addSubview(loginViewButton)
		
		registerViewButton = UIButton()
		registerViewButton.tag = 1
		registerViewButton.addTarget(self, action: #selector(switchVCs), for: .touchUpInside)
		registerViewButton.setTitle("注册", for: .init())
		registerViewButton.backgroundColor = Self.deactiveBgColor
		registerViewButton.layer.cornerRadius = loginViewButton.layer.cornerRadius
		registerViewButton.layer.maskedCorners = [.layerMaxXMinYCorner]
		view.addSubview(registerViewButton)
		
		loginViewButton.translatesAutoresizingMaskIntoConstraints = false
		registerViewButton.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			loginViewButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
			loginViewButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
			loginViewButton.heightAnchor.constraint(equalToConstant: 40),
			loginViewButton.widthAnchor.constraint(equalToConstant: 150),
			
			registerViewButton.leadingAnchor.constraint(equalTo: loginViewButton.trailingAnchor),
			registerViewButton.topAnchor.constraint(equalTo: loginViewButton.topAnchor),
			registerViewButton.heightAnchor.constraint(equalTo: loginViewButton.heightAnchor),
			registerViewButton.widthAnchor.constraint(equalTo: loginViewButton.widthAnchor)
		])
	}
}
