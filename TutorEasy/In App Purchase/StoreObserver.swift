//
//  StoreObserver.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/12/1.
//

import Foundation
import StoreKit


#warning("订阅状态变化可能发生在app外，例如用户通过app store更新续订，或通过app store及其他渠道取消续订或请求退款。最好用App Store Server Notifications接收apple主动发来的订阅状态变化通知")
#warning("在app内链接到https://reportaproblem.apple.com或以其他方式给用户提供发起退款或申请支持、联系")
class StoreObserver: NSObject, SKPaymentTransactionObserver {
	
	static let shared = StoreObserver()
	//Initialize the store observer.
	override init() {
		super.init()
		//Other initialization here.
	}

	//Observe transaction updates.
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		
		guard SKPaymentQueue.canMakePayments() else {
			print("can not make payment")
			return
		}

		transactions.forEach {
			
			switch $0.transactionState {
				case .purchasing:
					print("purchasing")
				case .purchased:
					print("purchased")
					if let receiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: receiptURL.path) {
						
						print("Transaction ID: \(String(describing: $0.transactionIdentifier))")
//						let rawData = try! Data(contentsOf: receiptURL, options: .alwaysMapped)
//						print(rawData)
//						let string = rawData.base64EncodedString(options: )
//						let string2 = String(data: rawData, encoding: .utf8)
//						print("string: \(String(describing: string))")
//						print("string2: \(String(describing: string2))")
					}
					SKPaymentQueue.default().finishTransaction($0)
				case .failed:
					print("failed")
					SKPaymentQueue.default().finishTransaction($0)
				case .restored:
					print("restored")
					SKPaymentQueue.default().finishTransaction($0)
				case .deferred:
					print("deferred")
				@unknown default:
					break
			}
		}
	}
	
}
