//
//  UILable + inset.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/3/31.
//

import Foundation
import UIKit

class PaddingLabel: UILabel {
	var textEdgeInsets = UIEdgeInsets.zero {
		didSet { invalidateIntrinsicContentSize() }
	}
	
	open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
		let textSize = self.font.pointSize

		// Magic numbers to set left & right inset
		textEdgeInsets.left = textSize * 1.5
		textEdgeInsets.right = textSize * 2
		
		let insetRect = bounds.inset(by: textEdgeInsets)
		let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
		let invertedInsets = UIEdgeInsets(top: -textEdgeInsets.top, left: -textEdgeInsets.left, bottom: -textEdgeInsets.bottom, right: -textEdgeInsets.right)
		return textRect.inset(by: invertedInsets)
	}
	
	override func drawText(in rect: CGRect) {
		super.drawText(in: rect.inset(by: textEdgeInsets))
	}
	
	
}
