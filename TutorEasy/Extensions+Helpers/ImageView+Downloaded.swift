import UIKit


// This is a hack from https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
extension UIImageView {
	
	func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit, addTrial: Bool = false) {
		contentMode = contentMode
		Task {
			if let data = try? await FileAPI.publicGetImageData(path: link).get() {
				self.image = UIImage(data: data)
				if addTrial { drawTrail() }
				self.setNeedsDisplay()
			}
		}
	}

	func drawTrail() {
		let originalImage: UIImage? = self.image
		let size = self.bounds.size

		let renderer = UIGraphicsImageRenderer(size: size)

		let img = renderer.image { ctx in
			// draw the orginal image if there is one
			originalImage?.draw(in: .init(origin: .zero, size: size))
			
			// Rotate the drawing context, this rotate from the origin(0, 0) point
			let rotation = Double.pi / Double(-4)
			ctx.cgContext.rotate(by: rotation)
			// Move drawing context left by one half of width, and down by whole height
			ctx.cgContext.translateBy(x: -size.width / 2, y: size.height)


			// background of the string
			ctx.cgContext.setFillColor(UIColor.systemYellow.cgColor)
			let rowHeight = size.height / 4
			let extraRect = CGRect(x: 0, y: 0, width: size.width, height: rowHeight)
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
		self.image = img
	}

}

func downloadImages(urls: [URL?]) async -> [UIImage?] {
	return await withTaskGroup(of: (Int, Data?).self, body: { group in
		var images: [UIImage?] = .init(repeating: nil, count: urls.count)

		for (index, url) in urls.enumerated() {
			group.addTask {
				if let url = url {
					let data = try? await FileAPI.publicGetImageData(path: url.path).get()
					return (index, data)
				}
				return (index, nil)
			}
			
		}
		
		for await result in group {
			if let data = result.1 {
				images[result.0] = UIImage(data: data)
			}
		}
		return images
	})
}
