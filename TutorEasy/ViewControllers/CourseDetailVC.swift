//
//  CourseDetailVC.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/30.
//

import UIKit

class CourseDetailVC: UIViewController {
	// MARK: - Properties
	static let stageTableCellIdentifier = "StageTableCellIdentifier"
	var courseID: UUID!
	
	private var course = coursePlaceHolder {
		didSet {
			courseTitle.text = course.name
			self.stages = course.stages
		}
	}
	
	private var stages: [Stage] = [] {
		didSet {
			Task {
				let urls = stages.map { $0.imageURL }
				self.stageImages = await downloadImages(urls: urls)
			}
		}
	}
	
	private var stageImages: [UIImage?] = [] {
		didSet {
			stageTableView.reloadData()
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
		courseTitle.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]

		return courseTitle
	}()
	
	private var stageTableView: UITableView = {
		let stageTableView = UITableView()
		stageTableView.register(UITableViewCell.self, forCellReuseIdentifier: stageTableCellIdentifier)
		stageTableView.translatesAutoresizingMaskIntoConstraints = false
		stageTableView.layer.cornerRadius = 20
		stageTableView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
		stageTableView.contentInset = .init(top: 30, left: 30, bottom: 30, right: 30)
		stageTableView.backgroundColor = .systemGray5
		return stageTableView
	}()
	// MARK: - Controller functions
	
	// When coming back from a previous VC, clear selection otherwise former selected item still shows different background color.
	override func viewWillAppear(_ animated: Bool) {
		stageTableView.selectRow(at: nil, animated: false, scrollPosition: .top)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		getCourse()
		
		view.backgroundColor = backgroundColor
		topView = configTopView(bgColor: UIColor.clear)
		
		iconView.layer.backgroundColor = UIColor.clear.cgColor
		let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.profileIconClicked))
		iconView.addGestureRecognizer(tap)
		topView.addSubview(iconView)
		
		backButtonView = setUpGoBackButton(in: topView)
		
		courseTitle.font = courseTitle.font.withSize(topViewHeight / 2)
		courseTitle.layer.cornerRadius = courseTitle.font.pointSize * 0.8
		topView.addSubview(courseTitle)
		
		view.addSubview(stageTableView)
		stageTableView.dataSource = self
		stageTableView.delegate = self
		
		NSLayoutConstraint.activate([
			courseTitle.leadingAnchor.constraint(equalTo: backButtonView.trailingAnchor),
			courseTitle.topAnchor.constraint(equalTo: topView.topAnchor),
			courseTitle.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
			
			iconView.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
			iconView.topAnchor.constraint(equalTo: topView.topAnchor),
			iconView.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
			iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor),
			
			stageTableView.leadingAnchor.constraint(equalTo: backButtonView.leadingAnchor),
			stageTableView.trailingAnchor.constraint(equalTo: iconView.trailingAnchor),
			stageTableView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 20),
			stageTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}
	
	func getCourse() {
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
}

extension CourseDetailVC: UITableViewDataSource, UITableViewDelegate {
	
	var cellHeight: CGFloat  {
		stageTableView.frame.height / 2.5
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return stages.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// Dequeue resuable cell won't give back cells with detailTextLable, at least not for iphone 6s
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: Self.stageTableCellIdentifier)
		
		cell.textLabel!.text = stages[indexPath.row].name
		cell.imageView?.layer.cornerRadius = tableView.layer.cornerRadius
		cell.imageView?.clipsToBounds = true
		cell.imageView?.image = stageImages[indexPath.row]
				
		cell.detailTextLabel?.numberOfLines = 3
		cell.detailTextLabel?.font = cell.detailTextLabel?.font.withSize(cellHeight / 10)
		cell.textLabel?.font = cell.textLabel?.font.withSize(cellHeight / 7)
		cell.detailTextLabel?.text = stages[indexPath.row].description
		cell.backgroundColor = tableView.backgroundColor
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return cellHeight
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let stageURL = stages[indexPath.row].directoryURL
		let chaptersVC = ChaptersVC()
		chaptersVC.stageURL = stageURL
		chaptersVC.courseName = course.name
		navigationController?.pushIfNot(destinationVCType: ChaptersVC.self, newVC: chaptersVC)
	}
	
	
	
}
