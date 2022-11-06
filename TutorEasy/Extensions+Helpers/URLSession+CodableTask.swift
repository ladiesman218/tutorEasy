//
//  URLSession + Extension.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/3.
//

import Foundation


extension URLSession {
    fileprivate func codableTask<T: Codable>(with req: URLRequest, dispatchThread: DispatchQueue = .main, completionHandler: @escaping (T?, URLResponse?, ResponseError?) -> Void) -> URLSessionDataTask {

        return self.dataTask(with: req) { data, response, error in
            guard let data = data, error == nil else {
                dispatchThread.async {
                    completionHandler(nil, response, ResponseError(error: true, reason: error!.localizedDescription))
                }
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            if let responseError = try? decoder.decode(ResponseError.self, from: data) {
                dispatchThread.async {
                    completionHandler(nil, response, responseError)
                }
                return
            }
            
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                dispatchThread.async {
                    completionHandler(decodedData, response, nil)
                }                
            } catch {
                dispatchThread.async {
                    completionHandler(nil, response, ResponseError(error: true, reason: "数据解析错误"))
                }
            }
        }
    }
    
    func languageTask(with req: URLRequest, dispatchThread: DispatchQueue = .main, completionHandler: @escaping (Language?, URLResponse?, ResponseError?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: req, dispatchThread: dispatchThread, completionHandler: completionHandler)
    }
    
    func languagesTask(with req: URLRequest, dispatchThread: DispatchQueue = .main, completionHandler: @escaping ([Language]?, URLResponse?, ResponseError?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: req, dispatchThread: dispatchThread, completionHandler: completionHandler)
    }
    
    func publicUserTask(with req: URLRequest, dispatchThread: DispatchQueue = .main, completionHandler: @escaping (User.PublicInfo?, URLResponse?, ResponseError?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: req, dispatchThread: dispatchThread, completionHandler: completionHandler)
    }
    
    func coursesTask(with req: URLRequest, dispatchThread: DispatchQueue = .main, completionHandler: @escaping ([Course]?, URLResponse?, ResponseError?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: req, dispatchThread: dispatchThread, completionHandler: completionHandler)
    }
    
    func courseTask(with req: URLRequest, dispatchQueue: DispatchQueue = .main, completionHandler: @escaping (Course?, URLResponse?, ResponseError?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: req, completionHandler: completionHandler)
    }
    
    func pathsTask(with req: URLRequest, dispatchThread: DispatchQueue = .main, completionHandler: @escaping ([String]?, URLResponse?, ResponseError?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: req, completionHandler: completionHandler)
    }
}
