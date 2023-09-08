//
//  AccountsVC.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/8/25.
//

import UIKit
#warning("Terms of Service and Privacy Policy info links according to https://developer.apple.com/design/human-interface-guidelines/technologies/in-app-purchase")

class AuthenticationVC: UIViewController {
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
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
    
    private let closeButton: CustomButton = {
        let button = CustomButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.setTitle("暂不登录", for: .normal)
        button.setTitleColor(.systemTeal, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
	#warning("what error message will be shown when login info is wrong")
    private let loginVC = LoginViewController()
    private lazy var registerVC = RegisterViewController()
    
    static private let activeBgColor = UIColor.blue
    static private let deactiveBgColor = UIColor.gray
    static private let buttonCornerRadius = CGFloat(10)
    
    var shorterConstraint: NSLayoutConstraint!
    var tallerConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dismissKeyboard()
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "LoginBg")!)
        
        loginViewButton.addTarget(self, action: #selector(switchVCs), for: .touchUpInside)
        view.addSubview(loginViewButton)
        
        registerViewButton.addTarget(self, action: #selector(switchVCs), for: .touchUpInside)
        view.addSubview(registerViewButton)
        
        view.addSubview(containerView)
        
        closeButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        view.addSubview(closeButton)
        
        shorterConstraint = containerView.heightAnchor.constraint(equalToConstant: 200)
        tallerConstraint = containerView.heightAnchor.constraint(equalToConstant: 250)

        // Two switch view buttons are constrained above container view rather than in the container view itself.
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            closeButton.heightAnchor.constraint(equalToConstant: 30),

            containerView.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 15),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            shorterConstraint,
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            
            loginViewButton.bottomAnchor.constraint(equalTo: containerView.topAnchor),
            loginViewButton.heightAnchor.constraint(equalToConstant: 40),
            loginViewButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            loginViewButton.widthAnchor.constraint(greaterThanOrEqualTo: containerView.widthAnchor, multiplier: 0.5),//equalTo: view.widthAnchor, multiplier: 0.3),
            
            registerViewButton.leadingAnchor.constraint(equalTo: loginViewButton.trailingAnchor),
            registerViewButton.topAnchor.constraint(equalTo: loginViewButton.topAnchor),
            registerViewButton.heightAnchor.constraint(equalTo: loginViewButton.heightAnchor),
            registerViewButton.widthAnchor.constraint(equalTo: loginViewButton.widthAnchor),
            
            
        ])
        
        // Default to login view
        switchVCs(sender: loginViewButton)
    }
    
    @objc private func switchVCs(sender: UIButton) {
        if sender.tag == 0 {
            registerViewButton.backgroundColor = Self.deactiveBgColor
            registerVC.view.removeFromSuperview()
            registerVC.removeFromParent()
            tallerConstraint.isActive = false
            
            loginViewButton.backgroundColor = Self.activeBgColor
            self.addChild(loginVC)
            containerView.addSubview(loginVC.view)
            shorterConstraint.isActive = true
            
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
            shorterConstraint.isActive = false
            
            registerViewButton.backgroundColor = Self.activeBgColor
            self.addChild(registerVC)
            containerView.addSubview(registerVC.view)
            tallerConstraint.isActive = true
            
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
