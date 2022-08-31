//
//  ResponseError.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/8/16.
//

import Foundation

struct ResponseError: Error, Decodable {
	let error: Bool
	let reason: String
}
