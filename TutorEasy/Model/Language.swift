import Foundation


struct Language: Codable {
	let id: UUID?
	let name: String
	let description: String
	let published: Bool
	let price: Double?
//	let courses: [Course]
	
	let path: URL
	let imageURL: URL?
	
	struct PublicInfo: Codable {
		let id: UUID
		let name: String
		let description: String
		let price: Double?
		let courses: [Course]?
		let path: URL?
		let imageURL: URL?
	}
}
