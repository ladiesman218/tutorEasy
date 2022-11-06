//
//  Chapter.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/11/6.
//

import Foundation

struct Chapter: Codable {
    let url: URL
    let name: String 
    let pdfPath: String?
    let imagePath: String?
}
