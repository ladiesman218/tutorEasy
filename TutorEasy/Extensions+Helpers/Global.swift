//
//  Global.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/6/24.
//

import UIKit

//let serverURL = URL(string: "http://localhost:8080")!     //localhost
let serverURL = URL(string: "https://d4ed-2408-822a-1c16-8030-a420-3b90-18f6-3713.ngrok-free.app")!     //ngrok
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

let chapterPlaceHolder = Chapter(directoryURL: URL(fileURLWithPath: ""), name: "", isFree: false, pdfURL: URL(fileURLWithPath: ""), imageURL: nil)
let stagePlaceHolder = Stage(directoryURL: URL(fileURLWithPath: "/"), name: "", imageURL: nil, description: "", chapters: [chapterPlaceHolder] )
let coursePlaceHolder = Course(id: UUID(), name: "", description: "", price: 1, stages: [stagePlaceHolder], imageURL: nil, annuallyIAPIdentifier: "")
