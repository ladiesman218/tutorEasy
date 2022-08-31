//
//  ViewController.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/6/23.
//

import UIKit

class LoginViewController: UIViewController {
	
	private let loginNameTextField = UITextField()
	private let passwordTextField = UITextField()
	private let loginButton = UIButton()
	
	static private let borderColor: CGColor = UIColor.gray.cgColor
	static private let textColor = UIColor.cyan
	
	@objc private func login() {
		guard let username = loginNameTextField.text, !username.isEmpty else {
			MessagePresenter.showMessage(title: "无效用户名", message: "请输入用户名", on: self, actions: [])
			return
		}
		
		guard let password = passwordTextField.text, !password.isEmpty else {
			MessagePresenter.showMessage(title: "无效密码", message: "请输入密码", on: self, actions: [])
			return
		}
		
		Auth.login(username: username, password: password) { result in
			switch result {
			case .success:
				DispatchQueue.main.async {
					let languageVC = LanguagesVC()
					let navVC = UINavigationController(rootViewController: languageVC)
					self.present(navVC, animated: true)
				}
			case .failure:
				MessagePresenter.showMessage(title: "登录失败", message: "请检查用户名或密码", on: self, actions: [])
			}
		}		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		loginNameTextField.becomeFirstResponder()
		
		loginNameTextField.autocapitalizationType = .none
		loginNameTextField.keyboardType = .emailAddress
		loginNameTextField.textColor = Self.textColor
		loginNameTextField.placeholder = "请输入用户名/邮箱"
		loginNameTextField.layer.borderWidth = 1
		loginNameTextField.layer.borderColor = Self.borderColor
		
		//Show only bottom border for textfield
		//		let bottomLine = CALayer()
		//		bottomLine.frame = CGRect(x: 0, y: loginNameTextField.frame.height - 1, width: loginNameTextField.frame.width, height: 1)
		//		bottomLine.backgroundColor = UIColor.red.cgColor
		//		loginNameTextField.borderStyle = .none
		//		loginNameTextField.layer.addSublayer(bottomLine)
		view.addSubview(loginNameTextField)
		
		passwordTextField.textColor = Self.textColor
		passwordTextField.isSecureTextEntry = true	// Show * instead of actual characters
		passwordTextField.layer.borderWidth = 1
		passwordTextField.placeholder = "请输入密码"
		passwordTextField.layer.borderColor = Self.borderColor
		view.addSubview(passwordTextField)
		
		loginButton.setTitle("登录", for: .normal)
		loginButton.sizeToFit()
		loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
		loginButton.layer.cornerRadius = 10
		loginButton.backgroundColor = UIColor.purple
		view.addSubview(loginButton)
		
		loginNameTextField.translatesAutoresizingMaskIntoConstraints = false
		passwordTextField.translatesAutoresizingMaskIntoConstraints = false
		loginButton.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			loginNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			loginNameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
			loginNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			
			passwordTextField.leadingAnchor.constraint(equalTo: loginNameTextField.leadingAnchor),
			passwordTextField.topAnchor.constraint(equalTo: loginNameTextField.bottomAnchor, constant: 20),
			passwordTextField.widthAnchor.constraint(equalTo: loginNameTextField.widthAnchor),
			
			loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
			loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			loginButton.widthAnchor.constraint(equalTo: loginNameTextField.widthAnchor, multiplier: 0.8)
		])
	}
	
}

