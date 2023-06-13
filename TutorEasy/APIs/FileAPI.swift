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
	
	static func convertToImageRequest(url: URL) -> URLRequest {
		let path = url.path
		let url = publicImageEndPoint.appendingPathComponent(path, isDirectory: false)
		let request = URLRequest(url: url)
		return request
	}
	
	// Pass in size enables the ability to resize the image inside this function, and saves the resized image data for the response cache, which in most cases are smaller than the actual image returned from server hence saves some caching space.
	static func publicGetImageData(request: URLRequest, size: CGSize) async throws -> UIImage {
		// If a cached response exists, server will respond 304 not modified for the request, cached data will be used for the image. Nothing needs to be done on client side, other than create the data task in cachedSession.
		let (data, response) = try await cachedSession.dataAndResponse(for: request)
		guard let image = UIImage(data: data) else {
			cachedSession.configuration.urlCache?.removeCachedResponse(for: request)
			throw ResponseError(reason: "图片文件损坏，请联系管理员\(adminEmail)")
		}

		// It's possible the image is returned from cache, if so, check if it's size is equal to the passed in parameter. If it's equal, return the image and bail out. If not, resize the image, save it's data in cache for the request.
		guard image.size != size else {
			return image
		}

		// In case resize fails, return original image
		guard let resizedImage = image.resizedImage(with: size) else {
			return image
		}
		
		// Conver data to resized image data, save space for storing cachedResponse. In case this fails, return the origin image. At this stage, request has been saved to cache already.
		guard let resizedData = resizedImage.jpegData(compressionQuality: 1.0) else {
			return resizedImage
		}
		// If cached data is not equal to resizedData, save it to cache.
		if let cachedData = cachedSession.configuration.urlCache?.cachedResponse(for: request)?.data, cachedData != resizedData {
//			print("before: \(cachedSession.configuration.urlCache?.cachedResponse(for: request)?.data.count)")
			cachedSession.configuration.urlCache?.removeCachedResponse(for: request)
			let cachedResponse = CachedURLResponse(response: response, data: resizedData)
			cachedSession.configuration.urlCache?.storeCachedResponse(cachedResponse, for: request)
//			print("after: \(cachedSession.configuration.urlCache?.cachedResponse(for: request)?.data.count)")
		}
		
		return resizedImage
	}
	
	#warning("The following method is no longer needed")
	static func publicGetImageData(path: String) async throws -> UIImage {
		// Generate http url scheme
		let url = publicImageEndPoint.appendingPathComponent(path, isDirectory: false)
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
