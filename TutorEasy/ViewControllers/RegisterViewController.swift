//
//  RegisterViewController.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/8/25.
//

import UIKit

class RegisterViewController: UIViewController {
    
    private let registrationEmailTextField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        textField.placeholder = "请输入邮箱地址(必填)"
        textField.textColor = textColor
        textField.layer.borderWidth = 1
        textField.layer.borderColor = borderColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.placeholder = "用户名(必填)，4-35个字符之间"
        textField.textColor = textColor
        textField.layer.borderColor = borderColor
        textField.layer.borderWidth = 1
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = textColor
        textField.isSecureTextEntry = true    // Show * instead of actual characters
        textField.placeholder = "密码，6-40个字符之间"
        textField.layer.borderWidth = 1
        textField.layer.borderColor = borderColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let password2TextField: UITextField = {
        let textField = UITextField()
        textField.textColor = textColor
        textField.isSecureTextEntry = true    // Show * instead of actual characters
        textField.placeholder = "再次输入密码"
        textField.layer.borderWidth = 1
        textField.layer.borderColor = borderColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("注册", for: .normal)
        button.backgroundColor = UIColor.purple
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(registrationEmailTextField)
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(password2TextField)
        view.addSubview(registerButton)
        registerButton.addTarget(self, action: #selector(register), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            
            registrationEmailTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            registrationEmailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            registrationEmailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            usernameTextField.leadingAnchor.constraint(equalTo: registrationEmailTextField.leadingAnchor),
            usernameTextField.topAnchor.constraint(equalTo: registrationEmailTextField.bottomAnchor, constant: 20),
            usernameTextField.widthAnchor.constraint(equalTo: registrationEmailTextField.widthAnchor),
            
            passwordTextField.leadingAnchor.constraint(equalTo: registrationEmailTextField.leadingAnchor),
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalTo: registrationEmailTextField.widthAnchor),
            
            password2TextField.leadingAnchor.constraint(equalTo: registrationEmailTextField.leadingAnchor),
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
        
		Task {
			do {
				let _ = try await AuthAPI.register(input: registerInput).get()
				// Here means registration process is successful, then we go login the user
				let _ = try await AuthAPI.login(username: registerInput.username, password: registerInput.password1).get()
				self.backButtonClicked()
			} catch {
				error.present(on: self, title: "注册失败", actions: [])
			}
		}
    }
}
