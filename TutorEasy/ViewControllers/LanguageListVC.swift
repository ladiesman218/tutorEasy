import UIKit

class LanguageListVC: UIViewController {
	
	// MARK: - Properties
	
	private var languages: [Language] = .init(repeating: languagePlaceHolder, count: placeholderForNumberOfCells) {
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
		Task {
			let result = await LanguageAPI.getAllLanguges()
			switch result {
				case .success(let languages):
					self.languages = languages
				case .failure(let error):
					error.present(on: self, title: "无法获取分类列表", actions: [])
			}
		}
	}
}

extension LanguageListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return languages.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LanguageCell.identifier, for: indexPath) as! LanguageCell
		cell.createShadow()
		#warning("is this gonna be a problem when list grows longer")
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
		let detailVC = LanguageDetailVC()
		detailVC.languageID = id
		self.navigationController?.pushIfNot(type: LanguageDetailVC.self, newVC: detailVC)
	}
}
