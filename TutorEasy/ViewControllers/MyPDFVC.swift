//
//  MyPDFVC.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/7/25.
//

import UIKit
import PDFKit

class MyPDFVC: UIViewController {
	// MARK: - Properties
	
	// All possible file extension for video used in pdf goes here
	static let videoExtension = ["mp4", "mov", "m4v"]
	// Playbutton's size
	static let size = CGSize(width: 80, height: 80)
	
	var pdfURL: URL!
	
	// Whether to display a close button. The button is only needed when this view controller displays nothing but a pdfView(no topView so the button is used for allowing user to go back to previous vc)
	var showCloseButton: Bool = false
	
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
	
	private lazy var closeButton: CustomButton = {
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
		// Disable zooming was set in viewWillLayoutSubviews(), but without this, when in .usePageViewController mode, scrolling to a new pdf page will make that zoomable again some time.
		NotificationCenter.default.addObserver(self, selector: #selector(setAndDisbaleZooming), name: .PDFViewVisiblePagesChanged, object: nil)
		
		pdfView.addSubview(loadIndicator)
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
		
		if showCloseButton {
			view.addSubview(closeButton)
			closeButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
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
	
	// Change scale factor when view's layoutChanges automatically, then disable zoom-in/zoom-out, so users can't change it. This viewDidLayoutSubviews() will be automatically called when this vc is a childVC of ChapterDetailVC, and user toggles ChapterDetailVC's isFullScreen value
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		setAndDisbaleZooming()
	}
	
	// MARK: - Custom functions
	@objc private func setAndDisbaleZooming() {
		pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
		// Following 2 will disable zoom-in / zoom-out
		pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
		pdfView.maxScaleFactor = pdfView.scaleFactorForSizeToFit
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
						MessagePresenter.showMessage(title: "未知错误", message: "", on: navVC.topViewController!, actions: [])
				}
			}
			catch {
				guard !Task.isCancelled else { return }
				// Maybe request timed-out or due to other reasons, threw an error,
				guard let navVC = self?.navigationController else { return }
				// Pop current vc first, no need to stay here
				navVC.popViewController(animated: true)
				
				if let _ = error as? URLError {
					MessagePresenter.showMessage(title: "无法载入课程文件", message: "网络错误", on: navVC.topViewController!, actions: [])
				}
				#if DEBUG
				print("\(error.localizedDescription) for loading pdf file \(String(describing: self?.pdfURL))")
				#endif
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
			// Trigger viewDidLayoutSubviews(), which set pdfView's scaleFactor
			view.setNeedsLayout()
		} else {
			// Vertical
			pdfView.displayMode = .singlePageContinuous
			// setNeedsLayout() does not force an immediate update, but instead waits for the next update cycle, without this, view won't know it's needed for layout again.
			view.setNeedsLayout()
			// layoutIfNeeded() forces the view to update its layout immediately. If we don't call this manually, layout will happen after pdfView.go(to: destination), so pdf view will scroll a little bit further down from top of the page
			view.layoutIfNeeded()
			// We will also be setting scaleFactor after document has been got from server, that will cause .singlePageContinuous pdf page to be scrolled a little further down from top of the page(guess zoom-in will begin from current page's center). So scroll back to top of the page. pdfView.go(to: PDFPage) is different from pdfView.goToFirstPage(sender: Any?), the latter won't work.
			let destination = PDFDestination(page: firstPage, at: CGPoint(x: 0, y: firstPage.bounds(for: .mediaBox).maxY))
			pdfView.go(to: destination)
		}
	}
}

extension MyPDFVC: PDFViewDelegate {
	func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
		let url = pdfURL.deletingLastPathComponent().appendingPathComponent(url.path)
		let videoURL = baseURL.appendingPathComponent(FileAPI.FileType.protectedContent.rawValue).appendingPathComponent(url.path, isDirectory: false)
		playVideo(url: videoURL)
	}
}
