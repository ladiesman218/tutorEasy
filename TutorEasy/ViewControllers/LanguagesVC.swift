//
//  StartViewController.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/6/25.
//

import UIKit

class LanguagesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
//	private var button: UIButton!
	private static let publicLanguageEndPoint = baseURL.appendingPathComponent("language")
	
	var collectionView: UICollectionView!
	private var languages: [Language]!

    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = .blue
		
		languages = []
		
		collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
		collectionView.backgroundColor = .systemRed
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.delegate = self
		collectionView.dataSource = self
		view.addSubview(collectionView)
		
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: view.topAnchor),
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
    }
    
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return languages.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LanguageCell.identifier, for: indexPath)
		return cell
	}
    
	static private func loadCourses(completion: @escaping (AuthResult) -> Void) {
		var req = URLRequest(url: publicLanguageEndPoint)
		req.httpMethod = "GET"
		
	}
}
