//
//  ChapterDetailView.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/11/9.
//

import UIKit
import PDFKit
import AVKit

class ChapterDetailVC: UIViewController {
	
	// MARK: - Properties
	var chapter: Chapter! {
		didSet {
			let url = chapter.pdfURL!
			self.pdfView.document = PDFDocument(url: url)!
//			self.pdfView.setNeedsDisplay()
		}
	}
	// This will hold the scaleFactor value for pdfView after it's set for the first time
	private var scaleFactor: CGFloat!
	
	private let player: AVPlayer = AVPlayer()
	// After video finished playing, try to play it again will give black screen with ongoing audio. Debug view hierarchy shows something wierd in AVPlayerViewController's subview. Solution for now is to create a new instance of AVPlayerViewController everytime user click to play a video, so it has to be instantiated inside the pdfViewWillClick delegate method.
	private var playerViewController: AVPlayerViewController!
	// To hold thumbnails we manually generated for the pdf document, then showing them later in a collectionView. The built-in PDFThumbnailView has an hard to work-around issue: when clicking an thumbnail, it automatically become larger and cover other thumbnails next to it.
	private var thumbnails = [UIImage]() {
		didSet {
			thumbnailCollectionView.reloadData()
		}
	}
	
	// MARK: - Custom subviews
	private var topView: UIView!
	private var backButtonView: UIView!
	private var chapterTitle: UILabel = {
		let chapterTitle = UILabel()
		chapterTitle.translatesAutoresizingMaskIntoConstraints = false
		chapterTitle.textColor = .white
		return chapterTitle
	}()
	
	var pdfView: PDFView = {
		let pdfView = PDFView()
		pdfView.displayMode = .singlePage
		pdfView.autoScales = true
		pdfView.enableDataDetectors = true
#warning("Disable selecting, editing, for pdfView")
		
		pdfView.translatesAutoresizingMaskIntoConstraints = false
		return pdfView
	}()
	
	let thumbnailCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.backgroundColor = backgroundColor
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.register(PDFThumbnailCell.self, forCellWithReuseIdentifier: PDFThumbnailCell.identifier)
		
		return collectionView
	}()
	
	// MARK: - Controller functions
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		scaleFactor = pdfView.scaleFactor
		// Setting min and max scaleFactor to a fixed value will prevent pdfView to zoom-in or out.
		pdfView.minScaleFactor = scaleFactor
		pdfView.maxScaleFactor = scaleFactor
		//		pdfView.isUserInteractionEnabled = false	// This disable all user interactions including clicking on a link.
		//		print(pdfView.document?.accessPermissions.rawValue)
		//		print(pdfView.document?.permissionsStatus.rawValue)

	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = backgroundColor
		topView = configTopView(bgColor: .orange)
		backButtonView = setUpGoBackButton(in: topView)
		
		chapterTitle.text = chapter.name
		chapterTitle.font = chapterTitle.font.withSize(topViewHeight / 2)
		topView.addSubview(chapterTitle)
		
		pdfView.delegate = self
		view.addSubview(pdfView)
		
		thumbnailCollectionView.delegate = self
		thumbnailCollectionView.dataSource = self
		view.addSubview(thumbnailCollectionView)
		
		// Generate thumbnails manually
		for number in 0 ... pdfView.document!.pageCount - 1 {
			let box = pdfView.displayBox
			let image = pdfView.document!.page(at: number)!.thumbnail(of: .init(width: 500, height: 350), for: box)
			thumbnails.append(image)
		}

		NotificationCenter.default.addObserver(self, selector: #selector(didFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
		
		NSLayoutConstraint.activate([
			chapterTitle.leadingAnchor.constraint(equalTo: backButtonView.trailingAnchor, constant: topViewHeight * 0.7),
			chapterTitle.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -topViewHeight * 2),
			chapterTitle.topAnchor.constraint(equalTo: topView.topAnchor),
			chapterTitle.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
			
			thumbnailCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			thumbnailCollectionView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 20),
			thumbnailCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			thumbnailCollectionView.widthAnchor.constraint(equalToConstant: view.frame.size.width * 0.2),
	
			pdfView.leadingAnchor.constraint(equalTo: thumbnailCollectionView.trailingAnchor),
			pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			pdfView.topAnchor.constraint(equalTo: thumbnailCollectionView.topAnchor),
			pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
		])
	}
}

extension ChapterDetailVC: PDFViewDelegate {
	func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
		// If the player is playing in picture in picture mode, there is a chance user could click the play button again to start another playback, make sure that doesn't happen.
//		guard player.currentItem == nil else { return }
		
		guard let senderURL = sender.document?.documentURL else { fatalError() }
		// senderURL contains the pdf file name and extension in its path, so remove that.
		let baseURL = senderURL.deletingLastPathComponent()
		let path = url.path
		
		let finalURL = baseURL.appendingPathComponent(path)
//		let finalPath = finalURL.path.removingPercentEncoding ?? finalURL.path

		playerViewController = AVPlayerViewController()
		playerViewController.delegate = self
		playerViewController.showsTimecodes = true
		if #available(iOS 16.0, *) {
			playerViewController.allowsVideoFrameAnalysis = true
		}
		
		// Disable picture in picture for now. pip still cause some issue
		playerViewController.allowsPictureInPicturePlayback = false
		player.replaceCurrentItem(with: .init(url: finalURL))
		playerViewController.player = player

		self.present(playerViewController, animated: true) { [unowned self] in
			playerViewController.player?.play()
		}
		
	}
}

extension ChapterDetailVC: AVPlayerViewControllerDelegate {
	
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
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
			playerViewController.dismiss(animated: false)
		}
	}
	
}

// create an extension of AVPlayerViewController
//extension AVPlayerViewController {
//	// override 'viewWillDisappear'
//	open override func viewWillDisappear(_ animated: Bool) {
//		super.viewWillDisappear(animated)
//		// now, check that this ViewController is dismissing
//		if self.isBeingDismissed == false {
//			return
//		}
//
//		player?.replaceCurrentItem(with: nil)
//		// and then , post a simple notification and observe & handle it, where & when you need to.....
////		NotificationCenter.default.post(name: .kAVPlayerViewControllerDismissingNotification, object: nil)
//	}
//}

extension ChapterDetailVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return thumbnails.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PDFThumbnailCell.identifier, for: indexPath) as! PDFThumbnailCell
		cell.imageView.image = thumbnails[indexPath.item]
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return .init(width: collectionView.bounds.size.width * 0.9, height: collectionView.bounds.size.width * 0.6)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		.init(top: 10, left: 0, bottom: 10, right: 0)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let page = pdfView.document!.page(at: indexPath.item)!
		pdfView.go(to: page)
	}
	
}
