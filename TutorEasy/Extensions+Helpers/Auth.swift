import Foundation
import UIKit

enum AuthResult {
	case success
	case failure
}

class Auth {
	static let keychainKey = "Tutor-Easy"
	
	static let baseURL = serverURL.appendingPathComponent("api")
	static let userEndPoint = baseURL.appendingPathComponent("user")
	
	static var token: String? {
		get {
			Keychain.load(key: Auth.keychainKey)
		}
		set {
			if let newToken = newValue {
				Keychain.save(key: Auth.keychainKey, data: newToken)
			} else {
				Keychain.delete(key: Auth.keychainKey)
			}
		}
	}
	
	static func logout() {
		token = nil
		DispatchQueue.main.async {
			let applicationDelegate = UIApplication.shared.delegate
			let rootController = AccountsVC(nibName: nil, bundle: nil) as UIViewController
			UIStoryboard(name: "Login", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginNavigation")
			applicationDelegate?.window??.rootViewController = rootController
		}
	}
	
	static func login(username: String, password: String, completion: @escaping (AuthResult) -> Void) {
		var req = URLRequest(url: Self.userEndPoint.appendingPathComponent("login"))

		guard let loginString = "\(username):\(password)".data(using: .utf8)?.base64EncodedString() else {
			fatalError("Failed to encode credentials")
		}
		
		req.addValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
		req.httpMethod = "POST"
		
		let dataTask = URLSession.shared.dataTask(with: req) { data, response, _ in

			guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let jsonData = data else {
				completion(.failure)
				return
			}
			do {
				let token = try JSONDecoder().decode(Token.self, from: jsonData)
				self.token = token.value
				completion(.success)
			} catch {
				completion(.failure)
			}
		}
		dataTask.resume()
	}
	
	
	static func register(registerInput: User.RegisterInput) {
		var request = URLRequest(url: Self.userEndPoint.appendingPathComponent("register"))
		request.httpMethod = "POST"
		guard let jsonData = try? JSONEncoder().encode(registerInput) else {
			fatalError("Encode register input failed")
		}
		
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = jsonData
		
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			
			guard let response = response as? HTTPURLResponse, response.statusCode == 201 else {
				fatalError("Unknown registration response")
			}
			
			guard let data = data, let registeredUser = try? JSONDecoder().decode(User.self, from: data) else {
				
				fatalError("Register failed")
			}
			
			// Here means registration is successful, redirect to the previous UI user was in, or account UI
//			Self.login(loginInput: .init(loginName: registerInput.username, password: registerInput.password1))
		}
		
		task.resume()
	}
}

