//
//  UIImage.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/5/3.
//

import UIKit

extension UIImage {
	
#warning("resized image data size base on image pixel/point size, current implementation doesn't change iamge data size")
	func resizedImage(with size: CGSize) -> UIImage? {
		// Create Graphics Context
		UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
		
		// Draw Image in Graphics Context
		draw(in: CGRect(origin: .zero, size: size))
		
		// Create Image from Current Graphics Context
		let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
		
		// Clean Up Graphics Context
		UIGraphicsEndImageContext()
		
		return resizedImage
	}
	
	func addTrail() -> UIImage {
		
		UIGraphicsBeginImageContextWithOptions(size, false, scale)
		// Draw original image
		draw(at: CGPoint.zero)

		// Rotate the drawing context, this rotates from the origin(0, 0) point
		let rotation = Double.pi / Double(-4)
		
		let ctx = UIGraphicsGetCurrentContext()!
		ctx.rotate(by: rotation)
		// Move drawing context left by one half of width, and down by whole height
		ctx.translateBy(x: -size.width / 4, y: size.height / 12)
		
		// Background of the string
		ctx.setFillColor(UIColor.systemYellow.cgColor)
		let rowHeight = size.height / 8
		let extraRect = CGRect(x: 0, y: 0, width: size.width / 2, height: rowHeight)
		ctx.fill(extraRect)
		
		// AttributedString
		let paragraphStyle = NSMutableParagraphStyle()
		// Horizontally center align the text
		paragraphStyle.alignment = .center
		
		let fontSize = rowHeight * 0.85
		let attrs: [NSAttributedString.Key: Any] = [
			.font: UIFont.systemFont(ofSize: fontSize),
			.foregroundColor: UIColor.white,
			.paragraphStyle: paragraphStyle,
			//				.baselineOffset: -(rowHeight - fontSize) / 2
		]
		let string = "免费"
		let attributedString = NSAttributedString(string: string, attributes: attrs)
		
		attributedString.draw(with: extraRect, options: .usesLineFragmentOrigin, context: nil)
		
		// Get image from current context
		let resultImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return resultImage ?? self
	}
	
}

extension UIColor {
	// Generate an image from a UIColor
	func convertToImage(size: CGSize) -> UIImage {
		let renderer = UIGraphicsImageRenderer(size: size)
		let image = renderer.image { (context) in
			self.setFill()
			context.fill(CGRect(origin: .zero, size: size))
		}
		return image
	}
}
