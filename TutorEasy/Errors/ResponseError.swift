//
//  ResponseError.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/8/16.
//

import Foundation

struct ResponseError: Error, Decodable {
	var error: Bool = true
	var reason: String
}

