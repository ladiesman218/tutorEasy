//
//  ChapterCell.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/31.
//

import UIKit

class ChapterCell: UICollectionViewCell {
    static let identifier = "chapterCollectionViewCell"
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.backgroundColor = UIColor.blue.cgColor
        contentView.layer.cornerRadius = frame.width * 0.07
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
