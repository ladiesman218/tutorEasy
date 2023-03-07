//
//  PDFThumbnailCell.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/11/19.
//

import UIKit

class PDFThumbnailCell: UICollectionViewCell {
	static let identifier = "pdfThumbnailCell"
	var imageView: UIImageView!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		imageView = UIImageView()
		contentView.layer.cornerRadius = contentView.frame.size.width * cornerRadiusMultiplier
		contentView.layer.backgroundColor = UIColor.blue.cgColor
		contentView.clipsToBounds = true
		
		contentView.addSubview(imageView)
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
	
}
