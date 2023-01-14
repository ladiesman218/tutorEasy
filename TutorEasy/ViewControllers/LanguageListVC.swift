import UIKit

class LanguageListVC: UIViewController {
	
	// MARK: - Properties
	
	// lan is just an empty placeholder, render enought language item in collection view before actual languages are fetched from server.
	static let lan = Language(id: UUID(), name: "", description: "", price: 1, courses: [], directoryURL: URL(fileURLWithPath: ""), imagePath: nil, annuallyIAPIdentifer: "")
	
	private var languages: [Language] = .init(repeating: lan, count: placeholderForNumberOfCells) {
		didSet {
			self.collectionView.reloadData()
		}
	}
	
	// MARK: - Custom subviews
	private var collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: .init(origin: .zero, size: .zero), collectionViewLayout: layout)
		collectionView.backgroundColor = .systemGray5
		collectionView.layer.cornerRadius = 20
		collectionView.contentInset = .init(top: 30, left: 30, bottom: 30, right: 30)
		collectionView.register(LanguageCell.self, forCellWithReuseIdentifier: LanguageCell.identifier)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		return collectionView
	}()
	
	private var topView: UIView!
	
	private var iconView: ProfileIconView! = .init(frame: .zero, extraInfo: true)
	
	// MARK: - Controller functions
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = backgroundColor
		
		view.addSubview(collectionView)
		collectionView.dataSource = self
		collectionView.delegate = self
		
		topView = configTopView(bgColor: UIColor.clear)
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.profileIconClicked))
		iconView.addGestureRecognizer(tap)
		topView.addSubview(iconView)
		
		NSLayoutConstraint.activate([
			iconView.heightAnchor.constraint(equalTo: topView.heightAnchor, multiplier: 0.95),
			iconView.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
			iconView.widthAnchor.constraint(greaterThanOrEqualToConstant: 300),
			iconView.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
			
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
}

extension LanguageListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return languages.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LanguageCell.identifier, for: indexPath) as! LanguageCell
		
		createShadow(for: cell)
		
		if let path = languages[indexPath.item].imagePath {
			cell.imageView.downloaded(from: path, contentMode: .scaleAspectFill)
		}
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let totalWidth = collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right)
		let width = totalWidth / 4 - 15 // Accounts for the item spacing, also add extra 5 to allow shadow to be fully displayed.
		return .init(width: width, height: width)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 30
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 10
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
			self.navigationController?.pushViewController(detailVC, animated: false)
		}
	}
}
