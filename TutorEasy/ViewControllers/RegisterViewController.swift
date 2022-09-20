//
//  RegisterViewController.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/8/25.
//

import UIKit

class RegisterViewController: UIViewController {
	
	private var registrationEmailTextField: UITextField!
	private var usernameTextField: UITextField!
	private var passwordTextField: UITextField!
	private var password2TextField: UITextField!
	private var registerButton: UIButton!
	
	static private let borderColor = UIColor.systemGray.cgColor//UIColor.gray.cgColor
	static private let textColor = UIColor.systemBlue//UIColor.cyan
	
	override func viewDidLoad() {
				
		super.viewDidLoad()
		registrationEmailTextField = UITextField()
		usernameTextField = UITextField()
		passwordTextField = UITextField()
		password2TextField = UITextField()
		registerButton = UIButton()
		
		registrationEmailTextField.autocapitalizationType = .none
		registrationEmailTextField.keyboardType = .emailAddress
		registrationEmailTextField.placeholder = "请输入邮箱地址(必填)"
		registrationEmailTextField.textColor = Self.textColor
		registrationEmailTextField.layer.borderWidth = 1
		registrationEmailTextField.layer.borderColor = Self.borderColor
		view.addSubview(registrationEmailTextField)
		
		usernameTextField.autocapitalizationType = .none
		usernameTextField.placeholder = "用户名(必填)，4-35个字符之间"
		usernameTextField.textColor = Self.textColor
		usernameTextField.layer.borderColor = Self.borderColor
		usernameTextField.layer.borderWidth = 1
		view.addSubview(usernameTextField)
		
		passwordTextField.textColor = Self.textColor
		passwordTextField.isSecureTextEntry = true	// Show * instead of actual characters
		passwordTextField.placeholder = "密码，6-40个字符之间"
		passwordTextField.layer.borderWidth = 1
		passwordTextField.layer.borderColor = Self.borderColor
		view.addSubview(passwordTextField)
		
		password2TextField.textColor = Self.textColor
		password2TextField.isSecureTextEntry = true	// Show * instead of actual characters
		password2TextField.placeholder = "再次输入密码"
		password2TextField.layer.borderWidth = 1
		password2TextField.layer.borderColor = Self.borderColor
		view.addSubview(password2TextField)

		registerButton.setTitle("注册", for: .normal)
		registerButton.sizeToFit()
		registerButton.addTarget(self, action: #selector(register), for: .touchUpInside)
		registerButton.backgroundColor = UIColor.purple
		registerButton.layer.cornerRadius = 10
		view.addSubview(registerButton)
		
		registrationEmailTextField.translatesAutoresizingMaskIntoConstraints = false
		passwordTextField.translatesAutoresizingMaskIntoConstraints = false
		password2TextField.translatesAutoresizingMaskIntoConstraints = false
		registerButton.translatesAutoresizingMaskIntoConstraints = false
		usernameTextField.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			
			registrationEmailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			registrationEmailTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
			registrationEmailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			
			usernameTextField.leadingAnchor.constraint(equalTo: registrationEmailTextField.leadingAnchor),
			usernameTextField.topAnchor.constraint(equalTo: registrationEmailTextField.bottomAnchor, constant: 20),
			usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			
			passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
			passwordTextField.widthAnchor.constraint(equalTo: registrationEmailTextField.widthAnchor),
			
			password2TextField.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
			password2TextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
			password2TextField.widthAnchor.constraint(equalTo: passwordTextField.widthAnchor),
			
			registerButton.topAnchor.constraint(equalTo: password2TextField.bottomAnchor, constant: 20),
			registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			registerButton.widthAnchor.constraint(equalTo: registrationEmailTextField.widthAnchor, multiplier: 0.8)
		])
	}
	
	@objc func register() {
		guard let email = registrationEmailTextField.text, !email.isEmpty && email.range(of: emailRegex, options: .regularExpression) != nil else {
			MessagePresenter.showMessage(title: "无效邮箱地址", message: "请填写正确的邮箱地址", on: self, actions: [])
			return
		}
		
		guard let username = usernameTextField.text, !username.isEmpty else {
			MessagePresenter.showMessage(title: "无效用户名", message: "", on: self, actions: [])
			return
		}
		
		guard let password1 = passwordTextField.text, !password1.isEmpty else {
			MessagePresenter.showMessage(title: "密码不能为空", message: "请输入密码", on: self, actions: [])
			return
		}
		
		guard let password2 = password2TextField.text, !password2.isEmpty || password2 != password1 else {
			MessagePresenter.showMessage(title: "两次输入密码不同", message: "请确认两次输入的密码完全一致", on: self, actions: [])
			return
		}
		
		let registerInput = User.RegisterInput(email: email, username: username, firstName: nil, lastName: nil, password1: password1, password2: password2)
		
		Auth.register(registerInput: registerInput) { result in
			switch result {
			case .success:
				Auth.login(username: registerInput.username, password: registerInput.password1) { _ in
					DispatchQueue.main.async {
						let languageVC = LanguagesVC()
						let navVC = UINavigationController(rootViewController: languageVC)
						self.present(navVC, animated: true)
					}
				}
			case .failure(let reason):
				let reason = reason
				MessagePresenter.showMessage(title: "注册失败", message: "\(reason)", on: self, actions: [])
			}
		}
		
			
			
	}
}
