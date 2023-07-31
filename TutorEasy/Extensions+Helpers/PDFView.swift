//
//  PDFView.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/5/30.
//

import UIKit
import PDFKit

extension PDFView {
	open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		return false
	}
}
