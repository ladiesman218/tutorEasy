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
	private static let publicChapterEndPoint = baseURL.appendingPathComponent("chapter")
	
	static func getAllCourses() async throws -> [Course] {
		let (data, _) = try await cachedSession.dataAndResponse(from: publicCourseEndPoint)
		
		let courses = try Decoder.isoDate.decode([Course].self, from: data)
		return courses
	}
	
	// This returns course detais, including stages info
	static func getCourse(id: UUID) async throws -> Course {
		let url = publicCourseEndPoint.appendingPathComponent(id.uuidString)
		
		let (data, _) = try await cachedSession.dataAndResponse(from: url)
		let course = try Decoder.isoDate.decode(Course.self, from: data)
		return course
		
	}
	
	// This returns stage details, including chapters info
	static func getStage(path: String) async throws -> Stage {
		let url = publicStageEndPoint.appendingPathComponent(path)
		
		let (data, _) = try await cachedSession.dataAndResponse(from: url)
		let stage = try Decoder.isoDate.decode(Stage.self, from: data)
		return stage
	}
	
	// This returns details info of a single chapter
	static func getChapter(path: String) async throws -> Chapter {
		let url = publicChapterEndPoint.appendingPathComponent(path)
		let (data, _) = try await cachedSession.dataAndResponse(from: url)
		let chapter = try Decoder.isoDate.decode(Chapter.self, from: data)
		return chapter
	}
}
