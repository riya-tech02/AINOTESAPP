//
//  FirebaseManager.swift
//  AINotesApp
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseManager: ObservableObject {
    @Published var notes: [Note] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUserId: String = "demo_user" // Replace with Firebase Auth
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        // For demo purposes, using a fixed user ID
        // In production, integrate Firebase Auth
        fetchNotes()
    }
    
    // MARK: - Fetch Notes
    func fetchNotes() {
        isLoading = true
        
        listener = db.collection("notes")
            .whereField("userId", isEqualTo: currentUserId)
            .order(by: "updatedAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                    }
                    print("❌ Error fetching notes: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No documents found")
                    return
                }
                
                let fetchedNotes = documents.compactMap { doc -> Note? in
                    try? doc.data(as: Note.self)
                }
                
                DispatchQueue.main.async {
                    self.notes = fetchedNotes
                    print("✅ Fetched \(fetchedNotes.count) notes")
                }
            }
    }
    
    // MARK: - Create Note
    func createNote(_ note: Note) async throws {
        var newNote = note
        newNote.userId = currentUserId
        newNote.createdAt = Date()
        newNote.updatedAt = Date()
        
        do {
            let ref = try db.collection("notes").addDocument(from: newNote)
            print("✅ Note created with ID: \(ref.documentID)")
        } catch {
            print("❌ Error creating note: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Update Note
    func updateNote(_ note: Note) async throws {
        guard let noteId = note.id else {
            throw NSError(domain: "FirebaseManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Note ID is missing"])
        }
        
        var updatedNote = note
        updatedNote.updatedAt = Date()
        
        do {
            try db.collection("notes").document(noteId).setData(from: updatedNote, merge: true)
            print("✅ Note updated: \(noteId)")
        } catch {
            print("❌ Error updating note: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Delete Note
    func deleteNote(_ note: Note) async throws {
        guard let noteId = note.id else {
            throw NSError(domain: "FirebaseManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Note ID is missing"])
        }
        
        do {
            try await db.collection("notes").document(noteId).delete()
            print("✅ Note deleted: \(noteId)")
        } catch {
            print("❌ Error deleting note: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Search Notes
    func searchNotes(query: String) -> [Note] {
        guard !query.isEmpty else { return notes }
        
        let lowercasedQuery = query.lowercased()
        return notes.filter { note in
            note.title.lowercased().contains(lowercasedQuery) ||
            note.content.lowercased().contains(lowercasedQuery) ||
            note.tags.contains { $0.lowercased().contains(lowercasedQuery) }
        }
    }
    
    // MARK: - Cleanup
    deinit {
        listener?.remove()
    }
}
