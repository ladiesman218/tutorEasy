//
//  CourseDetailVC.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/30.
//

import UIKit

class CourseDetailVC: UIViewController {

	// MARK: - Properties
	var courseID: UUID!
	static let stageTableCellIdentifier = "stageTableCellIdentifier"
	
	private var course = coursePlaceHolder {
		didSet {
			courseTitle.text = course.name
			descriptionLabel.text = course.description
			if let imageURL = course.imageURL {
				imageView.downloaded(from: imageURL.path, contentMode: .scaleAspectFill)
			}
//			Task {
//				chapterImages = await loadChapterImages()
//			}
		}
	}
	// chapters are already sorted by name(ascending order) when returning from server

	private var chapterImages: [UIImage?] = .init(repeating: nil, count: placeholderForNumberOfCells) {
		didSet {
			chapterCollectionView.reloadData()
		}
	}

	private var stages: [Stage] = .init(repeating: stagePlaceHolder, count: 4) {
		didSet {
			
		}
	}
//	private var chapters: [Chapter] = .init(repeating: chapterPlaceHolder, count: placeholderForNumberOfCells) {
//		didSet {
//			chapterCollectionView.reloadData()
//		}
//	}

//	var chapterImages: [String: UIImage?] = [:]
	//	var course: Course! {
	//		didSet {
	//			//			for (index, chapter) in course.chapters.enumerated() {
	//			//				if let imagePath = chapter.imagePath {
	//			//
	//			//					FileAPI.getFile(path: imagePath) { [unowned self] data, response, error in
	//			//						if let data = data {
	//			//							#warning("bug while go in this vc, then go back before the images are loaded, then go back again later, with following error message:")
	//			//							// Fatal error: Attempted to read an unowned reference but the object was already deallocatedFatal error: Attempted to read an unowned reference but the object was already deallocated
	//			//							let image = UIImage(data: data)!
	//			//							self.chapterCellImages[index] = image
	//			//						}
	//			//					}
	//			//				}
	//			//			}
	//		}
	//	}

	// MARK: - Custom subviews
	private var topView: UIView!
	private var iconView: ProfileIconView = .init(frame: .zero)
	private var backButtonView: UIView!
	private let courseNavView: UIView = {
		let courseNavView = UIView()
		courseNavView.translatesAutoresizingMaskIntoConstraints = false
		// Set a corner-like edge on the right side of the background
		courseNavView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
		courseNavView.layer.cornerCurve = .circular
		// We are using backed layer to draw a round radius corner, simply set label's background color will render all previous configurations obsolete since view's background color comes on top of layer. So use layer's backgroundColor here. 
		courseNavView.layer.backgroundColor = UIColor.systemYellow.cgColor
		courseNavView.layer.zPosition = .greatestFiniteMagnitude

		return courseNavView
	}()

	private var courseTitle: UILabel = {
		let courseTitle = UILabel()
		courseTitle.translatesAutoresizingMaskIntoConstraints = false
		courseTitle.textColor = .white
		return courseTitle
	}()

	private var stageNavView: UIView = {
		let stageNavView = UIView()
		stageNavView.translatesAutoresizingMaskIntoConstraints = false
		// Set a corner-like edge on the right side of the background
		stageNavView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
		stageNavView.layer.cornerCurve = .circular
		// We are using backed layer to draw a round radius corner, simply set label's background color will render all previous configurations obsolete since view's background color comes on top of layer. So use layer's backgroundColor here.
		stageNavView.layer.backgroundColor = UIColor.systemOrange.cgColor
		return stageNavView
	}()

	private var stageTitle: UILabel = {
		let stageTitle = UILabel()
		stageTitle.translatesAutoresizingMaskIntoConstraints = false
		stageTitle.textColor = .white
		return stageTitle
	}()

	private var themeView: UIView = {
		let themeView = UIView()
		themeView.translatesAutoresizingMaskIntoConstraints = false
		themeView.layer.backgroundColor = UIColor.systemGray5.cgColor
		return themeView
	}()

	// This is the image added to themeView, on top side.
	private var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		//		if let imagePath = course.imagePath {
		//			imageView.downloaded(from: imagePath, contentMode: .scaleAspectFill)
		//		}
		imageView.clipsToBounds = true
		return imageView
	}()

	private var themeLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.boldSystemFont(ofSize: 9)

		label.text = "主题简介"
		return label
	}()

	private var descriptionLabel: UILabel = {
		let descriptionLabel = UILabel()
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionLabel.numberOfLines = 0
		descriptionLabel.lineBreakMode = .byTruncatingTail
		return descriptionLabel
	}()
	
	private var stageTableView: UITableView {
		let stageTableView = UITableView()
		stageTableView.translatesAutoresizingMaskIntoConstraints = false
		stageTableView.dataSource = self
		stageTableView.delegate = self
		
		stageTableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.stageTableCellIdentifier)
		return stageTableView
	}

	private var chapterCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.contentInset = .init(top: 30, left: 20, bottom: 30, right: 20)
		collectionView.layer.cornerRadius = 20
		collectionView.register(ChapterCell.self, forCellWithReuseIdentifier: ChapterCell.identifier)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.layer.backgroundColor = UIColor.systemGray5.cgColor
		collectionView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
		collectionView.bounces = false

		return collectionView
	}()

	// MARK: - Controller functions
	override func viewDidLoad() {
		super.viewDidLoad()
		getCourse(id: courseID)
		// downloaded() function for imageView is asynchronous, it's gonna cause problem in collection view: when scrolling, images got misplaced. The solution we took is, create an array with optional images, set its initial value to nil and repeating as many times as chapters for the course. When course is set, get the image for each chapter, if one is found, replace the original nil value with the UIImage just found. This is done in the property observer of chapters.

//		chapterCollectionView.dataSource = self
//		chapterCollectionView.delegate = self
		view.addSubview(chapterCollectionView)

		view.backgroundColor = .systemGray4
		topView = configTopView(bgColor: UIColor.systemGray6)

		iconView.layer.backgroundColor = UIColor.clear.cgColor
		let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.profileIconClicked))
		iconView.addGestureRecognizer(tap)
		topView.addSubview(iconView)

		courseNavView.layer.cornerRadius = topViewHeight * 0.3
		backButtonView = setUpGoBackButton(in: courseNavView)
		topView.addSubview(courseNavView)

//		languageTitle.text = languageName
		courseTitle.font = courseTitle.font.withSize(topViewHeight / 2)
		courseNavView.addSubview(courseTitle)

		stageNavView.layer.cornerRadius = topViewHeight * 0.3
		topView.addSubview(stageNavView)

		stageTitle.font = courseTitle.font.withSize(topViewHeight / 2)
		stageNavView.addSubview(stageTitle)

		themeView.layer.cornerRadius = view.frame.width * 0.04
		view.addSubview(themeView)

		themeLabel.font = themeLabel.font.withSize(topViewHeight / 3)
		themeView.addSubview(themeLabel)

		descriptionLabel.font = descriptionLabel.font.withSize(topViewHeight / 3.5)
		themeView.addSubview(descriptionLabel)

		imageView.layer.cornerRadius = view.frame.width * 0.04 * 0.7
		themeView.addSubview(imageView)
		
		view.addSubview(stageTableView)

		NSLayoutConstraint.activate([
			courseTitle.leadingAnchor.constraint(equalTo: backButtonView.trailingAnchor, constant: topViewHeight * 0.7),
			courseTitle.trailingAnchor.constraint(equalTo: courseNavView.trailingAnchor, constant: -topViewHeight),
			courseTitle.topAnchor.constraint(equalTo: courseNavView.topAnchor),
			courseTitle.bottomAnchor.constraint(equalTo: courseNavView.bottomAnchor),

			courseNavView.leadingAnchor.constraint(equalTo: topView.leadingAnchor),
			courseNavView.topAnchor.constraint(equalTo: topView.topAnchor),
			courseNavView.bottomAnchor.constraint(equalTo: topView.bottomAnchor),

			stageTitle.leadingAnchor.constraint(equalTo: stageNavView.leadingAnchor, constant: topViewHeight * 0.7),
			stageTitle.trailingAnchor.constraint(equalTo: stageNavView.trailingAnchor, constant: -topViewHeight * 0.7),
			stageTitle.topAnchor.constraint(equalTo: stageNavView.topAnchor),
			stageTitle.bottomAnchor.constraint(equalTo: stageNavView.bottomAnchor),

			stageNavView.leadingAnchor.constraint(equalTo: courseNavView.trailingAnchor, constant: -topViewHeight * 0.3),
			stageNavView.topAnchor.constraint(equalTo: topView.topAnchor),
			stageNavView.bottomAnchor.constraint(equalTo: topView.bottomAnchor),

			iconView.trailingAnchor.constraint(equalTo: topView.trailingAnchor),
			iconView.topAnchor.constraint(equalTo: topView.topAnchor),
			iconView.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
			iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor),

			themeView.leadingAnchor.constraint(equalTo: stageTableView.trailingAnchor, constant: view.frame.width * 0.01),
			themeView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -view.frame.width * 0.01),
			themeView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: view.frame.width * 0.01),
			themeView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),

			imageView.leadingAnchor.constraint(equalTo: themeView.leadingAnchor, constant: view.frame.width * 0.02),
			imageView.topAnchor.constraint(equalTo: themeView.topAnchor, constant: view.frame.width * 0.02),
			imageView.bottomAnchor.constraint(equalTo: themeView.bottomAnchor, constant: -view.frame.width * 0.02),
			imageView.widthAnchor.constraint(equalTo: themeView.widthAnchor, multiplier: 0.3),

			themeLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: view.frame.width * 0.03),
			themeLabel.topAnchor.constraint(equalTo: imageView.topAnchor),

			descriptionLabel.topAnchor.constraint(equalTo: themeLabel.bottomAnchor, constant: topViewHeight * 0.2),
			descriptionLabel.leadingAnchor.constraint(equalTo: themeLabel.leadingAnchor),
			descriptionLabel.trailingAnchor.constraint(equalTo: themeView.trailingAnchor, constant: -view.frame.width * 0.02),
			descriptionLabel.bottomAnchor.constraint(equalTo: themeView.bottomAnchor),
			
			stageTableView.topAnchor.constraint(equalTo: topView.safeAreaLayoutGuide.bottomAnchor),
			stageTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			stageTableView.widthAnchor.constraint(equalToConstant: view.frame.width * 0.2),
			stageTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

			chapterCollectionView.leadingAnchor.constraint(equalTo: stageTableView.trailingAnchor),
			chapterCollectionView.trailingAnchor.constraint(equalTo: themeView.trailingAnchor),
			chapterCollectionView.topAnchor.constraint(equalTo: themeView.bottomAnchor, constant: view.frame.height * 0.02),
			chapterCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])
	}

	func getCourse(id: UUID) {
		Task {
			let result = await CourseAPI.getCourse(id: courseID)
			switch result {
				case .success(let course):
					self.course = course
				case .failure(let error):
					error.present(on: self, title: "无法获取课程", actions: [])
			}
		}
	}

//	func loadChapterImages() async -> [UIImage?] {
//		var imagesArray: [UIImage?] = .init(repeating: nil, count: placeholderForNumberOfCells)
//		imagesArray.reserveCapacity(30)
////		Task {
//			await withTaskGroup(of: (index: Int, data: Data?).self) { group in
//				for (index, chapter) in course.chapters.enumerated() {
//					if let imagePath = chapter.imagePath {
//						group.addTask {
//							let data = try? await FileAPI.getFile(path: imagePath).get()
//							return (index, data)
//						}
//					}
//				}
//
//				for await result in group {
//					if let data = result.data, let image = UIImage(data: data) {
//						imagesArray[result.index] = image
//					}
//				}
//			}
////		}
//		return imagesArray
//	}
}

//extension CourseDetailVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//
//	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//		return course.chapters.count
//	}
//
//	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChapterCell.identifier, for: indexPath) as! ChapterCell
//
//		cell.createShadow()
//
//		//		cell.imageView.image = chapterCellImages[indexPath.item]
//				cell.imageView.image = nil
//		let name = course.chapters[indexPath.item].name
//		if let image = chapterImages[indexPath.item] {
//			cell.imageView.image = image
//		}
//
//		return cell
//	}
//
//	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//		let totalWidth = collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right)
//		let width = totalWidth / 4 - 5	// Accounts for item spacing
//
//		return CGSize(width: width, height: width * 1.2)
//	}
//
//	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//		return 5
//	}
//
//	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//		collectionView.bounds.height * 0.1
//	}
//
//#warning("sync api will block user interaction")
//	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//		let chapter = course.chapters[indexPath.item]
//		guard chapter.pdfURL != nil else {
//			MessagePresenter.showMessage(title: "未找到课程文件", message: "请联系管理员\(adminEmail)", on: self, actions: [])
//			return
//		}
//		let chapterVC = ChapterDetailVC()
//		chapterVC.chapter = chapter
//		navigationController?.pushViewController(chapterVC, animated: false)
//	}
//
//}

extension CourseDetailVC {
//	func getChapterImages() async -> [String: UIImage] {
//		var imagesDict = [String: UIImage]()
//		return await withTaskGroup(of: (name: String, image: UIImage?).self) { group in
//
//			for chapter in course.chapters {
//				if let imagePath = chapter.imagePath {
//					group.addTask {
//						if let data = try? await FileAPI.getFile(path: imagePath).get(),
//						   let image = UIImage(data: data) {
//							return (chapter.name, image)
//						}
//						return (chapter.name, nil)
//					}
//				}
//			}
//
//			for await task in group {
//				for name in course.chapters.map({ $0.name }) {
//					if task.name == name {
//						imagesDict[name] = task.image
//					}
//				}
//			}
//			return imagesDict
//		}
//	}
}

extension CourseDetailVC: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return stages.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Self.stageTableCellIdentifier, for: indexPath)
		cell.textLabel!.text = stages[indexPath.row].name
		cell.backgroundColor = .blue
		return cell
	}
}
