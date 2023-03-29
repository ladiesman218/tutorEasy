//
//  Order.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/12/30.
//

import Foundation

struct Order: Codable {
	let id: UUID
	let status: String
	let items: [CourseCache]
	let user: Dictionary<String, UUID>
	let paymentAmount: Float
	let originalTransactionID: String?
	let transactionID: String
	let iapIdentifier: String?
	
	let generateTime: String
	let completeTime: String?
	let cancelTime: String?
	let refundTime: String?
	let expirationTime: String?
}
