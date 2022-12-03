import Foundation

// This should only mirror PublicInfo of the model on server-end, since we will not be managing models on client-end.
struct Language: Codable {
	let id: UUID
	let name: String
	let description: String
    let price: Double
    let courses: [Course]
	let directoryURL: URL   // We are not using language's directoryURL, at least for now. But to keep decoing json response easy, this property leaves.
	let imagePath: String?
}
