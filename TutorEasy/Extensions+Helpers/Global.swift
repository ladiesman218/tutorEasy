//
//  Global.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/6/24.
//

import UIKit

//let serverURL = URL(string: "http://localhost:8080")!     //localhost
let serverURL = URL(string: "https://32be-1-25-48-244.jp.ngrok.io")!     //ngrok
//let serverURL = URL(string: "http://0.0.0.0:8080")!     // docker production environment

let baseURL = serverURL.appendingPathComponent("api")

enum ImageName: String, CaseIterable {
	case image
	case banner
}

enum ImageExtension: String, CaseIterable {
	case png
	case jpg
	case jpeg
}

//let courseRoot = URL(string: "../Courses")!
let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
let phoneNumberRegex = "^([+](\\d{1,3}|\\d{1,2}[- ]{1,}\\d{3,4})[- ]{1,}){0,1}\\d{5,20}$"
let userNameLength = Range(4...35)
let nameLength = Range(3...40)
let passwordLength = Range(6...40)
let adminEmail = "chn_dunce@126.com"
let loginChanged: Notification.Name = .init(rawValue: "login-status-changed")


let borderColor: CGColor = UIColor.systemGray.cgColor
let textColor = UIColor.systemBlue
let backgroundColor = UIColor.systemBackground
let placeholderForNumberOfCells = 20

let cornerRadiusMultiplier = 0.1

enum Decoder {
	static var isoDate: JSONDecoder {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		return decoder
	}
}

enum Encoder {
	static var isoDate: JSONEncoder {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		return encoder
	}
}

let languagePlaceHolder = Language(id: UUID(), name: "", description: "", price: 1, courses: [], directoryURL: URL(fileURLWithPath: ""), imagePath: nil, annuallyIAPIdentifer: "")
let coursePlaceHolder = Course(id: UUID(), name: "", description: "", directoryURL: URL(fileURLWithPath: ""), imagePath: nil, freeChapters: [], chapters: [])
let chapterPlaceHolder = Chapter(directoryURL: URL(fileURLWithPath: ""), name: "", pdfURL: nil, imagePath: nil)
