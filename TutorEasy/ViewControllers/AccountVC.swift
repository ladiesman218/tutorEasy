//
//  AccountVC.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/14.
//

import UIKit

class AccountVC: UIViewController {

    private var topView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topView = configTopView()
        setUpGoBackButton(in: topView)
        // Do any additional setup after loading the view.
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
