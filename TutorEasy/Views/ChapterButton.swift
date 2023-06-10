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
		translatesAutoresizingMaskIntoConstraints = false
	}
	
	// Since both titlelable's string/character length and its fontsize were set in init function, we can use string.size(withAttributes attrs: [NSAttributedString.Key : Any]? = nil) -> CGSize and pass in the fontSize to get the actual size of the lable, therefore its witdh which we care about. Then we can define this custom `width` variable to get the larger on between the 2: titleLable's actual width and VC's topViewHeight, and use this variable's value to set width constraint for the button.
	// If title lable's actual width is larger, set button's width to it so text won't clipping. If not, constraint button's to topViewHeight, so the button apprears as a square, therefore imageView takes as much space as possible.
	var width: CGFloat {
		let titleWidth = self.titleLabel!.text!.size(withAttributes: [.font: UIFont.systemFont(ofSize: self.titleLabel!.font.pointSize)]).width
		return max(UIViewController.topViewHeight, titleWidth)
	}
}
