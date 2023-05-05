import UIKit

class CourseListVC: UIViewController {
	
	// MARK: - Properties
	private var courses: [Course] = .init(repeating: coursePlaceHolder, count: placeholderForNumberOfCells) {
		didSet {
			Task {
				let urls = courses.map { $0.imageURL }
				courseImages = await downloadImages(urls: urls)
			}
		}
	}
	
	private var courseImages: [UIImage?] = .init(repeating: nil, count: placeholderForNumberOfCells) {
		didSet { loaded = true }
	}
	
	private var loaded = false {
		didSet { collectionView.reloadData() }
	}
	
	// MARK: - Custom subviews
	private var collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.backgroundColor = .systemGray5
		collectionView.layer.cornerRadius = 20
		collectionView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
		collectionView.contentInset = .init(top: 30, left: 30, bottom: 30, right: 30)
//		collectionView.register(SkeletonCollectionCell.self, forCellWithReuseIdentifier: SkeletonCollectionCell.identifier)
		collectionView.register(CourseCell.self, forCellWithReuseIdentifier: CourseCell.identifier)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		return collectionView
	}()
	
	private var topView: UIView!
	
	private var iconView: ProfileIconView = .init(frame: .zero, extraInfo: true)
	
	// MARK: - Controller functions
	override func viewWillAppear(_ animated: Bool) {
		loadCourses()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor.systemBackground
		
		view.addSubview(collectionView)
		collectionView.dataSource = self
		collectionView.delegate = self
		
		topView = configTopView()

		topView.addSubview(iconView)
		
		NSLayoutConstraint.activate([
            topView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
			
			iconView.heightAnchor.constraint(equalTo: topView.heightAnchor, multiplier: 0.95),
			iconView.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
			iconView.widthAnchor.constraint(equalTo: topView.widthAnchor),
			iconView.leadingAnchor.constraint(equalTo: topView.leadingAnchor),
			
			collectionView.leadingAnchor.constraint(equalTo: iconView.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant:  -20),
			collectionView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 20),
			collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
		])
	}
	
	func loadCourses() {
		Task {
			do {
				self.courses = try await CourseAPI.getAllCourses()
			} catch {
				error.present(on: self, title: "无法获取课程列表", actions: [])
			}
		}
	}
}

extension CourseListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return courses.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//		if !loaded {
//			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SkeletonCollectionCell.identifier, for: indexPath) as! SkeletonCollectionCell
//			return cell
//		} else {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CourseCell.identifier, for: indexPath) as! CourseCell
			cell.imageView.image = courseImages[indexPath.item]
			return cell
//		}
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
		let id = courses[indexPath.item].id
		let detailVC = CourseDetailVC()
		detailVC.courseID = id
		self.navigationController?.pushIfNot(newVC: detailVC)
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		return loaded
	}
}
