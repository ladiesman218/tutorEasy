//
//  User.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/8/10.
//

import Foundation


struct User: Codable {
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
		
		func validate(errors: inout [Error]) {
			if email.range(of: emailRegex, options: .regularExpression) == nil {
				errors.append(RegistrationError.invalidEmail)
			}
			
			if !userNameLength.contains(username.count) {
				errors.append(RegistrationError.usernameLengthError)
			}
			
			if firstName != nil {
				if !nameLength.contains(firstName!.count) {
					errors.append(GeneralInputError.nameLengthInvalid)
				}
			}
			
			if lastName != nil {
				if !nameLength.contains(lastName!.count) {
					errors.append(GeneralInputError.nameLengthInvalid)
				}
			}
			
			if password1 != password2 {
				errors.append(RegistrationError.passwordsDontMatch)
			}
			
			if !passwordLength.contains(password1.count) {
				errors.append(RegistrationError.passwordLengthError)
			}
			
		}
	}
}

extension User {
	struct PublicInfo: Decodable {
		let id: String
		let email: String
		let username: String
		var firstName: String?
		var lastName: String?
		let registerTime: Date?
		let lastLoginTime: Date?
	}
	
}
