//
//  StageTableCell.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/6/15.
//

import UIKit
import SkeletonView

class StageCell: UICollectionViewCell {
	static let identifier = "StageCellIdentifier"
	var loadStageTask: Task<Void, Never>?
	var loadImageTask: Task<Void, Error>?
	
	let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.isSkeletonable = true
		return imageView
	}()
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .left
		
		label.isSkeletonable = true
		label.skeletonTextLineHeight = .relativeToFont
		label.skeletonTextNumberOfLines = 1
		label.lastLineFillPercent = 30
		
		return label
	}()
	
	let descriptionLabel: UILabel = {
		let label = UILabel()
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
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let height = contentView.bounds.height
		let verticalGap = height * 0.05
		let titleHeight = height * 0.18
		titleLabel.font = titleLabel.font.withSize(titleHeight)
		descriptionLabel.font = descriptionLabel.font.withSize(self.frame.height * 0.75 / 5)

		imageView.frame = .init(origin: .zero, size: .init(width: height, height: height))
		titleLabel.frame = .init(origin: .init(x: height + 20, y: verticalGap), size: .init(width: contentView.bounds.width - height - 20, height: titleHeight))
		descriptionLabel.frame.origin.x = titleLabel.frame.origin.x
		descriptionLabel.frame.origin.y = titleLabel.frame.origin.y + titleHeight + verticalGap
		descriptionLabel.frame.size.width = titleLabel.frame.size.width
		descriptionLabel.frame.size.height = height - titleHeight - verticalGap * 2
		
		if titleLabel.text == nil || titleLabel.text == placeHolderStage.name {
			titleLabel.showAnimatedGradientSkeleton(usingGradient: skeletonGradient, animation: skeletonAnimation, transition: .none)
		} else {
			let text = titleLabel.text
			titleLabel.stopSkeletonAnimation()
			titleLabel.hideSkeleton(reloadDataAfter: false, transition: .crossDissolve(0.25))
			titleLabel.text = text
		}
		
		if descriptionLabel.text == nil || descriptionLabel.text == placeHolderStage.description {
			descriptionLabel.showAnimatedGradientSkeleton(usingGradient: skeletonGradient, animation: skeletonAnimation, transition: .none)
		} else {
			let text = descriptionLabel.text
			descriptionLabel.stopSkeletonAnimation()
			descriptionLabel.hideSkeleton(reloadDataAfter: false, transition: .crossDissolve(0.25))
			descriptionLabel.text = text
		}
		
		if imageView.image == nil {
			imageView.showAnimatedGradientSkeleton(usingGradient: skeletonGradient, animation: skeletonAnimation, transition: .none)
		} else {
			imageView.stopSkeletonAnimation()
			imageView.hideSkeleton(reloadDataAfter: false, transition: .crossDissolve(0.25))
		}
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
