//
//  NoteDetailView.swift
//  AINotesApp
//

import SwiftUI

struct NoteDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var firebaseManager: FirebaseManager
    
    @State private var note: Note
    @State private var isGeneratingSummary = false
    @State private var showingSummary = false
    @State private var sentiment = ""
    @State private var keywords: [String] = []
    
    init(note: Note, firebaseManager: FirebaseManager) {
        _note = State(initialValue: note)
        self.firebaseManager = firebaseManager
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Title Editor
                    TextField("Title", text: $note.title, axis: .vertical)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    // Content Editor
                    TextEditor(text: $note.content)
                        .frame(minHeight: 300)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            Group {
                                if note.content.isEmpty {
                                    Text("Start typing or paste your content...")
                                        .foregroundColor(.secondary)
                                        .padding(.top, 16)
                                        .padding(.leading, 12)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                    
                    // AI Features Section
                    if !note.content.isEmpty {
                        aiFeatureSection
                    }
                    
                    // Summary Display
                    if showingSummary && !note.summary.isEmpty {
                        summarySection
                    }
                    
                    // Keywords Display
                    if !keywords.isEmpty {
                        keywordsSection
                    }
                    
                    // Tags Editor
                    tagsSection
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                    }
                    .fontWeight(.semibold)
                    .disabled(note.content.isEmpty)
                }
            }
        }
    }
    
    // MARK: - AI Feature Section
    private var aiFeatureSection: some View {
        VStack(spacing: 12) {
            Text("AI Features")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                Button(action: generateSummary) {
                    Label("Summarize", systemImage: "text.alignleft")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(isGeneratingSummary)
                
                Button(action: extractKeywords) {
                    Label("Keywords", systemImage: "tag")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button(action: analyzeSentiment) {
                    Label("Sentiment", systemImage: "face.smiling")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            
            if isGeneratingSummary {
                ProgressView("Generating summary...")
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    // MARK: - Summary Section
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Summary")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showingSummary = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            Text(note.summary)
                .font(.body)
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    // MARK: - Keywords Section
    private var keywordsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Keywords")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(keywords, id: \.self) { keyword in
                        Text(keyword)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(16)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    // MARK: - Tags Section
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(note.tags, id: \.self) { tag in
                        HStack(spacing: 4) {
                            Text("#\(tag)")
                                .font(.subheadline)
                            
                            Button(action: { removeTag(tag) }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(16)
                    }
                    
                    Button(action: addTag) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    // MARK: - Actions
    private func generateSummary() {
        isGeneratingSummary = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let summary = AIService.shared.summarize(note.content)
            
            DispatchQueue.main.async {
                note.summary = summary
                showingSummary = true
                isGeneratingSummary = false
            }
        }
    }
    
    private func extractKeywords() {
        keywords = AIService.shared.extractKeywords(from: note.content)
    }
    
    private func analyzeSentiment() {
        sentiment = AIService.shared.analyzeSentiment(note.content)
        
        // Show sentiment as alert
        let alert = UIAlertController(title: "Sentiment Analysis",
                                     message: "This note has a \(sentiment) tone",
                                     preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(alert, animated: true)
        }
    }
    
    private func addTag() {
        let alert = UIAlertController(title: "Add Tag",
                                     message: "Enter a tag name",
                                     preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Tag name"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            if let tag = alert.textFields?.first?.text, !tag.isEmpty {
                note.tags.append(tag)
            }
        })
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(alert, animated: true)
        }
    }
    
    private func removeTag(_ tag: String) {
        note.tags.removeAll { $0 == tag }
    }
    
    private func saveNote() {
        // Auto-generate title if empty
        if note.title.isEmpty || note.title == "New Note" {
            note.title = AIService.shared.generateTitle(from: note.content)
        }
        
        Task {
            do {
                if note.id == nil {
                    try await firebaseManager.createNote(note)
                } else {
                    try await firebaseManager.updateNote(note)
                }
                dismiss()
            } catch {
                print("❌ Error saving note: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    NoteDetailView(note: Note(title: "Sample Note",
                             content: "This is a sample note for preview",
                             userId: "demo"),
                  firebaseManager: FirebaseManager())
}
