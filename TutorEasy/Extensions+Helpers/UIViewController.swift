//
//  ViewController+ConfigProfileIcon.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/18.
//

import UIKit

extension UIViewController {
	
	func dismissKeyboard() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(UIViewController.dismissKeyboardTouchOutside))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}
	
	@objc private func dismissKeyboardTouchOutside() {
		view.endEditing(true)
	}
	
	var topViewHeight: CGFloat {
		view.frame.height * 0.1
	}
	
	// A container for goBack button, profile icon, etc
	// Leading and height anchors are varied between different vcs, needed to be set manually.
	func configTopView() -> UIView {
		let topView = UIView()
		view.addSubview(topView)
		topView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			topView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
		])
		return topView
	}
	
	func setUpGoBackButton(in superView: UIView, animated: Bool? = true) -> UIView {
		let image = UIImage(systemName: "backward.fill")
		
		let imageView = UIImageView(image: image)
		imageView.tintColor = .gray
		//        imageView.backgroundColor = UIColor(white: 1, alpha: 0.6)
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
		 The simplest way of implementing all above methods should be as follows:
		 
		 class CustomButton: UIButton {
		 var testValue: String?
		 }
		 
		 let button = CustomButton()
		 button.addTarget(self, action: #selector(someFunc), for: .touchUpInside)
		 button.testValue = "asdf"
		 
		 @objc func someFunc(sender: CustomButton) {
		 if let string = sender.testValue {
		 // Do something with the string
		 }
		 }
		 */
		
		let tap = CustomTapGestureRecognizer(target: self, action: #selector(backButtonClicked))
		tap.animated = animated
		imageView.addGestureRecognizer(tap)
		imageView.isUserInteractionEnabled = true   // By default, isUserInteractionEnabled is set to false for UIImageView
		return imageView
	}
	
	/// This function configure the behaviour of the back button.
	/// - Parameter sender: The sender of this @objc function. You should subclass a UIControl class with custom properties here. Despite we have accepted an optional CustomTapGestureRecognizer as parameter and default to nil, when adding this function as selector for a UIButton(in AuthenticationVC for closeButton), the sender will still be presented and of type UIButton... the reason is hard to understand but that's the fact. Therefore when we try to read sender.animated value in backButtonClicked, app will crash since a UIButton doesn't have an property named 'animated'. So we have to subclass UIButton, downbelow as CustomButton, and created closeButton from it.
	@objc func backButtonClicked(sender: CustomTapGestureRecognizer? = nil) {
		guard let animated = sender?.animated else {
			self.navigationController?.popViewController(animated: true)
			return
		}
		self.navigationController?.popViewController(animated: animated)
	}
	
	func recursivelyDisableLongPress(view: UIView) {
		for rec in view.subviews.compactMap({$0.gestureRecognizers}).flatMap({$0}) {
			if rec is UILongPressGestureRecognizer {
				rec.isEnabled = false
			}
		}
		
		for view in view.subviews {
			if !view.subviews.isEmpty {
				recursivelyDisableLongPress(view: view)
			}
		}
	}
}

class CustomTapGestureRecognizer: UITapGestureRecognizer {
	var animated: Bool?
}

class CustomButton: UIButton {
	var animated: Bool?
}
