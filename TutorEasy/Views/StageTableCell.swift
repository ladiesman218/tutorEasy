//
//  StageTableCell.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/6/15.
//

import UIKit

class StageTableCell: UITableViewCell {
	static let identifier = "StageTableCellIdentifier"

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
		
		imageView?.contentMode = .scaleAspectFill
		imageView?.clipsToBounds = true
		imageView?.translatesAutoresizingMaskIntoConstraints = false
		
		// Set detailTextLabel to have 3 lines at most, when overflow, truncate tail
		detailTextLabel?.numberOfLines = 3
		detailTextLabel?.allowsDefaultTighteningForTruncation = true
		detailTextLabel?.lineBreakMode = .byTruncatingTail
		
		NSLayoutConstraint.activate([
			imageView!.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			imageView!.topAnchor.constraint(equalTo: contentView.topAnchor),
			imageView!.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			imageView!.widthAnchor.constraint(equalTo: imageView!.heightAnchor),
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
//	override func layoutSubviews() {
//		super.layoutSubviews()
//		let height = self.contentView.frame.height
//		self.imageView?.frame.size = .init(width: height, height: height)
//		self.imageView?.image = nil
//
////		let frame = CGRect(origin: .zero, size: .init(width: height, height: height))
////		self.imageView?.frame = frame
//	}
}
