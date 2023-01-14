//
//  LanguageCache.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/12/30.
//

import Foundation

struct LanguageCache: Codable {
	let languageID: UUID
	let name: String
	let description: String
	let price: Double
	let iapIdentifier: String?
}
