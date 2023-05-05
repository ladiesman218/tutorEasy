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
		imageView.backgroundColor = UIColor.blue
		imageView.isSkeletonable = true
		return imageView
	}()
	
	// For task cancellation. When cell is off screen, there is no need to download the image so cancel the task.
	var imageTask: Task<(), Error>? = nil
	
	var chapter: Chapter = chapterPlaceHolder {
		didSet {
			
			guard let url = chapter.imageURL else {
//				imageView.backgroundColor = UIColor.blue
				if chapter.isFree { imageView.drawTrail() }
				return
			}
			#warning("lack of a background color sometimes")
			self.imageTask = Task {
				imageView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .asbestos), animation: nil, transition: .crossDissolve(1))
				if let image = try? await FileAPI.publicGetImageData(path: url.path).resizedImage(with: imageView.bounds.size) {
					imageView.image = image
				} else {
//					imageView.backgroundColor = UIColor.blue
					if chapter.isFree { imageView.drawTrail() }

				}
				imageView.stopSkeletonAnimation()
				imageView.hideSkeleton(reloadDataAfter: false, transition: .crossDissolve(0.25))
//				if imageView.image == nil { imageView.backgroundColor = UIColor.blue }
//				if chapter.isFree { imageView.drawTrail() }
			}
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		//		imageView.layer.backgroundColor = UIColor.blue.cgColor
		self.isSkeletonable = true
		
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
		
		// Maybe create an optional dataTask to hold the task for fetching image data in the cell, give it a value when needed, then cancel the task and set it to nil here.
		imageTask?.cancel()
		imageTask = nil
		self.chapter = chapterPlaceHolder
		self.imageView.image = nil

		//		self.loaded = false
	}
}
