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
	// Server responds image url with file:// scheme, generate a url request from it, which is of type http request.
	static func convertToImageRequest(url: URL) -> URLRequest {
		let path = url.path
		let url = publicImageEndPoint.appendingPathComponent(path, isDirectory: false)
		let request = URLRequest(url: url)
		return request
	}
	
	// Pass in size enables the ability to resize the image inside this function, and saves the resized image data for the response cache, which in most cases should be smaller than the actual image returned from server hence saves some caching space.
	static func publicGetImageData(url: URL?, size: CGSize) async -> UIImage? {
		guard let url = url else {
			// Generate a image if imageURL is nil
			let image = UIColor.blue.convertToImage(size: size)
			return image
		}
		
		let req = FileAPI.convertToImageRequest(url: url)
		do {
			// If a cached response exists, server will respond 304 not modified for the request, cached data will be used for the image. Nothing needs to be done on client side, other than create the data task in cachedSession.
			// When dataTask throws, it will go to catch block immediately, later steps won't be processed.
			let (data, response) = try await cachedSession.dataAndResponse(for: req)

			guard let image = UIImage(data: data) else {
				#if DEBUG
				print("\(response.statusCode) for \(url.path)")
				#endif
				let responseError = ResponseError(reason: "图片获取失败")
				throw responseError
			}
			// It's possible the image is returned from cache, if so, check if it's size is equal to the passed in parameter. If it's equal, return the image and bail out. If not, resize the image, save it's data in cache for the request.
			guard image.size != size else { return image }
			
			// In case resize fails, return original image
			guard let resizedImage = image.resizedImage(with: size) else { return image }
			
			// Convert data to resized image data, save space for storing cachedResponse. In case this fails, return the origin image. At this stage, response has been saved in cache already.
			guard let resizedData = resizedImage.jpegData(compressionQuality: 1.0) else {
				return resizedImage
			}
			
			// Here means cached data is not equal to resizedData, save it to cache.
			//			print("before: \(cachedSession.configuration.urlCache?.cachedResponse(for: request)?.data.count)")
			let cachedResponse = CachedURLResponse(response: response, data: resizedData)
			cachedSession.configuration.urlCache?.storeCachedResponse(cachedResponse, for: req)
			//			print("after: \(cachedSession.configuration.urlCache?.cachedResponse(for: request)?.data.count)")
			return resizedImage
		} catch {
			// We'll be checking image's value in datasource to decide if a loading task is needed, when task is cancelled, return nothing so if needed, same task can be re-start later.
			guard !Task.isCancelled else { return nil }
			let image = UIColor.blue.convertToImage(size: size)
			return image
		}
	}

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
