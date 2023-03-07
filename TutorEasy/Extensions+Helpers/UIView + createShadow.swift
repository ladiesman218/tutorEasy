//
//  UIView + createShadow.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/1/27.
//

import UIKit

extension UIView {
	func createShadow() {
		let dimension = self.bounds.size.width
		let multiplier = 0.07
		self.layer.shadowColor = UIColor.gray.cgColor
		self.layer.shadowOffset = .init(width: dimension * multiplier, height: -(dimension * multiplier))
		self.layer.shadowOpacity = 1
		self.layer.shadowRadius = 1
		// Generating shadows dynamically is expensive, because iOS has to draw the shadow around the exact shape of your view's contents. If you can, set the shadowPath property to a specific value so that iOS doesn't need to calculate transparency dynamically. Value 20 comes from the cornerRadius value of CourseCell's contentView
		self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: dimension * cornerRadiusMultiplier).cgPath
	}
}

