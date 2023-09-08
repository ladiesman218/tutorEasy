//
//  ButtonCell.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/8/27.
//

import UIKit

class ButtonCell: UICollectionViewCell {
	static let identifier = "buttonCell"
	var button: ChapterButton!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
//		contentView.backgroundColor = .blue
	}
	
	required init?(coder: NSCoder) {
		fatalError("Hasn't been implemented yet")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		contentView.addSubview(button)
		button.frame = contentView.bounds
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		// Without this, scrolling too fast will cause some cells to have 2 buttons
		button.removeFromSuperview()
		button = nil
	}
}

