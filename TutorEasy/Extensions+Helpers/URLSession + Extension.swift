//
//  URLSession + Extension.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/3.
//

import Foundation


extension URLSession {
     func codableTask<T: Codable>(with url: URL, tokenValue: String? = nil, completionHandler: @escaping (T?, URLResponse?, ResponseError?) -> Void) -> URLSessionDataTask {
        var req = URLRequest(url: url)
        if let tokenValue = tokenValue {
            req.addValue("Bearer \(tokenValue)", forHTTPHeaderField: "Authorization")
        }
        return self.dataTask(with: req) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completionHandler(nil, response, ResponseError(error: true, reason: error!.localizedDescription))
                }
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(decodedData, response, nil)
                }                
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil, response, ResponseError(error: true, reason: "数据解析错误"))
                }
            }
        }
    }
    
    func languageTask(with url: URL, tokenValue: String? = nil, completionHandler: @escaping (Language.PublicInfo?, URLResponse?, ResponseError?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, tokenValue: tokenValue, completionHandler: completionHandler)
    }
    
    func languagesTask(with url: URL, tokenValue: String? = nil, completionHandler: @escaping ([Language.PublicInfo]?, URLResponse?, ResponseError?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, tokenValue: tokenValue, completionHandler: completionHandler)
    }
    
    func userFromTokenTask(with url: URL, tokenValue: String, completionHandler: @escaping (User.PublicInfo?, URLResponse?, ResponseError?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, tokenValue: tokenValue, completionHandler: completionHandler)
    }
}
