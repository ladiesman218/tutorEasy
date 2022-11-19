//
//  CourseDetailVC.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/30.
//

import UIKit

class CourseDetailVC: UIViewController {
	
	// MARK: - Properties
	var languageName: String!
	private var chapterCellImages: [UIImage?]! {
		didSet {
			chapterCollectionView.reloadData()
		}
	}
	
	var course: Course! {
		didSet {
			for (index, chapter) in course.chapters.enumerated() {
				if let imagePath = chapter.imagePath {
					FileAPI.getFile(path: imagePath) { [unowned self] data, response, error in
						if let data = data {
							let image = UIImage(data: data)!
							self.chapterCellImages[index] = image
						}
					}
				}
			}
		}
	}
	
	// MARK: - Custom subviews
	private var topView: UIView!
	private var iconView: ProfileIconView = .init(frame: .zero)
	private var backButtonView: UIView!
	private let languageNavView: UIView = {
		let languageNavView = UIView()
		languageNavView.translatesAutoresizingMaskIntoConstraints = false
		// Set a corner-like edge on the right side of the background
		languageNavView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
		languageNavView.layer.cornerCurve = .circular
		// We are using backed layer to draw a round radius corner, simply set label's background color will render all previous configurations obsolete since view's background color comes on top of layer. So use layer's backgroundColor here. 
		languageNavView.layer.backgroundColor = UIColor.systemYellow.cgColor
		languageNavView.layer.zPosition = .greatestFiniteMagnitude
		
		
		return languageNavView
	}()
	
	private var languageTitle: UILabel = {
		let languageTitle = UILabel()
		languageTitle.translatesAutoresizingMaskIntoConstraints = false
		languageTitle.textColor = .white
		return languageTitle
	}()
	
	private var courseNavView: UIView = {
		let courseNavView = UIView()
		courseNavView.translatesAutoresizingMaskIntoConstraints = false
		// Set a corner-like edge on the right side of the background
		courseNavView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
		courseNavView.layer.cornerCurve = .circular
		// We are using backed layer to draw a round radius corner, simply set label's background color will render all previous configurations obsolete since view's background color comes on top of layer. So use layer's backgroundColor here.
		courseNavView.layer.backgroundColor = UIColor.systemOrange.cgColor
		return courseNavView
	}()
	
	private var courseTitle: UILabel = {
		let courseTitle = UILabel()
		courseTitle.translatesAutoresizingMaskIntoConstraints = false
		courseTitle.textColor = .white
		return courseTitle
	}()
	
	private var themeView: UIView = {
		let themeView = UIView()
		themeView.translatesAutoresizingMaskIntoConstraints = false
		themeView.layer.backgroundColor = UIColor.systemGray5.cgColor
		return themeView
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
	
	private var chapterCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
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
		
		// downloaded() function for imageView is asynchronous, it's gonna cause problem in collection view: when scrolling, images got misplaced. The solution we took is, create an array with optional images, set its initial value to nil and repeating as many times as chapters for the course. When course is set, get the image for each chapter, if one is found, replace the original nil value with the UIImage just found. This is done in the property observer of course.
		chapterCellImages = .init(repeating: nil, count: course.chapters.count)
		
		chapterCollectionView.dataSource = self
		chapterCollectionView.delegate = self
		
		view.backgroundColor = .systemGray4
		topView = configTopView(bgColor: UIColor.systemGray6)
		
		iconView.layer.backgroundColor = UIColor.clear.cgColor
		let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.profileIconClicked))
		iconView.addGestureRecognizer(tap)
		topView.addSubview(iconView)
		
		languageNavView.layer.cornerRadius = topViewHeight * 0.3
		backButtonView = setUpGoBackButton(in: languageNavView)
		topView.addSubview(languageNavView)
		
		languageTitle.text = languageName
		languageTitle.font = languageTitle.font.withSize(topViewHeight / 2)
		languageNavView.addSubview(languageTitle)
		
		courseNavView.layer.cornerRadius = topViewHeight * 0.3
		topView.addSubview(courseNavView)
		
		courseTitle.text = course.name
		courseTitle.font = courseTitle.font.withSize(topViewHeight / 2)
		courseNavView.addSubview(courseTitle)
		
		themeView.layer.cornerRadius = view.frame.width * 0.04
		view.addSubview(themeView)
		
		themeLabel.font = themeLabel.font.withSize(topViewHeight / 3)
		themeView.addSubview(themeLabel)
		
		descriptionLabel.text = course.description
		descriptionLabel.font = descriptionLabel.font.withSize(topViewHeight / 3.5)
		themeView.addSubview(descriptionLabel)
		
		// This is the image added to themeView, on top side.
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		if let imagePath = course.imagePath {
			imageView.downloaded(from: imagePath, contentMode: .scaleAspectFill)
		}
		imageView.layer.cornerRadius = view.frame.width * 0.04 * 0.7
		imageView.clipsToBounds = true
		themeView.addSubview(imageView)
		
		chapterCollectionView.layer.cornerRadius = topViewHeight * 0.3
		let inset = view.frame.width * 0.02
		chapterCollectionView.contentInset = .init(top: inset, left: inset, bottom: inset, right: inset)
		view.addSubview(chapterCollectionView)
		
		NSLayoutConstraint.activate([
			languageTitle.leadingAnchor.constraint(equalTo: backButtonView.trailingAnchor, constant: topViewHeight * 0.7),
			languageTitle.trailingAnchor.constraint(equalTo: languageNavView.trailingAnchor, constant: -topViewHeight),
			languageTitle.topAnchor.constraint(equalTo: languageNavView.topAnchor),
			languageTitle.bottomAnchor.constraint(equalTo: languageNavView.bottomAnchor),
			
			languageNavView.leadingAnchor.constraint(equalTo: topView.leadingAnchor),
			languageNavView.topAnchor.constraint(equalTo: topView.topAnchor),
			languageNavView.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
			
			courseTitle.leadingAnchor.constraint(equalTo: courseNavView.leadingAnchor, constant: topViewHeight * 0.7),
			courseTitle.trailingAnchor.constraint(equalTo: courseNavView.trailingAnchor, constant: -topViewHeight * 0.7),
			courseTitle.topAnchor.constraint(equalTo: courseNavView.topAnchor),
			courseTitle.bottomAnchor.constraint(equalTo: courseNavView.bottomAnchor),
			
			courseNavView.leadingAnchor.constraint(equalTo: languageNavView.trailingAnchor, constant: -topViewHeight * 0.3),
			courseNavView.topAnchor.constraint(equalTo: topView.topAnchor),
			courseNavView.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
			
			iconView.trailingAnchor.constraint(equalTo: topView.trailingAnchor),
			iconView.topAnchor.constraint(equalTo: topView.topAnchor),
			iconView.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
			iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor),
			
			themeView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: view.frame.width * 0.01),
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
			
			chapterCollectionView.leadingAnchor.constraint(equalTo: themeView.leadingAnchor),
			chapterCollectionView.trailingAnchor.constraint(equalTo: themeView.trailingAnchor),
			chapterCollectionView.topAnchor.constraint(equalTo: themeView.bottomAnchor, constant: view.frame.height * 0.02),
			chapterCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])
	}
}

extension CourseDetailVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return course.chapters.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChapterCell.identifier, for: indexPath) as! ChapterCell
		
		cell.imageView.image = chapterCellImages[indexPath.item]
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = (collectionView.bounds.width * 0.8) / 4
		
		return CGSize(width: width, height: width * 1.2)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 5
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		collectionView.bounds.height * 0.1
	}
	
#warning("Async api will block user interaction")
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let chapter = course.chapters[indexPath.item]
		guard chapter.pdfURL != nil else {
			print("Can't find pdf path for chapter")
			return
		}
		let chapterVC = ChapterDetailVC()
		chapterVC.chapter = chapter
		navigationController?.pushViewController(chapterVC, animated: false)
	}
	
}
