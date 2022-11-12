//
//  ChapterCell.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/31.
//

import UIKit

class ChapterCell: UICollectionViewCell {
    static let identifier = "chapterCollectionViewCell"
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.backgroundColor = UIColor.blue.cgColor
        contentView.layer.cornerRadius = frame.width * 0.07
		contentView.clipsToBounds = true

        imageView = UIImageView()
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
