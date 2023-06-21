//
//  Chapter.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/11/6.
//

import UIKit

class ChapterModel: Codable {
    let directoryURL: URL
    let name: String
	let isFree: Bool
    let pdfURL: URL
	let bInstructionURL: URL?
	let teachingPlanURL: URL?
	let imageURL: URL?
	
	init(directoryURL: URL, name: String, isFree: Bool, pdfURL: URL, bInstructionURL: URL?, teachingPlanURL: URL?, imageURL: URL?) {
		self.directoryURL = directoryURL
		self.name = name
		self.isFree = isFree
		self.pdfURL = pdfURL
		self.bInstructionURL = bInstructionURL
		self.teachingPlanURL = teachingPlanURL
		self.imageURL = imageURL
	}
}

class Chapter: ChapterModel {
	var image: UIImage? = nil
}
