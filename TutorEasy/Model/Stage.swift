//
//  Stage.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/3/10.
//

import Foundation

struct Stage: Codable {
	let directoryURL: URL
	let name: String
	let imageURL: URL?
	let description: String
	let chapters: [ChapterModel]
	
//	init(directoryURL: URL) {
//		// Order multiple stages by prefix each directory name with a number. Remove that number for stage name
//		let name = directoryURL.lastPathComponent
//		let index = name.firstIndex { !$0.isNumber } ?? name.startIndex
//		self.name = String(name[index...])
//		
//		self.directoryURL = directoryURL
//		self.imagePath = getImagePathInDirectory(url: directoryURL)
//	}
}
