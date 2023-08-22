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
	private var fullTop: NSLayoutConstraint!
	private var noTop: NSLayoutConstraint!
	private var fullThumb: NSLayoutConstraint!
	private var noThumb: NSLayoutConstraint!
	
	let pdfVC: MyPDFVC = {
		let pdfVC = MyPDFVC()
		pdfVC.view.translatesAutoresizingMaskIntoConstraints = false
		return pdfVC
	}()
	
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
			
			// Adjust scaleFactor after size of pdfView has changed
			pdfVC.pdfView.scaleFactor = pdfVC.pdfView.scaleFactorForSizeToFit
			pdfVC.pdfView.minScaleFactor = pdfVC.pdfView.scaleFactorForSizeToFit
			pdfVC.pdfView.maxScaleFactor = pdfVC.pdfView.scaleFactorForSizeToFit
			
			// In case scrolling was happened when in full screen, then user exit full screen mode, change selected cell.
			if !isFullScreen { changeSelectedCell() }
		}
	}
	
	var chapter: Chapter! {
		didSet {
			pdfVC.pdfURL = chapter.pdfURL
		}
	}
	
	private var thumbnails: [UIImage?] = .init(repeating: nil, count: placeHolderNumber)
	
	// MARK: - Custom subviews
	private var topView: UIView!
	private var backButtonView: UIView!
	private let containerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
#warning("Add a menu button, when clicking, show the teachingplan and building instruction buttons etc")
	
	private let teachingPlanButton: ChapterButton = {
		let button = ChapterButton(image: .init(named: "教案.png")!, titleText: "教案", fontSize: 10)
		button.tag = 0
		return button
	}()
	
	private let buildingInstructionButton: ChapterButton = {
		let button = ChapterButton(image: .init(named: "搭建说明.png")!, titleText: "搭建说明", fontSize: 10)
		button.tag = 1
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
	
	// MARK: - Controller functions
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemBackground
		topView = configTopView()
		topView.backgroundColor = .orange
		backButtonView = setUpGoBackButton(in: topView)
		
		teachingPlanButton.isEnabled = chapter.teachingPlanURL != nil
		teachingPlanButton.addTarget(self, action: #selector(goToPDF), for: .touchUpInside)
		topView.addSubview(teachingPlanButton)
		
		buildingInstructionButton.isEnabled = chapter.bInstructionURL != nil
		buildingInstructionButton.addTarget(self, action: #selector(goToPDF), for: .touchUpInside)
		topView.addSubview(buildingInstructionButton)
		
		chapterTitle.text = chapter.name
		chapterTitle.font = chapterTitle.font.withSize(Self.topViewHeight / 2)
		topView.addSubview(chapterTitle)
		
		thumbnailCollectionView.delegate = self
		thumbnailCollectionView.dataSource = self
		// Disable selection, then enable it when thumbnails have been generated. Change of selection before document has been loaded crash the app.
		thumbnailCollectionView.allowsSelection = false
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
		
		self.addChild(pdfVC)
		containerView.addSubview(pdfVC.view)
		view.addSubview(containerView)
		// Allow double tap and pinch to toggle full screen
		let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleFullScreen))
		doubleTapGesture.numberOfTapsRequired = 2
		pdfVC.pdfView.addGestureRecognizer(doubleTapGesture)
		let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoom))
		pdfVC.pdfView.addGestureRecognizer(pinchGesture)
		
		// These 2 observers should only receive notifications sending from contained pdfVC's pdfView, other instance's pdfView(like clicking teaching plan button to instantiate a new MyPDFVC) will send notifications if object is set to nil.
		NotificationCenter.default.addObserver(self, selector: #selector(createThumbnails), name: .PDFViewDocumentChanged, object: pdfVC.pdfView)
		NotificationCenter.default.addObserver(self, selector: #selector(changeSelectedCell), name: .PDFViewPageChanged, object: pdfVC.pdfView)
		
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
			
			containerView.leadingAnchor.constraint(equalTo: thumbnailCollectionView.trailingAnchor),
			containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			containerView.topAnchor.constraint(equalTo: thumbnailCollectionView.topAnchor),
			containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			
			pdfVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			pdfVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			pdfVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
			pdfVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
		])
		// Button's centerVertically() should be called after constraints have been set, coz it needs button's frame to have been set first.
		teachingPlanButton.centerVertically()
		buildingInstructionButton.centerVertically()
	}
	
	@objc private func toggleFullScreen() {
		isFullScreen.toggle()
	}
	
	@objc private func zoom(sender: UIPinchGestureRecognizer) {
		if sender.scale < 1.0 {
			isFullScreen = false
		} else {
			isFullScreen = true
		}
	}
	
	// When scrolling on pdfView to change pdf page, change selected cell for thumbnail collection view, and update all visible cells' opacity value. This should be called only when not in full screen mode, otherwise it does nothing.
	@objc private func changeSelectedCell() {
		guard let labelString = pdfVC.pdfView.currentPage?.label, let labelInt = Int(labelString) else { return }
		let index = labelInt - 1
		
		// Select item, and scroll it to vertically centered position
		thumbnailCollectionView.selectItem(at: .init(item: index, section: 0), animated: true, scrollPosition: .centeredVertically)
		// Call setNeedsLayout for all visible cells to update its opacity value
		thumbnailCollectionView.visibleCells.forEach { $0.setNeedsLayout() }
	}
	
	@objc private func goToPDF(sender: UIButton) {
		let newVC = MyPDFVC()
		if sender.tag == 0 {
			// Teaching plan
			guard let url = chapter.teachingPlanURL else { return }
			newVC.pdfURL = url
		} else if sender.tag == 1 {
			// Building instruction
			guard let url = chapter.bInstructionURL else { return }
			newVC.pdfURL = url
		}
		newVC.showCloseButton = true
		self.navigationController?.pushIfNot(newVC: newVC)
	}
	
	@objc func createThumbnails() {
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
