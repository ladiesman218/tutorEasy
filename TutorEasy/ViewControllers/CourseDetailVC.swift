//
//  CourseDetailVC.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/30.
//

import UIKit
import SkeletonView

class CourseDetailVC: UIViewController {
	// MARK: - Custom Properties
	var courseID: UUID!
	
	private var stageTuples: [(url: URL, stage: Stage)] = .init(repeating: (url: placeHolderURL, stage: placeHolderStage), count: placeHolderNumber)
	
	private var loadCourseTask: Task<Void, Never>?
	private var cellHeight: CGFloat!
	private var cellWidth: CGFloat!
	private var cellSize: CGSize!
	private var imageSize: CGSize!
	
	// MARK: - Custom Subviews
	private var topView: UIView!
	private var iconView: ProfileIconView = .init(frame: .zero)
	private var backButtonView: UIView!
	
	let courseTitle: PaddingLabel = {
		let courseTitle = PaddingLabel()
		courseTitle.translatesAutoresizingMaskIntoConstraints = false
		courseTitle.textColor = .white
		courseTitle.layer.backgroundColor = UIColor.systemYellow.cgColor
		courseTitle.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
		
		return courseTitle
	}()
	
	private let stageCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		cv.register(StageCell.self, forCellWithReuseIdentifier: StageCell.identifier)
		cv.translatesAutoresizingMaskIntoConstraints = false
		
		cv.layer.cornerRadius = 20
		cv.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
		cv.backgroundColor = .systemGray5
		
		return cv
	}()
	
	private let refreshControl = UIRefreshControl()
	
	// MARK: - Controller functions
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if stageCollectionView.contentOffset.y < 0 { stageCollectionView.scrollToItem(at: .init(item: 0, section: 0), at: .top, animated: true) }
		
		guard !stageTuples.contains(where: { item in
			item.url == placeHolderURL
		}) else {
			loadCourseTask = loadCourse()
			return
		}
		
		for indexPath in stageCollectionView.indexPathsForVisibleItems {
			guard let cell = stageCollectionView.cellForItem(at: indexPath) as? StageCell else { continue }
			
			let stage = stageTuples[indexPath.item].stage
			guard stage != placeHolderStage else {
				cell.loadStageTask = loadStage(forItem: indexPath.item)
				continue
			}
			if stage.image == nil {
				cell.loadImageTask = loadImage(forItem: indexPath.item)
			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		cancelAllTasks()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		failedStage.image = failedImage
		
		view.backgroundColor = .systemBackground
		topView = configTopView()
		
		topView.addSubview(iconView)
		
		backButtonView = setUpGoBackButton(in: topView)
		
		courseTitle.font = courseTitle.font.withSize(Self.topViewHeight / 2)
		courseTitle.layer.cornerRadius = courseTitle.font.pointSize * 0.8
		topView.addSubview(courseTitle)
		
		refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
		refreshControl.tintColor = .systemYellow
		stageCollectionView.addSubview(refreshControl)
		stageCollectionView.refreshControl = refreshControl
		
		view.addSubview(stageCollectionView)
		stageCollectionView.dataSource = self
		stageCollectionView.delegate = self
		
		NSLayoutConstraint.activate([
			topView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
			topView.heightAnchor.constraint(equalToConstant: Self.topViewHeight),
			
			courseTitle.leadingAnchor.constraint(equalTo: backButtonView.trailingAnchor),
			courseTitle.topAnchor.constraint(equalTo: topView.topAnchor),
			courseTitle.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
			
			iconView.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
			iconView.topAnchor.constraint(equalTo: topView.topAnchor),
			iconView.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
			iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor),
			
			stageCollectionView.leadingAnchor.constraint(equalTo: backButtonView.leadingAnchor),
			stageCollectionView.trailingAnchor.constraint(equalTo: iconView.trailingAnchor),
			stageCollectionView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 20),
			stageCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		cellHeight = stageCollectionView.bounds.height / 2.5
		cellWidth = stageCollectionView.bounds.width
		cellSize = CGSize(width: cellWidth, height: cellHeight)
		imageSize = CGSize(width: cellHeight, height: cellHeight)
	}
	
	// MARK: - Custom Functions
	private func cancelAllTasks() {
		loadCourseTask?.cancel()
		loadCourseTask = nil
		for case let cell as StageCell in (0 ... stageTuples.count - 1).map({
			stageCollectionView.dequeueReusableCell(withReuseIdentifier: StageCell.identifier, for: .init(item: $0, section: 0))
		}) {
			cell.prepareForReuse()
		}
	}
	
	private func loadCourse() -> Task<Void, Never> {
		let task = Task { [weak self] in
			do {
				guard let strongSelf = self else { return }
				let course = try await CourseAPI.getCourse(id: strongSelf.courseID)
				self?.stageTuples = course.stageURLs.map { (url: $0, stage: placeHolderStage) }
				self?.stageCollectionView.reloadData()
			} catch {
				guard !Task.isCancelled else {
					self?.refreshControl.endRefreshing()
					return
				}
				self?.stageTuples = .init(repeating: (failedURL, failedStage), count: placeHolderNumber)
				self?.stageCollectionView.reloadData()
			}
			self?.refreshControl.endRefreshing()
		}
		return task
	}
	
	private func loadStage(forItem index: Int) -> Task<Void, Never> {
		let url = stageTuples[index].url
		let indexPath = IndexPath(row: index, section: 0)
		
		let task = Task { [weak self] in
			do {
				let stage = try await CourseAPI.getStage(path: url.path)
				
				self?.stageTuples[index].stage = stage
				self?.stageCollectionView.reloadItems(at: [indexPath])
			} catch {
				guard !Task.isCancelled else { return }
				
				self?.stageTuples[index].stage = failedStage
				self?.stageCollectionView.reloadItems(at: [indexPath])
			}
		}
		return task
	}
	
	private func loadImage(forItem index: Int) -> Task<Void, Never> {
		let stage = stageTuples[index].stage
		
		let task = Task { [weak self] in
			guard let strongSelf = self else { return }
			let image = await UIImage.load(from: stage.imageURL, size: strongSelf.imageSize)
			self?.stageTuples[index].stage.image = image
			self?.stageCollectionView.reloadItems(at: [.init(item: index, section: 0)])
		}
		return task
	}
	
	@objc private func refresh(sender: UIRefreshControl) {
		
		cancelAllTasks()
		
		stageTuples = .init(repeating: (url: placeHolderURL, stage: placeHolderStage), count: placeHolderNumber)
		stageCollectionView.reloadData()
		
		loadCourseTask = loadCourse()
	}
}

extension CourseDetailVC: SkeletonCollectionViewDataSource, SkeletonCollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
		StageCell.identifier
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		stageTuples.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StageCell.identifier, for: indexPath) as! StageCell
		guard stageTuples[indexPath.item].url != placeHolderURL else { return cell }
		
		guard stageTuples[indexPath.item].stage != placeHolderStage else {
			cell.loadStageTask = loadStage(forItem: indexPath.item)
			return cell
		}
		
		cell.titleLabel.text = stageTuples[indexPath.item].stage.name
		cell.descriptionLabel.text = stageTuples[indexPath.item].stage.description
		
		guard stageTuples[indexPath.item].stage.image != nil else {
			cell.loadImageTask = loadImage(forItem: indexPath.item)
			return cell
		}
		cell.imageView.image = stageTuples[indexPath.item].stage.image
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 5
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 10
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return cellSize
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		let stage = stageTuples[indexPath.item].stage
		return stage != placeHolderStage &&
		stage != failedStage
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let chaptersVC = ChaptersVC()
		let stage = stageTuples[indexPath.item].stage
		chaptersVC.stageURL = stage.directoryURL
		chaptersVC.courseName = self.courseTitle.text!
		chaptersVC.stageName = stage.name
		self.navigationController?.pushIfNot(newVC: chaptersVC)
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
		return false
	}
}
