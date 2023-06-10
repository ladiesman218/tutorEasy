//
//  UIButton.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/5/29.
//

import UIKit
// From https://stackoverflow.com/a/22621613/7224424 and modified to meet our needs for buttons added into the topView in ChapterDetailVC, to display links for teaching plan pdf, etc.
extension UIButton {
	func centerVertically(padding: CGFloat = 0) {
		
		guard let imageViewSize = self.imageView?.frame.size,
			  let titleLabelSize = self.titleLabel?.frame.size else {
			return
		}

		let totalHeight = imageViewSize.height + titleLabelSize.height + padding
		
		self.imageEdgeInsets = UIEdgeInsets(
			top: 0,
			left: 0.0,
			bottom: 0.0,
			right: -titleLabelSize.width
		)
		
		self.titleEdgeInsets = UIEdgeInsets(
			top: 0.0,
			left: -imageViewSize.width,
			bottom: -(totalHeight - titleLabelSize.height),
			right: 0.0
		)
		
		self.contentEdgeInsets = UIEdgeInsets(
			top: 0.0,
			left: 0.0,
			bottom: titleLabelSize.height,
			right: 0.0
		)
	}
}

