//
//  FileAPI.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/11/6.
//

import Foundation
import UIKit



struct FileAPI {
    static let publicFileEndPoint = baseURL.appendingPathComponent("file")
    
	static func getFile(path: String) async -> Result<Data, Error> {
		let url = publicFileEndPoint.appendingPathComponent(path, isDirectory: false)
		
		do {
			let (data, response) = try await URLSession.shared.dataAndResponse(from: url)
			// In this case, server probably won't return a error if there is one, so check for response's status code instead.
			guard response.statusCode == 200 else {
				throw ResponseError(reason: "无法读取文件")
			}
			return .success(data)
		} catch {
			return .failure(error)
		}
	}
//    static func getFile(path: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
//
//        let request = URLRequest(url: publicFileEndPoint.appendingPathComponent(path, isDirectory: false))
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            // In this case, server probably won't return a error if there is one, so check for response's status code instead.
//            guard let data = data, error == nil, let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200 else {
//                DispatchQueue.main.async {
//                    completionHandler(nil, response, error)
//                }
//                return
//            }
//            DispatchQueue.main.async {
//                completionHandler(data, response, nil)
//            }
//        }.resume()
//    }
    
}
