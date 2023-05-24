//
//  PDFView.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/5/24.
//

import PDFKit

extension PDFView {
	func recursivelyDisableLongPress(view: UIView) {
		// Disable for the view itself
		if let gestureRecognizers = view.gestureRecognizers {
			gestureRecognizers.forEach {
				if $0 is UILongPressGestureRecognizer {
					print("disabled")
					$0.isEnabled = false
				}
			}
		}
		
		// Get all recs for its subviews, disbale them
		for rec in view.subviews.compactMap({$0.gestureRecognizers}).flatMap({$0}) {
			if rec is UILongPressGestureRecognizer {
				rec.isEnabled = false
			}
		}
		
		for view in view.subviews {
			if !view.subviews.isEmpty {
				recursivelyDisableLongPress(view: view)
			}
		}
	}
}
