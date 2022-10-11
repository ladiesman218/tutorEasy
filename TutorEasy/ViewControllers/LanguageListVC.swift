import UIKit

class LanguageListVC: UIViewController {
    
    // MARK: -
    private let languagesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(LanguageCell.self, forCellWithReuseIdentifier: LanguageCell.identifier)
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let bannerSlides: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .red
        scrollView.contentSize.height = scrollView.frame.height
        return scrollView
    }()
    
    private let topView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .yellow
        imageView.layer.cornerRadius = (topViewHeight - 10) / 2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let pager: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 1
        pageControl.currentPageIndicatorTintColor = .blue
        pageControl.pageIndicatorTintColor = .red
        pageControl.layer.zPosition = .greatestFiniteMagnitude
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    static let topViewHeight = CGFloat(70)
    
    private var languages = [Language.PublicInfo]() {
        didSet { self.languagesCollectionView.reloadData() }
    }
    
    private var bannerImages = [UIImage]() {
        didSet {
            addImageToSlides()
        }
    }
    
    // MARK: -
    override func loadView() {
        super.loadView()
        loadLanguages()
        loadBanners()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backgroundColor
        
        languagesCollectionView.dataSource = self
        languagesCollectionView.delegate = self
        
        view.addSubview(languagesCollectionView)
        view.addSubview(bannerSlides)
        bannerSlides.delegate = self
        view.addSubview(pager)
        pager.addTarget(self, action: #selector(pageControlTap), for: .touchUpInside)

        view.addSubview(topView)
        topView.addSubview(profileImageView)
        
        
        NSLayoutConstraint.activate([
            languagesCollectionView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            languagesCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width / 2),
            languagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            languagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            
            bannerSlides.topAnchor.constraint(equalTo: topView.bottomAnchor),
            bannerSlides.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerSlides.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -5),
            bannerSlides.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            
            topView.topAnchor.constraint(equalTo: view.topAnchor),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: Self.topViewHeight),
            
            profileImageView.heightAnchor.constraint(equalToConstant: Self.topViewHeight - 10),
            profileImageView.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
            
            pager.heightAnchor.constraint(equalToConstant: 30),
            pager.bottomAnchor.constraint(equalTo: bannerSlides.bottomAnchor),
            pager.widthAnchor.constraint(lessThanOrEqualTo: bannerSlides.widthAnchor),
            pager.centerXAnchor.constraint(equalTo: bannerSlides.centerXAnchor),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
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
    
    private func addImageToSlides() {
        let index = bannerImages.count - 1
        let point = CGPoint(x: bannerSlides.frame.width * CGFloat(index), y: 0)
        let imageView = UIImageView(frame: CGRect(origin: point, size: bannerSlides.frame.size))
        imageView.image = bannerImages[index]
        bannerSlides.addSubview(imageView)
        bannerSlides.contentSize.width = CGFloat(bannerSlides.frame.width * CGFloat(bannerImages.count))
        pager.numberOfPages = bannerImages.count
    }
}

extension LanguageListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return languages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LanguageCell.identifier, for: indexPath) as! LanguageCell
        
        cell.nameLabel.text = languages[indexPath.item].name
        cell.priceLabel.text = languages[indexPath.item].price?.description
        cell.descriptionLabel.text = languages[indexPath.item].description
        
        if let url = languages[indexPath.item].imageURL {
            cell.imageView.downloaded(from: url, contentMode: .scaleAspectFill)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2 - 10
        return CGSize(width: width, height: width)
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
            let navVC = UINavigationController(rootViewController: detailVC)
            navVC.navigationBar.barTintColor = .systemYellow
            self.present(navVC, animated: true)
        }
    }
}

extension LanguageListVC: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let width = scrollView.bounds.size.width
        pager.currentPage = Int(ceil(x/width))
    }
    
    // Tapping on pagecontrol changes scrollView contentOffset also..
    @objc private func pageControlTap(_ sender: UIPageControl) {
        let pageWidth: CGFloat = bannerSlides.frame.width
        let slideToX: CGFloat = CGFloat(sender.currentPage) * pageWidth
        bannerSlides.setContentOffset(CGPoint(x: slideToX, y: 0), animated: true)
    }
}
