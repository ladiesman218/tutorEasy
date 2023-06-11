//
//  PDFViewController.swift
//  TutorEasy
//
//  Created by Lei Gao on 2023/5/30.
//

import UIKit
import PDFKit

class PDFViewController: UIViewController {
	
	// MARK: - Properties
	var url: URL! {
		didSet {
			loadDocument()
		}
	}
	
	private var document = PDFDocument() {
		didSet {
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
		
        closeButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
//		closeButton.layer.zPosition = .greatestFiniteMagnitude
		
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
				
				// Only when document loaded succussfully, then add the close button.
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
	
	@objc func closeButtonTapped() {
		
	}
}
