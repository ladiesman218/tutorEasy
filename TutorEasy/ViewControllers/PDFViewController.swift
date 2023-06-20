//
//  PDFViewController.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/5/30.
//

import UIKit
import PDFKit
import AVKit

class PDFViewController: UIViewController {
	
	// MARK: - Properties
	var url: URL! {
		didSet {
			loadDocument()
		}
	}
	var chapter: Chapter!
	
	private let player: AVPlayer = AVPlayer()
	// After video finished playing, try to play it again will give black screen with ongoing audio. Debug view hierarchy shows something wierd in AVPlayerViewController's subview. Solution for now is to create a new instance of AVPlayerViewController everytime user click to play a video, so it has to be instantiated inside the pdfViewWillClick delegate method.
	private var playerViewController: AVPlayerViewController!
	// To hold thumbnails we manually generated for the pdf document, then showing them later in a collectionView. The built-in PDFThumbnailView has an hard-to-work-around issue: when clicking an thumbnail, it automatically become larger and cover other thumbnails next to it.
	private var document = PDFDocument() {
		didSet {
			pdfView.document = document
//			pdfView.setDisPlayMode()
			pdfView.displayMode = .singlePageContinuous
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
	override func viewDidLayoutSubviews() {
		pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
		pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
		pdfView.maxScaleFactor = pdfView.scaleFactorForSizeToFit
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		pdfView.delegate = self
        closeButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
		
		view.addSubview(pdfView)
		
		NSLayoutConstraint.activate([
			pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			
			
		])
	}
	
	private func loadDocument() {
		Task {
			do {
				let (data, response) = try await FileAPI.getCourseContent(path: url.path)
				let document = PDFDocument(data: data)!
				self.document = document
				
				// Only when document loaded succussfully, then add the close button. Otherwise it's hard/impossible to place closeButton on top of pdfView
				view.addSubview(closeButton)
				NSLayoutConstraint.activate([
					closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
					closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
					closeButton.widthAnchor.constraint(equalToConstant: Self.topViewHeight),
					closeButton.heightAnchor.constraint(equalToConstant: Self.topViewHeight)
				])
			} catch {
				let goBack = UIAlertAction(title: "返回", style: .cancel) { [unowned self] _ in
					self.navigationController?.popViewController(animated: true)
				}
				error.present(on: self, title: "无法获取课程", actions: [goBack])
			}
		}
	}
	
	@objc func pageChanged() {
		// Seems like when PDFPage is changed, long press gesture will be added again to the view. So Call this here to disable the gesture
		recursivelyDisableSelection(view: pdfView)
	}
}

extension PDFViewController: PDFViewDelegate {
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
		let videoURL = FileAPI.contentEndPoint.appendingPathComponent(chapter.directoryURL.path).appendingPathComponent(url.path)
		player.replaceCurrentItem(with: .init(url: videoURL))
		playerViewController.player = player
		
		//		NotificationCenter.default.addObserver(self, selector: #selector(didFinishPlaying), name: .AV, object: <#T##Any?#>)
		NotificationCenter.default.addObserver(self, selector: #selector(didFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
		
		self.present(playerViewController, animated: true) { [unowned self] in
			playerViewController.player?.play()
		}
		
	}
}

extension PDFViewController: AVPlayerViewControllerDelegate {
	
	// When pip started, this method returns true, which enbales user to view pdf contents. If this returns false, pdf contents will be blocked by playerVC itself(which is a blank screen in pip mode).
	func playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart(_ playerViewController: AVPlayerViewController) -> Bool {
		return true
	}
	
	// When clicking the restore button in pip window, restore playerViewController and keep playing the video. Without this, the resotre button acts like the close button.
	func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
		self.present(playerViewController, animated: true)
	}
	
	@objc func didFinishPlaying() {
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
