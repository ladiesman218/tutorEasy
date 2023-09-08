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
	private static let publicChapterEndPoint = baseURL.appendingPathComponent("chapter")
	var stageURL: URL!
	var courseName: String!
	var stageName: String!
	// Hold a reference to loadStageTask, so when viewWillDisappear, we can cancel it if it's not finished yet
	private var loadStageTask: Task<Void, Never>?
	
	// Datasource of the collectionView. We will show skeleton animation/failed image/actual data for each cell depending on what's in this array. Initial value of the array is with place holder urls and chapters. When viewWillAppear, loadStage will be called if this array contains at least one placeholder for url item. When each cell is dequeued, loadChapterTask will be set if url is not a placeholder.
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
		failedChapter.image = failedImage
		
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
	
	// Unfinished loadStageTask, all cell's loadChapter and loadImage tasks will be canceled when view disappeared. So when user goes back from a chapter detail vc or accountsVC, skeletonView will be shown on these cells, check and re-start loading tasks accordingly.
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Hiding refresh control is animated so it takes time. If before refresh control is fully hidden, user goes to another VC, then comeback later, collectionView may leave a blank gap(previously held by refresh control) on top, so scroll back.
		if chaptersCollectionView.contentOffset.y < 0 { chaptersCollectionView.scrollToItem(at: .init(item: 0, section: 0), at: .top, animated: true) }
		
		guard !chapterTuples.contains(where: {
			$0.url == placeHolderURL
		}) else {
			loadStageTask = loadStage()
			return
		}
		
		// Here means all urls for each chapter is set correctly, check if available cells has unfinished load tasks
		for index in 0 ... chapterTuples.count - 1 {
			guard let cell = chaptersCollectionView.cellForItem(at: .init(item: index, section: 0)) as? ChapterCell else { continue }
			
			guard chapterTuples[index].chapter != placeHolderChapter else {
				cell.loadChapterTask = loadChapter(forItem: index)
				continue
			}
			if chapterTuples[index].chapter.image == nil {
				cell.loadImageTask = loadImage(forItem: index)
			}
		}
	}
	
	// MARK: - Custom Functions
	private func loadStage() -> Task<Void, Never> {
		
		let task = Task { [weak self] in
			do {
				guard let strongSelf = self else { return }
				let stage = try await CourseAPI.getStage(path: strongSelf.stageURL.path)
				
				self?.chapterTuples = stage.chapterURLs.map { (url: $0, chapter: placeHolderChapter)}
				// When loadStage completes, it will set the array with the right number of tuples, so reload collection view will show the right number of cells, and also will trigger collectionView's cellForItem() delegate method again to set loadChapterTask for each cell.
				self?.chaptersCollectionView.reloadData()
			} catch {
				// If user cancels this task, don't change data source so later it can be re-start if needed. There is no need to call `try Task.checkCancellation()`. Just check for `Task.isCancelled` in catch block is suffice, this is different from `https://www.hackingwithswift.com/quick-start/concurrency/how-to-cancel-a-task`.
				guard !Task.isCancelled else {
					self?.refreshControl.endRefreshing()
					return
				}
				
				// Here means task wasn't cancelled, so replace all placeholder item to failed ones
				self?.chapterTuples = .init(repeating: (failedURL, failedChapter), count: placeHolderNumber)
				self?.chaptersCollectionView.reloadData()
				
				// URLError will be thrown (for example errorCode of -999 means task is cancelled before making network call, other values mean something else, check `https://learn.microsoft.com/en-us/dotnet/api/foundation.nsurlerror?view=xamarin-mac-sdk-14` for full list of errorCode).
				#if DEBUG
				print("\(error.localizedDescription) for loading stage detail \(String(describing: stageName))")
				#endif
			}
			// End refresh so users can refresh again if needed
			self?.refreshControl.endRefreshing()
		}
		return task
	}
	
	private func loadChapter(forItem index: Int) -> Task<Void, Never> {
		let url = chapterTuples[index].url
		let indexPath = IndexPath(item: index, section: 0)
		
		let task = Task { [weak self] in
			do {
				let chapter = try await CourseAPI.getChapter(path: url.path)
				// Store chapter back to array, so next time the cell gets dequeued, we don't need to download it again.
				self?.chapterTuples[index].chapter = chapter
				// When cell is reloaded and image in datasource is still nil, loadImage() should be triggered.
				self?.chaptersCollectionView.reloadItems(at: [indexPath])
			} catch {
				guard !Task.isCancelled else { return }
				// This failed place holder should be different than the default one, so when scrolling to trigger new cells to be created, it won't trigger load tasks to be re-started again, that way all sorts of wierd bugs will emerge.
				self?.chapterTuples[index].chapter = failedChapter
				self?.chaptersCollectionView.reloadItems(at: [indexPath])
				#if DEBUG
				print("\(error.localizedDescription) for chapter \(index)")
				#endif
			}
		}
		return task
	}
	
	private func loadImage(forItem index: Int) -> Task<Void, Never> {
		let chapter = chapterTuples[index].chapter
		
		let task = Task { [weak self] in
			guard let strongSelf = self else { return }
			// UIImage.load() will generate a image from given color if failed to retrieve data from server, or return nil if task is cancelled so it could be started later again when needed.
			guard var image = await FileAPI.publicGetImageData(url: chapter.imageURL, size: strongSelf.imageSize) else {
				return
			}
			image = (chapter.isFree) ? image.addTrail() : image
			// Set the generated image back into data source so next time cell is reused, no need to download again
			self?.chapterTuples[index].chapter.image = image
			self?.chaptersCollectionView.reloadItems(at: [.init(item: index, section: 0)])
		}
		return task
	}
	
	private func cancelAllTasks() {
		loadStageTask?.cancel()
		loadStageTask = nil
		// If all chapter folder's name were wrong/don't meets the naming requirements, chapterTuples.count chould be 0
		guard chapterTuples.count - 1 > 0 else { return }
		// When refreshing, use cellForItem() only gets the first 8 cells but more are possibly in memory.
		for case let cell as ChapterCell in (0 ... chapterTuples.count - 1).map({
			chaptersCollectionView.dequeueReusableCell(withReuseIdentifier: ChapterCell.identifier, for: .init(item: $0, section: 0))
		}) {
			#warning("Still has bug, doesn't cancel tasks for all available cells")
			cell.prepareForReuse()
		}
	}
	
	@objc private func refresh(sender: UIRefreshControl) {
		cancelAllTasks()
		
		// Resetting datasource and reload collectionView will give us new cells, hence new tasks
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
	
	// cellForItemAt() will be called at a wierd time. For example, adding break point on condition of indexPath.itme == 15, it will be paused when collectionView is scrolled to the top and the bottom, both situation the 16th cell is off screen(turn off collectionView's bounce won't solve the issue).
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChapterCell.identifier, for: indexPath) as! ChapterCell
		
		guard chapterTuples[indexPath.item].url != placeHolderURL else { return cell }
		
		guard chapterTuples[indexPath.item].chapter != placeHolderChapter else {
			cell.loadChapterTask = loadChapter(forItem: indexPath.item)
			return cell
		}
		cell.titleLabel.text = chapterTuples[indexPath.item].chapter.name
		
		// When loadChapterTask succeed, it will reload cell so loadImageTask will begin, but in case during image downloading, user has scrolled away or go to another vc, downloading task might be cancelled. So when cell is re-created, start downloading again if needed.
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
		let chapter = chapterTuples[indexPath.item].chapter
		// Loading and failed chapter shouldn't be selected
		return chapter != placeHolderChapter &&
		chapter != failedChapter
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
