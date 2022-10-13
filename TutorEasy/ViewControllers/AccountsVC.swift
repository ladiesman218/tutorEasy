//
//  AccountsVC.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/8/25.
//

import UIKit

class AccountsVC: UIViewController {
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private let loginViewButton: UIButton = {
        let button = UIButton()
        button.tag = 0
        button.setTitle("登录", for: .init())
        button.backgroundColor = activeBgColor
        button.layer.cornerRadius = buttonCornerRadius
        button.layer.maskedCorners = [.layerMinXMinYCorner]
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let registerViewButton: UIButton = {
        let button = UIButton()
        button.tag = 1
        button.setTitle("注册", for: .init())
        button.backgroundColor = deactiveBgColor
        button.layer.cornerRadius = buttonCornerRadius
        button.layer.maskedCorners = [.layerMaxXMinYCorner]
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loginVC = LoginViewController()
    private lazy var registerVC = RegisterViewController()
    
    static private let activeBgColor = UIColor.blue
    static private let deactiveBgColor = UIColor.gray
    static private let buttonCornerRadius = CGFloat(10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dismissKeyboard()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "LoginBg")!)
        
        loginViewButton.addTarget(self, action: #selector(switchVCs), for: .touchUpInside)
        view.addSubview(loginViewButton)
        
        registerViewButton.addTarget(self, action: #selector(switchVCs), for: .touchUpInside)
        view.addSubview(registerViewButton)
        
        view.addSubview(containerView)
        
        // Two switch view buttons are constrained above container view rather than in the container view itself.
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: loginViewButton.leadingAnchor),
            containerView.topAnchor.constraint(equalTo: loginViewButton.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: loginViewButton.widthAnchor, multiplier: 2),
            containerView.heightAnchor.constraint(equalToConstant: 250),
            
            loginViewButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            loginViewButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            loginViewButton.heightAnchor.constraint(equalToConstant: 40),
            loginViewButton.widthAnchor.constraint(equalToConstant: 150),
            
            registerViewButton.leadingAnchor.constraint(equalTo: loginViewButton.trailingAnchor),
            registerViewButton.topAnchor.constraint(equalTo: loginViewButton.topAnchor),
            registerViewButton.heightAnchor.constraint(equalTo: loginViewButton.heightAnchor),
            registerViewButton.widthAnchor.constraint(equalTo: loginViewButton.widthAnchor)
            
        ])
        
        // Default to login view
        switchVCs(sender: loginViewButton)
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
}
