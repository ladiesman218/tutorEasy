//
//  TutorEasy
//
//  Created by Lei Gao on 2022/12/30.
//

import Foundation

struct CourseCache: Codable {
	let id: UUID
	let name: String
	let description: String
	let price: Double
	let iapIdentifier: String?
}
