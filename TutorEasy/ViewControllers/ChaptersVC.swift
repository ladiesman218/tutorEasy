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
	var loadStageTask: Task<Void, Error>?
	// Init value of the array is with place holder urls and chapters. When loadStage() returns, it's gonna replace urls with actual directory urls of the chapters, then when each cell is about to be scrolled into screen, loadChapter will be called, which get the actual chapter for the given index, and store the chapter back to this array, so next time the cell is scrolled back to be displayed, we don't need to download the chapter again
	var chapterTuples: [(url: URL, chapter: Chapter)] = .init(repeating: (url: placeHolderURL, chapter: placeHolderChapter), count: placeHolderNumber)
	
	// MARK: - Custom subviews
	private var topView: UIView!
	private var iconView: ProfileIconView = .init(frame: .zero)
	private var backButtonView: UIView!
	
	private var courseTitle: PaddingLabel = {
		let courseTitle = PaddingLabel()
		courseTitle.translatesAutoresizingMaskIntoConstraints = false
		courseTitle.textColor = .white
		courseTitle.layer.backgroundColor = UIColor.systemYellow.cgColor
		
		return courseTitle
	}()
	
	private var stageTitle: PaddingLabel = {
		let stageTitle = PaddingLabel()
		stageTitle.translatesAutoresizingMaskIntoConstraints = false
		stageTitle.textColor = .white
		stageTitle.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
		stageTitle.layer.backgroundColor = UIColor.systemTeal.cgColor
		return stageTitle
	}()
#warning("添加双师堂按钮")
	private var chaptersCollectionView: UICollectionView = {
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
	var refreshControl = UIRefreshControl()
	
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
	}
	
	func loadStage() {
		loadStageTask = Task { [weak self] in
			try await Task.sleep(nanoseconds: 3_000_000_000)

			let stage = try await CourseAPI.getStage(path: self!.stageURL.path)
			try Task.checkCancellation()
			self?.chapterTuples = stage.chapterURLs.map { (url: $0, chapter: placeHolderChapter)}
			// When loadStage completes, it will set the array with the right number of tuples, so reload collection view will show the right number of cells.
			self?.chaptersCollectionView.reloadData()
		}
	}
	
	func loadChapter(forItem index: Int) async throws {
		let url = chapterTuples[index].url
		guard url != placeHolderURL else { return }
		
		if chapterTuples[index].chapter == placeHolderChapter {
			// Load chapter
			try await Task.sleep(nanoseconds: 3_000_000_000)

			let chapter = try await CourseAPI.getChapter(path: url.path)
			try Task.checkCancellation()
			
			// Store chapter back to array, so next time the cell gets dequeued, we don't need to download it again.
			chapterTuples[index].chapter = chapter
			// Reload given cell, which will display the chapter's name first, cos image downloading may take a while, but make sure the cell is still on screen first, otherwise titleLabel's text may not be displayed.
			if chaptersCollectionView.indexPathsForVisibleItems.contains(where: { indexPath in
				indexPath.item == index
			}) {
				chaptersCollectionView.reloadItems(at: [.init(item: index, section: 0)])
			}
		}
		
		if chapterTuples[index].chapter.image == nil {
			// Load image

			let width = CGFloat(200)
			let size = CGSize(width: width, height: width)
			let chapter = chapterTuples[index].chapter
			let image = try await UIImage.load(from: chapter.imageURL, size: size)
			try Task.checkCancellation()
			// set the generated image as chapter's image
			chapterTuples[index].chapter.image = image
			if chaptersCollectionView.indexPathsForVisibleItems.contains(where: { indexPath in
				indexPath.item == index
			}) {
				chaptersCollectionView.reloadItems(at: [.init(item: index, section: 0)])
			}
		}
	}
	
	@objc func refresh(sender: UIRefreshControl) {
		print(sender.state.rawValue)
		chapterTuples = .init(repeating: (url: placeHolderURL, chapter: placeHolderChapter), count: placeHolderNumber)
		chaptersCollectionView.reloadData()
		refreshControl.endRefreshing()
		loadStageTask?.cancel()
		loadStageTask = nil
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
		
		cell.imageView.image = chapterTuples[indexPath.item].chapter.image
		if chapterTuples[indexPath.item].chapter.name != placeHolderChapter.name {
			cell.titleLabel.text = chapterTuples[indexPath.item].chapter.name
		}
		
		return cell
	}
	
	// When a cell is about to be displayed, start the load chapter task
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChapterCell.identifier, for: indexPath) as! ChapterCell
		
		cell.loadTask = Task {
			try await self.loadChapter(forItem: indexPath.item)
		}
	}
	
	// Cancel load chapter task when cell is about to be scrolled off the screen, this is also essential for titleLabel's text to be displayed properly.
	func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChapterCell.identifier, for: indexPath) as! ChapterCell
		cell.loadTask?.cancel()
		cell.loadTask = nil
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
