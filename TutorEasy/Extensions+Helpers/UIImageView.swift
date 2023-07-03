import UIKit
import SkeletonView

extension UIImageView {
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
		self.image = img
	}
}
