//
//  UIbutton.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/5/28.
//

import UIKit

// Used to display links for teaching plan pdf, etc.
class ChapterButton: UIButton {
	
	convenience init(image: UIImage, titleText: String, fontSize: CGFloat) {
		self.init()
		setImage(image, for: .normal)
		// Keep original ratio while resizing the button's image.
		imageView?.contentMode = .scaleAspectFit
		setTitle(titleText, for: .normal)
		// By default, fontsize for title lable can be varied by its character length, in order to fix in view's bounds without truncation. We need to fix font size so despite each button's string length is different, they all appear as same size.
		titleLabel?.font = titleLabel?.font.withSize(fontSize)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.centerVertically()
	}
}
