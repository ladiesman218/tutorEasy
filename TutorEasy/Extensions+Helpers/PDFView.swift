//
//  PDFView.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/5/30.
//

import UIKit
import PDFKit

extension PDFView {
	// Check if pdf is vertical or horizontal, set displayMode to .singlePageContinuous for vertical document, usePageViewController if it's horizontal. PageViewController's default displayMode is .singlePage
	func setDisPlayMode() {
		// Make sure pdfView has an document, and the document has at least 1 page
		guard let bounds = self.document?.page(at: 0)?.bounds(for: self.displayBox) else {
			return
		}
		
		if bounds.width >= bounds.height {
			// Horizontal
			// Configure PDFView to display one page at a time, while keep the ability to scroll up and down on the pdfView itself.
			self.usePageViewController(true)
		} else {
			// Vertical
			self.displayMode = .singlePageContinuous
			// Manually trigger viewDidLayoutSubviews here is needed, maybe becoz pageViewController works different than set displayMode.
			self.superview?.setNeedsLayout()
		}
	}
	
	// This function checks if a play button should be added, and will draw it if it should.
	@objc func drawPlayButton() {
		// All possible file extension for video used in pdf goes here
		let videoExtension = ["mp4"]
		
		// Make sure current page contains annotations(link is a form of annotation), otherwise bail out
		guard let annotations = self.currentPage?.annotations else { return }
		// Make sure video annotations hasn't been added, otherwise bail. This avoid adding same play button multiple times.
		guard !annotations.contains(where: {$0.isKind(of: VideoAnnotation.self)} ) else {
			return
		}
		
		// Loop through all annotations on current page that contains an actionable url, which the url itself contains one of path extensions defined in videoExtension array.
		for annotation in annotations {
			guard let action = annotation.action as? PDFActionURL else { continue }
			guard let url = action.url else { continue }
			
			// The link's extension has to be contained by videoExtension array, which means it's a link for a video file
			guard videoExtension.contains(url.pathExtension) else { continue }
			
			// Initialize a VideoAnnotation, add it to current page
			let size = CGFloat(integerLiteral: 80)	// Playbutton's size
			// Place the play button annotation to bottom left corner of the link's annotation area, offset by 20 points right and 20 upwards.
			let bounds = CGRect(x: annotation.bounds.minX + 20, y: annotation.bounds.minY + 20, width: size, height: size)
			let videoAnnotation = VideoAnnotation(bounds: bounds, properties: ["/A": action])
			self.currentPage?.addAnnotation(videoAnnotation)
		}
	}

}
