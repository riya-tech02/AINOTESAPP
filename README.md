#  AI Notes App

An intelligent iOS note-taking application powered by AI, featuring voice-to-text transcription, automatic summarization, and cloud synchronization.

![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![Firebase](https://img.shields.io/badge/Firebase-Latest-yellow.svg)

##  Features

###  AI-Powered
- **Automatic Summarization**: Condense long notes into key points using Natural Language Processing
- **Keyword Extraction**: Automatically identify and tag important keywords
- **Sentiment Analysis**: Understand the emotional tone of your notes
- **Smart Titles**: Auto-generate descriptive titles from note content

###  Voice Recording
- **Speech-to-Text**: Real-time voice transcription using Apple's Speech Recognition
- **Live Preview**: See your words appear as you speak
- **Multi-Language Support**: Support for multiple languages (configurable)

###  Cloud Sync
- **Firebase Integration**: Sync notes across all your devices
- **Offline Support**: Access and edit notes without internet connection
- **Real-time Updates**: Changes sync automatically

###  Rich Features
- **Search**: Find notes quickly with full-text search
- **Tags**: Organize notes with custom tags
- **Timestamps**: Track when notes were created and modified
- **Swipe Actions**: Quick delete with swipe gestures

##  Requirements

- iOS 16.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later
- Firebase account (free tier available)
- CocoaPods or Swift Package Manager

##  Installation

### 1. Clone the Repository

```bash
git clone https://github.com/riya shukla/ai-notes-app.git
cd ai-notes-app/AINotesApp
```

### 2. Set Up Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project (or use existing)
3. Add an iOS app to your Firebase project
4. Register your app with bundle ID: `com.yourcompany.AINotesApp`
5. Download `GoogleService-Info.plist`
6. Drag the file into your Xcode project root (ensure "Copy items if needed" is checked)

### 3. Install Dependencies

**Using Swift Package Manager (Recommended):**

1. Open `AINotesApp.xcodeproj` in Xcode
2. Go to File → Add Package Dependencies
3. Add Firebase SDK:
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```
4. Select these packages:
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseStorage

**Using CocoaPods:**

```bash
pod init
```

Edit `Podfile`:
```ruby
platform :ios, '16.0'
use_frameworks!

target 'AINotesApp' do
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
end
```

Then install:
```bash
pod install
open AINotesApp.xcworkspace
```

### 4. Configure Permissions

The app requires microphone and speech recognition permissions. These are already configured in `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access to record voice notes</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>We need speech recognition to transcribe your notes</string>
```

### 5. Build and Run

1. Select your target device or simulator
2. Press `Cmd + R` to build and run
3. Grant microphone permissions when prompted

## 📁 Project Structure

```
AINotesApp/
├── AINotesAppApp.swift          # App entry point
├── AppDelegate.swift            # Firebase configuration
├── ContentView.swift            # Main UI
├── Models/
│   ├── Note.swift              # Data model
│   └── DistilBART.mlmodel      # AI model (optional)
├── Services/
│   ├── SpeechRecognizer.swift  # Voice-to-text service
│   ├── FirebaseManager.swift   # Cloud sync service
│   └── AIService.swift         # AI features
├── Views/
│   ├── NoteDetailView.swift    # Note editor
│   └── RecordingView.swift     # Voice recording UI
└── Assets.xcassets/            # App resources
```

##  Usage

### Creating a Text Note
1. Tap the pencil icon in the top-right corner
2. Enter your content
3. Use AI features to summarize or extract keywords
4. Tap "Save" to sync to cloud

### Recording a Voice Note
1. Tap the microphone icon (red)
2. Grant microphone permission if prompted
3. Tap the microphone button to start recording
4. Speak your note
5. Tap again to stop
6. Review transcript and tap "Save Note"

### AI Features
- **Summarize**: Generate a concise summary of long notes
- **Keywords**: Extract important keywords and phrases
- **Sentiment**: Analyze the emotional tone
- **Auto-Title**: Automatically generate descriptive titles

##  Configuration

### Firebase Rules

Set up Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /notes/{noteId} {
      allow read, write: if request.auth != null && 
                           request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
  }
}
```

### Customization

Edit `AIService.swift` to customize AI behavior:

```swift
// Adjust summary length
func summarize(_ text: String, maxSentences: Int = 3)

// Change keyword limit
func extractKeywords(from text: String, limit: Int = 5)
```

##  Testing

### Unit Tests
Run unit tests with:
```bash
Cmd + U
```

### Manual Testing Checklist
- [ ] Create a text note
- [ ] Record a voice note
- [ ] Edit existing note
- [ ] Delete a note
- [ ] Search functionality
- [ ] AI summarization
- [ ] Keyword extraction
- [ ] Offline mode
- [ ] Cloud sync

##  Troubleshooting

### Common Issues

**1. Firebase Not Configured**
```
Error: Firebase not initialized
```
**Solution**: Ensure `GoogleService-Info.plist` is added to your project

**2. Microphone Permission Denied**
```
Error: Speech recognition authorization denied
```
**Solution**: Go to Settings → Privacy → Microphone → Enable for AINotesApp

**3. Build Errors**
```
Error: Cannot find 'Firebase' in scope
```
**Solution**: Clean build folder (`Cmd + Shift + K`) and rebuild

**4. Notes Not Syncing**
- Check internet connection
- Verify Firebase project is active
- Check Firestore rules are properly configured

##  Security

- All notes are stored securely in Firebase Firestore
- User authentication can be added (currently uses demo user)
- Speech data is processed on-device (not sent to servers)
- AI summarization uses local Natural Language framework

## Customization Ideas

### Add User Authentication
```swift
// In FirebaseManager.swift
import FirebaseAuth

func signIn(email: String, password: String) async throws {
    let result = try await Auth.auth().signIn(withEmail: email, password: password)
    currentUserId = result.user.uid
}
```

### Add Dark Mode Support
```swift
// Already supported! SwiftUI adapts automatically
```

### Export Notes as PDF
```swift
import PDFKit

func exportAsPDF(note: Note) -> PDFDocument {
    // Implementation
}
```

### Add Rich Text Formatting
```swift
// Replace TextEditor with UITextView wrapper
// Add formatting toolbar
```

## 📊 AI Model (Optional)

### Using CoreML Models

For advanced summarization, you can integrate a CoreML model:

1. Download DistilBART or similar model from [Hugging Face](https://huggingface.co/models)
2. Convert to CoreML format:
   ```python
   pip install coremltools transformers
   
   from transformers import AutoModelForSeq2SeqLM
   import coremltools as ct
   
   model = AutoModelForSeq2SeqLM.from_pretrained("sshleifer/distilbart-cnn-12-6")
   # Convert and export
   ```
3. Add `.mlmodel` file to Xcode project
4. Uncomment CoreML code in `AIService.swift`

##  Roadmap

- [x] Voice recording
- [x] AI summarization
- [x] Cloud sync
- [ ] User authentication
- [ ] Note sharing
- [ ] Rich text editing
- [ ] Markdown support
- [ ] Note templates
- [ ] Reminders/notifications
- [ ] Apple Watch companion app
- [ ] iPad optimization
- [ ] Widget support
- [ ] Collaboration features

##  Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

# Code Style
- Follow Swift API Design Guidelines
- Use SwiftLint for code consistency
- Write clear commit messages
- Add comments for complex logic


## 👥 Authors

- **Riya** - *Initial work* - (https://github.com/riya-tech02)

##  Acknowledgments

- Apple's Speech Recognition framework
- Firebase for backend infrastructure
- Natural Language framework for AI features
- SwiftUI community for inspiration

##  Support

- 📧 Email: riyashukla9453347726@gamil.com

##  Stats

![GitHub stars](https://img.shields.io/github/stars/riya-tech02/ai-notes-app)

---

Made with using Swift and SwiftUI
