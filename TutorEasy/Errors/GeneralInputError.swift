//
//  GeneralInputError.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/8/12.
//

import Foundation


enum GeneralInputError: AbortError {
	case invalidID
	case invalidSlug
	case nameExisted(name: String)
	case nameLengthInvalid
	case invalidPrice
	
	var reason: String {
		switch self {
		case .invalidID:
			return "Invalid ID type, please refer to documentation"
		case .invalidSlug:
			return "Slug should only contain lowercase letters (a - z), and numbers (0-9) and dashes (-)"
		case .nameExisted(let name):
			return "\(name) is already used"
		case .nameLengthInvalid:
			return "Name should be between \(nameLength.lowerBound.description) and \((nameLength.upperBound - 1).description) characters"
		case .invalidPrice:
			return "Price can't be less than 0"
		}
	}
}
