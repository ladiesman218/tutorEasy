//
//  ChapterDetailView.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/11/9.
//

import UIKit

class ChapterDetailVC: UIViewController {
    
    // MARK: - Properties
    var chapter: Chapter!
    
    // MARK: - Custom subviews
    private var topView: UIView!
    private var backButtonView: UIView!
    private var chapterTitle: UILabel = {
        let chapterTitle = UILabel()
        chapterTitle.translatesAutoresizingMaskIntoConstraints = false
        chapterTitle.textColor = .white
        return chapterTitle
    }()
    
    // MARK: - Controller functions
    override func viewDidLoad() {
        topView = configTopView(bgColor: .orange)
        backButtonView = setUpGoBackButton(in: topView)
        
        chapterTitle.text = chapter.name
        chapterTitle.font = chapterTitle.font.withSize(topViewHeight / 2)
        topView.addSubview(chapterTitle)
        
        NSLayoutConstraint.activate([
            chapterTitle.leadingAnchor.constraint(equalTo: backButtonView.trailingAnchor, constant: topViewHeight * 0.7),
            chapterTitle.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -topViewHeight * 2),
            chapterTitle.topAnchor.constraint(equalTo: topView.topAnchor),
            chapterTitle.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
        ])
    }
}
