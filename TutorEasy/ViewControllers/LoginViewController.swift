//
//  ViewController.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/6/23.
//

import UIKit

class LoginViewController: UIViewController {
    
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
        
        view.addSubview(loginNameTextField)
        loginNameTextField.becomeFirstResponder()
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        
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

