//
//  FileAPI.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/11/6.
//

import Foundation
import UIKit



struct FileAPI {
    static let publicImageEndPoint = baseURL.appendingPathComponent("image")
	static let contentEndPoint = baseURL.appendingPathComponent("content")

	static func publicGetImageData(path: String) async -> Result<Data, Error> {
		let url = publicImageEndPoint.appendingPathComponent(path, isDirectory: false)
		
		do {
			let (data, _) = try await URLSession.shared.requestWithToken(url: url)
			return .success(data)
		} catch {
			let error = error as! ResponseError
			return .failure(error)
		}
	}
	
	static func getCourseContent(path: String) async throws -> (Data, HTTPURLResponse) {
		// In requestWithToken function we force casted server returned URLResponse to HTTPURLResponse. With a url with file scheme(which is what our server responses for file urls currently), the force casting will fail and cause the app crashing. Here we generate the url from scratch, which makes sure it will always be a http request.
		let url = contentEndPoint.appendingPathComponent(path, isDirectory: false)

		return try await URLSession.shared.requestWithToken(url: url)
	}
}
