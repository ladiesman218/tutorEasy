//
//  PDFThumbnailCell.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/11/19.
//

import UIKit

class PDFThumbnailCell: UICollectionViewCell {
	static let identifier = "pdfThumbnailCell"
	// Cells not selected will have a little transparency, selected will be fully opaque
	static let opacity: Float = 0.7
	var imageView: UIImageView!
	
	let loadIndicator: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView()
		indicator.color = .systemYellow
		indicator.hidesWhenStopped = true
		indicator.style = .large
		return indicator
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		imageView = UIImageView()
		contentView.layer.cornerRadius = contentView.frame.size.width * cornerRadiusMultiplier
		contentView.layer.backgroundColor = UIColor.systemFill.cgColor
		contentView.clipsToBounds = true
		
		contentView.addSubview(imageView)
		contentView.addSubview(loadIndicator)
		loadIndicator.frame = contentView.bounds
		
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
	
	override func layoutSubviews() {
		super.layoutSubviews()
		if imageView.image == nil {
			loadIndicator.startAnimating()
		} else {
			loadIndicator.stopAnimating()
		}
		
		contentView.layer.opacity = (isSelected) ? 1.0 : Self.opacity
	}
}
