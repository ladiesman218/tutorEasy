//
//  ButtonsCollectionVC.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/8/22.
//

import UIKit
class ButtonsCollectionVC: UICollectionViewController {
	// Title text for buttons should NOT extent 5 Chinese characters
	static let fontSize = UIViewController.topViewHeight * 0.25
	
	var chapter: Chapter!
	private var buttonsArray = [ChapterButton]()
	
	private let teachingPlanButton: ChapterButton = {
		let button = ChapterButton(image: .init(named: "教案.png")!, titleText: "教案", fontSize: fontSize)
		button.tag = 0
		return button
	}()
	
	private let buildingInstructionButton: ChapterButton = {
		let button = ChapterButton(image: .init(named: "搭建说明.png")!, titleText: "搭建说明", fontSize: fontSize)
		button.tag = 1
		return button
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()

		view.translatesAutoresizingMaskIntoConstraints = false
		collectionView.register(ButtonCell.self, forCellWithReuseIdentifier: ButtonCell.identifier)
		collectionView.backgroundColor = .systemBlue.withAlphaComponent(0.7)
		
		buttonsArray.append(teachingPlanButton)
		buttonsArray.append(buildingInstructionButton)
		
		#if DEBUG
		for _ in 1 ... 10 {
			let testButton = ChapterButton(image: .init(named: "搭建说明.png")!, titleText: "搭建说明长", fontSize: Self.fontSize)
			testButton.tag = 1
			buttonsArray.append(testButton)
		}
		
		for button in buttonsArray {
			button.addTarget(self, action: #selector(goToPDF), for: .touchUpInside)
		}
		#endif
		
		teachingPlanButton.isEnabled = chapter.teachingPlanURL != nil
		buildingInstructionButton.isEnabled = chapter.bInstructionURL != nil
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return buttonsArray.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ButtonCell.identifier, for: indexPath) as! ButtonCell
		
		cell.button = buttonsArray[indexPath.item]
		return cell
	}
	
	@objc private func goToPDF(sender: UIButton) {
		let newVC = MyPDFVC()
		switch sender.tag {
			case 0:
				// Teaching plan
				guard let url = chapter.teachingPlanURL else { return }
				newVC.pdfURL = url
			case 1:
				// Building instruction
				guard let url = chapter.bInstructionURL else { return }
				newVC.pdfURL = url
			default :
				return
		}
		
		newVC.showCloseButton = true
		self.navigationController?.pushIfNot(newVC: newVC)
	}
}

extension ButtonsCollectionVC: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.width)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 10
	}
}
