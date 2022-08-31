//
//  RegistrationError.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/8/12.
//

import Foundation
enum RegistrationError: AbortError {
	case passwordsDontMatch
	case emailAlreadyExists
	case usernameAlreadyExists
	case passwordLengthError
	case usernameLengthError
	case invalidEmail
	case invalidUsername
	case invalidDate
	
	var reason: String {
	  switch self {
	  case .passwordsDontMatch:
		return "Passwords did not match"
	  case .emailAlreadyExists:
		return "A user with that email already exists"
	  case .usernameAlreadyExists:
		return "Username is taken"
	  case .passwordLengthError:
		return "Password length must be between \(passwordLength.lowerBound.description) and \((passwordLength.upperBound - 1).description) characters"
	  case .usernameLengthError:
		return "Username should be between \(userNameLength.lowerBound.description) and \((userNameLength.upperBound - 1).description) characters"
	  case .invalidEmail:
		return "Email address is not valid"
	  case .invalidUsername:
		return "Username contains invalid character(s)"
	  case .invalidDate:
		return "Invalid date provided"
	  }
	}
}

