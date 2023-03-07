//
//  LanguageAPI.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/9/21.
//

import Foundation

struct LanguageAPI {
	
	private static let publicLanguageEndPoint = baseURL.appendingPathComponent("language")
	static func getLanuage(id: UUID) async -> Result<Language, Error> {
		let url = publicLanguageEndPoint.appendingPathComponent(id.uuidString)
		
		do {
			let (data, _) = try await URLSession.shared.dataAndResponse(from: url)
			let language = try Decoder.isoDate.decode(Language.self, from: data)
			return .success(language)
		} catch {
			return .failure(error)
		}
	}
//	static func getLanguage(id: UUID, completionHandler: @escaping (Language?, URLResponse?, ResponseError?) -> Void) {
//
//		let req = URLRequest(url: publicLanguageEndPoint.appendingPathComponent(id.uuidString))
//		URLSession.shared.languageTask(with: req, completionHandler: { language, response, error in
//			guard let language = language, error == nil else {
//				completionHandler(nil, response, error!)
//				return
//			}
//
//			completionHandler(language, response, nil)
//		}).resume()
//	}
	
	static func getAllLanguges() async -> Result<[Language], Error> {
		
		do {
			let (data, _) = try await URLSession.shared.dataAndResponse(from: publicLanguageEndPoint)
			let languages = try Decoder.isoDate.decode([Language].self, from: data)
			return .success(languages)
		} catch {
			return .failure(error)
		}
	}
//	static func getAllLanguages(completionHandler: @escaping ([Language]?, URLResponse?, ResponseError?) -> Void) {
//		let req = URLRequest(url: publicLanguageEndPoint)
//		URLSession.shared.languagesTask(with: req) { languages, response, error in
//			guard let languages = languages, error == nil else {
//				completionHandler(nil, response, error!)
//				return
//			}
//
//			completionHandler(languages, response, nil)
//		}.resume()
//	}
	
}
