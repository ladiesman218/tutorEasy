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
		URLCache.shared.removeAllCachedResponses()
//		print(URLCache.shared.currentDiskUsage / 1024 / 1024)
//		print(URLCache.shared.currentMemoryUsage / 1024 / 1024)
		
		
		// If a cached response exists, server will respond 304 not modified for the request, cached data will be used for the image. Nothing needs to be done on client side, other than create the data task in cachedSession.
		let (data, _) = try await cachedSession.dataAndResponse(from: url)
		guard let image = UIImage(data: data) else {
			cachedSession.configuration.urlCache?.removeCachedResponse(for: .init(url: url))
			throw ResponseError(reason: "图片文件损坏，请联系管理员\(adminEmail)")
		}
		return image
		
	}
	
	// This doesn't call URLSession extension's dataAndReponse, cause in that method we've converted all error to ResponseError, hence lost the HTTPURLResponse's status code, we need the status code to handle errors easier when calling getCourseContent()
	static func getCourseContent(path: String) async throws -> (Data, HTTPURLResponse) {
		// Generate http url scheme
		let url = contentEndPoint.appendingPathComponent(path, isDirectory: false)
		var request = URLRequest(url: url)
		request.addValue("Bearer \(AuthAPI.tokenValue ?? "")", forHTTPHeaderField: "Authorization")
		// For cached response, server will return "no-cache" for Cache-Control header, hence later requests will go to server first, only use cached data if user token validation has passed and server returns 304 not modified.
		let (data, response) = try await cachedSession.data(for: request)
		let urlResponse = response as! HTTPURLResponse
		
		return (data, urlResponse)
	}
}
