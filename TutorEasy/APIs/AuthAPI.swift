import Foundation
import UIKit

enum AuthResult {
    case success
    case failure(reason: String)
}

struct AuthAPI {
    static let userEndPoint = baseURL.appendingPathComponent("user")
    
    static let keychainTokenKey = "Tutor-Easy-Token"
    static let keychainUsernameKey = "Tutor-Easy-username"
    static let keychainPasswordKey = "Tutor-Easy-password"
    
    
    static var userInfo: User.PublicInfo? {
        get {
            guard let savedData = UserDefaults.standard.object(forKey: "user-public-info") as? Data else {
                return nil
            }
            guard let decodedUser = try? JSONDecoder().decode(User.PublicInfo.self, from: savedData) else {
                UserDefaults.standard.removeObject(forKey: "user-public-info")
                return nil
            }
            return decodedUser
        }
        
        set {
            if let encodedData = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encodedData, forKey: "user-public-info")
            } else {
                UserDefaults.standard.removeObject(forKey: "user-public-info")
            }
        }
    }
    
    static var tokenValue: String? {
        get {
            Keychain.load(key: AuthAPI.keychainTokenKey)
        }
        set {
            if let newToken = newValue {
                print("token new value: \(newToken)")
                Keychain.save(key: AuthAPI.keychainTokenKey, data: newToken)
            } else {
                print("token value set to nil")
                Keychain.delete(key: AuthAPI.keychainTokenKey)
            }
        }
    }
    
    static func register(registerInput: User.RegisterInput, completion: @escaping (AuthResult) -> Void) {
        var request = URLRequest(url: Self.userEndPoint.appendingPathComponent("register"))
        request.httpMethod = "POST"
        guard let jsonData = try? JSONEncoder().encode(registerInput) else {
            fatalError("Encode register input failed")
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Here we are dealing with the dataTask error, in other words, connection error, eg: server not running or connenction timed-out, etc.
            if let error = error {
                let errorMessage: String
#warning("Add more possible error messages")
                switch error.localizedDescription {
                case "Connection Error":
                    errorMessage = "无法连接服务器，请检查设备网络，或联系管理员\(adminEmail)"
                default:
                    errorMessage = error.localizedDescription
                }
                
                DispatchQueue.main.async {
                    completion(.failure(reason: errorMessage))
                }
                
                return
            }
            
            // Make sure dataTask has returned some sort of data, if the server ever reponds, this should always be the case.
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(reason: "未知错误，请联系管理员\(adminEmail)"))
                }
                return
            }
            
            // Check if server returned an error response
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let responseError = try? decoder.decode(ResponseError.self, from: data) {
                DispatchQueue.main.async {
                    completion(.failure(reason: responseError.reason))
                }
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 201 else {
                DispatchQueue.main.async {
                    completion(.failure(reason: "未知错误，请联系管理员\(adminEmail)"))
                }
                return
            }
            
            // Here means register is successful, automatically login the user.
            login(username: registerInput.username, password: registerInput.password1) { loginResult in
                switch loginResult {
                case .success:
                    DispatchQueue.main.async {
                        completion(.success)
                    }
                case .failure(let reason):
                    DispatchQueue.main.async {
                        completion(.failure(reason: reason))
                    }
                }
            }
        }
        
        task.resume()
    }
    
    static func login(username: String, password: String, completion: @escaping (AuthResult) -> Void) {
        var req = URLRequest(url: Self.userEndPoint.appendingPathComponent("login"))
        
        guard let loginString = "\(username):\(password)".data(using: .utf8)?.base64EncodedString() else {
            fatalError("Failed to encode login credentials")
        }
        
        req.addValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
        req.httpMethod = "POST"
        
        let dataTask = URLSession.shared.dataTask(with: req) { data, response, error in
            
            // Here we are dealing with the connection error, eg: server not running or timeout, etc
            if let error = error {
                DispatchQueue.main.async { completion(.failure(reason: error.localizedDescription)) }
                return
            }
            
            // Make sure dataTask has returned some sort of data, if the server ever reponds, this should always be the case.
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(reason: "未知错误，请联系管理员\(adminEmail)")) }
                return
            }
            
            // Check if server returned an error response
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let responseError = try? decoder.decode(ResponseError.self, from: data) {
                DispatchQueue.main.async { completion(.failure(reason: responseError.reason)) }
                return
            }
            
            let token: Token
            do {
                token = try decoder.decode(Token.self, from: data)
                self.tokenValue = token.value
                Keychain.save(key: keychainUsernameKey, data: username)
                Keychain.save(key: keychainPasswordKey, data: password)
                
                // This saves user's public info into UserDefaults, which will be used later in application process.
                
            } catch {
                // Here we are dealing with decoding errors, which should never happen
                DispatchQueue.main.async { completion(.failure(reason: "解码错误，请联系管理员\(adminEmail)")) }
            }
        }
        dataTask.resume()
    }
    
    static func logout(completion: @escaping (AuthResult) -> Void) {
        var req = URLRequest(url: Self.userEndPoint.appendingPathComponent("logout"))
        req.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: req) { _, response, _ in
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                DispatchQueue.main.async { completion(.failure(reason: "退出登录错误")) }
                return
            }
            
            tokenValue = nil
            UserDefaults.standard.removeObject(forKey: "user-public-info")
            DispatchQueue.main.async { completion(.success) }
        }
        
        task.resume()
    }
    
    static func getPublicUserFromToken(completion: @escaping (User.PublicInfo?, URLResponse?, ResponseError?) -> Void) {
        guard let tokenValue = tokenValue else {
            completion(nil, nil, .init(error: true, reason: "未找到令牌"))
            return
        }
        
        let url = userEndPoint.appendingPathComponent("token").appendingPathComponent("user-public")
        
        URLSession.shared.userFromTokenTask(with: url, tokenValue: tokenValue) { userInfo, response, error in
            if let error = error {
                completion(nil, response, error)
                return
            }
            
            self.userInfo = userInfo!
            completion(userInfo!, response, nil)
            
        }.resume()
    }
    
//    static func getPublicUserFromToken(completion: @escaping (AuthResult) -> Void) {
//
//        guard let tokenValue = tokenValue else {
//            completion(.failure(reason: "未找到令牌"))
//            return
//        }
//
//        var req = URLRequest(url: userEndPoint.appendingPathComponent("token").appendingPathComponent("user-public"))
//        req.httpMethod = "GET"
//
//        req.addValue("Bearer \(tokenValue)", forHTTPHeaderField: "Authorization")
//
//        URLSession.shared.dataTask(with: req) { data, response, error in
//            if let error = error {
//                DispatchQueue.main.async { completion(.failure(reason: error.localizedDescription)) }
//                return
//            }
//
//            guard let data = data else {
//                DispatchQueue.main.async { completion(.failure(reason: "服务器错误，请联系管理员\(adminEmail)")) }
//                return
//            }
//
//            // Check if server returned an error response
//            let decoder = JSONDecoder()
//            decoder.dateDecodingStrategy = .iso8601
//            if let responseError = try? decoder.decode(ResponseError.self, from: data) {
//                self.tokenValue = nil
//                userInfo = nil
//                DispatchQueue.main.async { completion(.failure(reason: responseError.reason)) }
//                return
//            }
//
//            do {
//                userInfo = try decoder.decode(User.PublicInfo.self, from: data)
//            } catch {
//                DispatchQueue.main.async { completion(.failure(reason: "解码错误，请联系管理员\(adminEmail)")) }
//                return
//            }
//
//            DispatchQueue.main.async { completion(.success) }
//        }.resume()
//    }
}

