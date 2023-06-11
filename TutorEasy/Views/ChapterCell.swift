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
		label.textAlignment = .center
		// Names longer than 2 lines will be tructated
		label.numberOfLines = 2
		label.adjustsFontSizeToFitWidth = true
		label.minimumScaleFactor = 0.9
		label.isSkeletonable = true
		label.backgroundColor = .systemYellow
		label.textColor = .white
		return label
	}()
	
	var isLoading: Bool = true {
		didSet {
			switch isLoading {
				case true:
					self.imageView.image = nil
					self.imageView.backgroundColor = nil
#warning("Ajust titleLabel display accordingly")
//					contentView.addSubview(titleLabel)
					
					// Start skeletonView animation
					imageView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: skeletonBaseColor), animation: animation, transition: .crossDissolve(0))
//					titleLabel.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: skeletonBaseColor), animation: animation, transition: .crossDissolve(0))
				case false:
					// Ajust titleLabel display accordingly
//					titleLabel.removeFromSuperview()
					
					// Draw chapter name on the imageView
//					imageView.drawName(name: chapter.name)
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
			
			guard let fileURL = chapter.imageURL else {
				imageView.backgroundColor = .blue
				isLoading = false
				return
			}
			
			let request = FileAPI.convertToImageRequest(url: fileURL)

#warning("try to replace the manually serve cache implemention with stale-while-revalidate")
#warning("Tweaking lable hide/display between skeletonView and after load")
			self.imageTask = Task {
				
				// If a cachedResponse is found, serve the image from it and stop skeleton animation. When scrolling, cell's image will be reset and retrieved from server again. Since validating to server to see if an image has changed takes small amount of time, scrolling up backwards will cause cached image to show skeletonview again. This extra step avoid that.
//				if let cachedResponse = cachedSession.configuration.urlCache?.cachedResponse(for: request), let image = UIImage(data: cachedResponse.data) {
//					
//					try Task.checkCancellation()
//					imageView.image = image
//					isLoading = false
//				}
				//				try await Task.sleep(nanoseconds: 3_000_000_000)
				let image = try? await FileAPI.publicGetImageData(request: request, size: imageView.bounds.size)
				titleLabel.text = chapter.name
				if let image = image {
					try Task.checkCancellation()
					imageView.image = image
				} else {
					try Task.checkCancellation()
					imageView.backgroundColor = .blue
				}
				isLoading = false
			}
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.isSkeletonable = true
		imageView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: skeletonBaseColor), animation: animation, transition: .crossDissolve(0))
		
		contentView.layer.cornerRadius = contentView.bounds.size.width * cornerRadiusMultiplier
		contentView.clipsToBounds = true
		
		contentView.addSubview(imageView)
		contentView.addSubview(titleLabel)
		self.createShadow()
		
		imageView.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
			
			titleLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
			titleLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
			titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
			titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		imageTask?.cancel()
		imageTask = nil
		
		isLoading = true
	}
}
