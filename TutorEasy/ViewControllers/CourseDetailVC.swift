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
		stageTableView.contentInset = .init(top: 15, left: 0, bottom: 0, right: 0)
		stageTableView.backgroundColor = .systemGray5
		//		stageTableView.bounces = false
		return stageTableView
	}()
	// MARK: - Controller functions
	
	// When coming back from a previous VC, clear selection otherwise former selected item still shows different background color.
	override func viewWillAppear(_ animated: Bool) {
		loadCourse()
		stageTableView.selectRow(at: nil, animated: false, scrollPosition: .top)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		topView = configTopView()
		
		topView.addSubview(iconView)
		
		backButtonView = setUpGoBackButton(in: topView)
		
		courseTitle.font = courseTitle.font.withSize(Self.topViewHeight / 2)
		courseTitle.layer.cornerRadius = courseTitle.font.pointSize * 0.8
		topView.addSubview(courseTitle)
		
		view.addSubview(stageTableView)
		stageTableView.dataSource = self
		stageTableView.delegate = self
		// Disable horizontal scroll
		stageTableView.contentSize = .init(width: stageTableView.frame.width, height: stageTableView.contentSize.height)
		
		NSLayoutConstraint.activate([
			topView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
			topView.heightAnchor.constraint(equalToConstant: Self.topViewHeight),
			
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
	
	private func loadCourse() {
		Task {
			do {
				self.course = try await CourseAPI.getCourse(id: courseID)
			} catch {
				let goBack = UIAlertAction(title: "返回", style: .cancel) { [unowned self] _ in
					self.navigationController?.popViewController(animated: true)
				}
				error.present(on: self, title: "无法获取课程", actions: [goBack])
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
		cell.textLabel?.font = cell.textLabel?.font.withSize(cellHeight / 7)
		
		cell.imageView?.layer.cornerRadius = tableView.layer.cornerRadius
		cell.imageView?.clipsToBounds = true
		cell.imageView?.image = stageImages[indexPath.row]
		
		// Set detailTextLabel to have 3 lines at most, when overflow, truncate tail
		cell.detailTextLabel?.numberOfLines = 3
		cell.detailTextLabel?.allowsDefaultTighteningForTruncation = true
		cell.detailTextLabel?.lineBreakMode = .byTruncatingTail
		cell.detailTextLabel?.font = cell.detailTextLabel?.font.withSize(cellHeight / 10)
		cell.detailTextLabel?.text = stages[indexPath.row].description
		
		cell.backgroundColor = tableView.backgroundColor
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return cellHeight
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let stage = stages[indexPath.row]
		let chaptersVC = ChaptersVC()
		chaptersVC.stageURL = stage.directoryURL
		chaptersVC.courseName = course.name
		chaptersVC.stageName = stage.name
		navigationController?.pushIfNot(newVC: chaptersVC)
	}
	
}
