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
	// These 4 are for toggling pdfView's full screen mode. pdfView's top and leading anchor are constrainted to topView and thumbnailCollectionView, when go into full screen mode, change these 2's layout will give us better animation than changing pdfView's top and leading constraint.
	private var fullTop: NSLayoutConstraint!
	private var noTop: NSLayoutConstraint!
	private var fullThumb: NSLayoutConstraint!
	private var noThumb: NSLayoutConstraint!
	// Following 2 are for buttonsCollectionView
	private var noButtons: NSLayoutConstraint!
	private var fullButtons: NSLayoutConstraint!
	
	let pdfVC: MyPDFVC = {
		let pdfVC = MyPDFVC()
		pdfVC.view.translatesAutoresizingMaskIntoConstraints = false
		return pdfVC
	}()
	
	private var isFullScreen: Bool! {
		didSet {
			if isFullScreen {
				fullTop.isActive = false
				fullThumb.isActive = false
				
				noTop.isActive = true
				noThumb.isActive = true
				// When goes into full screen, hide buttonsCollectionVC
				isToolsDisplaying = false
			} else {
				noTop.isActive = false
				noThumb.isActive = false
				
				fullTop.isActive = true
				fullThumb.isActive = true
			}
		}
	}
	
	private var isToolsDisplaying: Bool! {
		didSet {
			if isToolsDisplaying {
				noButtons.isActive = false
				fullButtons.isActive = true
			} else {
				fullButtons.isActive = false
				noButtons.isActive = true
			}
		}
	}
	
	var chapter: Chapter!
	
	private var thumbnails: [UIImage?] = .init(repeating: nil, count: placeHolderNumber)
	
	// MARK: - Custom subviews
	private var topView: UIView!
	private var backButtonView: UIView!
		
	private let toolsButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(UIImage(named: "toolbox")!, for: .normal)
		return button
	}()
	
	private let chapterTitle: UILabel = {
		let chapterTitle = UILabel()
		chapterTitle.translatesAutoresizingMaskIntoConstraints = false
		chapterTitle.textColor = .white
		return chapterTitle
	}()
	
	// To hold thumbnails we manually generated for the pdf document, then showing them later in a collectionView. The built-in PDFThumbnailView has an hard-to-work-around issue: when clicking an thumbnail, it automatically become larger and cover other thumbnails next to it.
	private let thumbnailCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.register(PDFThumbnailCell.self, forCellWithReuseIdentifier: PDFThumbnailCell.identifier)
		collectionView.backgroundColor = UIColor.systemBackground
		return collectionView
	}()
	
	private let buttonsCollectionVC = ButtonsCollectionVC(collectionViewLayout: UICollectionViewFlowLayout())
	
	// MARK: - Controller functions
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemBackground
		topView = configTopView()
		topView.backgroundColor = .orange
		backButtonView = setUpGoBackButton(in: topView)
		
		chapterTitle.text = chapter.name
		chapterTitle.font = chapterTitle.font.withSize(Self.topViewHeight / 2)
		topView.addSubview(chapterTitle)
		
		toolsButton.addTarget(self, action: #selector(toggleTools), for: .touchUpInside)
		topView.addSubview(toolsButton)
		
		// Setting up pdfVC
		pdfVC.pdfURL = chapter.pdfURL
		self.addChild(pdfVC)
		view.addSubview(pdfVC.view)
		
		// Config thumbnailCollectionView
		thumbnailCollectionView.delegate = self
		thumbnailCollectionView.dataSource = self
		// Disable selection, then enable it when thumbnails have been generated. Change of selection before document has been loaded crash the app.
		thumbnailCollectionView.allowsSelection = false
		view.addSubview(thumbnailCollectionView)
		
		// Config buttonsCollectionView, its view will over lap with pdfVC's view, although setting its zPosition can make the view visible, it won't respond to scroll or tapping interaction. Adding the view after adding pdfVC's view solves the problem.
		buttonsCollectionVC.chapter = chapter
		addChild(buttonsCollectionVC)
		view.addSubview(buttonsCollectionVC.view)
		
		// Allow double tap and pinch to toggle full screen
		let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleFullScreen))
		doubleTapGesture.numberOfTapsRequired = 2
		pdfVC.pdfView.addGestureRecognizer(doubleTapGesture)
		let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoom))
		pdfVC.pdfView.addGestureRecognizer(pinchGesture)
		
		// These 2 observers should only receive notifications sending from contained pdfVC's pdfView, other instance's pdfView(like clicking teaching plan button to instantiate a new MyPDFVC) will send notifications if object is set to nil.
		NotificationCenter.default.addObserver(self, selector: #selector(createThumbnails), name: .PDFViewDocumentChanged, object: pdfVC.pdfView)
		NotificationCenter.default.addObserver(self, selector: #selector(changeSelectedCell), name: .PDFViewPageChanged, object: pdfVC.pdfView)
		
		// Setting up changable constraints
		fullTop = topView.heightAnchor.constraint(equalToConstant: Self.topViewHeight)
		noTop = topView.heightAnchor.constraint(equalToConstant: 0)
		fullThumb = thumbnailCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: view.frame.size.width * 0.2)
		noThumb = thumbnailCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
		// Squeezing buttonsCollectionVC's width may cause some cells displaying no button while scrolling too fast, or misplaced buttons when toggling display/not too fast, so here we just push it outside of the screen when not displaying.
		fullButtons = buttonsCollectionVC.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -UIViewController.topViewHeight * 1.5)
		noButtons = buttonsCollectionVC.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
		
		isToolsDisplaying = false
		isFullScreen = false
		
		NSLayoutConstraint.activate([
			topView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			
			toolsButton.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
			toolsButton.topAnchor.constraint(equalTo: topView.topAnchor, constant: Self.topViewHeight * 0.1),
			toolsButton.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -Self.topViewHeight * 0.1),
			toolsButton.widthAnchor.constraint(equalTo: toolsButton.heightAnchor),
			
			buttonsCollectionVC.view.topAnchor.constraint(equalTo: topView.bottomAnchor),
			buttonsCollectionVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			buttonsCollectionVC.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			
			chapterTitle.leadingAnchor.constraint(equalTo: backButtonView.trailingAnchor, constant: Self.topViewHeight * 0.2),
			chapterTitle.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -Self.topViewHeight * 2),
			chapterTitle.topAnchor.constraint(equalTo: topView.topAnchor),
			chapterTitle.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
			
			thumbnailCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			thumbnailCollectionView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 10),
			thumbnailCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			
			pdfVC.view.leadingAnchor.constraint(equalTo: thumbnailCollectionView.trailingAnchor),
			pdfVC.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			pdfVC.view.topAnchor.constraint(equalTo: thumbnailCollectionView.topAnchor),
			pdfVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}
	
	@objc private func toggleFullScreen() {
		isFullScreen.toggle()
		animateLayoutChange()
	}
	
	@objc private func toggleTools(animated: Bool) {
		isToolsDisplaying.toggle()
		animateLayoutChange()
	}
	
	@objc private func zoom(sender: UIPinchGestureRecognizer) {
		if sender.scale < 1.0 {
			isFullScreen = false
		} else {
			isFullScreen = true
		}
		animateLayoutChange()
	}
	
	private func animateLayoutChange() {
		UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) { [weak self] in
			// Calling layoutIfNeeded() on self.view to animate topView and thumbnailCollectionView's layout change
			self?.view.layoutIfNeeded()
			// Calling setNeedsLayout() on pdfVC's view will trigger its viewDidLayoutSubviews() function, in which we changed pdfView's scaleFactor. Although calling self?.view.layoutIfNeeded() also triggers the function call, but has no actual effect because scaleFactor has to be changed after layout animation has finished, not during animation.
			self?.pdfVC.view.setNeedsLayout()
		} completion: { [weak self] _ in
			// Changing of pdf current page may happen in full screen mode, when exit full screen, change selected cell. This should be called after layout change animation has finished, otherwise won't work.
			if self?.isFullScreen == false {
				self?.changeSelectedCell()
			}
		}
	}
	
	// When scrolling on pdfView to change pdf page, change selected cell for thumbnail collection view, and update all visible cells' opacity value. This should be called only when not in full screen mode, otherwise it does nothing.
	@objc private func changeSelectedCell() {
		guard let labelString = pdfVC.pdfView.currentPage?.label, let labelInt = Int(labelString) else { return }
		let index = labelInt - 1
		
		// Select item, and scroll it to vertically centered position, or if it's the first index, scroll to top
		thumbnailCollectionView.selectItem(at: .init(item: index, section: 0), animated: true, scrollPosition: (index == 0) ? .top : .centeredVertically)
		// Call setNeedsLayout for all visible cells to update its opacity value
		thumbnailCollectionView.visibleCells.forEach { $0.setNeedsLayout() }
	}
	
	@objc private func createThumbnails() {
		guard let document = pdfVC.pdfView.document else { return }
		let lastIndex = document.pageCount - 1
		guard lastIndex > 0 else { return }
		
		let box = pdfVC.pdfView.displayBox
		let size = CGSize(width: 500, height: 300)
		
		// Generate thumbnails could be timely expensive, put this work into background thread.
		Task.detached {
			var imageTuples = [(Int,UIImage)]()
			await withTaskGroup(of: (Int, UIImage).self) { group in
				for index in 0 ... lastIndex {
					group.addTask(priority: .userInitiated) {
						let image = document.page(at: index)!.thumbnail(of: size, for: box)
						return (index, image)
					}
				}
				
				for await tuple in group {
					imageTuples.append(tuple)
				}
				// Sort by index, then remove indices to form an image array.
				let sortedImages = imageTuples.sorted { $0.0 < $1.0 }.compactMap { $0.1 }
				
				Task { @MainActor [weak self] in
					self?.thumbnails = sortedImages
					self?.thumbnailCollectionView.reloadData()
					self?.thumbnailCollectionView.allowsSelection = true
					// Select the first cell
					self?.thumbnailCollectionView.selectItem(at: [0, 0], animated: true, scrollPosition: .top)
				}
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
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return .init(width: collectionView.bounds.size.width * 0.9, height: collectionView.bounds.size.width * 0.6)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		.init(top: 10, left: 0, bottom: 10, right: 0)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let page = pdfVC.pdfView.document!.page(at: indexPath.item)!
		pdfVC.pdfView.go(to: page)
	}
}
