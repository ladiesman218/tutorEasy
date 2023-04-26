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
	configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
	configuration.urlCache = nil
	let session = URLSession(configuration: configuration)
	return session
}()

var cachedSession: URLSession = {
	URLCache.shared.memoryCapacity = 1024 * 1024 * 20	// 20M
	URLCache.shared.diskCapacity = 1024 * 1024 * 500	//500 MB

	// For default sessions, the default value is the shared URL cache object. No need to set configuration.urlCache manually
	let configuration = URLSessionConfiguration.default
	// .useProtocolCachePolicy is default🌚
	configuration.requestCachePolicy = .useProtocolCachePolicy
	let session = URLSession(configuration: configuration)
	return session
}()

extension URLSession {
	
	/// This method convert server error to ResponseError and throws them if there is one. It also convert the returned URLResponse to HTTPURLResponse. If everything works, it saves a cachedResponse for the request, and return the cached version when called later.
	/// - Parameter request: The URLRequest for receiving data and response.
	/// - Returns: Data and the response, only if non error is thrown.
	public func dataAndResponse(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
		if let cachedResponse = self.configuration.urlCache?.cachedResponse(for: request) {
			print("Using cached response for \(String(describing: request.url!))")
			return (cachedResponse.data, cachedResponse.response as! HTTPURLResponse)
		}
		
		let (data, response) = try await data(for: request)
		
		// When server stopped, reponse status code will be 502, when accessing a wrong endpoint, response code will be 404, with returned data of type ResponseError
		let httpResponse = response as! HTTPURLResponse
		
		// In case server respond with data that can be converted to ResponseError, throw that first
		if let responseError = try? Decoder.isoDate.decode(ResponseError.self, from: data) {
			throw responseError
		}
		
		// In case server can not be connected, throw ResponseError that user can understand, instead of saying "The data couldn’t be read because it is missing." Here we exclude 500 on purpose, since .internalServerError aka 500 is manually thrown on server side.
		if httpResponse.statusCode > 500 {
			throw ResponseError(reason: "服务器错误，请检查设备网络，或联系\(adminEmail)")
		}
		
		// Init and store the response's cache
		let cachedResponse = CachedURLResponse(response: response, data: data)
		self.configuration.urlCache?.storeCachedResponse(cachedResponse, for: request)
		
		// If everything works, return data with response, in case we need the response for future usage.
		return (data, httpResponse)
	}
		
	public func requestWithToken(for request : URLRequest) async throws -> (Data, HTTPURLResponse) {
		// AuthAPI.validateToken() is called from an unCachedSession, so it's guaranteed to validate from server side instead of using cachedResponse. If token validates successfully, nothing returns, so we can safely return cached data for the actual request later on. If validation fails, it throws errors indicate either the user hasn't logged in or the login has expired(new token for the user has been saved on server db, maybe due to same account logged in on another device), so we can redirect user to loginVC.
		try await AuthAPI.validateToken()
		// Since we have made sure token is validate, it's ok to return cachedResponse. Notice we still need to attach token in header, since on server side, some APIs are limited to authenticated user, and those APIs SHOULD NOT depend on token validation process called above. AuthAPI.validateToken() is called only because the follwing dataAndResponse(for: request) may return cachedReponse, we need to make sure user's credential is still valid since last time a successful cache was saved.
		var request = request
		request.addValue("Bearer \(AuthAPI.tokenValue ?? "")", forHTTPHeaderField: "Authorization")

		return try await dataAndResponse(for: request)
	}
	
	public func dataAndResponse(from url: URL) async throws -> (Data, HTTPURLResponse) {
		// For files, server response urls with file scheme, replace the url with a http scheme, or the force casting of response to httpResponse will fail
		let request = URLRequest(url: url)
		
		return try await dataAndResponse(for: request)
	}
	
	public func requestWithToken(from url: URL) async throws -> (Data, HTTPURLResponse) {
		try await AuthAPI.validateToken()
		// For files, server response urls with file scheme, replace the url with a http scheme, or the force casting of response to httpResponse will fail
		var request = URLRequest(url: url)
		request.addValue("Bearer \(AuthAPI.tokenValue ?? "")", forHTTPHeaderField: "Authorization")

		return try await dataAndResponse(for: request)
	}
}
