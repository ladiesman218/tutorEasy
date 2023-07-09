//
//  StageTableCell.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/6/15.
//

import UIKit
import SkeletonView

class StageCollectionCell: UICollectionViewCell {
	static let identifier = "StageCellIdentifier"
	var loadStageTask: Task<Void, Never>?
	var loadImageTask: Task<Void, Error>?
	
	let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.isSkeletonable = true
		return imageView
	}()
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .left
		label.translatesAutoresizingMaskIntoConstraints = false
		
		label.isSkeletonable = true
		label.skeletonTextLineHeight = .relativeToFont
		label.skeletonTextNumberOfLines = 1
		label.lastLineFillPercent = 30
		
		return label
	}()
	
	let descriptionLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
//		 Set detailTextLabel to have 3 lines at most, when overflow, truncate tail
		label.numberOfLines = 3
		label.allowsDefaultTighteningForTruncation = true
		label.lineBreakMode = .byTruncatingTail
		
		label.isSkeletonable = true
		label.skeletonTextLineHeight = .relativeToFont
		label.skeletonTextNumberOfLines = 3
		label.lastLineFillPercent = 80
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.clipsToBounds = true
		contentView.isSkeletonable = true
		contentView.addSubview(imageView)
		contentView.addSubview(titleLabel)
		contentView.addSubview(descriptionLabel)
		
		NSLayoutConstraint.activate([
			imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			imageView.widthAnchor.constraint(equalTo: contentView.heightAnchor),
			
			titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 20),
			titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
			
			descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
			descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
			descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		titleLabel.font = titleLabel.font.withSize(self.frame.height * 0.2)
		descriptionLabel.font = descriptionLabel.font.withSize(self.frame.height * 0.75 / 5)
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		loadStageTask?.cancel()
		loadStageTask = nil
		loadImageTask?.cancel()
		loadImageTask = nil
		
		imageView.image = nil
		titleLabel.text = nil
		descriptionLabel.text = nil
	}
}
