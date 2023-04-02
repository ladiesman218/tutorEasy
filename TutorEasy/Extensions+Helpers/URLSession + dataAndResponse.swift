//
//  URLSession + dataAndResponse.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/1/27.
//

import Foundation

extension URLSession {
	public func dataAndResponse(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
		let (data, response) = try await Self.shared.data(for: request)
		guard let httpResponse = response as? HTTPURLResponse else { fatalError() }
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
	
	public func dataAndResponse(from url: URL) async throws -> (Data, HTTPURLResponse) {
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		// Add token if there is one
		if let token = AuthAPI.tokenValue {
			request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		}
		let result = try await self.dataAndResponse(for: request)
		print(result.1.statusCode)
		guard result.1.statusCode != 401 else {
			throw ClientError.unauthorized
		}
		guard result.1.statusCode != 402 else {
			throw ClientError.paymentRequired
		}
		return result
//		return try await self.dataAndResponse(for: request)
	}
}
