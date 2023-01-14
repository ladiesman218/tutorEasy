//
//  ProductsViewController.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/12/1.
//

import UIKit
import StoreKit

class ProductsViewController: UIViewController {
	
	// MARK: - Custom Properties
	static let cellIdentifier = "IAPProductCell"
	private var products = [SKProduct]() {
		didSet {
			
			// Make sure VIP membership product is always in the first place
			products.sort { lhs, rhs in
				return lhs.localizedTitle.contains("VIP")
			}
				
			DispatchQueue.main.async { [unowned self] in
				self.productList.reloadData()
			}
		}
	}
	// Keep a strong reference to the request object; otherwise, the system might deallocate the request before it can complete
	var request: SKProductsRequest!
	
	// MARK: - Custom Views
	private let productList: UITableView = {
		let tableView = UITableView()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
		return tableView
	}()
	
	// MARK: - View Controller functions
	
	override func loadView() {
		super.loadView()
		fetchProducts()

		guard let userID = AuthAPI.userInfo?.id else { self.navigationController?.popViewController(animated: true)
			return
		}
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.addSubview(productList)
		//		productList.frame = view.bounds
		productList.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			productList.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			productList.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			productList.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			productList.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			
		])
		productList.dataSource = self
		productList.delegate = self
	}
	
	func fetchProducts() {
		let url = baseURL.appendingPathComponent("iap")
		
		URLSession.shared.dataTask(with: url) {  [unowned self] data, response, error in
			guard let data = data else {
				MessagePresenter.showMessage(title: "无法获取在售订阅", message: "请联系管理员\(adminEmail)", on: self, actions: [])
				return
			}
			guard let identifiers = try? JSONDecoder().decode([String].self, from: data) else {
				fatalError("无法生成订阅ID")
			}
			
			request = SKProductsRequest(productIdentifiers: Set(identifiers))
			request.delegate = self
			request.start()

		}.resume()
	}

}


extension ProductsViewController: SKProductsRequestDelegate {
	func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
		products = response.products
	}
}

extension ProductsViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return products.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath)
		let product = products[indexPath.row]
		cell.textLabel!.numberOfLines = 0
		cell.textLabel!.text = "\(product.localizedTitle) - \(product.localizedDescription) \(product.priceLocale.currencySymbol ?? "￥")\(product.price)"
		
		// Set button as the accessoryView of a cell, responsible for purchase subscribe
		let purchaseButton = UIButton(type: .custom)
		purchaseButton.backgroundColor = .systemTeal
		purchaseButton.setTitle(" 订阅 ", for: .normal)
		purchaseButton.sizeToFit()
		purchaseButton.layer.cornerRadius = purchaseButton.bounds.width * 0.35

		for order in AuthAPI.orders {
			print(order)
			if order.items.contains(where: { cache in
				cache.iapIdentifier == product.productIdentifier
			}) {
				print("owned")
				purchaseButton.setTitle("", for: .normal)
				
				purchaseButton.setImage(.checkmark, for: .normal)
				purchaseButton.isEnabled = false
				purchaseButton.layer.cornerRadius = 0
				purchaseButton.backgroundColor = nil

			}
		}

		purchaseButton.tag = indexPath.row
		purchaseButton.addTarget(self, action: #selector(purchaseTapped), for: .touchUpInside)
		cell.accessoryView = purchaseButton
		
		
		return cell
	}
	
	@objc func purchaseTapped(sender: UIButton) {
		
		#warning("test if authVC can be properly pushed")
#warning("If token doesn't exist on server, logout the user. Edge case: client app never logout, serverside db is re-created, so token exist on app, but user doesn't exist on server")
		guard let userID = AuthAPI.userInfo?.id.uuidString else {
			let cancel = UIAlertAction(title: "再看看", style: .cancel)
			let login = UIAlertAction(title: "去登录", style: .default) { [unowned self] _ in
				let authVC = AuthenticationVC(nibName: nil, bundle: nil)
				self.navigationController?.pushViewController(authVC, animated: true)
			}
			MessagePresenter.showMessage(title: "请先登录账号", message: "请在注册/登录后管理您的课程订阅", on: self, actions: [cancel, login])
			return
		}
		
		let payment = SKMutablePayment(product: products[sender.tag])
		payment.applicationUsername = userID
		
		SKPaymentQueue.default().add(payment)

	}
}
