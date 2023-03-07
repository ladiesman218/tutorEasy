import UIKit


// This is a hack from https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
extension UIImageView {
  
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = contentMode
		Task {
			if let data = try? await FileAPI.getFile(path: link).get() {
					self.image = UIImage(data: data)
					self.setNeedsDisplay()
			}
		}
//        FileAPI.getFile(path: link) { data, response, error in
//            if let data = data {
//                self.image = UIImage(data: data)
//            } else {
//#warning("return more specific error or response when failing")
//                MessagePresenter.showMessage(title: "图片获取失败", message: error?.localizedDescription ?? "服务器错误", on: self.findViewController(), actions: [])
//            }
//        }
    }
    
}
