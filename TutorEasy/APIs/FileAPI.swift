//
//  FileAPI.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/11/6.
//

import Foundation
import UIKit



struct FileAPI {
    static let publicImageEndPoint = baseURL.appendingPathComponent("image")
	static let contentEndPoint = baseURL.appendingPathComponent("content")

	static func publicGetImageData(path: String) async -> Result<Data, Error> {
		let url = publicImageEndPoint.appendingPathComponent(path, isDirectory: false)
		
		do {
			let (data, response) = try await URLSession.shared.dataAndResponse(from: url)
			// In this case, server probably won't return a error if there is one, so check for response's status code instead.
			guard response.statusCode == 200 else {
				throw ResponseError(reason: "无法获取图片")
			}
			return .success(data)
		} catch {
			return .failure(error)
		}
	}
	
	static func getCourseContent(path: String) async -> Result<Data, Error> {
		let url = contentEndPoint.appendingPathComponent(path, isDirectory: false)
		
		do {
			let (data, response) = try await URLSession.shared.dataAndResponse(from: url)
			
			return .success(data)
		} catch {
			if let error = error as? ClientError {
				print(error.localizedDescription)
			}
			return .failure(ResponseError(reason: error.localizedDescription))
		}
	}
}
