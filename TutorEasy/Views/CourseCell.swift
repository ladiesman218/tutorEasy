//
//  CourseCell.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/9/15.
//

import UIKit
import SkeletonView

class CourseCell: UICollectionViewCell {
    static let identifier = "courseCollectionViewCell"
	var loadImageTask: Task<Void, Never>?
	
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
		
		label.isSkeletonable = true
        return label
    }()
	
    let imageView: UIImageView = {
        let imageView = UIImageView()
		imageView.isSkeletonable = true
        return imageView
    }()
    
    var descriptionLabel: UILabel!
    var priceLabel: UILabel!
	
	override init(frame: CGRect) {
        super.init(frame: frame)
		contentView.layer.cornerRadius = contentView.bounds.size.width * cornerRadiusMultiplier
        contentView.clipsToBounds = true

        contentView.addSubview(imageView)
		self.createShadow()
    }
	
	override func layoutSubviews() {
		super.layoutSubviews()
		imageView.frame = contentView.frame
		
		if imageView.image == nil {
			imageView.showAnimatedGradientSkeleton(usingGradient: skeletonGradient, animation: skeletonAnimation, transition: .none)
		} else {
			imageView.stopSkeletonAnimation()
			imageView.hideSkeleton(reloadDataAfter: false, transition: .crossDissolve(0.25))
		}
		imageView.backgroundColor = (imageView.image == failedImage) ? .systemBrown : nil
	}
	    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
	override func prepareForReuse() {
		super.prepareForReuse()
		loadImageTask?.cancel()
		loadImageTask = nil
		
		imageView.image = nil
	}
}
