//
//  CourseAPI.swift
//  TutorEasy
//
//  Created by Lei Gao on 2022/10/26.
//

import Foundation


struct CourseAPI {
    
    private static let publicCourseEndPoint = baseURL.appendingPathComponent("course")
	private static let publicStageEndPoint = baseURL.appendingPathComponent("stage")

	static func getAllCourses() async -> Result<[Course], Error> {
		do {
			let (data, _) = try await URLSession.shared.dataAndResponse(from: publicCourseEndPoint)
			let courses = try Decoder.isoDate.decode([Course].self, from: data)
			return .success(courses)
		} catch {
			return .failure(error)
		}
	}
	
	// This returns course detais, including stages info
	static func getCourse(id: UUID) async -> Result<Course, Error> {
		let url = publicCourseEndPoint.appendingPathComponent(id.uuidString)
		do {
			let (data, _) = try await URLSession.shared.dataAndResponse(from: url)
			let course = try Decoder.isoDate.decode(Course.self, from: data)
			return .success(course)
		} catch {
			return .failure(error)
		}
	}
	
	// This returns stage details, including chapters info
	static func getStage(path: String) async -> Result<Stage, Error> {
		let url = publicStageEndPoint.appendingPathComponent(path)
		do {
			let (data, _) = try await URLSession.shared.dataAndResponse(from: url)
			let stage = try Decoder.isoDate.decode(Stage.self, from: data)
			return .success(stage)
		} catch {
			return .failure(error)
		}
	}
}
