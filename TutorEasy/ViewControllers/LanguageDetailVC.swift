//
//  LangaugeDetailVCViewController.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/9/29.
//

import UIKit

class LanguageDetailVC: UIViewController {
    
    // MARK: - Properties
    var language: Language! {
        didSet {
            courseCollectionView.reloadData()
        }
    }
    
    // MARK: - Custom subviews
    let leftBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let courseCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        collectionView.register(CourseCell.self, forCellWithReuseIdentifier: CourseCell.identifier)
        collectionView.backgroundColor = .systemGray4
        collectionView.contentInset = .init(top: 40, left: 40, bottom: 0, right: 20)
        collectionView.layer.cornerRadius = 20
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    
    private var topView: UIView!
    private var backButtonView: UIView!
    private var languageNavTitle: UILabel!
    
    // MARK: - Controller functions
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        
        courseCollectionView.dataSource = self
        courseCollectionView.delegate = self
        view.addSubview(courseCollectionView)
        
        view.addSubview(leftBar)
        
        topView = configTopView(bgColor: .systemYellow.withAlphaComponent(0.8))
        backButtonView = setUpGoBackButton(in: topView, animated: false)
        
        languageNavTitle = UILabel()
        languageNavTitle.text = language.name
        languageNavTitle.font = languageNavTitle.font.withSize(topViewHeight / 2)
        languageNavTitle.translatesAutoresizingMaskIntoConstraints = false
        languageNavTitle.backgroundColor = UIColor.clear
        topView.addSubview(languageNavTitle)
        
        
        NSLayoutConstraint.activate([
            languageNavTitle.leadingAnchor.constraint(equalTo: backButtonView.trailingAnchor),
            languageNavTitle.topAnchor.constraint(equalTo: topView.topAnchor),
            languageNavTitle.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
            
            leftBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            leftBar.topAnchor.constraint(equalTo: topView.bottomAnchor),
            leftBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            leftBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2),
            
            courseCollectionView.leadingAnchor.constraint(equalTo: leftBar.trailingAnchor, constant: 20),
            courseCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            courseCollectionView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 20),
            courseCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}


extension LanguageDetailVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return language.courses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CourseCell.identifier, for: indexPath) as! CourseCell
        
        cell.layer.shadowColor = UIColor.gray.cgColor
        let cellDiemension = cell.bounds.size.width
        cell.layer.shadowOffset = .init(width: cellDiemension * 0.07, height: -(cellDiemension * 0.07))
        cell.layer.shadowOpacity = 1
        cell.layer.shadowRadius = 1
        // Generating shadows dynamically is expensive, because iOS has to draw the shadow around the exact shape of your view's contents. If you can, set the shadowPath property to a specific value so that iOS doesn't need to calculate transparency dynamically. Value 20 comes from the cornerRadius value of CourseCell's contentView
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 20).cgPath
        if let imagePath = language.courses[indexPath.item].imagePath {
            cell.imageView.downloaded(from: imagePath, contentMode: .scaleAspectFill)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right)
        
        let width = totalWidth / 3
        return .init(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let courseDetailVC = CourseDetailVC()
        let course = language.courses[indexPath.item]
        courseDetailVC.languageName = language.name
        
        CourseAPI.getCourse(id: course.id) { [unowned self] course, response, error in
            guard let course = course else { 
                MessagePresenter.showMessage(title: "获取课程失败", message: error!.reason, on: self, actions: [])
                return
            }
            courseDetailVC.course = course

            navigationController?.pushViewController(courseDetailVC, animated: true)
        }
        
    }
}
