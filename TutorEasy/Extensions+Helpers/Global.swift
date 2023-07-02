//
//  Global.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/6/24.
//

import UIKit
import SkeletonView

//let serverURL = URL(string: "http://localhost:8080")!     //localhost and docker production environment
//let serverURL = URL(string: "https://app.douwone.xyz")!		// Gigsgigs
let serverURL = URL(string: "https://a3f3-2408-822a-1da3-7c60-4da7-69a1-40aa-30e7.ngrok-free.app")!     //ngrok

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

let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
let phoneNumberRegex = "^([+](\\d{1,3}|\\d{1,2}[- ]{1,}\\d{3,4})[- ]{1,}){0,1}\\d{5,20}$"
let userNameLength = Range(4...35)
let nameLength = Range(3...40)
let passwordLength = Range(6...40)
let adminEmail = "chn_dunce@126.com"
let loginChanged: Notification.Name = .init(rawValue: "login-status-changed")


let borderColor: CGColor = UIColor.systemGray.cgColor
let textColor = UIColor.systemBlue

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

let placeHolderNumber = 12
let placeHolderURL = URL(string: "/")!
let placeHolderChapter = Chapter(directoryURL: URL(fileURLWithPath: ""), name: "", isFree: false, pdfURL: URL(fileURLWithPath: ""), bInstructionURL: nil, teachingPlanURL: nil, imageURL: nil)
let placeHolderStage = Stage(directoryURL: URL(fileURLWithPath: "/"), name: "", description: "", imageURL: nil, chapterURLs: [] )
let placeHolderCourse = Course(id: UUID(), name: "", description: "", price: 1, stageURLs: [], imageURL: nil, annuallyIAPIdentifier: "")

let skeletonImageColor = UIColor.asbestos
let skeletonTitleColor = UIColor.amethyst
let skeletonAnimation = GradientDirection.topLeftBottomRight.slidingAnimation()
