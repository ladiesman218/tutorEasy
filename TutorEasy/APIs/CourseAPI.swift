//
//  CourseAPI.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/26.
//

import Foundation


struct CourseAPI {
    
    private static let publicCourseEndPoint = baseURL.appendingPathComponent("course")

	static func getAllCourses() async -> Result<[Course], Error> {
		do {
			let (data, _) = try await URLSession.shared.dataAndResponse(from: publicCourseEndPoint)
			let courses = try Decoder.isoDate.decode([Course].self, from: data)
			return .success(courses)
		} catch {
			return .failure(error)
		}
	}
	static func getCourse(id: UUID) async -> Result<Course, Error> {
		let url = publicCourseEndPoint.appendingPathComponent(id.uuidString)
		do {
			let (data, _) = try await URLSession.shared.dataAndResponse(from: url)
			print(String(data: data, encoding: .utf8))
			let course = try Decoder.isoDate.decode(Course.self, from: data)
			return .success(course)
		} catch {
			return .failure(error)
		}
	}
}
