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
	
}
