import UIKit

class LanguageListVC: UIViewController {
	
	// MARK: - Properties
	
	// lan is just an empty placeholder, render enought language item in collection view before actual languages are fetched from server.
	static let lan = Language(id: UUID(), name: "", description: "", price: nil, courses: [], directoryURL: URL(fileURLWithPath: ""), imagePath: nil)
	static let placeHolderNumber = 20
	
	private var languages: [Language] = .init(repeating: lan, count: placeHolderNumber) {
		didSet {
			self.collectionView.reloadData()
		}
	}
	
	//	private var bannerImages = [UIImage]() {
	//		didSet { addImageToSlides() }
	//	}
	
	// MARK: - Custom subviews
	//	private let scrollView: UIScrollView = {
	//		let scrollView = UIScrollView()
	////		scrollView.
	//		scrollView.translatesAutoresizingMaskIntoConstraints = false
	//		scrollView.backgroundColor = .red
	//		return scrollView
	//	}()
	
	private var collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: .init(origin: .zero, size: .zero), collectionViewLayout: layout)
		collectionView.backgroundColor = .systemGray5
		collectionView.layer.cornerRadius = 20
		collectionView.register(LanguageCell.self, forCellWithReuseIdentifier: LanguageCell.identifier)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		return collectionView
	}()
	
	private var topView: UIView!
	
	private var iconView: ProfileIconView! = .init(frame: .zero, extraInfo: true)
	
	//	private var bannerScrollView: UIScrollView = {
	//		let scrollView = UIScrollView()
	//		scrollView.isPagingEnabled = true
	//		scrollView.bounces = false
	////		scrollView.backgroundColor = .blue
	//		scrollView.translatesAutoresizingMaskIntoConstraints = false
	//		return scrollView
	//	}()
	
	//	private let pager: UIPageControl = {
	//		let pageControl = UIPageControl()
	//		pageControl.currentPage = 1
	//		pageControl.currentPageIndicatorTintColor = .blue
	//		pageControl.pageIndicatorTintColor = .red
	//		pageControl.layer.zPosition = .greatestFiniteMagnitude
	//		pageControl.translatesAutoresizingMaskIntoConstraints = false
	//		return pageControl
	//	}()
	
	// MARK: - Controller functions
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = backgroundColor
		
		//		view.addSubview(scrollView)
		
		//		scrollView.addSubview(bannerScrollView)
		//		scrollView.addSubview(collectionView)
		
		//		loadBanners()
		//		bannerScrollView.addSubview(pager)
		view.addSubview(collectionView)
		collectionView.dataSource = self
		collectionView.delegate = self
		
		topView = configTopView(bgColor: UIColor.clear)
		
		iconView.translatesAutoresizingMaskIntoConstraints = false
		topView.addSubview(iconView)
		
		//		let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.profileIconClicked))
		//		iconView.addGestureRecognizer(tap)
		//
		
		NSLayoutConstraint.activate([
			iconView.heightAnchor.constraint(equalTo: topView.heightAnchor, multiplier: 0.95),
			iconView.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
			iconView.widthAnchor.constraint(greaterThanOrEqualToConstant: 300),
			iconView.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
			
			//			scrollView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 20),
			//			scrollView.leadingAnchor.constraint(equalTo: iconView.leadingAnchor),
			//			scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
			//			scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			//
			//			bannerScrollView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			//			bannerScrollView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			//			bannerScrollView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			//			bannerScrollView.heightAnchor.constraint(equalToConstant: view.bounds.size.width * 0.4),
			//
			collectionView.leadingAnchor.constraint(equalTo: iconView.leadingAnchor),
			
			collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant:  -20),
			collectionView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 20),
			collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
		])
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
	
	//	private func loadBanners() {
	//
	//		// We don't know how many banners are stored on server side, so query /api/file/banner/paths for all possible banner file paths first.
	//		let queryBannersPath = FileAPI.publicFileEndPoint.appendingPathComponent("banner").appendingPathComponent("paths")
	//
	//		URLSession.shared.pathsTask(with: URLRequest(url: queryBannersPath)) { [unowned self] paths, response, error in
	//			guard let paths = paths else { return }
	//
	//			for path in paths {
	//				FileAPI.getFile(path: path) { data, response, error in
	//					guard let data = data, error == nil else {
	//						MessagePresenter.showMessage(title: "获取Banner错误", message: error?.localizedDescription ?? "服务器错误", on: self, actions: [])
	//						return
	//					}
	//
	//					if let image = UIImage(data: data) {
	//						self.bannerImages.append(image)
	//					}
	//				}
	//			}
	//		}.resume()
	//
	//	}
	//
	//	private func addImageToSlides() {
	//		guard bannerImages.count != 0 else { return }
	//		let index = bannerImages.count - 1
	//		let point = CGPoint(x: bannerScrollView.frame.width * CGFloat(index), y: 0)
	//		let imageView = UIImageView(frame: CGRect(origin: point, size: bannerScrollView.frame.size))
	//		imageView.image = bannerImages[index]
	//		bannerScrollView.addSubview(imageView)
	//		bannerScrollView.contentSize.width = CGFloat(bannerScrollView.frame.width * CGFloat(bannerImages.count))
	//		pager.numberOfPages = bannerImages.count
	//	}
}

extension LanguageListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return languages.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LanguageCell.identifier, for: indexPath) as! LanguageCell
		//            cell.nameLabel.text = languages[indexOffset].name
		//            cell.priceLabel.text = languages[indexOffset].price?.description
		//            cell.descriptionLabel.text = languages[indexOffset].description
		if let path = languages[indexPath.item].imagePath {
			cell.imageView.downloaded(from: path, contentMode: .scaleAspectFill)
		}
		return cell
	}
	
	
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = collectionView.bounds.width / 4 - 20
		return .init(width: width, height: width)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return .init(top: 20, left: 20, bottom: 20, right: 20)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		let id = languages[indexPath.item].id   // -1 is also for banner
		
		//        let detailVC = LanguageDetailVC()
		//        self.navigationController?.pushViewController(detailVC, animated: false)
		
		LanguageAPI.getLanguage(id: id) { [unowned self] language, response, error in
			
			guard let language = language, error == nil else {
				MessagePresenter.showMessage(title: "获取课程失败", message: error!.reason, on: self, actions: [])
				return
			}
			
			let detailVC = LanguageDetailVC()
			detailVC.language = language
			self.navigationController?.pushViewController(detailVC, animated: false)
		}
	}
	
	
	//	func configCollectionView(numberOfItems: Int) -> UICollectionView {
	//		let contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
	//
	//		// Screen ratio between different devices are not equal, so if we set width and height separatly, items we get will have different ratios on different devices. Here we want ratio to be fixed, so anchor height to width.
	//		// Hard part to understand the sizing with fractional methods, is to calculate backwards. If parameter numbers seem hard to reason about, try to figure out its parent size first, that means, keep calm and read on.
	//		let bannerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5))
	//		let bannerItem = NSCollectionLayoutItem(layoutSize: bannerSize)
	//		bannerItem.contentInsets = contentInsets
	//
	//		// Half of its parent group width, since its parent takes up half of all width later, this one takes 1/4.
	//		let topRightItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5))
	//		let topRightItem = NSCollectionLayoutItem(layoutSize: topRightItemSize)
	//		topRightItem.contentInsets = contentInsets
	//
	//		// A horizontal group contains 2 items. This will be wrapped in a group which takes up half of total width, so set height to half of its width will be 1/4 of total width, essentially gives us just the right amount of space to hold the item's height.
	//		let topRightRow = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5)), subitems: [topRightItem, topRightItem])
	//		let topRightGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5)), subitems: [topRightRow, topRightRow])
	//
	//		// The top group in all, combined with the banner, and the 2 by 2 grid.
	//		let topGroup = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5)), subitems: [bannerItem, topRightGroup])
	//
	//		let group: NSCollectionLayoutGroup  // To hold the final group
	//
	//		//         If language count is no more than 4, set the final group to contain topGroup only.
	//		if numberOfItems <= 4 {
	//			group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1000)), subitems: [topGroup])
	//		} else {
	//			// Create cells for extra items, and wrap them in groups. Normal means size for cells below banner.
	//			let normalSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/4), heightDimension: .fractionalWidth(1/4))
	//			let normalItem = NSCollectionLayoutItem(layoutSize: normalSize)
	//			normalItem.contentInsets = contentInsets
	//			// Create a single row. Again height is anchored to width
	//			let normalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: /*.fractionalHeight(1/8)*/.fractionalWidth(1/4)), subitems: [normalItem, normalItem, normalItem, normalItem])
	//
	//			// Calculate how many rows are needed. Notice the value of 'row' will be used to create group as repeatingSubitem/count parameter, so its value has to be greater than or equal to 1, or app will crash.
	//			let floatCount = Float(numberOfItems) //Float(20)
	//			// Top-right corner already has 4 items, take that into account.
	//			let removedTopRight = floatCount - 4
	//			// Each row has 4 items, if the division has a remainder, round up to get an extra row, thus all items get displayed.
	//			let row = Int(ceil(removedTopRight / 4))//Int((removedTopRight / 4).rounded(.up))
	//
	//			// According to previous configuration, normalGroup's height dimension is a decimal number(1/4 to be exact). This is the height for 1 row, we will use this value to get total height for the group below banner later.
	//			let height = normalGroup.layoutSize.heightDimension.dimension
	//
	//			// Create a vertical group to wrap all rows in.
	//			var rowsGroup: NSCollectionLayoutGroup
	//
	//			if #available(iOS 16.0, *) {
	//				// Height of the group is also anchored to width, calculated by row and height values.
	//				rowsGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(CGFloat(row) * height)), repeatingSubitem: normalGroup, count: row)
	//			} else {
	//				rowsGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(CGFloat(row) * height)), subitem: normalGroup, count: row)
	//			}
	//
	//			let topGroupHeight = self.view.bounds.width / 2
	//			let normalLineHeight = self.view.bounds.width / 4
	//			let normalGroupHeight = CGFloat(row) * normalLineHeight
	//			let totalHeight = normalGroupHeight + topGroupHeight
	//			print(languages.count)
	//			print(totalHeight)
	//			group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: /*.fractionalHeight(2)*//*.absolute(totalHeight)*/.estimated(1300)), subitems: [topGroup, rowsGroup])
	//		}
	//
	//		let section = NSCollectionLayoutSection(group: group)
	//
	//		let layout = UICollectionViewCompositionalLayout(section: section)
	//		let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
	//
	//		collectionView.register(LanguageCell.self, forCellWithReuseIdentifier: LanguageCell.identifier)
	//		collectionView.register(BannerSlidesCell.self, forCellWithReuseIdentifier: BannerSlidesCell.identifier)
	//		collectionView.translatesAutoresizingMaskIntoConstraints = false
	//
	//		collectionView.backgroundColor = UIColor.clear      // Without this, collectionView will get an black bg color
	//		collectionView.dataSource = self
	//		collectionView.delegate = self
	//		return collectionView
	//	}
}
