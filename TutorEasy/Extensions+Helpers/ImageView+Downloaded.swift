import UIKit


// This is a hack from https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        var modifiedURL = url
        
        // Some of the urls are returned by the server, and are prefixed with "../". Since by default vapor doesn't accept any parent-folder-access request, we have to remove the "../" from url before making the request on client end, then add the "../" after receiving the request on server end to access the files.
        if url.absoluteString.hasPrefix("../") {
            let string = url.absoluteString
            let path = string.replacingOccurrences(of: "../", with: "")
            modifiedURL = mediaURL.appendingPathComponent(path)
        }
        
        URLSession.shared.dataTask(with: modifiedURL) { data, response, error in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                  let mimeType = response?.mimeType, mimeType.hasSuffix("png") || mimeType.hasSuffix("jpg") || mimeType.hasSuffix("jpeg"),
                  let data = data, error == nil,
                  let image = UIImage(data: data)
            else {
                print("load image error")
                return
            }
            
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
