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
	var loadImageTask: Task<Void, Error>?
	
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
		
		label.isSkeletonable = true
        return label
    }()
	
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
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
        
        NSLayoutConstraint.activate([
            
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)//, constant: -50),
        ])
    }
	
	override func layoutSubviews() {
		super.layoutSubviews()
		if imageView.image == nil {
			imageView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .asbestos, secondaryColor: .clouds), animation: skeletonAnimation, transition: .none)
		} else {
			imageView.stopSkeletonAnimation()
			imageView.hideSkeleton(reloadDataAfter: true, transition: .none)
		}
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
