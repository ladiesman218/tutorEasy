//
//  UIButton.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/5/29.
//

import UIKit
// Seems like when added as a subview of UICollectionViewCell, UIbuton layout itself differently by default. Original answer at https://stackoverflow.com/a/22621613/7224424
extension UIButton {
	func centerVertically(padding: CGFloat = 0) {
		
		guard let imageViewSize = self.imageView?.frame.size,
			  let titleLabelSize = self.titleLabel?.frame.size else {
			return
		}
		
		self.imageEdgeInsets = UIEdgeInsets(
			top: 0,
			left: 0,
			bottom: titleLabelSize.height,
			right: 0
		)
		
		self.titleEdgeInsets = UIEdgeInsets(
			top: 0.0,
			left: -imageViewSize.width,
			bottom: -imageViewSize.height,
			right: 0.0
		)
	}
}

