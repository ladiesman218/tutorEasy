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
		imageView.isSkeletonable = true
		return imageView
	}()
	
	var titleLabel: UILabel = {
		let label = UILabel()
		label.isSkeletonable = true
		return label
	}()
	
	var isLoading: Bool = true {
		didSet {
			switch isLoading {
				case true:
					// Ajust titleLabel display accordingly
					contentView.addSubview(titleLabel)
					
					// Start skeletonView animation
					imageView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: skeletonBaseColor), animation: animation, transition: .crossDissolve(0))
					titleLabel.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: skeletonBaseColor), animation: animation, transition: .crossDissolve(0))
				case false:
					// Ajust titleLabel display accordingly
					titleLabel.removeFromSuperview()
					// Add trail if it's free
					if chapter.isFree { imageView.drawTrail() }
					// Stop animation and hide skeletonView
					contentView.stopSkeletonAnimation()
					contentView.hideSkeleton(reloadDataAfter: true, transition: .none)
			}
		}
	}
	
	let animation = GradientDirection.topLeftBottomRight.slidingAnimation()
	
	// For task cancellation. When cell is off screen, there is no need to download the image so cancel the task.
	var imageTask: Task<(), Error>? = nil
	
	var chapter: Chapter = chapterPlaceHolder {
		didSet {
			// Do nothing until real chapter info has been got from server and set to cell. Otherwise, when placeholder chapter is set for the cell, its imageURL is nil and imageView will display a solid background color first, then when real chapter is set, it will start skeleton animation. We want the skeleton animation to show first, and stop when image is got, or never gonna be set.
			guard chapter.name != chapterPlaceHolder.name else { return }
			
			guard let url = chapter.imageURL else {
				imageView.backgroundColor = UIColor.blue
				isLoading = false
				return
			}

			// skeletonview will still be displayed for a short period of time. That's because when prepareForReuse, we set isLoading to true which displays skeletonView. Then setting a chapter for the cell in ChaptersVC takes some time. Awaitng for server response is not the main reason here cause we've tried to set image from cachedResponse in the beginning of chapter's property observer, it still doesn't avoid showing of skeletonview.
			self.imageTask = Task {
				
//				try await Task.sleep(nanoseconds: 3_000_000_000)
				let image = try? await FileAPI.publicGetImageData(path: url.path).resizedImage(with: imageView.bounds.size)
				
				try Task.checkCancellation()
				
				if let image = image {
					imageView.image = image
				} else {
					imageView.backgroundColor = .blue
				}

				isLoading = false
			}
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.isSkeletonable = true
		
		contentView.layer.cornerRadius = contentView.bounds.size.width * cornerRadiusMultiplier
		contentView.clipsToBounds = true
		
		contentView.addSubview(imageView)
		contentView.addSubview(titleLabel)
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
		
		isLoading = true
	}
}
