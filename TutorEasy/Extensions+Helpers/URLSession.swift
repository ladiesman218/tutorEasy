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
		URLCache.shared.removeAllCachedResponses()
		// When Server is up and good, but client:
		// 1. Has 100% package loss, client gets url error, code -1200 or -1001(see a full list here `https://learn.microsoft.com/en-us/dotnet/api/foundation.nsurlerror?view=xamarin-mac-sdk-14`) indicates SSL error and connection can't be made or request timeout.
		// 2. Has very bad network, client gets 200 with all data, and same for better network
		// 3. Has 2G - poor or better, client got -1001
		
		// When server is down, client has good connection, client end gets 502 bad gateway
		// With ngrok up, server down, client got 502, when ngrok is also down, client got 404
		// With ngrok, when client side has googd network but server :
		// 1. 100% loss is equal to ngrok down, 404
		// 2. Very bad network got 200 and all data, but can't get images
		// 3. High latency DNS got 200 and all data including images
		let (data, response) = try await data(for: request)
		let httpResponse = response as! HTTPURLResponse
		try Task.checkCancellation()
		return (data, httpResponse)
	}
	
	public func dataAndResponse(from url: URL) async throws -> (Data, HTTPURLResponse) {
		let request = URLRequest(url: url)
		
		return try await dataAndResponse(for: request)
	}
}
