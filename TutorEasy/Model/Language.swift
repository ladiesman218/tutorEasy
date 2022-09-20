import Foundation


struct Language: Decodable {
	let id: UUID?
	let name: String
	let description: String
	let published: Bool
	let price: Double?
//	let courses: [Course]
	
	let path: URL
	let imageURL: URL?
	
}
