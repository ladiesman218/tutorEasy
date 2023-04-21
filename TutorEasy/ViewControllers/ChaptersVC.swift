//
//  ChaptersVC.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/3/31.
//

import UIKit

class ChaptersVC: UIViewController {
	// MARK: - Properties
	var stageURL: URL!
	var courseName: String!
	var stageName: String!
	
	private var chapters: [Chapter] = .init(repeating: chapterPlaceHolder, count: placeholderForNumberOfCells) {
		didSet {
//			Task {
//				let urls = chapters.map { $0.imageURL }
//				chapterImages = await downloadImages(urls: urls)
//			}
		}
	}
	
	private var chapterImages: [UIImage?] = .init(repeating: nil, count: placeholderForNumberOfCells)
//	{
//		didSet { loaded = true }
//	}
	
//	private var loaded = false {
//		didSet { chaptersCollectionView.reloadData() }
//	}
	
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
		chaptersCollectionView.register(SkeletonCollectionCell.self, forCellWithReuseIdentifier: SkeletonCollectionCell.identifier)
//		chaptersCollectionView.register(ChapterCell.self, forCellWithReuseIdentifier: ChapterCell.identifier)
//		chaptersCollectionView.contentInset = .init(top: 30, left: 30, bottom: 30, right: 30)
//		chaptersCollectionView.layer.cornerRadius = 20
//		chaptersCollectionView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
//		chaptersCollectionView.backgroundColor = .systemGray5
		return chaptersCollectionView
	}()
	
	// MARK: - Controller functions
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		chaptersCollectionView.alpha = 1
	}
	override func viewDidLoad() {
        super.viewDidLoad()
//		loadStage()
        
		view.backgroundColor = backgroundColor
		topView = configTopView(bgColor: UIColor.clear)
		
		iconView.layer.backgroundColor = UIColor.clear.cgColor
		let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.profileIconClicked))
		iconView.addGestureRecognizer(tap)
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
			let result = await CourseAPI.getStage(path: stageURL.path)
			switch result {
				case .success(let stage):
					self.chapters = stage.chapters
				case .failure(let error):
					let goBack = UIAlertAction(title: "返回", style: .cancel) { [unowned self] _ in
						self.navigationController?.popViewController(animated: true)
					}
					error.present(on: self, title: "无法获取小节列表", actions: [goBack])
			}
		}
	}
}

extension ChaptersVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return chapters.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		#warning("不显示SkeletonCollectionCell, 切换dark light theme会显示")
// 能正确dequeue到SkeletonCollectionCell，加了imageView背景色能看到。不加背景色cell就不显示，也没动画。如果把该vc做成第一个dequeue SkeletonCollectionCell的，也不显示动画，所以不是动画需要结束问题

//		if !loaded {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SkeletonCollectionCell.identifier, for: indexPath) as! SkeletonCollectionCell
		
//		print(cell.layer.animationKeys())
			return cell
//		} else {
//			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChapterCell.identifier, for: indexPath) as! ChapterCell
//			cell.imageView.image = chapterImages[indexPath.item]
//			if chapters[indexPath.item].isFree {
//				cell.imageView.drawTrail()
//			}
//			return cell
//		}
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
	
}
