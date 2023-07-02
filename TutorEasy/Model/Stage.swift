//
//  Stage.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/3/10.
//

import UIKit

class StageModel: Codable {
	let directoryURL: URL
	let name: String
	let description: String
	let imageURL: URL?
	let chapterURLs: [URL]
	
	init(directoryURL: URL, name: String, description: String, imageURL: URL?, chapterURLs: [URL]) {
		self.directoryURL = directoryURL
		self.name = name
		self.description = description
		self.imageURL = imageURL
		self.chapterURLs = chapterURLs
	}
}

class Stage: StageModel, Equatable {
	static func == (lhs: Stage, rhs: Stage) -> Bool {
		lhs.directoryURL == rhs.directoryURL
	}

	var image: UIImage? = nil
}
