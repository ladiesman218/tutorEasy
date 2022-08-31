//
//  AbortableError.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/8/12.
//

import Foundation

protocol AbortError: Error {
	var reason: String {
		get
	}
}
