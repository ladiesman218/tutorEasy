//
//  URLSession + requestWithToken.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/1/27.
//

import Foundation

public enum HTTPMethod: String {
	case post = "POST"
	case get = "GET"
}

extension URLSession {
	// Make a request from the given URL, used to get data and responses back
	public func requestWithToken(url: URL, httpMethod: HTTPMethod = .get) async throws -> (Data, HTTPURLResponse) {
		// For files, server response urls with file scheme, replace the url with a http scheme, or the force casting of response to httpResponse will fail
		var request = URLRequest(url: url)
		request.httpMethod = httpMethod.rawValue
		if let token = AuthAPI.tokenValue {
			request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		}
		
		let (data, response) = try await Self.shared.data(for: request)
		
		// When server stopped, reponse status code will be 502, when accessing a wrong endpoint, response code will be 404, with returned data of type ResponseError
		let httpResponse = response as! HTTPURLResponse
		
		return (data, httpResponse)
	}
		
	public func dataAndResponse(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
		let (data, response) = try await Self.shared.data(for: request)
		let httpResponse = response as! HTTPURLResponse
		// In case server respond with data that can be converted to ResponseError, throw that first
		if let responseError = try? Decoder.isoDate.decode(ResponseError.self, from: data) {
			throw responseError
		}
		
		// In case server can not be connected, throw ResponseError that user can understand, instead of saying "The data couldn’t be read because it is missing."
		if httpResponse.statusCode >= 500 {
			throw ResponseError(reason: "服务器错误，请检查设备网络，或联系管理员\(adminEmail)")
		}
		// If everything works, return data with response, in case we need the response for future usage
		return (data, httpResponse)
	}
}
