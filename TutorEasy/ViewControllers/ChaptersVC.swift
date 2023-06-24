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
	var loadStageTask: Task<Void, Error>?
	
	private var chapters: [Chapter] = .init(repeating: chapterPlaceHolder, count: placeholderForNumberOfCells) {
		didSet {
			chaptersCollectionView.reloadData()
		}
	}
	
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
	
	// MARK: - Controller functions
	override func viewDidLoad() {
		super.viewDidLoad()
		
//		loadStage()
		
		chaptersCollectionView.frame = view.frame
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
	
	// This ViewController is pushed into nav stack, without this, there will be only 1 skeleton cell displayed for collectionView, a wierd bug. Even though chapterURLs' property observer won't be triggered, it should still have 20 placeholder urls in it in the 1st place, enough for collectionView to dequeue
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		chaptersCollectionView.reloadData()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		loadStageTask?.cancel()
		loadStageTask = nil
	}
	
	func loadStage() {
		// Assigning a value to a task starts it automatically
		loadStageTask = Task {
			do {
				let chapters = try await CourseAPI.getStage(path: stageURL.path).chapters
				try Task.checkCancellation()
				
				self.chapters = chapters.map { .init(directoryURL: $0.directoryURL, name: $0.name, isFree: $0.isFree, pdfURL: $0.pdfURL, bInstructionURL: $0.bInstructionURL, teachingPlanURL: $0.teachingPlanURL, imageURL: $0.imageURL) }
			} catch {
				if error is CancellationError { return }
				error.present(on: self, title: "无法获取章节列表", actions: [])
			}
		}
	}
}

extension ChaptersVC: SkeletonCollectionViewDataSource, SkeletonCollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
		return ChapterCell.identifier
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return chapters.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChapterCell.identifier, for: indexPath) as! ChapterCell
		let chapter = chapters[indexPath.item]
		
		cell.titleLabel.text = chapter.name
		guard cell.titleLabel.text != chapterPlaceHolder.name else { cell.titleLabel.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .yellow, secondaryColor: .orange), animation: skeletonAnimation, transition: .none)
			return cell
		}

		cell.titleLabel.stopSkeletonAnimation()
		cell.titleLabel.hideSkeleton(reloadDataAfter: true, transition: .none)
		print("title set to \(cell.titleLabel.text)")

		
		guard chapter.image == nil else {
			cell.imageView.image = chapter.image
			// Why do we need to stop and hide skeletonView here?
			cell.imageView.stopSkeletonAnimation()
			cell.imageView.hideSkeleton(reloadDataAfter: true, transition: .none)
			return cell
		}
		
		// Public chapter image downloading has to be called here, since when download succeed, we need to modify data source(chapters array), can't do that inside ChapterCell.
		cell.imageView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .lightGray, secondaryColor: .darkGray), animation: skeletonAnimation, transition: .none)
		
		guard let imageURL = chapter.imageURL else {
			// Generate image from a UIColor
			// Set imageView's image
			// Store that image for the chapter in original chapter data source.
			// Stop SkeletonView's animation
			return cell
		}
		
		let req = FileAPI.convertToImageRequest(url: imageURL)
		let size = CGSize(width: cell.bounds.size.width, height: cell.bounds.size.width)

		cell.imageTask = Task {
			let image = try await FileAPI.publicGetImageData(request: req, size: size)
			try Task.checkCancellation()
			print("image downloaded for indexPath: \(indexPath.item)")
			// Store image in chapters, so next time the cell gets scrolled back into collectionView, no need to download it again
			chapters[indexPath.item].image = image
			
			cell.imageView.image = image
			cell.imageView.stopSkeletonAnimation()
			cell.imageView.hideSkeleton(reloadDataAfter: true, transition: .none)
		}
		
		return cell
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
}
