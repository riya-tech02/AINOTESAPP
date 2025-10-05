//
//  RecordingView.swift
//  AINotesApp
//

import SwiftUI
import Speech

struct RecordingView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var firebaseManager: FirebaseManager
    @ObservedObject var speechRecognizer: SpeechRecognizer
    
    @State private var isAnimating = false
    @State private var showingPermissionAlert = false
    @State private var transcriptionText = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.3), Color.orange.opacity(0.3)]),
                             startPoint: .topLeading,
                             endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Recording Status
                    statusView
                    
                    // Microphone Button
                    microphoneButton
                    
                    // Transcript Display
                    if !speechRecognizer.transcript.isEmpty {
                        transcriptView
                    }
                    
                    Spacer()
                    
                    // Action Buttons
                    if !speechRecognizer.transcript.isEmpty && !speechRecognizer.isRecording {
                        actionButtons
                    }
                }
                .padding()
            }
            .navigationTitle("Voice Recording")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        speechRecognizer.reset()
                        dismiss()
                    }
                }
            }
            .alert("Microphone Access Required", isPresented: $showingPermissionAlert) {
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Please enable microphone access in Settings to record voice notes.")
            }
            .onAppear {
                checkPermissions()
            }
        }
    }
    
    // MARK: - Status View
    private var statusView: some View {
        VStack(spacing: 12) {
            if speechRecognizer.isRecording {
                Text("Recording...")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Tap microphone to stop")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else if speechRecognizer.transcript.isEmpty {
                Text("Ready to Record")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Tap microphone to start")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("Recording Complete")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Review and save your note")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Microphone Button
    private var microphoneButton: some View {
        Button(action: toggleRecording) {
            ZStack {
                // Pulsing circles when recording
                if speechRecognizer.isRecording {
                    Circle()
                        .stroke(Color.red.opacity(0.3), lineWidth: 3)
                        .frame(width: 180, height: 180)
                        .scaleEffect(isAnimating ? 1.3 : 1.0)
                        .opacity(isAnimating ? 0.0 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: isAnimating)
                    
                    Circle()
                        .stroke(Color.red.opacity(0.3), lineWidth: 3)
                        .frame(width: 180, height: 180)
                        .scaleEffect(isAnimating ? 1.0 : 1.3)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: isAnimating)
                }
                
                // Main button
                Circle()
                    .fill(speechRecognizer.isRecording ? Color.red : Color.white)
                    .frame(width: 120, height: 120)
                    .shadow(color: Color.black.opacity(0.2), radius: 10)
                
                Image(systemName: speechRecognizer.isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 50))
                    .foregroundColor(speechRecognizer.isRecording ? .white : .red)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(speechRecognizer.authorizationStatus != .authorized)
        .onAppear {
            if speechRecognizer.isRecording {
                isAnimating = true
            }
        }
    }
    
    // MARK: - Transcript View
    private var transcriptView: some View {
        ScrollView {
            Text(speechRecognizer.transcript)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 5)
        }
        .frame(maxHeight: 250)
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: { speechRecognizer.reset() }) {
                Label("Clear", systemImage: "trash")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .foregroundColor(.red)
                    .cornerRadius(12)
            }
            
            Button(action: saveNote) {
                Label("Save Note", systemImage: "checkmark")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Actions
    private func toggleRecording() {
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
            isAnimating = false
        } else {
            speechRecognizer.startRecording()
            isAnimating = true
        }
    }
    
    private func checkPermissions() {
        if speechRecognizer.authorizationStatus == .denied || speechRecognizer.authorizationStatus == .restricted {
            showingPermissionAlert = true
        }
    }
    
    private func saveNote() {
        let transcript = speechRecognizer.transcript
        guard !transcript.isEmpty else { return }
        
        // Create note from transcript
        let newNote = Note(
            title: AIService.shared.generateTitle(from: transcript),
            content: transcript,
            summary: AIService.shared.summarize(transcript),
            isRecorded: true,
            tags: AIService.shared.extractKeywords(from: transcript),
            userId: firebaseManager.currentUserId
        )
        
        Task {
            do {
                try await firebaseManager.createNote(newNote)
                speechRecognizer.reset()
                dismiss()
            } catch {
                print("❌ Error saving note: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    RecordingView(firebaseManager: FirebaseManager(),
                 speechRecognizer: SpeechRecognizer())
}
