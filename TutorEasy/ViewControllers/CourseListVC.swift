import UIKit
import SkeletonView

class CourseListVC: UIViewController {
	
	// MARK: - Properties
	private var courses: [Course] = .init(repeating: placeHolderCourse, count: placeHolderNumber)
	// Hold a reference to load all courses task. When needed, we can cancel it. We need to cancel the old task so refresh could work.
	private var loadCoursesTask: Task<Void, Never>?

	// MARK: - Custom subviews
	private let collectionView: UICollectionView = {
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
	override func viewDidLoad() {
		super.viewDidLoad()
		loadCourses()
		view.backgroundColor = UIColor.systemBackground
		
		refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
		collectionView.addSubview(refreshControl)
		collectionView.refreshControl = refreshControl
		
		view.addSubview(collectionView)
		collectionView.dataSource = self
		collectionView.delegate = self
		
		topView = configTopView()
		
		topView.addSubview(iconView)
		
		NSLayoutConstraint.activate([
			topView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
			topView.heightAnchor.constraint(equalToConstant: Self.topViewHeight),
			
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
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		loadCoursesTask?.cancel()
		loadCoursesTask = nil
		collectionView.visibleCells.map { $0 as! CourseCell }.forEach {
			$0.loadImageTask?.cancel()
			$0.loadImageTask = nil
		}
	}
	
	// MARK: - Custom Functions
	private func loadCourses() {
		loadCoursesTask = Task {
			do {
				self.courses = try await CourseAPI.getAllCourses()
				collectionView.reloadData()
			} catch is CancellationError {
				// If Task is canceled, do nothing
				return
			} catch {
				let retry = UIAlertAction(title: "重试", style: .cancel) { [unowned self] action in
					refresh(sender: self.refreshControl)
				}
				error.present(on: self, title: "无法获取课程列表", actions: [retry])
			}
		}
	}
	
	private func loadImage(forItem index: Int) async throws {
		let course = courses[index]
		
		// If the course is a place holder, then loadCourses() is unfinished, no need to download image
		guard course != placeHolderCourse else { return }
		// If there is an image, no need to download it again
		guard course.image == nil else { return }
		
		let width = collectionView.bounds.size.width / 4.2
		let size = CGSize(width: width, height: width)
		
		let image = try await UIImage.load(from: course.imageURL, size: size)
		try Task.checkCancellation()
		
		courses[index].image = image
		if collectionView.indexPathsForVisibleItems.contains(where: { indexPath in
			indexPath.item == index
		}) {
			collectionView.reloadItems(at: [.init(item: index, section: 0)])
		}
	}
	
	@objc private func refresh(sender: UIRefreshControl) {
		loadCoursesTask?.cancel()
		loadCoursesTask = nil
		// Cancel all loadImageTasks
		collectionView.visibleCells.map { $0 as! CourseCell }.forEach {
			$0.loadImageTask?.cancel()
			$0.loadImageTask = nil
		}
		// Re-generate datasource
		courses = .init(repeating: placeHolderCourse, count: placeHolderNumber)
		collectionView.reloadData()
		loadCourses()
		refreshControl.endRefreshing()
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
		cell.imageView.image = courses[indexPath.item].image
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CourseCell.identifier, for: indexPath) as! CourseCell
		cell.loadImageTask = Task { [weak self] in
			try await self?.loadImage(forItem: indexPath.item)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CourseCell.identifier, for: indexPath) as! CourseCell
		cell.loadImageTask?.cancel()
		cell.loadImageTask = nil
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
		let cell = collectionView.cellForItem(at: indexPath) as! CourseCell
		return !cell.sk.isSkeletonActive
	}
}
