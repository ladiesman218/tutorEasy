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
	private let navigationTexts = ["个人资料", "我的课程", "我的钱包", "退出登录"]
	static let navigationIdentifier = "accountsVCNavCell"
	
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
//		tableView.backgroundColor = customBgColor
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
        AuthAPI.logout { result in
            switch result {
            case .success:
                self.navigationController?.popViewController(animated: true)
            case .failure(let reason):
                MessagePresenter.showMessage(title: "注销错误", message: reason, on: self, actions: [])
            }
        }
    }
    
}

extension AccountVC: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 4
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Self.navigationIdentifier, for: indexPath)
		cell.textLabel!.text = navigationTexts[indexPath.row]
		cell.textLabel!.textColor = .white
		cell.backgroundColor = Self.customBgColor

		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return tableView.frame.height / CGFloat(tableView.numberOfRows(inSection: 0))
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		for vc in self.children  {
			vc.removeFromParent()
		}

		switch indexPath {
			case [0, 0]:
				break
			case [0, 1]:
				let productsVC = ProductsViewController()
				self.addChild(productsVC)
				self.containerView.addSubview(productsVC.view)
				productsVC.view.frame = self.containerView.bounds
				
			case [0, 2]:
				break
			case [0, 3]:
				break
			default:
				break
		}
		
	}
}
