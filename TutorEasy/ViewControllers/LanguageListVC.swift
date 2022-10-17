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

extension LanguageListVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Accounts for banner item, so add extra one
        return languages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath == [0, 0]  {
            let bannerCell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerSlidesCell.identifier, for: indexPath) as! BannerSlidesCell
            bannerCell.scrollView.delegate = self
            bannerCell.bannerImages = bannerImages
            return bannerCell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LanguageCell.identifier, for: indexPath) as! LanguageCell
            // Account for banner item
            let indexOffset = indexPath.item - 1
            cell.nameLabel.text = languages[indexOffset].name
            cell.priceLabel.text = languages[indexOffset].price?.description
            cell.descriptionLabel.text = languages[indexOffset].description
            
            if let url = languages[indexOffset].imageURL {
                cell.imageView.downloaded(from: url, contentMode: .scaleAspectFill)
            }
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return indexPath == [0, 0] ? false : true
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
        
        // Screen ratio between different devices are not equal, so if we set width and height separatly, items we get will have different ratios on different devices. Here we want ratio to be fixed, so anchor height to width.
        // Hard part to understand the sizing with fractional methods, is to calculate backwards. If parameter numbers seem hard to reason about, try to figure out its parent size first, that means, keep calm and read on.
        let bannerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5))
        let bannerItem = NSCollectionLayoutItem(layoutSize: bannerSize)
        bannerItem.contentInsets = contentInsets
        
        // Half of its parent group width, since its parent takes up half of all width later, this one takes 1/4.
        let topRightItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5))
        let topRightItem = NSCollectionLayoutItem(layoutSize: topRightItemSize)
        topRightItem.contentInsets = contentInsets
        
        // A horizontal group contains 2 items. This will be wrapped in a group which takes up half of total width, so set height to half of its width will be 1/4 of total width, essentially gives us just the right amount of space to hold the item's height.
        let topRightRow = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5)), subitems: [topRightItem, topRightItem])
        let topRightGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5)), subitems: [topRightRow, topRightRow])
        
        // The top group in all, combined with the banner, and the 2 by 2 grid.
        let topGroup = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5)), subitems: [bannerItem, topRightGroup])
        
        let group: NSCollectionLayoutGroup  // To hold the final group
        
        // If language count is no more than 4, set the final group to contain topGroup only.
        if languages.count <= 4 {
            group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1000)), subitems: [topGroup])
        } else {
            // Create cells for extra items, and wrap them in groups. Normal means size for cells below banner.
            let normalSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/4), heightDimension: .fractionalWidth(1/4))
            let normalItem = NSCollectionLayoutItem(layoutSize: normalSize)
            normalItem.contentInsets = contentInsets
            // Create a single row. Again height is anchored to width
            let normalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/4)), subitems: [normalItem, normalItem, normalItem, normalItem])
            
            // Calculate how many rows are needed. Notice the value of row will be used to create group as repeatingSubitem/count parameter, so its value has to be greater or equal to 1, or app will crash.
            let floatCount = Float(languages.count)
            // Top-right corner already has 4 items, take that into account.
            let removedTopRight = floatCount - 4
            // Each row has 4 items, if the division has a remainder, round up to get an extra row, thus all items get displayed.
            let row = Int((removedTopRight / 4).rounded(.up))
            
            // According to previous configuration, normalGroup's height dimension is a decimal number(1/4 to be exact). This is the height for 1 row, we will use this value to get total height for the group below banner later.
            let height = normalGroup.layoutSize.heightDimension.dimension
            
            // Create a vertical group to wrap all rows in.
            var rowsGroup: NSCollectionLayoutGroup
            
            if #available(iOS 16.0, *) {
                // Height of the group is also anchored to width, calculated by row and height values.
                rowsGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(CGFloat(row) * height)), repeatingSubitem: normalGroup, count: row)
            } else {
                rowsGroup = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(CGFloat(row) * height)), subitem: normalGroup, count: row)
            }
            
            group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1000)), subitems: [topGroup, rowsGroup])
        }
        
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
