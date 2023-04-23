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
	var imageView = UIImageView()
	
	var loaded = false {
		didSet {
			if loaded == true {
				contentView.stopSkeletonAnimation()
				contentView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(1))
			} else {
				contentView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .amethyst), animation: nil, transition: .crossDissolve(1))
			}
		}
	}
	
	var chapter = chapterPlaceHolder {
		didSet {
			guard chapter.name != "" else { return }
			guard let imageURL = chapter.imageURL else {
				if chapter.isFree {
					imageView.drawTrail()
				}
				loaded = true
				return
			}
			
			Task {
				if let data = try? await FileAPI.publicGetImageData(path: imageURL.path).get() {
					let image = UIImage(data: data)
					imageView.image = image
				}
				if chapter.isFree {
					imageView.drawTrail()
				}
				loaded = true
			}
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		contentView.isSkeletonable = true
		contentView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .amethyst), animation: nil, transition: .crossDissolve(1))
		
		contentView.layer.backgroundColor = UIColor.blue.cgColor
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
		self.imageView.image = nil
		self.chapter = chapterPlaceHolder
		self.loaded = false
	}
}
