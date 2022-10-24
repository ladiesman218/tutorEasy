//
//  ViewController+ConfigProfileIcon.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/18.
//

import UIKit

extension UIViewController {
    
    func configProfileView() -> UIView {
        let view = UIView()
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
        view.addSubview(imageView)
        view.addSubview(usernameLabel)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            
            usernameLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor),
            usernameLabel.topAnchor.constraint(equalTo: view.topAnchor),
            usernameLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
        ])

        view.layer.backgroundColor = UIColor.red.cgColor
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(UIViewController.profileIconClicked))
        
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        
        return view
    }
        
    @objc func profileIconClicked() {
        let destinationVC: UIViewController = (isLoggedIn) ? AccountVC(nibName: nil, bundle: nil) : AuthenticationVC(nibName: nil, bundle: nil)
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
}
