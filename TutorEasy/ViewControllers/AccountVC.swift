//
//  AccountVC.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/14.
//

import UIKit

class AccountVC: UIViewController {
	
	// MARK: - Custom Properties
	static let customBgColor = UIColor.systemBlue.withAlphaComponent(0.6)
	static let navigationIdentifier = "accountsVCNavCell"
	
	enum SubVC: String, CaseIterable {
		case profile = "个人资料"
		case subscription = "管理订阅"
		case wallet = "我的钱包"
		case logout = "退出登录"
	}
	static let subVCs = SubVC.allCases
	var currentVC: SubVC! {
		didSet {
			// Remove previous added view controller from self, and remove its view from containerView first.
			self.children.forEach {
				$0.removeFromParent()
			}
			containerView.subviews.forEach {
				$0.removeFromSuperview()
			}

			// Add new viewController and its view accordingly.
			switch currentVC {
				case .profile:
					let profileVC = ProfileVC()
					addChild(profileVC)
					containerView.addSubview(profileVC.view)
					profileVC.view.frame = containerView.bounds
				case .subscription:
					let productsVC = ProductsViewController()
					addChild(productsVC)
					containerView.addSubview(productsVC.view)
					productsVC.view.frame = containerView.bounds
				case .wallet:
					break
				case .logout:
					Task {
						let _ = await AuthAPI.logout()
						self.navigationController?.popViewController(animated: true)
					}
				case .none:
					break
			}
		}
	}
	
	// MARK: - Custom Views
	private var topView: UIView!
	private var backButtonView: UIView!
	private let navTitle: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "个人中心"
		label.textColor = .white
		return label
	}()
	
	private let navigationTable: UITableView = {
		let tableView = UITableView()
		tableView.backgroundColor = customBgColor
		tableView.bounces = false
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: navigationIdentifier)
		return tableView
	}()
	
	private let containerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	// MARK: - View Controller functions
	// Without this, navigationTable won't show a selected background before selection change, kinda confusing which one is currently selected when first enter this VC.
	override func viewWillAppear(_ animated: Bool) {
		let index = Self.subVCs.firstIndex(of: currentVC)!
		let indexPath = IndexPath(row: index, section: 0)
		navigationTable.selectRow(at: indexPath, animated: false, scrollPosition: .none)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = backgroundColor
		
		topView = configTopView(bgColor: Self.customBgColor)
		backButtonView = setUpGoBackButton(in: topView)
		
		view.addSubview(navTitle)
		navTitle.font = navTitle.font.withSize(topViewHeight / 2)
		
		view.addSubview(navigationTable)
		navigationTable.dataSource = self
		navigationTable.delegate = self
		
		view.addSubview(containerView)
		
		NSLayoutConstraint.activate([
			// Leading position of backButtonView is special in accountsVC
			backButtonView.leadingAnchor.constraint(equalTo: topView.leadingAnchor),
			
			navTitle.leadingAnchor.constraint(equalTo: backButtonView.trailingAnchor),
			navTitle.heightAnchor.constraint(equalTo: topView.heightAnchor),
			navTitle.topAnchor.constraint(equalTo: topView.topAnchor),
			
			navigationTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			navigationTable.topAnchor.constraint(equalTo: topView.bottomAnchor),
			navigationTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			navigationTable.widthAnchor.constraint(equalToConstant: view.frame.width * 0.2),
			
			containerView.topAnchor.constraint(equalTo: topView.bottomAnchor),
			containerView.leadingAnchor.constraint(equalTo: navigationTable.trailingAnchor),
			containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
		
		
	}
	
	@objc func logout() {
		Task {
			let result = await AuthAPI.logout()
			do {
				try result.get()
				self.navigationController?.popViewController(animated: true)
			} catch {
				error.present(on: self, title: "登出错误", actions: [])
			}
		}
	}
	
}

extension AccountVC: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Self.subVCs.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Self.navigationIdentifier, for: indexPath)
		cell.textLabel!.text = Self.subVCs.map { $0.rawValue }[indexPath.row]
		cell.textLabel!.textColor = .white
		cell.backgroundColor = Self.customBgColor
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return tableView.frame.height / CGFloat(tableView.numberOfRows(inSection: 0))
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// When selection change, just change currentVC's value, then the property observer of currentVC will change sub viewController and view
		currentVC = Self.subVCs[indexPath.row]
	}
	
	
}
