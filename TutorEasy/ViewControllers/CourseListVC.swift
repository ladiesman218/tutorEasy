import UIKit
import SkeletonView

class CourseListVC: UIViewController {
	
	// MARK: - Properties
	private var courses: [Course] = .init(repeating: placeHolderCourse, count: placeHolderNumber)
	private var loadCoursesTask: Task<Void, Never>?
	private var cellWidth: CGFloat!
	private var cellSize: CGSize!
	
	// MARK: - Custom subviews
	private let courseCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.backgroundColor = .systemGray5
		collectionView.layer.cornerRadius = 20
		collectionView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
		collectionView.contentInset = .init(top: 30, left: 30, bottom: 30, right: 30)
		
		collectionView.register(CourseCell.self, forCellWithReuseIdentifier: CourseCell.identifier)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		return collectionView
	}()
	
	private let refreshControl = UIRefreshControl()
	
	private var topView: UIView!
	
	private let iconView: ProfileIconView = .init(frame: .zero, extraInfo: true)
	
	// MARK: - Controller functions
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		let totalWidth = courseCollectionView.bounds.width - (courseCollectionView.contentInset.left + courseCollectionView.contentInset.right)
		cellWidth = totalWidth / 4 - 15
		cellSize = .init(width: cellWidth, height: cellWidth)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// This vc is kinda special, it's the entrance for most of this app's major functions. So we launch loadCourse() in viewDidLoad() and never cancel its tasks.
		loadCoursesTask = loadCourses()
		view.backgroundColor = UIColor.systemBackground
		
		refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
		refreshControl.tintColor = .systemYellow
		courseCollectionView.addSubview(refreshControl)
		courseCollectionView.refreshControl = refreshControl
		
		view.addSubview(courseCollectionView)
		courseCollectionView.dataSource = self
		courseCollectionView.delegate = self
		
		topView = configTopView()
		
		topView.addSubview(iconView)
		
		NSLayoutConstraint.activate([
			topView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
			topView.heightAnchor.constraint(equalToConstant: Self.topViewHeight),
			
			iconView.heightAnchor.constraint(equalTo: topView.heightAnchor, multiplier: 0.95),
			iconView.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
			iconView.widthAnchor.constraint(equalTo: topView.widthAnchor),
			iconView.leadingAnchor.constraint(equalTo: topView.leadingAnchor),
			
			courseCollectionView.leadingAnchor.constraint(equalTo: iconView.leadingAnchor),
			courseCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant:  -20),
			courseCollectionView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 20),
			courseCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
		])
	}
	
	// MARK: - Custom Functions
	private func loadCourses() -> Task<Void, Never> {
		let task = Task { [weak self] in
			// When user is not logged in, AuthenticationVC maybe pushed into nav stack, if loadCourses() fails while AuthVC is the top vc of nav stack, make sure alert won't pop up to confuse user. But we still need to tell user loading courses failed, this is done by setting images for place holder cell's to load-failed.png
			do {
//				try await Task.sleep(nanoseconds: 4_000_000_000)
				self?.courses = try await CourseAPI.getAllCourses()
				try Task.checkCancellation()
				self?.courseCollectionView.reloadData()
			} catch is CancellationError { return }
			catch {
				guard let strongSelf = self else { return }
				for case let cell as CourseCell in (0 ... strongSelf.courses.count - 1).map({
					self?.courseCollectionView.cellForItem(at: .init(item: $0, section: 0)) }) {
					cell.imageView.image = failedImage
					cell.imageView.backgroundColor = .systemBrown
					cell.setNeedsLayout()
				}
				
				// Do not show alert when self is not the top VC of nav stack
				guard self?.navigationController?.topViewController == self else {
					// This early `return` may actually happen, so when it happens, end refresh if there is one ongoing, so refreshControl won't be displayed if user come back to this vc later.
					self?.refreshControl.endRefreshing()
					return
				}
				
				let retry = UIAlertAction(title: "重试", style: .default) { action in
					self?.refresh(sender: strongSelf.refreshControl)
				}
				let cancel = UIAlertAction(title: "取消", style: .cancel)
				error.present(on: strongSelf, title: "无法获取课程列表", actions: [retry, cancel])
			}
			self?.refreshControl.endRefreshing()
		}
		return task
	}
	
	private func loadImage(forItem index: Int) -> Task<Void, Error> {
		
		let task = Task { [weak self] in
			//				try await Task.sleep(nanoseconds: 3_000_000_000)
			guard let strongSelf = self else { return }
			let course = strongSelf.courses[index]
			let image = await UIImage.load(from: course.imageURL, size: strongSelf.cellSize)
			try Task.checkCancellation()
			
			self?.courses[index].image = image
			
			if let cell = self?.courseCollectionView.cellForItem(at: .init(item: index, section: 0)) as? CourseCell {
				cell.imageView.image = image
				cell.setNeedsLayout()
			}
		}
		return task
	}
	
	@objc private func refresh(sender: UIRefreshControl) {
		courses = .init(repeating: placeHolderCourse, count: placeHolderNumber)
		courseCollectionView.reloadData()
		loadCoursesTask = loadCourses()
	}
}

extension CourseListVC: SkeletonCollectionViewDelegate, SkeletonCollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
		CourseCell.identifier
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return courses.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CourseCell.identifier, for: indexPath) as! CourseCell
		
		guard courses[indexPath.item] != placeHolderCourse else { return cell }
		
		guard courses[indexPath.item].image != nil else {
			cell.loadImageTask = loadImage(forItem: indexPath.item)
			return cell
		}
		
		cell.imageView.image = courses[indexPath.item].image
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return cellSize
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
		detailVC.courseTitle.text = courses[indexPath.item].name
		self.navigationController?.pushIfNot(newVC: detailVC)
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		return courses[indexPath.item] != placeHolderCourse
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
		return false
	}
}
