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
	
	private var chaptersCollectionView: UICollectionView = {
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
	
	// MARK: - Controller functions
	override func viewDidLoad() {
		super.viewDidLoad()
		loadStage()
		
		view.backgroundColor = UIColor.systemBackground
		topView = configTopView()
		
		iconView.layer.backgroundColor = UIColor.clear.cgColor
		topView.addSubview(iconView)
		
		backButtonView = setUpGoBackButton(in: topView)
		
		courseTitle.font = courseTitle.font.withSize(topViewHeight / 2)
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
			topView.heightAnchor.constraint(equalToConstant: topViewHeight),
			
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
	
	func loadStage() {
		Task {
			do {
				self.chapters = try await CourseAPI.getStage(path: stageURL.path).chapters
			} catch {
				let goBack = UIAlertAction(title: "返回", style: .cancel) { [unowned self] _ in
					self.navigationController?.popViewController(animated: true)
				}
				error.present(on: self, title: "无法获取小节列表", actions: [goBack])
			}
		}
	}
	
}

extension ChaptersVC: SkeletonCollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
		return ChapterCell.identifier
	}
	
	func collectionSkeletonView(_ skeletonView: UICollectionView, prepareCellForSkeleton cell: UICollectionViewCell, at indexPath: IndexPath) {
		
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return chapters.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChapterCell.identifier, for: indexPath) as! ChapterCell
		cell.chapter = chapters[indexPath.item]
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
		return .init(width: width, height: width)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let chapterDetailVC = ChapterDetailVC()
		let chapter = chapters[indexPath.item]
		chapterDetailVC.chapter = chapter
		navigationController?.pushIfNot(newVC: chapterDetailVC)
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		if let cell = collectionView.cellForItem(at: indexPath) as? ChapterCell {
			return !cell.imageView.sk.isSkeletonActive
		}
		return false
	}
}
