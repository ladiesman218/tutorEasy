//
//  CourseCellCollectionViewCell.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/25.
//

import UIKit

class CourseCellOrginal: UICollectionViewCell {
    static let identifier = "courseCollectionViewCell"
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .blue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        contentView.addSubview(imageView)
		contentView.layer.cornerRadius = contentView.bounds.size.width * cornerRadiusMultiplier
        contentView.clipsToBounds = true
//        contentView.layoutMargins = .init(top: 3, left: 3, bottom: 3, right: 3)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
