//
//  Chapter.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/11/6.
//

import Foundation

struct Chapter: Codable {
    let directoryURL: URL
    let name: String
    let pdfURL: URL?
    let imagePath: String?
}
