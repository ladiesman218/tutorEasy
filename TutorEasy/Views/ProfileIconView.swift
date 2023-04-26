//
//  ProfileIconView.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/29.
//

import UIKit

class ProfileIconView: UIView {

	// In some VCs, only icon(imageView) is needed, so we add an option in init method to control if extraInfo(title label) should be added to the view itself and constraint properly.
	// Title label will display username when logged in, and logOutTitle when not.
	static let logOutTitle = "未登录"

	let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = (AuthAPI.userInfo == nil) ? UIImage(systemName: "person.circle.fill")! : UIImage(systemName: "person.crop.circle")!
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
    var title: UILabel?
	
	init(frame: CGRect, extraInfo: Bool = false) {
        super.init(frame: frame)
		self.translatesAutoresizingMaskIntoConstraints = false

		// When this view is tapped, depending on if a user has logged in, different view controller should be pushed into navigation stack. Gesture recogizer should be added in this view instead of every view controller has this view, so target for the recogizer is self, and in profileIconClicked function, we use findViewController method to find the view controller, since that's the type of obejct that has a navigationController and can push new VC.
		let tap = UITapGestureRecognizer(target: self, action: #selector(profileIconClicked))
		addGestureRecognizer(tap)
		
		// Listen to loginStatusChanged notification, when it happens, update image and title accordingly.
        NotificationCenter.default.addObserver(self, selector: #selector(loginStatusChanged), name: loginChanged, object: nil)
		// According to documentation "If your app targets iOS 9.0 and later or macOS 10.11 and later, you do not need to unregister an observer that you created with this function. If you forget or are unable to remove an observer, the system cleans up the next time it would have posted to it."
        
		// Add imageView and its constraint, width is set equal to height, so is a square.
        self.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: self.heightAnchor),
        ])
        
		// If extraInfo is needed, init title label and add constraints.
        if extraInfo {
            title = UILabel()
			title!.text = AuthAPI.userInfo?.username ?? Self.logOutTitle
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
		Task {
			await MainActor.run { 
				if AuthAPI.userInfo != nil {
					// User has logged in
					imageView.image = UIImage(systemName: "person.crop.circle")!
					title?.text = AuthAPI.userInfo?.username
				} else {
					imageView.image = UIImage(systemName: "person.circle.fill")!
					title?.text = Self.logOutTitle
				}
				self.setNeedsDisplay()
			}
		}
    }
	
	@objc func profileIconClicked() {
		let destinationVC: UIViewController = (AuthAPI.userInfo != nil) ? AccountVC() : AuthenticationVC()
		// When a logged in user click profileIcon, go to manage profile view by default
		if let accountsVC = destinationVC as? AccountVC {
			accountsVC.currentVC = .profile
		}
		self.findViewController()!.navigationController?.pushIfNot(newVC: destinationVC, animated: true)
	}
}
