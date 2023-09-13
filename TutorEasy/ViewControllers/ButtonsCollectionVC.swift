//
//  ButtonsCollectionVC.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/8/22.
//

import UIKit
class ButtonsCollectionVC: UICollectionViewController {
	// MARK: - Properties
	// Title text for buttons should NOT extent 5 Chinese characters
	static let fontSize = UIViewController.topViewHeight * 0.25
	static let cellIdentifier = "ButtonCell"
	
	var chapter: Chapter!
	private var buttonsArray = [ChapterButton]()
	
	// MARK: - Custom subviews
	
	// MARK: - Controller functions
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.translatesAutoresizingMaskIntoConstraints = false
		collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Self.cellIdentifier)
		collectionView.backgroundColor = .systemBlue.withAlphaComponent(0.7)
		
		let teachingPlanButton = ChapterButton(image: .init(named: "教案.png")!, titleText: "教案", fontSize: Self.fontSize, destinationURL: chapter.teachingPlanURL)
		buttonsArray.append(teachingPlanButton)
		
		let buildingInstructionButton = ChapterButton(image: .init(named: "搭建说明.png")!, titleText: "搭建说明", fontSize: Self.fontSize, destinationURL: chapter.bInstructionURL)
		buttonsArray.append(buildingInstructionButton)
		
		let sstButton = ChapterButton(image: .init(named: "双师堂")!, titleText: "双师堂", fontSize: Self.fontSize, destinationURL: chapter.sstURL)
		buttonsArray.append(sstButton)
		
		#if DEBUG
		for _ in 1 ... 10 {
			let testButton = ChapterButton(image: .init(named: "搭建说明.png")!, titleText: "搭建说明长", fontSize: Self.fontSize, destinationURL: nil)
			buttonsArray.append(testButton)
		}
		#endif
		
		for button in buttonsArray {
			button.addTarget(self, action: #selector(chapterButtonTapped), for: .touchUpInside)
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return buttonsArray.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.cellIdentifier, for: indexPath)
		
		// Remove previously added button, cuase cell is reused
		cell.contentView.subviews.forEach { $0.removeFromSuperview() }
		
		// Add the right button
		let button = buttonsArray[indexPath.item]
		cell.contentView.addSubview(button)
		button.frame = cell.contentView.bounds
		return cell
	}
	
	@objc private func chapterButtonTapped(sender: ChapterButton) {
		guard let destURL = sender.destinationURL else { return }
		let ext = destURL.pathExtension
		
		if ext == "pdf" {
			let newVC = MyPDFVC()
			newVC.pdfURL = destURL
			newVC.showCloseButton = true
			self.navigationController?.pushIfNot(newVC: newVC)
		} else if MyPDFVC.videoExtension.contains(ext) {
			let videoURL = baseURL.appendingPathComponent(FileAPI.FileType.protectedContent.rawValue).appendingPathComponent(destURL.path, isDirectory: false)
			playVideo(url: videoURL)
		}
	}
}

extension ButtonsCollectionVC: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.width)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return UIViewController.topViewHeight / 4
	}
}
