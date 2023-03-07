import Foundation
import UIKit

//enum AuthResult {
//	case success
//	case failure(reason: String)
//}

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
					userInfo = try? await getPublicUserFromToken().get()
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
	
	static func register(input:User.RegisterInput) async -> Result<HTTPURLResponse, Error> {
		var request = URLRequest(url: Self.userEndPoint.appendingPathComponent("register"))
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpMethod = "POST"
		
		do {
			let jsonData = try Encoder.isoDate.encode(input)
			request.httpBody = jsonData
			let (_, response) = try await URLSession.shared.dataAndResponse(for: request)
			return .success(response)
		} catch {
			return .failure(error)
		}

	}
	
	static func login(username: String, password: String) async -> Result<Void, Error> {
		var req = URLRequest(url: Self.userEndPoint.appendingPathComponent("login"))
		
		guard let loginString = "\(username):\(password)".data(using: .utf8)?.base64EncodedString() else {
			return .failure(ResponseError(reason: "登录信息中包含无效字符"))
		}
		req.addValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
		req.httpMethod = "POST"

		do {
			let (data, _) = try await URLSession.shared.dataAndResponse(for: req)

			let token = try Decoder.isoDate.decode(Token.self, from: data)
			
			self.tokenValue = token.value
			Keychain.save(key: keychainUsernameKey, data: username)
			Keychain.save(key: keychainPasswordKey, data: password)
			return .success(())
		} catch {
			return .failure(error)
		}
		
	}
	
	static func logout() async -> Result<Void, Error> {
		guard let tokenValue = tokenValue else {
			userInfo = nil
			return .success(())
		}
		var req = URLRequest(url: Self.userEndPoint.appendingPathComponent("logout"))
		req.addValue("Bearer \(tokenValue)", forHTTPHeaderField: "Authorization")
		req.httpMethod = "POST"
		
		// On server side, logout function already invalidate all tokens associated with the user by itself. Here set local tokenValue to nil has 2 purposes: 1. trigger loginChanged notification, so languageListVC will display correct info for login status. 2. During next launch, we will call getPublicUserFromToken to decide if login/register vc is gonna be pushed, without an tokenValue that method returns quicker than goes to server side.
		Self.tokenValue = nil
		
		do {
			// We don't care about response here, even if it's not 200, we've set tokenValue to nil anyway, essentially trigger logout behaviour locally. Get response and check its status code is only for testing purposes and see if there is any other possibilities.
			let response = try await URLSession.shared.dataAndResponse(for: req).1
			guard response.statusCode == 200 else { return .failure(ResponseError(reason: "登出错误"))}
			return .success(())
		} catch {
			return .failure(error)
		}
	}

	static func getPublicUserFromToken() async -> Result<User.PublicInfo, Error> {
		guard let tokenValue = tokenValue else {
			return .failure(ResponseError(reason: "未找到令牌"))
		}
		
		var req = URLRequest(url: userEndPoint.appendingPathComponent("public-info"))
		req.addValue("Bearer \(tokenValue)", forHTTPHeaderField: "Authorization")
		
		do {
			let (data, _) = try await URLSession.shared.dataAndResponse(for: req)
			let userInfo = try Decoder.isoDate.decode(User.PublicInfo.self, from: data)
			return .success(userInfo)
		} catch {
			return .failure(error)
		}
	}

	static func fetchValidOrders() async -> Result<Void, Error> {
		let url = baseURL.appendingPathComponent("order").appendingPathComponent("valid")
		var req = URLRequest(url: url)
		guard let token = AuthAPI.tokenValue else { return .failure(ResponseError(reason: "未找到令牌")) }
		req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		
		do {
			let (data, _) = try await URLSession.shared.dataAndResponse(for: req)
			let orders = try Decoder.isoDate.decode([Order].self, from: data)
			Self.orders = orders
			return .success(())
		} catch {
			return .failure(error)
		}
	}
}
