//
//  SkeletonCells.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/4/20.
//

import UIKit

// A hack from https://github.com/jrasmusson/swift-arcade/blob/master/Animation/Shimmer/README.md, modified a bit
protocol SkeletonLoadable {}

extension SkeletonLoadable {
	
	func makeAnimationGroup(previousGroup: CAAnimationGroup? = nil) -> CAAnimationGroup {
		let animDuration: CFTimeInterval = 1.5
		let anim1 = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.backgroundColor))
		anim1.fromValue = UIColor.lightGray.cgColor
		anim1.toValue = UIColor.darkGray.cgColor
		anim1.duration = animDuration
		anim1.beginTime = 0.0

		let anim2 = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.backgroundColor))
		anim2.fromValue = UIColor.darkGray.cgColor
		anim2.toValue = UIColor.lightGray.cgColor
		anim2.duration = animDuration
		anim2.beginTime = anim1.beginTime + anim1.duration

		let group = CAAnimationGroup()
		group.animations = [anim1, anim2]
		group.repeatCount = .greatestFiniteMagnitude // infinite
		group.duration = anim2.beginTime + anim2.duration
		group.isRemovedOnCompletion = false

		if let previousGroup = previousGroup {
			// Offset groups by 0.33 seconds for effect
			group.beginTime = previousGroup.beginTime + 0.33
		}

		return group
	}
	
}

class SkeletonCollectionCell: UICollectionViewCell {
	static let identifier = "skeletonCollectionCell"
	let imageView = UIImageView()
	let imageLayer = CAGradientLayer()

	let titleLabel: UILabel = {
		let label = UILabel()
		label.text = " "
		label.translatesAutoresizingMaskIntoConstraints = false

		return label
	}()
	let titleLayer = CAGradientLayer()

	override init(frame: CGRect) {
		super.init(frame: frame)

		contentView.addSubview(imageView)
		contentView.addSubview(titleLabel)

		imageLayer.startPoint = CGPoint(x: 0, y: 0.5)
		imageLayer.endPoint = CGPoint(x: 1, y: 0.5)
		imageView.layer.addSublayer(imageLayer)

		titleLayer.startPoint = CGPoint(x: 0, y: 0.5)
		titleLayer.endPoint = CGPoint(x: 1, y: 0.5)
		titleLabel.layer.addSublayer(titleLayer)

		let imageGroup = makeAnimationGroup()
		imageGroup.beginTime = 0.0
		imageLayer.add(imageGroup, forKey: "backgroundColor")

		let titleGroup = makeAnimationGroup(previousGroup: imageGroup)
		titleLayer.add(titleGroup, forKey: "backgroundColor")
		
		imageView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8),
			titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
			titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
		
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		imageLayer.frame = imageView.bounds
		imageLayer.cornerRadius = imageView.bounds.height / 8
		
		titleLayer.frame = titleLabel.bounds
		titleLayer.cornerRadius = titleLabel.bounds.height / 3
	}
}


extension SkeletonCollectionCell: SkeletonLoadable { }
