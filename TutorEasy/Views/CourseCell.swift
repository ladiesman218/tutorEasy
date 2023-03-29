//
//  LanguageCell.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/9/15.
//

import UIKit

class CourseCell: UICollectionViewCell {
    static let identifier = "courseCollectionViewCell"
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var descriptionLabel: UILabel!
    var priceLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //                contentView.layer.borderWidth = 1
		contentView.layer.cornerRadius = contentView.bounds.size.width * cornerRadiusMultiplier
        contentView.layer.backgroundColor = UIColor.blue.cgColor
        //        		contentView.layer.borderColor = UIColor.systemGray.cgColor
//        contentView.backgroundColor = .red
        contentView.clipsToBounds = true

        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)//, constant: -50),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}
