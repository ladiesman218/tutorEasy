//
//  Global.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/6/24.
//

import UIKit
import SkeletonView

//let serverURL = URL(string: "http://localhost:8080")!     //localhost and docker production environment
//let serverURL = URL(string: "https://tutoreasy.mleak.top")!		// Gigsgigs
let serverURL = URL(string: "https://warthog-fitting-purely.ngrok-free.app")!     //ngrok

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

let failedImage = UIImage(named: "load-failed.png")!

let placeHolderNumber = 8
let placeHolderURL = URL(fileURLWithPath: "/")
let placeHolderChapter = Chapter(directoryURL: placeHolderURL, name: "", isFree: false, pdfURL: placeHolderURL, bInstructionURL: nil, teachingPlanURL: nil, sstURL: nil, imageURL: nil)
let failedURL = URL(fileURLWithPath: "")
let failedChapter = Chapter(directoryURL: failedURL, name: " ", isFree: false, pdfURL: failedURL, bInstructionURL: nil, teachingPlanURL: nil, sstURL: nil, imageURL: nil)

let placeHolderStage = Stage(directoryURL: placeHolderURL, name: "", description: " ", imageURL: nil, chapterURLs: [] )
let failedStage = Stage(directoryURL: failedURL, name: " ", description: "  ", imageURL: nil, chapterURLs: [])
let placeHolderCourse = Course(id: UUID(), name: "", description: "", price: 1, stageURLs: [], imageURL: nil, annuallyIAPIdentifier: "")
let failedCourse = Course(id: UUID(), name: " ", description: " ", price: 1.1, stageURLs: [], imageURL: nil, annuallyIAPIdentifier: "")

let skeletonAnimation = GradientDirection.topLeftBottomRight.slidingAnimation()
let skeletonGradient = SkeletonGradient(baseColor: .asbestos, secondaryColor: .clouds)
