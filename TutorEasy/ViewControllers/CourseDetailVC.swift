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
	
	// Init value of the array is with place holder urls and stages. When loadCourse() returns, it's gonna replace urls with actual directory urls of the stages. This way when total number of stages for a course is changed, users can pull to refresh to get the right number(comparing to set urls when initializing this vc, users will have to go back to previous VC and refresh course info). Then when each cell is about to be scrolled onto screen, loadStage() will be called for each cell, which get the actual stage for the given index, and store the stage back to this array, so next time the cell is scrolled back to be displayed, we don't need to download the stage again
	private var stageTuples: [(url: URL, stage: Stage)] = .init(repeating: (url: placeHolderURL, stage: placeHolderStage), count: placeHolderNumber)
		
	private var loadCourseTask: Task<Void, Error>?
	
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
		stageCollectionView.selectItem(at: nil, animated: false, scrollPosition: .top)
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
			stageCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}
	
	// MARK: - Custom Functions
	private func loadCourse() {
		loadCourseTask = Task { [weak self] in
			do {
				guard let strongSelf = self else { return }
				let course = try await CourseAPI.getCourse(id: strongSelf.courseID)
				try Task.checkCancellation()
				self?.stageTuples = course.stageURLs.map { (url: $0, stage: placeHolderStage) }
				self?.stageCollectionView.reloadData()
			} catch is CancellationError {
				return
			} catch {
				guard let strongSelf = self else { return }
				let retry = UIAlertAction(title: "重试", style: .default) { action in
					self?.refresh(sender: self?.refreshControl)
				}
				let cancel = UIAlertAction(title: "取消", style: .cancel)
				error.present(on: strongSelf, title: "无法获取课程详情", actions: [retry, cancel])
			}
		}
	}
	
	private func loadStage(forItem index: Int) async throws {
		let url = stageTuples[index].url
		// Make sure loadCourse() has finished
		guard url != placeHolderURL else { return }
		
		if stageTuples[index].stage == placeHolderStage {
			let stage = try await CourseAPI.getStage(path: url.path)
			try Task.checkCancellation()
			stageTuples[index].stage = stage
			
			if stageCollectionView.indexPathsForVisibleItems.contains(where: {
				$0.item == index
			}) {
				stageCollectionView.reloadItems(at: [.init(item: index, section: 0)])
			}
		}
	}
	
	@objc private func refresh(sender: UIRefreshControl?) {
		loadCourseTask?.cancel()
		loadCourseTask = nil
		
		stageCollectionView.visibleCells.map { $0 as! StageCollectionCell }.forEach {
			$0.loadStageTask?.cancel()
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
		
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StageCollectionCell.identifier, for: indexPath) as! StageCollectionCell

		if stageTuples[indexPath.item].stage.name != placeHolderStage.name {
			cell.titleLabel.text = stageTuples[indexPath.row].stage.name
			cell.descriptionLabel.text = stageTuples[indexPath.row].stage.description
		}
		cell.imageView.image = stageTuples[indexPath.row].stage.image
		
//		cell.backgroundColor = tableView.backgroundColor
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StageCollectionCell.identifier, for: indexPath) as! StageCollectionCell
		cell.loadStageTask = Task { [weak self] in
			try? await self?.loadStage(forItem: indexPath.row)
		}
	}

	func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StageCollectionCell.identifier, for: indexPath ) as! StageCollectionCell
		cell.loadStageTask?.cancel()
		cell.loadStageTask = nil
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 5
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 10
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = stageCollectionView.bounds.width
		let height = stageCollectionView.bounds.height / 2.5
		let size = CGSize(width: width, height: height)
		return size
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
