//
//  ViewController+ConfigProfileIcon.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/18.
//

import UIKit
import PDFKit

extension UIViewController {
	
	func dismissKeyboard() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(UIViewController.dismissKeyboardTouchOutside))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}
	
	@objc private func dismissKeyboardTouchOutside() {
		view.endEditing(true)
	}
	
	static var topViewHeight: CGFloat {
		return UIScreen.main.bounds.height * 0.1
	}
	
	// A container for goBack button, profile icon, etc
	// Leading and height anchors are varied between different vcs, needed to be set manually.
	// In fact only VC wherein topView's height will change is ChapterDetailVC, when full screen is toggled, topView's height could change between UIViewController's topViewHeight(custom computed property defined in its extension) and 0. We can constraint height to topViewHeight here and remove all height constraint settings in other VCs, but in ChapterDetailVC when toggling full screen mode, it generated warning messages in console says can't satisfy constraints at the same time, things will work but the console messages are annoying, so we make height anchor not fixed.
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
	
	/// Disables double tap(text selection) for the given PDFView.
	///
	/// Double tap and "tap then drag" won't enable selection on iOS16, but for iOS13 it will, so it is needed for disabling these behaviors for iOS13.
	/// - Warning: Call this method AFTER PDFView's document is set, otherwise it won't work.
	/// - Warning: If you enabled [usePageViewController()](https://developer.apple.com/documentation/pdfkit/pdfview/2877501-usepageviewcontroller) for your PDFView, it seems when scrolling to change current page, gestures will be added again. A reasonable thought would be adding an observer for PDFViewPageChanged message, I tried, it only works sometimes. A better notification message to listen to is PDFViewVisiblePagesChanged, this way it always works. Again, observer should be added after PDFView's document has been set otherwise it won't work.
	/// - Parameter view: The instance of PDFView you need to disable text selection
	func recursivelyDisableSelection(view: UIView) {
		
		// Get all recognizers for the PDFView's subviews. Here we are ignoring the recognizers for the PDFView itself, since we know from testing that's not the reason for the mess.
		for rec in view.subviews.compactMap({$0.gestureRecognizers}).flatMap({$0}) {
			// UITapAndAHalfRecognizer is for a gesture like "tap first, then tap again and drag", this gesture also enable's text selection
			if rec is UILongPressGestureRecognizer || type(of: rec).description() == "UITapAndAHalfRecognizer" {
				rec.isEnabled = false
			}
		}
		
		// For all subviews, if they do have subview in itself, disable the above 2 gestures as well.
		for view in view.subviews {
			if !view.subviews.isEmpty {
				recursivelyDisableSelection(view: view)
			}
		}
	}
	
	// Find PDFView in view's subviews, then call its drawPlayButton. Essentially a wrapper so we can call the function directly in different view controllers.
	@objc func drawPlayButton() {
		guard let pdfView = view.subviews.first(where: { view in
			view is PDFView
		}) as? PDFView else { return }
		pdfView.drawPlayButton()
	}

}

class CustomTapGestureRecognizer: UITapGestureRecognizer {
	var animated: Bool?
}

class CustomButton: UIButton {
	var animated: Bool?
}
