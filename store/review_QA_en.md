# Store Review QA Template (English)

## App Store / Google Play Review Questions & Answers

### What does the app do?

**Answer**: Snap JP Learn is a Japanese language learning app that uses OCR (Optical Character Recognition) technology to extract Japanese text from photos. Users can:

- Take photos of Japanese text (signs, menus, books, etc.)
- Extract Japanese characters automatically using ML Kit
- Create study cards with SRS (Spaced Repetition System) for efficient learning
- Track learning progress with statistics and charts
- Store all data locally on device (no cloud sync required)

**Key Features**:
- Photo-based text extraction
- SRS learning system
- Offline functionality
- Progress tracking
- Premium features (unlimited cards)

### Why do you need camera/photo access?

**Answer**: 
- **Camera Permission**: Required to capture photos of Japanese text in real-time for immediate text extraction and learning
- **Photo Library Permission**: Required to select existing images from device gallery for text extraction

**Usage Context**:
- Users take photos of Japanese text they encounter in daily life
- The app extracts text using Google ML Kit OCR
- No photos are stored permanently - only the extracted text is saved for learning
- All processing happens on-device

### Does the app collect any data?

**Answer**: **No personal data collection**.

- All user data (photos, extracted text, learning progress) is stored locally on device only
- No data is transmitted to external servers
- No user analytics or tracking
- No advertising networks
- No third-party data sharing

**Data Storage**:
- Photos: Processed immediately, not permanently stored
- Learning data: Stored locally using Hive database
- User preferences: Stored locally using SharedPreferences

### How to access premium features?

**Answer**: 
- **Free Version**: Limited to 10 study cards
- **Premium Version**: Unlimited cards + advanced statistics + backup features

**Access Methods**:
1. **In-App Purchase**: Tap "Upgrade" button in app
2. **Test Account**: Use sandbox account for testing (iOS) / license testing (Android)
3. **Restore Purchases**: Available in Settings for existing users

**Premium Features**:
- Unlimited study card creation
- Advanced learning statistics
- Data backup and restore
- Future AI features (planned)

### Steps to reproduce main flows

**1. OCR Text Extraction Flow**:
1. Open app → Home tab
2. Tap "Camera" button → Allow camera permission
3. Take photo of Japanese text
4. View extracted text in dialog
5. Tap "Save as Post" → Text saved locally

**2. Study Card Creation Flow**:
1. Go to Posts tab → Select saved post
2. Tap "Create Cards" → Select terms to study
3. Cards created with SRS scheduling
4. View in Learn tab

**3. Learning/Review Flow**:
1. Go to Learn tab → Tap "Start Review"
2. Review cards using SRS algorithm
3. Rate difficulty (Again/Hard/Good/Easy)
4. Progress tracked in Stats tab

**4. Statistics Flow**:
1. Go to Stats tab
2. View daily/weekly/monthly progress
3. Check learning streaks and card counts

**5. Settings/Backup Flow**:
1. Go to Settings tab
2. Tap "Backup Data" → Export learning data
3. Tap "Restore Data" → Import previous backup

### Common Review Issues & Solutions

**Issue**: "App crashes on startup"
- **Solution**: Ensure device has sufficient storage and memory
- **Test**: Try on different device models and OS versions

**Issue**: "OCR not working properly"
- **Solution**: Ensure good lighting and clear text in photos
- **Test**: Try with various text types (printed, handwritten, different fonts)

**Issue**: "Permissions not requested properly"
- **Solution**: App requests permissions only when needed (camera when taking photos)
- **Test**: Deny permissions and verify graceful handling

**Issue**: "Premium features not accessible"
- **Solution**: Use sandbox account (iOS) or license testing (Android)
- **Test**: Verify purchase flow and restore functionality

### Technical Specifications

**Platform Support**:
- iOS 12.0+
- Android 6.0+ (API level 23+)

**Dependencies**:
- Google ML Kit (for OCR)
- Camera/Photo permissions
- Local storage only

**Privacy Compliance**:
- No data collection
- No third-party SDKs with tracking
- Local-only data storage
- User controls all data

### Testing Instructions for Reviewers

1. **Basic Functionality**:
   - Install app → Grant permissions → Take test photo
   - Verify OCR extraction works
   - Create study card and review it

2. **Permission Handling**:
   - Deny camera permission → Verify graceful error handling
   - Go to Settings → Re-enable → Return to app

3. **Premium Features**:
   - Try to create 11th card → Verify paywall appears
   - Test purchase flow with sandbox account

4. **Offline Functionality**:
   - Disable internet → Verify app works normally
   - All features should work without network

5. **Data Privacy**:
   - Check no network requests are made
   - Verify all data stays on device
   - Test data export/import functionality
