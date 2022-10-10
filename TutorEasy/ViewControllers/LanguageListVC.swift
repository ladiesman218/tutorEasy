import UIKit

class LanguageListVC: UIViewController {
    
    private var languagesCollectionView: UICollectionView!
    private var bannerSlides: UIScrollView!
    private var topView: UIView!
    private var profileImageView: UIImageView!
    private let pager = UIPageControl()
    
    var languages = [Language.PublicInfo]() {
        didSet { self.languagesCollectionView.reloadData() }
    }
    
    private var bannerImages = [UIImage]() {
        didSet {
            print(bannerImages.count)
            addImageToSlides()
        }
    }
    
    #warning("Page control display bugs")
    func configPager() {
        pager.backgroundColor = .red
        pager.currentPage = 1
//        pager.frame = CGRect(x: 10, y: bannerSlides.frame.height - 30, width: bannerSlides.frame.width - 20, height: 30)
        pager.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pager.topAnchor.constraint(equalTo: bannerSlides.topAnchor),
            pager.heightAnchor.constraint(equalToConstant: 100),
            pager.leadingAnchor.constraint(equalTo: bannerSlides.leadingAnchor),
            pager.widthAnchor.constraint(equalToConstant: 100)
        ])
        pager.layer.zPosition = .greatestFiniteMagnitude

    }
    
            
    override func loadView() {
        super.loadView()
        loadLanguages()
        loadBanners()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = backgroundColor
        
        configTopView()
        configCollectionView()
        configBannerSlides()
        bannerSlides.addSubview(pager)

        configPager()

//        pager.frame = CGRect(x: 10, y: bannerSlides.frame.height - 30, width: bannerSlides.frame.width - 20, height: 30)
//        pager.layer.zPosition = .greatestFiniteMagnitude

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
                guard let res = response as? HTTPURLResponse, res.statusCode == 200, error == nil else {
                    return
                }
                guard let data = data else { return }
                let image = UIImage(data: data)!
                DispatchQueue.main.async {
                    self.bannerImages.append(image)
                }
            }.resume()
        }
    }
    
    func configTopView() {
        
        let topViewHeight: CGFloat = 70
        
        topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topView)
        
        profileImageView = UIImageView()
        profileImageView.backgroundColor = .yellow
        profileImageView.layer.cornerRadius = (topViewHeight - 10) / 2
        profileImageView.clipsToBounds = true
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(profileImageView)
        
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.topAnchor),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: topViewHeight),
            
            profileImageView.heightAnchor.constraint(equalToConstant: topViewHeight - 10),
            profileImageView.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20)
        ])
    }
    
    func configBannerSlides() {
        bannerSlides = UIScrollView()
        bannerSlides.isPagingEnabled = true
        bannerSlides.bounces = false
        bannerSlides.translatesAutoresizingMaskIntoConstraints = false
        bannerSlides.backgroundColor = .red
        view.addSubview(bannerSlides)
        
        NSLayoutConstraint.activate([
            bannerSlides.topAnchor.constraint(equalTo: topView.bottomAnchor),
            bannerSlides.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerSlides.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10),
            bannerSlides.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
        ])
        
        bannerSlides.contentSize.height = bannerSlides.frame.height
    }
    
    func addImageToSlides() {
        let index = bannerImages.count - 1
        let point = CGPoint(x: bannerSlides.frame.width * CGFloat(index), y: 0)
        let imageView = UIImageView(frame: CGRect(origin: point, size: bannerSlides.frame.size))
        imageView.image = bannerImages[index]
        bannerSlides.addSubview(imageView)
        bannerSlides.contentSize.width = CGFloat(bannerSlides.frame.width * CGFloat(bannerImages.count))
        pager.numberOfPages = bannerImages.count
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let x = scrollView.contentOffset.x
            let w = scrollView.bounds.size.width
            pager.currentPage = Int(ceil(x/w))
    }
    
    func configCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        languagesCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        languagesCollectionView.register(LanguageCell.self, forCellWithReuseIdentifier: LanguageCell.identifier)
        
        if #available(iOS 13.0, *) {
            languagesCollectionView.backgroundColor = .systemGray6
        } else {
            languagesCollectionView.backgroundColor = .white
        }
        
        languagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        languagesCollectionView.delegate = self
        languagesCollectionView.dataSource = self
        view.addSubview(languagesCollectionView)
        
        NSLayoutConstraint.activate([
            languagesCollectionView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            languagesCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width / 2),
            languagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            languagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        ])
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
            //                self.show(navVC, sender: self)
            self.present(navVC, animated: true)
        }
        
    }
}
