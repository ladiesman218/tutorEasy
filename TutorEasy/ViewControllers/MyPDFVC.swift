//
//  MyPDFVC.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/7/25.
//

import UIKit
import PDFKit
import AVKit

class MyPDFVC: UIViewController {
	// MARK: - Properties
	
	// All possible file extension for video used in pdf goes here
	static let videoExtension = ["mp4"]
	// Playbutton's size
	static let size = CGSize(width: 80, height: 80)
	
	var pdfURL: URL!
	
	// Whether to display a close button. The button is only needed when this view controller displays nothing but a pdfView(no topView so the button is used for allowing user to go back to previous vc)
	var showCloseButton: Bool = false
	
	private let player: AVPlayer = AVPlayer()
	// After video finished playing, try to play it again will give black screen with ongoing audio. Debug view hierarchy shows something wierd in AVPlayerViewController's subview. Solution for now is to create a new instance of AVPlayerViewController everytime user click to play a video, so it has to be instantiated inside the pdfViewWillClick delegate method.
	private var playerViewController: AVPlayerViewController!
	
	private var loadTask: Task<Void, Never>? = nil
	
	// MARK: - Custom subviews
	let pdfView: PDFView = {
		let pdfView = PDFView()
		pdfView.layer.cornerRadius = 10
		pdfView.translatesAutoresizingMaskIntoConstraints = false
		return pdfView
	}()
	
	private let loadIndicator: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView()
		indicator.color = .systemYellow
		indicator.hidesWhenStopped = true
		indicator.style = .large
		indicator.translatesAutoresizingMaskIntoConstraints = false
		return indicator
	}()
	
	private let closeButton: CustomButton = {
		let button = CustomButton()
		button.animated = true
		button.layer.cornerRadius = 10
		button.backgroundColor = .gray.withAlphaComponent(0.3)
		
		button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	// MARK: - Controller functions
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		pdfView.delegate = self
		
		// Draw play button for annotations with video links
		NotificationCenter.default.addObserver(self, selector: #selector(drawPlayButton), name: .PDFViewPageChanged, object: nil)
		
		// Disbale text selection should be called when PDFViewVisiblePagesChanged, when calling in PDFViewPageChanged it fails sometime.
		NotificationCenter.default.addObserver(self, selector: #selector(disableSelection), name: .PDFViewVisiblePagesChanged, object: nil)
		pdfView.addSubview(loadIndicator)
		view.addSubview(pdfView)
		
		closeButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
		
		NSLayoutConstraint.activate([
			pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			
			loadIndicator.leadingAnchor.constraint(equalTo: pdfView.leadingAnchor),
			loadIndicator.trailingAnchor.constraint(equalTo: pdfView.trailingAnchor),
			loadIndicator.topAnchor.constraint(equalTo: pdfView.topAnchor),
			loadIndicator.bottomAnchor.constraint(equalTo: pdfView.bottomAnchor)
		])
		
		if showCloseButton {
			view.addSubview(closeButton)
			NSLayoutConstraint.activate([
				closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
				closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
				closeButton.widthAnchor.constraint(equalToConstant: Self.topViewHeight),
				closeButton.heightAnchor.constraint(equalToConstant: Self.topViewHeight)
			])
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// Users may go to a new pdf vc before a chapter's main pdf been loaded, then when they go back, check if document is nil and load it again if needed.
		if pdfView.document == nil {
			loadTask = loadDocument()
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		loadTask?.cancel()
		loadTask = nil
	}
	
	private func loadDocument() -> Task<Void, Never> {
		loadIndicator.startAnimating()
		
		let task = Task { [weak self] in
			do {
				guard let strongSelf = self else { return }
				
				let (data, response) = try await FileAPI.getCourseContent(url: strongSelf.pdfURL)
				if let document = PDFDocument(data: data) {
//					let startTime = DispatchTime.now()
#warning("there will be a 200 - 400ms dead lock for setting pdfView's document alone, and it can't be put in background thread")
					self?.pdfView.document = document
//					let endTime = DispatchTime.now()
//					let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
//					let timeInterval = Double(nanoTime) / 1_000_000_000
//					print("Function execution time: \(timeInterval) seconds")
					
					self?.setDisPlayMode()
					// Disable scale for pdfView, set after both document and displayMode have been set, otherwise won't work
					self?.pdfView.scaleFactor = strongSelf.pdfView.scaleFactorForSizeToFit
					self?.pdfView.minScaleFactor = strongSelf.pdfView.scaleFactorForSizeToFit
					self?.pdfView.maxScaleFactor = strongSelf.pdfView.scaleFactorForSizeToFit
					
					self?.loadIndicator.stopAnimating()
					return
				}
				// Success will return, so here means request failed.
				guard let navVC = self?.navigationController else { return }
				// Pop current vc first, no need to stay here
				navVC.popViewController(animated: true)
				
				let cancel = UIAlertAction(title: "取消", style: .cancel)
				
				switch response.statusCode {
					case 400:
						// Bad request, indicates something wrong in code
						MessagePresenter.showMessage(title: "无法载入PDF", message: "请联系管理员\(adminEmail)", on: navVC.topViewController!, actions: [cancel])
					case 401:
						let login = UIAlertAction(title: "去登录", style: .destructive) {  _ in
							let authVC = AuthenticationVC()
							navVC.pushIfNot(newVC: authVC)
						}
						MessagePresenter.showMessage(title: "付费内容，无访问权限", message: "点击\"去登录\"可注册或登录账号", on: navVC.topViewController!, actions: [login, cancel])
					case 402:
						// Indicates user hasn't bought the course
						let message = try Decoder.isoDate.decode(ResponseError.self, from: data).reason
						let subscription = UIAlertAction(title: "管理订阅", style: .destructive) { _ in
							let accountsVC = AccountVC()
							accountsVC.currentVC = .subscription
							navVC.pushIfNot(newVC: accountsVC)
						}
						MessagePresenter.showMessage(title: "付费内容，无访问权限", message: message, on: navVC.topViewController!, actions: [subscription, cancel])
					case 404:
						// Not found, 2 possible reasons with 404 status, one for course name not found or course not published, another for course pdf file doesn't exist on server. The only possible way to legitimately get the 1st possiblity is we did something wrong in our code, so here we show message to user to indicate the 2nd reason.
						let message = try Decoder.isoDate.decode(ResponseError.self, from: data).reason
						MessagePresenter.showMessage(title: message, message: "请联系管理员\(adminEmail)", on: navVC.topViewController!, actions: [cancel])
					case 500...599:
						// Service un-reachable, either client end doesn't have a network connection, or server is down
						MessagePresenter.showMessage(title: "服务器无响应", message: "请检查设备网络，或联系管理员\(adminEmail)", on: navVC.topViewController!, actions: [cancel])
					default:
						break
				}
			}
			catch {
				guard !Task.isCancelled else { return }
			}
		}
		return task
	}
	
	@objc private func disableSelection() {
		// Seems like when PDFPage is changed, long press gesture will be added again to the view. So Call this here to disable the gesture
		recursivelyDisableSelection(view: pdfView)
	}
	
	// This function checks if a play button should be added, and will draw it if it should.
	@objc func drawPlayButton() {

		// Make sure current page contains annotations(link is a form of annotation), and play button hasn't been drawn(this avoid adding same play button multiple times.), otherwise bail out
		guard let annotations = pdfView.currentPage?.annotations,
			  !annotations.contains(where: {$0.isKind(of: VideoAnnotation.self)} ) else { return }
				//!annotations.isEmpty else { return }
		
		// Loop through all annotations on current page that contains an actionable url, which the url itself contains one of path extensions defined in videoExtension array.
		for annotation in annotations {
			guard let action = annotation.action as? PDFActionURL,
				  let url = action.url,
				  // The link's extension has to be contained by videoExtension array, which means it's a link for a video file
				  Self.videoExtension.contains(url.pathExtension)
			else { continue }
						
			// Place the play button annotation to bottom left corner of the link's annotation area, offset by 20 points right and 20 upwards.
			let bounds = CGRect(origin: .init(x: annotation.bounds.minX + 20, y: annotation.bounds.minY + 20), size: Self.size)

			let videoAnnotation = VideoAnnotation(bounds: bounds, properties: ["/A": action])
			pdfView.currentPage?.addAnnotation(videoAnnotation)
		}
	}
	
	// Check if pdf is vertical or horizontal, set displayMode to .singlePageContinuous for vertical document, usePageViewController if it's horizontal. PageViewController's default displayMode is .singlePage
	func setDisPlayMode() {
		// Make sure pdfView has an document, and the document has at least 1 page
		guard let firstPage = pdfView.document?.page(at: 0) else { return }
		let bounds = firstPage.bounds(for: .mediaBox)
		
		if bounds.width >= bounds.height {
			// Horizontal
			// Configure PDFView to display one page at a time, while keep the ability to scroll up and down on the pdfView itself.
			pdfView.usePageViewController(true)
		} else {
			// Vertical
			pdfView.displayMode = .singlePageContinuous
			// We will also be setting scaleFactor after document has been got from server, that will cause .singlePageContinuous pdf page to be scrolled a little further down from top of the page. So scroll back to top of the page. pdfView.go(to: PDFPage) is different from pdfView.goToFirstPage(sender: Any?), the latter won't work.
		}
		pdfView.goToNextPage(nil)
		pdfView.go(to: firstPage)
	}
}

extension MyPDFVC: PDFViewDelegate {
	func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
		// If the player is playing in picture in picture mode, there is a chance user could click the play button again to start another playback, make sure that doesn't happen.
		//		guard player.currentItem == nil else { return }
		playerViewController = AVPlayerViewController()
		playerViewController.entersFullScreenWhenPlaybackBegins = true
		playerViewController.delegate = self
		playerViewController.showsTimecodes = true
		//		if #available(iOS 16.0, *) {
		//			playerViewController.allowsVideoFrameAnalysis = true
		//		}
		
		// Disable picture in picture for now. pip still cause some issue
		playerViewController.allowsPictureInPicturePlayback = false
		
		// In PDF file, relative path is used for video files(relative to chapter's directory url), so when accessing the real file, we need to modify that link path.
		let url = pdfURL.deletingLastPathComponent().appendingPathComponent(url.path)
		let videoURL = baseURL.appendingPathComponent(FileAPI.FileType.protectedContent.rawValue).appendingPathComponent(url.path, isDirectory: false)
		
		player.replaceCurrentItem(with: .init(url: videoURL))
		playerViewController.player = player
		
		NotificationCenter.default.addObserver(self, selector: #selector(didFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
		
		self.present(playerViewController, animated: true) { [unowned self] in
			playerViewController.player?.play()
		}
		
	}
}

extension MyPDFVC: AVPlayerViewControllerDelegate {
	
	// When pip started, this method returns true, which enbales user to view pdf contents. If this returns false, pdf contents will be blocked by playerVC itself(which is a blank screen in pip mode).
	func playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart(_ playerViewController: AVPlayerViewController) -> Bool {
		return true
	}
	
	// When clicking the restore button in pip window, restore playerViewController and keep playing the video. Without this, the resotre button acts like the close button.
	func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
		self.present(playerViewController, animated: true)
	}
	
	@objc private func didFinishPlaying() {
		player.replaceCurrentItem(with: nil)
		// If/when playback is in a pip window, due to the current implementation, playerVC is dismissed, and will be restored after playback finished. In that case the following dismiss command will happen earlier than the restoration without asyncAfter, therefor no dismission will actually happen. Adding asyncAfter will delay dismission, practically guarantee restoration happens first, and we get a successful dismiss.
		Task {
			try await Task.sleep(nanoseconds: 3_000_000)
			await MainActor.run {
				playerViewController.dismiss(animated: true)
			}
		}
	}
	
}
