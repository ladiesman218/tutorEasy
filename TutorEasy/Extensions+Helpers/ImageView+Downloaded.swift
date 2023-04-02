import UIKit


// This is a hack from https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
extension UIImageView {
	
	func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
		contentMode = contentMode
		Task {
			if let data = try? await FileAPI.publicGetImageData(path: link).get() {
				self.image = UIImage(data: data)
				self.setNeedsDisplay()
			}
		}
	}
	
}

func downloadImages(urls: [URL?]) async -> [UIImage?] {
	return await withTaskGroup(of: (Int, Data?).self, body: { group in
		var images: [UIImage?] = .init(repeating: nil, count: urls.count)

		for (index, url) in urls.enumerated() {
			group.addTask {
				if let url = url {
					let data = try? await FileAPI.publicGetImageData(path: url.path).get()
					return (index, data)
				}
				return (index, nil)
			}

		}

		for await result in group {
			if let data = result.1 {
				images[result.0] = UIImage(data: data)
			}
		}
		return images
	})
}
