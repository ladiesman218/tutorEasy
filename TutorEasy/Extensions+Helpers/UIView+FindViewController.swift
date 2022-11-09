//
//  UIView + FindViewController.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/11/7.
//

import UIKit

extension UIView {
    
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
    
}
