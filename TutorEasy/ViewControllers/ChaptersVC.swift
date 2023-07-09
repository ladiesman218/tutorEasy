//
//  ChaptersVC.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/3/31.
//

import UIKit
import SkeletonView

class ChaptersVC: UIViewController {
	// MARK: - Properties
	var stageURL: URL!
	var courseName: String!
	var stageName: String!
	// Hold a reference to loadStageTask, so when viewWillDisappear, we can cancel it if it's not finished yet
	private var loadStageTask: Task<Void, Never>?
	// UIRefreshControl's isRefreshing property will always be true when refresh method is triggered, so it's useless, refreshControl's isHidden is always false so it's useless too. Hence this property is created to track if a refresh is in progress.
	private var isRefreshing = false
	// Init value of the array is with place holder urls and chapters. When loadStage() returns, it's gonna replace urls with actual directory urls of the chapters. This way when total number of chapters for a stage is changed, users can pull to refresh to get the right number(comparing to set urls when initializing this vc, users will have to go back to previous VC and refresh stage info). Then when each cell is about to be scrolled onto screen, loadChapter will be called for each cell, which get the actual chapter for the given index, and store the chapter back to this array, so next time the cell is scrolled back to be displayed, we don't need to download the chapter again
	private var chapterTuples: [(url: URL, chapter: Chapter)] = .init(repeating: (url: placeHolderURL, chapter: placeHolderChapter), count: placeHolderNumber)
	private var cellWidth: CGFloat!
	private var cellSize: CGSize!
	private var imageSize: CGSize!
	
	// MARK: - Custom subviews
	private var topView: UIView!
	private let iconView: ProfileIconView = .init(frame: .zero)
	private var backButtonView: UIView!
	
	private let courseTitle: PaddingLabel = {
		let courseTitle = PaddingLabel()
		courseTitle.translatesAutoresizingMaskIntoConstraints = false
		courseTitle.textColor = .white
		courseTitle.layer.backgroundColor = UIColor.systemYellow.cgColor
		
		return courseTitle
	}()
	
	private let stageTitle: PaddingLabel = {
		let stageTitle = PaddingLabel()
		stageTitle.translatesAutoresizingMaskIntoConstraints = false
		stageTitle.textColor = .white
		stageTitle.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
		stageTitle.layer.backgroundColor = UIColor.systemTeal.cgColor
		return stageTitle
	}()
#warning("添加双师堂按钮")
	private let chaptersCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let chaptersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		chaptersCollectionView.translatesAutoresizingMaskIntoConstraints = false
		chaptersCollectionView.register(ChapterCell.self, forCellWithReuseIdentifier: ChapterCell.identifier)
		chaptersCollectionView.contentInset = .init(top: 30, left: 30, bottom: 30, right: 30)
		chaptersCollectionView.layer.cornerRadius = 20
		chaptersCollectionView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
		chaptersCollectionView.backgroundColor = .systemGray5
		chaptersCollectionView.isSkeletonable = true
		
		return chaptersCollectionView
	}()
	
	private let refreshControl = UIRefreshControl()
	
	// MARK: - Controller functions
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		let totalWidth = chaptersCollectionView.bounds.width - (chaptersCollectionView.contentInset.left + chaptersCollectionView.contentInset.right)
		let cellWidth = totalWidth / 4 - 15 // Accounts for the item spacing, also add extra 5 to allow shadow to be fully displayed.
		imageSize = .init(width: cellWidth, height: cellWidth)
		cellSize = .init(width: cellWidth, height: cellWidth * 1.3)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		loadStageTask = loadStage()
		// Start skeleton animation for collectionView, number of cells is still affected by chapterTuples.count value, but since skeletonView is showed on collectionView, scrolling will be disbaled until loadStageTask returns.
		chaptersCollectionView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .asbestos, secondaryColor: .clouds), animation: skeletonAnimation, transition: .none)
		
		view.backgroundColor = UIColor.systemBackground
		topView = configTopView()
		
		iconView.layer.backgroundColor = UIColor.clear.cgColor
		topView.addSubview(iconView)
		
		backButtonView = setUpGoBackButton(in: topView)
		
		courseTitle.font = courseTitle.font.withSize(Self.topViewHeight / 2)
		courseTitle.text = courseName
		topView.addSubview(courseTitle)
		
		stageTitle.text = stageName
		stageTitle.font = courseTitle.font
		stageTitle.layer.cornerRadius = stageTitle.font.pointSize * 0.8
		topView.addSubview(stageTitle)
		
		refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
		chaptersCollectionView.addSubview(refreshControl)
		chaptersCollectionView.refreshControl = refreshControl
		
		view.addSubview(chaptersCollectionView)
		chaptersCollectionView.dataSource = self
		chaptersCollectionView.delegate = self
		
		NSLayoutConstraint.activate([
			topView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
			topView.heightAnchor.constraint(equalToConstant: Self.topViewHeight),
			
			courseTitle.leadingAnchor.constraint(equalTo: backButtonView.trailingAnchor),
			courseTitle.topAnchor.constraint(equalTo: topView.topAnchor),
			courseTitle.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
			
			stageTitle.leadingAnchor.constraint(equalTo: courseTitle.trailingAnchor),
			stageTitle.topAnchor.constraint(equalTo: courseTitle.topAnchor),
			stageTitle.bottomAnchor.constraint(equalTo: courseTitle.bottomAnchor),
			
			iconView.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
			iconView.topAnchor.constraint(equalTo: topView.topAnchor),
			iconView.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
			iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor),
			
			chaptersCollectionView.leadingAnchor.constraint(equalTo: backButtonView.leadingAnchor),
			chaptersCollectionView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 20),
			chaptersCollectionView.trailingAnchor.constraint(equalTo: iconView.trailingAnchor),
			chaptersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		loadStageTask?.cancel()
		loadStageTask = nil
		
		chaptersCollectionView.visibleCells.map { $0 as! ChapterCell }.forEach {
			$0.loadChapterTask?.cancel()
			$0.loadChapterTask = nil
			$0.loadImageTask?.cancel()
			$0.loadImageTask = nil
		}
	}
	
	// Unfinished loadStageTask, visible cell's loadChapter and loadImage tasks will be canceled when view disappeared. So when user goes back from a chapter detail vc, skeletonView will be shown on these cells, check and re-start loading tasks accordingly.
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		guard !chapterTuples.contains(where: {
			$0.url == placeHolderURL
		}) else {
			loadStageTask?.cancel()
			loadStageTask = nil
			loadStageTask = loadStage()
			// When loadStage() returns successfully, it will reload collectionView's data, loadChapter for each visible cell will be triggered, so we can return if we are here.
			return
		}
		
		// Here means all urls for each chapter is set correctly, check if visible cells has unfinished load tasks
		chaptersCollectionView.indexPathsForVisibleItems.forEach {
			let cell = chaptersCollectionView.dequeueReusableCell(withReuseIdentifier: ChapterCell.identifier, for: $0) as! ChapterCell
			if cell.titleLabel.sk.isSkeletonActive {
				cell.loadChapterTask?.cancel()
				cell.loadChapterTask = nil
				cell.loadChapterTask = loadChapter(forItem: $0.item)
				// When loadChapter() returns successfully, it will reload the cell, which will trigger loadImage()
			} else if cell.imageView.sk.isSkeletonActive {
				cell.loadImageTask?.cancel()
				cell.loadImageTask = nil
				cell.loadImageTask = loadImage(forItem: $0.item)
			}
		}
	}
	
	// MARK: - Custom Functions
	private func loadStage() -> Task<Void, Never> {
		let task = Task.detached { [weak self] in
			// Avoid capturing self in task, so weak self is used. But data task needs a url instead of optional url, so get a strongSelf here and pass it in CourseAPI.getStage(). If when CourseAPI.getStage() returns strongSelf is not available, we should be getting an CancellationError before that, so later use of strongSelf won't cause the app to crash.
			guard let strongSelf = self else { return }
			
			do {
				let randomNumber = Double.random(in: 4...7)
				try await Task.sleep(nanoseconds: UInt64(randomNumber) * 1_000_000_000)
				let stage = try await CourseAPI.getStage(path: strongSelf.stageURL.path)

				try Task.checkCancellation()
				Task { @MainActor in
					strongSelf.chapterTuples = stage.chapterURLs.map { (url: $0, chapter: placeHolderChapter)}
					// When loadStage completes, it will set the array with the right number of tuples, so reload collection view will show the right number of cells.
					strongSelf.chaptersCollectionView.hideSkeleton()
					strongSelf.chaptersCollectionView.reloadData()
					strongSelf.isRefreshing = false
					strongSelf.refreshControl.endRefreshing()
				}
			} catch is CancellationError { return }
			catch {
				Task { @MainActor in
					let cancel = UIAlertAction(title: "取消", style: .cancel)
					let retry = UIAlertAction(title: "重试", style: .default) { action in
						strongSelf.refresh(sender: strongSelf.refreshControl)
					}
					error.present(on: strongSelf, title: "无法载入课程列表", actions: [cancel, retry])
					strongSelf.isRefreshing = false
					strongSelf.refreshControl.endRefreshing()
				}
			}
			// refresh control won't be hid until this function returns
			
		}
		return task
	}
	
	private func loadChapter(forItem index: Int) -> Task<Void, Never>? {
		let url = chapterTuples[index].url

		let task = Task { [weak self] in
			do {
				let randomNumber = Double.random(in: 1...3)
				try await Task.sleep(nanoseconds: UInt64(randomNumber) * 1_000_000_000)
				
				let chapter = try await CourseAPI.getChapter(path: url.path)
				try Task.checkCancellation()
				
				// Store chapter back to array, so next time the cell gets dequeued, we don't need to download it again.
				self?.chapterTuples[index].chapter = chapter
				
				self?.chaptersCollectionView.reloadItems(at: [.init(item: index, section: 0)])
			} catch is CancellationError { return }
			catch {
				print("load chapter error for \(index): \(error)")
#warning("When failing, set image to say '获取信息失败，请尝试下拉刷新'")
			}
		}
		return task
	}
	
	private func loadImage(forItem index: Int) -> Task<Void, Error> {
		let chapter = chapterTuples[index].chapter
		
		let task = Task { [weak self] in
			guard let strongSelf = self else { return }
			let randomNumber = Double.random(in: 1...3)
			try await Task.sleep(nanoseconds: UInt64(4) * 1_000_000_000)
			
			let image = try await UIImage.load(from: chapter.imageURL, size: strongSelf.imageSize)
			try Task.checkCancellation()
			// set the generated image as chapter's image
			self?.chapterTuples[index].chapter.image = image
			
			self?.chaptersCollectionView.reloadItems(at: [.init(item: index, section: 0)])
		}
		return task
	}
	
	@objc private func refresh(sender: UIRefreshControl) {
		// Make sure previous refresh progress has finished, if not we do nothing and bail out directly.
		guard !isRefreshing else { return }
		// Mark a refreshing is in progress, so if user pull down to refresh multiple times, only 1 is ongoing.
		isRefreshing = true
		
		// Cancel loadStageTask and visible cell's loadChapter and loadImage tasks.
		loadStageTask?.cancel()
		loadStageTask = nil
		chaptersCollectionView.visibleCells.map { $0 as! ChapterCell }.forEach {
			$0.loadChapterTask?.cancel()
			$0.loadChapterTask = nil
			$0.loadImageTask?.cancel()
			$0.loadImageTask = nil
		}
		
		// Reset datasource
		chapterTuples = .init(repeating: (url: placeHolderURL, chapter: placeHolderChapter), count: placeHolderNumber)
		// Reload collectionView
		chaptersCollectionView.reloadData()
		// Show skeleton animation on collectionView.
		chaptersCollectionView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .asbestos, secondaryColor: .clouds), animation: skeletonAnimation, transition: .none)

		// Start a loadStage task, which will set the right number of cell for collectionView when successfully returned.
		loadStageTask = loadStage()
	}
}

extension ChaptersVC: SkeletonCollectionViewDataSource, SkeletonCollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
		return ChapterCell.identifier
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return chapterTuples.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChapterCell.identifier, for: indexPath) as! ChapterCell

		cell.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .asbestos, secondaryColor: .clouds), animation: skeletonAnimation, transition: .none)
		//		cell.imageView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .asbestos, secondaryColor: .clouds), animation: skeletonAnimation, transition: .none)
		//		cell.titleLabel.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .asbestos, secondaryColor: .clouds), animation: skeletonAnimation, transition: .none)
		
		guard chapterTuples[indexPath.item].url != placeHolderURL else { return cell }
		
		let chapter = chapterTuples[indexPath.item].chapter
		guard chapter != placeHolderChapter else {
			cell.loadChapterTask = loadChapter(forItem: indexPath.item)
			return cell
		}
		
		cell.titleLabel.stopSkeletonAnimation()
		cell.titleLabel.hideSkeleton(reloadDataAfter: false, transition: .none)
		cell.titleLabel.text = chapter.name
		
		guard let image = chapter.image else {
			cell.loadImageTask = loadImage(forItem: indexPath.item)
			return cell
		}
		cell.imageView.stopSkeletonAnimation()
		cell.imageView.hideSkeleton(reloadDataAfter: false, transition: .none)
		// Add trail string to image if needed.
		cell.imageView.image = (chapter.isFree) ? image.addTrail() : image
		
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 30
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 10
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return cellSize
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		let cell = collectionView.cellForItem(at: indexPath) as! ChapterCell
		return !cell.titleLabel.sk.isSkeletonActive
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let detailVC = ChapterDetailVC()
		detailVC.chapter = chapterTuples[indexPath.item].chapter
		self.navigationController?.pushIfNot(newVC: detailVC)
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
		return false
	}
	
}
