//
//  User.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/8/10.
//

import Foundation


struct User {
	let id: UUID?
	let email: String
	let username: String
	let firstName: String?
	let lastName: String?
	let password: String
	let registerTime: Date?
	let lastLoginTime: Date?
	
	
}

extension User {
	
	struct RegisterInput: Encodable {
		let email: String
		let username: String
		var firstName: String?
		var lastName: String?
		let password1: String
		let password2: String
		
	}
}

extension User {
	struct PublicInfo: Codable {
		let id: UUID
		let email: String
		let username: String
		var firstName: String?
		var lastName: String?
		let registerTime: Date?
		let lastLoginTime: Date?
	}
	
}
