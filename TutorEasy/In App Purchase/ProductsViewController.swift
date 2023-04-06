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
	private var products: [SKProduct] = [] {
		didSet {
			// Make sure VIP membership product is always in the first place
			products.sort { lhs, rhs in
				return lhs.localizedTitle.contains("VIP")
			}
			
			Task {
				await MainActor.run {
					self.productList.reloadData()
				}
			}
		}
	}
	// Keep a strong reference to the request object; otherwise, the system might deallocate the request before it can complete
	var request: SKProductsRequest!
	
	// MARK: - Custom Views
	private let productList: UITableView = {
		let tableView = UITableView()
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
		return tableView
	}()
	
	// MARK: - View Controller functions
	
	override func loadView() {
		super.loadView()
		fetchProducts()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.addSubview(productList)
		
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
		
		Task {
			do {
				let (data, _) = try await URLSession.shared.requestWithToken(url: url)
				let identifiers = try JSONDecoder().decode([String].self, from: data)
				request = SKProductsRequest(productIdentifiers: Set(identifiers))
				request.delegate = self
				request.start()
				
			} catch {
				error.present(on: self, title: "无法获取可供订阅的课程信息", actions: [])
			}
		}
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
			if order.items.contains(where: { cache in
				cache.iapIdentifier == product.productIdentifier
			}) {
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
		
		Task {
			guard let userInfo = try? await AuthAPI.getPublicUserFromToken().get() else {
				// Dispite whether token is nil or not, as long as userInfo can not be get from server, we logout the user(by setting token to nil to make sure), this also pushes user back to authVC)
				AuthAPI.tokenValue = nil
				let cancel = UIAlertAction(title: "再看看", style: .cancel)
				let login = UIAlertAction(title: "去登录", style: .default) { [unowned self] _ in
					let authVC = AuthenticationVC()
					self.navigationController?.pushIfNot(newVC: authVC, animated: true)
				}
				MessagePresenter.showMessage(title: "登录信息已失效", message: "重新登录后管理您的课程订阅", on: self, actions: [login, cancel])
				return
			}

			let payment = SKMutablePayment(product: products[sender.tag])
			payment.applicationUsername = userInfo.id.uuidString
			
			SKPaymentQueue.default().add(payment)
		}
		
	}
}
