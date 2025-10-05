//
//  ContentView.swift
//  AINotesApp
//

import SwiftUI

struct ContentView: View {
    @StateObject private var firebaseManager = FirebaseManager()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    @State private var showingRecordSheet = false
    @State private var showingDetailSheet = false
    @State private var selectedNote: Note?
    @State private var searchText = ""
    @State private var showingSettings = false
    
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return firebaseManager.notes
        }
        return firebaseManager.searchNotes(query: searchText)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if firebaseManager.notes.isEmpty && !firebaseManager.isLoading {
                    emptyStateView
                } else {
                    notesList
                }
                
                if firebaseManager.isLoading {
                    ProgressView("Loading notes...")
                }
            }
            .navigationTitle("AI Notes")
            .searchable(text: $searchText, prompt: "Search notes...")
            .onAppear {
                        // ADD THIS
                        print("📱 ContentView appeared")
                        print("📊 Current notes count: \(firebaseManager.notes.count)")
                        firebaseManager.fetchNotes()
                    }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingSettings.toggle() }) {
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { createTextNote() }) {
                        Image(systemName: "square.and.pencil")
                    }
                    
                    Button(action: { showingRecordSheet = true }) {
                        Image(systemName: "mic.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .sheet(isPresented: $showingRecordSheet) {
                RecordingView(firebaseManager: firebaseManager,
                            speechRecognizer: speechRecognizer)
            }
            .sheet(item: $selectedNote) { note in
                NoteDetailView(note: note, firebaseManager: firebaseManager)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
    
    // MARK: - Notes List
    private var notesList: some View {
        List {
            ForEach(filteredNotes) { note in
                NoteRowView(note: note)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedNote = note
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteNote(note)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "note.text")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("No Notes Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create your first note with text or voice")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                Button(action: { createTextNote() }) {
                    Label("Write", systemImage: "square.and.pencil")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button(action: { showingRecordSheet = true }) {
                    Label("Record", systemImage: "mic.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
    
    // MARK: - Actions
    private func createTextNote() {
        let newNote = Note(userId: firebaseManager.currentUserId)
        selectedNote = newNote
    }
    
    private func deleteNote(_ note: Note) {
        Task {
            do {
                try await firebaseManager.deleteNote(note)
            } catch {
                print("❌ Error deleting note: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Note Row View
struct NoteRowView: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                if note.isRecorded {
                    Image(systemName: "mic.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            if !note.summary.isEmpty {
                Text(note.summary)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            } else {
                Text(note.preview)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Text(note.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !note.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(note.tags.prefix(3), id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("App Info") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                }
                
                Section("AI Features") {
                    Toggle("Auto-summarize notes", isOn: .constant(true))
                    Toggle("Extract keywords", isOn: .constant(true))
                }
                
                Section("Voice Recording") {
                    Picker("Language", selection: .constant("en-US")) {
                        Text("English (US)").tag("en-US")
                        Text("English (UK)").tag("en-GB")
                        Text("Spanish").tag("es-ES")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

