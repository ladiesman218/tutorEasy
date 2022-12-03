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
    let directoryURL: URL
    let imagePath: String?
    let freeChapters: [Int]
    let chapters: [Chapter]
}
