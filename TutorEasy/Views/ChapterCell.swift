//
//  ChapterCell.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/31.
//

import UIKit
import SkeletonView

class ChapterCell: UICollectionViewCell {
	// MARK: - Properties
	static let identifier = "chapterCollectionViewCell"
	// Hold a reference to loadChapter task, so when cell is about to be scrolled off the screen, we can cancel it.
	var loadTask: Task<Void, Error>?
	
	// MARK: - Custom subviews
	var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.isSkeletonable = true

		return imageView
	}()
	
	var titleLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .center
		// Names longer than 2 lines will be tructated
		label.numberOfLines = 2
		
		label.backgroundColor = .systemYellow
		label.textColor = .white
		
		label.isSkeletonable = true
		label.skeletonTextLineHeight = .relativeToFont
		label.skeletonTextNumberOfLines = 1
		label.lastLineFillPercent = 100

		return label
	}()
	
	// MARK: - Controller functions
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		contentView.isSkeletonable = true
		
		contentView.layer.cornerRadius = contentView.bounds.size.width * cornerRadiusMultiplier
		contentView.clipsToBounds = true
		
		contentView.addSubview(imageView)
		contentView.addSubview(titleLabel)
		self.createShadow()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// When cell is laying out subviews, set frames for imageView and titleLabel. Also this is the only place to show/hide skeleton if we only wanna do it in one place.
	override func layoutSubviews() {
		super.layoutSubviews()
		
		imageView.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.width)
		titleLabel.frame = CGRect(x: 0, y: contentView.bounds.width, width: contentView.bounds.width, height: contentView.bounds.height - contentView.bounds.width)
		titleLabel.font = titleLabel.font.withSize(titleLabel.bounds.height * 0.4)
		
		if imageView.image == nil {
			imageView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .asbestos, secondaryColor: .clouds), animation: skeletonAnimation, transition: .none)
		} else {
			imageView.stopSkeletonAnimation()
			imageView.hideSkeleton(reloadDataAfter: true, transition: .none)
		}
		
		if titleLabel.text == nil {
			titleLabel.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .asbestos, secondaryColor: .clouds), animation: skeletonAnimation, transition: .none)
		} else {
			titleLabel.stopSkeletonAnimation()
			titleLabel.hideSkeleton(reloadDataAfter: true, transition: .none)
		}
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		loadTask?.cancel()
		loadTask = nil
		
		imageView.image = nil
		titleLabel.text = nil
	}
	
}
