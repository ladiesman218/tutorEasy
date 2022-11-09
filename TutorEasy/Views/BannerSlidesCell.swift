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
        
        // We don't know how many banners are stored on server side, so query /api/file/banner/paths for all possible banner file paths first.
        let queryBannersPath = FileAPI.publicFileEndPoint.appendingPathComponent("banner").appendingPathComponent("paths")
        
        URLSession.shared.pathsTask(with: URLRequest(url: queryBannersPath)) { [unowned self] paths, response, error in
            guard let paths = paths else { return }
            
            for path in paths {
                FileAPI.getFile(path: path) { data, response, error in
                    guard let data = data, error == nil else {
                        MessagePresenter.showMessage(title: "获取Banner错误", message: error?.localizedDescription ?? "服务器错误", on: self.findViewController(), actions: [])
                        return
                    }
                    
                    if let image = UIImage(data: data) {
                        self.bannerImages.append(image)
                    }
                }
            }
        }.resume()

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
