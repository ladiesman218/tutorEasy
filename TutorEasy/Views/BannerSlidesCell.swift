//
//  BannerSlidesCell.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/15.
//

import UIKit

class BannerSlidesCell: UICollectionViewCell {

    
    static let identifier = "bannerSlidesCell"
    
    var scrollView: UIScrollView!
    
    var bannerImages = [UIImage]() {
        didSet {
            addImageToSlides()
        }
    }
    
    private func addImageToSlides() {
        guard bannerImages.count != 0 else { return }
        let index = bannerImages.count - 1
        let point = CGPoint(x: self.frame.width * CGFloat(index), y: 0)
        let imageView = UIImageView(frame: CGRect(origin: point, size: self.frame.size))
        imageView.image = bannerImages[index]
        scrollView.addSubview(imageView)
        scrollView.contentSize.width = CGFloat(scrollView.frame.width * CGFloat(bannerImages.count))
//        pager.numberOfPages = bannerImages.count
    }
    
    
    var nameLabel: UILabel!
    var imageView: UIImageView!
    var descriptionLabel: UILabel!
    var priceLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollView = UIScrollView()
        
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.frame.size = self.bounds.size
        scrollView.backgroundColor = .blue
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

}
