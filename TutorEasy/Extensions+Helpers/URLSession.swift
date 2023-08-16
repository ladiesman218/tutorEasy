//
//  URLSession + requestWithToken.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/1/27.
//

import Foundation

// This is a session that doesn't have a cache object so it won't take up any cache space at all.
var noCacheSession: URLSession = {
	let configuration = URLSessionConfiguration.default
	configuration.urlCache = nil	// Disable cache
	configuration.timeoutIntervalForRequest = 30
	let session = URLSession(configuration: configuration)
	return session
}()

var cachedSession: URLSession = {
	URLCache.shared.memoryCapacity = 1024 * 1024 * 20	// 20M
	URLCache.shared.diskCapacity = 1024 * 1024 * 500	//500 MB
	// For default sessions, the default value for configuration.urlCache is the shared URL cache object. No need to set that manually
	let configuration = URLSessionConfiguration.default
	configuration.timeoutIntervalForRequest = 30
	
	// .useProtocolCachePolicy is default for requestCachePolicy
	let session = URLSession(configuration: configuration)
	return session
}()

extension URLSession {
	
	public func dataAndResponse(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
		
		let (data, response) = try await data(for: request)
		try Task.checkCancellation()
		let httpResponse = response as! HTTPURLResponse
		
		return (data, httpResponse)
	}
	
	public func dataAndResponse(from url: URL) async throws -> (Data, HTTPURLResponse) {
		let request = URLRequest(url: url)
		
		return try await dataAndResponse(for: request)
	}
}
