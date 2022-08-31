//
//  APIHelper.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/6/23.
//

import UIKit
import Security

struct APIHelper {

	static let baseURL = serverURL.appendingPathComponent("api")
	static let userEndPoint = baseURL.appendingPathComponent("user")
	
	static func register(registerInput: User.RegisterInput) {
		var request = URLRequest(url: Self.userEndPoint.appendingPathComponent("register"))
		request.httpMethod = "POST"
		guard let jsonData = try? JSONEncoder().encode(registerInput) else {
			fatalError("Encode register input failed")
		}
		
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = jsonData
		
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			
			guard let response = response as? HTTPURLResponse, response.statusCode == 201 else {
				fatalError("Unknown registration response")
			}
			
//			guard let data = data, let registeredUser = try? JSONDecoder().decode(User.self, from: data) else {
//				fatalError("Register failed")
//			}
			
			// Here means registration is successful, redirect to the previous UI user was in, or account UI
//			Self.login(loginInput: .init(loginName: registerInput.username, password: registerInput.password1))
		}
		
		task.resume()
	}
	
//	static func login(loginInput: User.LoginInput) -> String? {
//		var req = URLRequest(url: Self.userEndPoint.appendingPathComponent("login"))
//		print(Self.userEndPoint.appendingPathComponent("login"))
//		req.httpMethod = "POST"
//
//
//		guard let loginString = "\(loginInput.loginName):\(loginInput.password)"
//			.data(using: .utf8)?
//			.base64EncodedString()
//		else {
//		  fatalError("Failed to encode credentials")
//		}
//
//		req.addValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
//
////		let dataTask = URLSession.shared.dataTask(with: req) { data, response, _ in
////		  guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let jsonData = data else {
////			completion(.failure)
////			return
////		  }
////
////		  do {
////			let token = try JSONDecoder().decode(Token.self, from: jsonData)
////			self.token = token.value
////			completion(.success)
////		  } catch {
////			completion(.failure)
////		  }
////		}
////		dataTask.resume()
//
//
//
//		var errorMessage: String?
//
//		let semaphore = DispatchSemaphore(value: 0)
//
//		let task = URLSession.shared.dataTask(with: req) { data, response, error in
//			// Here deals with server error, eg: server not running or timeout, etc.
//			if let error = error {
//				errorMessage = error.localizedDescription
//				semaphore.signal()
//
//				return
//			}
//
//			let user: User.PublicInfo
//			do {
//				user = try decodeData(data: data, type: User.PublicInfo.self)
//				// TODO: store userinfo somewhere on device
//				print(user.id)
//				semaphore.signal()
//			} catch {
//				// Here we are dealing with errors the server returns, eg: server may return "user not found" or something alike.
//				if let error = error as? ResponseError {
//					errorMessage = error.reason
//					semaphore.signal()
//				} else {
//					// This should never happen, it's here for future proof.
//					errorMessage = error.localizedDescription
//					semaphore.signal()
//				}
//				return
//			}
//		}
//
//		task.resume()
//		semaphore.wait()
//		return errorMessage
//	}
	
	static func decodeData<T: Decodable>(data: Data?, type: T.Type) throws -> T {
		
		guard let data = data else {
			let error = ResponseError(error: true, reason: "No data returned from the server")
			throw error
		}
		
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		
		if let error = try? decoder.decode(ResponseError.self, from: data) {
			// Check if server returned a error response
			throw error
		} else {
			do {
				let object = try decoder.decode(type, from: data)
				return object
			} catch {
				// Here means we can't either decode the response into ResponseError struct, or into a given T type, should not be happen at all but still here for future proof.
				throw error
			}
		}
		
	}
}
