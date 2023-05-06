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
	var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.clipsToBounds = true
		imageView.isSkeletonable = true
		return imageView
	}()
	
	// For task cancellation. When cell is off screen, there is no need to download the image so cancel the task.
	var imageTask: Task<(), Error>? = nil
	
	var chapter: Chapter = chapterPlaceHolder {
		didSet {
			// Do nothing until real chapter info has been got from server and set to cell. Otherwise, when placeholder chapter is set for the cell, its imageURL is nil and imageView will display a solid background color first, then when real chapter is set, it will start skeleton animation. We want the skeleton animation to show first, and stop when image is got, or never gonna be set.
			guard chapter.name != chapterPlaceHolder.name else { return }
			
			guard let url = chapter.imageURL else {
				imageView.backgroundColor = UIColor.blue
				if chapter.isFree { imageView.drawTrail() }
				imageView.stopSkeletonAnimation()
				imageView.hideSkeleton(reloadDataAfter: false, transition: .crossDissolve(0.25))
				return
			}
			
			self.imageTask = Task {
				if let image = try? await FileAPI.publicGetImageData(path: url.path).resizedImage(with: imageView.bounds.size) {
					try Task.checkCancellation()
					imageView.image = image
				} else {
					try Task.checkCancellation()
					imageView.backgroundColor = UIColor.blue
				}
				if chapter.isFree { imageView.drawTrail() }
				imageView.stopSkeletonAnimation()
				imageView.hideSkeleton(reloadDataAfter: false, transition: .crossDissolve(0.25))
			}
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.isSkeletonable = true
		imageView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .asbestos), animation: nil, transition: .crossDissolve(1))
		
		imageView.layer.cornerRadius = contentView.bounds.size.width * cornerRadiusMultiplier
		
		contentView.layer.cornerRadius = contentView.bounds.size.width * cornerRadiusMultiplier
		contentView.clipsToBounds = true
		
		contentView.addSubview(imageView)
		self.createShadow()
		
		imageView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		imageTask?.cancel()
		imageTask = nil
		self.imageView.image = nil
		self.imageView.backgroundColor = nil
		imageView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .asbestos), animation: nil, transition: .crossDissolve(0))
	}
}
