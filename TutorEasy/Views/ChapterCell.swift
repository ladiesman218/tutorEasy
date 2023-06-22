//
//  ChapterCell.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/31.
//

import UIKit
import SkeletonView

class ChapterCell: UICollectionViewCell {
	static let identifier = "chapterCollectionViewCell"
	var chapter: Chapter! {
		didSet {
			
			titleLabel.text = chapter.name
			imageView.image = chapter.image
			
			if titleLabel.text == chapterPlaceHolder.name {
				titleLabel.textAlignment = .natural
				//			titleLabel.skeletonTextNumberOfLines = 2
				titleLabel.skeletonLineSpacing = 0
				titleLabel.lastLineFillPercent = 80
				titleLabel.linesCornerRadius = 5
				
				titleLabel.skeletonTextLineHeight = .relativeToFont
				titleLabel.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: skeletonTitleColor), animation: skeletonAnimation, transition: .none)
			} else {
				
				titleLabel.textAlignment = .center
				titleLabel.stopSkeletonAnimation()
				titleLabel.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0))
			}
		}
	}
	
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
		
		label.isSkeletonable = true
		label.backgroundColor = .systemYellow
		label.textColor = .white
		return label
	}()
	
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
	
	override func prepareForReuse() {
		super.prepareForReuse()
		imageView.image = nil
		titleLabel.text = nil
	}
	
	//	func configure(chapter: Chapter) {
	//		titleLabel.text = chapter.name
	//		imageView.image = chapter.image
	//
	//
	//		if titleLabel.text == chapterPlaceHolder.name {
	//			titleLabel.textAlignment = .natural
	////			titleLabel.skeletonTextNumberOfLines = 2
	//			titleLabel.skeletonLineSpacing = 0
	//			titleLabel.lastLineFillPercent = 80
	//			titleLabel.linesCornerRadius = 5
	//
	//			titleLabel.skeletonTextLineHeight = .relativeToFont
	//			titleLabel.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: skeletonTitleColor), animation: skeletonAnimation, transition: .none)
	//		} else {
	//			print(titleLabel.text)
	//			titleLabel.textAlignment = .center
	//			titleLabel.stopSkeletonAnimation()
	//			titleLabel.hideSkeleton(reloadDataAfter: true, transition: .none)
	//			titleLabel.setNeedsLayout()
	//			titleLabel.setNeedsDisplay()
	//		}
	//
	//	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		imageView.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.width)
		titleLabel.frame = CGRect(x: 0, y: contentView.bounds.width, width: contentView.bounds.width, height: contentView.bounds.height - contentView.bounds.width)
		titleLabel.font = titleLabel.font.withSize(titleLabel.bounds.height * 0.4)
	}
}
