//
//  ViewController.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/6/23.
//

import UIKit

class LoginViewController: UIViewController {
	
	private var loginNameTextField: UITextField!
	private var passwordTextField: UITextField!
	private var loginButton: UIButton!
	
	@objc private func login() {
		guard let username = loginNameTextField.text, !username.isEmpty else {
			MessagePresenter.showMessage(title: "无效用户名", message: "请输入用户名", on: self, actions: [])
			return
		}
		
		guard let password = passwordTextField.text, !password.isEmpty else {
			MessagePresenter.showMessage(title: "无效密码", message: "请输入密码", on: self, actions: [])
			return
		}
		
		AuthAPI.login(username: username, password: password) { result in
			switch result {
			case .success:
					let languageVC = LanguageListVC()
					self.present(languageVC, animated: true)
			case .failure(let reason):
				MessagePresenter.showMessage(title: "登录失败", message: "\(reason)", on: self, actions: [])
			}
		}		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		loginNameTextField = UITextField()
		passwordTextField = UITextField()
		loginButton = UIButton()
		
		loginNameTextField.becomeFirstResponder()
		
		loginNameTextField.autocapitalizationType = .none
		loginNameTextField.keyboardType = .emailAddress
		loginNameTextField.textColor = textColor
		loginNameTextField.placeholder = "请输入用户名"
		loginNameTextField.layer.borderWidth = 1
		loginNameTextField.layer.borderColor = borderColor
		
		//Show only bottom border for textfield
		//		let bottomLine = CALayer()
		//		bottomLine.frame = CGRect(x: 0, y: loginNameTextField.frame.height - 1, width: loginNameTextField.frame.width, height: 1)
		//		bottomLine.backgroundColor = UIColor.red.cgColor
		//		loginNameTextField.borderStyle = .none
		//		loginNameTextField.layer.addSublayer(bottomLine)
		view.addSubview(loginNameTextField)
		
		passwordTextField.textColor = textColor
		passwordTextField.isSecureTextEntry = true	// Show * instead of actual characters
		passwordTextField.layer.borderWidth = 1
		passwordTextField.placeholder = "请输入密码"
		passwordTextField.layer.borderColor = borderColor
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

