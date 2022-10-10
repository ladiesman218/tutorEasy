//
//  LanguageAPI.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/9/21.
//

import Foundation

struct LanguageAPI {
	
	private static let publicLanguageEndPoint = baseURL.appendingPathComponent("language")
	
	static func getLanguage(id: UUID, completionHandler: @escaping (Language.PublicInfo?, URLResponse?, ResponseError?) -> Void) {
		
		let url = publicLanguageEndPoint.appendingPathComponent(id.uuidString)
		URLSession.shared.languageTask(with: url, completionHandler: { language, response, error in
			guard let language = language, error == nil else {
				completionHandler(nil, response, error)
				return
			}
			
			DispatchQueue.main.async {
				completionHandler(language, response, nil)
			}
		}).resume()
	}
	
	static func getAllLanguages(completionHandler: @escaping ([Language.PublicInfo]?, URLResponse?, ResponseError?) -> Void) {
		let url = publicLanguageEndPoint
		URLSession.shared.languagesTask(with: url) { languages, response, error in
			guard let languages = languages, error == nil else {
				completionHandler(nil, response, error)
				return
			}
			
			DispatchQueue.main.async {
				completionHandler(languages, response, nil)
			}
		}.resume()
	}
}
