//
//  CourseAPI.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/26.
//

import Foundation


struct CourseAPI {
    
    private static let publicCourseEndPoint = baseURL.appendingPathComponent("course")

    static func getCourse(id: UUID, completionHandler: @escaping (Course?, URLResponse?, ResponseError?) -> Void) {

        let req = URLRequest(url: publicCourseEndPoint.appendingPathComponent(id.uuidString))
        URLSession.shared.courseTask(with: req, completionHandler: { course, response, error in
            guard let course = course, error == nil else {
                completionHandler(nil, response, error!)
                return
            }

            completionHandler(course, response, nil)
        }).resume()
    }
    
//    static func getCoursesForLanguage(completionHandler: @escaping ([Language.PublicInfo]?, URLResponse?, ResponseError?) -> Void) {
//        let req = URLRequest(url: publicLanguageEndPoint)
//        URLSession.shared.languagesTask(with: req) { languages, response, error in
//            guard let languages = languages, error == nil else {
//                completionHandler(nil, response, error!)
//                return
//            }
//            
//            completionHandler(languages, response, nil)
//        }.resume()
//    }
}
