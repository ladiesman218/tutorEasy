//
//  CourseDetailVC.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/30.
//

import UIKit
import SkeletonView

class CourseDetailVC: UIViewController {
	// MARK: - Properties
	var courseID: UUID!
	
	// Init value of the array is with place holder urls and stages. When loadCourse() returns, it's gonna replace urls with actual directory urls of the stages. This way when total number of stages for a course is changed, users can pull to refresh to get the right number(comparing to set urls when initializing this vc, users will have to go back to previous VC and refresh course info). Then when each cell is about to be scrolled in screen, loadStage() will be called for each cell, which get the actual stage for the given index, and store the stage back to this array, so next time the cell is scrolled back to be displayed, we don't need to download the stage again.
	private var stageTuples: [(url: URL, stage: Stage)] = .init(repeating: (url: placeHolderURL, stage: placeHolderStage), count: placeHolderNumber)
	
	private var loadCourseTask: Task<Void, Never>?
	private var cellHeight: CGFloat!
	private var cellWidth: CGFloat!
	private var cellSize: CGSize!
	private var imageSize: CGSize!
	private let skeletonAnimation = GradientDirection.leftRight.slidingAnimation(duration: 2.5, autoreverses: false)
	
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
		cv.register(StageCollectionCell.self, forCellWithReuseIdentifier: StageCollectionCell.identifier)
		cv.translatesAutoresizingMaskIntoConstraints = false
		
		cv.layer.cornerRadius = 20
		cv.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
		cv.backgroundColor = .systemGray5
		
		return cv
	}()
	
	private let refreshControl = UIRefreshControl()
	
	// MARK: - Controller functions
	// When coming back from a previous VC, clear selection otherwise former selected item still shows different background color.
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		stageCollectionView.selectItem(at: nil, animated: false, scrollPosition: .top)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		loadCourseTask?.cancel()
		loadCourseTask = nil
		
		stageCollectionView.visibleCells.map { $0 as! StageCollectionCell }.forEach {
			$0.loadStageTask?.cancel()
			$0.loadStageTask = nil
			$0.loadImageTask?.cancel()
			$0.loadImageTask = nil
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		loadCourse()
		
		view.backgroundColor = .systemBackground
		topView = configTopView()
		
		topView.addSubview(iconView)
		
		backButtonView = setUpGoBackButton(in: topView)
		
		courseTitle.font = courseTitle.font.withSize(Self.topViewHeight / 2)
		courseTitle.layer.cornerRadius = courseTitle.font.pointSize * 0.8
		topView.addSubview(courseTitle)
		
		refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
		stageCollectionView.addSubview(refreshControl)
		stageCollectionView.refreshControl = refreshControl
		
		view.addSubview(stageCollectionView)
		stageCollectionView.dataSource = self
		stageCollectionView.delegate = self
		
		// Disable horizontal scroll
		stageCollectionView.contentSize = .init(width: stageCollectionView.frame.width, height: stageCollectionView.contentSize.height)
		
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
			stageCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor) ])
		
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		cellHeight = stageCollectionView.bounds.height / 2.5
		cellWidth = stageCollectionView.bounds.width
		cellSize = CGSize(width: cellWidth, height: cellHeight)
		imageSize = CGSize(width: cellHeight, height: cellHeight)
	}
	
	// MARK: - Custom Functions
	private func loadCourse() {
		loadCourseTask = Task { [weak self] in
			guard let strongSelf = self else { return }
			do {
				let course = try await CourseAPI.getCourse(id: strongSelf.courseID)
				try Task.checkCancellation()
				self?.stageTuples = course.stageURLs.map { (url: $0, stage: placeHolderStage) }
				self?.stageCollectionView.reloadData()
			} catch is CancellationError { return }
			catch {
				let cancel = UIAlertAction(title: "取消", style: .cancel)
				let retry = UIAlertAction(title: "重试", style: .default) { action in
					self?.refresh(sender: self?.refreshControl)
				}
				error.present(on: strongSelf, title: "无法载入课程详情", actions: [retry, cancel])
			}
		}
	}
	
	private func loadStage(forItem index: Int) -> Task<Void, Never> {
		let url = stageTuples[index].url
		
		let task = Task { [weak self] in
			guard let strongSelf = self else { return }
			
			do {
				let randomNumber = Double.random(in: 1...3)
				try await Task.sleep(nanoseconds: UInt64(randomNumber) * 1_000_000_000)
				
				let stage = try await CourseAPI.getStage(path: url.path)
				try Task.checkCancellation()
				// Store stage back to datasource, so next time it's called, we don't need to download it again.
				self?.stageTuples[index].stage = stage
				
				self?.stageCollectionView.reloadItems(at: [.init(item: index, section: 0)])
			} catch is CancellationError { return }
			catch {
				print("load stage failed for \(index)")
#warning("Set image to the same failed loading image in chaptersVC")
			}
		}
		return task
	}
	
	private func loadImage(forItem index: Int) -> Task<Void, Error> {
		let stage = stageTuples[index].stage
#warning("first image won't show sometimes")
		let task = Task { [weak self] in
			guard let strongSelf = self else { return }
			let randomNumber = Double.random(in: 1...3)
			try await Task.sleep(nanoseconds: UInt64(randomNumber) * 1_000_000_000)
			let image = try await UIImage.load(from: stage.imageURL, size: strongSelf.imageSize)
			try Task.checkCancellation()
			// Store image back 1to datasource, so next time it's called, we don't need to download it again.
			self?.stageTuples[index].stage.image = image
			self?.stageCollectionView.reloadItems(at: [.init(item: index, section: 0)])
		}
		return task
	}
	
	@objc private func refresh(sender: UIRefreshControl?) {
		loadCourseTask?.cancel()
		loadCourseTask = nil
		
		stageCollectionView.visibleCells.map { $0 as! StageCollectionCell }.forEach {
			$0.loadStageTask?.cancel()
			$0.loadStageTask = nil
			$0.loadImageTask?.cancel()
			$0.loadStageTask = nil
		}
		
		stageTuples = .init(repeating: (url: placeHolderURL, stage: placeHolderStage), count: placeHolderNumber)
		stageCollectionView.reloadData()
		refreshControl.endRefreshing()
		loadCourse()
	}
}

extension CourseDetailVC: SkeletonCollectionViewDataSource, SkeletonCollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
		StageCollectionCell.identifier
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		stageTuples.count
	}
	
	// cellForItem(at:) method is called automatically when the cell or the entire collectionView is reloaded, and it's called before viewWillDisplay(_:, forItemAt:) function, which in contrast will not be called when cell or collectionView is reloaded.
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StageCollectionCell.identifier, for: indexPath) as! StageCollectionCell
		cell.contentView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .asbestos, secondaryColor: .clouds), animation: skeletonAnimation, transition: .none)
		
		let stage = stageTuples[indexPath.item].stage
		guard stage != placeHolderStage else {
			cell.loadStageTask = loadStage(forItem: indexPath.item)
			return cell
		}
		cell.titleLabel.stopSkeletonAnimation()
		cell.titleLabel.hideSkeleton(reloadDataAfter: false, transition: .none)
		cell.titleLabel.text = stage.name
		cell.descriptionLabel.stopSkeletonAnimation()
		cell.descriptionLabel.hideSkeleton(reloadDataAfter: false, transition: .none)
		cell.descriptionLabel.text = stage.description
		
		guard let image = stage.image else {
			cell.loadImageTask = loadImage(forItem: indexPath.item)
			return cell
		}
		
		cell.imageView.stopSkeletonAnimation()
		cell.imageView.hideSkeleton(reloadDataAfter: false, transition: .none)
		cell.imageView.image = image
		
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
		let cell = collectionView.cellForItem(at: indexPath) as! StageCollectionCell
		return !cell.titleLabel.sk.isSkeletonActive
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let chaptersVC = ChaptersVC()
		let stage = stageTuples[indexPath.item].stage
		assert(courseTitle.text != nil, "Empty course title")
		chaptersVC.stageURL = stage.directoryURL
		chaptersVC.courseName = self.courseTitle.text!
		chaptersVC.stageName = stage.name
		self.navigationController?.pushIfNot(newVC: chaptersVC)
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
		return false
	}
}
