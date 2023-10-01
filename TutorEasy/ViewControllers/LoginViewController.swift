//
//  ViewController.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/6/23.
//

import UIKit

class LoginViewController: UIViewController {
	//MARK: - Custom Views
	private let loginNameTextField: UITextField = {
		let textField = UITextField()
		textField.autocapitalizationType = .none
		textField.keyboardType = .emailAddress
		textField.textColor = textColor
		textField.placeholder = "请输入用户名"
		textField.layer.borderWidth = 1
		textField.layer.borderColor = borderColor
		textField.translatesAutoresizingMaskIntoConstraints = false
		return textField
		//Show only bottom border for textfield
		//        let bottomLine = CALayer()
		//        bottomLine.frame = CGRect(x: 0, y: loginNameTextField.frame.height - 1, width: loginNameTextField.frame.width, height: 1)
		//        bottomLine.backgroundColor = UIColor.red.cgColor
		//        loginNameTextField.borderStyle = .none
		//        loginNameTextField.layer.addSublayer(bottomLine)
	}()
	
	private let passwordTextField: UITextField = {
		let textField = UITextField()
		textField.textColor = textColor
		textField.isSecureTextEntry = true    // Show * instead of actual characters
		textField.layer.borderWidth = 1
		textField.placeholder = "请输入密码"
		textField.layer.borderColor = borderColor
		textField.translatesAutoresizingMaskIntoConstraints = false
		
		return textField
	}()
	
	private let loginButton: UIButton = {
		let button = UIButton()
		button.setTitle("登录", for: .normal)
		button.layer.cornerRadius = 10
		button.backgroundColor = UIColor.purple
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private let loginIndicator: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView()
		indicator.color = .systemYellow
		indicator.hidesWhenStopped = true
		indicator.style = .large
		indicator.translatesAutoresizingMaskIntoConstraints = false
		return indicator
	}()
	
	private let forgetPWButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("忘记密码", for: .normal)
		button.setTitleColor(.systemBlue, for: .normal)
		return button
	}()
	
	//MARK: - Custom Functions
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		forgetPWButton.titleLabel?.font = forgetPWButton.titleLabel?.font.withSize(loginNameTextField.frame.height * 0.7)
	}
	
	@objc private func login() {
		guard let username = loginNameTextField.text, !username.isEmpty else {
			MessagePresenter.showMessage(title: "无效用户名", message: "请输入用户名", on: self, actions: [])
			return
		}
		
		guard let password = passwordTextField.text, !password.isEmpty else {
			MessagePresenter.showMessage(title: "无效密码", message: "请输入密码", on: self, actions: [])
			return
		}
		
		// Disable login button and display activity indicator
		loginIndicator.startAnimating()
		loginButton.isEnabled = false
		loginButton.backgroundColor = UIColor.systemGray
		
		Task { [weak self] in
			do {
				try await AuthAPI.login(username: username, password: password)
				self?.navigationController?.popViewController(animated: true)
			} catch {
				guard let strongSelf = self else { return }
				error.present(on: strongSelf, title: "登录失败", actions: [])
			}
			// When success, popViewController will make self deinitialized, following won't be called but that's okay.
			self?.loginIndicator.stopAnimating()
			self?.loginButton.backgroundColor = UIColor.purple
			self?.loginButton.isEnabled = true
		}
	}
	
	@objc private func forgetPassword() {
		print("clicked")
	}
	
	// MARK: - Controller Functions
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		
		view.addSubview(loginNameTextField)
		view.addSubview(passwordTextField)
		loginButton.addSubview(loginIndicator)
		view.addSubview(loginButton)
		loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
		view.addSubview(forgetPWButton)
		forgetPWButton.addTarget(self, action: #selector(forgetPassword), for: .touchUpInside)
		
		NSLayoutConstraint.activate([
			loginNameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
			loginNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
			loginNameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
			
			passwordTextField.leadingAnchor.constraint(equalTo: loginNameTextField.leadingAnchor),
			passwordTextField.topAnchor.constraint(equalTo: loginNameTextField.bottomAnchor, constant: 20),
			passwordTextField.widthAnchor.constraint(equalTo: loginNameTextField.widthAnchor),
			
			forgetPWButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor),
			forgetPWButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
			
			loginButton.topAnchor.constraint(equalTo: forgetPWButton.bottomAnchor, constant: 20),
			loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			loginButton.widthAnchor.constraint(equalTo: loginNameTextField.widthAnchor, multiplier: 0.8),
			
			loginIndicator.topAnchor.constraint(equalTo: loginButton.topAnchor),
			loginIndicator.leadingAnchor.constraint(equalTo: loginButton.titleLabel!.trailingAnchor)
		])
	}
}

