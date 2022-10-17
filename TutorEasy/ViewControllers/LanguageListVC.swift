import UIKit

class LanguageListVC: UIViewController {
    
    // MARK: -
    private var collectionView: UICollectionView!
    
    private let topView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let pager: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 1
        pageControl.currentPageIndicatorTintColor = .blue
        //        pageControl.pageIndicatorTintColor = .red
        pageControl.layer.zPosition = .greatestFiniteMagnitude
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private var profileButton: UIButton!
    
    static let topViewHeight = CGFloat(70)
    
    private var languages = [Language.PublicInfo]() {
        didSet { self.collectionView.reloadData() }
    }
    
    private var bannerImages = [UIImage]()
    
    // MARK: -
    override func loadView() {
        super.loadView()
        loadLanguages()
        loadBanners()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backgroundColor
        collectionView = configCollectionView()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        view.addSubview(pager)
        //        pager.addTarget(self, action: #selector(pageControlTap), for: .touchUpInside)
        
        view.addSubview(topView)
        profileButton = configProfileIcon(for: self)
        topView.addSubview(profileButton)
        
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            collectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: Self.topViewHeight),
            
            profileButton.heightAnchor.constraint(equalToConstant: Self.topViewHeight - 10),
            profileButton.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
            profileButton.widthAnchor.constraint(equalTo: profileButton.heightAnchor),
            profileButton.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
            
            //            pager.heightAnchor.constraint(equalToConstant: 30),
            //            pager.bottomAnchor.constraint(equalTo: bannerSlides.bottomAnchor),
            //            pager.widthAnchor.constraint(lessThanOrEqualTo: bannerSlides.widthAnchor),
            //            pager.centerXAnchor.constraint(equalTo: bannerSlides.centerXAnchor),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profileButton = configProfileIcon(for: self)
        // load profilepic according to isLoggedIn value
        
    }
    
    func loadLanguages() {
        LanguageAPI.getAllLanguages { languages, response, error in
            guard let languages = languages, error == nil else {
                MessagePresenter.showMessage(title: "获取语言列表失败", message: error!.reason, on: self, actions: [])
                return
            }
            self.languages = languages
        }
    }
    
    func loadBanners() {
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
}

extension LanguageListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        return languages.count + 1  // Added extra 1 for banners
        return 13
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath == [0, 0]  {
            let bannerCell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerSlidesCell.identifier, for: indexPath) as! BannerSlidesCell
            bannerCell.scrollView.delegate = self
            bannerCell.bannerImages = bannerImages
            return bannerCell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LanguageCell.identifier, for: indexPath) as! LanguageCell
            
            //            cell.nameLabel.text = languages[indexPath.item].name
            //            cell.priceLabel.text = languages[indexPath.item].price?.description
            //            cell.descriptionLabel.text = languages[indexPath.item].description
            
            //            if let url = languages[indexPath.item].imageURL {
            //                cell.imageView.downloaded(from: url, contentMode: .scaleAspectFill)
            //            }
            return cell
        }
        
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if indexPath == [0, 0]  {
//            let width = collectionView.frame.width / 2 - 10
//            return CGSize(width: width, height: width)
//        } else {
//            let width = collectionView.frame.width / 4 - 10
//            return CGSize(width: width, height: width)
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if indexPath == [0, 0] {
            return false
        } else { return true }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let id = languages[indexPath.item].id
        
        LanguageAPI.getLanguage(id: id) { [unowned self] language, response, error in
            
            guard let language = language, error == nil else {
                MessagePresenter.showMessage(title: "获取课程失败", message: error!.reason, on: self, actions: [])
                return
            }
            
            let detailVC = LanguageDetailVC()
            detailVC.language = language
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func configCollectionView() -> UICollectionView {
        let contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let bannerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5))
        let bannerItem = NSCollectionLayoutItem(layoutSize: bannerSize)
        bannerItem.contentInsets = contentInsets
        
        let topRightItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5))
        let topRightItem = NSCollectionLayoutItem(layoutSize: topRightItemSize)
        topRightItem.contentInsets = contentInsets
        let topRightRow = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5)), subitems: [topRightItem, topRightItem])
        let topRightGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5)), subitems: [topRightRow, topRightRow])
        let topGroup = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5)), subitems: [bannerItem, topRightGroup])
        
        let normalSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/4), heightDimension: .fractionalWidth(1/4))
        let normalItem = NSCollectionLayoutItem(layoutSize: normalSize)
        normalItem.contentInsets = contentInsets
        let normalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/4)), subitems: [normalItem, normalItem, normalItem, normalItem])

        let row = Int(((Float(12) - 4) / 4).rounded(.up))

        var normalRow: NSCollectionLayoutGroup
        let height = normalGroup.layoutSize.heightDimension.dimension

        if #available(iOS 16.0, *) {
            normalRow = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(CGFloat(row) * height)), repeatingSubitem: normalGroup, count: row)
        } else {
            normalRow = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(CGFloat(row) * height)), subitem: normalGroup, count: row)
        }

        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(3000)), subitems: [topGroup, normalRow])
        
        let section = NSCollectionLayoutSection(group: group)
        
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        collectionView.register(LanguageCell.self, forCellWithReuseIdentifier: LanguageCell.identifier)
        collectionView.register(BannerSlidesCell.self, forCellWithReuseIdentifier: BannerSlidesCell.identifier)
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }
}

extension LanguageListVC: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let width = scrollView.bounds.size.width
        pager.currentPage = Int(ceil(x/width))
    }
    
    // Tapping on pagecontrol changes scrollView contentOffset also..
    //    @objc private func pageControlTap(_ sender: UIPageControl) {
    //        let pageWidth: CGFloat = bannerSlides.frame.width
    //        let slideToX: CGFloat = CGFloat(sender.currentPage) * pageWidth
    //        bannerSlides.setContentOffset(CGPoint(x: slideToX, y: 0), animated: true)
    //    }
}
