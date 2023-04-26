//
//  ResponseError.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/8/16.
//

import Foundation

struct ResponseError: Error, Decodable {
	var error: Bool = true
	var reason: String
}

// Override Error's localizedDescription property for ResponseErrors
public extension Error {
	var localizedDescription: String {
		if let responseError = self as? ResponseError {
			return responseError.reason
		}
		// Keep default implementation
		return NSError(domain: _domain, code: _code, userInfo: nil).localizedDescription
	}
}
