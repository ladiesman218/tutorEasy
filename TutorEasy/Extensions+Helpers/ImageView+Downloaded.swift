import UIKit


// This is a hack from https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            #warning("return more specific error or response when failing")
            let a = UIDocument(fileURL: URL(fileURLWithPath: "asdf"))
            guard let httpURLResponse = response as? HTTPURLResponse,
                  httpURLResponse.statusCode == 200,
                  // let mimeType = httpURLResponse.mimeType, /*mimeType.hasSuffix("png") || mimeType.hasSuffix("jpg") || mimeType.hasSuffix("jpeg"),*/
                  let data = data,
                  error == nil,
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
        //link is the file path, prefix that path with the fileURL to generate the right endpoint url.
        let url = fileURL.appendingPathComponent(link)
        downloaded(from: url, contentMode: mode)
    }
}
