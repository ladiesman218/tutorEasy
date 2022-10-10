//
//  LanguageCell.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/9/15.
//

import UIKit

class LanguageCell: UICollectionViewCell {
    static let identifier = "langaugeCollectionViewCell"

//    var topView: UIView!
//    var iconImageView: UIImageView!
//    var userNameView
    
    var nameLabel: UILabel!
    var imageView: UIImageView!
    var descriptionLabel: UILabel!
    var priceLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//                contentView.layer.borderWidth = 1
                contentView.layer.cornerRadius = 10
//        		contentView.layer.borderColor = UIColor.systemGray.cgColor
        contentView.clipsToBounds = true
        
        nameLabel = UILabel()
        nameLabel.textColor = .systemRed
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(nameLabel)
        
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(descriptionLabel)
        
        priceLabel = UILabel()
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(priceLabel)
        
        
        NSLayoutConstraint.activate([
            
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)//, constant: -50),
            
//            nameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor),
//            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
//            nameLabel.heightAnchor.constraint(equalToConstant: 15),
//
//            descriptionLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor),
//            descriptionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
//            descriptionLabel.heightAnchor.constraint(equalToConstant: 25),
//
//            priceLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor),
//            priceLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            priceLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor),
//            priceLabel.heightAnchor.constraint(equalToConstant: 10)
            
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}
