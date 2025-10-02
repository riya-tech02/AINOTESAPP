//
//  Note.swift
//  AINotesApp
//

import Foundation
import FirebaseFirestore

struct Note: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var content: String
    var summary: String
    var createdAt: Date
    var updatedAt: Date
    var isRecorded: Bool
    var audioURL: String?
    var tags: [String]
    var userId: String
    
    init(id: String? = nil,
         title: String = "New Note",
         content: String = "",
         summary: String = "",
         createdAt: Date = Date(),
         updatedAt: Date = Date(),
         isRecorded: Bool = false,
         audioURL: String? = nil,
         tags: [String] = [],
         userId: String = "") {
        self.id = id
        self.title = title
        self.content = content
        self.summary = summary
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isRecorded = isRecorded
        self.audioURL = audioURL
        self.tags = tags
        self.userId = userId
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case summary
        case createdAt
        case updatedAt
        case isRecorded
        case audioURL
        case tags
        case userId
    }
    
    // Helper computed properties
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: updatedAt)
    }
    
    var preview: String {
        let maxLength = 100
        if content.count > maxLength {
            return String(content.prefix(maxLength)) + "..."
        }
        return content
    }
}
