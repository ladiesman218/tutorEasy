//
//  Course.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/9/20.
//

import UIKit

class CourseModel: Codable {
	let id: UUID
	let name: String
	let description: String
	let price: Float
	let stages: [Stage]
    let imageURL: URL?
	let annuallyIAPIdentifier: String
	
	init(id: UUID, name: String, description: String, price: Float, stages: [Stage], imageURL: URL?, annuallyIAPIdentifier: String) {
		self.id = id
		self.name = name
		self.description = description
		self.price = price
		self.stages = stages
		self.imageURL = imageURL
		self.annuallyIAPIdentifier = annuallyIAPIdentifier
	}
}

class Course: CourseModel, Equatable {
	static func == (lhs: Course, rhs: Course) -> Bool {
		return lhs.id == rhs.id
	}
	
	var image: UIImage?
}
