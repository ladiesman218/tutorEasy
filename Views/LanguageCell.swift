//
//  LanguageCell.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/9/15.
//

import UIKit

class LanguageCell: UICollectionViewCell {
    static let identifier = "langaugeCollectionViewCell"
	
	private let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.backgroundColor = .systemPink
		return imageView
	}()
	
	private let descriptionView: UITextView = {
		let textView = UITextView()
		textView.backgroundColor = .systemBlue
		return textView
	}()
	
	private let priceLabel: UILabel = {
		let label = UILabel()
		label.backgroundColor = .systemTeal
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.addSubview(imageView)
		contentView.addSubview(descriptionView)
		contentView.addSubview(priceLabel)
	}
	
	required init?(coder: NSCoder) {
		fatalError()
	}
	
}
