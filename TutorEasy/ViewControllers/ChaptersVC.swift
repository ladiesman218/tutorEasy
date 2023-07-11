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
		refreshControl.tintColor = .systemYellow
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
		cancelAllTasks()
	}
	
	// Unfinished loadStageTask, visible cell's loadChapter and loadImage tasks will be canceled when view disappeared. So when user goes back from a chapter detail vc or accountsVC, skeletonView will be shown on these cells, check and re-start loading tasks accordingly.
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		guard !chapterTuples.contains(where: {
			$0.url == placeHolderURL
		}) else {
			cancelAllTasks()
			loadStageTask = loadStage()
			return
		}
		
		// Here means all urls for each chapter is set correctly, check if visible cells has unfinished load tasks
		for indexPath in chaptersCollectionView.indexPathsForVisibleItems {
			guard let cell = chaptersCollectionView.cellForItem(at: indexPath) as? ChapterCell else { continue }

			let chapter = chapterTuples[indexPath.item].chapter
			guard chapter != placeHolderChapter else {
				cell.loadChapterTask = loadChapter(forItem: indexPath.item)
				continue
			}
			if chapter.image == nil {
				cell.loadImageTask = loadImage(forItem: indexPath.item)
			}
		}
	}
	
	// MARK: - Custom Functions
	private func loadStage() -> Task<Void, Never> {
		let task = Task { [weak self] in
			
			do {
//				let randomNumber = Double.random(in: 4...7)
//				try await Task.sleep(nanoseconds: UInt64(randomNumber) * 1_000_000_000)
				
				guard let strongSelf = self else { return }
				let stage = try await CourseAPI.getStage(path: strongSelf.stageURL.path)
				try Task.checkCancellation()
				
				self?.chapterTuples = stage.chapterURLs.map { (url: $0, chapter: placeHolderChapter)}
				// When loadStage completes, it will set the array with the right number of tuples, so reload collection view will show the right number of cells.
				self?.chaptersCollectionView.reloadData()
			} catch is CancellationError { return }
			catch {
				guard let strongSelf = self else { return }

				let cancel = UIAlertAction(title: "取消", style: .cancel)
				let retry = UIAlertAction(title: "重试", style: .default) { action in
					strongSelf.refresh(sender: strongSelf.refreshControl)
				}
				error.present(on: strongSelf, title: "无法载入课程列表", actions: [cancel, retry])
			}
			// Discard task reference, so user can refresh if needed.
			self?.loadStageTask = nil
			// Hide refreshControl
			self?.refreshControl.endRefreshing()
		}
		return task
	}
	
	private func loadChapter(forItem index: Int) -> Task<Void, Never>? {
		let url = chapterTuples[index].url
		
		let task = Task { [weak self] in
			do {
//				let randomNumber = Double.random(in: 1...3)
//				try await Task.sleep(nanoseconds: UInt64(randomNumber) * 1_000_000_000)
				
				let chapter = try await CourseAPI.getChapter(path: url.path)
				try Task.checkCancellation()
				
				// Store chapter back to array, so next time the cell gets dequeued, we don't need to download it again.
				self?.chapterTuples[index].chapter = chapter
				
				if let cell = self?.chaptersCollectionView.cellForItem(at: .init(item: index, section: 0)) as? ChapterCell {
					cell.titleLabel.text = chapter.name
					cell.setNeedsLayout()
					cell.loadImageTask = self?.loadImage(forItem: index)
				}
			} catch is CancellationError { return }
			catch {
				print("load chapter error for \(index): \(error)")
				if let cell = self?.chaptersCollectionView.cellForItem(at: .init(item: index, section: 0)) as? ChapterCell {
					let image = UIImage(named: "load-failed.png")!
					cell.imageView.image = image
					// To hide skeletonView for titleLabel
					cell.titleLabel.text = "   "
					cell.setNeedsLayout()
				}
			}
		}
		return task
	}
	
	private func loadImage(forItem index: Int) -> Task<Void, Error> {
		let chapter = chapterTuples[index].chapter

		let task = Task { [weak self] in
			guard let strongSelf = self else { return }
//			let randomNumber = Double.random(in: 1...3)
//			try await Task.sleep(nanoseconds: UInt64(randomNumber) * 1_000_000_000)
			
			var image = try await UIImage.load(from: chapter.imageURL, size: strongSelf.imageSize)
			try Task.checkCancellation()
			image = (chapter.isFree) ? image.addTrail() : image
			// set the generated image as chapter's image
			self?.chapterTuples[index].chapter.image = image
			if let cell = self?.chaptersCollectionView.cellForItem(at: .init(item: index, section: 0)) as? ChapterCell {
				cell.imageView.image = image
				cell.setNeedsLayout()
			}
		}
		return task
	}
	
	private func cancelAllTasks() {
		loadStageTask?.cancel()
		loadStageTask = nil
		// Somehow, use cellForItem(at:) will miss out some cells
		for case let cell as ChapterCell in (0 ... chapterTuples.count - 1).map({
			chaptersCollectionView.dequeueReusableCell(withReuseIdentifier: ChapterCell.identifier, for: .init(item: $0, section: 0))
		}) {
			cell.prepareForReuse()
		}
	}
	
	@objc private func refresh(sender: UIRefreshControl) {
		// Make sure previous refresh progress has finished
		guard loadStageTask == nil else { return }
		
		cancelAllTasks()
		
		// Reset datasource
		chapterTuples = .init(repeating: (url: placeHolderURL, chapter: placeHolderChapter), count: placeHolderNumber)
		// Reload collectionView to show skeleton animation for cells
		chaptersCollectionView.reloadData()
		
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
		
		guard chapterTuples[indexPath.item].url != placeHolderURL else { return cell }
		
		guard chapterTuples[indexPath.item].chapter != placeHolderChapter else {
			cell.loadChapterTask = loadChapter(forItem: indexPath.item)
			return cell
		}
		cell.titleLabel.text = chapterTuples[indexPath.item].chapter.name
		
		// When loadChapterTask succeed, it will set loadImageTask, but in case during image downloading, user has scrolled away then back to the cell, downloading task might be cancelled.
		guard chapterTuples[indexPath.item].chapter.image != nil else {
			cell.loadImageTask = loadImage(forItem: indexPath.item)
			return cell
		}
		cell.imageView.image = chapterTuples[indexPath.item].chapter.image
		
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
