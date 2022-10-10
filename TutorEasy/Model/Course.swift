//
//  Course.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/9/20.
//

import Foundation

struct Course: Codable {
	let id: UUID?
	let name: String
	let description: String
	let price: Double
	let published: Bool
	let freeChapters: [Int]
	
	
	struct PublicInfo: Decodable {
		let name: String
		let description: String
		let price: Double
		let path: URL?
		let imageURL:  URL?
		let courseCount: Int
		let freeChapters: [Int]
	}
	
}
