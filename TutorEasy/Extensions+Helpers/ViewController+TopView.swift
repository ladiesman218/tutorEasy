//
//  ViewController+ConfigProfileIcon.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/18.
//

import UIKit

extension UIViewController {
    
    func configTopView() -> UIView {
        let topView = UIView()
        topView.backgroundColor = .systemYellow
        view.addSubview(topView)
        topView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            topView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor, multiplier: 0.10),
        ])
        return topView
    }
    
    func configProfileView(in superView: UIView) {
        let iconView = UIView()
        let image = UIImage(systemName: "person.crop.circle")
        let imageView = UIImageView()
        let usernameLabel = UILabel()
        
        if isLoggedIn {
            imageView.image = image
            usernameLabel.text = "已登录"
        } else {
            imageView.image = image
            usernameLabel.text = "未登录"
        }
        //        usernameLabel.backgroundColor = .blue
        iconView.addSubview(imageView)
        iconView.addSubview(usernameLabel)
        superView.addSubview(iconView)
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconView.heightAnchor.constraint(equalTo: superView.heightAnchor, multiplier: 0.95),
            iconView.centerYAnchor.constraint(equalTo: superView.centerYAnchor),
            iconView.widthAnchor.constraint(greaterThanOrEqualToConstant: 300),
            iconView.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 20),
            
            imageView.leadingAnchor.constraint(equalTo: iconView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: iconView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: iconView.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            
            usernameLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor),
            usernameLabel.topAnchor.constraint(equalTo: iconView.topAnchor),
            usernameLabel.heightAnchor.constraint(equalTo: iconView.heightAnchor, multiplier: 0.5),
        ])
        
        iconView.layer.backgroundColor = UIColor.red.cgColor
        
        let tap = UITapGestureRecognizer( target: self, action: #selector(UIViewController.profileIconClicked))
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        
    }
    
    func setUpGoBackButton(in superView: UIView, animated: Bool? = true) {
        let image = UIImage(systemName: "backward.fill")
        
        let imageView = UIImageView(image: image)
        imageView.tintColor = .gray
        imageView.backgroundColor = UIColor(white: 1, alpha: 0.6)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        superView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: superView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: superView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: superView.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
        ])
        
        /* backButtonClicked() function only does 1 thing: pop current vc from navigation stack, but we wanna control the animated parameter's value in different senarios. The problem is target-action mechanism(which the selector uses) doesn't support passing in parameters, so we can't, say for example, #selector(backButtonClicked(animated: true)). So the hack approach is:
         1. Subclas a UIControl, in this case we are sub-classing UIGestureRecognizer, define an optional variable to hold the value we wanna pass into(Check definition of CustomTapGestureRecognizer class).
         2. Use the subclass to create the control, then set the customize value for the object.
         3. When defining the action method, accept the subclass as a parameter in function signature, then read the associated value inside the subclassed object.
            
         Original explanation should be found at https://programmingwithswift.com/pass-arguments-to-a-selector-with-swift/
         The simplest way of implementing all above thinks should be as follows:
         
         class CustomButton: UIButton {
         var testValue: String?
         }
         
         let button = CustomButton()
         button.addTarget(self, action: #selector(someFunc), for: .touchUpInside)
         button.testValue = "asdf"
         
         @objc func someFunc(sender: CustomButton) {
            if let string = sender.testValue {
                // Do something about the string
            }
         }
         */
        
        let tap = CustomTapGestureRecognizer(target: self, action: #selector(backButtonClicked))
        tap.animated = animated
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true   // By default, isUserInteractionEnabled is set for UIImageView
    }
    
    @objc func profileIconClicked() {
        let destinationVC: UIViewController = (isLoggedIn) ? AccountVC(nibName: nil, bundle: nil) : AuthenticationVC(nibName: nil, bundle: nil)
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    // Despite we have accepted an optional CustomTapGestureRecognizer as parameter and default to nil, when adding this function as selector for a UIButton(in AuthenticationVC for closeButton), the sender will still be presented and of type UIButton... the reason is hard to understand but that's the fact. Therefore when we try to read sender.animated value in backButtonClicked, app will crash since a UIButton doesn't have an property named 'animated'. So we have to subclass UIButton, downbelow as CustomButton, and created closeButton from it.
    @objc func backButtonClicked(sender: CustomTapGestureRecognizer? = nil) {
        
        guard let animated = sender?.animated else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        self.navigationController?.popViewController(animated: animated)
    }
}

class CustomTapGestureRecognizer: UITapGestureRecognizer {
    var animated: Bool?
}

class CustomButton: UIButton {
    var animated: Bool?
}
