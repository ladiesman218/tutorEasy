//
//  ChapterDetailView.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/11/9.
//

import UIKit
import PDFKit

class ChapterDetailVC: UIViewController {
    
    // MARK: - Properties
	var chapter: Chapter! {
		didSet {
			FileAPI.getFile(path: chapter.pdfPath!) { data, response, error in
				if let data = data {
					let document = PDFDocument(data: data)!
					self.pdfView.document = document
					self.pdfView.setNeedsDisplay()
				}
			}
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
		pdfView.displayMode = .singlePageContinuous
		pdfView.backgroundColor = .yellow
		pdfView.autoScales = true
		
//		pdfView.isInMarkupMode = false
		pdfView.translatesAutoresizingMaskIntoConstraints = false
		return pdfView
	}()

	// MARK: - Controller functions
	
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
        
        NSLayoutConstraint.activate([
            chapterTitle.leadingAnchor.constraint(equalTo: backButtonView.trailingAnchor, constant: topViewHeight * 0.7),
            chapterTitle.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -topViewHeight * 2),
            chapterTitle.topAnchor.constraint(equalTo: topView.topAnchor),
            chapterTitle.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
			
			pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			pdfView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 20),
			pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension ChapterDetailVC: PDFViewDelegate {}
