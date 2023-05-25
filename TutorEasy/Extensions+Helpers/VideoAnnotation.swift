//
//  VideoAnnotation.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/5/22.
//

import PDFKit

class VideoAnnotation: PDFAnnotation {

	convenience init(bounds: CGRect, properties: [AnyHashable : Any]?) {
		// bounds parameter is required in init function, but we will be copying properties when init the instance, and 
		self.init(bounds: bounds, forType: PDFAnnotationSubtype.link, withProperties: properties)
		// For some wierd reasons, custom annotation won't be displayed without a border lineWidth greater than 0
		let border = PDFBorder()
		border.lineWidth = 0.0001
		self.border = border
	}

	override func draw(with box: PDFDisplayBox, in context: CGContext) {
		// Draw original content.
		super.draw(with: box, in: context)

		UIGraphicsPushContext(context)
		context.saveGState()

		let playIcon = UIImage(named: "playButton.png")!

		// Drawing the image within the annotation’s bounds.
		guard let cgImage = playIcon.cgImage else { return }

		context.draw(cgImage, in: bounds)
		
		context.restoreGState()
		UIGraphicsPopContext()
	}
}
