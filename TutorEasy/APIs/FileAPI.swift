//
//  FileAPI.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/11/6.
//

import UIKit

// In requestWithToken function we force casted server returned URLResponse to HTTPURLResponse. With a url with file scheme(which is what our server responses for file urls currently), the force casting will fail and cause the app crashing. Here we generate the url from scratch, which makes sure it will always be a http request.
struct FileAPI {
	static let publicImageEndPoint = baseURL.appendingPathComponent("image")
	static let contentEndPoint = baseURL.appendingPathComponent("content")
	
	static func publicGetImageData(path: String) async throws -> UIImage {
		// Generate http url scheme
		let url = publicImageEndPoint.appendingPathComponent(path, isDirectory: false)
		
		let (data, _) = try await cachedSession.dataAndResponse(from: url)
		guard let image = UIImage(data: data) else {
			throw ResponseError(reason: "图片文件损坏，请联系管理员\(adminEmail)")
		}
		return image
		
	}
	
	static func getCourseContent(path: String, for chapter: Chapter) async throws -> (Data, HTTPURLResponse) {
		// Generate http url scheme
		let url = contentEndPoint.appendingPathComponent(path, isDirectory: false)
		// If it's a free chapter, call funciton without token otherwise it will fail
		if chapter.isFree {
			return try await cachedSession.dataAndResponse(from: url)
		}
		
		return try await cachedSession.requestWithToken(from: url)
	}
}
