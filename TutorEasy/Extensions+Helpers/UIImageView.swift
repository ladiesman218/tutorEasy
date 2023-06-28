import UIKit
import SkeletonView

extension UIImageView {
	func downloaded(from link: String?, contentMode mode: ContentMode = .scaleAspectFit) {
		contentMode = contentMode
		
		if let link = link {
			Task {
				self.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .amethyst), animation: nil, transition: .crossDissolve(1))
				if let image = try? await FileAPI.publicGetImageData(path: link) {
					await MainActor.run {
						self.image = image
					}
				}

				self.stopSkeletonAnimation()
				self.hideSkeleton(reloadDataAfter: false, transition: .crossDissolve(1))
				self.setNeedsDisplay()
			}
		}
	}
	
//	func drawName(name: String) {
//		let originalImage: UIImage? = self.image
//		let size = self.bounds.size
//		
//		let renderer = UIGraphicsImageRenderer(size: size)
//		
//		let img = renderer.image { ctx in
//			// draw the orginal image if there is one
//			originalImage?.draw(in: .init(origin: .zero, size: size))
//			// background of the string
//			ctx.cgContext.setFillColor(UIColor.systemYellow.cgColor)
//			let rowHeight = size.height / 5
//			// Use this rect to fill background color
//			let extraRect = CGRect(origin: .zero, size: .init(width: size.width, height: rowHeight))
//			// Move the rect down
//			ctx.cgContext.translateBy(x: 0, y: size.height - rowHeight)
//			ctx.cgContext.fill(extraRect)
//			
//			// AttributedString
//			let paragraphStyle = NSMutableParagraphStyle()
//			// Horizontally center align the text
//			paragraphStyle.alignment = .center
//			
//			let fontSize = rowHeight * 0.5
//			let attrs: [NSAttributedString.Key: Any] = [
//				.font: UIFont.systemFont(ofSize: fontSize),
//				.foregroundColor: UIColor.white,
//				.paragraphStyle: paragraphStyle,
//				.baselineOffset: -rowHeight / 5
//			]
//			
//			let attributedString = NSAttributedString(string: name, attributes: attrs)
//			attributedString.draw(with: extraRect, options: .usesLineFragmentOrigin, context: nil)
//		}
//		self.image = img
//	}
	
	func drawTrail() {
		let originalImage: UIImage? = self.image
		let size = self.bounds.size
		
		let renderer = UIGraphicsImageRenderer(size: size)
		
		let img = renderer.image { ctx in
			// draw the orginal image if there is one
			originalImage?.draw(in: .init(origin: .zero, size: size))
			// Rotate the drawing context, this rotates from the origin(0, 0) point
			let rotation = Double.pi / Double(-4)
			ctx.cgContext.rotate(by: rotation)
			// Move drawing context left by one half of width, and down by whole height
			ctx.cgContext.translateBy(x: -size.width / 4, y: size.height / 12)
			
			// background of the string
			ctx.cgContext.setFillColor(UIColor.systemYellow.cgColor)
			let rowHeight = size.height / 8
			let extraRect = CGRect(x: 0, y: 0, width: size.width / 2, height: rowHeight)
			ctx.cgContext.fill(extraRect)
			
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
		}
		
		Task { @MainActor in
			self.image = img
		}
		
	}
	
}

func downloadImages(urls: [URL?]) async -> [UIImage?] {
	return await withTaskGroup(of: (Int, UIImage?).self, body: { group in
		var images: [UIImage?] = .init(repeating: nil, count: urls.count)
		
		for (index, url) in urls.enumerated() {
			group.addTask {
				if let url = url {
					let image = try? await FileAPI.publicGetImageData(path: url.path)
					return (index, image)
				}
				return (index, nil)
			}
			
		}
		
		for await result in group {
			if let image = result.1 {
				images[result.0] = image
			}
		}
		return images
	})
}
