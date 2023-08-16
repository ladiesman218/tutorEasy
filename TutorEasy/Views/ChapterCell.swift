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
	// Hold reference to loadChapter and loadImage tasks, so when cell is about to be scrolled off the screen, we can cancel it.
	var loadChapterTask: Task<Void, Never>? = nil
	var loadImageTask: Task<Void, Never>? = nil
	
	// MARK: - Custom subviews
	// SkeletonView doesn't work very well with auto layout, using auto layout on these 2 views will cause only 1 cell displaying skeleton animation, dispite collection view has many cells.
	let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.isSkeletonable = true
		return imageView
	}()
	
	let titleLabel: UILabel = {
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
		
		contentView.layer.cornerRadius = contentView.bounds.size.width * cornerRadiusMultiplier
		contentView.clipsToBounds = true
		
		contentView.addSubview(imageView)
		contentView.addSubview(titleLabel)
		self.createShadow()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// When cell is laying out subviews, set frames for imageView and titleLabel.
	override func layoutSubviews() {
		super.layoutSubviews()
		
		imageView.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.width)
		titleLabel.frame = CGRect(x: 0, y: contentView.bounds.width, width: contentView.bounds.width, height: contentView.bounds.height - contentView.bounds.width)
		titleLabel.font = titleLabel.font.withSize(titleLabel.bounds.height * 0.4)
		titleLabel.skeletonPaddingInsets = .init(top: titleLabel.bounds.height * 0.4, left: 0, bottom: 0, right: 0)
		
		// Display/hide skeleton depending on those 2 view's text/image property, so that we can simply set view's property value accordingly, then call setNeedsLayout() on cell, no need to reload cell anymore.
		if titleLabel.text == nil || titleLabel.text == placeHolderChapter.name {
			titleLabel.showAnimatedGradientSkeleton(usingGradient: skeletonGradient, animation: skeletonAnimation, transition: .none)
		} else {
			// titleLable's text will be lost after hideSkeleton(reloadDataAfter: , transition: ) gets called, despite value of reloadDataAfter. This may be a bug. Anyway we get it's text before calling hideSkeleton() and set the text again after that.
			let text = titleLabel.text
			titleLabel.stopSkeletonAnimation()
			titleLabel.hideSkeleton(reloadDataAfter: false, transition: .crossDissolve(0.25))
			titleLabel.text = text
		}
		
		if imageView.image == nil {
			imageView.showAnimatedGradientSkeleton(usingGradient: skeletonGradient, animation: skeletonAnimation, transition: .none)
		} else {
			imageView.stopSkeletonAnimation()
			imageView.hideSkeleton(reloadDataAfter: false, transition: .crossDissolve(0.25))
		}
		imageView.backgroundColor = (imageView.image == failedImage) ? .systemBrown : nil
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		loadChapterTask?.cancel()
		loadChapterTask = nil
		loadImageTask?.cancel()
		loadImageTask = nil
		
		imageView.image = nil
		titleLabel.text = nil
	}
}
