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
	static let userDefaultsPublicInfoKey = "user-public-info"
    
    static var userInfo: User.PublicInfo? {
		get {
			if let savedData = UserDefaults.standard.object(forKey: userDefaultsPublicInfoKey) as? Data,
			   let decodedUser = try? JSONDecoder().decode(User.PublicInfo.self, from: savedData) {
				return decodedUser
			}
			return nil
		}
        
        set {
            if newValue == nil {
            print("userInfo set to nil")
                UserDefaults.standard.removeObject(forKey: userDefaultsPublicInfoKey)
            } else if let encodedData = try? JSONEncoder().encode(newValue) {
                print("userInfo set to \(newValue!)")

                UserDefaults.standard.set(encodedData, forKey: userDefaultsPublicInfoKey)
            }
			// loginChanged Notification is observed by ProfileIconView, when received the notification, it will check if userInfo is nil, and update the profile icon and associated text accordingly, also the destination VC of clicking the icon depends on whether userInfo is nil
            NotificationCenter.default.post(name: loginChanged, object: nil)
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
                // If we get here, that means a new token is generated, get new user info automatically.
                getPublicUserFromToken { userInfo, _, _ in
                    guard let info = userInfo else { fatalError() }
                    self.userInfo = info
                }
            } else {
                print("token value set to nil")
                Keychain.delete(key: AuthAPI.keychainTokenKey)
                self.userInfo = nil
            }
        }
    }
	
	static var orders = [Order]() {
		didSet {
			print(orders)
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
            
            DispatchQueue.main.async { completion(.success) }
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
        
        URLSession.shared.dataTask(with: req) { data, response, error in
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
                DispatchQueue.main.async { completion(.success) }
            } catch {
                // Here we are dealing with decoding errors, which should never happen
                DispatchQueue.main.async { completion(.failure(reason: "解码错误，请联系管理员\(adminEmail)")) }
            }
        }.resume()
    }
    
    static func logout(completion: @escaping (AuthResult) -> Void) {
		guard let tokenValue = tokenValue else {
			// If no token value is found, we still generate a false success completion, essentially on caller side throw user back to LanguageListVC
			DispatchQueue.main.async { completion(.success) }
			return
		}
        var req = URLRequest(url: Self.userEndPoint.appendingPathComponent("logout"))
		req.addValue("Bearer \(tokenValue)", forHTTPHeaderField: "Authorization")
        req.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: req) { _, response, _ in
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                DispatchQueue.main.async { completion(.failure(reason: "退出登录错误")) }
                return
            }
            
			// On server side, logout function already invalidate all tokens associated with the user by itself. Here set local tokenValue to nil has 2 purposes: 1. trigger loginChanged notification, so languageListVC will display correct info for login status. 2. During next launch, we will call getPublicUserFromToken to decide if login/register vc is gonna be pushed, without an tokenValue that method returns quicker than goes to server side.
			Self.tokenValue = nil
            DispatchQueue.main.async { completion(.success) }
        }.resume()
    }
    
    static func getPublicUserFromToken(completion: @escaping (User.PublicInfo?, URLResponse?, ResponseError?) -> Void) {
        guard let tokenValue = tokenValue else {
            completion(nil, nil, .init(error: true, reason: "未找到令牌"))
            return
        }
        
        var req = URLRequest(url: userEndPoint.appendingPathComponent("public-info"))
        req.addValue("Bearer \(tokenValue)", forHTTPHeaderField: "Authorization")
        URLSession.shared.publicUserTask(with: req) { userInfo, response, error in
            if let error = error {
                completion(nil, response, error)
                return
            }
            completion(userInfo!, response, nil)
        }.resume()
    }
	
	static func fetchValidOrders() async throws {
		let url = baseURL.appendingPathComponent("order").appendingPathComponent("valid")
		var req = URLRequest(url: url)
		guard let token = AuthAPI.tokenValue else { return }
		req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		
		let (data, _) = try await URLSession.shared.data(for: req)
		let orders = try JSONDecoder().decode([Order].self, from: data)
		Self.orders = orders
	}
}

