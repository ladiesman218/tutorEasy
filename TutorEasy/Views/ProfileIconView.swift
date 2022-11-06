//
//  ProfileIconView.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/29.
//

import UIKit

class ProfileIconView: UIView {
    
    let imageView = UIImageView()
    var title: UILabel?
    
    init(frame: CGRect, extraInfo: Bool = false) {
        super.init(frame: frame)
        
        if AuthAPI.userInfo != nil {
            // User has logged in
            imageView.image = UIImage(systemName: "person.crop.circle")!
        } else {
            imageView.image = UIImage(systemName: "person.circle.fill")!
        }
        
        // According to documentation "If your app targets iOS 9.0 and later or macOS 10.11 and later, you do not need to unregister an observer that you created with this function. If you forget or are unable to remove an observer, the system cleans up the next time it would have posted to it."
        NotificationCenter.default.addObserver(self, selector: #selector(loginStatusChanged), name: loginChanged, object: nil)
        
        self.layer.backgroundColor = UIColor.red.cgColor
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: self.heightAnchor),
        ])
        
        if extraInfo {
            title = UILabel()
            title!.text = (AuthAPI.userInfo != nil) ? "已登录" : "未登录"
            title!.textColor = .black
            title!.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(title!)
            NSLayoutConstraint.activate([
                title!.leadingAnchor.constraint(equalTo: imageView.trailingAnchor),
                title!.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func loginStatusChanged() {
        DispatchQueue.main.async { [unowned self] in
            if AuthAPI.userInfo != nil {
                // User has logged in
                imageView.image = UIImage(systemName: "person.crop.circle")!
                title?.text = "已登录"
            } else {
                imageView.image = UIImage(systemName: "person.circle.fill")!
                title?.text = "未登录"
            }
            self.setNeedsDisplay()
        }
    }
}
