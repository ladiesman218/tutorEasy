//
//  AccountVC.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/14.
//

import UIKit

class AccountVC: UIViewController {

    // MARK: -
    private var topView: UIView!
    private var backButtonView: UIView!
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backgroundColor
        topView = configTopView(bgColor: .systemBlue.withAlphaComponent(0.6))


        backButtonView = setUpGoBackButton(in: topView)
        // Do any additional setup after loading the view.
        
        
        let button = UIButton(frame: CGRect(origin: .init(x: 100, y: 50), size: .init(width: 100, height: 40)))
        button.backgroundColor = .black
        button.setTitle("Log out", for: .normal)
        button.addTarget(self, action: #selector(logout), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc func logout() {
        AuthAPI.logout { result in
            switch result {
            case .success:
                self.navigationController?.popViewController(animated: true)
            case .failure(let reason):
                MessagePresenter.showMessage(title: "注销错误", message: reason, on: self, actions: [])
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
