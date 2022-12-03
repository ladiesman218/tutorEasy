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
		fetchProducts()
	}
	
	func fetchProducts() {
//		let identifiers = Product.allCases.map { $0.rawValue }
		LanguageAPI.getAllLanguages { [unowned self] languages, response, error in
			guard let languages = languages, error == nil else {
				MessagePresenter.showMessage(title: "获取语言列表失败", message: error!.reason, on: self, actions: [])
				return
			}
			var identifiers = languages.map { $0.appStoreID }
			identifiers.append(vipIDforIAP)
			request = SKProductsRequest(productIdentifiers: Set(identifiers))
			request.delegate = self
			request.start()

		}
	}
}

extension ProductsViewController: SKProductsRequestDelegate {
	func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
		products = response.products
//		print(products.count)
		print(response.invalidProductIdentifiers)
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
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let payment = SKPayment(product: products[indexPath.row])
		SKPaymentQueue.default().add(payment)
	}
}

