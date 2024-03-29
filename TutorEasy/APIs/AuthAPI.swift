import Foundation
import UIKit

struct AuthAPI {
	static let userEndPoint = baseURL.appendingPathComponent("user")
	
	static let keychainTokenKey = "Tutor-Easy-Token"
	static let keychainUsernameKey = "Tutor-Easy-username"
	static let keychainPasswordKey = "Tutor-Easy-password"
	static let userDefaultsPublicInfoKey = "user-public-info"
	
	static var userInfo: User.PublicInfo? {
		get {
			if let savedData = UserDefaults.standard.object(forKey: userDefaultsPublicInfoKey) as? Data,
			   let decodedUser = try? Decoder.isoDate.decode(User.PublicInfo.self, from: savedData) {
				return decodedUser
			}
			return nil
		}
		
		set {
			if newValue == nil {
				print("userInfo set to nil")
				UserDefaults.standard.removeObject(forKey: userDefaultsPublicInfoKey)
			} else if let encodedData = try? Encoder.isoDate.encode(newValue) {
				print("userInfo set to \(newValue!)")
				
				UserDefaults.standard.set(encodedData, forKey: userDefaultsPublicInfoKey)
			}
			// loginChanged Notification is observed by ProfileIconView, when received the notification, it will check if userInfo is nil, and update the profile icon and associated text accordingly, also the destination VC of clicking the icon depends on whether userInfo is nil
			NotificationCenter.default.post(name: loginChanged, object: nil)
		}
	}
	
	static var tokenValue: String? {
		get {
			return Keychain.load(key: AuthAPI.keychainTokenKey)
		}
		
		set {
			if let newToken = newValue {
				print("new token value: \(newToken)")
				Keychain.save(key: AuthAPI.keychainTokenKey, data: newToken)
				// If we get here, that means a new token is generated, get new user info automatically.
				Task {
					userInfo = try? await getPublicUserFromToken()
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
	
	// For registration endpoint, server either responds http status code 201(created) or throws an error.
	static func register(input:User.RegisterInput) async throws {
		var request = URLRequest(url: Self.userEndPoint.appendingPathComponent("register"))
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpMethod = "POST"
		
		let jsonData = try Encoder.isoDate.encode(input)
		request.httpBody = jsonData
		let _ = try await noCacheSession.dataAndResponse(for: request)
	}
	
	// For login, server either returns a token, or throws an error.
	static func login(username: String, password: String) async throws {
		var req = URLRequest(url: Self.userEndPoint.appendingPathComponent("login"))
		
		guard let loginString = "\(username):\(password)".data(using: .utf8)?.base64EncodedString() else {
			throw ResponseError(reason: "登录信息中包含无效字符")
		}
		req.addValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
		req.httpMethod = "POST"
		
		let (data, _) = try await noCacheSession.dataAndResponse(for: req)
		
		let token = try Decoder.isoDate.decode(Token.self, from: data)
		
		self.tokenValue = token.value
		Keychain.save(key: keychainUsernameKey, data: username)
		Keychain.save(key: keychainPasswordKey, data: password)
	}
	
	static func validateToken() async throws {
		guard let token = AuthAPI.tokenValue else {
			throw ResponseError(reason: "未登录")
		}
		
		var request = URLRequest(url: Self.userEndPoint.appendingPathComponent("validate"))
		request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		
		// For token validation, server either returns true false without throwing
		let data = try await noCacheSession.dataAndResponse(for: request).0
		let validated = try Decoder.isoDate.decode(Bool.self, from: data)
		if validated {
			return
		} else {
			throw ResponseError(reason: "登录信息已失效")
		}
	}
	
	static func logout() async {
		guard let tokenValue = tokenValue else {
			userInfo = nil
			return
		}
		
		var req = URLRequest(url: Self.userEndPoint.appendingPathComponent("logout"))
		req.addValue("Bearer \(tokenValue)", forHTTPHeaderField: "Authorization")
		req.httpMethod = "POST"
		
		// On server side, logout function already invalidate all tokens associated with the user by itself. Here set local tokenValue to nil has 2 purposes: 1. trigger loginChanged notification, so visible viewController will display correct info for login status. 2. During next launch, we will call getPublicUserFromToken to decide if login/register vc is gonna be pushed, without an tokenValue that method returns quicker than goes to server side.
		Self.tokenValue = nil
		
		do {
			// We don't care about response here, even if it's not 200, we've set tokenValue to nil anyway, essentially trigger logout behaviour locally. Get response and check its status code is only for testing purposes and see if there is any other possible errors.
			let response = try await noCacheSession.dataAndResponse(for: req).1
			if response.statusCode != 200 {
				throw ResponseError(reason: "登出错误")
			}
		} catch {
			print(error)
		}
	}
	
	static func getPublicUserFromToken() async throws -> User.PublicInfo {
		
		var req = URLRequest(url: userEndPoint.appendingPathComponent("public-info"))
		req.addValue("Bearer \(tokenValue ?? "")", forHTTPHeaderField: "Authorization")
		
		let (data, _) = try await noCacheSession.dataAndResponse(for: req)
		let userInfo = try Decoder.isoDate.decode(User.PublicInfo.self, from: data)
		return userInfo
	}
	
	static func fetchValidOrders() async throws {
		let url = baseURL.appendingPathComponent("order").appendingPathComponent("valid")
		var request = URLRequest(url: url)
		
		request.addValue("Bearer \(tokenValue ?? "")", forHTTPHeaderField: "Authorization")

		let (data, _) = try await cachedSession.dataAndResponse(for: request)
		let orders = try Decoder.isoDate.decode([Order].self, from: data)
		Self.orders = orders
	}
}
