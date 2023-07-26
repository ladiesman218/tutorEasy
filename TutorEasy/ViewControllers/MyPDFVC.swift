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
	var pdfURL: URL! {
		didSet {
			loadDocument()
		}
	}
		
	private let player: AVPlayer = AVPlayer()
	// After video finished playing, try to play it again will give black screen with ongoing audio. Debug view hierarchy shows something wierd in AVPlayerViewController's subview. Solution for now is to create a new instance of AVPlayerViewController everytime user click to play a video, so it has to be instantiated inside the pdfViewWillClick delegate method.
	private var playerViewController: AVPlayerViewController!
	// To hold thumbnails we manually generated for the pdf document, then showing them later in a collectionView. The built-in PDFThumbnailView has an hard-to-work-around issue: when clicking an thumbnail, it automatically become larger and cover other thumbnails next to it.
	private var document = PDFDocument() {
		didSet {
			
			loadIndicator.stopAnimating()
			pdfView.document = document
			pdfView.setDisPlayMode()
			pdfView.drawPlayButton()
			recursivelyDisableSelection(view: pdfView)
			
			NotificationCenter.default.addObserver(self, selector: #selector(drawPlayButton), name: .PDFViewPageChanged, object: nil)
			
			// Disbale text selection should be called when PDFViewVisiblePagesChanged, when calling in PDFViewPageChanged it fails sometime.
			NotificationCenter.default.addObserver(self, selector: #selector(pageChanged), name: .PDFViewVisiblePagesChanged, object: nil)
		}
	}
	
	// MARK: - Custom subviews
	private let pdfView: PDFView = {
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
	
	// MARK: - Controller functions
	// Disable scale for pdfView
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
		pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
		pdfView.maxScaleFactor = pdfView.scaleFactorForSizeToFit
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		pdfView.delegate = self
		
		pdfView.addSubview(loadIndicator)
		loadIndicator.startAnimating()
		view.addSubview(pdfView)
		
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
	}
	
	private func loadDocument() {
		Task {
			do {
				let (data, response) = try await FileAPI.getCourseContent(path: self.pdfURL.path)
				let navVC = self.navigationController!
				let cancel = UIAlertAction(title: "再看看", style: .default) { action in
					navVC.popViewController(animated: true)
				}
				
				switch response.statusCode {
					case 200:
						let document = PDFDocument(data: data)!
						await MainActor.run {
							self.document = document
						}
					case 400:
						// Bad request, indicates something wrong in code
						MessagePresenter.showMessage(title: "未知错误", message: "请联系管理员\(adminEmail)", on: navVC.topViewController!, actions: [cancel])
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
			} catch {
				print("Load pdf file error")
			}
			
			
			// Only when document loaded succussfully, then add the close button. Otherwise it's hard/impossible to place closeButton on top of pdfView
		}
	}
	
	@objc private func pageChanged() {
		// Seems like when PDFPage is changed, long press gesture will be added again to the view. So Call this here to disable the gesture
		recursivelyDisableSelection(view: pdfView)
	}
}

extension MyPDFVC: PDFViewDelegate {
	func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
		print("clicked")
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
		
		// In PDF file, relative path is used for video files(relative to chapter's directory url), so when accessing the real file, we need to modify that link path, prepend api end point and directory url first
		let videoURL = FileAPI.contentEndPoint.appendingPathComponent(pdfURL.deletingLastPathComponent().path).appendingPathComponent(url.path)
		player.replaceCurrentItem(with: .init(url: videoURL))
		playerViewController.player = player
		
		//		NotificationCenter.default.addObserver(self, selector: #selector(didFinishPlaying), name: .AV, object: <#T##Any?#>)
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
