//
//  URLSession + Extension.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/3.
//

import Foundation


extension URLSession {
    fileprivate func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, ResponseError?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: url) { data, response, error in
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
    
    func languageTask(with url: URL, completionHandler: @escaping (Language.PublicInfo?, URLResponse?, ResponseError?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, completionHandler: completionHandler)
    }
    
    func languagesTask(with url: URL, completionHandler: @escaping ([Language.PublicInfo]?, URLResponse?, ResponseError?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, completionHandler: completionHandler)
    }
}
