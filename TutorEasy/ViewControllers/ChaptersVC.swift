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
	private var loadStageTask: Task<Void, Error>?
	// Init value of the array is with place holder urls and chapters. When loadStage() returns, it's gonna replace urls with actual directory urls of the chapters. This way when total number of chapters for a stage is changed, users can pull to refresh to get the right number(comparing to set urls when initializing this vc, users will have to go back to previous VC and refresh stage info). Then when each cell is about to be scrolled onto screen, loadChapter will be called for each cell, which get the actual chapter for the given index, and store the chapter back to this array, so next time the cell is scrolled back to be displayed, we don't need to download the chapter again
	private var chapterTuples: [(url: URL, chapter: Chapter)] = .init(repeating: (url: placeHolderURL, chapter: placeHolderChapter), count: placeHolderNumber)
	
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
		
		return chaptersCollectionView
	}()
	
	private let refreshControl = UIRefreshControl()
	
	// MARK: - Controller functions
	override func viewDidLoad() {
		super.viewDidLoad()
		
		loadStage()
		
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
	
	// MARK: - Custom Functions
	private func loadStage() {
		loadStageTask = Task { [weak self] in
			guard let strongSelf = self else { return }
			let stage = try await CourseAPI.getStage(path: strongSelf.stageURL.path)
			try Task.checkCancellation()
			self?.chapterTuples = stage.chapterURLs.map { (url: $0, chapter: placeHolderChapter)}
			// When loadStage completes, it will set the array with the right number of tuples, so reload collection view will show the right number of cells.
			self?.chaptersCollectionView.reloadData()
		}
	}
	
	private func loadChapter(forItem index: Int) -> Task<Void, Error>? {
		let url = chapterTuples[index].url
		let task = Task {
			let chapter = try await CourseAPI.getChapter(path: url.path)
			try Task.checkCancellation()
			
			// Store chapter back to array, so next time the cell gets dequeued, we don't need to download it again.
			chapterTuples[index].chapter = chapter
			
			//If cell is still on screen, reload given cell, which will display the chapter's name first, cos image downloading may take a while.
			guard !chaptersCollectionView.indexPathsForVisibleItems.contains(where: {
				$0.item == index
			}) else {
				chaptersCollectionView.reloadItems(at: [.init(item: index, section: 0)])
				return
			}
		}
		return task
	}
	
	private func loadImage(forItem index: Int) -> Task<Void, Error> {
		let width = chaptersCollectionView.bounds.width / 4.2
		let size = CGSize(width: width, height: width)
		let chapter = chapterTuples[index].chapter
		
		let task = Task {
			let image = try await UIImage.load(from: chapter.imageURL, size: size)
			try Task.checkCancellation()
			// set the generated image as chapter's image
			chapterTuples[index].chapter.image = image
			
			//If cell is still on screen, reload given cell, which will display the downloaded image.
			guard !chaptersCollectionView.indexPathsForVisibleItems.contains(where: {
				$0.item == index
			}) else {
				chaptersCollectionView.reloadItems(at: [.init(item: index, section: 0)])
				return
			}
		}
		return task
	}
	
	@objc private func refresh(sender: UIRefreshControl) {
		loadStageTask?.cancel()
		loadStageTask = nil
		chaptersCollectionView.visibleCells.map { $0 as! ChapterCell }.forEach {
			$0.loadChapterTask?.cancel()
			$0.loadChapterTask = nil
			$0.loadImageTask?.cancel()
			$0.loadImageTask = nil
		}
		
		chapterTuples = .init(repeating: (url: placeHolderURL, chapter: placeHolderChapter), count: placeHolderNumber)
		chaptersCollectionView.reloadData()
		refreshControl.endRefreshing()
		loadStage()
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
		
		// titleLabel's text is nil by default, display skeletonView for that. If the corresponding chapter in chapterTuples is not a place holder, which means the real chapter info has been downloaded, set titleLable's text to chapter's name and hide skeletonView.
		if chapterTuples[indexPath.item].chapter != placeHolderChapter {
			cell.titleLabel.stopSkeletonAnimation()
			cell.titleLabel.hideSkeleton(reloadDataAfter: false, transition: .none)
			cell.titleLabel.text = chapterTuples[indexPath.item].chapter.name
		} else {
			cell.titleLabel.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .asbestos, secondaryColor: .clouds), animation: skeletonAnimation, transition: .none)
		}
		
		// Do the same thing for imageView.
		if let image = chapterTuples[indexPath.item].chapter.image {
			cell.imageView.stopSkeletonAnimation()
			cell.imageView.hideSkeleton(reloadDataAfter: false, transition: .none)
			// Add trail string to image if needed.
			cell.imageView.image = (chapterTuples[indexPath.item].chapter.isFree) ? image.addTrail() : image
		} else {
			cell.imageView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .asbestos, secondaryColor: .clouds), animation: skeletonAnimation, transition: .none)
		}
		
		return cell
	}
	
	// When a cell is about to be displayed, check datasource to see if loading tasks should be started.
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		// If url for the given indexPath is a place holder, bail out.
		guard chapterTuples[indexPath.item].url != placeHolderURL else { return }
		// Here means we got a real url for a chapter.
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChapterCell.identifier, for: indexPath) as! ChapterCell
		
		// Make sure chapter info is not loaded
		guard chapterTuples[indexPath.item].chapter == placeHolderChapter else {
			// Here means chapter is already downloaded
			guard chapterTuples[indexPath.item].chapter.image != nil else {
				// Here means image has not been downloaded.
				cell.loadImageTask = loadImage(forItem: indexPath.item)
				return
			}
			// Here means both chapter and image have been downloaded, we can bailout.
			return
		}
		// Start load info for chapter
		cell.loadChapterTask = loadChapter(forItem: indexPath.item)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 30
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 10
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let totalWidth = collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right)
		let width = totalWidth / 4 - 15 // Accounts for the item spacing, also add extra 5 to allow shadow to be fully displayed.
		return .init(width: width, height: width * 1.3)
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		let cell = collectionView.cellForItem(at: indexPath) as! ChapterCell
		return !cell.titleLabel.sk.isSkeletonActive
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		print(indexPath.item)
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
		return false
	}
	
}
