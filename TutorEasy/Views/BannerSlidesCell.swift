//
//  BannerSlidesCell.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/15.
//

import UIKit

class BannerSlidesCell: UICollectionViewCell {
    
    // MARK: -
    static let identifier = "bannerSlidesCell"
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        return scrollView
    }()
    
    private var bannerImages = [UIImage]() {
        didSet { addImageToSlides() }
    }
    
    private let pager: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 1
        pageControl.currentPageIndicatorTintColor = .blue
        pageControl.pageIndicatorTintColor = .red
        pageControl.layer.zPosition = .greatestFiniteMagnitude
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    // MARK: -
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadBanners()
        
        scrollView.delegate = self
        scrollView.frame.size = self.bounds.size
        self.contentView.addSubview(scrollView)
        
        pager.addTarget(self, action: #selector(pageControlTap), for: .touchUpInside)
        self.addSubview(pager)
        
        NSLayoutConstraint.activate([
            pager.heightAnchor.constraint(equalToConstant: 30),
            pager.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -30),
            pager.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor),
            pager.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func loadBanners() {
        for i in 1 ... 10 {
            let url = mediaURL.appendingPathComponent("Courses/" + "banner\(i)")
            
            URLSession.shared.dataTask(with: url) { [unowned self] data, response, error in
                guard let res = response as? HTTPURLResponse, res.statusCode == 200, error == nil else { return }
                guard let data = data else { return }
                let image = UIImage(data: data)!
                DispatchQueue.main.async {
                    self.bannerImages.append(image)
                }
            }.resume()
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
        pager.numberOfPages = bannerImages.count
    }

}

extension BannerSlidesCell: UIScrollViewDelegate {
    // Tapping on pagecontrol changes scrollView contentOffset also..
    @objc private func pageControlTap(_ sender: UIPageControl) {
        let pageWidth: CGFloat = self.frame.width
        let slideToX: CGFloat = CGFloat(sender.currentPage) * pageWidth
        scrollView.setContentOffset(CGPoint(x: slideToX, y: 0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let width = scrollView.bounds.size.width
        pager.currentPage = Int(ceil(x/width))
    }
}
