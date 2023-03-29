//
//  Course.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/9/20.
//

import Foundation

struct Course: Codable {
	let id: UUID
	let name: String
	let description: String
	let price: Float
	let stages: [Stage]
    let imageURL: URL?
	let annuallyIAPIdentifier: String
}
