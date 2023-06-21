//
//  ChapterDetailView.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/11/9.
//

import UIKit
import PDFKit
import AVKit
#warning("Loading chapter pdf should enable skeletonView")
class ChapterDetailVC: UIViewController {
	
	// MARK: - Properties
	private var fullTop: NSLayoutConstraint!
	private var noTop: NSLayoutConstraint!
	private var fullThumb: NSLayoutConstraint!
	private var noThumb: NSLayoutConstraint!
	
	// When chapter's pdf file is got from server, set this variable's value to that file, this will trigger property observer to do its things
	private var chapterPDF = PDFDocument() {
		didSet {
			pdfView.document = chapterPDF
			
			pdfView.setDisPlayMode()
			
			// Creat thumbnails
			for number in 0 ... chapterPDF.pageCount - 1 {
				let box = pdfView.displayBox
				let image = pdfView.document!.page(at: number)!.thumbnail(of: .init(width: 500, height: 350), for: box)
				thumbnails.append(image)
			}
			
			// Add functionality for double tapping to toggle full screen
			let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleFullScreen))
			doubleTapGesture.numberOfTapsRequired = 2
			pdfView.addGestureRecognizer(doubleTapGesture)
			
			pdfView.drawPlayButton()
			recursivelyDisableSelection(view: pdfView)
			
			
			// Call changeSelectedCell and drawPlayButton when PDFViewVisiblePagesChanged doesn't work as expected, scrolling position won't be right and playbutton won't be added sometimes, so call it when PDFViewPageChanged.
			NotificationCenter.default.addObserver(self, selector: #selector(changeSelectedCell), name: .PDFViewPageChanged, object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(drawPlayButton), name: .PDFViewPageChanged, object: nil)
			
			// Disbale text selection should be called when PDFViewVisiblePagesChanged, when calling in PDFViewPageChanged it fails sometime.
			NotificationCenter.default.addObserver(self, selector: #selector(pageChanged), name: .PDFViewVisiblePagesChanged, object: nil)
		}
	}
	
	private var isFullScreen: Bool = false {
		didSet {
			if isFullScreen {
				fullTop.isActive = false
				fullThumb.isActive = false
				
				noTop.isActive = true
				noThumb.isActive = true
			} else {
				noTop.isActive = false
				noThumb.isActive = false
				
				fullTop.isActive = true
				fullThumb.isActive = true
			}
			
			UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations:{ [unowned self] in
				// layoutIfNeeded is for animation, here we animate layout changes, so changes has to be effect before animation starts
				view.layoutIfNeeded()
				// setNeedsLayout is for triggering pdf auto resize, when usePageViewController, viewDidLayoutSubViews will be called automatically when isFullScreen changed, hence handling the resize. This is only needed when displayMode is set to .singlePageContinuous, which means pdf page is in vertical mode.
				view.setNeedsLayout()
			})
			
			// This has to be called after collectionView is already on screen, otherwise it won't work.
			if !isFullScreen { changeSelectedCell() }
		}
	}
	
	var chapter: ChapterModel! {
		didSet {
			Task.detached { [unowned self] in
				await self.loadPDF()
			}
		}
	}
	
	private let player: AVPlayer = AVPlayer()
	// After video finished playing, try to play it again will give black screen with ongoing audio. Debug view hierarchy shows something wierd in AVPlayerViewController's subview. Solution for now is to create a new instance of AVPlayerViewController everytime user click to play a video, so it has to be instantiated inside the pdfViewWillClick delegate method.
	private var playerViewController: AVPlayerViewController!
	// To hold thumbnails we manually generated for the pdf document, then showing them later in a collectionView. The built-in PDFThumbnailView has an hard-to-work-around issue: when clicking an thumbnail, it automatically become larger and cover other thumbnails next to it.
	private var thumbnails = [UIImage]() {
		didSet {
			thumbnailCollectionView.reloadData()
			// Select the first cell, make it fully opaque
			thumbnailCollectionView.selectItem(at: [0, 0], animated: true, scrollPosition: .top)
			thumbnailCollectionView.cellForItem(at: [0, 0])?.contentView.layer.opacity = 1
		}
	}
	
	// MARK: - Custom subviews
	private var topView: UIView!
	private var backButtonView: UIView!
	private let teachingPlanButton: ChapterButton = ChapterButton(image: .init(named: "教案.png")!, titleText: "教案", fontSize: 10)
	
	private let buildingInstructionButton: ChapterButton = ChapterButton(image: .init(named: "搭建说明.png")!, titleText: "搭建说明", fontSize: 10)
	
	private let chapterTitle: UILabel = {
		let chapterTitle = UILabel()
		chapterTitle.translatesAutoresizingMaskIntoConstraints = false
		chapterTitle.textColor = .white
		return chapterTitle
	}()
	
	private let pdfView: PDFView = {
		let pdfView = PDFView()
		
		pdfView.layer.cornerRadius = 10
		//		pdfView.enableDataDetectors = true		// Does't seem to affect anything?
		
		pdfView.translatesAutoresizingMaskIntoConstraints = false
		return pdfView
	}()
	
	private let thumbnailCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.register(PDFThumbnailCell.self, forCellWithReuseIdentifier: PDFThumbnailCell.identifier)
		collectionView.backgroundColor = UIColor.systemBackground
		return collectionView
	}()
	
	// MARK: - Controller functions
	override func viewDidLayoutSubviews() {
		// viewDidLayoutSubviews will be called both when full screen is toggled, and after the chapterPdf was set and the first page was displayed on screen, so this is the only place to set scale factor and disable zooming by set min/max scale factor to the same value.
		pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
		pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
		pdfView.maxScaleFactor = pdfView.scaleFactorForSizeToFit
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemBackground
		topView = configTopView()
		topView.backgroundColor = .orange
		backButtonView = setUpGoBackButton(in: topView)
		
		teachingPlanButton.isEnabled = chapter.teachingPlanURL != nil
		teachingPlanButton.tag = 0
		teachingPlanButton.addTarget(self, action: #selector(goToPDF), for: .touchUpInside)
		topView.addSubview(teachingPlanButton)
		
		buildingInstructionButton.isEnabled = chapter.bInstructionURL != nil
		buildingInstructionButton.tag = 1
		buildingInstructionButton.addTarget(self, action: #selector(goToPDF), for: .touchUpInside)
		topView.addSubview(buildingInstructionButton)
		
		chapterTitle.text = chapter.name
		chapterTitle.font = chapterTitle.font.withSize(Self.topViewHeight / 2)
		topView.addSubview(chapterTitle)
		
		pdfView.delegate = self
		view.addSubview(pdfView)
		
		thumbnailCollectionView.delegate = self
		thumbnailCollectionView.dataSource = self
		view.addSubview(thumbnailCollectionView)
		
		fullTop = topView.heightAnchor.constraint(equalToConstant: Self.topViewHeight)
		noTop = topView.heightAnchor.constraint(equalToConstant: 0)
		fullThumb = thumbnailCollectionView.widthAnchor.constraint(equalToConstant: view.frame.size.width * 0.2)
		noThumb = thumbnailCollectionView.widthAnchor.constraint(equalToConstant: 0)
		
		// Manually set to avoid unnecessary animations
		if isFullScreen {
			noTop.isActive = true
			noThumb.isActive = true
		} else {
			fullTop.isActive = true
			fullThumb.isActive = true
		}
		
		NSLayoutConstraint.activate([
			topView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			
			teachingPlanButton.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: 0),
			teachingPlanButton.topAnchor.constraint(equalTo: topView.topAnchor),
			teachingPlanButton.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
			teachingPlanButton.widthAnchor.constraint(equalToConstant: teachingPlanButton.width),
			
			buildingInstructionButton.trailingAnchor.constraint(equalTo: teachingPlanButton.leadingAnchor),
			buildingInstructionButton.topAnchor.constraint(equalTo: topView.topAnchor),
			buildingInstructionButton.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
			buildingInstructionButton.widthAnchor.constraint(equalToConstant: buildingInstructionButton.width),
			
			chapterTitle.leadingAnchor.constraint(equalTo: backButtonView.trailingAnchor, constant: Self.topViewHeight * 0.2),
			chapterTitle.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -Self.topViewHeight * 2),
			chapterTitle.topAnchor.constraint(equalTo: topView.topAnchor),
			chapterTitle.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
			
			thumbnailCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			thumbnailCollectionView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 10),
			thumbnailCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			
			pdfView.leadingAnchor.constraint(equalTo: thumbnailCollectionView.trailingAnchor),
			pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			pdfView.topAnchor.constraint(equalTo: thumbnailCollectionView.topAnchor),
			pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
		])
		// These 2 functions should be called after constraints have been set, coz centerVertically() needs button's frame to have been set, to actually work.
		teachingPlanButton.centerVertically()
		buildingInstructionButton.centerVertically()
	}
	
	@objc func toggleFullScreen() {
		isFullScreen.toggle()
	}
	
	@objc func pageChanged() {
		// Seems like when PDFPage is changed, long press gesture will be added again to the view. So Call this here to disable the gesture
		recursivelyDisableSelection(view: pdfView)
	}
	
	// When scrolling on pdfView to change pdf page, change opacity for thumbnail collection view cells accordingly. This should be called only when not in full screen mode, otherwise it does nothing.
	@objc func changeSelectedCell() {
		guard let labelString = pdfView.currentPage?.label, let labelInt = Int(labelString) else { return }
		let index = labelInt - 1
		
		// Clear selection
		for indexPath in thumbnailCollectionView.indexPathsForVisibleItems {
			thumbnailCollectionView.deselectItem(at: indexPath, animated: false)
		}
		// By default, un-selected cells are a little transparent
		thumbnailCollectionView.visibleCells.forEach {
			$0.contentView.layer.opacity = PDFThumbnailCell.opacity
		}
		
		// Make it fully opaque
		thumbnailCollectionView.cellForItem(at: [0, index])?.contentView.layer.opacity = 1
		// Select item
		thumbnailCollectionView.selectItem(at: [0, index], animated: true, scrollPosition: .centeredVertically)
	}
	
	@objc func goToPDF(sender: UIButton) {
		let pdfVC = PDFViewController()
		pdfVC.chapter = chapter
		if sender.tag == 0 {
			// Teaching plan
			guard let url = chapter.teachingPlanURL else { return }
			pdfVC.url = url
		} else if sender.tag == 1 {
			// Building instruction
			guard let url = chapter.bInstructionURL else { return }
			pdfVC.url = url
		}
		self.navigationController?.pushIfNot(newVC: pdfVC)
	}
	
	private func loadPDF() async {
		let path = chapter.pdfURL.path
		do {
			let (data, response) = try await FileAPI.getCourseContent(path: path)
			print("In the function: \(Thread.current)")
			let navVC = self.navigationController!
			let cancel = UIAlertAction(title: "再看看", style: .default) { action in
				navVC.popViewController(animated: true)
			}
			
			switch response.statusCode {
				case 200:
					let document = PDFDocument(data: data)!
					await MainActor.run {
						self.chapterPDF = document
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
	}
}

extension ChapterDetailVC: PDFViewDelegate {
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
		Task {
			try await Task.sleep(nanoseconds: 3_000_000)
			await MainActor.run {
				playerViewController.dismiss(animated: true)
			}
		}
	}
	
}

extension ChapterDetailVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return thumbnails.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PDFThumbnailCell.identifier, for: indexPath) as! PDFThumbnailCell
		cell.imageView.image = thumbnails[indexPath.item]
		// Since opacity is changing during select and deselect, and we are reusing instead of creating new cells, opacity should be set here otherwise scrolling will cause visual bugs
		cell.contentView.layer.opacity = (cell.isSelected) ? 1 : PDFThumbnailCell.opacity
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
