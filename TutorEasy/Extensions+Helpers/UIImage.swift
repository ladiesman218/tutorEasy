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
	
	static func load(from url: URL?, size: CGSize) async throws -> UIImage {
		guard let url = url else {
			// Generate a image if imageURL is nil, so skeletonView can be stopped.
			let image = UIColor.blue.convertToImage(size: size)
			return image
		}
		
		let req = FileAPI.convertToImageRequest(url: url)
		let image = try await FileAPI.publicGetImageData(request: req, size: size)
		try Task.checkCancellation()
		return image
	}
}

extension UIColor {
	func convertToImage(size: CGSize) -> UIImage {
		let renderer = UIGraphicsImageRenderer(size: size)
		let image = renderer.image { (context) in
			self.setFill()
			context.fill(CGRect(origin: .zero, size: size))
		}
		
		return image
	}
}
